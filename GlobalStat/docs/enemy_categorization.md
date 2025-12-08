# ⚔️ Категоризация врагов Darktide

---

## 📊 Полная классификация на основе исходников игры

Категоризация основана на анализе файлов `breed_settings` из исходного кода игры.

---

## 👹 БОССЫ (is_boss = true)

Враги с флагом `is_boss = true`:

| Breed Name | Localization Key | Статистика |
|-----------|------------------|------------|
| `chaos_beast_of_nurgle` | `loc_breed_display_name_chaos_beast_of_nurgle` | `total_chaos_beast_of_nurgle_killed` |
| `chaos_spawn` | `loc_breed_display_name_chaos_spawn` | `total_chaos_spawn_killed` |
| `chaos_plague_ogryn` | `loc_breed_display_name_chaos_plague_ogryn` | `total_chaos_plague_ogryn_killed` |
| `chaos_daemonhost` | `loc_breed_display_name_chaos_daemonhost` | `total_chaos_daemonhost_killed` |
| `chaos_mutator_daemonhost` | `loc_breed_display_name_chaos_daemonhost` | `total_chaos_mutator_daemonhost_killed` |
| `renegade_captain` | `loc_breed_display_name_renegade_captain` | `total_renegade_captain_killed` |
| `renegade_twin_captain` | `loc_breed_display_name_renegade_twin_captain` | `total_renegade_twin_captain_killed` |
| `renegade_twin_captain_two` | `loc_breed_display_name_renegade_twin_captain_two` | `total_renegade_twin_captain_two_killed` |
| `cultist_captain` | `loc_breed_display_name_cultist_captain` | `total_cultist_captain_killed` |

**Всего боссов: 9** (5 уникальных типов)

---

## 🛡️ ЭЛИТЫ (tags.elite = true)

Враги с тегом `elite = true`:

### Chaos Ogryn:
| Breed Name | Localization Key | Статистика |
|-----------|------------------|------------|
| `chaos_ogryn_gunner` | `loc_breed_display_name_chaos_ogryn_gunner` | `total_chaos_ogryn_gunner_killed` |
| `chaos_ogryn_executor` | `loc_breed_display_name_chaos_ogryn_executor` | `total_chaos_ogryn_executor_killed` |
| `chaos_ogryn_bulwark` | `loc_breed_display_name_chaos_ogryn_bulwark` | `total_chaos_ogryn_bulwark_killed` |

### Renegade (Scabs):
| Breed Name | Localization Key | Статистика |
|-----------|------------------|------------|
| `renegade_shocktrooper` | `loc_breed_display_name_renegade_shocktrooper` | `total_renegade_shocktrooper_killed` |
| `renegade_plasma_gunner` | `loc_breed_display_name_renegade_plasma_gunner` | `total_renegade_plasma_gunner_killed` |
| `renegade_radio_operator` | `loc_breed_display_name_renegade_radio_operator` | `total_renegade_radio_operator_killed` |
| `renegade_gunner` | `loc_breed_display_name_renegade_gunner` | `total_renegade_gunner_killed` |
| `renegade_executor` | `loc_breed_display_name_renegade_executor` | `total_renegade_executor_killed` |
| `renegade_berzerker` | `loc_breed_display_name_renegade_berzerker` | `total_renegade_berzerker_killed` |

### Cultist (Dregs):
| Breed Name | Localization Key | Статистика |
|-----------|------------------|------------|
| `cultist_shocktrooper` | `loc_breed_display_name_cultist_shocktrooper` | `total_cultist_shocktrooper_killed` |
| `cultist_gunner` | `loc_breed_display_name_cultist_gunner` | `total_cultist_gunner_killed` |
| `cultist_berzerker` | `loc_breed_display_name_cultist_berzerker` | `total_cultist_berzerker_killed` |

**Всего элитов: 12**

---

## ⚡ СПЕЦИАЛИСТЫ (tags.special = true)

Враги с тегом `special = true`:

| Breed Name | Localization Key | Статистика | Теги |
|-----------|------------------|------------|------|
| `chaos_poxwalker_bomber` | `loc_breed_display_name_chaos_poxwalker_bomber` | `total_chaos_poxwalker_bomber_killed` | bomber, scrambler |
| `chaos_hound` | `loc_breed_display_name_chaos_hound` | `total_chaos_hound_killed` | disabler |
| `chaos_hound_mutator` | `loc_breed_display_name_chaos_hound` | `total_chaos_hound_mutator_killed` | disabler, mutator |
| `cultist_mutant` | `loc_breed_display_name_cultist_mutant` | `total_cultist_mutant_killed` | disabler |
| `cultist_mutant_mutator` | `loc_breed_display_name_cultist_mutant` | `total_cultist_mutant_mutator_killed` | disabler, mutator |
| `cultist_flamer` | `loc_breed_display_name_cultist_flamer` | `total_cultist_flamer_killed` | scrambler |
| `cultist_grenadier` | `loc_breed_display_name_cultist_grenadier` | `total_cultist_grenadier_killed` | - |
| `renegade_flamer` | `loc_breed_display_name_renegade_flamer` | `total_renegade_flamer_killed` | scrambler |
| `renegade_flamer_mutator` | `loc_breed_display_name_renegade_flamer` | `total_renegade_flamer_mutator_killed` | mutator, scrambler |
| `renegade_grenadier` | `loc_breed_display_name_renegade_grenadier` | `total_renegade_grenadier_killed` | scrambler |
| `renegade_sniper` | `loc_breed_display_name_renegade_sniper` | `total_renegade_sniper_killed` | sniper |
| `renegade_netgunner` | `loc_breed_display_name_renegade_netgunner` | `total_renegade_netgunner_killed` | disabler |

**Всего специалистов: 12** (8 уникальных типов)

---

## 🧟 ОРДА (tags.horde = true)

Враги с тегом `horde = true`:

| Breed Name | Localization Key | Статистика | Доп. теги |
|-----------|------------------|------------|-----------|
| `chaos_poxwalker` | `loc_breed_display_name_chaos_poxwalker` | `total_chaos_poxwalker_killed` | melee, poxwalker |
| `chaos_mutated_poxwalker` | `loc_breed_display_name_chaos_mutated_poxwalker` | `total_chaos_mutated_poxwalker_killed` | melee, poxwalker |
| `chaos_lesser_mutated_poxwalker` | `loc_breed_display_name_chaos_lesser_mutated_poxwalker` | `total_chaos_lesser_mutated_poxwalker_killed` | melee, poxwalker |
| `chaos_newly_infected` | `loc_breed_display_name_chaos_newly_infected` | `total_chaos_newly_infected_killed` | melee |
| `chaos_armored_infected` | `loc_breed_display_name_chaos_armored_infected` | `total_chaos_armored_infected_killed` | melee |

**Всего орды: 5**

---

## 👥 ROAMERS (tags.roamer = true)

Базовые враги с тегом `roamer = true`:

### Renegade (Scabs):
| Breed Name | Localization Key | Статистика | Доп. теги |
|-----------|------------------|------------|-----------|
| `renegade_rifleman` | `loc_breed_display_name_renegade_rifleman` | `total_renegade_rifleman_killed` | far |
| `renegade_melee` | `loc_breed_display_name_renegade_melee` | `total_renegade_melee_killed` | melee |
| `renegade_assault` | `loc_breed_display_name_renegade_assault` | `total_renegade_assault_killed` | close |

### Cultist (Dregs):
| Breed Name | Localization Key | Статистика | Доп. теги |
|-----------|------------------|------------|-----------|
| `cultist_melee` | `loc_breed_display_name_cultist_melee` | `total_cultist_melee_killed` | melee |
| `cultist_assault` | `loc_breed_display_name_cultist_assault` | `total_cultist_assault_killed` | close, far |

**Всего roamers: 5**

---

## 📋 Итоговая статистика

| Категория | Количество врагов | В моде |
|-----------|-------------------|---------|
| **Боссы** | 9 (5 уникальных) | ✅ Все |
| **Элиты** | 12 | ✅ Все |
| **Специалисты** | 12 (8 уникальных) | ✅ Все |
| **Орда** | 5 | ✅ Все |
| **Roamers** | 5 | ✅ Все |
| **ИТОГО** | 43 | ✅ 43 |

---

## 🔧 Дополнительные теги

### Специализация по дальности:
- `melee` - ближний бой
- `far` - дальний бой
- `close` - средняя дистанция

### Специальные роли:
- `disabler` - контролирующие (Hound, Mutant, Netgunner)
- `scrambler` - создающие хаос (Flamer, Grenadier, Poxburster)
- `bomber` - взрывные (Poxburster)
- `sniper` - снайперы
- `ogryn` - огрины
- `monster` - монстры (боссы)
- `witch` - колдуны (Daemonhost)
- `poxwalker` - поксвокеры
- `captain` - капитаны (боссы)

---

## 💡 Примечания

### Суммирование в моде:
- **Daemonhost** = обычный + mutator
- **Hound** = обычный + mutator  
- **Mutant** = обычный + mutator
- **Flamer** = renegade + renegade_mutator + cultist
- **Grenadier** = renegade + cultist
- **Poxwalker** = обычный + mutated + lesser_mutated

### Не отслеживаются отдельно:
- `cultist_ritualist` - ритуалисты (редкие)
- `chaos_mutator_ritualist` - мутатор ритуалист
- `companion_dog` - собака игрока

---

## 🔍 Источник данных

Файлы: `Darktide-Source-Code/scripts/settings/breed/breeds/**/*_breed.lua`

Проверка категории:
```lua
is_boss = true  -- Босс
tags = {
    elite = true,    -- Элита
    special = true,  -- Специалист
    horde = true,    -- Орда
    roamer = true,   -- Бродяга
}
```

---

**Версия:** 1.0  
**Дата:** 2025-12-01

