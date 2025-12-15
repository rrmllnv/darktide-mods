# scoreboard_view_definitions.lua - Определения UI элементов

## Назначение

Файл определяет структуру UI для scoreboard view: scenegraph (позиционирование элементов) и виджеты.

## Структура

Файл возвращает таблицу `ScoreboardViewDefinitions` с полями:
- `scenegraph_definition` - Определения позиций элементов
- `widget_definitions` - Определения виджетов
- `legend_inputs` - Определения легенды ввода

---

## Scenegraph Definition

Определяет позиционирование элементов на экране.

### `screen`
Базовый элемент экрана (из `UIWorkspaceSettings.screen`).

### `scoreboard`
Основной контейнер scoreboard.

**Свойства:**
- `vertical_alignment = "center"` - Вертикальное выравнивание по центру
- `horizontal_alignment = "center"` - Горизонтальное выравнивание по центру
- `parent = "screen"` - Родительский элемент
- `size` - Размер из `ScoreboardViewSettings.scoreboard_size`
- `position = {0, 0, base_z}` - Позиция (base_z = 100)

### `scoreboard_rows`
Контейнер для строк статистики.

**Свойства:**
- `vertical_alignment = "top"` - Выравнивание по верху
- `parent = "scoreboard"` - Родитель - scoreboard
- `size` - Ширина = scoreboard, высота = scoreboard - 100
- `position = {0, 40, base_z + 1}` - Смещение вниз на 40 пикселей

---

## Widget Definitions

### `scoreboard`
Виджет фона scoreboard с несколькими слоями.

**Слои (pass_template):**

1. **Слой 1 (style_id_1)** - Тень
   - `pass_type = "texture"`
   - `value = "content/ui/materials/frames/dropshadow_heavy"`
   - `offset = {0, 0, base_z + 2}`
   - `size = {width - 4, height - 3}`
   - `color = Color.black(255, true)`

2. **Слой 2 (style_id_2)** - Внутренняя тень
   - `pass_type = "texture"`
   - `value = "content/ui/materials/frames/inner_shadow_medium"`
   - `offset = {0, 0, base_z + 1}`
   - `size = {width - 24, height - 28}`
   - `color = Color.terminal_grid_background(255, true)`

3. **Слой 3 (style_id_3)** - Фон
   - `pass_type = "texture"`
   - `value = "content/ui/materials/backgrounds/terminal_basic"`
   - `offset = {0, 0, base_z}`
   - `size = {width - 4, height}`
   - `color = Color.terminal_grid_background(255, true)`

4. **Слой 4 (style_id_4)** - Верхняя рамка
   - `pass_type = "texture"`
   - `value = "content/ui/materials/frames/premium_store/details_upper"`
   - `offset = {0, -height / 2, base_z + 200}`
   - `size = {width, 80}`
   - `color = Color.gray(255, true)`

5. **Слой 5 (style_id_5)** - Нижняя рамка
   - `pass_type = "texture"`
   - `value = "content/ui/materials/frames/premium_store/details_lower_basic"`
   - `offset = {0, height / 2 - 50, base_z + 200}`
   - `size = {width + 50, 120}`
   - `color = Color.gray(255, true)`

**Scenegraph ID:** `"scoreboard"`

---

## Legend Inputs

Определения для легенды ввода (подсказки по клавишам).

### Запись легенды

```lua
{
    input_action = "hotkey_menu_special_1",  -- Действие ввода
    on_pressed_callback = "cb_on_save_pressed",  -- Callback при нажатии
    display_name = "loc_scoreboard_save",  -- Ключ локализации
    alignment = "left_alignment"  -- Выравнивание
}
```

**Использование:** Отображает подсказку "Сохранить" с привязкой к клавише.

---

## Зависимости

- `UIWorkspaceSettings` - Настройки рабочего пространства UI
- `UIWidget` - Класс виджетов
- `ScoreboardViewSettings` - Настройки размеров scoreboard
- `Color` - Цвета UI

---

## Использование

Определения используются в `ScoreboardView` для:
- Создания scenegraph через `BaseView.init()`
- Создания виджетов через `UIWidget.create_definition()`
- Настройки легенды ввода через `ViewElementInputLegend`

---

## Изменение размеров

Размеры элементов берутся из `ScoreboardViewSettings.scoreboard_size`, что позволяет изменять размер scoreboard через настройки.

---

## Z-индексы

Элементы располагаются на разных Z-уровнях:
- `base_z` (100) - Фон
- `base_z + 1` (101) - Внутренняя тень, строки
- `base_z + 2` (102) - Внешняя тень
- `base_z + 200` (300) - Рамки (поверх всего)
