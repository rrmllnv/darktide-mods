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

Ниже — **логическая** классификация встроенных `id` из `CommunicationCommandWheel_buttons.lua`: в одной строке только то, что по смыслу рядом. Это не границы страниц в mod options.

| Группа | Команды (`id`) | Замечание |
|--------|----------------|-----------|
| Ответы | `yes`, `no`, `please`, `sorry` | Короткие реплики в диалоге; у `sorry` нет VO — только чат. |
| Помощь | `need_help` | Запрос поддержки в бою; VO: `generic_mission_vo` + `calling_for_help`. |
| Предметы | `take_this`, `i_need_this` | Предложить предмет союзнику и попросить у отряда; VO ком-колеса для обеих. |
| Угроза | `daemonhost`, `enemy_ahead`, `dont_shoot_poxbuster` | Предупреждение отряду: демонхост (VO `on_demand_vo_tag_enemy` + `chaos_daemonhost`), враг в секторе (VO ком-колеса), не стрелять во взрывоопасную цель (`dont_shoot_poxbuster` — только чат). |
| Навигация | `follow_you`, `follow_me`, `cover_me`, `coming_to_you`, `waiting_for_you`, `dont_fall_behind`, `faster`, `wait`, `back` | Куда идти, кого ждать, прикрытие, ускориться / стоп, направление «назад»; у `back` и части остальных — только чат, без VO. |
| Защита | `hold_position`, `hold_exit` | Удержание занятой точки и удержание выхода (в т.ч. экстракт, экспедиции); только чат, VO нет. |
| Отряд | `dont_split_up`, `almost_there`, `away_from_squad` | Связность («не расползаться»), статус «почти на месте» и «оторван от отряда»; у `almost_there` и `away_from_squad` — `generic_mission_vo`, `dont_split_up` — только чат. |

### Связь с дефолтными страницами (`CommunicationCommandWheel_pages.lua`)

| Страница | Слоты (по умолчанию) | Примечание |
|----------|------------------------|------------|
| 1 | `yes`, `please`, `sorry`, `need_help`, `no`, `take_this`, `i_need_this`, `daemonhost` | Смешение «ответы», «помощь», «предметы», «угроза». |
| 2 | `follow_you` … `wait` (8 слотов) | Вся страница — «навигация» (без `back`); слоты заполнены. |
| 3 | `almost_there`, `away_from_squad`, `back`, `hold_position`, `enemy_ahead`, `hold_exit`, `dont_split_up`, `dont_shoot_poxbuster` | Смешение «отряд», «навигация» (`back`), «защита», «угроза». |

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

## Переводы команд (к разделу «Группы команд по смыслу»)

Тексты как в `CommunicationCommandWheel_localization.lua` (`en` / `ru`). В **чат миссии** по сети уходит **английская** строка (`en`); `ru` — для интерфейса колеса при выбранном русском языке.

| `id` | English (`en`) | Русский (`ru`) |
|------|----------------|----------------|
| `yes` | Yes | Да |
| `no` | No | Нет |
| `please` | Please | Пожалуйста |
| `sorry` | Sorry | Извини |
| `need_help` | Need Help | Нужна помощь |
| `take_this` | Take This | Возьми это |
| `i_need_this` | I Need This | Мне это нужно |
| `daemonhost` | Attention, Daemonhost | Внимание, Демонхост |
| `enemy_ahead` | Enemy ahead | Враг впереди |
| `dont_shoot_poxbuster` | Don't shoot the Poxburster | Не стреляй по poxbuster |
| `follow_you` | Following You | Следую за тобой |
| `follow_me` | Follow Me | Следуй за мной |
| `cover_me` | Cover Me | Прикрой меня |
| `coming_to_you` | Coming To You | Иду к тебе |
| `waiting_for_you` | Waiting For You | Жду тебя |
| `dont_fall_behind` | Don't Fall Behind | Не отставай |
| `faster` | Faster | Быстрее |
| `wait` | Wait | Ждите |
| `hold_position` | Hold this position | Удерживайте позицию |
| `hold_exit` | Hold the exit | Держим выход |
| `dont_split_up` | Don't split up | Не разбегаемся |
| `almost_there` | Almost There | Почти на месте |
| `away_from_squad` | Away From Squad | Отстал от отряда |
| `back` | Back | Назад |
