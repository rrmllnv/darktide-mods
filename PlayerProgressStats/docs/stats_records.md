# 🏆 Вкладка "Рекорды" (Records)

---

## Статистики для вкладки "Рекорды"

### 🎯 Убийства - Рекорды:

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `max_head_shot_in_a_row` | Своя: `stats_max_headshots` | Максимальное количество хедшотов подряд |
| `max_kills_last_60_sec` | Своя: `stats_max_kills_60s` | Максимальное количество убийств за 60 секунд |
| `max_head_shot_kills_last_10_sec` | Своя: `stats_max_headshots_10s` | Максимальное количество хедшотов за 10 секунд |
| `fastest_boss_kill` | Своя: `stats_fastest_boss_kill` | Самое быстрое убийство босса (в секундах) |

**Примечание:** `fastest_boss_kill` проверяется на диапазон `> 0 и < 18000` (до 5 часов).

### 🤝 Помощь союзникам:

| Статистика | Локализация | Описание | Флаг |
|-----------|-------------|----------|------|
| `total_player_rescues` | - | Общее количество спасений игроков | `backend` |
| `total_player_assists` | - | Общее количество ассистов (помощь союзникам) | `backend` |
| `max_different_players_rescued` | Своя: `stats_max_different_players_rescued` | Максимум разных игроков спасено в одной миссии | `backend` |

### 💪 Выносливость (Toughness):

| Статистика | Локализация | Описание | Ограничение |
|-----------|-------------|----------|-------------|
| `total_coherency_toughness` | - | Общее восстановление через coherency | Макс. 2000, флаг `never_log` |
| `total_melee_toughness_regen` | - | Общее восстановление в ближнем бою | Макс. 40000 |
| `max_dodges_in_a_row` | Своя: `stats_max_dodges_record` | Максимум уклонений подряд | - |
| `max_damage_blocked_last_20_sec` | Своя: `stats_max_damage_blocked_20s` | Макс. заблокированный урон за 20 секунд | - |

### 🛡️ Рекорды миссий

| Статистика | Локализация | Описание |
|-----------|-------------|----------|
| `lowest_damage_taken_on_win` | Своя: `stats_lowest_damage_taken` | Минимальный урон за победу |

---

## 💻 Пример кода для вкладки:

```lua
-- tab_records.lua

local layout = {}

-- Рекорды убийств
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("stats_max_headshots"),
    value = format_number(safe_read_stat("max_head_shot_in_a_row"))
})

table.insert(layout, {
    widget_type = "stat_line",
    text = localize("stats_max_kills_60s"),
    value = format_number(safe_read_stat("max_kills_last_60_sec"))
})

-- Самое быстрое убийство босса (с проверкой валидности)
local fastest_boss = safe_read_stat("fastest_boss_kill")
if fastest_boss > 0 and fastest_boss < 18000 then
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_fastest_boss_kill"),
        value = format_number(fastest_boss) .. "s"
    })
end

-- Помощь команде
table.insert(layout, {
    widget_type = "stat_line",
    text = "Player Rescues",
    value = format_number(safe_read_stat("total_player_rescues"))
})

table.insert(layout, {
    widget_type = "stat_line",
    text = "Player Assists",
    value = format_number(safe_read_stat("total_player_assists"))
})
```

---

## 📋 Текущая реализация:

Файл: `PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_records.lua`

Отображает:
1. Максимум хедшотов подряд
2. Максимум убийств за 60 секунд
3. Самое быстрое убийство босса (если есть)
4. Рекорды миссий: минимальный полученный урон при победе
5. **[TEST]** Player Rescues
6. **[TEST]** Player Assists
7. **[TEST]** Coherency Toughness
8. **[TEST]** Melee Toughness Regen

---

## 🔧 Дополнительные рекорды (не реализовано):

### Рекорды по классам:

#### Veteran (Sharpshooter):
| Статистика | Описание |
|-----------|----------|
| `max_weakspot_hit_during_volley_fire_alternate_fire` | Максимум попаданий в weakspot во время Volley Fire |
| `max_elite_weakspot_kill_during_volley_fire_alternate_fire` | Максимум убийств элит в weakspot во время Volley Fire |
| `veteran_accuracy_at_end_of_mission_with_no_ammo_left` | Точность в конце миссии без патронов |
| `veteran_min_melee_damage_taken` | Минимальный урон в ближнем бою |

#### Zealot (Preacher):
| Статистика | Описание |
|-----------|----------|
| `max_zealot_2_stagger_sniper_with_grenade_distance` | Макс. дистанция оглушения снайпера гранатой |
| `max_zealot_2_kills_of_shocked_enemies_last_15` | Макс. убийств оглушенных врагов за 15 сек |
| `max_zealot_2_health_healed_with_leech_during_resist_death` | Макс. здоровья восстановлено через leech во время Resist Death |
| `zealot_2_fastest_mission_with_low_health` | Самая быстрая миссия с низким здоровьем |

#### Psyker:
| Статистика | Описание |
|-----------|----------|
| `max_psyker_2_edge_kills_last_2_sec` | Максимум Edge убийств за 2 секунды |
| `max_psyker_2_time_at_max_souls` | Максимальное время на максимальных душах |

#### Ogryn:
| Статистика | Описание |
|-----------|----------|
| `max_ogryn_2_lunge_number_of_enemies_hit` | Максимум врагов поражено одним рывком |
| `max_ogryn_2_lunge_distance_last_x_seconds` | Максимальная дистанция рывка за X секунд |
| `max_ogryns_bullrushed` | Максимум огринов сбито рывком |

### Специфические достижения:

| Статистика | Описание |
|-----------|----------|
| `poxhound_pushed_mid_air` | Отталкивания псов в воздухе (макс. 50) |
| `bulwark_backstab_damage_inflicted` | Урон по булварку со спины |
| `grenadier_killed_before_attack_occurred` | Убийства гренадеров до атаки |
| `flamer_killed_before_attack_occurred` | Убийства фламеров до атаки |
| `team_poxburster_damage_avoided` | Урон от поксбурстеров избежанный командой |
| `team_chaos_spawned_killed_no_players_grabbed` | Убийства Chaos Spawn без захватов |
| `team_chaos_beast_of_nurgle_slain_no_corruption` | Убийства Beast без коррупции |

### Рекорды команды:

| Статистика | Описание |
|-----------|----------|
| `team_flawless_missions` | Безупречные миссии команды (без падений) |
| `lowest_damage_taken_on_win` | Минимальный полученный урон при победе |
| `max_different_players_rescued` | Максимум разных игроков спасено |

---

## 📝 Локализация в файле мода:

Файл: `PlayerProgressStats/scripts/mods/PlayerProgressStats/PlayerProgressStats_localization.lua`

```lua
stats_max_headshots = {
    en = "Max Headshots in a Row",
    ru = "Максимум хедшотов подряд",
},
stats_max_kills_60s = {
    en = "Max Kills in 60 Seconds",
    ru = "Максимум убийств за 60 секунд",
},
stats_fastest_boss_kill = {
    en = "Fastest Boss Kill",
    ru = "Самое быстрое убийство босса",
},
```

---

## 🔍 Источники данных:

- `stat_definitions.lua` - строки 776, 816-832, 858-870
- Все статистики с флагом `StatFlags.backend`
- Формат: `max_*` для максимальных значений

