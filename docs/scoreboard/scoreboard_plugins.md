# scoreboard_default_plugins.lua - Отслеживание игровых событий

## Назначение

Файл содержит хуки для отслеживания игровых событий и обновления статистики на основе действий игроков. Это основной файл, который собирает данные для scoreboard.

## Основные компоненты

### Импорты

```lua
local InteractionSettings = mod:original_require("scripts/settings/interaction/interaction_settings")
local DamageProfileTemplates = mod:original_require("scripts/settings/damage/damage_profile_templates")
local TextUtilities = mod:original_require("scripts/utilities/ui/text")
local UISettings = mod:original_require("scripts/settings/ui/ui_settings")
local Breed = mod:original_require("scripts/utilities/breed")
local WalletSettings = mod:original_require("scripts/settings/wallet_settings")
```

**Назначение:** Импорт необходимых классов и настроек игры для работы с событиями.

---

## Вспомогательные функции

### `mod.player_from_unit(unit)`

**Назначение:** Получает объект игрока по игровому юниту.

**Параметры:**
- `unit` - Игровой юнит (unit)

**Возвращает:** Объект игрока или `nil`

**Что делает:**
- Проходит по всем игрокам через `Managers.player:players()`
- Сравнивает `player.player_unit` с переданным `unit`
- Возвращает найденного игрока

**Использование:** Преобразование игрового юнита в объект игрока для получения `account_id`.

---

### `mod.file_name(url)`

**Назначение:** Извлекает имя файла из полного пути.

**Параметры:**
- `url` - Полный путь к файлу (например, `"path/to/file.lua"`)

**Возвращает:** Имя файла (например, `"file.lua"`)

**Что делает:**
- Обрабатывает строку с конца до первого символа `/`
- Переворачивает результат для получения правильного порядка символов

**Использование:** Определение типа предмета по имени файла ресурса.

---

## Отслеживание когерентности

### Переменные

- **`mod.coherency_frequency`** (число) - Частота обновления когерентности в секундах (10)
- **`mod.coherency_timer`** (число) - Таймер до следующего обновления

### `mod.update_coherency(dt)`

**Назначение:** Обновляет статистику когерентности (близости к союзникам) для всех игроков.

**Параметры:**
- `dt` - Время, прошедшее с последнего кадра

**Что делает:**
1. Уменьшает таймер на `dt`
2. Когда таймер <= 0:
   - Проходит по всем игрокам
   - Для каждого игрока получает расширение `coherency_system`
   - Получает количество юнитов в когерентности через `num_units_in_coherency()`
   - Обновляет статистику `coherency_efficiency` с этим значением
   - Сбрасывает таймер на `coherency_frequency`

**Использование:** Вызывается каждый кадр из `mod.update()` для периодического обновления.

---

## Отслеживание переноски предметов

### Переменные

- **`mod.carrying`** (таблица) - Хранит информацию о переносимых предметах
  - Структура: `{[unit] = {[pickup_name] = pickup_name, ...}}`

### `mod.carrying_units()`

**Назначение:** Подсчитывает количество юнитов, несущих предметы.

**Возвращает:** Количество юнитов с предметами

**Использование:** Проверка, нужно ли обновлять статистику переноски.

---

### `mod.update_carrying(dt)`

**Назначение:** Обновляет статистику времени переноски предметов.

**Параметры:**
- `dt` - Время, прошедшее с последнего кадра

**Что делает:**
1. Подсчитывает количество несущих юнитов
2. Если есть несущие юниты:
   - Проходит по всем юнитам в `mod.carrying`
   - Для каждого предмета определяет тип:
     - `"scripture_pocketable"` → `"tomes"`
     - `"grimoire_pocketable"` → `"grims"`
     - Остальное → `"other"`
   - Получает игрока по юниту
   - Обновляет статистику `carrying_{type}` с приращением `dt` (время в секундах)

**Использование:** Вызывается каждый кадр из `mod.update()` для отслеживания времени переноски.

---

## Отслеживание оглушений врагов

### Переменные

- **`mod.last_enemy_interaction`** (таблица) - Хранит последнего игрока, взаимодействовавшего с врагом
  - Структура: `{[enemy_unit] = player_unit}`

### `mod.enemy_stagger(event_name, event_index, unit, first_person, context)`

**Назначение:** Обрабатывает событие оглушения врага.

**Параметры:**
- `event_name` - Имя события анимации
- `event_index` - Индекс события
- `unit` - Юнит врага
- `first_person` - Флаг первого лица
- `context` - Контекст события

**Что делает:**
1. Проверяет, есть ли запись о последнем взаимодействии с этим врагом
2. Получает игрока по `player_unit` из записи
3. Обновляет статистику `enemies_staggerd` с значением 1

**Использование:** Регистрируется как callback для событий анимации `enemy_stagger`.

---

### `mod.enemy_heavy_stagger(event_name, event_index, unit, first_person, context)`

**Назначение:** Обрабатывает событие сильного оглушения врага.

**Параметры:** Аналогично `enemy_stagger`

**Что делает:**
- Аналогично `enemy_stagger`, но обновляет статистику со значением 2 (более сильное оглушение)

**Использование:** Регистрируется как callback для событий анимации `enemy_stagger_heavy`.

---

## Отслеживание размещения ящиков

### Переменные

- **`mod.crates_equiped`** (таблица) - Хранит информацию о экипированных ящиках
  - Структура: `{[unit] = crate_name}`

### `mod.equip_crate(event_name, event_index, unit, first_person, context)`

**Назначение:** Отслеживает экипировку ящика игроком.

**Параметры:**
- `event_name` - Имя события анимации
- `event_index` - Индекс события
- `unit` - Юнит игрока
- `first_person` - Флаг первого лица
- `context` - Контекст события

**Что делает:**
1. Получает игрока по юниту
2. Если не первое лицо (третье лицо):
   - Получает компонент инвентаря через `unit_data_system`
   - Читает `slot_pocketable` (слот карманного предмета)
   - Извлекает имя файла предмета через `file_name()`
   - Сохраняет в `mod.crates_equiped[unit]`

**Использование:** Регистрируется как callback для события анимации `equip_crate`.

---

### `mod.drop_crate(event_name, event_index, unit, first_person, context)`

**Назначение:** Отслеживает размещение ящика игроком.

**Параметры:** Аналогично `equip_crate`

**Что делает:**
1. Получает игрока по юниту
2. Если не первое лицо и есть экипированный ящик:
   - Определяет тип ящика:
     - `"med_crate_pocketable"` → обновляет `health_placed`, показывает сообщение
     - `"ammo_cache_pocketable"` → обновляет `ammo_placed`, показывает сообщение
   - Удаляет запись из `mod.carrying[unit]`
   - Удаляет запись из `mod.crates_equiped[unit]`

**Использование:** Регистрируется как callback для события анимации `drop`.

---

## Отслеживание взаимодействий

### Хук `InteracteeExtension.stopped`

**Назначение:** Отслеживает завершение взаимодействия с объектами.

**Что делает:**
1. Проверяет, что взаимодействие успешно (`result == interaction_results.success`)
2. Получает тип взаимодействия через `interaction_type()`
3. Обрабатывает различные типы:

#### Тип "default" / "moveable_platform" / "scripted_scenario" / "luggable_socket"

- Обновляет `machinery_operated`
- Показывает сообщение, если включено `message_default`

#### Тип "pocketable"

- Определяет тип предмета через `mod.pickups`:
  - `"med_crate_pocketable"` - Мед. ящик
  - `"ammo_cache_pocketable"` - Ящик с боеприпасами
  - `"grimoire_pocketable"` - Гримуар
  - `"scripture_pocketable"` - Том
- Добавляет предмет в `mod.carrying[unit]`
- Обновляет `machinery_operated`
- Показывает сообщение, если включено соответствующее

#### Тип "health_station"

- Обновляет `heal_station_used`
- Показывает сообщение, если включено `message_health_station`

#### Тип "servo_skull" / "servo_skull_activator"

- Сохраняет связь юнита с объектом в `mod.interaction_units`
- Обновляет `gadget_operated`
- Показывает сообщение, если включено `message_decoded`

#### Тип "decoding" / "setup_decoding"

- Сохраняет связь юнита с объектом в `mod.interaction_units`
- (Обработка происходит в других хуках)

#### Тип "forge_material"

- Определяет тип материала через `mod.forge_material`:
  - `"loc_pickup_small_metal"` → `"small_metal"` (10 единиц)
  - `"loc_pickup_large_metal"` → `"large_metal"` (25 единиц)
  - `"loc_pickup_small_platinum"` → `"small_platinum"` (10 единиц)
  - `"loc_pickup_large_platinum"` → `"large_platinum"` (25 единиц)
- Обновляет соответствующую статистику с количеством единиц
- Показывает сообщение, если включено `message_forge_material`

#### Тип "ammunition"

- Определяет тип боеприпасов через `mod.ammunition`:
  - `"loc_pickup_consumable_small_clip_01"` → `"small_clip"` (15% от максимума)
  - `"loc_pickup_consumable_large_clip_01"` → `"large_clip"` (50% от максимума)
  - `"loc_pickup_deployable_ammo_crate_01"` → `"crate"` (до максимума)
- Вычисляет:
  - Текущий запас боеприпасов
  - Максимальный запас
  - Количество, которое можно взять
  - Потраченное впустую (если взято больше, чем нужно)
- Обновляет:
  - `ammo_small_picked_up` / `ammo_large_picked_up` / `ammo_crate_picked_up`
  - `ammo_picked_up` (реально взятое)
  - `ammo_wasted` (потраченное впустую)
- Показывает сообщение, если включено `message_ammo`

---

### Хук `InteracteeExtension.started`

**Назначение:** Отслеживает начало взаимодействия.

**Что делает:**
- Сохраняет связь юнита с объектом в `mod.interaction_units`
- Для типа "ammunition" сохраняет текущий запас боеприпасов в `mod.current_ammo[unit]` для последующего вычисления потраченного впустую

---

## Отслеживание взаимодействий с игроками

### Хук `PlayerInteracteeExtension.stopped`

**Назначение:** Отслеживает завершение взаимодействия с другим игроком.

**Что делает:**
1. Проверяет успешность взаимодействия
2. Обрабатывает типы:

#### Тип "pull_up" / "revive" / "remove_net"

- Обновляет `rescued_operative` (спасение)
- Показывает сообщение с именем спасенного игрока, если включено `message_revived_rescued`

#### Тип "rescue"

- Обновляет `revived_operative` (воскрешение)
- Показывает сообщение с именем воскрешенного игрока, если включено `message_revived_rescued`

---

## Отслеживание блокировок атак

### Хук `WeaponSystem.rpc_player_blocked_attack`

**Назначение:** Отслеживает блокировку атаки игроком.

**Параметры:**
- `channel_id` - ID канала сети
- `unit_id` - ID юнита игрока
- `attacking_unit_id` - ID атакующего юнита
- `hit_world_position` - Позиция попадания
- `block_broken` - Флаг пробития блока
- `weapon_template_id` - ID шаблона оружия
- `attack_type_id` - ID типа атаки

**Что делает:**
1. Получает юнит игрока по `unit_id`
2. Получает объект игрока
3. Обновляет статистику `attacks_blocked` с значением 1

---

## Отслеживание урона и убийств

### Переменные

- **`mod.bosses`** (массив) - Список имен боссов для определения типа врага
- **`mod.current_health`** (таблица) - Хранит текущее здоровье врагов
  - Структура: `{[enemy_unit] = health_value}`
- **`mod.last_enemy_interaction`** (таблица) - Последний игрок, взаимодействовавший с врагом

### Хук `AttackReportManager.add_attack_result`

**Назначение:** Отслеживает результаты атак игроков по врагам.

**Параметры:**
- `damage_profile` - Профиль урона
- `attacked_unit` - Атакованный юнит (враг)
- `attacking_unit` - Атакующий юнит (игрок)
- `attack_direction` - Направление атаки
- `hit_world_position` - Позиция попадания
- `hit_weakspot` - Флаг попадания в уязвимое место
- `damage` - Нанесенный урон
- `attack_result` - Результат атаки ("damaged" или "died")
- `attack_type` - Тип атаки
- `damage_efficiency` - Эффективность урона

**Что делает:**

1. **Проверка крита:**
   - Получает компонент `critical_strike` игрока
   - Если крит активен, обновляет `critical_hits` с значением 1

2. **Проверка попадания в уязвимое место:**
   - Если `hit_weakspot == true`, обновляет `weakspot_hits` с значением 1

3. **Обработка урона по миньонам:**
   - Проверяет, что цель - миньон через `Breed.is_minion()`
   - Сохраняет связь игрока с врагом в `mod.last_enemy_interaction`
   - Получает текущее здоровье врага
   - Вычисляет реальный урон и избыточный урон:
     - Если `attack_result == "damaged"`: реальный урон = минимум(урон, текущее здоровье)
     - Если `attack_result == "died"`: реальный урон = текущее здоровье, избыточный = урон - реальный
   - Обновляет здоровье врага в `mod.current_health`
   - Если враг убит, обновляет статистику убийств по имени породы (`breed_or_nil.name`)
   - Определяет тип врага (босс или обычный):
     - Если босс: обновляет `boss_damage_dealt` и `overkill_damage_dealt`
     - Если обычный: обновляет `actual_damage_dealt` и `overkill_damage_dealt`

---

### Хук `HuskHealthExtension.init`

**Назначение:** Инициализирует отслеживание здоровья врага при его создании.

**Что делает:**
- Сохраняет максимальное здоровье врага в `mod.current_health[unit]`

**Использование:** Отслеживание здоровья врагов для вычисления реального урона.

---

## Отслеживание полученного урона

### Хук `PlayerHuskHealthExtension.fixed_update`

**Назначение:** Отслеживает полученный урон игроком.

**Параметры:**
- `unit` - Юнит игрока
- `dt` - Время кадра
- `t` - Текущее время

**Что делает:**
1. Получает игрока по юниту
2. Если есть урон (`self._damage > 0`):
   - Обновляет статистику `damage_taken` с значением урона

**Использование:** Отслеживание полученного урона для статистики защиты.

---

## Отслеживание завершения декодирования

### Хук `DecoderDeviceSystem.rpc_decoder_device_place_unit`

**Назначение:** Отслеживает размещение устройства декодирования.

**Что делает:**
1. Получает юнит устройства
2. Находит игрока через `mod.interaction_units[unit]`
3. Обновляет `gadget_operated`
4. Показывает сообщение, если включено `message_decoded`

---

### Хук `DecoderDeviceSystem.rpc_decoder_device_finished`

**Назначение:** Отслеживает завершение декодирования.

**Что делает:**
- Аналогично `rpc_decoder_device_place_unit`

---

### Хук `MinigameSystem.rpc_minigame_sync_completed`

**Назначение:** Отслеживает завершение мини-игры (сканирование).

**Что делает:**
- Аналогично предыдущим хукам декодирования

---

## Отслеживание сканирования

### Хук `ScanningEventSystem.rpc_scanning_device_finished`

**Назначение:** Отслеживает завершение сканирования устройства.

**Примечание:** В текущей версии только логирует событие, не обновляет статистику.

---

### Хук `ScanningDeviceExtension.finished_event`

**Назначение:** Отслеживает завершение сканирования через расширение.

**Примечание:** В текущей версии только логирует событие, не обновляет статистику.

---

## Вспомогательные таблицы

### `mod.pickups`
**Назначение:** Маппинг локализованных имен на внутренние имена предметов
```lua
{
    loc_pickup_pocketable_medical_crate_01 = "med_crate_pocketable",
    loc_pickup_pocketable_ammo_crate_01 = "ammo_cache_pocketable",
    loc_pickup_side_mission_pocketable_01 = "grimoire_pocketable",
    loc_pickup_side_mission_pocketable_02 = "scripture_pocketable",
}
```

### `mod.pickups_text`
**Назначение:** Обратный маппинг для получения локализованных имен
```lua
{
    med_crate_pocketable = "loc_pickup_pocketable_medical_crate_01",
    ammo_cache_pocketable = "loc_pickup_pocketable_ammo_crate_01",
    grimoire_pocketable = "loc_pickup_side_mission_pocketable_01",
    scripture_pocketable = "loc_pickup_side_mission_pocketable_02",
}
```

### `mod.forge_material`
**Назначение:** Маппинг локализованных имен материалов на внутренние имена
```lua
{
    loc_pickup_small_metal = "small_metal",
    loc_pickup_large_metal = "large_metal",
    loc_pickup_small_platinum = "small_platinum",
    loc_pickup_large_platinum = "large_platinum",
}
```

### `mod.forge_material_count`
**Назначение:** Количество единиц материала в каждом типе
```lua
{
    small_metal = 10,
    large_metal = 25,
    small_platinum = 10,
    large_platinum = 25,
}
```

### `mod.ammunition`
**Назначение:** Маппинг локализованных имен боеприпасов на внутренние имена
```lua
{
    loc_pickup_consumable_small_clip_01 = "small_clip",
    loc_pickup_consumable_large_clip_01 = "large_clip",
    loc_pickup_deployable_ammo_crate_01 = "crate",
}
```

### `mod.ammunition_percentage`
**Назначение:** Процент от максимума боеприпасов для каждого типа
```lua
{
    small_clip = 0.15,  -- 15%
    large_clip = 0.5,   -- 50%
}
```

### `mod.current_ammo`
**Назначение:** Хранит текущий запас боеприпасов игроков перед взаимодействием
- Структура: `{[unit] = ammo_count}`

### `mod.interaction_units`
**Назначение:** Хранит связь между объектами взаимодействия и игроками
- Структура: `{[interaction_unit] = player_unit}`

---

## Регистрация callback'ов анимации

### `mod.animation_events_add_packs`

**Назначение:** Определяет пакеты событий анимации для регистрации.

**Структура:**
```lua
{
    enemy_stagger = {список имен событий оглушения},
    enemy_stagger_heavy = {список имен событий сильного оглушения},
    equip_crate = {список имен событий экипировки ящика},
    drop = {список имен событий размещения ящика},
}
```

### `mod.animation_events_add_callbacks`

**Назначение:** Определяет функции-обработчики для событий анимации.

**Структура:**
```lua
{
    enemy_stagger = mod.enemy_stagger,
    enemy_stagger_heavy = mod.enemy_heavy_stagger,
    equip_crate = mod.equip_crate,
    drop = mod.drop_crate,
}
```

**Использование:** Эти таблицы используются системой модов для автоматической регистрации callback'ов.

---

## Функция для сообщений в чат

### `mod._get_player_presentation_name(unit)`

**Назначение:** Получает цветное имя игрока для отображения в сообщениях.

**Параметры:**
- `unit` - Юнит игрока

**Возвращает:** Строка с цветным именем игрока

**Что делает:**
1. Получает игрока через `player_unit_spawn_manager:owner(unit)`
2. Получает имя и слот игрока
3. Применяет цвет слота к имени через `TextUtilities.apply_color_to_text()`

**Использование:** Отображение имен игроков в сообщениях о действиях (воскрешение, спасение).

---

## Зависимости

- `InteractionSettings` - Настройки взаимодействий
- `DamageProfileTemplates` - Шаблоны урона
- `Breed` - Классификация пород врагов
- `TextUtilities` - Утилиты для работы с текстом
- `UISettings` - Настройки UI
- `WalletSettings` - Настройки валюты (для иконок материалов)

---

## Примеры использования

### Добавление собственного отслеживания события

```lua
mod:hook(CLASS.MySystem, "my_event", function(func, self, ...)
    local player_unit = ...
    local player = mod:player_from_unit(player_unit)
    if player then
        local account_id = player:account_id()
        mod:update_stat("my_custom_stat", account_id, 1)
    end
    return func(self, ...)
end)
```

### Отслеживание здоровья врага

```lua
mod.current_health[enemy_unit] = current_health_value
```

### Определение типа предмета

```lua
local pickup_name = mod.pickups[localized_name] or localized_name
```
