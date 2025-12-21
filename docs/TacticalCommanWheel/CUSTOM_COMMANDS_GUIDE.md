# Руководство по добавлению кастомных команд в колесо коммуникации

## Возможности добавления команд

### ✅ Вариант 1: Команды только с текстом в чат (БЕЗ голоса)

**Самый простой способ** - добавить команду, которая отправляет только текст в чат, без голосовой реплики.

**Пример:**

```lua
[WHEEL_OPTION.my_custom_command] = {
    display_name = "loc_my_custom_command",  -- Ключ локализации
    icon = "content/ui/materials/icons/list_buttons/check",  -- Иконка
    chat_message_data = {
        text = "loc_my_custom_message",  -- Текст для чата
        channel = ChannelTags.MISSION,
    },
    -- НЕТ voice_event_data - значит голоса не будет
},
```

**Как обработать в коде:**

В `custom_entry_actions.lua` добавьте обработку:

```lua
mod:hook_safe(
    "HudElementSmartTagging",
    "_on_com_wheel_stop_callback",
    function(self, t, ui_renderer, render_settings, input_service)
        if self.destroyed then
            return
        end

        local wheel_active = self._wheel_active
        local wheel_hovered_entry = wheel_active and self:_is_wheel_entry_hovered(t)

        if wheel_hovered_entry then
            local option = wheel_hovered_entry.option

            if option.display_name == "loc_my_custom_command" then
                -- Ваша кастомная логика здесь
                mod.send_wheel_message(Localize("loc_my_custom_message"), 5)
                -- Или любая другая логика
            end
        end
    end
)
```

### ✅ Вариант 2: Команды с существующими голосовыми репликами

Используйте существующие голосовые события из `vo_query_constants.lua`:

```lua
[WHEEL_OPTION.follow_you] = {
    display_name = "loc_reply_smart_tag_follow",
    icon = "content/ui/materials/icons/list_buttons/check",
    voice_event_data = {
        voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
        voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_follow_you,
    },
},
```

### ⚠️ Вариант 3: Команды с кастомными голосовыми файлами (СЛОЖНО)

**Требуется:**
1. Голосовые файлы в формате Wwise
2. Добавление их в файлы `dialogues/generated/on_demand_vo_*` для каждого голоса
3. Регистрация в системе диалогов

**Пример из need_help.lua:**

```lua
mod.vo_call_for_help = function(player_needing_help)
    -- Загружаем настройки голоса
    local vo_settings_path = "dialogues/generated/gameplay_vo_" .. player_needing_help._profile.selected_voice
    local vo_settings = require(vo_settings_path)
    
    -- Берем случайный звук из пула
    local vo_sound_events = vo_settings.calling_for_help.sound_events
    local vo_sound_from_pool = vo_sound_events[math.random(#vo_sound_events)]
    local vo_file_path = "wwise/externals/" .. vo_sound_from_pool
    
    -- Воспроизводим через Wwise
    local wwise_world = Managers.world:wwise_world(world)
    wwise_world:trigger_resource_external_event(
        "wwise/events/vo/play_sfx_es_player_vo_2d",
        "es_player_vo_2d",
        vo_file_path,
        4,
        wwise_world:make_auto_source(player_unit, 1)
    )
end
```

**Проблемы:**
- Нужны голосовые файлы для всех голосов персонажей
- Нужно знать структуру файлов dialogues/generated/
- Сложно интегрировать в систему игры

## Практический пример: Добавление команды "Отлично!"

### Шаг 1: Добавить опцию в wheel_options.lua

```lua
local WHEEL_OPTION = table.enum(
    -- ... существующие опции ...
    "excellent"  -- Добавляем новую
)

local wheel_options = {
    -- ... существующие опции ...
    
    [WHEEL_OPTION.excellent] = {
        display_name = "loc_my_excellent_command",
        icon = "content/ui/materials/icons/list_buttons/check",
        chat_message_data = {
            text = "loc_excellent_message",
            channel = ChannelTags.MISSION,
        },
    },
}
```

### Шаг 2: Добавить локализацию в ForTheEmperor_localization.lua

```lua
local localizations = {
    -- ... существующие ...
    loc_my_excellent_command = {
        ["en"] = "Excellent!",
        ["ru"] = "Отлично!",
    },
    loc_excellent_message = {
        ["en"] = "Excellent work!",
        ["ru"] = "Отличная работа!",
    },
}
```

### Шаг 3: Добавить в конфигурацию колеса (ForTheEmperor.lua)

```lua
local wheel_config = mod:get("wheel_config")
    or {
        [1] = WHEEL_OPTION.thanks,
        [2] = WHEEL_OPTION.health,
        [3] = WHEEL_OPTION.emperor,
        [4] = WHEEL_OPTION.yes,
        [5] = WHEEL_OPTION.enemy,
        [6] = WHEEL_OPTION.location,
        [7] = WHEEL_OPTION.attention,
        [8] = WHEEL_OPTION.no,
        [9] = WHEEL_OPTION.help,
        [10] = WHEEL_OPTION.ammo,
        [11] = WHEEL_OPTION.excellent,  -- Добавляем новую команду
    }
```

### Шаг 4: (Опционально) Добавить кастомную логику

Если нужна дополнительная логика (например, маркер, эффект и т.д.):

```lua
-- В custom_entry_actions.lua или отдельном модуле
mod:hook_safe(
    "HudElementSmartTagging",
    "_on_com_wheel_stop_callback",
    function(self, t, ui_renderer, render_settings, input_service)
        if self.destroyed then
            return
        end

        local wheel_active = self._wheel_active
        local wheel_hovered_entry = wheel_active and self:_is_wheel_entry_hovered(t)

        if wheel_hovered_entry then
            local option = wheel_hovered_entry.option

            if option.display_name == "loc_my_excellent_command" then
                -- Ваша кастомная логика
                mod.send_wheel_message(Localize("loc_excellent_message"), 5)
                
                -- Например, добавить маркер
                -- Managers.event:trigger("add_world_marker_unit", ...)
            end
        end
    end
)
```

## Рекомендации

1. **Для начала используйте Вариант 1** (только текст) - это самый простой способ
2. **Для голоса используйте существующие реплики** из `vo_query_constants.lua`
3. **Кастомные голосовые файлы** требуют глубокого понимания системы и наличия файлов

## Структура опции колеса

```lua
{
    display_name = "loc_key",              -- Обязательно: ключ локализации
    icon = "path/to/icon",                 -- Обязательно: путь к иконке
    
    -- Опционально: голосовая реплика
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",
        voice_tag_id = "com_wheel_vo_xxx",  -- Должен существовать в vo_query_constants.lua
    },
    
    -- Опционально: сообщение в чат
    chat_message_data = {
        text = "loc_key",
        channel = ChannelTags.MISSION,
    },
    
    -- Опционально: тип тега для маркировки
    tag_type = "location_ping",
}
```

## Где искать иконки

Иконки находятся в:
- `content/ui/materials/hud/communication_wheel/icons/` - стандартные иконки колеса
- `content/ui/materials/icons/list_buttons/` - кнопки (check, cross и т.д.)
- `content/ui/materials/hud/interactions/icons/` - иконки взаимодействий

## Итог

**Да, можно добавить свои команды!** Самый простой способ - команды с текстом в чат без голоса. Для голоса лучше использовать существующие реплики из игры.

