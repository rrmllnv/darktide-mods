# Communication Command Wheel

Мод для **Warhammer 40,000: Darktide**: радиальное колесо тактических фраз в миссии. Удерживаемая клавиша открывает колесо; выбор команды отправляет текст в **чат миссии** и при поддержке игрой воспроизводит **VO** персонажа.

**Код мода:** `darktide-mods/CommunicationCommandWheel/`

## Зависимости

- [Darktide Mod Framework (DMF)](https://github.com/danreeves/dt-mod-framework)

## Настройки

- Клавиша открытия, задержка удержания до появления колеса.
- До **3 страниц** по **8 слотов** — выпадающий список команд на слот (пустой слот = пустой сектор).
- Группа **«Настройки»**: сброс раскладки слотов к встроенным значениям по умолчанию (клавиша и задержка не меняются).

## Группы команд по смыслу

Ниже — **логическая** классификация встроенных `id` команд из `CommunicationCommandWheel_buttons.lua`. Это не границы страниц в mod options: дефолтная раскладка по страницам может смешивать группы (например, страница 1 объединяет ответы, помощь и угрозу).

| Группа | Команды (`id`) | Замечание |
|--------|----------------|-----------|
| Ответы / вежливость | `yes`, `no`, `please`, `sorry` | У `sorry` нет `voice_event_data` в определении — только чат. |
| Помощь / обмен | `need_help`, `take_this`, `i_need_this` | `need_help`: `generic_mission_vo` + `calling_for_help`. |
| Угроза | `daemonhost` | VO: `on_demand_vo_tag_enemy`, тег врага `chaos_daemonhost`. |
| Движение / связь | `follow_you`, `follow_me`, `cover_me`, `coming_to_you`, `waiting_for_you`, `dont_fall_behind`, `faster`, `wait`, `hold_position` | У многих только чат, без `voice_event_data`. `hold_position` — приказ удерживать точку; отдельного VO в ванили нет. |
| Статус позиции | `almost_there`, `away_from_squad` | `generic_mission_vo`. |
| Навигация | `back` | Только чат. |

### Связь с дефолтными страницами (`CommunicationCommandWheel_pages.lua`)

| Страница | Слоты (по умолчанию) | Примечание |
|----------|------------------------|------------|
| 1 | `yes`, `please`, `sorry`, `need_help`, `no`, `take_this`, `i_need_this`, `daemonhost` | Смешение групп «ответы», «помощь», «угроза». |
| 2 | `follow_you` … `wait` (8 слотов) | Группа «движение / связь»; страница заполнена. |
| 3 | `almost_there`, `away_from_squad`, `back`, `hold_position` + пустые слоты | «Статус» + «навигация» + `hold_position` (логически движение; на стр. 3 из‑за нехватки места на стр. 2). |

## Технические файлы (кратко)

| Файл | Назначение |
|------|------------|
| `CommunicationCommandWheel.lua` | Регистрация мода, хуки HUD, смена настроек, миграция слотов страницы 3. |
| `CommunicationCommandWheel_data.lua` | Виджеты DMF (mod options). |
| `CommunicationCommandWheel_buttons.lua` | Каталог команд: `id`, иконка, `label_key`, VO, чат. |
| `CommunicationCommandWheel_setting_dropdown_options.lua` | Список опций для выпадающих списков слотов. |
| `CommunicationCommandWheel_pages.lua` | `MAX_PAGES`, `CONFIGURED_SLOT_COUNT`, `DEFAULT_SLOT_LAYOUT`. |
| `CommunicationCommandWheel_localization.lua` | Строки; ключи команд — `ccw_command_*`. |
| `HudElementCommunicationCommandWheel.lua` | HUD-элемент колеса. |
| `CommunicationCommandWheel_definitions.lua` | Виджеты и scenegraph. |

## Локализация и глобальные строки

Ключи **`ccw_command_*`** дополнительно регистрируются в глобальную таблицу локализации игры (см. `CommunicationCommandWheel.lua`), чтобы `Localize()` находил те же строки, что и `mod:localize()`.

Префикс **`ccw`** = **C**ommunication **C**ommand **W**heel.
