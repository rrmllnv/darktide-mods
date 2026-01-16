import { ModEntry } from '../models/ModEntry.js';

// Сервис для работы с файлами mod_load_order.txt
export class FileService {
    constructor(statusCallback) {
        this.setStatus = statusCallback;
    }
    
    // Парсинг содержимого файла в структуру данных
    parseFileContent(content) {
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
        
        const headerLines = [];
        const modEntries = [];
        
        // Разделение на заголовок и моды
        let inHeader = true;
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const stripped = line.replace(/\r?\n$/, '');
            
            // Заголовок - строки начинающиеся с "-- " (с пробелом после) или пустые строки в начале
            if (inHeader) {
                if (stripped.startsWith('-- ')) {
                    // Комментарий заголовка (с пробелом после --)
                    headerLines.push(line);
                    continue;
                } else if (stripped === '' && headerLines.length > 0) {
                    // Пустая строка в заголовке
                    headerLines.push(line);
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
            const modIndex = modEntries.length; // Порядковый номер мода в файле
            if (stripped.startsWith('--')) {
                // Закомментированный мод (начинается с --, но без пробела или с именем мода)
                const modName = stripped.substring(2).trim();
                // Проверяем, что это действительно имя мода (содержит буквы/цифры)
                if (modName && /[a-zA-Z0-9]/.test(modName)) {
                    modEntries.push(new ModEntry(modName, false, stripped, false, modIndex, false, false));
                }
            } else {
                // Активный мод (не начинается с --)
                const modName = stripped.trim();
                if (modName) { // Проверяем, что строка не пустая
                    modEntries.push(new ModEntry(modName, true, stripped, false, modIndex, false, false));
                }
            }
        }
        
        return { headerLines, modEntries };
    }
    
    // Формирование содержимого файла для сохранения
    formatFileContent(headerLines, modEntries) {
        // Сортируем моды по orderIndex перед сохранением
        const sortedMods = [...modEntries].sort((a, b) => a.orderIndex - b.orderIndex);
        
        let content = '';
        // Заголовок сохраняем как есть (с оригинальными символами новой строки)
        for (const line of headerLines) {
            content += line;
        }
        // Моды добавляем с \n
        for (const modEntry of sortedMods) {
            // Пропускаем новые моды, которые не включены (не выбраны галочкой)
            if (modEntry.isNew && !modEntry.enabled) {
                continue; // Не сохраняем в файл
            }
            
            // Сбрасываем флаг "новый" только для модов, которые сохраняются в файл
            if (modEntry.isNew) {
                modEntry.isNew = false;
            }
            
            if (modEntry.enabled) {
                content += modEntry.name + '\n';
            } else {
                content += '--' + modEntry.name + '\n';
            }
        }
        
        return content;
    }
    
    // Загрузка файла
    async loadFile(filePath) {
        const exists = await window.electronAPI.fileExists(filePath);
        if (!exists) {
            throw new Error(`Файл не найден: ${filePath}`);
        }
        
        const result = await window.electronAPI.loadFile(filePath);
        if (!result.success) {
            throw new Error(result.error);
        }
        
        return this.parseFileContent(result.content);
    }
    
    // Сохранение файла
    async saveFile(filePath, headerLines, modEntries) {
        const content = this.formatFileContent(headerLines, modEntries);
        const result = await window.electronAPI.saveFile(filePath, content);
        
        if (!result.success) {
            throw new Error(result.error);
        }
        
        return result;
    }
}
