# 🗺️ Вкладка "Миссии" (Missions)

---

## 📊 Полная статистика миссий

Все статистики миссий разбиты на **6 категорий** на основе исходников игры.

---

## ОСНОВНЫЕ МИССИИ

| Статистика | Локализация | Описание | Флаги |
|-----------|-------------|----------|-------|
| `missions` | Своя: `stats_missions` | Общее количество пройденных миссий | `backend` |
| `auric_missions` | Своя: `stats_auric_missions` | Auric миссии (сложность 4-5) | `backend` |
| `havoc_missions` | Своя: `stats_havoc_missions` | Havoc миссии | `backend` |
| `mission_maelstrom` | Своя: `stats_maelstrom_missions` | Maelstrom миссии (flash missions) | `backend` |
| `mission_auric_maelstrom` | Своя: `stats_auric_maelstrom_missions` | Auric Maelstrom миссии | `backend` |
| `mission_circumstance` | Своя: `stats_circumstance_missions` | Миссии с обстоятельствами | `backend` |

**Условия:**
- `auric_missions`: `config.is_auric_mission == true`
- `havoc_missions`: `config.is_havoc == true`
- `mission_maelstrom`: `config.is_flash_mission == true`
- `mission_auric_maelstrom`: `config.is_flash_mission and config.is_auric_mission`
- `mission_circumstance`: миссии с активными обстоятельствами

---

## БЕЗУПРЕЧНЫЕ МИССИИ (FLAWLESS)

| Статистика | Локализация | Описание | Условие |
|-----------|-------------|----------|---------|
| `max_flawless_mission_in_a_row` | Своя: `stats_flawless_missions` | Макс. безупречных миссий подряд | Сложность >= 3, без смертей и падений игрока |
| `personal_flawless_auric` | Своя: `stats_personal_flawless_auric` | Личные безупречные Auric | Auric, без смертей игрока, joined <= 0.2 |
| `team_flawless_missions` | Своя: `stats_team_flawless_missions` | Командные безупречные миссии | Без падений всей команды |
| `flawless_auric_maelstrom` | Своя: `stats_flawless_auric_maelstrom` | Безупречные Auric Maelstrom | Auric + difficulty >= 5, без падений команды |
| `flawless_auric_maelstrom_consecutive` | Своя: `stats_flawless_auric_maelstrom_consecutive` | Auric Maelstrom подряд | Flash + Auric + diff >= 5, без смертей игрока |
| `flawless_havoc_won` | Своя: `stats_flawless_havoc_won` | Безупречные Havoc (ранг 35+) | Havoc rank >= 35, без смертей и падений |

**Разница между типами flawless:**
- **Personal**: без смертей **игрока** (`session_deaths == 0`)
- **Team**: без падений **всей команды** (`team_knock_downs == 0`)
- **Flawless in a row**: сбрасывается при смерти или падении игрока

---

## HAVOC

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `havoc_missions` | Своя: `stats_havoc_missions` | Всего Havoc миссий |
| `havoc_win_assisted` | Своя: `stats_havoc_win_assisted` | Havoc победы (не владелец заказа) |
| `havoc_rank_reached_01` | Своя: `stats_havoc_rank` | Ранг 5 достигнут |
| `havoc_rank_reached_02` | Своя: `stats_havoc_rank` | Ранг 10 достигнут |
| `havoc_rank_reached_03` | Своя: `stats_havoc_rank` | Ранг 15 достигнут |
| `havoc_rank_reached_04` | Своя: `stats_havoc_rank` | Ранг 20 достигнут |
| `havoc_rank_reached_05` | Своя: `stats_havoc_rank` | Ранг 25 достигнут |
| `havoc_rank_reached_06` | Своя: `stats_havoc_rank` | Ранг 30 достигнут |
| `havoc_rank_reached_07` | Своя: `stats_havoc_rank` | Ранг 35 достигнут |
| `havoc_rank_reached_08` | Своя: `stats_havoc_rank` | Ранг 40 достигнут |

**Логика определения ранга:**
```lua
local havoc_rank = 0
for i = 8, 1, -1 do
    if safe_read_stat("havoc_rank_reached_0" .. i) > 0 then
        havoc_rank = i * 5
        break
    end
end
```

**Условия:**
- `havoc_win_assisted`: `config.is_havoc and config.havoc_order_owner ~= config.account_id`
- `havoc_rank_reached_XX`: `config.is_havoc and required_rank <= config.havoc_rank`

---

## TWINS МИССИИ

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `mission_twins` | Своя: `stats_mission_twins` | Twins миссии (макс. сложность) |
| `mission_twins_hard_mode` | Своя: `stats_mission_twins_hard_mode` | Twins хард мод (сложность 5+) |
| `mission_twins_secret_puzzle_trigger` | Своя: `stats_mission_twins_secret_puzzle` | Активация секретной головоломки |
| `mission_twins_killed_successfully_within_x` | Своя: `stats_mission_twins_killed_within_x` | Оба Twins убиты за 5 секунд |
| `mission_twins_no_mines_triggered` | Своя: `stats_mission_twins_no_mines` | Twins без активации мин |

**Условия:**
- Все: `circumstance_name == "player_journey_010"`
- `mission_twins_hard_mode`: `has_hard_mode() and difficulty >= 5`
- `mission_twins_killed_successfully_within_x`: оба босса (`renegade_twin_captain` + `renegade_twin_captain_two`) убиты с интервалом < 5 секунд

---

## МИССИИ ПО ЗОНАМ

Формат: `zone_{zone_name}_missions_completed`

| Зона | Статистика | Локализация игры |
|------|-----------|------------------|
| Dust | `zone_dust_missions_completed` | `loc_zone_dust` |
| Entertainment | `zone_entertainment_missions_completed` | `loc_zone_entertainment` |
| Operations | `zone_operations_missions_completed` | `loc_zone_operations` |
| Tank Foundry | `zone_tank_foundry_missions_completed` | `loc_zone_tank_foundry` |
| Throneside | `zone_throneside_missions_completed` | `loc_zone_throneside` |
| Transit | `zone_transit_missions_completed` | `loc_zone_transit` |
| Void | `zone_void_missions_completed` | `loc_zone_void` |
| Watertown | `zone_watertown_missions_completed` | `loc_zone_watertown` |
| Horde | `zone_horde_missions_completed` | `loc_horde_mission_breifing_zone` |

**Примечание:** Зоны `hub`, `training_grounds`, `prologue`, `placeholder` не учитываются (имеют флаг `not_needed_for_penance`).

**Условие:** `MissionTemplates[config.mission_name].zone_id == zone_id`

---

## 💻 Пример кода:

```lua
-- tab_missions.lua

-- Основные миссии
table.insert(layout, {widget_type = "stat_header", text = localize("stats_missions_main")})
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("stats_missions"),
    value = format_number(safe_read_stat("missions"))
})
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("stats_auric_missions"),
    value = format_number(safe_read_stat("auric_missions"))
})

-- Flawless миссии С ПОДСКАЗКАМИ (tooltip при наведении)
table.insert(layout, {widget_type = "stat_header", text = localize("stats_flawless_header")})
table.insert(layout, {
    widget_type = "stat_line_tooltip",  -- Специальный blueprint с поддержкой tooltip
    text = localize("stats_personal_flawless_auric"),
    value = format_number(safe_read_stat("personal_flawless_auric")),
    tooltip = localize("tooltip_personal_flawless_auric")  -- Подсказка при наведении
})

-- Havoc ранг
local havoc_rank = 0
for i = 8, 1, -1 do
    if safe_read_stat("havoc_rank_reached_0" .. i) > 0 then
        havoc_rank = i * 5
        break
    end
end
if havoc_rank > 0 then
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_havoc_rank"),
        value = format_number(havoc_rank)
    })
end

-- Зоны (только те где есть миссии)
local zones = {
    {key = "dust", loc_key = "loc_zone_dust"},
    {key = "watertown", loc_key = "loc_zone_watertown"},
    -- ... остальные
}

for _, zone in ipairs(zones) do
    local stat_name = string.format("zone_%s_missions_completed", zone.key)
    local count = safe_read_stat(stat_name)
    if count > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize(zone.loc_key),
            value = format_number(count)
        })
    end
end
```

---

## 💡 ПОДСКАЗКИ ПРИ НАВЕДЕНИИ (TOOLTIPS)

Для **Flawless миссий** реализованы всплывающие подсказки при наведении мыши.

### Как это работает:

1. **Новый blueprint:** `stat_line_tooltip`
   - Хранит tooltip текст в `widget.content.tooltip`
   - Обычная высота строки (34px)
   
2. **Floating tooltip widget:**
   - Отдельный widget с z-index = 200
   - Плавает НАД элементом при hover
   - Не накладывается на текст
   - Динамический размер по тексту

3. **Использование:**
```lua
table.insert(layout, {
    widget_type = "stat_line_tooltip",  -- Вместо "stat_line"
    text = localize("stats_flawless_missions"),
    value = format_number(safe_read_stat("max_flawless_mission_in_a_row")),
    tooltip = localize("tooltip_flawless_missions")  -- Новый параметр
})
```

3. **Локализация tooltips:**
```lua
-- PlayerProgressStats_localization.lua
tooltip_flawless_missions = {
    en = "Difficulty 3+, no deaths or downs (player)",
    ru = "Сложность 3+, без смертей и падений (игрок)",
},
tooltip_personal_flawless_auric = {
    en = "Auric, no player deaths, joined ≤20%%",  -- %% = символ %
    ru = "Auric, без смертей игрока, вход ≤20%%",
},
```

**⚠️ Важно:** Символ `%` нужно экранировать как `%%` в Lua!

### Почему это полезно:

- ❓ **Flawless миссии** имеют сложные условия
- 📝 Подсказки объясняют условия без загромождения UI
- 🎯 Пользователь видит детали только при наведении
- 🌐 Поддержка локализации на всех языках
- ✅ Реализовано **по аналогии с DMF** (floating widget, не накладывается на текст)

### Доступные подсказки:

| Статистика | Tooltip ключ | Условие |
|-----------|--------------|---------|
| Max Flawless | `tooltip_flawless_missions` | Сложность 3+, без смертей/падений игрока |
| Personal Flawless Auric | `tooltip_personal_flawless_auric` | Auric, без смертей, вход ≤20%% (символ %% экранирован) |
| Team Flawless | `tooltip_team_flawless_missions` | Без падений команды |
| Flawless Auric Maelstrom | `tooltip_flawless_auric_maelstrom` | Auric + Diff 5+, без падений команды |
| Flawless Auric Maelstrom Consecutive | `tooltip_flawless_auric_maelstrom_consecutive` | Flash + Auric + Diff 5+, без смертей игрока |
| Flawless Havoc | `tooltip_flawless_havoc_won` | Havoc 35+, без смертей/падений команды |

**⚠️ Важно:** Если в tooltip нужен символ `%`, экранируйте его как `%%` в локализации!

---

## 🔧 Дополнительные статистики (не реализовано):

### Миссии по типам:

Формат: `mission_{mission_name}_difficulty_{1-5}`

Примеры:
- `mission_cm_raid_difficulty_5`
- `mission_dm_stockpile_difficulty_4`
- `mission_lm_scavenge_difficulty_3`

### Миссии по типам и аркетипам:

Формат: `mission_type_{type_index}_max_difficulty_{archetype_name}`

Примеры:
- `mission_type_1_max_difficulty_veteran`
- `mission_type_2_max_difficulty_zealot`

### Миссии по архетипам:

Формат: `missions_{archetype_name}_2_difficulty_{1-5}`

Примеры:
- `missions_veteran_2_difficulty_5`
- `missions_psyker_2_difficulty_4`

---

## 🔍 Проверка через консоль:

```bash
# Основные миссии
/check_stat missions
/check_stat auric_missions
/check_stat havoc_missions

# Flawless
/check_stat max_flawless_mission_in_a_row
/check_stat personal_flawless_auric

# Twins
/check_stat mission_twins
/check_stat mission_twins_hard_mode

# Зоны
/check_stat zone_watertown_missions_completed
/check_stat zone_dust_missions_completed

# Локализация зон
/check_loc loc_zone_watertown
/check_loc loc_zone_dust
```

---

## 📖 Дополнительная документация:

- [`enemy_categorization.md`](enemy_categorization.md) - Категоризация врагов
- [`stats_general.md`](stats_general.md) - Общие статистики
- [`STATS_REFERENCE.md`](../STATS_REFERENCE.md) - Главный справочник

---

## 🎯 Источники данных:

### Файлы исходников:
- `Darktide-Source-Code/scripts/managers/stats/stat_definitions.lua` (строки 1337-2236)
- `Darktide-Source-Code/scripts/settings/zones/zones.lua`
- `Darktide-Source-Code/scripts/settings/mission/mission_templates.lua`
- `Darktide-Source-Code/scripts/settings/mission/mission_types.lua`

### Ключевые секции:
- Строка 1337: `StatDefinitions.missions`
- Строка 1348: `StatDefinitions.auric_missions`
- Строка 1532-1718: Twins missions
- Строка 1939-1966: Zone missions (динамическая генерация)
- Строка 2061-2110: Flawless missions
- Строка 2151-2236: Havoc missions

---

**Версия:** 2.0  
**Обновлено:** 2025-12-02  
**Источник:** Darktide Source Code stat_definitions.lua
