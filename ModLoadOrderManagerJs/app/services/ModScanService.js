import { ModEntry } from '../models/ModEntry.js';

// Сервис для сканирования папки модов
export class ModScanService {
    constructor(filePath, statusCallback) {
        this.filePath = filePath;
        this.setStatus = statusCallback;
    }
    
    // Сканирование папки модов
    async scanModsDirectory(modEntries, selectedModName) {
        try {
            // Определяем путь к папке mods (та же директория, где находится mod_load_order.txt)
            const modsDir = this.filePath.substring(0, this.filePath.lastIndexOf('\\'));
            if (!modsDir) {
                return { added: 0, removed: 0, selectedModName };
            }
            
            const exists = await window.electronAPI.fileExists(modsDir);
            if (!exists) {
                return { added: 0, removed: 0, selectedModName };
            }
            
            // Получаем список существующих модов из файла
            const existingModNames = new Set(modEntries.map(mod => mod.name));
            
            // Сканируем папки в директории mods
            const result = await window.electronAPI.scanModsDirectory(modsDir);
            if (!result.success) {
                this.setStatus(`Предупреждение: не удалось просканировать папку модов: ${result.error}`);
                return { added: 0, removed: 0, deleted: 0, restored: 0, selectedModName };
            }
            
            // Получаем список модов из файловой системы
            const fileSystemMods = new Set(result.mods);
            const symlinkMods = result.symlinks || new Map(); // Карта симлинков
            
            // Удаляем моды с флагом isNew, которых больше нет в файловой системе
            const modsToRemove = [];
            let newSelectedModName = selectedModName;
            let deletedCount = 0; // Счетчик модов, помеченных как deleted
            let restoredCount = 0; // Счетчик модов, у которых снят флаг deleted (папка появилась)
            
            // Проверяем все моды из файла на наличие папок
            for (const mod of modEntries) {
                const wasDeleted = mod.isDeleted; // Сохраняем предыдущее состояние
                
                // Если мод не новый (есть в файле), но его папки нет в файловой системе
                if (!mod.isNew && !fileSystemMods.has(mod.name)) {
                    if (!wasDeleted) {
                        // Мод только что помечен как deleted
                        deletedCount++;
                    }
                    mod.isDeleted = true; // Помечаем как удаленный
                    mod.isSymlink = false; // Если папки нет, симлинк тоже не может быть
                } else if (mod.isDeleted && fileSystemMods.has(mod.name)) {
                    // Если папка появилась снова - снимаем флаг
                    mod.isDeleted = false;
                    if (wasDeleted) {
                        // Флаг был снят (папка восстановлена)
                        restoredCount++;
                    }
                }
                
                // Обновляем флаг isSymlink для существующих модов
                if (fileSystemMods.has(mod.name)) {
                    mod.isSymlink = symlinkMods.get(mod.name) || false;
                }
                
                // Если мод помечен как новый, но его нет в файловой системе - удаляем
                if (mod.isNew && !fileSystemMods.has(mod.name)) {
                    modsToRemove.push(mod.name);
                }
            }
            
            // Удаляем моды с флагом isNew, которых нет в файловой системе
            for (let i = modEntries.length - 1; i >= 0; i--) {
                const mod = modEntries[i];
                if (modsToRemove.includes(mod.name)) {
                    modEntries.splice(i, 1);
                }
            }
            
            // Если удалили выбранный мод, сбрасываем выбор
            if (newSelectedModName && modsToRemove.includes(newSelectedModName)) {
                newSelectedModName = '';
            }
            
            // Добавляем новые моды, которых нет в текущем списке
            const newMods = result.mods.filter(modName => !existingModNames.has(modName));
            
            // Добавляем новые моды в конец списка (выключенными по умолчанию)
            // Новые моды получают большой orderIndex, чтобы быть в конце при сортировке по умолчанию
            const baseIndex = modEntries.length + 1000; // Большой индекс для новых модов
            newMods.sort().forEach((modName, idx) => {
                const isSymlink = symlinkMods.get(modName) || false;
                modEntries.push(new ModEntry(
                    modName,
                    false, // Новые моды по умолчанию выключены
                    `--${modName}`, // По умолчанию закомментированы
                    true, // Флаг нового мода
                    baseIndex + idx, // Порядок для новых модов
                    false, // isDeleted
                    isSymlink // Флаг симлинка
                ));
            });
            
            return { 
                added: newMods.length, 
                removed: modsToRemove.length, 
                deleted: deletedCount,
                restored: restoredCount,
                selectedModName: newSelectedModName 
            };
            
        } catch (error) {
            // Не показываем ошибку пользователю, просто логируем в статус
            this.setStatus(`Предупреждение: не удалось просканировать папку модов: ${error.message}`);
            return { added: 0, removed: 0, deleted: 0, restored: 0, selectedModName };
        }
    }
}
