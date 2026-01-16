import { ModEntry } from '../models/ModEntry.js';

// Сервис для работы с профилями
export class ProfileService {
    constructor(profilesDir) {
        this.profilesDir = profilesDir;
    }
    
    // Сохранение текущего состояния в формат профиля
    saveState(modEntries) {
        // Сохраняем все моды, кроме тех, которые помечены как NEW и выключены
        // Если мод с флагом NEW включен (галочка стоит), он должен сохраниться в профиль
        const modsToSave = modEntries.filter(modEntry => {
            // Исключаем только NEW моды, которые выключены
            // Если NEW мод включен - сохраняем его
            if (modEntry.isNew && !modEntry.enabled) {
                return false;
            }
            return true;
        });
        
        // Сортируем моды по orderIndex для сохранения правильного порядка
        const sortedMods = [...modsToSave].sort((a, b) => a.orderIndex - b.orderIndex);
        
        const state = {
            _order: [], // Массив имен модов в порядке из файла
            _mods: {}   // Объект с состоянием каждого мода
        };
        
        for (const modEntry of sortedMods) {
            state._order.push(modEntry.name);
            state._mods[modEntry.name] = modEntry.enabled;
        }
        
        return state;
    }
    
    // Восстановление состояния из профиля
    restoreState(state, existingModEntries) {
        if (!state) {
            return { modEntries: [], selectedModName: '' };
        }
        
        // Поддержка старого формата профиля (без порядка)
        let profileOrder = [];
        let profileMods = {};
        
        if (state._order && state._mods) {
            // Новый формат с порядком
            profileOrder = state._order;
            profileMods = state._mods;
        } else {
            // Старый формат (только состояние) - создаем порядок из ключей
            profileOrder = Object.keys(state);
            profileMods = state;
        }
        
        // Получаем список имен модов из профиля
        const profileModNames = new Set(profileOrder);
        
        // Создаем карту существующих модов для быстрого доступа
        const existingModsMap = new Map();
        for (const modEntry of existingModEntries) {
            existingModsMap.set(modEntry.name, modEntry);
        }
        
        // Восстанавливаем порядок и состояние модов из профиля
        const restoredMods = [];
        const maxOrderIndex = Math.max(...existingModEntries.map(m => m.orderIndex), 0);
        
        // Проходим по порядку из профиля
        profileOrder.forEach((modName, index) => {
            const enabled = profileMods[modName];
            const existingMod = existingModsMap.get(modName);
            
            if (existingMod) {
                // Мод существует - обновляем его состояние и порядок
                existingMod.enabled = enabled;
                existingMod.orderIndex = index; // Восстанавливаем порядок из профиля
                existingMod.isNew = false; // Снимаем флаг NEW
                restoredMods.push(existingMod);
                existingModsMap.delete(modName); // Убираем из карты, чтобы не обработать повторно
            } else {
                // Мод есть в профиле, но отсутствует в текущем списке - добавляем его
                restoredMods.push(new ModEntry(
                    modName,
                    enabled,
                    enabled ? modName : `--${modName}`,
                    false, // НЕ новый мод, так как он из профиля
                    index, // Порядок из профиля
                    false, // isDeleted
                    false // isSymlink (из профиля не знаем, определится при сканировании)
                ));
            }
        });
        
        // Обрабатываем моды, которых нет в профиле
        for (const [modName, modEntry] of existingModsMap) {
            // Мод НЕТ в профиле - помечаем как новый
            if (!modEntry.isNew) {
                modEntry.isNew = true;
            }
            // Сбрасываем состояние enabled для модов, которых нет в профиле
            // Они должны быть выключены, так как их нет в загруженном профиле
            modEntry.enabled = false;
            // Добавляем в конец с большим orderIndex
            modEntry.orderIndex = maxOrderIndex + 1000 + restoredMods.length;
            restoredMods.push(modEntry);
        }
        
        return { modEntries: restoredMods };
    }
    
    // Список профилей
    async listProfiles() {
        if (!this.profilesDir) {
            return { success: false, profiles: [] };
        }
        
        return await window.electronAPI.listProfiles(this.profilesDir);
    }
    
    // Сохранение профиля
    async saveProfile(profileName, state) {
        if (!this.profilesDir) {
            return { success: false, error: 'Папка профилей не определена' };
        }
        
        return await window.electronAPI.saveProfile(this.profilesDir, profileName, state);
    }
    
    // Загрузка профиля
    async loadProfile(profileName) {
        if (!this.profilesDir) {
            return { success: false, error: 'Папка профилей не определена' };
        }
        
        return await window.electronAPI.loadProfile(this.profilesDir, profileName);
    }
    
    // Удаление профиля
    async deleteProfile(profileName) {
        if (!this.profilesDir) {
            return { success: false, error: 'Папка профилей не определена' };
        }
        
        return await window.electronAPI.deleteProfile(this.profilesDir, profileName);
    }
    
    // Переименование профиля
    async renameProfile(oldName, newName) {
        if (!this.profilesDir) {
            return { success: false, error: 'Папка профилей не определена' };
        }
        
        return await window.electronAPI.renameProfile(this.profilesDir, oldName, newName);
    }
}
