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
                return { added: 0, removed: 0, selectedModName };
            }
            
            // Получаем список модов из файловой системы
            const fileSystemMods = new Set(result.mods);
            
            // Удаляем моды с флагом isNew, которых больше нет в файловой системе
            const modsToRemove = [];
            let newSelectedModName = selectedModName;
            
            // Проверяем все моды из файла на наличие папок
            for (const mod of modEntries) {
                // Если мод не новый (есть в файле), но его папки нет в файловой системе
                if (!mod.isNew && !fileSystemMods.has(mod.name)) {
                    mod.isDeleted = true; // Помечаем как удаленный
                } else if (mod.isDeleted && fileSystemMods.has(mod.name)) {
                    // Если папка появилась снова - снимаем флаг
                    mod.isDeleted = false;
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
                modEntries.push(new ModEntry(
                    modName,
                    false, // Новые моды по умолчанию выключены
                    `--${modName}`, // По умолчанию закомментированы
                    true, // Флаг нового мода
                    baseIndex + idx // Порядок для новых модов
                ));
            });
            
            return { added: newMods.length, removed: modsToRemove.length, selectedModName: newSelectedModName };
            
        } catch (error) {
            // Не показываем ошибку пользователю, просто логируем в статус
            this.setStatus(`Предупреждение: не удалось просканировать папку модов: ${error.message}`);
            return { added: 0, removed: 0, selectedModName };
        }
    }
}
