// Менеджер для привязки событий UI
export class EventBinder {
    constructor(elements, callbacks) {
        this.elements = elements;
        this.callbacks = callbacks;
        this.bindAll();
    }
    
    bindAll() {
        // Кнопки управления файлом
        this.elements.browseBtn.addEventListener('click', () => this.callbacks.browseFile());
        this.elements.loadBtn.addEventListener('click', () => this.callbacks.loadFile());
        
        // Сортировка
        this.elements.sortSelect.addEventListener('change', () => this.callbacks.onSortChange());
        
        // Массовые операции
        this.elements.enableAllBtn.addEventListener('click', () => this.callbacks.enableAll());
        this.elements.disableAllBtn.addEventListener('click', () => this.callbacks.disableAll());
        this.elements.scanBtn.addEventListener('click', () => this.callbacks.scanAndUpdate());
        
        // Поиск
        this.elements.searchInput.addEventListener('input', () => this.callbacks.onSearchChange());
        this.elements.clearSearchBtn.addEventListener('click', () => this.callbacks.clearSearch());
        
        // Скрытие новых модов
        this.elements.hideNewModsCheckbox.addEventListener('change', () => {
            this.callbacks.onHideNewModsChange(this.elements.hideNewModsCheckbox.checked);
        });
        
        // Скрытие не используемых модов
        this.elements.hideUnusedModsCheckbox.addEventListener('change', () => {
            this.callbacks.onHideUnusedModsChange(this.elements.hideUnusedModsCheckbox.checked);
        });
        
        // Удаление мода
        this.elements.deleteModBtn.addEventListener('click', () => this.callbacks.deleteSelectedMod());
        
        // Создание симлинка
        this.elements.createSymlinkBtn.addEventListener('click', () => this.callbacks.createSymlinkForMod());
        
        // Перемещение модов
        this.elements.moveUpBtn.addEventListener('click', () => this.callbacks.moveModUp());
        this.elements.moveDownBtn.addEventListener('click', () => this.callbacks.moveModDown());
        
        // Быстрое переключение
        this.elements.onlyThisModBtn.addEventListener('click', () => this.callbacks.enableOnlyThisMod());
        this.elements.restoreStateBtn.addEventListener('click', () => this.callbacks.restoreSavedState());
        
        // Профили
        this.elements.newProfileBtn.addEventListener('click', () => this.callbacks.saveCurrentProfile());
        this.elements.overwriteProfileBtn.addEventListener('click', () => this.callbacks.overwriteSelectedProfile());
        this.elements.loadProfileBtn.addEventListener('click', () => this.callbacks.loadSelectedProfile());
        this.elements.reloadFileBtn.addEventListener('click', () => this.callbacks.reloadFile());
        this.elements.renameProfileBtn.addEventListener('click', () => this.callbacks.renameSelectedProfile());
        this.elements.deleteProfileBtn.addEventListener('click', () => this.callbacks.deleteSelectedProfile());
        
        // Сохранение
        this.elements.saveBtn.addEventListener('click', () => this.callbacks.saveFile());
        this.elements.cancelBtn.addEventListener('click', () => this.callbacks.loadFile());
    }
}
