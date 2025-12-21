# Полный список реплик из gameplay_vo для собственного колеса коммуникации

Этот документ содержит **полный список всех реплик** из файлов `gameplay_vo_*.lua`, которые можно использовать в вашем собственном колесе коммуникации.

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

**Описание:** Реплики для запроса помощи от команды.

**Использование:**
```lua
voice_tag_id = "calling_for_help"
```

**Доступность:** Есть во всех файлах gameplay_vo (zealot, veteran, psyker, ogryn, все варианты голосов)

---

## 2. almost_there - "Почти на месте"

**Описание:** Реплики о том, что цель почти достигнута.

**Использование:**
```lua
voice_tag_id = "almost_there"
```

**Доступность:** Есть во всех файлах gameplay_vo (zealot, veteran, psyker, ogryn, все варианты голосов)

---

## 3. away_from_squad - "Отстал от отряда"

**Описание:** Реплики о том, что персонаж отстал от команды.

**Использование:**
```lua
voice_tag_id = "away_from_squad"
```

**Доступность:** Есть во всех файлах gameplay_vo (zealot, veteran, psyker, ogryn, все варианты голосов)

---

## 4. combat_pause_one_liner - Короткие фразы в бою

**Описание:** Короткие боевые фразы, произносимые во время паузы в бою.

**Использование:**
```lua
voice_tag_id = "combat_pause_one_liner"
```

**Доступность:** Есть во всех файлах gameplay_vo (zealot, veteran, psyker, ogryn, все варианты голосов)

---

## 5. ability_* - Способности

**Описание:** Реплики, связанные с использованием способностей персонажей.

### 5.1. Zealot (Фанатик)

- **ability_maniac** - Способность "Маньяк"
  - Доступность: Все варианты голосов zealot (male_a/b/c, female_a/b/c)

### 5.2. Veteran (Ветеран)

- **ability_ranger** - Способность "Рейнджер"
  - Доступность: Все варианты голосов veteran (male_a/b/c, female_a/b/c)

### 5.3. Psyker (Псайкер)

- **ability_biomancer_high** - Способность "Биомансер" (высокий уровень)
  - Доступность: Все варианты голосов psyker (male_a/b/c, female_a/b/c)

- **ability_biomancer_low** - Способность "Биомансер" (низкий уровень)
  - Доступность: Все варианты голосов psyker (male_a/b/c, female_a/b/c)

- **ability_venting** - Способность "Вентиляция"
  - Доступность: Все варианты голосов psyker (male_a/b/c, female_a/b/c)

### 5.4. Ogryn (Огрун)

- **ability_bonebreaker** - Способность "Костолом"
  - Доступность: Все варианты голосов ogryn (a/b/c/d)

### 5.5. Class Rework - Дополнительные способности

#### Zealot Class Rework:
- **ability_banisher** - Способность "Изгнатель"
- **ability_banisher_impact** - Способность "Изгнатель" (удар)
- **ability_pious_stabber** - Способность "Благочестивый закалыватель"
- **ability_repent_a** - Способность "Покаяние A"

#### Veteran Class Rework:
- **ability_shock_trooper** - Способность "Шоковый солдат"
- **ability_squad_leader** - Способность "Командир отряда"

#### Psyker Class Rework:
- **ability_buff_stance_a** - Способность "Буфф стойка A"
- **ability_gunslinger** - Способность "Гансlinger"
- **ability_protectorate_start** - Способность "Протекторат" (начало)
- **ability_protectorate_stop** - Способность "Протекторат" (конец)

#### Ogryn Class Rework:
- **ability_bullgryn** - Способность "Буллгрин"
- **ability_gun_lugger** - Способность "Ган Луггер"

#### Adamant (Особый персонаж):
- **ability_charge_a** - Способность "Зарядка A"
- **ability_howl_a** - Способность "Вой A"
- **ability_stance_a** - Способность "Стойка A"

**Примечание:** Class Rework реплики находятся в файлах `class_rework_*.lua` и `adamant_*.lua`, а не в основных `gameplay_vo_*.lua`.

---

## 6. alerted_* - Предупреждения

**Описание:** Реплики предупреждения о врагах.

### 6.1. Daemonhost (Демон-хост)

- **alerted_2_enemy_daemonhost** - Предупреждение о 2+ демон-хостах
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant)

- **alerted_enemy_daemonhost** - Предупреждение о демон-хосте
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn, broker, adamant)

**Примечание:** Эти реплики используются для предупреждения команды о присутствии опасного врага.

---

## 7. found_* - Находки

**Описание:** Реплики о найденных предметах (патроны, здоровье).

### 7.1. Патроны (Ammo)

- **found_ammo_ogryn_low_on_ammo** - Найдены патроны (для огруна с низким запасом)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_ammo_psyker_low_on_ammo** - Найдены патроны (для псайкера с низким запасом)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_ammo_veteran_low_on_ammo** - Найдены патроны (для ветерана с низким запасом)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_ammo_zealot_low_on_ammo** - Найдены патроны (для фанатика с низким запасом)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

**Примечание:** Эти реплики произносятся, когда персонаж находит патроны и видит, что у другого персонажа низкий запас патронов.

### 7.2. Здоровье (Health)

#### Базовые реплики:

- **found_health_booster** - Найден бустер здоровья
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_booster_low_on_health** - Найден бустер здоровья (у говорящего низкое здоровье)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

#### Специфичные для класса:

- **found_health_booster_ogryn_low_on_health** - Найден бустер здоровья (для огруна с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_booster_psyker_low_on_health** - Найден бустер здоровья (для псайкера с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_booster_veteran_low_on_health** - Найден бустер здоровья (для ветерана с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_booster_zealot_low_on_health** - Найден бустер здоровья (для фанатика с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

#### Станции здоровья:

- **found_health_station_ogryn_low_on_health** - Найдена станция здоровья (для огруна с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_station_psyker_low_on_health** - Найдена станция здоровья (для псайкера с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_station_veteran_low_on_health** - Найдена станция здоровья (для ветерана с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

- **found_health_station_zealot_low_on_health** - Найдена станция здоровья (для фанатика с низким здоровьем)
  - Доступность: Все файлы gameplay_vo (zealot, veteran, psyker, ogryn)

**Примечание:** Эти реплики произносятся, когда персонаж находит предметы здоровья и видит, что у другого персонажа низкое здоровье.

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
        voice_tag_id = "found_ammo_veteran_low_on_ammo",  -- Или другой вариант
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

