# Многостраничное колесо команд

## Концепция

Реализация системы страниц для радиального меню команд, позволяющая переключаться между несколькими наборами команд.

**Идея:** 
- Первая страница - основные команды
- Кнопка переключения страниц (например, в центре или один из слотов)
- Вторая страница - дополнительные команды
- Возможность расширения до 3+ страниц

## План реализации

### 1. Структура данных для страниц

```lua
-- В HudElementCommandWheel.lua
local PAGE_CONFIGS = {
    page_1 = {
        id = "page_1",
        name = "Основные команды",
        commands = {
            "yes", "no", "thanks", "wait", "help",
            "follow_me", "take_this", "i_need_this"
        }
    },
    page_2 = {
        id = "page_2",
        name = "Тактические команды",
        commands = {
            "forward", "retreat", "hold", "group_up",
            "medkit_here", "ammo_here", "grenade_here"
        }
    },
    page_3 = {
        id = "page_3",
        name = "Враги",
        commands = {
            "sniper", "flamer", "bomber", "mutant",
            "ogryn", "boss", "elite"
        }
    }
}
```

### 2. Добавление состояния страницы

```lua
HudElementCommandWheel.init = function(self, parent, draw_layer, start_scale)
    HudElementCommandWheel.super.init(self, parent, draw_layer, start_scale, Definitions)
    
    -- ... существующий код ...
    
    -- Добавляем состояние страницы
    self._current_page = 1
    self._max_pages = 3
    self._page_configs = PAGE_CONFIGS
end
```

### 3. Модификация функции генерации опций

```lua
local function generate_options_from_config(wheel_config, current_page)
    local options = {}
    local page_config = PAGE_CONFIGS["page_" .. current_page]
    
    if not page_config then
        page_config = PAGE_CONFIGS["page_1"]
    end
    
    -- Добавляем кнопку переключения страниц в первый слот
    options[1] = {
        id = "switch_page",
        label_key = "loc_page_" .. current_page,
        icon = "content/ui/materials/icons/system/page_switch",
        action = "switch_page",
        page_number = current_page,
    }
    
    -- Заполняем остальные слоты командами текущей страницы
    local commands = page_config.commands
    for i = 1, #commands do
        local command_id = commands[i]
        if button_definitions_by_id[command_id] then
            options[i + 1] = button_definitions_by_id[command_id]
        end
    end
    
    return options
end
```

### 4. Обработка переключения страниц

```lua
local function switch_page(self, direction)
    direction = direction or 1  -- 1 = следующая, -1 = предыдущая
    
    self._current_page = self._current_page + direction
    
    -- Циклическое переключение
    if self._current_page > self._max_pages then
        self._current_page = 1
    elseif self._current_page < 1 then
        self._current_page = self._max_pages
    end
    
    -- Обновляем колесо с новыми командами
    local options = generate_options_from_config(self._wheel_config, self._current_page)
    self:_populate_wheel(options)
    
    -- Звуковой эффект переключения
    if UISoundEvents.emote_wheel_open then
        Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
    end
end
```

### 5. Модификация обработки ввода

```lua
HudElementCommandWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
    -- ... существующий код ...
    
    if not right_mouse_held and input_service and type(input_service.has) == "function" then
        local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
        
        if hovered_entry and input_service:has("left_pressed") and input_service:get("left_pressed") then
            local option = hovered_entry.option
            
            -- Проверяем, является ли это кнопкой переключения страниц
            if option and option.action == "switch_page" then
                self:switch_page(1)  -- Переключаем на следующую страницу
                return  -- Не закрываем колесо
            end
            
            -- Обычная обработка команды
            if activate_option(option) then
                self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
            end
        end
    end
    
    -- Добавляем горячую клавишу для переключения страниц (опционально)
    if input_service:has("page_next") and input_service:get("page_next") then
        self:switch_page(1)
    elseif input_service:has("page_prev") and input_service:get("page_prev") then
        self:switch_page(-1)
    end
end
```

### 6. Визуальная индикация текущей страницы

```lua
HudElementCommandWheel._update_wheel_presentation = function(self, dt, t, ui_renderer, render_settings, input_service)
    -- ... существующий код ...
    
    -- Добавляем отображение номера страницы
    local wheel_background_widget = self._wheel_background_widget
    if wheel_background_widget then
        local page_config = self._page_configs["page_" .. self._current_page]
        if page_config then
            wheel_background_widget.content.page_text = string.format("%d/%d", self._current_page, self._max_pages)
            wheel_background_widget.content.page_name = page_config.name
        end
    end
end
```

## Альтернативный подход: Центральная кнопка

Вместо использования одного из слотов, можно добавить отдельную центральную кнопку для переключения страниц:

```lua
-- В Definitions добавляем виджет для центральной кнопки
local center_button_definition = UIWidget.create_definition({
    {
        pass_type = "texture",
        value_id = "icon",
        value = "content/ui/materials/icons/system/page_switch",
        style_id = "icon",
        style = {
            -- стили для иконки
        },
    },
    {
        pass_type = "text",
        value_id = "text",
        value = "1/3",
        style_id = "text",
        style = {
            -- стили для текста
        },
    },
}, "center_pivot")

-- В HudElementCommandWheel добавляем обработку клика по центру
local function _is_center_button_hovered(self, input_service)
    if not input_service then
        return false
    end
    
    local cursor = input_service:get("cursor")
    if not cursor then
        return false
    end
    
    local center_widget = self._center_button_widget
    if not center_widget then
        return false
    end
    
    -- Проверяем, находится ли курсор в области центральной кнопки
    local scenegraph_id = center_widget.scenegraph_id
    local position = self:_scenegraph_position(scenegraph_id)
    local size = self:_scenegraph_size(scenegraph_id)
    
    local center_x = position[1]
    local center_y = position[2]
    local radius = size[1] / 2
    
    local dx = cursor[1] - center_x
    local dy = cursor[2] - center_y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    return distance <= radius
end
```

## Пример полной реализации

### Структура файлов

```
YourModName/
├── YourModName.mod
└── scripts/
    └── mods/
        └── YourModName/
            ├── YourModName.lua
            ├── YourModName_data.lua
            ├── YourModName_localization.lua
            ├── YourModName_settings.lua
            ├── YourModName_definitions.lua
            ├── YourModName_buttons.lua
            ├── YourModName_pages.lua      # НОВЫЙ: Конфигурация страниц
            ├── YourModName_utils.lua
            └── HudElementCommandWheel.lua
```

### YourModName_pages.lua

```lua
local button_definitions_by_id = require("YourModName/scripts/mods/YourModName/YourModName_buttons").button_definitions_by_id

local PAGE_CONFIGS = {
    page_1 = {
        id = "page_1",
        name_key = "loc_page_basic_commands",
        commands = {
            "yes",
            "no",
            "thanks",
            "wait",
            "help",
            "follow_me",
            "take_this",
            "i_need_this",
        }
    },
    page_2 = {
        id = "page_2",
        name_key = "loc_page_tactical_commands",
        commands = {
            "forward",
            "retreat",
            "hold",
            "group_up",
            "medkit_here",
            "ammo_here",
            "grenade_here",
            "plasma_here",
        }
    },
    page_3 = {
        id = "page_3",
        name_key = "loc_page_enemies",
        commands = {
            "sniper",
            "flamer",
            "bomber",
            "mutant",
            "ogryn",
            "boss",
            "elite",
            "daemonhost",
        }
    }
}

local function get_page_config(page_number)
    return PAGE_CONFIGS["page_" .. page_number] or PAGE_CONFIGS["page_1"]
end

local function get_max_pages()
    local count = 0
    for _ in pairs(PAGE_CONFIGS) do
        count = count + 1
    end
    return count
end

return {
    PAGE_CONFIGS = PAGE_CONFIGS,
    get_page_config = get_page_config,
    get_max_pages = get_max_pages,
}
```

### Модификация HudElementCommandWheel.lua

```lua
local Pages = require("YourModName/scripts/mods/YourModName/YourModName_pages")

local HudElementCommandWheel = class("HudElementCommandWheel", "HudElementBase")

HudElementCommandWheel.init = function(self, parent, draw_layer, start_scale)
    HudElementCommandWheel.super.init(self, parent, draw_layer, start_scale, Definitions)
    
    -- ... существующий код ...
    
    -- Инициализация страниц
    self._current_page = 1
    self._max_pages = Pages.get_max_pages()
    self._page_configs = Pages.PAGE_CONFIGS
end

local function generate_options_from_page(current_page)
    local options = {}
    local page_config = Pages.get_page_config(current_page)
    
    if not page_config then
        return options
    end
    
    -- Первый слот - кнопка переключения страниц
    options[1] = {
        id = "switch_page",
        label_key = "loc_page_switch",
        icon = "content/ui/materials/icons/system/page_switch",
        action = "switch_page",
        page_number = current_page,
        page_name_key = page_config.name_key,
    }
    
    -- Остальные слоты - команды страницы
    local commands = page_config.commands
    for i = 1, math.min(#commands, CommandWheelSettings.wheel_slots - 1) do
        local command_id = commands[i]
        if button_definitions_by_id[command_id] then
            options[i + 1] = button_definitions_by_id[command_id]
        end
    end
    
    return options
end

HudElementCommandWheel.switch_page = function(self, direction)
    direction = direction or 1
    
    self._current_page = self._current_page + direction
    
    if self._current_page > self._max_pages then
        self._current_page = 1
    elseif self._current_page < 1 then
        self._current_page = self._max_pages
    end
    
    local options = generate_options_from_page(self._current_page)
    self:_populate_wheel(options)
    
    if UISoundEvents.emote_wheel_open then
        Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
    end
end

HudElementCommandWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
    -- ... существующий код до обработки клика ...
    
    if not right_mouse_held and input_service and type(input_service.has) == "function" then
        local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
        
        if hovered_entry and input_service:has("left_pressed") and input_service:get("left_pressed") then
            local option = hovered_entry.option
            
            -- Переключение страниц
            if option and option.action == "switch_page" then
                self:switch_page(1)
                return  -- Не закрываем колесо
            end
            
            -- Обычная команда
            if activate_option(option) then
                self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
            end
        end
    end
end
```

## Локализация

```lua
-- YourModName_localization.lua
return {
    loc_page_basic_commands = {
        en = "Basic Commands",
        ru = "Основные команды",
    },
    loc_page_tactical_commands = {
        en = "Tactical Commands",
        ru = "Тактические команды",
    },
    loc_page_enemies = {
        en = "Enemies",
        ru = "Враги",
    },
    loc_page_switch = {
        en = "Switch Page",
        ru = "Следующая страница",
    },
}
```

## Преимущества подхода

1. **Масштабируемость** - легко добавить больше страниц
2. **Гибкость** - можно настроить команды для каждой страницы
3. **Удобство** - не нужно закрывать колесо для переключения
4. **Визуальная обратная связь** - можно показать номер страницы

## Дополнительные улучшения

### Анимация переключения

```lua
HudElementCommandWheel.switch_page = function(self, direction)
    -- ... код переключения ...
    
    -- Анимация переключения
    self._page_switch_animation = {
        progress = 0,
        duration = 0.2,
        start_time = t,
    }
end
```

### Сохранение выбранной страницы

```lua
-- При открытии колеса
local saved_page = mod:get("last_page") or 1
self._current_page = saved_page

-- При переключении
mod:set("last_page", self._current_page)
```

### Горячие клавиши

```lua
-- В YourModName_data.lua добавить настройки для клавиш переключения
{
    keybind = "page_next",
    setting_id = "page_next_keybind",
    title = "loc_page_next_keybind",
    keybind_trigger = "pressed",
},
```

## Заключение

Реализация многостраничного колеса команд позволяет значительно расширить количество доступных команд без перегрузки интерфейса. Основные шаги:

1. Создать конфигурацию страниц
2. Добавить состояние текущей страницы
3. Модифицировать генерацию опций
4. Добавить обработку переключения страниц
5. Добавить визуальную индикацию

