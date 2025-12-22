# Руководство по добавлению команд в собственное колесо коммуникации

Это руководство для создания **собственного колеса коммуникации** (как `MourningstarCommandWheel`), а не для модификации стандартного колеса игры.

## Структура команды

Каждая команда в вашем колесе определяется в файле `YourModName_buttons.lua`:

```lua
{
    id = "unique_command_id",        -- Уникальный идентификатор
    label_key = "loc_key",            -- Ключ локализации для отображения
    icon = "path/to/icon",            -- Путь к иконке
    
    -- Опционально: голосовая реплика
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",  -- или "generic_mission_vo"
        voice_tag_id = "com_wheel_vo_xxx",          -- ID голосового события
    },
    
    -- Опционально: сообщение в чат
    chat_message_data = {
        text = "loc_key",
        channel = "mission",  -- или другой канал
    },
    
    -- Опционально: кастомное действие
    action = function(option)
        -- Ваша кастомная логика
        return true
    end,
}
```

## Варианты добавления команд

### ✅ Вариант 1: Команды только с текстом в чат (БЕЗ голоса)

**Самый простой способ** - команда отправляет только текст в чат.

**Пример:**

```lua
{
    id = "excellent",
    label_key = "loc_excellent",
    icon = "content/ui/materials/icons/list_buttons/check",
    chat_message_data = {
        text = "loc_excellent_message",
        channel = "mission",
    },
    -- НЕТ voice_event_data - значит голоса не будет
}
```

**Обработка в HudElementCommandWheel.lua:**

В функции активации команды добавьте:

```lua
local function activate_option(option)
    if not option then
        return false
    end

    -- Обработка голосового события
    if option.voice_event_data then
        local player_unit = Managers.player:local_player_safe(1).player_unit
        if player_unit then
            local Vo = require("scripts/utilities/vo")
            Vo.on_demand_vo_event(
                player_unit,
                option.voice_event_data.voice_tag_concept,
                option.voice_event_data.voice_tag_id
            )
        end
    end

    -- Обработка сообщения в чат
    if option.chat_message_data then
        local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
        local ChannelTags = ChatManagerConstants.ChannelTag
        local channel_tag = option.chat_message_data.channel
        
        local channels = Managers.chat:connected_chat_channels()
        if channels then
            for channel_handle, channel in pairs(channels) do
                if channel.tag == channel_tag then
                    Managers.chat:send_loc_channel_message(
                        channel_handle,
                        option.chat_message_data.text,
                        nil
                    )
                    break
                end
            end
        end
    end

    -- Обработка кастомного действия
    if option.action and type(option.action) == "function" then
        return option.action(option)
    end

    return true
end
```

### ✅ Вариант 2: Команды с существующими голосовыми репликами

Используйте голосовые события из `vo_query_constants.lua`:

```lua
{
    id = "follow_you",
    label_key = "loc_reply_smart_tag_follow",
    icon = "content/ui/materials/icons/list_buttons/check",
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",
        voice_tag_id = "com_wheel_vo_follow_you",
    },
}
```

**Доступные реплики:** См. `ALL_VOICE_OPTIONS.md`

### ✅ Вариант 3: Команды с репликами из gameplay_vo

Используйте контекстные реплики из игры:

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

**Подробнее:** См. `VOICE_REPLICAS_EXPLANATION.md`

### ✅ Вариант 4: Команды с кастомными действиями

Добавьте функцию для выполнения кастомной логики:

```lua
{
    id = "custom_action",
    label_key = "loc_custom_action",
    icon = "content/ui/materials/icons/list_buttons/check",
    action = function(option)
        -- Ваша кастомная логика
        mod:info("Custom action executed!")
        
        -- Например, добавить маркер
        local player_unit = Managers.player:local_player_safe(1).player_unit
        if player_unit then
            Managers.event:trigger(
                "add_world_marker_unit",
                "player_assistance",
                player_unit,
                function(marker_id)
                    mod:info("Marker created: %s", marker_id)
                end
            )
        end
        
        return true
    end,
}
```

## Практический пример: Добавление команды "Отлично!"

### Шаг 1: Добавить команду в YourModName_buttons.lua

```lua
local button_definitions = {
    -- ... существующие команды ...
    
    {
        id = "excellent",
        label_key = "loc_excellent",
        icon = "content/ui/materials/icons/list_buttons/check",
        chat_message_data = {
            text = "loc_excellent_message",
            channel = "mission",
        },
    },
}
```

### Шаг 2: Добавить локализацию в YourModName_localization.lua

```lua
local localizations = {
    -- ... существующие ...
    loc_excellent = {
        ["en"] = "Excellent!",
        ["ru"] = "Отлично!",
    },
    loc_excellent_message = {
        ["en"] = "Excellent work!",
        ["ru"] = "Отличная работа!",
    },
}
```

### Шаг 3: Добавить в конфигурацию колеса

В `HudElementCommandWheel.lua` функция `load_wheel_config()` должна включать новую команду:

```lua
local function load_wheel_config()
    local saved_config = mod:get("wheel_config")
    if saved_config and #saved_config > 0 then
        -- Использовать сохраненную конфигурацию
        return saved_config
    end
    
    -- Конфигурация по умолчанию
    local default_config = {
        "thanks",
        "yes",
        "no",
        "excellent",  -- Добавляем новую команду
        -- ... другие команды ...
    }
    return default_config
end
```

## Расширенные примеры

### Команда с голосом и чатом

```lua
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
}
```

### Команда с тегом местоположения

```lua
{
    id = "enemy",
    label_key = "loc_communication_wheel_display_name_enemy",
    icon = "content/ui/materials/hud/communication_wheel/icons/enemy",
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",
        voice_tag_id = "com_wheel_vo_enemy_over_here",
    },
    tag_type = "location_threat",  -- Создаст тег на местоположении
}
```

**Обработка тегов в activate_option:**

```lua
if option.tag_type then
    local player_unit = Managers.player:local_player_safe(1).player_unit
    if player_unit then
        -- Получить позицию под курсором
        local smart_targeting_extension = ScriptUnit.extension(player_unit, "smart_targeting_system")
        smart_targeting_extension:force_update_smart_tag_targets()
        local targeting_data = smart_targeting_extension:smart_tag_targeting_data()
        
        if targeting_data.static_hit_position then
            local smart_tag_system = Managers.state.extension:system("smart_tag_system")
            smart_tag_system:set_tag(
                option.tag_type,
                player_unit,
                nil,
                Vector3Box.unbox(targeting_data.static_hit_position)
            )
        end
    end
end
```

## Рекомендации

1. **Начните с простых команд** (только текст) - это самый простой способ
2. **Используйте существующие реплики** из `vo_query_constants.lua` для голоса
3. **Тестируйте каждую команду** - не все реплики звучат хорошо вне контекста
4. **Добавляйте локализацию** для всех команд
5. **Используйте подходящие иконки** из игры

## Где искать иконки

Иконки находятся в:
- `content/ui/materials/hud/communication_wheel/icons/` - стандартные иконки колеса
- `content/ui/materials/icons/list_buttons/` - кнопки (check, cross и т.д.)
- `content/ui/materials/hud/interactions/icons/` - иконки взаимодействий
- `content/ui/materials/icons/system/escape/` - системные иконки

## Итог

**Создание собственного колеса дает полный контроль** над командами и их поведением. Вы можете:
- Добавлять любые команды
- Использовать голосовые реплики из игры
- Создавать кастомные действия
- Настраивать внешний вид и поведение

См. `README.md` для общей структуры проекта и `MourningstarCommandWheel` как рабочий пример.
