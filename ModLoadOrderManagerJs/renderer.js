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
        this.selectedModName = '';
        this.hideNewMods = false;
        this.hideUnusedMods = false;
        
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
            selectedModInfo: document.getElementById('selected-mod-info'),
            deleteModBtn: document.getElementById('delete-mod-btn'),
            createSymlinkBtn: document.getElementById('create-symlink-btn'),
            moveUpBtn: document.getElementById('move-up-btn'),
            moveDownBtn: document.getElementById('move-down-btn'),
            onlyThisModBtn: document.getElementById('only-this-mod-btn'),
            restoreStateBtn: document.getElementById('restore-state-btn'),
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
            modalCancelBtn: document.getElementById('modal-cancel-btn')
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
                onModSelect: (modName) => this.selectMod(modName),
                onDrop: () => {
                    const searchText = this.elements.searchInput.value;
                    this.updateModList(searchText);
                }
            }
        );
        
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
            deleteSelectedMod: () => this.deleteSelectedMod(),
            createSymlinkForMod: () => this.createSymlinkForMod(),
            moveModUp: () => this.moveModUp(),
            moveModDown: () => this.moveModDown(),
            enableOnlyThisMod: () => this.enableOnlyThisMod(),
            restoreSavedState: () => this.restoreSavedState(),
            saveCurrentProfile: () => this.saveCurrentProfile(),
            overwriteSelectedProfile: () => this.overwriteSelectedProfile(),
            loadSelectedProfile: () => this.loadSelectedProfile(),
            reloadFile: () => this.reloadFile(),
            renameSelectedProfile: () => this.renameSelectedProfile(),
            deleteSelectedProfile: () => this.deleteSelectedProfile(),
            saveFile: () => this.saveFile()
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
            this.updateModList();
            this.updateStatistics();
            
            // Обновляем папку профилей после загрузки файла
            await this.initProfilesDirectory();
            
        } catch (error) {
            alert(`Не удалось загрузить файл:\n${error.message}`);
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
        
        // Обновляем интерфейс
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
        
        // Показываем результат
        let message = '';
        if (scanResult.added > 0 && scanResult.removed > 0) {
            message = `Найдено новых модов: ${scanResult.added}\nУдалено несуществующих модов: ${scanResult.removed}`;
        } else if (scanResult.added > 0) {
            message = `Найдено новых модов: ${scanResult.added}`;
        } else if (scanResult.removed > 0) {
            message = `Удалено несуществующих модов: ${scanResult.removed}`;
        } else {
            message = 'Изменений не обнаружено';
        }
        
        alert(message);
    }
    
    updateModList(filterText = null) {
        this.modListRenderer.updateModList(
            filterText,
            this.hideNewMods,
            this.hideUnusedMods,
            this.selectedModName
        );
        this.updateStatistics();
    }
    
    onSortChange() {
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateMoveButtonsState();
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
    
    selectMod(modName) {
        if (this.selectedModName) {
            const prevMod = this.modEntries.find(m => m.name === this.selectedModName);
            if (prevMod && prevMod.modItem) {
                prevMod.modItem.classList.remove('selected');
            }
        }
        
        this.selectedModName = modName;
        
        const modEntry = this.modEntries.find(m => m.name === modName);
        if (modEntry) {
            if (modEntry.modItem) {
                modEntry.modItem.classList.add('selected');
            }
            
            const status = modEntry.enabled ? 'Включен' : 'Выключен';
            let infoText = `${modName}\nСтатус: ${status}`;
            if (modEntry.isNew) {
                infoText += '\n⚠ Новый мод (не был в файле)';
            }
            this.elements.selectedModInfo.textContent = infoText;
            
            this.updateMoveButtonsState();
            this.updateQuickSwitchButtons();
            this.updateDeleteButtonState();
        } else {
            this.elements.selectedModInfo.textContent = 'Нет выбора';
            this.elements.moveUpBtn.disabled = true;
            this.elements.moveDownBtn.disabled = true;
            this.elements.onlyThisModBtn.disabled = true;
            this.elements.deleteModBtn.disabled = true;
        }
    }
    
    updateDeleteButtonState() {
        this.elements.deleteModBtn.disabled = !this.selectedModName;
    }
    
    deleteSelectedMod() {
        if (!this.selectedModName) {
            return;
        }
        
        if (!confirm(`Удалить мод '${this.selectedModName}' из списка?\n\nМод будет удален из файла при сохранении.`)) {
            return;
        }
        
        const modIndex = this.modEntries.findIndex(m => m.name === this.selectedModName);
        if (modIndex === -1) {
            return;
        }
        
        this.modEntries.splice(modIndex, 1);
        
        // Обновляем ссылку на modEntries в рендерере
        if (this.modListRenderer) {
            this.modListRenderer.modEntries = this.modEntries;
        }
        
        this.selectedModName = '';
        this.elements.selectedModInfo.textContent = 'Нет выбора';
        
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
        
        this.elements.moveUpBtn.disabled = true;
        this.elements.moveDownBtn.disabled = true;
        this.elements.onlyThisModBtn.disabled = true;
        this.elements.deleteModBtn.disabled = true;
        
        this.setStatus(`Мод удален из списка. Не забудьте сохранить файл.`);
    }
    
    async createSymlinkForMod() {
        const modsDir = this.filePath.substring(0, this.filePath.lastIndexOf('\\'));
        if (!modsDir) {
            alert('Не удалось определить папку модов');
            return;
        }
        
        const result = await window.electronAPI.selectFolder('');
        if (!result.success || result.canceled) {
            return;
        }
        
        const targetPath = result.folderPath;
        
        const targetExists = await window.electronAPI.fileExists(targetPath);
        if (!targetExists) {
            alert('Выбранная папка не существует');
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
            
            if (!confirm(`Создать символическую ссылку?\n\nИз: ${targetPath}\nВ: ${linkPath}\n\nИмя: ${cleanModName}`)) {
                return;
            }
            
            try {
                const symlinkResult = await window.electronAPI.createSymlink(linkPath, targetPath);
                if (!symlinkResult.success) {
                    alert(`Не удалось создать символическую ссылку:\n${symlinkResult.error}`);
                    return;
                }
                
                alert(`Символическая ссылка успешно создана!\n\n${linkPath} -> ${targetPath}`);
                this.setStatus(`Символическая ссылка создана: ${cleanModName}`);
                
                await this.scanAndUpdate();
            } catch (error) {
                alert(`Ошибка при создании символической ссылки:\n${error.message}`);
            }
        });
    }
    
    updateStatistics() {
        this.statusManager.updateStatistics(this.modEntries);
    }
    
    updateMoveButtonsState() {
        const currentSort = this.elements.sortSelect.value;
        
        if (!this.selectedModName || currentSort !== 'По порядку файла') {
            this.elements.moveUpBtn.disabled = true;
            this.elements.moveDownBtn.disabled = true;
            return;
        }
        
        const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        const modIndex = sortedMods.findIndex(m => m.name === this.selectedModName);
        
        if (modIndex === -1) {
            this.elements.moveUpBtn.disabled = true;
            this.elements.moveDownBtn.disabled = true;
            return;
        }
        
        this.elements.moveUpBtn.disabled = modIndex <= 0;
        this.elements.moveDownBtn.disabled = modIndex >= sortedMods.length - 1;
    }
    
    moveModUp() {
        if (!this.selectedModName) {
            return;
        }
        
        const modEntry = this.modEntries.find(m => m.name === this.selectedModName);
        if (!modEntry) {
            return;
        }
        
        const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        const currentIndex = sortedMods.findIndex(m => m.name === this.selectedModName);
        
        if (currentIndex <= 0) {
            return;
        }
        
        const prevMod = sortedMods[currentIndex - 1];
        [modEntry.orderIndex, prevMod.orderIndex] = [prevMod.orderIndex, modEntry.orderIndex];
        
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateMoveButtonsState();
    }
    
    moveModDown() {
        if (!this.selectedModName) {
            return;
        }
        
        const modEntry = this.modEntries.find(m => m.name === this.selectedModName);
        if (!modEntry) {
            return;
        }
        
        const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        const currentIndex = sortedMods.findIndex(m => m.name === this.selectedModName);
        
        if (currentIndex < 0 || currentIndex >= sortedMods.length - 1) {
            return;
        }
        
        const nextMod = sortedMods[currentIndex + 1];
        [modEntry.orderIndex, nextMod.orderIndex] = [nextMod.orderIndex, modEntry.orderIndex];
        
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateMoveButtonsState();
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
            alert('Нет модов для сохранения');
            return;
        }
        
        try {
            await this.fileService.saveFile(this.filePath, this.headerLines, this.modEntries);
            
            alert('Файл успешно сохранен!');
            this.setStatus('Файл сохранен');
            
            await this.loadFile();
            
        } catch (error) {
            alert(`Не удалось сохранить файл:\n${error.message}`);
            this.setStatus(`Ошибка сохранения: ${error.message}`);
        }
    }
    
    saveCurrentState() {
        return this.profileService.saveState(this.modEntries);
    }
    
    restoreState(state) {
        const result = this.profileService.restoreState(state, this.modEntries);
        this.modEntries = result.modEntries;
        
        for (const modEntry of this.modEntries) {
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = modEntry.enabled;
            }
        }
        
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
    }
    
    enableOnlyThisMod() {
        if (!this.selectedModName) {
            return;
        }
        
        this.savedState = this.saveCurrentState();
        
        for (const modEntry of this.modEntries) {
            modEntry.enabled = false;
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = false;
            }
        }
        
        const modEntry = this.modEntries.find(m => m.name === this.selectedModName);
        if (modEntry) {
            modEntry.enabled = true;
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = true;
            }
        }
        
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
        
        this.updateQuickSwitchButtons();
        
        alert(`Включен только мод: ${this.selectedModName}\nИспользуйте 'Вернуть все' для восстановления.`);
    }
    
    restoreSavedState() {
        if (!this.savedState) {
            alert('Нет сохраненного состояния для восстановления');
            return;
        }
        
        this.restoreState(this.savedState);
        this.savedState = null;
        
        this.updateQuickSwitchButtons();
        
        alert('Состояние модов восстановлено');
    }
    
    updateQuickSwitchButtons() {
        this.elements.onlyThisModBtn.disabled = !this.selectedModName;
        this.elements.restoreStateBtn.disabled = !this.savedState;
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
            alert('Не удалось определить папку для профилей');
            return;
        }
        
        this.modalManager.showModal('Введите имя профиля:', '', async (profileName) => {
            if (!profileName) {
                return;
            }
            
            const cleanName = profileName.replace(/[^a-zA-Z0-9\s\-_]/g, '').trim();
            if (!cleanName) {
                alert('Недопустимое имя профиля');
                return;
            }
            
            try {
                const state = this.saveCurrentState();
                const result = await this.profileService.saveProfile(cleanName, state);
                
                if (!result.success) {
                    alert(`Не удалось сохранить профиль:\n${result.error}`);
                    return;
                }
                
                await this.refreshProfilesList();
                alert(`Профиль '${cleanName}' сохранен`);
            } catch (error) {
                alert(`Не удалось сохранить профиль:\n${error.message}`);
            }
        });
    }
    
    async loadSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            alert('Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            alert('Выберите профиль из списка');
            return;
        }
        
        const profileName = this.elements.profilesList.options[selectedIndex].value;
        
        try {
            const result = await this.profileService.loadProfile(profileName);
            if (!result.success) {
                alert(`Не удалось загрузить профиль:\n${result.error}`);
                return;
            }
            
            this.restoreState(result.state);
            
            await this.modScanService.scanModsDirectory(this.modEntries, this.selectedModName);
            
            const searchText = this.elements.searchInput.value;
            this.updateModList(searchText);
            this.updateStatistics();
            
            alert(`Профиль '${profileName}' загружен`);
        } catch (error) {
            alert(`Не удалось загрузить профиль:\n${error.message}`);
        }
    }
    
    async reloadFile() {
        if (confirm('Вернуться к исходному состоянию файла?\n\nВсе несохраненные изменения будут потеряны.')) {
            await this.loadFile();
            this.setStatus('Файл перезагружен. Состояние восстановлено из файла.');
        }
    }
    
    async renameSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            alert('Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            alert('Выберите профиль из списка');
            return;
        }
        
        const oldProfileName = this.elements.profilesList.options[selectedIndex].value;
        
        this.modalManager.showModal(`Введите новое имя для профиля '${oldProfileName}':`, oldProfileName, async (newProfileName) => {
            if (!newProfileName) {
                return;
            }
            
            const cleanName = newProfileName.replace(/[^a-zA-Z0-9\s\-_]/g, '').trim();
            if (!cleanName) {
                alert('Недопустимое имя профиля');
                return;
            }
            
            if (cleanName === oldProfileName) {
                return;
            }
            
            try {
                const result = await this.profileService.renameProfile(oldProfileName, cleanName);
                if (!result.success) {
                    alert(`Не удалось переименовать профиль:\n${result.error}`);
                    return;
                }
                
                await this.refreshProfilesList();
                alert(`Профиль '${oldProfileName}' переименован в '${cleanName}'`);
            } catch (error) {
                alert(`Не удалось переименовать профиль:\n${error.message}`);
            }
        });
    }
    
    async overwriteSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            alert('Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            alert('Выберите профиль из списка для перезаписи');
            return;
        }
        
        const profileName = this.elements.profilesList.options[selectedIndex].value;
        
        if (!confirm(`Перезаписать профиль '${profileName}' текущим состоянием?`)) {
            return;
        }
        
        try {
            const state = this.saveCurrentState();
            const result = await this.profileService.saveProfile(profileName, state);
            
            if (!result.success) {
                alert(`Не удалось перезаписать профиль:\n${result.error}`);
                return;
            }
            
            alert(`Профиль '${profileName}' перезаписан`);
        } catch (error) {
            alert(`Не удалось перезаписать профиль:\n${error.message}`);
        }
    }
    
    async deleteSelectedProfile() {
        if (!this.profilesDir) {
            await this.initProfilesDirectory();
        }
        
        if (!this.profilesDir) {
            alert('Не удалось определить папку для профилей');
            return;
        }
        
        const selectedIndex = this.elements.profilesList.selectedIndex;
        if (selectedIndex === -1) {
            alert('Выберите профиль из списка');
            return;
        }
        
        const profileName = this.elements.profilesList.options[selectedIndex].value;
        
        if (!confirm(`Удалить профиль '${profileName}'?`)) {
            return;
        }
        
        try {
            const result = await this.profileService.deleteProfile(profileName);
            if (!result.success) {
                alert(`Не удалось удалить профиль:\n${result.error}`);
                return;
            }
            
            await this.refreshProfilesList();
            alert(`Профиль '${profileName}' удален`);
        } catch (error) {
            alert(`Не удалось удалить профиль:\n${error.message}`);
        }
    }
    
    setStatus(message) {
        this.statusManager.setStatus(message);
    }
}

// Инициализация приложения при загрузке страницы
let app;
document.addEventListener('DOMContentLoaded', () => {
    app = new ModLoadOrderManager();
});
