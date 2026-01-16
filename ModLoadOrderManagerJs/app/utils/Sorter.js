// Утилита для сортировки модов
export class Sorter {
    static sortMods(mods, sortType) {
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
}
