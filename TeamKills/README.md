# TeamKills Mod

A mod for Warhammer 40,000: Darktide that tracks team statistics including kills, damage, killstreaks, and boss damage.

## API Documentation

This mod provides an API for other mods to access team statistics data.

### Usage Example

```lua
local teamkills_mod = get_mod("TeamKills")
if teamkills_mod then
    -- For reading data (fast, no copying):
    local player_kills_readonly = teamkills_mod.get_player_kills_readonly()
    
    -- For modifying data (safe, with deep copy):
    local player_kills = teamkills_mod.get_player_kills()
    
    -- Get data for specific player
    local player_data = teamkills_mod.get_player_data(account_id)
    
    -- Get all data
    local all_data = teamkills_mod.get_all_data()
end
```

### API Functions

**Note:** All functions now have two versions:
- **Standard version** (e.g., `get_player_kills()`) - Returns a deep copy of the data (safe for modification)
- **Readonly version** (e.g., `get_player_kills_readonly()`) - Returns direct reference to data (faster, but read-only)

#### `get_player_kills()` / `get_player_kills_readonly()`
Returns all player kills data.
- **Returns:** `table` - `{account_id = kills_count, ...}`

#### `get_player_damage()` / `get_player_damage_readonly()`
Returns all player damage data.
- **Returns:** `table` - `{account_id = damage_amount, ...}`

#### `get_player_last_damage()` / `get_player_last_damage_readonly()`
Returns all player last damage data.
- **Returns:** `table` - `{account_id = last_damage_amount, ...}`

#### `get_kills_by_category()` / `get_kills_by_category_readonly()`
Returns kills by category for all players.
- **Returns:** `table` - `{account_id = {breed_name = count, ...}, ...}`

#### `get_damage_by_category()` / `get_damage_by_category_readonly()`
Returns damage by category for all players.
- **Returns:** `table` - `{account_id = {breed_name = damage, ...}, ...}`

#### `get_player_killstreak()` / `get_player_killstreak_readonly()`
Returns all player killstreak data.
- **Returns:** `table` - `{account_id = killstreak_count, ...}`

#### `get_boss_damage()` / `get_boss_damage_readonly()`
Returns boss damage data.
- **Returns:** `table` - `{boss_unit = {account_id = damage, ...}, ...}`

#### `get_boss_last_damage()` / `get_boss_last_damage_readonly()`
Returns last damage to bosses.
- **Returns:** `table` - `{boss_unit = {account_id = last_damage, ...}, ...}`

#### `get_player_data(account_id)`
Returns all data for a specific player.
- **Parameters:**
  - `account_id` (string) - Player account ID
- **Returns:** `table` - Player data object containing:
  - `kills` (number) - Total kills
  - `damage` (number) - Total damage
  - `last_damage` (number) - Last damage dealt
  - `killstreak` (number) - Current killstreak
  - `kills_by_category` (table) - Kills by breed category
  - `damage_by_category` (table) - Damage by breed category
- **Note:** Returns empty structure if account_id is invalid

#### `get_all_data()`
Returns all mod data in a single table.
- **Returns:** `table` - Object containing all available data:
  - `player_kills` (table)
  - `player_damage` (table)
  - `player_last_damage` (table)
  - `kills_by_category` (table)
  - `damage_by_category` (table)
  - `player_killstreak` (table)
  - `boss_damage` (table)
  - `boss_last_damage` (table)

#### `get_version()`
Returns the mod version.
- **Returns:** `string` - Mod version (e.g., "2.0.0")

### Notes

- All standard API functions return **deep copies** of data to prevent modification of original data.
- All `_readonly` functions return **direct references** for better performance, but should not be modified.
- All functions are safe to call even if data doesn't exist yet (returns empty tables or default structures).
- The `account_id` parameter should be the player's account ID or name.
- Use `_readonly` functions when you only need to read data for better performance.
- Use standard functions when you need to modify returned data.

---

## Документация API

Этот мод предоставляет API для других модов для доступа к статистике команды.

### Пример использования

```lua
local teamkills_mod = get_mod("TeamKills")
if teamkills_mod then
    -- Для чтения данных (быстро, без копирования):
    local player_kills_readonly = teamkills_mod.get_player_kills_readonly()
    
    -- Для изменения данных (безопасно, с глубоким копированием):
    local player_kills = teamkills_mod.get_player_kills()
    
    -- Получить данные конкретного игрока
    local player_data = teamkills_mod.get_player_data(account_id)
    
    -- Получить все данные
    local all_data = teamkills_mod.get_all_data()
end
```

### API Функции

**Примечание:** Все функции теперь имеют две версии:
- **Стандартная версия** (например, `get_player_kills()`) - Возвращает глубокую копию данных (безопасно для изменения)
- **Readonly версия** (например, `get_player_kills_readonly()`) - Возвращает прямую ссылку на данные (быстрее, но только для чтения)

#### `get_player_kills()` / `get_player_kills_readonly()`
Возвращает данные об убийствах всех игроков.
- **Возвращает:** `table` - `{account_id = количество_убийств, ...}`

#### `get_player_damage()` / `get_player_damage_readonly()`
Возвращает данные об уроне всех игроков.
- **Возвращает:** `table` - `{account_id = количество_урона, ...}`

#### `get_player_last_damage()` / `get_player_last_damage_readonly()`
Возвращает данные о последнем уроне всех игроков.
- **Возвращает:** `table` - `{account_id = последний_урон, ...}`

#### `get_kills_by_category()` / `get_kills_by_category_readonly()`
Возвращает убийства по категориям для всех игроков.
- **Возвращает:** `table` - `{account_id = {имя_породы = количество, ...}, ...}`

#### `get_damage_by_category()` / `get_damage_by_category_readonly()`
Возвращает урон по категориям для всех игроков.
- **Возвращает:** `table` - `{account_id = {имя_породы = урон, ...}, ...}`

#### `get_player_killstreak()` / `get_player_killstreak_readonly()`
Возвращает данные о сериях убийств всех игроков.
- **Возвращает:** `table` - `{account_id = количество_в_серии, ...}`

#### `get_boss_damage()` / `get_boss_damage_readonly()`
Возвращает данные об уроне по боссам.
- **Возвращает:** `table` - `{юнит_босса = {account_id = урон, ...}, ...}`

#### `get_boss_last_damage()` / `get_boss_last_damage_readonly()`
Возвращает последний урон по боссам.
- **Возвращает:** `table` - `{юнит_босса = {account_id = последний_урон, ...}, ...}`

#### `get_player_data(account_id)`
Возвращает все данные для конкретного игрока.
- **Параметры:**
  - `account_id` (string) - ID аккаунта игрока
- **Возвращает:** `table` - Объект с данными игрока, содержащий:
  - `kills` (number) - Всего убийств
  - `damage` (number) - Всего урона
  - `last_damage` (number) - Последний нанесенный урон
  - `killstreak` (number) - Текущая серия убийств
  - `kills_by_category` (table) - Убийства по категориям пород
  - `damage_by_category` (table) - Урон по категориям пород
- **Примечание:** Возвращает пустую структуру если account_id неверный

#### `get_all_data()`
Возвращает все данные мода в одной таблице.
- **Возвращает:** `table` - Объект, содержащий все доступные данные:
  - `player_kills` (table)
  - `player_damage` (table)
  - `player_last_damage` (table)
  - `kills_by_category` (table)
  - `damage_by_category` (table)
  - `player_killstreak` (table)
  - `boss_damage` (table)
  - `boss_last_damage` (table)

#### `get_version()`
Возвращает версию мода.
- **Возвращает:** `string` - Версия мода (например, "2.0.0")

### Примечания

- Все стандартные API функции возвращают **глубокие копии** данных, чтобы предотвратить изменение оригинальных данных.
- Все `_readonly` функции возвращают **прямые ссылки** для лучшей производительности, но их не следует изменять.
- Все функции безопасны для вызова, даже если данные еще не существуют (возвращают пустые таблицы или стандартные структуры).
- Параметр `account_id` должен быть ID аккаунта или именем игрока.
- Используйте `_readonly` функции когда вам нужно только читать данные для лучшей производительности.
- Используйте стандартные функции когда вам нужно изменять возвращаемые данные.

