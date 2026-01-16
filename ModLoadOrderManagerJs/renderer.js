// Класс для представления записи мода
class ModEntry {
    constructor(name, enabled, originalLine, isNew = false, orderIndex = 0) {
        this.name = name;
        this.enabled = enabled;
        this.originalLine = originalLine;
        this.isNew = isNew; // Флаг для новых модов, найденных при сканировании
        this.orderIndex = orderIndex; // Порядковый номер из файла (для сортировки по умолчанию)
    }
}

// Главный класс приложения
class ModLoadOrderManager {
    constructor() {
        // Путь к файлу mod_load_order.txt
        this.defaultPath = '';
        this.filePath = '';
        
        // Данные
        this.headerLines = [];
        this.modEntries = [];
        this.filteredModEntries = [];
        this.selectedModName = '';
        this.sortType = 'По порядку файла';
        
        // Система профилей
        this.savedState = null; // Сохраненное состояние перед переключением
        this.profilesDir = null; // Путь к папке профилей
        
        // Элементы интерфейса
        this.elements = {};
        
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
            statsTotal: document.getElementById('stats-total'),
            statsEnabled: document.getElementById('stats-enabled'),
            statsDisabled: document.getElementById('stats-disabled'),
            selectedModInfo: document.getElementById('selected-mod-info'),
            moveUpBtn: document.getElementById('move-up-btn'),
            moveDownBtn: document.getElementById('move-down-btn'),
            onlyThisModBtn: document.getElementById('only-this-mod-btn'),
            restoreStateBtn: document.getElementById('restore-state-btn'),
            profilesList: document.getElementById('profiles-list'),
            newProfileBtn: document.getElementById('new-profile-btn'),
            overwriteProfileBtn: document.getElementById('overwrite-profile-btn'),
            loadProfileBtn: document.getElementById('load-profile-btn'),
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
        
        // Переменная для хранения callback функции модального окна
        this.modalCallback = null;
        
        // Получаем путь по умолчанию
        this.defaultPath = await window.electronAPI.getDefaultPath();
        this.filePath = this.defaultPath;
        this.elements.pathInput.value = this.filePath;
        
        // Инициализация папки профилей
        await this.initProfilesDirectory();
        
        // Привязка событий
        this.bindEvents();
        
        // Загрузка файла при старте
        await this.loadFile();
    }
    
    async initProfilesDirectory() {
        try {
            const modsDir = this.filePath ? this.filePath.substring(0, this.filePath.lastIndexOf('\\')) : '';
            if (!modsDir) {
                // Используем путь по умолчанию
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
            
            // Обновляем список профилей
            await this.refreshProfilesList();
        } catch (error) {
            console.error('Ошибка инициализации папки профилей:', error);
        }
    }
    
    bindEvents() {
        // Кнопки управления файлом
        this.elements.browseBtn.addEventListener('click', () => this.browseFile());
        this.elements.loadBtn.addEventListener('click', () => this.loadFile());
        
        // Сортировка
        this.elements.sortSelect.addEventListener('change', () => this.onSortChange());
        
        // Массовые операции
        this.elements.enableAllBtn.addEventListener('click', () => this.enableAll());
        this.elements.disableAllBtn.addEventListener('click', () => this.disableAll());
        this.elements.scanBtn.addEventListener('click', () => this.scanAndUpdate());
        
        // Поиск
        this.elements.searchInput.addEventListener('input', () => this.onSearchChange());
        this.elements.clearSearchBtn.addEventListener('click', () => this.clearSearch());
        
        // Перемещение модов
        this.elements.moveUpBtn.addEventListener('click', () => this.moveModUp());
        this.elements.moveDownBtn.addEventListener('click', () => this.moveModDown());
        
        // Быстрое переключение
        this.elements.onlyThisModBtn.addEventListener('click', () => this.enableOnlyThisMod());
        this.elements.restoreStateBtn.addEventListener('click', () => this.restoreSavedState());
        
        // Профили
        this.elements.newProfileBtn.addEventListener('click', () => this.saveCurrentProfile());
        this.elements.overwriteProfileBtn.addEventListener('click', () => this.overwriteSelectedProfile());
        this.elements.loadProfileBtn.addEventListener('click', () => this.loadSelectedProfile());
        this.elements.renameProfileBtn.addEventListener('click', () => this.renameSelectedProfile());
        this.elements.deleteProfileBtn.addEventListener('click', () => this.deleteSelectedProfile());
        
        // Сохранение
        this.elements.saveBtn.addEventListener('click', () => this.saveFile());
        this.elements.cancelBtn.addEventListener('click', () => this.loadFile());
        
        // Модальное окно
        this.elements.modalOkBtn.addEventListener('click', () => this.handleModalOk());
        this.elements.modalCancelBtn.addEventListener('click', () => this.handleModalCancel());
        this.elements.profileNameInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.handleModalOk();
            } else if (e.key === 'Escape') {
                this.handleModalCancel();
            }
        });
        
        // Закрытие модального окна при клике вне его
        this.elements.profileDialog.addEventListener('click', (e) => {
            // Закрываем только если клик был по фону, а не по содержимому
            if (e.target === this.elements.profileDialog) {
                this.handleModalCancel();
            }
        });
        
        // Предотвращаем закрытие при клике на содержимое модального окна
        const modalContent = this.elements.profileDialog.querySelector('.modal-content');
        if (modalContent) {
            modalContent.addEventListener('click', (e) => {
                e.stopPropagation();
            });
        }
    }
    
    showModal(title, defaultValue = '', callback) {
        this.elements.modalTitle.textContent = title;
        this.modalCallback = callback;
        
        // Убеждаемся, что поле доступно и очищено
        this.elements.profileNameInput.disabled = false;
        this.elements.profileNameInput.readOnly = false;
        this.elements.profileNameInput.value = '';
        
        // Показываем модальное окно
        this.elements.profileDialog.classList.add('show');
        
        // Устанавливаем значение и фокус после показа модального окна
        // Используем requestAnimationFrame для гарантии, что DOM обновлен
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                this.elements.profileNameInput.value = defaultValue || '';
                // Фокус на поле ввода и выделение текста
                this.elements.profileNameInput.focus();
                this.elements.profileNameInput.select();
                
                // Дополнительная проверка - если фокус не установился, пробуем еще раз
                if (document.activeElement !== this.elements.profileNameInput) {
                    setTimeout(() => {
                        this.elements.profileNameInput.focus();
                        this.elements.profileNameInput.select();
                    }, 100);
                }
            });
        });
    }
    
    hideModal() {
        this.elements.profileDialog.classList.remove('show');
        this.elements.profileNameInput.value = '';
        this.modalCallback = null;
    }
    
    handleModalOk() {
        const value = this.elements.profileNameInput.value.trim();
        if (this.modalCallback) {
            this.modalCallback(value);
        }
        this.hideModal();
    }
    
    handleModalCancel() {
        if (this.modalCallback) {
            this.modalCallback(null);
        }
        this.hideModal();
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
        
        const exists = await window.electronAPI.fileExists(this.filePath);
        if (!exists) {
            alert(`Файл не найден:\n${this.filePath}`);
            this.setStatus('Ошибка: файл не найден');
            return;
        }
        
        try {
            const result = await window.electronAPI.loadFile(this.filePath);
            if (!result.success) {
                alert(`Не удалось загрузить файл:\n${result.error}`);
                this.setStatus(`Ошибка: ${result.error}`);
                return;
            }
            
            // Разбиваем на строки, сохраняя информацию о символах новой строки
            // Используем регулярное выражение для разделения, но сохраняем оригинальные строки
            const content = result.content;
            const lines = [];
            let currentLine = '';
            
            // Разбиваем файл на строки, сохраняя символы новой строки
            for (let i = 0; i < content.length; i++) {
                const char = content[i];
                if (char === '\n') {
                    lines.push(currentLine + '\n');
                    currentLine = '';
                } else if (char === '\r') {
                    // Пропускаем \r, так как \n будет следующим
                    continue;
                } else {
                    currentLine += char;
                }
            }
            // Добавляем последнюю строку, если она не заканчивается на \n
            if (currentLine) {
                lines.push(currentLine + '\n');
            }
            
            // Очистка данных
            this.headerLines = [];
            this.modEntries = [];
            
            // Разделение на заголовок и моды
            let inHeader = true;
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                const stripped = line.replace(/\r?\n$/, '');
                
                // Заголовок - строки начинающиеся с "-- " (с пробелом после) или пустые строки в начале
                if (inHeader) {
                    if (stripped.startsWith('-- ')) {
                        // Комментарий заголовка (с пробелом после --)
                        this.headerLines.push(line);
                        continue;
                    } else if (stripped === '' && this.headerLines.length > 0) {
                        // Пустая строка в заголовке
                        this.headerLines.push(line);
                        continue;
                    } else {
                        // Первая не-заголовочная строка - начинаем обработку модов
                        inHeader = false;
                    }
                }
                
                // Пропускаем пустые строки после заголовка
                if (!stripped) {
                    continue;
                }
                
                // Обработка модов
                const modIndex = this.modEntries.length; // Порядковый номер мода в файле
                if (stripped.startsWith('--')) {
                    // Закомментированный мод (начинается с --, но без пробела или с именем мода)
                    const modName = stripped.substring(2).trim();
                    // Проверяем, что это действительно имя мода (содержит буквы/цифры)
                    if (modName && /[a-zA-Z0-9]/.test(modName)) {
                        this.modEntries.push(new ModEntry(modName, false, stripped, false, modIndex));
                    }
                } else {
                    // Активный мод (не начинается с --)
                    const modName = stripped.trim();
                    if (modName) { // Проверяем, что строка не пустая
                        this.modEntries.push(new ModEntry(modName, true, stripped, false, modIndex));
                    }
                }
            }
            
            // Сканирование папки модов для поиска новых модов
            await this.scanModsDirectory();
            
            // Обновление интерфейса
            this.updateModList();
            this.updateStatistics();
            
            const newModsCount = this.modEntries.filter(m => m.isNew).length;
            if (newModsCount > 0) {
                this.setStatus(`Загружено модов: ${this.modEntries.length} (новых: ${newModsCount})`);
            } else {
                this.setStatus(`Загружено модов: ${this.modEntries.length}`);
            }
            
            // Обновляем папку профилей после загрузки файла
            await this.initProfilesDirectory();
            
        } catch (error) {
            alert(`Не удалось загрузить файл:\n${error.message}`);
            this.setStatus(`Ошибка: ${error.message}`);
        }
    }
    
    async scanModsDirectory() {
        try {
            // Определяем путь к папке mods (та же директория, где находится mod_load_order.txt)
            const modsDir = this.filePath.substring(0, this.filePath.lastIndexOf('\\'));
            if (!modsDir) {
                return;
            }
            
            const exists = await window.electronAPI.fileExists(modsDir);
            if (!exists) {
                return;
            }
            
            // Получаем список существующих модов из файла
            const existingModNames = new Set(this.modEntries.map(mod => mod.name));
            
            // Сканируем папки в директории mods
            const result = await window.electronAPI.scanModsDirectory(modsDir);
            if (!result.success) {
                this.setStatus(`Предупреждение: не удалось просканировать папку модов: ${result.error}`);
                return;
            }
            
            const newMods = result.mods.filter(modName => !existingModNames.has(modName));
            
            // Добавляем новые моды в конец списка (выключенными по умолчанию)
            // Новые моды получают большой orderIndex, чтобы быть в конце при сортировке по умолчанию
            const baseIndex = this.modEntries.length + 1000; // Большой индекс для новых модов
            newMods.sort().forEach((modName, idx) => {
                this.modEntries.push(new ModEntry(
                    modName,
                    false, // Новые моды по умолчанию выключены
                    `--${modName}`, // По умолчанию закомментированы
                    true, // Флаг нового мода
                    baseIndex + idx // Порядок для новых модов
                ));
            });
            
        } catch (error) {
            // Не показываем ошибку пользователю, просто логируем в статус
            this.setStatus(`Предупреждение: не удалось просканировать папку модов: ${error.message}`);
        }
    }
    
    async scanAndUpdate() {
        const oldCount = this.modEntries.length;
        await this.scanModsDirectory();
        const newCount = this.modEntries.length - oldCount;
        
        if (newCount > 0) {
            // Обновляем интерфейс
            const searchText = this.elements.searchInput.value;
            this.updateModList(searchText);
            this.updateStatistics();
            alert(`Найдено новых модов: ${newCount}`);
        } else {
            alert('Новых модов не найдено');
        }
    }
    
    updateModList(filterText = null) {
        // Очистка существующих виджетов
        this.elements.modsList.innerHTML = '';
        
        // Получаем текст фильтра
        if (filterText === null) {
            filterText = this.elements.searchInput.value;
        }
        
        // Фильтрация модов
        let filtered;
        if (filterText) {
            const filterLower = filterText.toLowerCase();
            filtered = this.modEntries.filter(mod => 
                mod.name.toLowerCase().includes(filterLower)
            );
        } else {
            filtered = [...this.modEntries];
        }
        
        // Сортировка модов
        this.filteredModEntries = this.sortMods(filtered);
        
        // Создание элементов для каждого мода
        this.filteredModEntries.forEach((modEntry) => {
            const modItem = document.createElement('div');
            modItem.className = 'mod-item';
            if (modEntry.name === this.selectedModName) {
                modItem.classList.add('selected');
            }
            
            // Чекбокс
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.checked = modEntry.enabled;
            checkbox.addEventListener('change', () => {
                modEntry.enabled = checkbox.checked;
                this.onCheckboxChange(modEntry.name);
            });
            
            // Название мода
            const modName = document.createElement('span');
            modName.className = 'mod-name';
            modName.textContent = modEntry.name;
            
            // Метка "NEW" для новых модов
            let newLabel = null;
            if (modEntry.isNew) {
                newLabel = document.createElement('span');
                newLabel.className = 'mod-new-label';
                newLabel.textContent = '[NEW]';
            }
            
            // Индикатор статуса
            const status = document.createElement('span');
            status.className = `mod-status ${modEntry.enabled ? 'enabled' : 'disabled'}`;
            status.textContent = modEntry.enabled ? '✓' : '✗';
            
            // Обработка клика по элементу для выбора мода
            modItem.addEventListener('click', (e) => {
                if (e.target !== checkbox) {
                    this.selectMod(modEntry.name);
                }
            });
            
            // Сборка элемента
            modItem.appendChild(checkbox);
            modItem.appendChild(modName);
            if (newLabel) {
                modItem.appendChild(newLabel);
            }
            modItem.appendChild(status);
            
            // Сохраняем ссылку на элементы
            modEntry.checkbox = checkbox;
            modEntry.statusElement = status;
            modEntry.modItem = modItem;
            
            this.elements.modsList.appendChild(modItem);
        });
        
        // Обновление статистики
        this.updateStatistics();
    }
    
    sortMods(mods) {
        const sortType = this.elements.sortSelect.value;
        
        if (sortType === 'По порядку файла') {
            // Сортировка в порядке из файла (по orderIndex)
            return [...mods].sort((a, b) => a.orderIndex - b.orderIndex);
        } else if (sortType === 'По имени') {
            // Сортировка по имени (алфавитно)
            return [...mods].sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
        } else if (sortType === 'По статусу') {
            // Сортировка по статусу: сначала включенные, потом выключенные
            return [...mods].sort((a, b) => {
                if (a.enabled !== b.enabled) {
                    return a.enabled ? -1 : 1;
                }
                return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
            });
        } else if (sortType === 'Новые сначала') {
            // Сортировка: сначала новые моды, потом остальные (по имени)
            return [...mods].sort((a, b) => {
                if (a.isNew !== b.isNew) {
                    return a.isNew ? -1 : 1;
                }
                return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
            });
        } else {
            // По умолчанию - в порядке из файла (по orderIndex)
            return [...mods].sort((a, b) => a.orderIndex - b.orderIndex);
        }
    }
    
    onSortChange() {
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateMoveButtonsState();
    }
    
    onCheckboxChange(modName) {
        // Обновляем статус в данных
        const modEntry = this.modEntries.find(m => m.name === modName);
        if (modEntry) {
            // Обновляем визуальный индикатор статуса
            if (modEntry.statusElement) {
                modEntry.statusElement.textContent = modEntry.enabled ? '✓' : '✗';
                modEntry.statusElement.className = `mod-status ${modEntry.enabled ? 'enabled' : 'disabled'}`;
            }
        }
        
        // Обновляем статистику
        this.updateStatistics();
        
        // Обновляем информацию о выбранном моде, если он был выбран
        if (this.selectedModName === modName) {
            this.selectMod(modName);
        }
    }
    
    selectMod(modName) {
        // Снимаем выделение с предыдущего мода
        if (this.selectedModName) {
            const prevMod = this.modEntries.find(m => m.name === this.selectedModName);
            if (prevMod && prevMod.modItem) {
                prevMod.modItem.classList.remove('selected');
            }
        }
        
        this.selectedModName = modName;
        
        // Ищем мод в основном списке
        const modEntry = this.modEntries.find(m => m.name === modName);
        if (modEntry) {
            // Выделяем выбранный мод
            if (modEntry.modItem) {
                modEntry.modItem.classList.add('selected');
            }
            
            const status = modEntry.enabled ? 'Включен' : 'Выключен';
            let infoText = `${modName}\nСтатус: ${status}`;
            if (modEntry.isNew) {
                infoText += '\n⚠ Новый мод (не был в файле)';
            }
            this.elements.selectedModInfo.textContent = infoText;
            
            // Обновляем состояние кнопок перемещения
            this.updateMoveButtonsState();
            // Обновляем состояние кнопки "Только этот мод"
            this.updateQuickSwitchButtons();
        } else {
            this.elements.selectedModInfo.textContent = 'Нет выбора';
            // Отключаем кнопки, если мод не выбран
            this.elements.moveUpBtn.disabled = true;
            this.elements.moveDownBtn.disabled = true;
            this.elements.onlyThisModBtn.disabled = true;
        }
    }
    
    updateStatistics() {
        const total = this.modEntries.length;
        const enabled = this.modEntries.filter(m => m.enabled).length;
        const disabled = total - enabled;
        
        this.elements.statsTotal.textContent = `Всего модов: ${total}`;
        this.elements.statsEnabled.textContent = `Включено: ${enabled}`;
        this.elements.statsDisabled.textContent = `Выключено: ${disabled}`;
    }
    
    updateMoveButtonsState() {
        // Проверяем, активна ли сортировка "По порядку файла"
        const currentSort = this.elements.sortSelect.value;
        
        if (!this.selectedModName || currentSort !== 'По порядку файла') {
            // Отключаем кнопки, если мод не выбран или выбрана другая сортировка
            this.elements.moveUpBtn.disabled = true;
            this.elements.moveDownBtn.disabled = true;
            return;
        }
        
        // Для ручной сортировки работаем с исходным порядком (orderIndex)
        // Сортируем по orderIndex для определения позиции
        const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        const modIndex = sortedMods.findIndex(m => m.name === this.selectedModName);
        
        if (modIndex === -1) {
            // Мод не найден
            this.elements.moveUpBtn.disabled = true;
            this.elements.moveDownBtn.disabled = true;
            return;
        }
        
        // Включаем/отключаем кнопки в зависимости от позиции
        this.elements.moveUpBtn.disabled = modIndex <= 0;
        this.elements.moveDownBtn.disabled = modIndex >= sortedMods.length - 1;
    }
    
    moveModUp() {
        if (!this.selectedModName) {
            return;
        }
        
        // Находим мод в списке
        const modEntry = this.modEntries.find(m => m.name === this.selectedModName);
        if (!modEntry) {
            return;
        }
        
        // Сортируем по orderIndex для определения позиции
        const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        const currentIndex = sortedMods.findIndex(m => m.name === this.selectedModName);
        
        if (currentIndex <= 0) {
            return; // Уже вверху
        }
        
        // Меняем местами orderIndex с предыдущим модом
        const prevMod = sortedMods[currentIndex - 1];
        [modEntry.orderIndex, prevMod.orderIndex] = [prevMod.orderIndex, modEntry.orderIndex];
        
        // Обновляем список с учетом новой сортировки
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        
        // Обновляем состояние кнопок
        this.updateMoveButtonsState();
    }
    
    moveModDown() {
        if (!this.selectedModName) {
            return;
        }
        
        // Находим мод в списке
        const modEntry = this.modEntries.find(m => m.name === this.selectedModName);
        if (!modEntry) {
            return;
        }
        
        // Сортируем по orderIndex для определения позиции
        const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        const currentIndex = sortedMods.findIndex(m => m.name === this.selectedModName);
        
        if (currentIndex < 0 || currentIndex >= sortedMods.length - 1) {
            return; // Уже внизу
        }
        
        // Меняем местами orderIndex со следующим модом
        const nextMod = sortedMods[currentIndex + 1];
        [modEntry.orderIndex, nextMod.orderIndex] = [nextMod.orderIndex, modEntry.orderIndex];
        
        // Обновляем список с учетом новой сортировки
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        
        // Обновляем состояние кнопок
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
            // Подготовка содержимого
            const contentLines = [];
            
            // Добавляем заголовок
            contentLines.push(...this.headerLines);
            
            // Сортируем моды по orderIndex перед сохранением
            const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
            
            // Добавляем моды в порядке из orderIndex
            for (const modEntry of sortedMods) {
                // Сбрасываем флаг "новый" после сохранения
                if (modEntry.isNew) {
                    modEntry.isNew = false;
                }
                
                if (modEntry.enabled) {
                    contentLines.push(modEntry.name + '\n');
                } else {
                    contentLines.push('--' + modEntry.name + '\n');
                }
            }
            
            // Сохранение файла (сохраняем заголовок как есть, моды добавляем с \n)
            let content = '';
            // Заголовок сохраняем как есть (с оригинальными символами новой строки)
            for (const line of this.headerLines) {
                content += line;
            }
            // Моды добавляем с \n
            for (const modEntry of sortedMods) {
                if (modEntry.enabled) {
                    content += modEntry.name + '\n';
                } else {
                    content += '--' + modEntry.name + '\n';
                }
            }
            
            const result = await window.electronAPI.saveFile(this.filePath, content);
            
            if (!result.success) {
                alert(`Не удалось сохранить файл:\n${result.error}`);
                this.setStatus(`Ошибка сохранения: ${result.error}`);
                return;
            }
            
            alert('Файл успешно сохранен!');
            this.setStatus('Файл сохранен');
            
            // Перезагрузка для синхронизации
            await this.loadFile();
            
        } catch (error) {
            alert(`Не удалось сохранить файл:\n${error.message}`);
            this.setStatus(`Ошибка сохранения: ${error.message}`);
        }
    }
    
    saveCurrentState() {
        const state = {};
        for (const modEntry of this.modEntries) {
            state[modEntry.name] = modEntry.enabled;
        }
        return state;
    }
    
    restoreState(state) {
        if (!state) {
            return;
        }
        
        for (const modEntry of this.modEntries) {
            if (modEntry.name in state) {
                modEntry.enabled = state[modEntry.name];
                // Обновляем чекбоксы
                if (modEntry.checkbox) {
                    modEntry.checkbox.checked = state[modEntry.name];
                }
            }
        }
        
        // Обновляем интерфейс
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
    }
    
    enableOnlyThisMod() {
        if (!this.selectedModName) {
            return;
        }
        
        // Сохраняем текущее состояние
        this.savedState = this.saveCurrentState();
        
        // Отключаем все моды
        for (const modEntry of this.modEntries) {
            modEntry.enabled = false;
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = false;
            }
        }
        
        // Включаем только выбранный мод
        const modEntry = this.modEntries.find(m => m.name === this.selectedModName);
        if (modEntry) {
            modEntry.enabled = true;
            if (modEntry.checkbox) {
                modEntry.checkbox.checked = true;
            }
        }
        
        // Обновляем интерфейс
        const searchText = this.elements.searchInput.value;
        this.updateModList(searchText);
        this.updateStatistics();
        
        // Обновляем состояние кнопок
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
        
        // Обновляем состояние кнопок
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
            const result = await window.electronAPI.listProfiles(this.profilesDir);
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
        
        this.showModal('Введите имя профиля:', '', async (profileName) => {
            if (!profileName) {
                return;
            }
            
            // Очищаем имя от недопустимых символов
            const cleanName = profileName.replace(/[^a-zA-Z0-9\s\-_]/g, '').trim();
            if (!cleanName) {
                alert('Недопустимое имя профиля');
                return;
            }
            
            try {
                const state = this.saveCurrentState();
                const result = await window.electronAPI.saveProfile(this.profilesDir, cleanName, state);
                
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
            const result = await window.electronAPI.loadProfile(this.profilesDir, profileName);
            if (!result.success) {
                alert(`Не удалось загрузить профиль:\n${result.error}`);
                return;
            }
            
            this.restoreState(result.state);
            alert(`Профиль '${profileName}' загружен`);
        } catch (error) {
            alert(`Не удалось загрузить профиль:\n${error.message}`);
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
        
        // Показываем модальное окно с текущим именем
        this.showModal(`Введите новое имя для профиля '${oldProfileName}':`, oldProfileName, async (newProfileName) => {
            if (!newProfileName) {
                return;
            }
            
            // Очищаем имя от недопустимых символов
            const cleanName = newProfileName.replace(/[^a-zA-Z0-9\s\-_]/g, '').trim();
            if (!cleanName) {
                alert('Недопустимое имя профиля');
                return;
            }
            
            // Проверяем, что новое имя отличается от старого
            if (cleanName === oldProfileName) {
                return;
            }
            
            try {
                const result = await window.electronAPI.renameProfile(this.profilesDir, oldProfileName, cleanName);
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
            const result = await window.electronAPI.saveProfile(this.profilesDir, profileName, state);
            
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
            const result = await window.electronAPI.deleteProfile(this.profilesDir, profileName);
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
        this.elements.statusText.textContent = message;
    }
}

// Инициализация приложения при загрузке страницы
let app;
document.addEventListener('DOMContentLoaded', () => {
    app = new ModLoadOrderManager();
});
