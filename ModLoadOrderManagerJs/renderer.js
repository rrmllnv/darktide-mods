// Импорты модулей
import { ModEntry } from './models/ModEntry.js';
import { FileService } from './services/FileService.js';
import { ProfileService } from './services/ProfileService.js';
import { ModScanService } from './services/ModScanService.js';
import { ModalManager } from './ui/ModalManager.js';
import { ModListRenderer } from './ui/ModListRenderer.js';
import { EventBinder } from './ui/EventBinder.js';
import { StatusManager } from './utils/StatusManager.js';

// Главный класс приложения
class ModLoadOrderManager {
    constructor() {
        // Путь к файлу mod_load_order.txt
        this.defaultPath = '';
        this.filePath = '';
        
        // Данные
        this.headerLines = [];
        this.modEntries = [];
        this.selectedModName = ''; // Одиночный выбор (для совместимости)
        this.selectedModNames = new Set(); // Множественный выбор
        this.lastSelectedModIndex = -1; // Для Shift+Click
        this.hideNewMods = false;
        this.hideUnusedMods = false;
        this.hideDeletedMods = false;
        
        // Система профилей
        this.savedState = null;
        this.profilesDir = null;
        
        // Элементы интерфейса
        this.elements = {};
        
        // Сервисы и менеджеры
        this.fileService = null;
        this.profileService = null;
        this.modScanService = null;
        this.modalManager = null;
        this.modListRenderer = null;
        this.statusManager = null;
        this.eventBinder = null;
        
        // Инициализация
        this.init();
    }
    
    async init() {
        // Получаем элементы интерфейса
        this.elements = {
            pathInput: document.getElementById('path-input'),
            browseBtn: document.getElementById('browse-btn'),
            loadBtn: document.getElementById('load-btn'),
            sortSelect: document.getElementById('sort-select'),
            enableAllBtn: document.getElementById('enable-all-btn'),
            disableAllBtn: document.getElementById('disable-all-btn'),
            scanBtn: document.getElementById('scan-btn'),
            modsList: document.getElementById('mods-list'),
            searchInput: document.getElementById('search-input'),
            clearSearchBtn: document.getElementById('clear-search-btn'),
            hideNewModsCheckbox: document.getElementById('hide-new-mods-checkbox'),
            hideUnusedModsCheckbox: document.getElementById('hide-unused-mods-checkbox'),
            hideDeletedModsCheckbox: document.getElementById('hide-deleted-mods-checkbox'),
            createSymlinkBtn: document.getElementById('create-symlink-btn'),
            profilesList: document.getElementById('profiles-list'),
            newProfileBtn: document.getElementById('new-profile-btn'),
            overwriteProfileBtn: document.getElementById('overwrite-profile-btn'),
            loadProfileBtn: document.getElementById('load-profile-btn'),
            reloadFileBtn: document.getElementById('reload-file-btn'),
            renameProfileBtn: document.getElementById('rename-profile-btn'),
            deleteProfileBtn: document.getElementById('delete-profile-btn'),
            saveBtn: document.getElementById('save-btn'),
            cancelBtn: document.getElementById('cancel-btn'),
            statusText: document.getElementById('status-text'),
            profileDialog: document.getElementById('profile-dialog'),
            modalTitle: document.getElementById('modal-title'),
            profileNameInput: document.getElementById('profile-name-input'),
            modalOkBtn: document.getElementById('modal-ok-btn'),
            modalCancelBtn: document.getElementById('modal-cancel-btn'),
            messageDialog: document.getElementById('message-dialog'),
            messageTitle: document.getElementById('message-title'),
            messageText: document.getElementById('message-text'),
            messageOkBtn: document.getElementById('message-ok-btn'),
            bulkActionsPanel: document.getElementById('bulk-actions-panel'),
            bulkSelectEnabledBtn: document.getElementById('bulk-select-enabled-btn'),
            bulkSelectDisabledBtn: document.getElementById('bulk-select-disabled-btn'),
            bulkEnableBtn: document.getElementById('bulk-enable-btn'),
            bulkDisableBtn: document.getElementById('bulk-disable-btn'),
            bulkDeleteBtn: document.getElementById('bulk-delete-btn'),
            bulkClearSelectionBtn: document.getElementById('bulk-clear-selection-btn'),
            bulkSelectionCount: document.getElementById('bulk-selection-count')
        };
        
        // Получаем путь по умолчанию
        this.defaultPath = await window.electronAPI.getDefaultPath();
        this.filePath = this.defaultPath;
        this.elements.pathInput.value = this.filePath;
        
        // Инициализация сервисов и менеджеров
        this.statusManager = new StatusManager(this.elements.statusText);
        this.fileService = new FileService((msg) => this.setStatus(msg));
        this.modalManager = new ModalManager(this.elements);
        
        // Инициализация папки профилей
        await this.initProfilesDirectory();
        
        // Инициализация сервиса сканирования
        this.modScanService = new ModScanService(this.filePath, (msg) => this.setStatus(msg));
        
        // Инициализация рендерера списка модов (создаем после инициализации сервисов)
        this.modListRenderer = new ModListRenderer(
            this.elements,
            this.modEntries,
            {
                onCheckboxChange: (modName) => this.onCheckboxChange(modName),
                onModSelect: (modName, ctrlKey, shiftKey) => this.selectMod(modName, ctrlKey, shiftKey),
                onDrop: () => {
                    const searchText = this.elements.searchInput.value;
                    this.updateModList(searchText);
                },
                getSelectedMods: () => Array.from(this.selectedModNames),
                getLastSelectedIndex: () => this.lastSelectedModIndex,
                setLastSelectedIndex: (index) => { this.lastSelectedModIndex = index; }
            }
        );
        
        // Обработка клика вне списка для очистки выбора
        document.addEventListener('click', (e) => {
            // ИСКЛЮЧАЕМ модальное окно - оно не должно мешать
            // Проверяем и сам элемент, и его родителей
            if (e.target.closest('#profile-dialog') || 
                e.target.closest('.modal') || 
                e.target.closest('.modal-content') ||
                e.target.closest('.modal-body') ||
                e.target.closest('.modal-footer') ||
                e.target.closest('.modal-header')) {
                return; // Не обрабатываем клики по модальному окну
            }
            
            // Если клик не по элементу мода и не по чекбоксу
            if (!e.target.closest('.mod-item') && !e.target.closest('#mods-list')) {
                // Очищаем выбор только если не кликнули по кнопкам массовых действий
                if (!e.target.closest('#bulk-actions-panel') && !e.target.closest('.btn-icon')) {
                    this.clearSelection();
                }
            }
        });
        
        // Привязка событий
        this.eventBinder = new EventBinder(this.elements, {
            browseFile: () => this.browseFile(),
            loadFile: () => this.loadFile(),
            onSortChange: () => this.onSortChange(),
            enableAll: () => this.enableAll(),
            disableAll: () => this.disableAll(),
            scanAndUpdate: () => this.scanAndUpdate(),
            onSearchChange: () => this.onSearchChange(),
            clearSearch: () => this.clearSearch(),
            onHideNewModsChange: (checked) => {
                this.hideNewMods = checked;
                const searchText = this.elements.searchInput.value;
                this.updateModList(searchText);
            },
            onHideUnusedModsChange: (checked) => {
                this.hideUnusedMods = checked;
                const searchText = this.elements.searchInput.value;
                this.updateModList(searchText);
            },
            onHideDeletedModsChange: (checked) => {
                this.hideDeletedMods = checked;
                const searchText = this.elements.searchInput.value;
                this.updateModList(searchText);
            },
            createSymlinkForMod: () => this.createSymlinkForMod(),
            saveCurrentProfile: () => this.saveCurrentProfile(),
            overwriteSelectedProfile: () => this.overwriteSelectedProfile(),
            loadSelectedProfile: () => this.loadSelectedProfile(),
            reloadFile: () => this.reloadFile(),
            renameSelectedProfile: () => this.renameSelectedProfile(),
            deleteSelectedProfile: () => this.deleteSelectedProfile(),
            saveFile: () => this.saveFile(),
            bulkSelectEnabled: () => this.bulkSelectEnabled(),
            bulkSelectDisabled: () => this.bulkSelectDisabled(),
            bulkEnable: () => this.bulkEnable(),
            bulkDisable: () => this.bulkDisable(),
            bulkDelete: () => this.bulkDelete(),
            bulkClearSelection: () => this.clearSelection()
        });
        
        // Загрузка файла при старте
        await this.loadFile();
    }
    
    async initProfilesDirectory() {
        try {
            const modsDir = this.filePath ? this.filePath.substring(0, this.filePath.lastIndexOf('\\')) : '';
            if (!modsDir) {
                const defaultModsDir = this.defaultPath.substring(0, this.defaultPath.lastIndexOf('\\'));
                const result = await window.electronAPI.getProfilesDirectory(defaultModsDir);
                if (result.success) {
                    this.profilesDir = result.path;
                }
            } else {
                const result = await window.electronAPI.getProfilesDirectory(modsDir);
                if (result.success) {
                    this.profilesDir = result.path;
                }
            }
            
            // Инициализация сервиса профилей
            this.profileService = new ProfileService(this.profilesDir);
            
            // Обновляем список профилей
            await this.refreshProfilesList();
        } catch (error) {
            console.error('Ошибка инициализации папки профилей:', error);
        }
    }
    
    async browseFile() {
        const result = await window.electronAPI.selectFile(this.filePath);
        if (result.success && !result.canceled) {
            this.filePath = result.filePath;
            this.elements.pathInput.value = this.filePath;
            await this.loadFile();
        }
    }
    
    async loadFile() {
        this.filePath = this.elements.pathInput.value;
        
        try {
            const parsed = await this.fileService.loadFile(this.filePath);
            this.headerLines = parsed.headerLines;
            this.modEntries = parsed.modEntries;
            
            // Обновляем ссылку на modEntries в рендерере
            if (this.modListRenderer) {
                this.modListRenderer.modEntries = this.modEntries;
            }
            
            // Обновляем сервис сканирования с новым путем
            this.modScanService = new ModScanService(this.filePath, (msg) => this.setStatus(msg));
            
            // Сканирование папки модов для поиска новых модов
            const scanResult = await this.modScanService.scanModsDirectory(this.modEntries, this.selectedModName);
            this.selectedModName = scanResult.selectedModName;
            
            // Обновляем ссылку на modEntries в рендерере после сканирования
            if (this.modListRenderer) {
                this.modListRenderer.modEntries = this.modEntries;
            }
            
            // Обновление интерфейса
            this.clearSelection(); // Очищаем выбор при загрузке файла
            this.updateModList();
            this.updateStatistics();
            
            // Обновляем папку профилей после загрузки файла
            await this.initProfilesDirectory();
            
        } catch (error) {
            await this.showMessage('Ошибка', `Не удалось загрузить файл:\n${error.message}`);
            this.setStatus(`Ошибка: ${error.message}`);
        }
    }
    
    async scanAndUpdate() {
        const scanResult = await this.modScanService.scanModsDirectory(this.modEntries, this.selectedModName);
        this.selectedModName = scanResult.selectedModName;
        
        // Обновляем ссылку на modEntries в рендерере после сканирования
        if (this.modListRenderer) {
            this.modListRenderer.modEntries = this.modEntries;
        }
        
        // Очищаем выбор удаленных модов
        if (scanResult.removed > 0) {
            const currentSelected = Array.from(this.selectedModNames);
            currentSelected.forEach(modName => {
                if (!this.modEntries.find(m => m.name === modName)) {
                    this.selectedModNames.delete(modName);
                }
            });
        }
        
        // Обновляем интерфейс
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
        
        // Показываем результат
        let message = '';
        const parts = [];
        
        if (scanResult.added > 0) {
            parts.push(`Найдено новых модов: ${scanResult.added}`);
        }
        if (scanResult.removed > 0) {
            parts.push(`Удалено не найденных модов: ${scanResult.removed}`);
        }
        if (scanResult.deleted > 0) {
            parts.push(`Помечено как удаленные: ${scanResult.deleted}`);
        }
        if (scanResult.restored > 0) {
            parts.push(`Восстановлено модов: ${scanResult.restored}`);
        }
        
        if (parts.length > 0) {
            message = parts.join('\n');
        } else {
            message = 'Изменений не обнаружено';
        }
        
        this.showMessage('Информация', message);
    }
    
    updateModList(filterText = null) {
        this.modListRenderer.updateModList(
            filterText,
            this.hideNewMods,
            this.hideUnusedMods,
            this.hideDeletedMods,
            this.selectedModName,
            this.selectedModNames
        );
        this.updateStatistics();
        this.updateBulkActionsPanel();
    }
    
    onSortChange() {
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
    }
    
    onCheckboxChange(modName) {
        const modEntry = this.modEntries.find(m => m.name === modName);
        if (modEntry && modEntry.statusElement) {
            modEntry.statusElement.textContent = modEntry.enabled ? '✓' : '✗';
            modEntry.statusElement.className = `mod-status ${modEntry.enabled ? 'enabled' : 'disabled'}`;
        }
        
        this.updateStatistics();
        
        if (this.selectedModName === modName) {
            this.selectMod(modName);
        }
    }
    
    selectMod(modName, ctrlKey = false, shiftKey = false) {
        // Получаем индекс текущего мода в отфильтрованном списке
        const filteredMods = this.modListRenderer.filteredModEntries || [];
        const currentIndex = filteredMods.findIndex(m => m.name === modName);
        
        if (shiftKey && this.lastSelectedModIndex !== -1) {
            // Shift+Click - выбираем диапазон
            const startIndex = Math.min(this.lastSelectedModIndex, currentIndex);
            const endIndex = Math.max(this.lastSelectedModIndex, currentIndex);
            
            for (let i = startIndex; i <= endIndex; i++) {
                if (filteredMods[i]) {
                    this.selectedModNames.add(filteredMods[i].name);
                }
            }
        } else if (ctrlKey) {
            // Ctrl+Click - переключаем выбор
            if (this.selectedModNames.has(modName)) {
                this.selectedModNames.delete(modName);
            } else {
                this.selectedModNames.add(modName);
            }
        } else {
            // Обычный клик - одиночный выбор
            this.selectedModNames.clear();
            this.selectedModNames.add(modName);
            this.selectedModName = modName; // Для совместимости
        }
        
        // Обновляем lastSelectedModIndex
        if (currentIndex !== -1) {
            this.lastSelectedModIndex = currentIndex;
            if (this.modListRenderer.callbacks.setLastSelectedIndex) {
                this.modListRenderer.callbacks.setLastSelectedIndex(currentIndex);
            }
        }
        
        // Обновляем визуальное выделение
        this.updateModListSelection();
        
        // Обновляем информацию о выбранном моде (для одиночного выбора)
        if (this.selectedModNames.size === 1) {
            const singleMod = Array.from(this.selectedModNames)[0];
            this.selectedModName = singleMod;
        } else {
            this.selectedModName = '';
        }
        
        this.updateBulkActionsPanel();
    }
    
    // Обновление визуального выделения выбранных модов
    updateModListSelection() {
        this.modEntries.forEach(modEntry => {
            if (modEntry.modItem) {
                if (this.selectedModNames.has(modEntry.name)) {
                    modEntry.modItem.classList.add('selected');
                } else {
                    modEntry.modItem.classList.remove('selected');
                }
            }
        });
    }
    
    // Очистка множественного выбора
    clearSelection() {
        this.selectedModNames.clear();
        this.selectedModName = '';
        this.lastSelectedModIndex = -1;
        this.updateModListSelection();
        this.updateBulkActionsPanel();
    }
    
    
    async createSymlinkForMod() {
        const modsDir = this.filePath.substring(0, this.filePath.lastIndexOf('\\'));
        if (!modsDir) {
            await this.showMessage('Ошибка', 'Не удалось определить папку модов');
            return;
        }
        
        const result = await window.electronAPI.selectFolder('');
        if (!result.success || result.canceled) {
            return;
        }
        
        const targetPath = result.folderPath;
        
        const targetExists = await window.electronAPI.fileExists(targetPath);
        if (!targetExists) {
            await this.showMessage('Ошибка', 'Выбранная папка не существует');
            return;
        }
        
        const pathParts = targetPath.split('\\');
        const defaultModName = pathParts[pathParts.length - 1];
        
        this.modalManager.showModal('Введите имя мода для симлинка:', defaultModName, async (modName) => {
            if (!modName || !modName.trim()) {
                return;
            }
            
            const cleanModName = modName.trim();
            const linkPath = modsDir + '\\' + cleanModName;
            
            const confirmed = await this.showConfirm(`Создать символическую ссылку?\n\nИз: ${targetPath}\nВ: ${linkPath}\n\nИмя: ${cleanModName}`);
            if (!confirmed) {
                return;
            }
            
            try {
                const symlinkResult = await window.electronAPI.createSymlink(linkPath, targetPath);
                if (!symlinkResult.success) {
                    await this.showMessage('Ошибка', `Не удалось создать символическую ссылку:\n${symlinkResult.error}`);
                    return;
                }
                
                await this.showMessage('Успех', `Символическая ссылка успешно создана!\n\n${linkPath} -> ${targetPath}`);
                this.setStatus(`Символическая ссылка создана: ${cleanModName}`);
                
                await this.scanAndUpdate();
            } catch (error) {
                await this.showMessage('Ошибка', `Ошибка при создании символической ссылки:\n${error.message}`);
            }
        });
    }
    
    updateStatistics() {
        this.statusManager.updateStatistics(this.modEntries);
    }
    
    
    onSearchChange() {
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
    }
    
    clearSearch() {
        this.elements.searchInput.value = '';
        this.updateModList();
    }
    
    enableAll() {
        this.modEntries.forEach(modEntry => {
            modEntry.enabled = true;
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = true;
            }
        });
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
    }
    
    disableAll() {
        this.modEntries.forEach(modEntry => {
            modEntry.enabled = false;
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = false;
            }
        });
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
    }
    
    async saveFile() {
        if (this.modEntries.length === 0) {
            await this.showMessage('Ошибка', 'Нет модов для сохранения');
            return;
        }
        
        try {
            await this.fileService.saveFile(this.filePath, this.headerLines, this.modEntries);
            
            await this.showMessage('Успех', 'Файл успешно сохранен!');
            this.setStatus('Файл сохранен');
            
            await this.loadFile();
            
        } catch (error) {
            await this.showMessage('Ошибка', `Не удалось сохранить файл:\n${error.message}`);
            this.setStatus(`Ошибка сохранения: ${error.message}`);
        }
    }
    
    saveCurrentState() {
        return this.profileService.saveState(this.modEntries);
    }
    
    restoreState(state) {
        const result = this.profileService.restoreState(state, this.modEntries);
        this.modEntries = result.modEntries;
        
        // Очищаем все старые ссылки на DOM элементы, чтобы они не мешали
        this.modEntries.forEach(modEntry => {
            modEntry.checkbox = null;
            modEntry.statusElement = null;
            modEntry.modItem = null;
        });
        
        // Обновляем ссылку на modEntries в рендерере
        if (this.modListRenderer) {
            this.modListRenderer.modEntries = this.modEntries;
        }
        
        // Очищаем выбор при восстановлении состояния
        this.clearSelection();
        
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
    }
    
    async refreshProfilesList() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        this.elements.profilesList.innerHTML = '';
        
        if (!this.profilesDir) {
            return;
        }
        
        try {
            const result = await this.profileService.listProfiles();
            if (result.success) {
                result.profiles.forEach(profileName => {
                    const option = document.createElement('option');
                    option.value = profileName;
                    option.textContent = profileName;
                    this.elements.profilesList.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Ошибка обновления списка профилей:', error);
        }
    }
    
    async saveCurrentProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            await this.showMessage('Ошибка', 'Не удалось определить папку для профилей');
            return;
        }
        
        this.modalManager.showModal('Введите имя профиля:', '', async (profileName) => {
            if (!profileName) {
                return;
            }
            
            const cleanName = profileName.replace(/[^a-zA-Z0-9\s\-_]/g, '').trim();
            if (!cleanName) {
                await this.showMessage('Ошибка', 'Недопустимое имя профиля');
                return;
            }
            
            try {
                const state = this.saveCurrentState();
                const result = await this.profileService.saveProfile(cleanName, state);
                
                if (!result.success) {
                    await this.showMessage('Ошибка', `Не удалось сохранить профиль:\n${result.error}`);
                    return;
                }
                
                await this.refreshProfilesList();
                await this.showMessage('Успех', `Профиль '${cleanName}' сохранен`);
            } catch (error) {
                await this.showMessage('Ошибка', `Не удалось сохранить профиль:\n${error.message}`);
            }
        });
    }
    
    async loadSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            await this.showMessage('Ошибка', 'Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            await this.showMessage('Ошибка', 'Выберите профиль из списка');
            return;
        }
        
        const profileName = this.elements.profilesList.options[selectedIndex].value;
        
        try {
            const result = await this.profileService.loadProfile(profileName);
            if (!result.success) {
                await this.showMessage('Ошибка', `Не удалось загрузить профиль:\n${result.error}`);
                return;
            }
            
            this.restoreState(result.state);
            
            // Обновляем ссылку на modEntries в рендерере после восстановления
            if (this.modListRenderer) {
                this.modListRenderer.modEntries = this.modEntries;
            }
            
            // Сканируем папку модов после загрузки профиля
            const scanResult = await this.modScanService.scanModsDirectory(this.modEntries, this.selectedModName);
            this.selectedModName = scanResult.selectedModName;
            
            // Обновляем ссылку на modEntries в рендерере после сканирования
            if (this.modListRenderer) {
                this.modListRenderer.modEntries = this.modEntries;
            }
            
            // Очищаем выбор удаленных модов
            if (scanResult.removed > 0) {
                const currentSelected = Array.from(this.selectedModNames);
                currentSelected.forEach(modName => {
                    if (!this.modEntries.find(m => m.name === modName)) {
                        this.selectedModNames.delete(modName);
                    }
                });
            }
            
            const searchText = this.elements.searchInput.value;
            this.updateModList(searchText);
            this.updateStatistics();
            
            await this.showMessage('Успех', `Профиль '${profileName}' загружен`);
        } catch (error) {
            await this.showMessage('Ошибка', `Не удалось загрузить профиль:\n${error.message}`);
        }
    }
    
    async reloadFile() {
        const confirmed = await this.showConfirm('Вернуться к исходному состоянию файла?\n\nВсе несохраненные изменения будут потеряны.');
        if (confirmed) {
            await this.loadFile();
            this.setStatus('Файл перезагружен. Состояние восстановлено из файла.');
        }
    }
    
    async renameSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            await this.showMessage('Ошибка', 'Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            await this.showMessage('Ошибка', 'Выберите профиль из списка');
            return;
        }
        
        const oldProfileName = this.elements.profilesList.options[selectedIndex].value;
        
        this.modalManager.showModal(`Введите новое имя для профиля '${oldProfileName}':`, oldProfileName, async (newProfileName) => {
            if (!newProfileName) {
                return;
            }
            
            const cleanName = newProfileName.replace(/[^a-zA-Z0-9\s\-_]/g, '').trim();
            if (!cleanName) {
                await this.showMessage('Ошибка', 'Недопустимое имя профиля');
                return;
            }
            
            if (cleanName === oldProfileName) {
                return;
            }
            
            try {
                const result = await this.profileService.renameProfile(oldProfileName, cleanName);
                if (!result.success) {
                    await this.showMessage('Ошибка', `Не удалось переименовать профиль:\n${result.error}`);
                    return;
                }
                
                await this.refreshProfilesList();
                await this.showMessage('Успех', `Профиль '${oldProfileName}' переименован в '${cleanName}'`);
            } catch (error) {
                await this.showMessage('Ошибка', `Не удалось переименовать профиль:\n${error.message}`);
            }
        });
    }
    
    async overwriteSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            await this.showMessage('Ошибка', 'Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            await this.showMessage('Ошибка', 'Выберите профиль из списка для перезаписи');
            return;
        }
        
        const profileName = this.elements.profilesList.options[selectedIndex].value;
        
        const confirmed = await this.showConfirm(`Перезаписать профиль '${profileName}' текущим состоянием?`);
        if (!confirmed) {
            return;
        }
        
        try {
            const state = this.saveCurrentState();
            const result = await this.profileService.saveProfile(profileName, state);
            
            if (!result.success) {
                await this.showMessage('Ошибка', `Не удалось перезаписать профиль:\n${result.error}`);
                return;
            }
            
            await this.showMessage('Успех', `Профиль '${profileName}' перезаписан`);
        } catch (error) {
            await this.showMessage('Ошибка', `Не удалось перезаписать профиль:\n${error.message}`);
        }
    }
    
    async deleteSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            await this.showMessage('Ошибка', 'Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            await this.showMessage('Ошибка', 'Выберите профиль из списка');
            return;
        }
        
        const profileName = this.elements.profilesList.options[selectedIndex].value;
        
        const confirmed = await this.showConfirm(`Удалить профиль '${profileName}'?`);
        if (!confirmed) {
            return;
        }
        
        try {
            const result = await this.profileService.deleteProfile(profileName);
            if (!result.success) {
                await this.showMessage('Ошибка', `Не удалось удалить профиль:\n${result.error}`);
                return;
            }
            
            await this.refreshProfilesList();
            await this.showMessage('Успех', `Профиль '${profileName}' удален`);
        } catch (error) {
            await this.showMessage('Ошибка', `Не удалось удалить профиль:\n${error.message}`);
        }
    }
    
    setStatus(message) {
        this.statusManager.setStatus(message);
    }
    
    // Показ сообщения в модальном окне вместо alert
    showMessage(title, message) {
        return new Promise((resolve) => {
            // Восстанавливаем кнопку OK на случай, если она была заменена
            const footer = this.elements.messageDialog.querySelector('.modal-footer');
            if (!footer.querySelector('#message-ok-btn')) {
                footer.innerHTML = '<button id="message-ok-btn" class="btn btn-primary">OK</button>';
                this.elements.messageOkBtn = document.getElementById('message-ok-btn');
            } else {
                // Обновляем ссылку на кнопку, если она уже есть
                this.elements.messageOkBtn = document.getElementById('message-ok-btn');
            }
            
            this.elements.messageTitle.textContent = title || 'Сообщение';
            this.elements.messageText.textContent = message;
            this.elements.messageDialog.classList.add('show');
            
            // Удаляем старые обработчики, если есть
            const newOkBtn = this.elements.messageOkBtn.cloneNode(true);
            this.elements.messageOkBtn.parentNode.replaceChild(newOkBtn, this.elements.messageOkBtn);
            this.elements.messageOkBtn = newOkBtn;
            
            const handleOk = () => {
                this.elements.messageDialog.classList.remove('show');
                this.elements.messageOkBtn.removeEventListener('click', handleOk);
                resolve();
            };
            
            this.elements.messageOkBtn.addEventListener('click', handleOk);
        });
    }
    
    // Показ подтверждения в модальном окне вместо confirm
    showConfirm(message) {
        return new Promise((resolve) => {
            this.elements.messageTitle.textContent = 'Подтверждение';
            this.elements.messageText.textContent = message;
            
            // Заменяем кнопку OK на две кнопки Да/Нет
            const footer = this.elements.messageDialog.querySelector('.modal-footer');
            footer.innerHTML = `
                <button id="confirm-yes-btn" class="btn btn-primary">Да</button>
                <button id="confirm-no-btn" class="btn">Нет</button>
            `;
            
            this.elements.messageDialog.classList.add('show');
            
            const yesBtn = document.getElementById('confirm-yes-btn');
            const noBtn = document.getElementById('confirm-no-btn');
            
            const handleYes = () => {
                this.elements.messageDialog.classList.remove('show');
                // Восстанавливаем кнопку OK
                footer.innerHTML = '<button id="message-ok-btn" class="btn btn-primary">OK</button>';
                this.elements.messageOkBtn = document.getElementById('message-ok-btn');
                yesBtn.removeEventListener('click', handleYes);
                noBtn.removeEventListener('click', handleNo);
                resolve(true);
            };
            
            const handleNo = () => {
                this.elements.messageDialog.classList.remove('show');
                // Восстанавливаем кнопку OK
                footer.innerHTML = '<button id="message-ok-btn" class="btn btn-primary">OK</button>';
                this.elements.messageOkBtn = document.getElementById('message-ok-btn');
                yesBtn.removeEventListener('click', handleYes);
                noBtn.removeEventListener('click', handleNo);
                resolve(false);
            };
            
            yesBtn.addEventListener('click', handleYes);
            noBtn.addEventListener('click', handleNo);
        });
    }
    
    // Обновление панели массовых действий
    updateBulkActionsPanel() {
        if (!this.elements.bulkActionsPanel) {
            return;
        }
        
        const count = this.selectedModNames.size;
        const hasSelection = count >= 1;
        
        // Обновляем текст счетчика
        if (this.elements.bulkSelectionCount) {
            if (count === 0) {
                this.elements.bulkSelectionCount.textContent = 'Нет выбранных модов';
            } else {
                const modText = count === 1 ? 'мод' : count < 5 ? 'мода' : 'модов';
                this.elements.bulkSelectionCount.textContent = `${count} ${modText} выбрано`;
            }
        }
        
        // Делаем кнопки активными/неактивными в зависимости от выбора
        if (this.elements.bulkEnableBtn) {
            this.elements.bulkEnableBtn.disabled = !hasSelection;
        }
        if (this.elements.bulkDisableBtn) {
            this.elements.bulkDisableBtn.disabled = !hasSelection;
        }
        if (this.elements.bulkDeleteBtn) {
            this.elements.bulkDeleteBtn.disabled = !hasSelection;
        }
        if (this.elements.bulkClearSelectionBtn) {
            this.elements.bulkClearSelectionBtn.disabled = !hasSelection;
        }
        
        // Добавляем/убираем класс для визуального отображения неактивного состояния
        if (hasSelection) {
            this.elements.bulkActionsPanel.classList.remove('disabled');
        } else {
            this.elements.bulkActionsPanel.classList.add('disabled');
        }
    }
    
    // Выделить все включенные моды
    bulkSelectEnabled() {
        this.selectedModNames.clear();
        this.selectedModName = '';
        this.lastSelectedModIndex = -1;
        
        this.modEntries.forEach(modEntry => {
            if (modEntry.enabled) {
                this.selectedModNames.add(modEntry.name);
            }
        });
        
        // Обновляем визуальное выделение
        this.updateModListSelection();
        
        this.updateBulkActionsPanel();
    }
    
    // Выделить все выключенные моды
    bulkSelectDisabled() {
        this.selectedModNames.clear();
        this.selectedModName = '';
        this.lastSelectedModIndex = -1;
        
        this.modEntries.forEach(modEntry => {
            if (!modEntry.enabled) {
                this.selectedModNames.add(modEntry.name);
            }
        });
        
        // Обновляем визуальное выделение
        this.updateModListSelection();
        
        this.updateBulkActionsPanel();
    }
    
    // Массовое включение выбранных модов
    bulkEnable() {
        const selected = Array.from(this.selectedModNames);
        if (selected.length === 0) {
            return;
        }
        
        selected.forEach(modName => {
            const modEntry = this.modEntries.find(m => m.name === modName);
            if (modEntry) {
                modEntry.enabled = true;
                if (modEntry.checkbox) {
                    modEntry.checkbox.checked = true;
                }
                if (modEntry.statusElement) {
                    modEntry.statusElement.textContent = '✓';
                    modEntry.statusElement.className = 'mod-status enabled';
                }
            }
        });
        
        this.updateStatistics();
        this.setStatus(`Включено модов: ${selected.length}`);
    }
    
    // Массовое выключение выбранных модов
    bulkDisable() {
        const selected = Array.from(this.selectedModNames);
        if (selected.length === 0) {
            return;
        }
        
        selected.forEach(modName => {
            const modEntry = this.modEntries.find(m => m.name === modName);
            if (modEntry) {
                modEntry.enabled = false;
                if (modEntry.checkbox) {
                    modEntry.checkbox.checked = false;
                }
                if (modEntry.statusElement) {
                    modEntry.statusElement.textContent = '✗';
                    modEntry.statusElement.className = 'mod-status disabled';
                }
            }
        });
        
        this.updateStatistics();
        this.setStatus(`Выключено модов: ${selected.length}`);
    }
    
    // Массовое удаление выбранных модов
    async bulkDelete() {
        const selected = Array.from(this.selectedModNames);
        if (selected.length === 0) {
            return;
        }
        
        const confirmed = await this.showConfirm(`Удалить ${selected.length} выбранных модов из списка?\n\nМоды будут удалены из файла при сохранении.`);
        if (!confirmed) {
            return;
        }
        
        // Удаляем моды из списка
        selected.forEach(modName => {
            const modIndex = this.modEntries.findIndex(m => m.name === modName);
            if (modIndex !== -1) {
                this.modEntries.splice(modIndex, 1);
            }
        });
        
        // Обновляем ссылку в рендерере
        if (this.modListRenderer) {
            this.modListRenderer.modEntries = this.modEntries;
        }
        
        // Очищаем выбор
        this.clearSelection();
        
        // Обновляем интерфейс
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
        
        this.setStatus(`Удалено модов: ${selected.length}. Не забудьте сохранить файл.`);
    }
}

// Инициализация приложения при загрузке страницы
let app;
document.addEventListener('DOMContentLoaded', () => {
    app = new ModLoadOrderManager();
});
