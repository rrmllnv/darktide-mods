# Полный список всех доступных голосовых реплик для колеса коммуникации

Собрано из исходного кода Darktide (`scripts/settings/dialogue/vo_query_constants.lua`)

## Все доступные голосовые события (com_wheel_vo)

### Используемые в стандартном колесе игры (7 опций):

1. **com_wheel_vo_for_the_emperor** (`com_cheer`)
   - Локализация: `loc_communication_wheel_display_name_cheer`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/for_the_emperor`
   - Описание: "За Императора!"

2. **com_wheel_vo_need_health** (`com_need_health`)
   - Локализация: `loc_communication_wheel_display_name_need_health`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/health`
   - Чат: `loc_communication_wheel_need_health`
   - Описание: "Нужно здоровье"

3. **com_wheel_vo_thank_you** (`com_thank_you`)
   - Локализация: `loc_communication_wheel_display_name_thanks`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/thanks`
   - Чат: `loc_communication_wheel_thanks`
   - Описание: "Спасибо"

4. **com_wheel_vo_need_ammo** (`com_need_ammo`)
   - Локализация: `loc_communication_wheel_display_name_need_ammo`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/ammo`
   - Чат: `loc_communication_wheel_need_ammo`
   - Описание: "Нужны патроны"

5. **com_wheel_vo_enemy_over_here** (`location_enemy_there`)
   - Локализация: `loc_communication_wheel_display_name_enemy`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/enemy`
   - Tag type: `location_threat`
   - Описание: "Враг здесь"

6. **com_wheel_vo_lets_go_this_way** (`location_this_way`)
   - Локализация: `loc_communication_wheel_display_name_location`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/location`
   - Tag type: `location_ping`
   - Описание: "Идем сюда"

7. **com_wheel_vo_over_here** (`location_over_here`)
   - Локализация: `loc_communication_wheel_display_name_attention`
   - Иконка: `content/ui/materials/hud/communication_wheel/icons/attention`
   - Tag type: `location_attention`
   - Описание: "Внимание (сюда)"

### Добавленные в моде ForTheEmperor:

8. **com_wheel_vo_yes** (`answer_yes`)
   - Локализация: `loc_social_menu_confirmation_popup_confirm_button`
   - Иконка: `content/ui/materials/icons/list_buttons/check`
   - Описание: "Да"

9. **com_wheel_vo_no** (`answer_no`)
   - Локализация: `loc_social_menu_confirmation_popup_decline_button`
   - Иконка: `content/ui/materials/icons/list_buttons/cross`
   - Описание: "Нет"

10. **help** (кастомная логика)
    - Локализация: `loc_communication_wheel_need_help`
    - Иконка: `content/ui/materials/hud/interactions/icons/help`
    - Описание: "Нужна помощь" (использует кастомную логику из need_help.lua)

### Доступные, но не используемые в стандартном колесе:

11. **com_wheel_vo_follow_you** (`answer_following`)
    - Используется в smart_tag_settings.lua как reply для тегов
    - Локализация: `loc_reply_smart_tag_follow`
    - Описание: "Следую за тобой"
    - Примечание: Используется как ответ на теги, но может быть добавлен в колесо

12. **com_wheel_vo_my_pleasure** (`com_my_pleasure`)
    - Описание: "Пожалуйста" (ответ на спасибо)
    - Примечание: Нужно найти правильную локализацию и иконку

13. **com_wheel_vo_need_that** (`answer_need`)
    - Используется в smart_tag_settings.lua как reply "dibs"
    - Локализация: `loc_reply_smart_tag_dibs`
    - Описание: "Мне это нужно" (dibs)
    - Примечание: Используется как ответ на теги предметов

14. **com_wheel_vo_take_this** (`com_take_this`)
    - Описание: "Возьми это"
    - Примечание: Нужно найти правильную локализацию и иконку

## Структура опции колеса

Каждая опция может содержать:

```lua
{
    display_name = "loc_key",              -- Ключ локализации для отображения
    icon = "path/to/icon",                 -- Путь к иконке
    tag_type = "location_ping",            -- Опционально: тип тега для маркировки
    voice_event_data = {
        voice_tag_concept = "on_demand_com_wheel",
        voice_tag_id = "com_wheel_vo_xxx",
    },
    chat_message_data = {                  -- Опционально: сообщение в чат
        text = "loc_key",
        channel = ChannelTags.MISSION,
    },
}
```

## Использование в коде

Все голосовые события определены в:
- `scripts/settings/dialogue/vo_query_constants.lua`

Стандартное колесо определено в:
- `scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging.lua`

Настройки тегов (где используются некоторые из этих реплик как ответы):
- `scripts/settings/smart_tag/smart_tag_settings.lua`

## Примечания

- Все голосовые события используют концепт `on_demand_com_wheel`
- Некоторые реплики используются только как ответы на теги (replies), но могут быть добавлены в колесо
- Для новых опций нужно найти подходящие иконки и локализационные ключи
- Мод ForTheEmperor добавляет 3 новые опции: yes, no, help

