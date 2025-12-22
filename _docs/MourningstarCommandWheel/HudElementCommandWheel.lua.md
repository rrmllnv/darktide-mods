# HudElementCommandWheel.lua - Документация

## Описание файла

Основной файл HUD элемента колеса команд. Содержит класс `HudElementCommandWheel`, который наследуется от `HudElementBase` и реализует всю логику отображения и взаимодействия с колесом команд.

## Зависимости

- `HudElementBase` - базовый класс HUD элементов
- `CommandWheelSettings` - настройки колеса (из `MourningstarCommandWheel_settings.lua`)
- `MourningstarCommandWheel_utils` - утилиты (из `MourningstarCommandWheel_utils.lua`)
- `MourningstarCommandWheel_buttons` - определения кнопок (из `MourningstarCommandWheel_buttons.lua`)
- `InputDevice` - работа с устройствами ввода
- `UISoundEvents` - звуковые события
- `UIWidget` - система виджетов
- `RESOLUTION_LOOKUP` - информация о разрешении экрана

## Глобальные переменные

### `HOVER_GRACE_PERIOD`
Период "милосердия" для hover (0.4 секунды). Используется в `_is_wheel_entry_hovered()`.

### `button_definitions`
Массив определений всех доступных кнопок (из `MourningstarCommandWheel_buttons.lua`). Каждая кнопка содержит:
- `id` - уникальный идентификатор
- `view` - имя view для открытия (или `nil` для специальных действий)
- `label_key` - ключ локализации
- `icon` - путь к иконке
- `action` - специальное действие (опционально, для `change_character` и `exit_psychanium`)

### `button_definitions_by_id`
Словарь для быстрого доступа к кнопкам по `id` (из `MourningstarCommandWheel_buttons.lua`).

## Используемые утилиты

Файл использует функции из `MourningstarCommandWheel_utils.lua`:
- `is_in_valid_lvl()` - проверка допустимой локации
- `is_in_psychanium()` - проверка нахождения в псайкинариуме
- `localize_text()` - локализация текста
- `activate_option()` - активация действия/вью
- `apply_style_offset()` - применение смещения к стилю
- `apply_style_color()` - применение цвета к стилю

---

## Вспомогательные функции

---

### `load_wheel_config()`
Загружает порядок кнопок из настроек мода.

**Возвращает:**
- `table` - массив `id` кнопок в порядке отображения

**Логика:**
1. Пытается загрузить сохраненный конфиг из `mod:get("wheel_config")`
2. Проверяет валидность всех `id` (существуют ли в `button_definitions_by_id`)
3. Добавляет недостающие кнопки в конец (кроме `exit_psychanium`)
4. Если сохраненного конфига нет, возвращает порядок по умолчанию (все кнопки кроме `exit_psychanium`)

---

### `save_wheel_config(wheel_config)`
Сохраняет порядок кнопок в настройки мода.

**Параметры:**
- `wheel_config` - массив `id` кнопок

**Логика:**
1. Сохраняет через `mod:set("wheel_config", wheel_config)`
2. Принудительно сохраняет настройки через DMF `save_unsaved_settings_to_file()`

---

### `generate_options_from_config(wheel_config)`
Генерирует опции кнопок из конфига с учетом текущего состояния (в псайкинариуме или нет).

**Параметры:**
- `wheel_config` - массив `id` кнопок

**Возвращает:**
- `table` - массив опций кнопок (может содержать `nil` для скрытых слотов)

**Логика:**
1. Проверяет, находимся ли мы в псайкинариуме
2. Если в псайкинариуме и `id == "training_grounds"`, заменяет на `exit_psychanium`
3. Если не в псайкинариуме и `id == "exit_psychanium"`, скрывает (`options[i] = nil`)
4. Для остальных использует `button_definitions_by_id[id]`

---

## Класс HudElementCommandWheel

### Методы инициализации

#### `HudElementCommandWheel.init(self, parent, draw_layer, start_scale)`
Инициализирует HUD элемент колеса команд.

**Параметры:**
- `parent` - родительский HUD элемент
- `draw_layer` - слой отрисовки
- `start_scale` - начальный масштаб

**Логика:**
1. Вызывает `super.init()` с `Definitions`
2. Инициализирует переменные состояния:
   - `_wheel_active_progress = 0`
   - `_wheel_active = false`
   - `_entries = {}`
   - `_last_widget_hover_data = {index = nil, t = nil}`
   - `_wheel_context = {}`
   - `_close_delay = nil`
3. Загружает конфиг через `load_wheel_config()`
4. Определяет количество слотов (максимум из активных кнопок и `wheel_slots`)
5. Создает entries через `_setup_entries()`
6. Заполняет колесо через `_populate_wheel()`
7. Сохраняет ссылку на фоновый виджет

---

#### `HudElementCommandWheel._setup_entries(self, num_entries)`
Создает entries (слоты) для кнопок.

**Параметры:**
- `num_entries` - количество слотов для создания

**Логика:**
1. Удаляет старые entries (если есть) через `_unregister_widget_name()`
2. Создает новые entries с виджетами через `_create_widget()`
3. Каждый entry содержит:
   - `widget` - виджет кнопки
   - `option` - опция кнопки (устанавливается в `_populate_wheel()`)

---

#### `HudElementCommandWheel._populate_wheel(self, options)`
Заполняет колесо опциями кнопок.

**Параметры:**
- `options` - массив опций кнопок

**Логика:**
1. Для каждого слота:
   - Устанавливает `content.visible = option ~= nil`
   - Сохраняет `option` в `entry.option`
   - Если `option` существует:
     - Устанавливает иконку
     - Устанавливает текст через `localize_text()` (использует `Localize()` для ключей `loc_*`, иначе `mod:localize()`)

---

### Методы обновления

#### `HudElementCommandWheel.update(self, dt, t, ui_renderer, render_settings, input_service)`
Основной метод обновления элемента.

**Параметры:**
- `dt` - время с последнего кадра
- `t` - текущее время
- `ui_renderer` - рендерер UI
- `render_settings` - настройки рендеринга
- `input_service` - сервис ввода

**Логика:**
1. Вызывает `super.update()`
2. Обновляет прогресс анимации через `_update_active_progress()`
3. Обновляет позиции виджетов через `_update_widget_locations()`
4. Если колесо активно, обновляет презентацию через `_update_wheel_presentation()`
5. Обрабатывает ввод через `_handle_input()`

---

#### `HudElementCommandWheel._update_active_progress(self, dt)`
Обновляет прогресс анимации появления/исчезновения колеса.

**Параметры:**
- `dt` - время с последнего кадра

**Логика:**
1. Если `_wheel_active == true`, увеличивает прогресс до 1
2. Если `_wheel_active == false`, уменьшает прогресс до 0
3. Скорость изменения: `anim_speed * dt`
4. Управляет видимостью фонового виджета (`visible = progress > 0`)

---

#### `HudElementCommandWheel._update_widget_locations(self)`
Обновляет позиции всех виджетов кнопок по кругу.

**Логика:**
1. Вычисляет угол для каждой кнопки: `start_angle + (i - 1) * radians_per_widget`
2. Вычисляет радиус с учетом анимации: `min_radius + anim_progress * (max_radius - min_radius)`
3. Вычисляет позицию: `{sin(angle) * radius, cos(angle) * radius}`
4. Устанавливает `content.angle` и `widget.offset`

---

#### `HudElementCommandWheel._update_wheel_presentation(self, dt, t, ui_renderer, render_settings, input_service)`
Обновляет визуальное представление колеса (hover, подсветка, текст).

**Параметры:**
- `dt` - время с последнего кадра
- `t` - текущее время
- `ui_renderer` - рендерер UI
- `render_settings` - настройки рендеринга
- `input_service` - сервис ввода

**Логика:**
1. Получает позицию курсора (мышь или геймпад)
2. Вычисляет расстояние и угол курсора от центра
3. Для каждой кнопки:
   - Проверяет, находится ли курсор в зоне hover (расстояние и угол)
   - Устанавливает `hotspot.force_hover`
4. Обновляет фоновый виджет:
   - Устанавливает угол стрелки
   - Устанавливает текст названия кнопки
   - Воспроизводит звук при начале hover

---

### Методы обработки ввода

#### `HudElementCommandWheel._handle_input(self, t, dt, ui_renderer, render_settings, input_service)`
Обрабатывает весь ввод для колеса.

**Параметры:**
- `t` - текущее время
- `dt` - время с последнего кадра
- `ui_renderer` - рендерер UI
- `render_settings` - настройки рендеринга
- `input_service` - сервис ввода

**Логика:**
1. Обрабатывает задержку закрытия (`_close_delay`)
2. Проверяет, не открыт ли чат (закрывает колесо если да)
3. Проверяет нажатие клавиши открытия:
   - При нажатии: вызывает `_on_wheel_start()`
   - При отпускании: проверяет hover, активирует выбранную кнопку, вызывает `_on_wheel_stop()`
4. Управляет состоянием `_wheel_active`:
   - Открывает колесо через 0.1 секунды после начала удержания
   - Обновляет опции при открытии (для замены `training_grounds` на `exit_psychanium`)
   - Воспроизводит звуки открытия/закрытия
   - Управляет курсором
5. Обрабатывает закрытие по ESC
6. Обрабатывает перетаскивание правой кнопкой мыши
7. Обрабатывает выбор левой кнопкой мыши

**Активация кнопок:**
- Использует функцию `activate_option()` из утилит, которая обрабатывает:
  - `change_character`: вызывает `mod:change_character()`
  - `exit_psychanium`: вызывает `Managers.state.game_mode:complete_game_mode()`
  - Остальные: вызывает `mod:activate_hub_view(option.view)`

---

#### `HudElementCommandWheel._is_wheel_entry_hovered(self, t)`
Проверяет, наведен ли курсор на какую-либо кнопку.

**Параметры:**
- `t` - текущее время

**Возвращает:**
- `entry, index` - entry и индекс наведенной кнопки, или `nil, nil`

**Логика:**
1. Проверяет `hotspot.is_hover` для всех entries
2. Если найдена наведенная кнопка, сохраняет данные и возвращает
3. Если не найдена, проверяет период "милосердия" (`hover_grace_period`)
4. Возвращает последнюю наведенную кнопку, если прошло меньше `hover_grace_period` времени

---

#### `HudElementCommandWheel._on_wheel_start(self, t, input_service)`
Вызывается при начале удержания клавиши открытия колеса.

**Параметры:**
- `t` - текущее время
- `input_service` - сервис ввода

**Логика:**
- Сохраняет время начала в `_wheel_context.input_start_time`

---

#### `HudElementCommandWheel._on_wheel_stop(self, t, ui_renderer, render_settings, input_service)`
Вызывается при отпускании клавиши открытия колеса.

**Параметры:**
- `t` - текущее время
- `ui_renderer` - рендерер UI
- `render_settings` - настройки рендеринга
- `input_service` - сервис ввода

**Логика:**
1. Сбрасывает `input_start_time`
2. Убирает курсор через `_pop_cursor()`
3. Устанавливает `_wheel_active = false`
4. Сбрасывает состояние перетаскивания
5. Воспроизводит звук закрытия (если колесо было активно)

---

### Методы управления курсором

#### `HudElementCommandWheel._push_cursor(self)`
Перемещает курсор в центр экрана.

**Логика:**
1. Получает `Managers.input`
2. Вызывает `push_cursor()` с именем класса
3. Устанавливает позицию курсора в центр (`{0.5, 0.5, 0}`)
4. Устанавливает флаг `_cursor_pushed = true`

---

#### `HudElementCommandWheel._pop_cursor(self)`
Возвращает курсор в исходное положение.

**Логика:**
1. Если `_cursor_pushed == true`:
   - Вызывает `pop_cursor()` с именем класса
   - Устанавливает `_cursor_pushed = false`

---

### Методы визуальной обратной связи

#### `HudElementCommandWheel._update_drag_visual_feedback(self, hovered_index)`
Обновляет визуальную обратную связь при перетаскивании кнопок.

**Параметры:**
- `hovered_index` - индекс кнопки, на которую наведен курсор

**Логика:**
1. Для перетаскиваемой кнопки (`hovered_index`):
   - Применяет смещение по направлению от центра (`drag_offset = 30`) через `apply_style_offset()`
   - Увеличивает яркость цвета через `apply_style_color()`
2. Для остальных кнопок:
   - Сбрасывает смещение через `apply_style_offset()`
   - Приглушает цвет через `apply_style_color()`

---

#### `HudElementCommandWheel._reset_drag_visual_feedback(self)`
Сбрасывает визуальную обратную связь перетаскивания.

**Логика:**
- Сбрасывает смещение всех кнопок через `apply_style_offset(0, 0)`
- Сбрасывает цвета всех кнопок к значениям по умолчанию через `apply_style_color()`

---

### Методы отрисовки

#### `HudElementCommandWheel._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)`
Отрисовывает виджеты колеса.

**Параметры:**
- `dt` - время с последнего кадра
- `t` - текущее время
- `input_service` - сервис ввода
- `ui_renderer` - рендерер UI
- `render_settings` - настройки рендеринга

**Логика:**
1. Если `_wheel_active_progress == 0`, не рисует ничего
2. Устанавливает `render_settings.alpha_multiplier = active_progress` для плавного появления
3. Рисует все entries через `UIWidget.draw()`
4. Обновляет данные последнего hover
5. Вызывает `super._draw_widgets()` для отрисовки фонового виджета

---

### Методы состояния

#### `HudElementCommandWheel.using_input(self)`
Проверяет, использует ли элемент ввод.

**Возвращает:**
- `boolean` - `true` если колесо активно, иначе `false`

---

## Внутренние переменные экземпляра

### `_wheel_active_progress`
Прогресс анимации появления/исчезновения (0.0 - 1.0).

### `_wheel_active`
Флаг активности колеса (`true`/`false`).

### `_entries`
Массив entries (слотов) для кнопок. Каждый entry содержит:
- `widget` - виджет кнопки
- `option` - опция кнопки (определение из `button_definitions`)

### `_last_widget_hover_data`
Данные последнего hover:
- `index` - индекс кнопки
- `t` - время последнего hover

### `_wheel_context`
Контекст колеса:
- `input_start_time` - время начала удержания клавиши

### `_close_delay`
Задержка перед закрытием (для геймпада).

### `_wheel_config`
Конфиг порядка кнопок (массив `id`).

### `_wheel_background_widget`
Ссылка на фоновый виджет.

### `_cursor_pushed`
Флаг, указывающий, что курсор был перемещен элементом.

---

## Особенности реализации

### Динамическая замена кнопок
При входе в псайкинариум кнопка `training_grounds` автоматически заменяется на `exit_psychanium` при открытии колеса.

### Перетаскивание кнопок
Пользователь может перетаскивать кнопки правой кнопкой мыши для изменения их порядка. Новый порядок сохраняется автоматически.

### Период "милосердия"
Если курсор быстро отводится от кнопки, действие все равно сработает в течение `hover_grace_period` времени.

### Поддержка геймпада
Колесо работает как с клавиатурой/мышью, так и с геймпадом. Для геймпада используется `navigate_controller_right` для позиции курсора.

### Безопасность
Все вызовы активации views и действий обернуты в `pcall()` для предотвращения крашей при ошибках.

