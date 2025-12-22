# Полный список ВСЕХ реплик из gameplay_vo для собственного колеса коммуникации

Этот документ содержит **ПОЛНЫЙ СПИСОК ВСЕХ РЕПЛИК** из файлов `gameplay_vo_*.lua`, которые можно использовать в вашем собственном колесе коммуникации.

**Важно:** Все эти реплики используют концепт `generic_mission_vo` (не `on_demand_com_wheel`).

## Структура использования

```lua
-- В YourModName_buttons.lua
{
    id = "replica_id",
    label_key = "loc_key",
    icon = "path/to/icon",
    voice_event_data = {
        voice_tag_concept = "generic_mission_vo",  -- Важно!
        voice_tag_id = "replica_name",  -- Имя из списка ниже
    },
}
```

---

## 1. calling_for_help - Просьба о помощи

**Полное имя реплики:** `calling_for_help`

**Использование:**
```lua
voice_tag_id = "calling_for_help"
```

**Доступность:** Есть во ВСЕХ файлах gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant - все варианты голосов)

---

## 2. almost_there - "Почти на месте"

**Полное имя реплики:** `almost_there`

**Использование:**
```lua
voice_tag_id = "almost_there"
```

**Доступность:** Есть во ВСЕХ файлах gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant - все варианты голосов)

---

## 3. away_from_squad - "Отстал от отряда"

**Полное имя реплики:** `away_from_squad`

**Использование:**
```lua
voice_tag_id = "away_from_squad"
```

**Доступность:** Есть во ВСЕХ файлах gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant - все варианты голосов)

---

## 4. combat_pause_one_liner - Короткие фразы в бою

**Полное имя реплики:** `combat_pause_one_liner`

**Использование:**
```lua
voice_tag_id = "combat_pause_one_liner"
```

**Доступность:** Есть во ВСЕХ файлах gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant - все варианты голосов)

---

## 5. ability_* - Способности

### 5.1. Zealot (Фанатик) - Основные файлы gameplay_vo_zealot_*.lua

**Полное имя реплики:** `ability_maniac`

**Использование:**
```lua
voice_tag_id = "ability_maniac"
```

**Доступность:** Все варианты голосов zealot (male_a, male_b, male_c, female_a, female_b, female_c)

### 5.2. Veteran (Ветеран) - Основные файлы gameplay_vo_veteran_*.lua

**Полное имя реплики:** `ability_ranger`

**Использование:**
```lua
voice_tag_id = "ability_ranger"
```

**Доступность:** Все варианты голосов veteran (male_a, male_b, male_c, female_a, female_b, female_c)

### 5.3. Psyker (Псайкер) - Основные файлы gameplay_vo_psyker_*.lua

**Полное имя реплики 1:** `ability_biomancer_high`

**Использование:**
```lua
voice_tag_id = "ability_biomancer_high"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 2:** `ability_biomancer_low`

**Использование:**
```lua
voice_tag_id = "ability_biomancer_low"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 3:** `ability_venting`

**Использование:**
```lua
voice_tag_id = "ability_venting"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

### 5.4. Ogryn (Огрун) - Основные файлы gameplay_vo_ogryn_*.lua

**Полное имя реплики:** `ability_bonebreaker`

**Использование:**
```lua
voice_tag_id = "ability_bonebreaker"
```

**Доступность:** Все варианты голосов ogryn (a, b, c, d)

### 5.5. Zealot Class Rework - Файлы class_rework_zealot_*.lua

**Полное имя реплики 1:** `ability_banisher`

**Использование:**
```lua
voice_tag_id = "ability_banisher"
```

**Доступность:** Все варианты голосов zealot (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 2:** `ability_banisher_impact`

**Использование:**
```lua
voice_tag_id = "ability_banisher_impact"
```

**Доступность:** Все варианты голосов zealot (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 3:** `ability_pious_stabber`

**Использование:**
```lua
voice_tag_id = "ability_pious_stabber"
```

**Доступность:** Все варианты голосов zealot (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 4:** `ability_repent_a`

**Использование:**
```lua
voice_tag_id = "ability_repent_a"
```

**Доступность:** Все варианты голосов zealot (male_a, male_b, male_c, female_a, female_b, female_c)

### 5.6. Veteran Class Rework - Файлы class_rework_veteran_*.lua

**Полное имя реплики 1:** `ability_shock_trooper`

**Использование:**
```lua
voice_tag_id = "ability_shock_trooper"
```

**Доступность:** Все варианты голосов veteran (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 2:** `ability_squad_leader`

**Использование:**
```lua
voice_tag_id = "ability_squad_leader"
```

**Доступность:** Все варианты голосов veteran (male_a, male_b, male_c, female_a, female_b, female_c)

### 5.7. Psyker Class Rework - Файлы class_rework_psyker_*.lua

**Полное имя реплики 1:** `ability_buff_stance_a`

**Использование:**
```lua
voice_tag_id = "ability_buff_stance_a"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 2:** `ability_gunslinger`

**Использование:**
```lua
voice_tag_id = "ability_gunslinger"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 3:** `ability_protectorate_start`

**Использование:**
```lua
voice_tag_id = "ability_protectorate_start"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 4:** `ability_protectorate_stop`

**Использование:**
```lua
voice_tag_id = "ability_protectorate_stop"
```

**Доступность:** Все варианты голосов psyker (male_a, male_b, male_c, female_a, female_b, female_c)

### 5.8. Ogryn Class Rework - Файлы class_rework_ogryn_*.lua

**Полное имя реплики 1:** `ability_bullgryn`

**Использование:**
```lua
voice_tag_id = "ability_bullgryn"
```

**Доступность:** Все варианты голосов ogryn (a, b, c, d)

**Полное имя реплики 2:** `ability_gun_lugger`

**Использование:**
```lua
voice_tag_id = "ability_gun_lugger"
```

**Доступность:** Все варианты голосов ogryn (a, b, c, d)

### 5.9. Adamant (Особый персонаж) - Файлы adamant_adamant_*.lua

**Полное имя реплики 1:** `ability_charge_a`

**Использование:**
```lua
voice_tag_id = "ability_charge_a"
```

**Доступность:** Все варианты голосов adamant (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 2:** `ability_howl_a`

**Использование:**
```lua
voice_tag_id = "ability_howl_a"
```

**Доступность:** Все варианты голосов adamant (male_a, male_b, male_c, female_a, female_b, female_c)

**Полное имя реплики 3:** `ability_stance_a`

**Использование:**
```lua
voice_tag_id = "ability_stance_a"
```

**Доступность:** Все варианты голосов adamant (male_a, male_b, male_c, female_a, female_b, female_c)

---

## 6. alerted_* - Предупреждения

### 6.1. Daemonhost (Демон-хост)

**Полное имя реплики 1:** `alerted_2_enemy_daemonhost`

**Использование:**
```lua
voice_tag_id = "alerted_2_enemy_daemonhost"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant - все варианты голосов)

**Полное имя реплики 2:** `alerted_enemy_daemonhost`

**Использование:**
```lua
voice_tag_id = "alerted_enemy_daemonhost"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant - все варианты голосов)

---

## 7. found_* - Находки

### 7.1. Патроны (Ammo)

**Полное имя реплики 1:** `found_ammo_ogryn_low_on_ammo`

**Использование:**
```lua
voice_tag_id = "found_ammo_ogryn_low_on_ammo"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 2:** `found_ammo_psyker_low_on_ammo`

**Использование:**
```lua
voice_tag_id = "found_ammo_psyker_low_on_ammo"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 3:** `found_ammo_veteran_low_on_ammo`

**Использование:**
```lua
voice_tag_id = "found_ammo_veteran_low_on_ammo"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 4:** `found_ammo_zealot_low_on_ammo`

**Использование:**
```lua
voice_tag_id = "found_ammo_zealot_low_on_ammo"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

### 7.2. Здоровье (Health) - Базовые реплики

**Полное имя реплики 1:** `found_health_booster`

**Использование:**
```lua
voice_tag_id = "found_health_booster"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 2:** `found_health_booster_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_booster_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

### 7.3. Здоровье (Health) - Специфичные для класса

**Полное имя реплики 1:** `found_health_booster_ogryn_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_booster_ogryn_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 2:** `found_health_booster_psyker_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_booster_psyker_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 3:** `found_health_booster_veteran_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_booster_veteran_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 4:** `found_health_booster_zealot_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_booster_zealot_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

### 7.4. Здоровье (Health) - Станции здоровья

**Полное имя реплики 1:** `found_health_station_ogryn_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_station_ogryn_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 2:** `found_health_station_psyker_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_station_psyker_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 3:** `found_health_station_veteran_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_station_veteran_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

**Полное имя реплики 4:** `found_health_station_zealot_low_on_health`

**Использование:**
```lua
voice_tag_id = "found_health_station_zealot_low_on_health"
```

**Доступность:** Все файлы gameplay_vo (zealot, veteran, psyker, ogryn - все варианты голосов)

---

## Полный список всех реплик для копирования

### Базовые реплики (есть везде):
- `calling_for_help`
- `almost_there`
- `away_from_squad`
- `combat_pause_one_liner`

### Способности (ability_*):
- `ability_maniac` (zealot)
- `ability_ranger` (veteran)
- `ability_biomancer_high` (psyker)
- `ability_biomancer_low` (psyker)
- `ability_venting` (psyker)
- `ability_bonebreaker` (ogryn)
- `ability_banisher` (zealot class rework)
- `ability_banisher_impact` (zealot class rework)
- `ability_pious_stabber` (zealot class rework)
- `ability_repent_a` (zealot class rework)
- `ability_shock_trooper` (veteran class rework)
- `ability_squad_leader` (veteran class rework)
- `ability_buff_stance_a` (psyker class rework)
- `ability_gunslinger` (psyker class rework)
- `ability_protectorate_start` (psyker class rework)
- `ability_protectorate_stop` (psyker class rework)
- `ability_bullgryn` (ogryn class rework)
- `ability_gun_lugger` (ogryn class rework)
- `ability_charge_a` (adamant)
- `ability_howl_a` (adamant)
- `ability_stance_a` (adamant)

### Предупреждения (alerted_*):
- `alerted_2_enemy_daemonhost`
- `alerted_enemy_daemonhost`

### Находки (found_*):
- `found_ammo_ogryn_low_on_ammo`
- `found_ammo_psyker_low_on_ammo`
- `found_ammo_veteran_low_on_ammo`
- `found_ammo_zealot_low_on_ammo`
- `found_health_booster`
- `found_health_booster_low_on_health`
- `found_health_booster_ogryn_low_on_health`
- `found_health_booster_psyker_low_on_health`
- `found_health_booster_veteran_low_on_health`
- `found_health_booster_zealot_low_on_health`
- `found_health_station_ogryn_low_on_health`
- `found_health_station_psyker_low_on_health`
- `found_health_station_veteran_low_on_health`
- `found_health_station_zealot_low_on_health`

---

## Примеры использования

### Пример 1: Просьба о помощи

```lua
-- В YourModName_buttons.lua
{
    id = "help",
    label_key = "loc_help",
    icon = "content/ui/materials/hud/interactions/icons/help",
    voice_event_data = {
        voice_tag_concept = "generic_mission_vo",
        voice_tag_id = "calling_for_help",
    },
}
```

### Пример 2: Способность Zealot

```lua
{
    id = "ability_maniac",
    label_key = "loc_ability_maniac",
    icon = "content/ui/materials/hud/abilities/icons/maniac",
    voice_event_data = {
        voice_tag_concept = "generic_mission_vo",
        voice_tag_id = "ability_maniac",
    },
}
```

### Пример 3: Предупреждение о демон-хосте

```lua
{
    id = "alert_daemonhost",
    label_key = "loc_alert_daemonhost",
    icon = "content/ui/materials/hud/enemies/icons/daemonhost",
    voice_event_data = {
        voice_tag_concept = "generic_mission_vo",
        voice_tag_id = "alerted_enemy_daemonhost",
    },
}
```

### Пример 4: Находка патронов

```lua
{
    id = "found_ammo",
    label_key = "loc_found_ammo",
    icon = "content/ui/materials/hud/items/icons/ammo",
    voice_event_data = {
        voice_tag_concept = "generic_mission_vo",
        voice_tag_id = "found_ammo_veteran_low_on_ammo",
    },
}
```

---

## Важные замечания

1. **Концепт:** Все реплики из `gameplay_vo` используют концепт `generic_mission_vo`, а не `on_demand_com_wheel`.

2. **Доступность:** Не все реплики доступны для всех персонажей. Проверьте наличие в конкретном файле `gameplay_vo_*.lua`.

3. **Class Rework:** Некоторые способности находятся в файлах `class_rework_*.lua`, а не в основных `gameplay_vo_*.lua`.

4. **Контекстные реплики:** Реплики `found_*` с указанием класса (например, `found_ammo_veteran_low_on_ammo`) произносятся, когда персонаж видит, что у другого персонажа низкий запас/здоровье.

5. **Использование:** Эти реплики можно использовать в вашем собственном колесе коммуникации, но они могут не всегда подходить для всех ситуаций, так как изначально предназначены для автоматического использования игрой.

---

## См. также

- `VOICE_REPLICAS_EXPLANATION.md` - Объяснение типов реплик
- `CUSTOM_COMMANDS_GUIDE.md` - Руководство по добавлению команд
- `ALL_VOICE_OPTIONS.md` - Полный список всех голосовых опций
