# scoreboard_data.lua - Конфигурация настроек

## Назначение

Файл определяет все настройки мода, которые отображаются в меню настроек DMF.

## Структура

Файл возвращает таблицу с полем `options`, которое содержит массив `widgets` с определениями настроек.

## Типы настроек

### `keybind` - Горячая клавиша

**Поля:**
- `setting_id` - Уникальный идентификатор настройки
- `type` - `"keybind"`
- `default_value` - Значение по умолчанию (массив клавиш, например `{"f5"}`)
- `keybind_trigger` - Триггер (`"pressed"` или `"held"`)
- `keybind_type` - Тип привязки:
  - `"view_toggle"` - Переключение view
  - `"function_call"` - Вызов функции
- `view_name` - Имя view (если `keybind_type = "view_toggle"`)
- `function_name` - Имя функции (если `keybind_type = "function_call"`)

**Пример:**
```lua
{
    setting_id = "open_scoreboard_history",
    type = "keybind",
    default_value = {"f5"},
    keybind_trigger = "pressed",
    keybind_type = "view_toggle",
    view_name = "scoreboard_history_view"
}
```

---

### `checkbox` - Чекбокс

**Поля:**
- `setting_id` - Уникальный идентификатор
- `type` - `"checkbox"`
- `default_value` - Значение по умолчанию (`true` или `false`)
- `sub_widgets` - Массив дочерних виджетов (опционально)

**Пример:**
```lua
{
    setting_id = "tactical_overview",
    type = "checkbox",
    default_value = true
}
```

---

### `dropdown` - Выпадающий список

**Поля:**
- `setting_id` - Уникальный идентификатор
- `type` - `"dropdown"`
- `default_value` - Значение по умолчанию (число, индекс опции)
- `options` - Массив опций:
  - `text` - Ключ локализации текста
  - `value` - Значение опции
  - `show_widgets` - Виджеты, которые показываются при выборе (опционально)

**Пример:**
```lua
{
    setting_id = "generate_scores",
    type = "dropdown",
    default_value = 1,
    options = {
        {text = "generate_scores_on", value = 1},
        {text = "generate_scores_space", value = 2},
        {text = "generate_scores_off", value = 3}
    }
}
```

---

### `numeric` - Числовое значение

**Поля:**
- `setting_id` - Уникальный идентификатор
- `type` - `"numeric"`
- `default_value` - Значение по умолчанию
- `range` - Диапазон значений `{min, max}`

**Пример:**
```lua
{
    setting_id = "scoreboard_panel_height",
    type = "numeric",
    default_value = 1000,
    range = {580, 1000}
}
```

---

### `group` - Группа настроек

**Поля:**
- `setting_id` - Уникальный идентификатор
- `type` - `"group"`
- `sub_widgets` - Массив дочерних виджетов

**Пример:**
```lua
{
    setting_id = "group_plugins",
    type = "group",
    sub_widgets = {
        -- Дочерние настройки
    }
}
```

---

## Определенные настройки

### Основные настройки

1. **`open_scoreboard_history`** (keybind, F5)
   - Открывает view истории scoreboard

2. **`save_all_scoreboards`** (checkbox, true)
   - Автоматически сохранять scoreboard в конце миссии

3. **`tactical_overview`** (checkbox, true)
   - Показывать scoreboard в тактическом обзоре (HUD)

4. **`generate_scores`** (dropdown, 1)
   - Режим генерации очков:
     - 1: Показывать очки везде
     - 2: Показывать очки только в группах
     - 3: Не показывать очки

5. **`zero_values`** (dropdown, 1)
   - Отображение нулевых значений:
     - 1: Нормально
     - 2: Скрывать
     - 3: Темным цветом

6. **`worst_values`** (dropdown, 1)
   - Отображение худших значений:
     - 1: Нормально
     - 2: Темным цветом

7. **`dev_mode`** (checkbox, false)
   - Режим разработчика
   - Имеет дочернюю настройку `open_scoreboard` (keybind, F6)

8. **`scoreboard_panel_height`** (numeric, 1000)
   - Максимальная высота панели scoreboard (580-1000)

---

### Группа "group_plugins" - Плагины статистики

Содержит настройки включения/выключения различных строк статистики:

- **`plugin_forge_material`** - Материалы кузницы
- **`plugin_machinery_gadget_operated`** - Операции с механизмами
- **`plugin_coherency_efficiency`** - Когерентность
- **`plugin_ammo`** - Боеприпасы (dropdown: on/simple/off)
- **`plugin_carrying`** - Переноска предметов
- **`plugin_health_ammo_placed`** - Размещение предметов
- **`plugin_revived_rescued`** - Воскрешения и спасения
- **`plugin_damage_taken_heal_station_used`** - Полученный урон
- **`plugin_enemies_staggerd`** - Оглушения врагов
- **`plugin_attacks_blocked`** - Заблокированные атаки
- **`plugin_damage_dealt`** - Нанесенный урон (dropdown: on/simple/off)
- **`plugin_boss_damage_dealt`** - Урон по боссам
- **`plugin_special_hits`** - Особые попадания
- **`plugin_lesser_enemies`** - Малые враги
- **`plugin_melee_ranged_threats`** - Угрозы ближнего/дальнего боя
- **`plugin_disabler_threats`** - Обездвиживающие враги
- **`plugin_special_threats`** - Специальные враги
- **`plugin_boss_threats`** - Боссы

---

### Группа "group_messages" - Сообщения в чат

Содержит настройки отображения сообщений о действиях игроков:

- **`message_ammo`** - Сообщения о боеприпасах
- **`message_health_station`** - Сообщения об использовании мед. станций
- **`message_forge_material`** - Сообщения о материалах кузницы
- **`message_default`** - Сообщения об операциях с механизмами
- **`message_health_placed`** - Сообщения о размещении мед. ящиков
- **`message_ammo_placed`** - Сообщения о размещении ящиков с боеприпасами
- **`message_revived_rescued`** - Сообщения о воскрешениях/спасениях
- **`message_decoded`** - Сообщения о декодировании
- **`message_ammo_health_pickup`** - Сообщения о подборе предметов
- **`scripture_grimoire_pickup`** - Сообщения о подборе томов/гримуаров

---

## Использование настроек

### Получение значения настройки

```lua
local value = mod:get("setting_id")
```

### Проверка условия настройки

В строках статистики можно использовать условия:
```lua
setting = "plugin_ammo = 1"  -- Показывать только если plugin_ammo == 1
setting = "plugin_damage_dealt < 3"  -- Показывать только если plugin_damage_dealt < 3
```

### Обновление опций в UI

При изменении настройки вызывается `mod.on_setting_changed(setting_id)`, который:
1. Обновляет опцию в UI через `mod.update_option(setting_id)`
2. Обновляет флаги (например, `tactical_overview`)

---

## Локализация

Все тексты настроек должны быть определены в файле локализации с ключами:
- `mod_title` - Название мода
- `mod_description` - Описание мода
- Ключи для опций dropdown (например, `generate_scores_on`, `generate_scores_space`)

---

## Зависимости

- DMF (Darktide Mod Framework) - для системы настроек
