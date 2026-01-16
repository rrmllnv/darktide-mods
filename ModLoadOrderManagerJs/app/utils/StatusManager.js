// Менеджер для управления статус-баром
export class StatusManager {
    constructor(statusElement) {
        this.statusElement = statusElement;
    }
    
    setStatus(message) {
        if (this.statusElement) {
            this.statusElement.textContent = message;
        }
    }
    
    updateStatistics(modEntries) {
        const total = modEntries.length;
        const enabled = modEntries.filter(m => m.enabled).length;
        const disabled = total - enabled;
        const newModsCount = modEntries.filter(m => m.isNew).length;
        
        // Формируем строку статистики для статус бара
        let statsText = `Всего: ${total} | Включено: ${enabled} | Выключено: ${disabled}`;
        if (newModsCount > 0) {
            statsText += ` | Новых: ${newModsCount}`;
        }
        
        this.setStatus(statsText);
    }
}
