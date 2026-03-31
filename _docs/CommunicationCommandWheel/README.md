# Communication Command Wheel

Мод для **Warhammer 40,000: Darktide**: радиальное колесо тактических фраз в миссии. Удерживаемая клавиша открывает колесо; выбор команды отправляет текст в **чат миссии** и при поддержке игрой воспроизводит **VO** персонажа.

**Код мода:** `darktide-mods/CommunicationCommandWheel/`

## Зависимости

- [Darktide Mod Framework (DMF)](https://github.com/danreeves/dt-mod-framework)

## Настройки

- Клавиша открытия, задержка удержания до появления колеса.
- Группа **«Переключение страниц»**: горячая клавиша следующей страницы; чекбокс **колёсико** (при нескольких страницах — `Managers.ui:add_inputs_in_use_by_ui` для Ingame `wield_scroll_*`, смена оружия колёсиком заблокирована); чекбокс **клик по центру** (`ccw_center_click_switch_page`, по умолчанию вкл.) — ЛКМ / confirm в центре переключает страницу; выкл. — без переключения по центру.
- До **3 страниц** по **8 слотов** — выпадающий список команд на слот (пустой слот = пустой сектор).
- Группа **«Настройки»**: сброс раскладки слотов к встроенным значениям по умолчанию (клавиша и задержка не меняются).

## Группы команд по смыслу

Ниже — **логическая** классификация встроенных `id` команд из `CommunicationCommandWheel_buttons.lua`. Это не границы страниц в mod options: дефолтная раскладка по страницам может смешивать группы (например, страница 1 объединяет ответы, помощь и угрозу).

| Группа | Команды (`id`) | Замечание |
|--------|----------------|-----------|
| Ответы / вежливость | `yes`, `no`, `please`, `sorry` | У `sorry` нет `voice_event_data` в определении — только чат. |
| Помощь / обмен | `need_help`, `take_this`, `i_need_this` | `need_help`: `generic_mission_vo` + `calling_for_help`. |
| Угроза | `daemonhost`, `enemy_ahead`, `dont_shoot_poxbuster` | `daemonhost`: `on_demand_vo_tag_enemy`, `chaos_daemonhost`. `enemy_ahead`: чат «Враг впереди»; VO ванильного пинга угрозы — `on_demand_com_wheel` + `com_wheel_vo_enemy_over_here`. `dont_shoot_poxbuster` — только чат (поксбастер / Poxburster). |
| Движение и темп | `follow_you`, `follow_me`, `cover_me`, `coming_to_you`, `waiting_for_you`, `dont_fall_behind`, `faster`, `wait` | В основном про относительное движение и скорость; у многих только чат, без `voice_event_data`. |
| Удержание и состав отряда | `hold_position`, `hold_exit`, `dont_split_up` | Тактика точки/выхода и «не расползаться» (в т.ч. экспедиции, экстракт); только чат, VO нет. |
| Статус позиции | `almost_there`, `away_from_squad` | `generic_mission_vo`. |
| Навигация | `back` | Только чат. |

### Связь с дефолтными страницами (`CommunicationCommandWheel_pages.lua`)

| Страница | Слоты (по умолчанию) | Примечание |
|----------|------------------------|------------|
| 1 | `yes`, `please`, `sorry`, `need_help`, `no`, `take_this`, `i_need_this`, `daemonhost` | Смешение групп «ответы», «помощь», «угроза». |
| 2 | `follow_you` … `wait` (8 слотов) | Только «движение и темп»; страница заполнена. |
| 3 | `almost_there`, `away_from_squad`, `back`, `hold_position`, `enemy_ahead`, `hold_exit`, `dont_split_up`, `dont_shoot_poxbuster` | Смешение статуса, навигации, удержания/состава отряда и угрозы. |

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
