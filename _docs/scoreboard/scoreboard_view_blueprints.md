# scoreboard_view_blueprints.lua - Шаблоны виджетов

## Назначение

Файл определяет шаблоны (blueprints) для создания виджетов строк статистики.

## Структура

Файл возвращает таблицу `blueprints` с шаблонами виджетов.

---

## Шаблон `scoreboard_row`

Шаблон для создания виджета одной строки статистики.

### Размер

```lua
size = {
    grid_width,  -- Ширина (из OptionsViewSettings.grid_size[1])
    ScoreboardViewSettings.scoreboard_row_height  -- Высота (20)
}
```

### Pass Template

Шаблон содержит 12 элементов (passes) для отрисовки:

#### Pass 1 - Текст заголовка (название строки)
- `value_id = "text"`
- `pass_type = "text"`
- `offset = {30, 0, base_z + 1}`
- `size = {scoreboard_column_header_width - 30, row_height}`
- `font_size = 16`
- `text_horizontal_alignment = "left"`
- `text_color = Color.terminal_text_header(255, true)`

#### Pass 2 - Иконка для игрока 1
- `value_id = "icon_1"`
- `pass_type = "texture"`
- `offset = {scoreboard_column_header_width, 2, base_z + 1}`
- `size = {row_height, row_height - 4}`
- `visible = false` (по умолчанию)

#### Pass 3 - Текст значения игрока 1
- `value_id = "text1"`
- `pass_type = "text"`
- `offset = {scoreboard_column_header_width, 0, base_z + 1}`
- `size = {scoreboard_column_width, row_height}`
- `font_size = 16`
- `text_horizontal_alignment = "center"`

#### Pass 4 - Фон колонки игрока 1
- `value_id = "bg1"`
- `pass_type = "texture"`
- `offset = {scoreboard_column_header_width, 0, base_z}`
- `size = {scoreboard_column_width, row_height}`
- `color = Color.terminal_frame(100, true)`

#### Pass 5 - Иконка для игрока 2
- `value_id = "icon_2"`
- Аналогично Pass 2, смещение по X: `+ scoreboard_column_width`

#### Pass 6 - Текст значения игрока 2
- `value_id = "text2"`
- Аналогично Pass 3, смещение по X: `+ scoreboard_column_width`

#### Pass 7 - Иконка для игрока 3
- `value_id = "icon_3"`
- Аналогично Pass 2, смещение по X: `+ scoreboard_column_width * 2`

#### Pass 8 - Текст значения игрока 3
- `value_id = "text3"`
- Аналогично Pass 3, смещение по X: `+ scoreboard_column_width * 2`

#### Pass 9 - Фон колонки игрока 3
- `value_id = "bg3"`
- Аналогично Pass 4, смещение по X: `+ scoreboard_column_width * 2`

#### Pass 10 - Иконка для игрока 4
- `value_id = "icon_4"`
- Аналогично Pass 2, смещение по X: `+ scoreboard_column_width * 3`

#### Pass 11 - Текст значения игрока 4
- `value_id = "text4"`
- Аналогично Pass 3, смещение по X: `+ scoreboard_column_width * 3`

#### Pass 12 - Фон всей строки
- `value_id = "bg"`
- `pass_type = "texture"`
- `size = {width - 32, 0}` (высота устанавливается динамически)
- `offset = {16, 0, base_z}`
- `color = Color.terminal_frame(200, true)`

---

## Маппинг passes

Для удобства работы используются маппинги:

### `player_pass_map`
Индексы passes для текстов игроков:
```lua
{3, 6, 8, 11}  -- text1, text2, text3, text4
```

### `icon_pass_map`
Соответствие текстовых passes иконкам:
```lua
{
    ["3"] = 2,   -- text1 -> icon_1
    ["6"] = 5,   -- text2 -> icon_2
    ["8"] = 7,   -- text3 -> icon_3
    ["11"] = 10  -- text4 -> icon_4
}
```

### `background_pass_map`
Соответствие текстовых passes фонам колонок:
```lua
{
    ["3"] = 4,   -- text1 -> bg1
    ["8"] = 9    -- text3 -> bg3
}
```

---

## Шаблон `settings_button`

Шаблон для кнопки настроек (не используется в основном scoreboard view, но определен для совместимости).

### Размер

```lua
size = {
    grid_width,
    settings_value_height  -- 64
}
```

### Pass Template

Использует `ButtonPassTemplates.list_button_with_icon` из стандартных шаблонов игры.

---

## Использование

Шаблон `scoreboard_row` используется в `scoreboard_view.lua` в функции `mod.create_row_widget()`:

1. Клонируется шаблон через `table.clone()`
2. Модифицируются значения и стили в зависимости от типа строки
3. Создается виджет через `UIWidget.create_definition()`

---

## Кастомизация

При создании виджета строки:

1. **Изменяются размеры:**
   - Высота строки в зависимости от типа (обычная/заголовок/большая/с очками)
   - Размер шрифта

2. **Заполняются значения:**
   - Текст заголовка (название строки)
   - Значения игроков (отформатированные числа или текст)
   - Иконки (если есть)

3. **Настраивается видимость:**
   - Иконки показываются только если у строки есть `icon`
   - Фоны колонок скрываются для четных строк (чередование)
   - Дочерние строки скрывают значения в родительской

4. **Устанавливается позиция:**
   - Вертикальное смещение на основе `current_offset`
   - Горизонтальное смещение для дочерних строк

---

## Зависимости

- `ScoreboardViewSettings` - Настройки размеров
- `OptionsViewSettings` - Настройки сетки UI
- `ButtonPassTemplates` - Шаблоны кнопок
- `UISoundEvents` - Звуковые события UI

---

## Примеры использования

### Создание виджета строки

```lua
local template = table.clone(blueprints["scoreboard_row"])
-- Модификация template
local widget_definition = UIWidget.create_definition(
    template.pass_template, 
    "scoreboard_rows", 
    nil, 
    template.size
)
local widget = self:_create_widget(name, widget_definition)
```

### Доступ к pass'ам

```lua
local player_pass_map = {3, 6, 8, 11}
local text_pass = template.pass_template[player_pass_map[1]]  -- text1
text_pass.value = "1000"
```

### Установка иконки

```lua
local icon_pass_map = {["3"] = 2}
local icon_pass = template.pass_template[icon_pass_map["3"]]  -- icon_1
icon_pass.style.visible = true
icon_pass.value = "path/to/icon"
```
