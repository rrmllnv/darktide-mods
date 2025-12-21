# Руководство по созданию собственного колеса коммуникации для Darktide

Это руководство поможет вам создать собственное колесо коммуникации для Warhammer 40,000: Darktide, аналогичное `MourningstarCommandWheel`, но для голосовых команд и коммуникации.

## Структура проекта

```
YourModName/
├── YourModName.mod
└── scripts/
    └── mods/
        └── YourModName/
            ├── YourModName.lua              # Основной файл мода
            ├── YourModName_data.lua          # Настройки мода
            ├── YourModName_localization.lua   # Локализация
            ├── YourModName_settings.lua      # Параметры колеса
            ├── YourModName_definitions.lua   # Определения виджетов
            ├── YourModName_buttons.lua       # Определения кнопок/команд
            ├── YourModName_utils.lua         # Вспомогательные функции
            └── HudElementCommandWheel.lua    # HUD элемент колеса
```

## Основные компоненты

### 1. YourModName.lua - Регистрация мода

```lua
local mod = get_mod("YourModName")

-- Регистрация путей для require
mod:add_require_path("YourModName/scripts/mods/YourModName/YourModName_settings")
mod:add_require_path("YourModName/scripts/mods/YourModName/YourModName_definitions")
mod:add_require_path("YourModName/scripts/mods/YourModName/YourModName_utils")
mod:add_require_path("YourModName/scripts/mods/YourModName/YourModName_buttons")
mod:add_require_path("YourModName/scripts/mods/YourModName/HudElementCommandWheel")

-- Регистрация HUD элемента
local hud_elements = {
    {
        filename = "YourModName/scripts/mods/YourModName/HudElementCommandWheel",
        class_name = "HudElementCommandWheel",
        visibility_groups = {
            "alive",
            "dead",
        },
    },
}

-- Hook для добавления элемента в HUD
mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
    for _, hud_element in ipairs(hud_elements) do
        if not table.find_by_key(elements, "class_name", hud_element.class_name) then
            table.insert(elements, {
                class_name = hud_element.class_name,
                filename = hud_element.filename,
                visibility_groups = hud_element.visibility_groups,
            })
        end
    end
    
    return func(self, elements, visibility_groups, params)
end)

-- Сохранение ссылки на элемент
mod._command_wheel_element = nil

mod:hook_safe("HudElementCommandWheel", "init", function(self, parent, draw_layer, start_scale)
    mod._command_wheel_element = self
end)
```

### 2. YourModName_buttons.lua - Определение команд

```lua
local button_definitions = {
    {
        id = "thanks",
        label_key = "loc_communication_wheel_display_name_thanks",
        icon = "content/ui/materials/hud/communication_wheel/icons/thanks",
        voice_event_data = {
            voice_tag_concept = "on_demand_com_wheel",
            voice_tag_id = "com_wheel_vo_thank_you",
        },
        chat_message_data = {
            text = "loc_communication_wheel_thanks",
            channel = "mission",
        },
    },
    {
        id = "yes",
        label_key = "loc_social_menu_confirmation_popup_confirm_button",
        icon = "content/ui/materials/icons/list_buttons/check",
        voice_event_data = {
            voice_tag_concept = "on_demand_com_wheel",
            voice_tag_id = "com_wheel_vo_yes",
        },
    },
    -- Добавьте больше команд...
}

local button_definitions_by_id = {}
for i, button in ipairs(button_definitions) do
    button_definitions_by_id[button.id] = button
end

return {
    button_definitions = button_definitions,
    button_definitions_by_id = button_definitions_by_id,
}
```

### 3. YourModName_settings.lua - Настройки колеса

```lua
local command_wheel_settings = {
    anim_speed = 25,              -- Скорость анимации
    max_radius = 190,             -- Максимальный радиус колеса
    min_radius = 150,             -- Минимальный радиус колеса
    center_circle_size = 250,     -- Размер центрального круга
    hover_min_distance = 130,     -- Минимальное расстояние для hover
    hover_angle_degrees = 30,     -- Угол hover в градусах
    wheel_slots = 10,             -- Количество слотов в колесе
    icon_size = 80,               -- Размер иконок
    line_width = 200,             -- Ширина линий
    line_height = 147,            -- Высота линий
    icon_color_default = nil,     -- Цвет иконок по умолчанию
    icon_color_hover = nil,       -- Цвет иконок при hover
    line_color_default = nil,     -- Цвет линий по умолчанию
    line_color_hover = nil,       -- Цвет линий при hover
}

return settings("CommandWheelSettings", command_wheel_settings)
```

### 4. HudElementCommandWheel.lua - Основная логика

См. пример в `MourningstarCommandWheel` для полной реализации.

Основные функции:
- `init()` - инициализация элемента
- `update()` - обновление состояния
- `_setup_entries()` - создание виджетов для кнопок
- `_populate_wheel()` - заполнение колеса командами
- `_update_wheel_presentation()` - обновление отображения
- `_handle_input()` - обработка ввода

## Добавление голосовых команд

### Использование существующих реплик

```lua
{
    id = "emperor",
    label_key = "loc_communication_wheel_display_name_cheer",
    icon = "content/ui/materials/hud/communication_wheel/icons/for_the_emperor",
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",
        voice_tag_id = "com_wheel_vo_for_the_emperor",
    },
}
```

### Использование реплик из gameplay_vo

```lua
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

## Документация

- **ALL_VOICE_OPTIONS.md** - Полный список доступных голосовых реплик
- **VOICE_REPLICAS_EXPLANATION.md** - Объяснение использования разных типов реплик
- **CUSTOM_COMMANDS_GUIDE.md** - Руководство по добавлению кастомных команд
- **wheel_options_all.lua** - Пример файла со всеми доступными опциями

## Примеры

См. `MourningstarCommandWheel` как полный рабочий пример создания собственного колеса.

## Полезные ссылки

- Исходный код: `Darktide-Source-Code/scripts/ui/hud/elements/smart_tagging/`
- Пример мода: `darktide-mods/MourningstarCommandWheel/`
- Голосовые константы: `Darktide-Source-Code/scripts/settings/dialogue/vo_query_constants.lua`

