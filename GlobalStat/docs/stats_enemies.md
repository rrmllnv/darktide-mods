# ⚔️ Вкладка "Враги" (Enemies)

---

## 📊 Полная категоризация врагов

Все враги разбиты на **5 категорий** на основе их тегов в исходниках игры.

---

## БОССЫ (is_boss = true)

| Статистика | Локализация | В моде |
|-----------|-------------|--------|
| `total_chaos_beast_of_nurgle_killed` | `loc_breed_display_name_chaos_beast_of_nurgle` | ✅ |
| `total_chaos_spawn_killed` | `loc_breed_display_name_chaos_spawn` | ✅ |
| `total_chaos_plague_ogryn_killed` | `loc_breed_display_name_chaos_plague_ogryn` | ✅ |
| `total_chaos_daemonhost_killed` | `loc_breed_display_name_chaos_daemonhost` | ✅ (сумма) |
| `total_chaos_mutator_daemonhost_killed` | `loc_breed_display_name_chaos_daemonhost` | ✅ (сумма) |
| `total_renegade_captain_killed` | `loc_breed_display_name_renegade_captain` | ✅ |
| `total_renegade_twin_captain_killed` | `loc_breed_display_name_renegade_twin_captain` | ✅ |
| `total_renegade_twin_captain_two_killed` | `loc_breed_display_name_renegade_twin_captain_two` | ✅ |
| `total_cultist_captain_killed` | `loc_breed_display_name_cultist_captain` | ✅ |

**Примечание:** Daemonhost показывается как сумма обычного и mutator версий.

---

## ЭЛИТЫ (tags.elite = true)

### Chaos Ogryn Elites:
| Статистика | Локализация | Теги |
|-----------|-------------|------|
| `total_chaos_ogryn_gunner_killed` | `loc_breed_display_name_chaos_ogryn_gunner` | elite, far, ogryn |
| `total_chaos_ogryn_executor_killed` | `loc_breed_display_name_chaos_ogryn_executor` | elite, melee, ogryn |
| `total_chaos_ogryn_bulwark_killed` | `loc_breed_display_name_chaos_ogryn_bulwark` | elite, melee, ogryn, bulwark |

### Renegade (Scabs) Elites:
| Статистика | Локализация | Теги |
|-----------|-------------|------|
| `total_renegade_shocktrooper_killed` | `loc_breed_display_name_renegade_shocktrooper` | elite, close |
| `total_renegade_plasma_gunner_killed` | `loc_breed_display_name_renegade_plasma_gunner` | elite, far |
| `total_renegade_radio_operator_killed` | `loc_breed_display_name_renegade_radio_operator` | elite, far |
| `total_renegade_gunner_killed` | `loc_breed_display_name_renegade_gunner` | elite, far |
| `total_renegade_executor_killed` | `loc_breed_display_name_renegade_executor` | elite, melee |
| `total_renegade_berzerker_killed` | `loc_breed_display_name_renegade_berzerker` | elite, melee |

### Cultist (Dregs) Elites:
| Статистика | Локализация | Теги |
|-----------|-------------|------|
| `total_cultist_shocktrooper_killed` | `loc_breed_display_name_cultist_shocktrooper` | elite, close |
| `total_cultist_gunner_killed` | `loc_breed_display_name_cultist_gunner` | elite, far |
| `total_cultist_berzerker_killed` | `loc_breed_display_name_cultist_berzerker` | elite, melee |

---

## СПЕЦИАЛИСТЫ (tags.special = true)

| Статистика | Локализация | Теги | В моде |
|-----------|-------------|------|--------|
| `total_chaos_poxwalker_bomber_killed` | `loc_breed_display_name_chaos_poxwalker_bomber` | bomber, scrambler | ✅ |
| `total_chaos_hound_killed` | `loc_breed_display_name_chaos_hound` | disabler | ✅ (сумма) |
| `total_chaos_hound_mutator_killed` | `loc_breed_display_name_chaos_hound` | disabler, mutator | ✅ (сумма) |
| `total_cultist_mutant_killed` | `loc_breed_display_name_cultist_mutant` | disabler | ✅ (сумма) |
| `total_cultist_mutant_mutator_killed` | `loc_breed_display_name_cultist_mutant` | disabler, mutator | ✅ (сумма) |
| `total_cultist_flamer_killed` | `loc_breed_display_name_cultist_flamer` | scrambler | ✅ отдельно |
| `total_cultist_grenadier_killed` | `loc_breed_display_name_cultist_grenadier` | - | ✅ отдельно |
| `total_renegade_flamer_killed` | `loc_breed_display_name_renegade_flamer` | scrambler | ✅ (сумма) |
| `total_renegade_flamer_mutator_killed` | `loc_breed_display_name_renegade_flamer` | mutator, scrambler | ✅ (сумма) |
| `total_renegade_grenadier_killed` | `loc_breed_display_name_renegade_grenadier` | scrambler | ✅ отдельно |
| `total_renegade_sniper_killed` | `loc_breed_display_name_renegade_sniper` | sniper | ✅ |
| `total_renegade_netgunner_killed` | `loc_breed_display_name_renegade_netgunner` | disabler | ✅ |

**Суммирование в моде:**
- Hound = обычный + mutator (один враг)
- Mutant = обычный + mutator (один враг)
- Renegade Flamer = обычный + mutator (один враг)
- Cultist Flamer = показывается отдельно
- Renegade Grenadier = показывается отдельно
- Cultist Grenadier = показывается отдельно

**Важно:** Враги из разных фракций НЕ объединяются!

---

## ОРДА (tags.horde = true)

| Статистика | Локализация | Доп. теги |
|-----------|-------------|-----------|
| `total_chaos_poxwalker_killed` | `loc_breed_display_name_chaos_poxwalker` | melee, poxwalker |
| `total_chaos_mutated_poxwalker_killed` | `loc_breed_display_name_chaos_mutated_poxwalker` | melee, poxwalker |
| `total_chaos_lesser_mutated_poxwalker_killed` | `loc_breed_display_name_chaos_lesser_mutated_poxwalker` | melee, poxwalker |
| `total_chaos_newly_infected_killed` | `loc_breed_display_name_chaos_newly_infected` | melee |
| `total_chaos_armored_infected_killed` | `loc_breed_display_name_chaos_armored_infected` | melee |

**Суммирование в моде:** Все Poxwalker варианты суммируются

---

## ROAMERS (tags.roamer = true)

Базовые враги патрулирующие уровни:

### Renegade (Scabs):
| Статистика | Локализация | Тип боя |
|-----------|-------------|---------|
| `total_renegade_rifleman_killed` | `loc_breed_display_name_renegade_rifleman` | far (дальний) |
| `total_renegade_melee_killed` | `loc_breed_display_name_renegade_melee` | melee (ближний) |
| `total_renegade_assault_killed` | `loc_breed_display_name_renegade_assault` | close (средний) |

### Cultist (Dregs):
| Статистика | Локализация | Тип боя |
|-----------|-------------|---------|
| `total_cultist_melee_killed` | `loc_breed_display_name_cultist_melee` | melee (ближний) |
| `total_cultist_assault_killed` | `loc_breed_display_name_cultist_assault` | close, far (универсал) |

---

## 💻 Пример кода:

```lua
-- tab_enemies.lua

-- Боссы
table.insert(layout, {widget_type = "stat_header", text = localize("stats_bosses")})
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("loc_breed_display_name_chaos_daemonhost"),
    value = format_number(safe_read_stat("total_chaos_daemonhost_killed"))
})

-- Элиты
table.insert(layout, {widget_type = "stat_header", text = localize("stats_elites")})
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("loc_breed_display_name_chaos_ogryn_gunner"),
    value = format_number(safe_read_stat("total_chaos_ogryn_gunner_killed"))
})

-- Специалисты (разные фракции показываются отдельно)
-- Renegade Flamer (обычный + mutator)
local renegade_flamer = safe_read_stat("total_renegade_flamer_killed") + 
                        safe_read_stat("total_renegade_flamer_mutator_killed")
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("loc_breed_display_name_renegade_flamer"),
    value = format_number(renegade_flamer)
})

-- Cultist Flamer (отдельно)
table.insert(layout, {
    widget_type = "stat_line",
    text = localize("loc_breed_display_name_cultist_flamer"),
    value = format_number(safe_read_stat("total_cultist_flamer_killed"))
})
```

---

## 🔍 Проверка врага через консоль:

```bash
# Проверить название врага
/check_loc loc_breed_display_name_chaos_daemonhost

# Проверить убийства
/check_stat total_chaos_daemonhost_killed
```

---

## 📖 Дополнительная документация:

- [`enemy_categorization.md`](enemy_categorization.md) - Полная таблица категоризации
- [`stats_general.md`](stats_general.md) - Общие статистики
- [`STATS_REFERENCE.md`](../STATS_REFERENCE.md) - Главный справочник

---

**Версия:** 2.0  
**Обновлено:** 2025-12-01  
**Источник:** Darktide Source Code breed definitions
