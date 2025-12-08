# 📊 Вкладка "Общее" (General)

---

## Статистики для вкладки "Общее"

### 🎯 Убийства - Общие:

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `total_kills` | Своя: `stats_total_kills` | Общее количество убийств |
| `total_renegade_kills` | Своя: `stats_renegade_kills` | Убийства ренегатов |
| `total_cultist_kills` | Своя: `stats_cultist_kills` | Убийства культистов |
| `total_chaos_kills` | Своя: `stats_chaos_kills` | Убийства хаоса |

### 🎯 Убийства - Специальные:

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `enemies_killed_with_barrels` | Игра: `loc_achievement_enemies_killed_by_barrels_name`<br>Своя: `stats_barrel_kills` | Враги убиты бочками |
| `enemies_killed_with_poxburster_explosion` | Игра: `loc_achievement_enemies_killed_by_poxburster_name`<br>Своя: `stats_poxburster_explosion_kills` | Враги убиты взрывами поксбурстеров |

### 🐕 Companion (Собака):

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `adamant_killed_enemies_pounced_by_companion` | Своя: `stats_companion_pounce_kills` | Убийства врагов, прыгнутых компаньоном |
| `adamant_team_companion_in_coherency_kills` | Своя: `stats_companion_coherency_kills` | Убийства команды с компаньоном в coherency |

### 📝 Прочие убийства:

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `other_kills` | Своя: `stats_other_kills` | Рассчитывается как разница: `total_kills - (все остальные типы)` |

### 🗺️ Миссии (краткая):

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `missions` | Своя: `stats_missions` | Пройдено миссий |
| `auric_missions` | Своя: `stats_auric_missions` | Auric миссий |
| `havoc_missions` | Своя: `stats_havoc_missions` | Havoc миссий |

---

## 💻 Пример кода для вкладки:

```lua
-- tab_general.lua

local layout = {}

-- Общие убийства
local total_kills = safe_read_stat("total_kills")
local renegade_kills = safe_read_stat("total_renegade_kills")
local cultist_kills = safe_read_stat("total_cultist_kills")
local chaos_kills = safe_read_stat("total_chaos_kills")

table.insert(layout, {
    widget_type = "stat_line", 
    text = localize("stats_total_kills"), 
    value = format_number(total_kills)
})

-- Специальные убийства
local barrel_kills = safe_read_stat("enemies_killed_with_barrels")
table.insert(layout, {
    widget_type = "stat_line", 
    text = localize("loc_achievement_enemies_killed_by_barrels_name"),  -- Официальная локализация
    value = format_number(barrel_kills)
})
```

---

## 📋 Текущая реализация:

Файл: `PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_general.lua`

Отображает:
1. Общее количество убийств
2. Разбивку по фракциям (Renegade, Cultist, Chaos)
3. Специальные убийства (бочки, взрывы поксбурстеров)
4. Убийства с компаньоном (если > 0)
5. Краткую статистику миссий

---

## 🔧 Для добавления новых статистик:

1. Найдите ключ статистики в `stat_definitions.lua`
2. Проверьте флаг `StatFlags.backend` (должен быть для сохранения)
3. Найдите локализацию в `achievement_definitions.lua` или `breeds.lua`
4. Добавьте в `tab_general.lua`
5. При необходимости добавьте свою локализацию в `PlayerProgressStats_localization.lua`

