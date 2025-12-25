# TeamKills Mod

A mod for Warhammer 40,000: Darktide that tracks team statistics including kills, damage, killstreaks, and boss damage.

## API Documentation

This mod provides an API for other mods to access team statistics data.

### Usage Example

```lua
local teamkills_mod = get_mod("TeamKills")
if teamkills_mod then
    -- Get all player kills
    local player_kills = teamkills_mod.get_player_kills()
    
    -- Get all player damage
    local player_damage = teamkills_mod.get_player_damage()
    
    -- Get data for specific player
    local player_data = teamkills_mod.get_player_data(account_id)
    
    -- Get all data
    local all_data = teamkills_mod.get_all_data()
end
```

### API Functions

#### `get_player_kills()`
Returns a copy of all player kills data.
- **Returns:** `table` - `{account_id = kills_count, ...}`

#### `get_player_damage()`
Returns a copy of all player damage data.
- **Returns:** `table` - `{account_id = damage_amount, ...}`

#### `get_player_last_damage()`
Returns a copy of all player last damage data.
- **Returns:** `table` - `{account_id = last_damage_amount, ...}`

#### `get_kills_by_category()`
Returns a copy of kills by category for all players.
- **Returns:** `table` - `{account_id = {breed_name = count, ...}, ...}`

#### `get_damage_by_category()`
Returns a copy of damage by category for all players.
- **Returns:** `table` - `{account_id = {breed_name = damage, ...}, ...}`

#### `get_player_killstreak()`
Returns a copy of all player killstreak data.
- **Returns:** `table` - `{account_id = killstreak_count, ...}`

#### `get_boss_damage()`
Returns a copy of boss damage data.
- **Returns:** `table` - `{boss_unit = {account_id = damage, ...}, ...}`

#### `get_boss_last_damage()`
Returns a copy of last damage to bosses.
- **Returns:** `table` - `{boss_unit = {account_id = last_damage, ...}, ...}`

#### `get_player_data(account_id)`
Returns all data for a specific player.
- **Parameters:**
  - `account_id` (string) - Player account ID
- **Returns:** `table` or `nil` - Player data object containing:
  - `kills` (number) - Total kills
  - `damage` (number) - Total damage
  - `last_damage` (number) - Last damage dealt
  - `killstreak` (number) - Current killstreak
  - `kills_by_category` (table) - Kills by breed category
  - `damage_by_category` (table) - Damage by breed category

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

---

## Документация API

Этот мод предоставляет API для других модов для доступа к статистике команды.

### Пример использования

```lua
local teamkills_mod = get_mod("TeamKills")
if teamkills_mod then
    -- Получить все убийства игроков
    local player_kills = teamkills_mod.get_player_kills()
    
    -- Получить весь урон игроков
    local player_damage = teamkills_mod.get_player_damage()
    
    -- Получить данные конкретного игрока
    local player_data = teamkills_mod.get_player_data(account_id)
    
    -- Получить все данные
    local all_data = teamkills_mod.get_all_data()
end
```

### API Функции

#### `get_player_kills()`
Возвращает копию данных об убийствах всех игроков.
- **Возвращает:** `table` - `{account_id = количество_убийств, ...}`

#### `get_player_damage()`
Возвращает копию данных об уроне всех игроков.
- **Возвращает:** `table` - `{account_id = количество_урона, ...}`

#### `get_player_last_damage()`
Возвращает копию данных о последнем уроне всех игроков.
- **Возвращает:** `table` - `{account_id = последний_урон, ...}`

#### `get_kills_by_category()`
Возвращает копию убийств по категориям для всех игроков.
- **Возвращает:** `table` - `{account_id = {имя_породы = количество, ...}, ...}`

#### `get_damage_by_category()`
Возвращает копию урона по категориям для всех игроков.
- **Возвращает:** `table` - `{account_id = {имя_породы = урон, ...}, ...}`

#### `get_player_killstreak()`
Возвращает копию данных о сериях убийств всех игроков.
- **Возвращает:** `table` - `{account_id = количество_в_серии, ...}`

#### `get_boss_damage()`
Возвращает копию данных об уроне по боссам.
- **Возвращает:** `table` - `{юнит_босса = {account_id = урон, ...}, ...}`

#### `get_boss_last_damage()`
Возвращает копию последнего урона по боссам.
- **Возвращает:** `table` - `{юнит_босса = {account_id = последний_урон, ...}, ...}`

#### `get_player_data(account_id)`
Возвращает все данные для конкретного игрока.
- **Параметры:**
  - `account_id` (string) - ID аккаунта игрока
- **Возвращает:** `table` или `nil` - Объект с данными игрока, содержащий:
  - `kills` (number) - Всего убийств
  - `damage` (number) - Всего урона
  - `last_damage` (number) - Последний нанесенный урон
  - `killstreak` (number) - Текущая серия убийств
  - `kills_by_category` (table) - Убийства по категориям пород
  - `damage_by_category` (table) - Урон по категориям пород

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

---

## Notes / Примечания

- All API functions return **deep copies** of data to prevent modification of original data.
- All functions are safe to call even if data doesn't exist yet (returns empty tables or nil).
- The `account_id` parameter should be the player's account ID or name.

- Все API функции возвращают **глубокие копии** данных, чтобы предотвратить изменение оригинальных данных.
- Все функции безопасны для вызова, даже если данные еще не существуют (возвращают пустые таблицы или nil).
- Параметр `account_id` должен быть ID аккаунта или именем игрока.

