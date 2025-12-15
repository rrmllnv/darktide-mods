# scoreboard_view_settings.lua - Настройки размеров и стилей UI

## Назначение

Файл определяет настройки размеров, высот и других параметров UI для scoreboard view.

## Структура

Файл возвращает таблицу `scoreboard_view_settings` с полями:

---

## Параметры

### `shading_environment`
**Тип:** Строка  
**Значение:** `"content/shading_environments/ui/system_menu"`  
**Назначение:** Окружение затенения для UI

---

### `scoreboard_size`
**Тип:** Массив `{width, height}`  
**Значение:** `{1000, mod:get("scoreboard_panel_height")}`  
**Назначение:** Размер основного контейнера scoreboard
- Ширина: 1000 пикселей
- Высота: из настройки `scoreboard_panel_height` (по умолчанию 1000, диапазон 580-1000)

---

### `scoreboard_row_height`
**Тип:** Число  
**Значение:** `20`  
**Назначение:** Высота обычной строки статистики в пикселях

---

### `scoreboard_row_header_height`
**Тип:** Число  
**Значение:** `30`  
**Назначение:** Высота строки заголовка (с именами игроков) в пикселях

---

### `scoreboard_row_big_height`
**Тип:** Число  
**Значение:** `36`  
**Назначение:** Высота большой строки (с флагом `big = true`) в пикселях

---

### `scoreboard_row_score_height`
**Тип:** Число  
**Значение:** `36`  
**Назначение:** Высота строки с очками (с флагом `score = true`) в пикселях

---

### `scoreboard_column_width`
**Тип:** Число  
**Значение:** `170`  
**Назначение:** Ширина колонки для значения игрока в пикселях

---

### `scoreboard_column_header_width`
**Тип:** Число  
**Значение:** `300`  
**Назначение:** Ширина колонки заголовка (название строки) в пикселях

---

### `scoreboard_fade_length`
**Тип:** Число  
**Значение:** `0.1`  
**Назначение:** Длительность анимации появления строки в секундах

---

## Использование

Настройки используются в:
- `scoreboard_view_definitions.lua` - для размеров scenegraph
- `scoreboard_view_blueprints.lua` - для размеров виджетов строк
- `scoreboard_view.lua` - для вычисления позиций и размеров элементов

---

## Изменение настроек

### Динамические настройки

`scoreboard_size[2]` (высота) берется из настройки мода `scoreboard_panel_height`, что позволяет пользователю изменять высоту scoreboard.

### Статические настройки

Остальные настройки захардкожены и могут быть изменены только в коде.

---

## Зависимости

- `mod` - Объект мода для доступа к настройкам

---

## Примеры использования

### Получение размера scoreboard

```lua
local settings = mod:io_dofile("scoreboard_view_settings")
local width = settings.scoreboard_size[1]  -- 1000
local height = settings.scoreboard_size[2]  -- из настройки
```

### Получение высоты строки

```lua
local row_height = settings.scoreboard_row_height  -- 20
local header_height = settings.scoreboard_row_header_height  -- 30
```

### Вычисление позиции колонки

```lua
local column_x = settings.scoreboard_column_header_width + 
                 (player_index - 1) * settings.scoreboard_column_width
```
