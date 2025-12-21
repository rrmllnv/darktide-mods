# Использование текста вместо иконок в собственном колесе команд

**Да, можно использовать текст вместо иконок!** В `MourningstarCommandWheel` уже есть поддержка текста.

## Как это работает

В определении виджета (`YourModName_definitions.lua`) уже есть два элемента:
1. **Иконка** (`pass_type = "texture"`) - отображает иконку
2. **Текст** (`pass_type = "text"`) - отображает текст команды

## Вариант 1: Показывать только текст (скрыть иконку)

### Шаг 1: Модифицируйте определение виджета

В `YourModName_definitions.lua` измените определение `entry_widget_definition`:

```lua
local entry_widget_definition = UIWidget.create_definition({
    {
        content_id = "hotspot",
        pass_type = "hotspot",
        content = default_button_content,
    },
    -- ИКОНКА - СКРЫТА (visibility_function возвращает false)
    {
        pass_type = "texture",
        value_id = "icon",
        value = "content/ui/materials/base/ui_default_base",
        style_id = "icon",
        style = {
            horizontal_alignment = "center",
            vertical_alignment = "center",
            size = {
                CommandWheelSettings.icon_size,
                CommandWheelSettings.icon_size,
            },
            offset = {
                0,
                0,
                100,
            },
            color = get_hud_color("color_tint_main_2", 255),
        },
        visibility_function = function (content, style)
            return false  -- Скрыть иконку
        end,
    },
    -- ... остальные элементы (slice_line, slice_highlight, slice) ...
    
    -- ТЕКСТ - ВИДИМЫЙ
    {
        pass_type = "text",
        value_id = "text",
        value = "",
        style_id = "text",
        style = {
            text_horizontal_alignment = "center",
            text_vertical_alignment = "center",
            offset = {
                0,
                0,
                200,  -- Увеличьте z-index, чтобы текст был поверх всего
            },
            font_type = simple_button_font_settings.font_type,
            font_size = 20,  -- Увеличьте размер шрифта для лучшей читаемости
            text_color = simple_button_font_color,
            default_text_color = simple_button_font_color,
        },
        change_function = function (content, style)
            local default_text_color = style.default_text_color
            local text_color = style.text_color
            local hotspot = content.hotspot
            local anim_hover_progress = hotspot.anim_hover_progress
            
            -- Изменение цвета при hover
            local hover_text_color = {255, 255, 255, 255}  -- Белый при hover
            ColorUtilities.color_lerp(default_text_color, hover_text_color, anim_hover_progress, text_color, false)
        end,
    },
}, "pivot")
```

### Шаг 2: Убедитесь, что текст устанавливается

В `HudElementCommandWheel.lua` функция `_populate_wheel` уже устанавливает текст:

```lua
HudElementCommandWheel._populate_wheel = function(self, options)
    local entries = self._entries
    
    for i = 1, #entries do
        local entry = entries[i]
        local widget = entry.widget
        local content = widget.content
        local option = options[i]
        
        if option then
            entry.option = option
            content.visible = true
            content.icon = option.icon or "content/ui/materials/base/ui_default_base"
            content.text = localize_text(option.label_key)  -- Текст уже устанавливается!
        else
            entry.option = nil
            content.visible = false
        end
    end
end
```

### Шаг 3: Настройте размер текста

В `YourModName_settings.lua` можно добавить настройки для текста:

```lua
local command_wheel_settings = {
    -- ... существующие настройки ...
    text_font_size = 20,  -- Размер шрифта текста
    text_max_width = 100,  -- Максимальная ширина текста (для переноса)
}
```

## Вариант 2: Показывать и текст, и иконку

Оставьте оба элемента видимыми, но измените позиционирование:

```lua
{
    pass_type = "texture",
    value_id = "icon",
    -- ... стиль иконки ...
    style = {
        -- ...
        offset = {
            0,
            -20,  -- Иконка выше
            100,
        },
    },
},
{
    pass_type = "text",
    value_id = "text",
    -- ... стиль текста ...
    style = {
        -- ...
        offset = {
            0,
            20,  -- Текст ниже иконки
            200,
        },
        font_size = 14,  -- Меньший размер для текста под иконкой
    },
},
```

## Вариант 3: Только текст с увеличенным размером

Для лучшей читаемости увеличьте размер текста и скройте иконку:

```lua
{
    pass_type = "text",
    value_id = "text",
    value = "",
    style_id = "text",
    style = {
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        offset = {
            0,
            0,
            200,
        },
        font_type = simple_button_font_settings.font_type,
        font_size = 24,  -- Большой размер для читаемости
        text_color = simple_button_font_color,
        default_text_color = simple_button_font_color,
        size = {
            120,  -- Ширина области текста
            40,   -- Высота области текста
        },
    },
    change_function = function (content, style)
        local default_text_color = style.default_text_color
        local text_color = style.text_color
        local hotspot = content.hotspot
        local anim_hover_progress = hotspot.anim_hover_progress
        
        -- Ярче при hover
        local hover_text_color = {255, 255, 255, 255}
        ColorUtilities.color_lerp(default_text_color, hover_text_color, anim_hover_progress, text_color, false)
        
        -- Немного увеличить размер при hover
        local base_size = 24
        local hover_size = 28
        style.font_size = base_size + (hover_size - base_size) * anim_hover_progress
    end,
},
```

## Пример: Команда без иконки

В `YourModName_buttons.lua` можно вообще не указывать иконку:

```lua
{
    id = "thanks",
    label_key = "loc_communication_wheel_display_name_thanks",
    -- icon не указан - будет использоваться текст
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",
        voice_tag_id = "com_wheel_vo_thank_you",
    },
}
```

И в `_populate_wheel` обработайте отсутствие иконки:

```lua
if option then
    entry.option = option
    content.visible = true
    -- Если иконка не указана, используем пустую или скрываем
    if option.icon then
        content.icon = option.icon
    else
        content.icon = "content/ui/materials/base/ui_default_base"  -- Пустая иконка
    end
    content.text = localize_text(option.label_key)
end
```

## Рекомендации

1. **Размер шрифта:** Используйте 18-24px для хорошей читаемости
2. **Цвет текста:** Используйте яркие цвета (белый, желтый) для контраста
3. **Длина текста:** Ограничьте длину текста (максимум 10-15 символов)
4. **Перенос строк:** Если текст длинный, используйте `\n` для переноса
5. **Hover эффект:** Добавьте изменение цвета/размера при наведении

## Полный пример определения виджета с текстом

```lua
local entry_widget_definition = UIWidget.create_definition({
    -- Hotspot для взаимодействия
    {
        content_id = "hotspot",
        pass_type = "hotspot",
        content = default_button_content,
    },
    
    -- Иконка (скрыта)
    {
        pass_type = "texture",
        value_id = "icon",
        value = "content/ui/materials/base/ui_default_base",
        style_id = "icon",
        style = {
            horizontal_alignment = "center",
            vertical_alignment = "center",
            size = {0, 0},  -- Размер 0, чтобы не занимать место
            offset = {0, 0, 0},
            color = {0, 0, 0, 0},  -- Прозрачная
        },
        visibility_function = function (content, style)
            return false  -- Всегда скрыта
        end,
    },
    
    -- Линия (опционально, можно оставить для визуального разделения)
    {
        pass_type = "rotated_texture",
        value = "content/ui/materials/hud/communication_wheel/slice_eighth_line",
        style_id = "slice_line",
        -- ... стиль линии ...
    },
    
    -- ТЕКСТ КОМАНДЫ
    {
        pass_type = "text",
        value_id = "text",
        value = "",
        style_id = "text",
        style = {
            text_horizontal_alignment = "center",
            text_vertical_alignment = "center",
            offset = {
                0,
                0,
                200,  -- Высокий z-index
            },
            font_type = simple_button_font_settings.font_type,
            font_size = 22,
            text_color = {255, 255, 255, 255},  -- Белый текст
            default_text_color = {200, 200, 200, 255},  -- Серый по умолчанию
            size = {
                150,  -- Ширина области
                50,   -- Высота области
            },
        },
        change_function = function (content, style)
            local default_text_color = style.default_text_color
            local text_color = style.text_color
            local hotspot = content.hotspot
            local anim_hover_progress = hotspot.anim_hover_progress
            
            -- Ярче при hover
            local hover_text_color = {255, 255, 200, 255}  -- Желтоватый при hover
            ColorUtilities.color_lerp(default_text_color, hover_text_color, anim_hover_progress, text_color, false)
            
            -- Немного увеличить размер при hover
            local base_size = 22
            local hover_size = 26
            style.font_size = base_size + (hover_size - base_size) * anim_hover_progress
        end,
    },
}, "pivot")
```

## Итог

**Да, можно использовать текст вместо иконок!** Просто:
1. Скрыть иконку через `visibility_function = function() return false end`
2. Увеличить размер текста в стиле
3. Настроить цвета и эффекты hover для текста

Текст уже поддерживается в `MourningstarCommandWheel`, нужно только настроить отображение.

