// Менеджер для drag and drop функционала
export class DragDropManager {
    constructor(modEntries, modsListElement, onDropCallback) {
        this.modEntries = modEntries; // Ссылка на массив модов
        this.modsListElement = modsListElement;
        this.onDropCallback = onDropCallback;
    }
    
    // Обновление ссылки на массив модов
    updateModEntries(modEntries) {
        this.modEntries = modEntries;
    }
    
    // Привязка drag and drop обработчиков к элементу мода
    attachDragDrop(modItem, modEntry, index, currentSort) {
        // Включаем drag and drop только для сортировки "По порядку файла"
        if (currentSort === 'По порядку файла') {
            modItem.draggable = true;
            modItem.setAttribute('data-mod-name', modEntry.name);
            
            modItem.addEventListener('dragstart', (e) => {
                modItem.classList.add('dragging');
                e.dataTransfer.effectAllowed = 'move';
                e.dataTransfer.setData('text/plain', modEntry.name);
                e.dataTransfer.setData('mod-index', index.toString());
            });
            
            modItem.addEventListener('dragend', (e) => {
                modItem.classList.remove('dragging');
                // Убираем все классы drag-over
                document.querySelectorAll('.mod-item.drag-over').forEach(item => {
                    item.classList.remove('drag-over');
                });
            });
            
            modItem.addEventListener('dragover', (e) => {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
                
                const draggingItem = document.querySelector('.mod-item.dragging');
                if (draggingItem && draggingItem !== modItem) {
                    const allItems = Array.from(this.modsListElement.querySelectorAll('.mod-item'));
                    const draggingIndex = allItems.indexOf(draggingItem);
                    const currentIndex = allItems.indexOf(modItem);
                    
                    // Убираем класс drag-over со всех элементов
                    allItems.forEach(item => item.classList.remove('drag-over'));
                    
                    // Добавляем класс drag-over на элемент, над которым перетаскиваем
                    if (draggingIndex < currentIndex) {
                        modItem.classList.add('drag-over');
                    } else if (draggingIndex > currentIndex) {
                        modItem.classList.add('drag-over');
                    }
                }
            });
            
            modItem.addEventListener('dragleave', (e) => {
                modItem.classList.remove('drag-over');
            });
            
            modItem.addEventListener('drop', (e) => {
                e.preventDefault();
                modItem.classList.remove('drag-over');
                
                const draggedModName = e.dataTransfer.getData('text/plain');
                if (!draggedModName || draggedModName === modEntry.name) {
                    return;
                }
                
                // Находим перетаскиваемый мод
                const draggedMod = this.modEntries.find(m => m.name === draggedModName);
                if (!draggedMod) {
                    return;
                }
                
                // Находим целевой мод
                const targetMod = modEntry;
                
                // Получаем все моды, отсортированные по orderIndex
                const sortedMods = [...this.modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
                const draggedIndex = sortedMods.findIndex(m => m.name === draggedModName);
                const targetIndex = sortedMods.findIndex(m => m.name === targetMod.name);
                
                if (draggedIndex === -1 || targetIndex === -1) {
                    return;
                }
                
                // Перемещаем мод в новую позицию
                if (draggedIndex < targetIndex) {
                    // Перемещаем вниз
                    for (let i = draggedIndex + 1; i <= targetIndex; i++) {
                        sortedMods[i].orderIndex = sortedMods[i].orderIndex - 1;
                    }
                    draggedMod.orderIndex = targetIndex;
                } else {
                    // Перемещаем вверх
                    for (let i = targetIndex; i < draggedIndex; i++) {
                        sortedMods[i].orderIndex = sortedMods[i].orderIndex + 1;
                    }
                    draggedMod.orderIndex = targetIndex;
                }
                
                // Вызываем callback для обновления списка
                if (this.onDropCallback) {
                    this.onDropCallback();
                }
            });
        } else {
            modItem.draggable = false;
        }
    }
}
