import { Sorter } from '../utils/Sorter.js';
import { DragDropManager } from './DragDropManager.js';

// Рендерер для списка модов
export class ModListRenderer {
    constructor(elements, modEntries, callbacks) {
        this.elements = elements;
        // Обеспечиваем, что modEntries всегда является массивом
        this._modEntries = Array.isArray(modEntries) ? modEntries : [];
        this.callbacks = callbacks; // { onCheckboxChange, onModSelect, onDrop }
        this.filteredModEntries = [];
        this.dragDropManager = new DragDropManager(
            this._modEntries,
            elements.modsList,
            callbacks.onDrop
        );
    }
    
    // Обновление ссылки на массив модов
    set modEntries(value) {
        // Обеспечиваем, что value всегда является массивом
        this._modEntries = Array.isArray(value) ? value : [];
        // Обновляем ссылку в DragDropManager
        if (this.dragDropManager) {
            this.dragDropManager.updateModEntries(this._modEntries);
        }
    }
    
    get modEntries() {
        return this._modEntries;
    }
    
    // Обновление списка модов
    updateModList(filterText = null, hideNewMods = false, hideUnusedMods = false, hideDeletedMods = false, selectedModName = '', selectedModNames = null) {
        // Обеспечиваем, что selectedModNames всегда является Set
        if (!selectedModNames || !(selectedModNames instanceof Set)) {
            selectedModNames = new Set();
        }
        
        // Проверяем, что _modEntries является массивом
        if (!Array.isArray(this._modEntries)) {
            console.error('_modEntries is not an array:', this._modEntries);
            this._modEntries = [];
        }
        
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
            filtered = this._modEntries.filter(mod => 
                mod && mod.name && mod.name.toLowerCase().includes(filterLower)
            );
        } else {
            filtered = [...this._modEntries].filter(mod => mod && mod.name);
        }
        
        // Фильтрация новых модов, если включен чекбокс
        if (hideNewMods) {
            filtered = filtered.filter(mod => !mod.isNew);
        }
        
        // Фильтрация не используемых модов (выключенных), если включен чекбокс
        if (hideUnusedMods) {
            filtered = filtered.filter(mod => mod.enabled);
        }
        
        // Фильтрация удаленных модов, если включен чекбокс
        if (hideDeletedMods) {
            filtered = filtered.filter(mod => !mod.isDeleted);
        }
        
        // Сортировка модов
        const currentSort = this.elements.sortSelect.value;
        this.filteredModEntries = Sorter.sortMods(filtered, currentSort);
        
        // Создание элементов для каждого мода
        if (!this.elements.modsList) {
            console.error('modsList element not found');
            return;
        }
        
        this.filteredModEntries.forEach((modEntry, index) => {
            if (!modEntry || !modEntry.name) {
                console.warn('Invalid modEntry at index', index, modEntry);
                return;
            }
            const isSelected = selectedModNames.has(modEntry.name) || modEntry.name === selectedModName;
            const modItem = this.createModItem(modEntry, selectedModName, currentSort, index, isSelected);
            if (modItem) {
                this.elements.modsList.appendChild(modItem);
            }
        });
    }
    
    // Создание элемента мода
    createModItem(modEntry, selectedModName, currentSort, index, isSelected = false) {
        const modItem = document.createElement('div');
        modItem.className = 'mod-item';
        if (isSelected) {
            modItem.classList.add('selected');
        }
        
        // Чекбокс
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = modEntry.enabled;
        checkbox.addEventListener('change', () => {
            modEntry.enabled = checkbox.checked;
            if (this.callbacks.onCheckboxChange) {
                this.callbacks.onCheckboxChange(modEntry.name);
            }
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
        
        // Метка "DELETED" для модов с удаленной папкой
        let deletedLabel = null;
        if (modEntry.isDeleted) {
            deletedLabel = document.createElement('span');
            deletedLabel.className = 'mod-deleted-label';
            deletedLabel.textContent = '[DELETED]';
        }
        
        // Метка "SYMLINK" для модов-симлинков
        let symlinkLabel = null;
        if (modEntry.isSymlink) {
            symlinkLabel = document.createElement('span');
            symlinkLabel.className = 'mod-symlink-label';
            symlinkLabel.textContent = '[SYMLINK]';
        }
        
        // Индикатор статуса
        const status = document.createElement('span');
        status.className = `mod-status ${modEntry.enabled ? 'enabled' : 'disabled'}`;
        status.textContent = modEntry.enabled ? '✓' : '✗';
        
        // Обработка клика по элементу для выбора мода
        modItem.addEventListener('click', (e) => {
            if (e.target !== checkbox && !modItem.classList.contains('dragging')) {
                if (this.callbacks.onModSelect) {
                    const ctrlKey = e.ctrlKey || e.metaKey; // Поддержка Cmd на Mac
                    const shiftKey = e.shiftKey;
                    this.callbacks.onModSelect(modEntry.name, ctrlKey, shiftKey);
                }
            }
        });
        
        // Привязка drag and drop
        this.dragDropManager.attachDragDrop(modItem, modEntry, index, currentSort);
        
        // Сборка элемента
        modItem.appendChild(checkbox);
        modItem.appendChild(modName);
        
        
        if (symlinkLabel) {
            modItem.appendChild(symlinkLabel);
        }
        if (deletedLabel) {
            modItem.appendChild(deletedLabel);
        }
        if (newLabel) {
            modItem.appendChild(newLabel);
        }
        modItem.appendChild(status);
        
        // Сохраняем ссылку на элементы
        modEntry.checkbox = checkbox;
        modEntry.statusElement = status;
        modEntry.modItem = modItem;
        
        return modItem;
    }
}
