# Быстрый старт: Создание собственного колеса коммуникации

## Что это?

Это руководство поможет вам создать **собственное колесо коммуникации** для Warhammer 40,000: Darktide, аналогичное `MourningstarCommandWheel`, но для голосовых команд и коммуникации.

## Структура документации

1. **README.md** - Общая структура проекта и основные компоненты
2. **CUSTOM_COMMANDS_GUIDE.md** - Подробное руководство по добавлению команд
3. **ALL_VOICE_OPTIONS.md** - Полный список всех доступных голосовых реплик
4. **VOICE_REPLICAS_EXPLANATION.md** - Объяснение использования разных типов реплик
5. **wheel_options_all.lua** - Пример файла со всеми доступными опциями

## Быстрый старт

### 1. Изучите пример

Посмотрите на `MourningstarCommandWheel` - это полный рабочий пример создания собственного колеса.

### 2. Создайте структуру проекта

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
            ├── YourModName_utils.lua
            └── HudElementCommandWheel.lua
```

### 3. Добавьте первую команду

В `YourModName_buttons.lua`:

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
}
```

### 4. Обработайте активацию

В `HudElementCommandWheel.lua` добавьте функцию `activate_option()` для обработки команд.

## Основные концепции

### Типы реплик

1. **on_demand_com_wheel** - Реплики специально для колеса (14 доступных)
2. **generic_mission_vo** - Контекстные реплики из gameplay_vo (много доступных)
3. **on_demand_vo_tag_item** - Реплики для тегов предметов

### Структура команды

```lua
{
    id = "unique_id",           -- Обязательно
    label_key = "loc_key",      -- Обязательно
    icon = "path/to/icon",      -- Обязательно
    voice_event_data = { ... }, -- Опционально
    chat_message_data = { ... }, -- Опционально
    action = function() { ... } -- Опционально
}
```

## Следующие шаги

1. Прочитайте **README.md** для понимания структуры
2. Изучите **CUSTOM_COMMANDS_GUIDE.md** для добавления команд
3. Используйте **ALL_VOICE_OPTIONS.md** для выбора реплик
4. Смотрите **VOICE_REPLICAS_EXPLANATION.md** для понимания типов реплик

## Полезные ссылки

- Пример мода: `darktide-mods/MourningstarCommandWheel/`
- Исходный код: `Darktide-Source-Code/scripts/ui/hud/elements/smart_tagging/`
- Голосовые константы: `Darktide-Source-Code/scripts/settings/dialogue/vo_query_constants.lua`

