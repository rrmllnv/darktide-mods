# MourningstarCommandWheel_definitions.lua - Документация

## Описание файла

Файл определений UI для колеса команд. Содержит определения scenegraph, виджетов и их стилей для отображения колеса на экране.

## Зависимости

- `CommandWheelSettings` - настройки колеса (из `MourningstarCommandWheel_settings.lua`)
- `UIFontSettings` - настройки шрифтов
- `UISoundEvents` - звуковые события
- `UIWidget` - система виджетов
- `UIWorkspaceSettings` - настройки workspace
- `UIHudSettings` - настройки HUD
- `ColorUtilities` - утилиты для работы с цветами

## Структура файла

Файл возвращает таблицу с тремя основными компонентами:
- `scenegraph_definition` - определение scenegraph
- `widget_definitions` - определения виджетов
- `entry_widget_definition` - определение виджета для одной кнопки

---

## Scenegraph Definition

### `screen`
Корневой элемент scenegraph, наследуется от `UIWorkspaceSettings.screen`.

### `pivot`
Центральная точка для позиционирования колеса.

**Параметры:**
- `horizontal_alignment`: `"center"` - горизонтальное выравнивание по центру
- `vertical_alignment`: `"center"` - вертикальное выравнивание по центру
- `size`: `{0, 0}` - размер (не используется, так как позиционирование через offset)
- `position`: `{0, 0, 100}` - позиция (центр экрана, z = 100)

### `background`
Фоновый элемент для центрального круга.

**Параметры:**
- `size`: `{CommandWheelSettings.center_circle_size, CommandWheelSettings.center_circle_size}`
- `position`: `{0, 0, 1}` - относительно pivot

---

## Entry Widget Definition

Определение виджета для одной кнопки в колесе. Создается через `UIWidget.create_definition()`.

### Компоненты виджета

#### 1. Hotspot
Область взаимодействия для кнопки.

**Тип:** `hotspot`  
**Content ID:** `"hotspot"`  
**Звуки:**
- `on_hover_sound`: `UISoundEvents.default_mouse_hover`
- `on_pressed_sound`: `UISoundEvents.default_select`

---

#### 2. Icon (Иконка)
Текстура иконки кнопки.

**Тип:** `texture`  
**Value ID:** `"icon"`  
**Размер:** `{CommandWheelSettings.icon_size, CommandWheelSettings.icon_size}`

**Change Function:**
- Изменяет цвет иконки в зависимости от состояния hover
- Использует `ColorUtilities.color_lerp()` для плавного перехода между `icon_default_color` и `icon_hover_color`

---

#### 3. Slice Line (Линия сегмента)
Внешняя граница сегмента.

**Тип:** `rotated_texture`  
**Текстура:** `"content/ui/materials/hud/communication_wheel/slice_eighth_line"`  
**Style ID:** `"slice_line"`

**Параметры:**
- `size`: `{CommandWheelSettings.line_width, line_height}`
- `angle`: вычисляется как `math.pi + content.angle`

**Change Function:**
- Обновляет угол поворота
- Вычисляет высоту линии, если не задана явно
- Изменяет цвет в зависимости от hover состояния

---

#### 4. Slice Highlight (Подсветка сегмента)
Подсветка сегмента при наведении.

**Тип:** `rotated_texture`  
**Текстура:** `"content/ui/materials/hud/communication_wheel/slice_eighth_highlight"`  
**Style ID:** `"slice_highlight"`

**Параметры:**
- `size`: `{CommandWheelSettings.slice_width, CommandWheelSettings.slice_height}`
- `uvs`: обрезка текстуры через `slice_uv_*` параметры
- `angle`: вычисляется как `math.pi + content.angle`

**Change Function:**
- Применяет корректировку кривизны через `slice_curvature_scale_*`
- Изменяет цвет между `button_color_default` и `button_color_hover`

---

#### 5. Slice (Сегмент)
Основной сегмент кнопки.

**Тип:** `rotated_texture`  
**Текстура:** `"content/ui/materials/hud/communication_wheel/slice_eighth"`  
**Style ID:** `"slice"`

**Параметры:**
- `size`: `{CommandWheelSettings.slice_width, CommandWheelSettings.slice_height}`
- `uvs`: обрезка текстуры через `slice_uv_*` параметры
- `angle`: вычисляется как `math.pi + content.angle`

**Change Function:**
- Применяет корректировку кривизны через `slice_curvature_scale_*`

---

#### 6. Text (Текст)
Текстовая метка кнопки (не используется в текущей реализации).

**Тип:** `text`  
**Value ID:** `"text"`  
**Font:** `button_medium`  
**Font Size:** `16`

**Change Function:**
- Изменяет яркость текста в зависимости от состояния нажатия

---

## Widget Definitions

### `wheel_background`
Виджет фона колеса, содержащий несколько компонентов.

#### Компонент 1: Middle Box (Ромб)
Ромб, который появляется при наведении на кнопку.

**Тип:** `texture`  
**Текстура:** `"content/ui/materials/hud/communication_wheel/middle_box"`

**Параметры:**
- `size`: `{rhombus_width or center_circle_size, rhombus_height or center_circle_size * 0.256}`
- `color`: `CommandWheelSettings.rhombus_color`

**Change Function:**
- Обновляет размер ромба динамически

**Visibility Function:**
- Видим только когда `content.force_hover == true`

---

#### Компонент 2: Text (Текст в центре)
Текст названия кнопки в центре колеса.

**Тип:** `text`  
**Value ID:** `"text"`  
**Font:** `hud_body` (размер 28)

**Visibility Function:**
- Видим только когда `content.force_hover == true`

---

#### Компонент 3: Middle Circle (Центральный круг)
Фоновый круг в центре колеса.

**Тип:** `texture`  
**Текстура:** `"content/ui/materials/hud/communication_wheel/middle_circle"`

**Параметры:**
- `size`: `{CommandWheelSettings.center_circle_size, CommandWheelSettings.center_circle_size}`
- `color`: `CommandWheelSettings.background_color`

**Change Function:**
- Обновляет размер фона динамически

---

#### Компонент 4: Mark (Стрелка)
Стрелка, указывающая на выбранную кнопку.

**Тип:** `rotated_texture`  
**Текстура:** `"content/ui/materials/hud/communication_wheel/arrow"`  
**Style ID:** `"mark"`

**Параметры:**
- `size`: `{20, 28}` (масштабируется пропорционально `center_circle_size`)
- `pivot`: `{10, 147}` (масштабируется)
- `offset`: `{0, -133, 100}` (масштабируется)

**Change Function:**
- Обновляет угол поворота: `math.pi - content.angle`
- Масштабирует размер и позицию пропорционально `center_circle_size`
- Изменяет цвет в зависимости от hover состояния

---

## Цвета

Файл определяет цвета для различных элементов:

### `hover_color`
Цвет линии при наведении. Использует `CommandWheelSettings.line_color_hover` или `get_hud_color("color_tint_main_1", 255)`.

### `default_color`
Цвет линии по умолчанию. Использует `CommandWheelSettings.line_color_default` или `get_hud_color("color_tint_main_2", 255)`.

### `icon_hover_color`
Цвет иконки при наведении. Использует `CommandWheelSettings.icon_color_hover` или `get_hud_color("color_tint_main_2", 255)`.

### `icon_default_color`
Цвет иконки по умолчанию. Использует `CommandWheelSettings.icon_color_default` или `get_hud_color("color_tint_main_3", 255)`.

---

## Использование

Определения используются в `HudElementCommandWheel.lua` для:
- Создания виджетов через `UIWidget.init()`
- Инициализации scenegraph через `UIScenegraph.init_scenegraph()`
- Отрисовки виджетов через `UIWidget.draw()`

## Примечания

- Все углы вычисляются в радианах
- Позиционирование кнопок происходит через `offset` виджетов
- UV координаты используются для обрезки текстур и создания промежутков между кнопками
- Change functions вызываются каждый кадр для обновления визуального состояния

