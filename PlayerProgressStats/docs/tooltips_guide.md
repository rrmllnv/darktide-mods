# 💡 Руководство по всплывающим подсказкам (Tooltips)

---

## Что такое Tooltips?

**Tooltips (всплывающие подсказки)** - это дополнительная информация, которая отображается при наведении мыши на элемент.

В моде используются для объяснения сложных условий Flawless миссий без загромождения основного UI.

---

## 🎯 Когда использовать tooltips?

✅ **Используйте tooltips когда:**
- Статистика имеет сложные условия получения
- Нужно объяснить аббревиатуру или термин
- Есть важные детали, но не хватает места в UI
- Нужно показать формулу расчета

❌ **НЕ используйте tooltips когда:**
- Информация очевидна из названия
- Это обычная простая статистика
- Нет дополнительной информации для показа

---

## 📝 Как добавить tooltip к статистике?

### Шаг 1: Используйте blueprint `stat_line_tooltip`

```lua
-- tab_missions.lua или другой tab файл

table.insert(layout, {
    widget_type = "stat_line_tooltip",  -- ⬅ Специальный blueprint
    text = localize("stats_your_stat"),
    value = format_number(safe_read_stat("your_stat_name")),
    tooltip = localize("tooltip_your_stat")  -- ⬅ Ключ локализации подсказки
})
```

### Шаг 2: Добавьте локализацию

```lua
-- PlayerProgressStats_localization.lua

tooltip_your_stat = {
    en = "Your tooltip text in English",
    ru = "Текст подсказки на русском",
},
```

---

## 🎨 Стиль tooltips

### Текущий стиль:
- **Тип:** Floating widget (плавающий над элементом)
- **Шрифт:** `proxima_nova_bold`
- **Размер:** `16px`
- **Цвет:** Белый текст на черном фоне с border
- **Позиция:** **НАД** widget'ом (не внутри строки!)
- **Видимость:** Только при `hotspot.is_hover == true`
- **Z-index:** `200` (высокий приоритет, над всеми элементами)

### Пример визуально:

```
┌────────────────────────────────────────────┐
│ Auric, no player deaths, joined ≤20%      │ ⬅ Floating Tooltip (над строкой)
└────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Personal Flawless Auric           123       │ ⬅ Основная строка (при hover)
└─────────────────────────────────────────────┘
```

**Ключевое отличие от старой реализации:** Tooltip теперь **не накладывается** на текст, а плавает над ним как отдельный widget!

---

## 🔧 Технические детали

### Архитектура (по аналогии с DMF):

```
1. Scenegraph элемент "tooltip" (z=200, высокий приоритет)
   ↓
2. Floating widget с border + background + text
   ↓
3. stat_line_tooltip_blueprint хранит tooltip в content
   ↓
4. _update_tooltip() проверяет hover и показывает/скрывает widget
```

### 1. Scenegraph Definition:

```lua
tooltip = {
    vertical_alignment = "top",
    parent = "screen",
    horizontal_alignment = "left",
    size = {0, 0},
    position = {0, 0, 200},  -- Z=200 для показа поверх всех элементов
},
```

### 2. Tooltip Widget Definition:

```lua
tooltip = UIWidget.create_definition({
    {
        pass_type = "rect",  -- Border (рамка)
        style = {
            color = Color.ui_terminal(255, true),
            size_addition = {16, 16},
        },
    },
    {
        pass_type = "rect",  -- Background (фон)
        style = {
            color = Color.black(255, true),
            size_addition = {14, 14},
        },
    },
    {
        value_id = "text",
        pass_type = "text",
        value = "",
        style = {
            font_type = "proxima_nova_bold",
            font_size = 16,
            text_color = Color.white(255, true),
        },
    },
}, "tooltip", {
    visible = false,  -- По умолчанию скрыт
}),
```

### 3. Blueprint хранит tooltip в content:

```lua
local stat_line_tooltip_blueprint = {
    size = {grid_size[1] - 20, 34},  -- Обычная высота строки
    pass_template = {
        -- hotspot, background, text, value...
    },
    init = function(_, widget, element)
        widget.content.text = element.text or ""
        widget.content.value = element.value or ""
        widget.content.tooltip = element.tooltip or ""  -- ⬅ Сохраняем tooltip
    end,
}
```

### 4. Функция обновления tooltip:

```lua
PlayerProgressStatsView._update_tooltip = function(self)
    local tooltip_widget = self._widgets_by_name.tooltip
    local grid = self._stats_grid
    local widgets = grid:widgets()
    
    for i = 1, #widgets do
        local widget = widgets[i]
        local hotspot = widget.content.hotspot
        local tooltip_text = widget.content.tooltip
        
        if hotspot and hotspot.is_hover and tooltip_text and tooltip_text ~= "" then
            -- Вычисляем позицию
            local grid_pivot = self:_scenegraph_world_position("grid_pivot")
            local x_pos = grid_pivot[1] + widget.offset[1]
            local y_pos = grid_pivot[2] + widget.offset[2] - scroll_offset - height - 20
            
            -- Позиционируем и показываем
            tooltip_widget.offset[1] = x_pos
            tooltip_widget.offset[2] = math.max(y_pos, 50)
            tooltip_widget.content.text = tooltip_text
            tooltip_widget.content.visible = true
            break
        end
    end
end
```

### Ключевые отличия от встроенного tooltip:

| Встроенный | Floating Widget |
|-----------|----------------|
| ❌ Накладывается на текст | ✅ Плавает над элементом |
| ❌ Увеличивает высоту строки | ✅ Не влияет на layout |
| ❌ Ограничен размером строки | ✅ Динамический размер |
| ❌ Z-fighting проблемы | ✅ Высокий z-index (200) |

---

## 📊 Примеры использования

### Пример 1: Flawless Mission

```lua
table.insert(layout, {
    widget_type = "stat_line_tooltip",
    text = localize("stats_flawless_missions"),
    value = format_number(safe_read_stat("max_flawless_mission_in_a_row")),
    tooltip = localize("tooltip_flawless_missions")
})

-- Локализация:
tooltip_flawless_missions = {
    en = "Difficulty 3+, no deaths or downs (player)",
    ru = "Сложность 3+, без смертей и падений (игрок)",
}
```

### Пример 2: Havoc Rank

```lua
table.insert(layout, {
    widget_type = "stat_line_tooltip",
    text = localize("stats_havoc_rank"),
    value = format_number(havoc_rank),
    tooltip = localize("tooltip_havoc_rank")
})

-- Локализация:
tooltip_havoc_rank = {
    en = "Highest Havoc rank reached (5-40)",
    ru = "Наивысший достигнутый Havoc ранг (5-40)",
}
```

### Пример 3: Без tooltip (пустая строка)

```lua
table.insert(layout, {
    widget_type = "stat_line_tooltip",
    text = localize("stats_simple_stat"),
    value = format_number(safe_read_stat("simple_stat")),
    tooltip = ""  -- ⬅ Пустая строка = tooltip не будет показан
})
```

---

## 🌐 Рекомендации по локализации

### ✅ Хорошие tooltip тексты:

```lua
-- Кратко, но информативно
"Difficulty 3+, no deaths or downs"

-- Указывает конкретные условия
"Auric + Difficulty 5+, no team downs"

-- Объясняет аббревиатуру
"Havoc Rank 35+, no team deaths or downs"
```

### ❌ Плохие tooltip тексты:

```lua
-- Слишком длинно
"This statistic tracks the maximum number of flawless missions you have completed in a row without dying or being downed on difficulty 3 or higher"

-- Повторяет название
"Total Kills: your total kills"

-- Непонятно
"Special condition applies"
```

### Правила для текста:

- ✅ Максимум **50 символов**
- ✅ Используйте **аббревиатуры** (Diff, no, ≤)
- ✅ Указывайте **конкретные числа** (3+, 5+, 35+)
- ✅ Пишите **условия**, а не описания
- ❌ Не дублируйте название статистики
- ❌ Не пишите длинные предложения

---

## 🛠️ Добавление в другие вкладки

### tab_records.lua

```lua
table.insert(layout, {
    widget_type = "stat_line_tooltip",
    text = localize("stats_max_headshots"),
    value = format_number(safe_read_stat("max_head_shot_in_a_row")),
    tooltip = localize("tooltip_max_headshots")
})
```

### tab_defense.lua

```lua
table.insert(layout, {
    widget_type = "stat_line_tooltip",
    text = localize("stats_max_dodges"),
    value = format_number(safe_read_stat("max_dodges_in_a_row")),
    tooltip = localize("tooltip_max_dodges")
})
```

---

## 🔍 Отладка tooltips

### Проверка в игре:

1. Запустите игру и откройте мод
2. Наведите мышь на статистику с tooltip
3. **Подсказка должна появиться** внизу строки серым текстом
4. При отведении мыши подсказка исчезает

### Если tooltip не появляется:

1. ✅ Проверьте что используется `stat_line_tooltip`, а не `stat_line`
2. ✅ Проверьте что `tooltip` параметр не пустой
3. ✅ Проверьте локализацию - ключ должен существовать
4. ✅ Проверьте консоль на ошибки

### Если tooltip отображается неправильно:

1. Проверьте длину текста - слишком длинный может выходить за границы
2. **Проверьте символ `%`** - он должен быть экранирован как `%%`
3. Проверьте специальные символы - `<`, `>`, `&` могут вызывать проблемы
4. Проверьте кодировку русского текста в файле локализации

### ⚠️ Важно: Экранирование символа %

Lua использует `%` для форматирования строк. Если вам нужен символ процента в tooltip, **экранируйте его как `%%`**:

```lua
-- ❌ ОШИБКА: invalid option '%' to 'format'
tooltip_example = {
    en = "joined ≤20%",
}

-- ✅ ПРАВИЛЬНО:
tooltip_example = {
    en = "joined ≤20%%",  -- %% -> отобразится как %
}
```

---

## 📖 Дополнительная информация

### Связанные файлы:
- `views/player_progress_stats_view.lua` - определение blueprint
- `views/tabs/tab_missions.lua` - пример использования
- `PlayerProgressStats_localization.lua` - локализация tooltips

### Связанная документация:
- [`stats_missions.md`](stats_missions.md) - полный список Flawless миссий
- [`STATS_REFERENCE.md`](../STATS_REFERENCE.md) - главный справочник

---

**Версия:** 1.0  
**Дата:** 2025-12-02  
**Статус:** ✅ Реализовано для вкладки "Миссии"

