# Варианты дизайна многостраничного колеса команд

## Обзор

Различные подходы к визуальному представлению и навигации между страницами команд в радиальном меню.

---

## Вариант 1: Центральная кнопка переключения

### Концепция
Кнопка переключения страниц находится в центре колеса, заменяя или дополняя центральный круг.

### Визуальное представление
```
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]  [1/3]  [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Не занимает слоты команд
- Всегда доступна
- Интуитивно понятное расположение

### Реализация

```lua
-- Центральный виджет для переключения страниц
local center_page_button = UIWidget.create_definition({
    {
        pass_type = "hotspot",
        content_id = "hotspot",
    },
    {
        pass_type = "texture",
        value = "content/ui/materials/hud/communication_wheel/middle_circle",
        style_id = "background",
        style = {
            size = { 120, 120 },
            color = { 200, 50, 50, 50 },
        },
    },
    {
        pass_type = "text",
        value_id = "page_text",
        value = "1/3",
        style_id = "page_text",
        style = {
            font_size = 24,
            text_horizontal_alignment = "center",
            text_vertical_alignment = "center",
            color = { 255, 255, 255, 255 },
        },
    },
    {
        pass_type = "texture",
        value = "content/ui/materials/icons/system/page_switch",
        style_id = "icon",
        style = {
            size = { 40, 40 },
            offset = { 0, -20, 2 },
        },
    },
}, "pivot")
```

---

## Вариант 2: Боковые индикаторы страниц

### Концепция
Индикаторы страниц расположены по бокам колеса (слева/справа или сверху/снизу).

### Визуальное представление
```
◄ [1] [2] [3] ►
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]      [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Не мешает основному колесу
- Визуально показывает все страницы
- Можно кликать по конкретной странице

### Реализация

```lua
-- Виджет индикаторов страниц
local page_indicators_widget = UIWidget.create_definition({
    {
        pass_type = "hotspot",
        content_id = "hotspot",
    },
    -- Фон
    {
        pass_type = "rect",
        style_id = "background",
        style = {
            size = { 200, 40 },
            color = { 100, 0, 0, 0 },
        },
    },
    -- Кнопка "Предыдущая"
    {
        pass_type = "texture",
        value = "content/ui/materials/icons/system/arrow_left",
        style_id = "prev_button",
        style = {
            size = { 30, 30 },
            offset = { -80, 0, 2 },
        },
    },
    -- Индикаторы страниц
    {
        pass_type = "texture",
        value_id = "page_1",
        value = "content/ui/materials/icons/system/page_dot",
        style_id = "page_1",
        style = {
            size = { 20, 20 },
            offset = { -20, 0, 2 },
            color = { 255, 255, 255, 255 }, -- Активная страница
        },
    },
    {
        pass_type = "texture",
        value_id = "page_2",
        value = "content/ui/materials/icons/system/page_dot",
        style_id = "page_2",
        style = {
            size = { 20, 20 },
            offset = { 0, 0, 2 },
            color = { 150, 150, 150, 150 }, -- Неактивная
        },
    },
    {
        pass_type = "texture",
        value_id = "page_3",
        value = "content/ui/materials/icons/system/page_dot",
        style_id = "page_3",
        style = {
            size = { 20, 20 },
            offset = { 20, 0, 2 },
            color = { 150, 150, 150, 150 },
        },
    },
    -- Кнопка "Следующая"
    {
        pass_type = "texture",
        value = "content/ui/materials/icons/system/arrow_right",
        style_id = "next_button",
        style = {
            size = { 30, 30 },
            offset = { 80, 0, 2 },
        },
    },
}, "pivot")
```

---

## Вариант 3: Вложенные колеса (концентрические)

### Концепция
Внутренний круг - переключение страниц, внешний круг - команды текущей страницы.

### Визуальное представление
```
    [Стр1] [Стр2] [Стр3]
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]      [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Компактный дизайн
- Все страницы видны одновременно
- Быстрое переключение

### Реализация

```lua
-- Внутреннее колесо для страниц
local inner_wheel_radius = 80
local outer_wheel_radius = 190

-- Генерация внутренних слотов для страниц
local function generate_page_slots(num_pages)
    local page_slots = {}
    local angle_step = (math.pi * 2) / num_pages
    local start_angle = math.pi / 2
    
    for i = 1, num_pages do
        local angle = start_angle + (i - 1) * angle_step
        local x = math.sin(angle) * inner_wheel_radius
        local y = math.cos(angle) * inner_wheel_radius
        
        page_slots[i] = {
            angle = angle,
            position = { x, y },
            page_number = i,
        }
    end
    
    return page_slots
end
```

---

## Вариант 4: Горизонтальное меню вкладок

### Концепция
Вкладки страниц расположены горизонтально над или под колесом.

### Визуальное представление
```
┌─────┬─────┬─────┐
│Стр1 │Стр2 │Стр3 │
└─────┴─────┴─────┘
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]      [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Классический интерфейс
- Легко понять
- Можно показать названия страниц

### Реализация

```lua
local tab_widget_definition = UIWidget.create_definition({
    {
        pass_type = "hotspot",
        content_id = "hotspot",
    },
    -- Фон вкладки
    {
        pass_type = "rect",
        style_id = "background",
        style = {
            size = { 150, 40 },
            color = { 150, 0, 0, 0 },
        },
    },
    -- Активная вкладка (подсветка)
    {
        pass_type = "rect",
        style_id = "active_indicator",
        style = {
            size = { 150, 4 },
            offset = { 0, 18, 1 },
            color = { 255, 255, 100, 100 },
        },
        visibility_function = function(content, style)
            return content.is_active
        end,
    },
    -- Текст вкладки
    {
        pass_type = "text",
        value_id = "tab_name",
        value = "Основные",
        style_id = "tab_text",
        style = {
            font_size = 18,
            text_horizontal_alignment = "center",
            text_vertical_alignment = "center",
            color = { 255, 255, 255, 255 },
        },
    },
}, "pivot")
```

---

## Вариант 5: Вертикальное боковое меню

### Концепция
Меню страниц расположено вертикально слева или справа от колеса.

### Визуальное представление
```
[1]     [Команда 1]
[2]  [Команда 2]  [Команда 3]
[3] [Команда 4]      [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Не перекрывает колесо
- Компактное расположение
- Легко добавить больше страниц

### Реализация

```lua
local vertical_menu_widget = UIWidget.create_definition({
    {
        pass_type = "hotspot",
        content_id = "hotspot",
    },
    -- Фон меню
    {
        pass_type = "rect",
        style_id = "background",
        style = {
            size = { 60, 200 },
            color = { 100, 0, 0, 0 },
        },
    },
    -- Кнопки страниц
    {
        pass_type = "rect",
        value_id = "page_1",
        style_id = "page_1",
        style = {
            size = { 50, 50 },
            offset = { 5, -75, 2 },
            color = { 255, 255, 255, 255 }, -- Активная
        },
    },
    {
        pass_type = "text",
        value_id = "page_1_text",
        value = "1",
        style_id = "page_1_text",
        style = {
            font_size = 24,
            offset = { 5, -75, 3 },
            text_horizontal_alignment = "center",
            text_vertical_alignment = "center",
        },
    },
    -- Аналогично для других страниц...
}, "pivot")
```

---

## Вариант 6: Минималистичный индикатор

### Концепция
Только маленький индикатор в углу экрана с номером страницы и стрелками.

### Визуальное представление
```
                    ◄ 1/3 ►
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]      [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Не мешает обзору
- Минималистичный дизайн
- Можно разместить в любом углу

### Реализация

```lua
local minimal_indicator = UIWidget.create_definition({
    {
        pass_type = "hotspot",
        content_id = "hotspot",
    },
    -- Фон
    {
        pass_type = "rect",
        style_id = "background",
        style = {
            size = { 100, 30 },
            color = { 50, 0, 0, 0 },
        },
    },
    -- Стрелка влево
    {
        pass_type = "texture",
        value = "content/ui/materials/icons/system/arrow_left",
        style_id = "prev",
        style = {
            size = { 20, 20 },
            offset = { 5, 5, 2 },
        },
    },
    -- Номер страницы
    {
        pass_type = "text",
        value_id = "page_number",
        value = "1/3",
        style_id = "page_text",
        style = {
            font_size = 16,
            offset = { 30, 0, 2 },
            text_horizontal_alignment = "center",
        },
    },
    -- Стрелка вправо
    {
        pass_type = "texture",
        value = "content/ui/materials/icons/system/arrow_right",
        style_id = "next",
        style = {
            size = { 20, 20 },
            offset = { 75, 5, 2 },
        },
    },
}, "pivot")
```

---

## Вариант 7: Warhammer-стиль (глифы и символы)

### Концепция
Использование символов и глифов в стиле Warhammer 40k для индикации страниц.

### Визуальное представление
```
    ═══ [I] ═══ [II] ═══ [III] ═══
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]      [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Соответствует тематике игры
- Уникальный дизайн
- Атмосферность

### Реализация

```lua
local warhammer_style_indicator = UIWidget.create_definition({
    {
        pass_type = "hotspot",
        content_id = "hotspot",
    },
    -- Декоративные линии
    {
        pass_type = "texture",
        value = "content/ui/materials/hud/communication_wheel/imperial_symbol",
        style_id = "decorative_line",
        style = {
            size = { 200, 4 },
            color = { 200, 150, 50, 200 },
        },
    },
    -- Римские цифры для страниц
    {
        pass_type = "text",
        value_id = "page_roman",
        value = "I",
        style_id = "page_roman_text",
        style = {
            font_type = "machine_medium",
            font_size = 28,
            text_horizontal_alignment = "center",
            color = { 255, 200, 100, 255 },
        },
    },
    -- Имперский орел или символ
    {
        pass_type = "texture",
        value = "content/ui/materials/icons/imperial_eagle",
        style_id = "imperial_symbol",
        style = {
            size = { 40, 40 },
            offset = { 0, -30, 1 },
        },
    },
}, "pivot")
```

---

## Вариант 8: Комбинированный (центральная кнопка + индикаторы)

### Концепция
Центральная кнопка для переключения + боковые индикаторы для визуальной обратной связи.

### Визуальное представление
```
    [1] [2] [3]
        [Команда 1]
    [Команда 2]  [Команда 3]
[Команда 4]  [1/3]  [Команда 5]
    [Команда 6]  [Команда 7]
        [Команда 8]
```

### Преимущества
- Два способа переключения
- Максимальная информативность
- Удобство использования

---

## Вариант 9: Анимированное переключение

### Концепция
Плавная анимация при переключении страниц (fade, slide, rotate).

### Типы анимаций

#### Fade (затухание)
```lua
local function animate_page_switch_fade(self, new_page, duration)
    duration = duration or 0.2
    local fade_out = {
        progress = 0,
        duration = duration / 2,
        start_time = t,
        type = "out",
    }
    local fade_in = {
        progress = 0,
        duration = duration / 2,
        start_time = t + duration / 2,
        type = "in",
    }
    
    self._page_switch_animation = {
        fade_out = fade_out,
        fade_in = fade_in,
    }
end
```

#### Slide (сдвиг)
```lua
local function animate_page_switch_slide(self, direction, duration)
    -- Команды сдвигаются в сторону, новые появляются с другой стороны
    local slide_distance = 200
    local slide_progress = 0
    
    -- Анимация сдвига
    for i, entry in ipairs(self._entries) do
        local widget = entry.widget
        local offset = widget.offset
        offset[1] = offset[1] + slide_distance * direction * slide_progress
    end
end
```

#### Rotate (вращение)
```lua
local function animate_page_switch_rotate(self, direction, duration)
    -- Колесо вращается при переключении
    local rotation_angle = (math.pi * 2 / self._max_pages) * direction
    local rotation_progress = 0
    
    -- Применяем вращение ко всем элементам
    for i, entry in ipairs(self._entries) do
        local widget = entry.widget
        local angle = widget.content.angle or 0
        widget.content.angle = angle + rotation_angle * rotation_progress
    end
end
```

---

## Вариант 10: Адаптивный дизайн (разные стили для разных ситуаций)

### Концепция
Меню меняет стиль в зависимости от контекста (в бою, в меню, в инвентаре).

### Реализация

```lua
local function get_wheel_style_for_context(context)
    local styles = {
        combat = {
            background_color = { 200, 255, 0, 0 },  -- Красный/желтый
            indicator_position = "center",
            animation_speed = 30,
        },
        menu = {
            background_color = { 150, 0, 0, 0 },  -- Темный
            indicator_position = "top",
            animation_speed = 20,
        },
        inventory = {
            background_color = { 100, 100, 100, 100 },  -- Серый
            indicator_position = "side",
            animation_speed = 15,
        },
    }
    
    return styles[context] or styles.combat
end
```

---

## Сравнительная таблица

| Вариант | Сложность | Визуальная нагрузка | Удобство | Уникальность |
|---------|-----------|---------------------|----------|--------------|
| Центральная кнопка | Низкая | Низкая | Высокое | Средняя |
| Боковые индикаторы | Средняя | Средняя | Высокое | Средняя |
| Вложенные колеса | Высокая | Средняя | Среднее | Высокая |
| Горизонтальные вкладки | Низкая | Средняя | Высокое | Низкая |
| Вертикальное меню | Средняя | Низкая | Высокое | Средняя |
| Минималистичный | Низкая | Очень низкая | Среднее | Высокая |
| Warhammer-стиль | Высокая | Высокая | Среднее | Очень высокая |
| Комбинированный | Высокая | Средняя | Очень высокое | Высокая |
| Анимированный | Очень высокая | Средняя | Высокое | Высокая |
| Адаптивный | Очень высокая | Низкая | Высокое | Высокая |

---

## Рекомендации по выбору

### Для начинающих
- **Вариант 1** (Центральная кнопка) - простой в реализации
- **Вариант 4** (Горизонтальные вкладки) - классический подход

### Для среднего уровня
- **Вариант 2** (Боковые индикаторы) - хороший баланс
- **Вариант 5** (Вертикальное меню) - компактный дизайн

### Для продвинутых
- **Вариант 7** (Warhammer-стиль) - уникальный дизайн
- **Вариант 8** (Комбинированный) - максимальная функциональность
- **Вариант 9** (Анимированный) - плавные переходы

---

## Пример комбинированной реализации

```lua
-- Комбинированный виджет: центральная кнопка + боковые индикаторы
local combined_page_control = {
    center_button = center_page_button,
    side_indicators = page_indicators_widget,
    
    init = function(self)
        self._center_button_widget = self:_create_widget("center_page_button", center_page_button)
        self._side_indicators_widget = self:_create_widget("side_indicators", page_indicators_widget)
    end,
    
    update = function(self, current_page, max_pages)
        -- Обновляем центральную кнопку
        self._center_button_widget.content.page_text = string.format("%d/%d", current_page, max_pages)
        
        -- Обновляем боковые индикаторы
        for i = 1, max_pages do
            local indicator = self._side_indicators_widget.style["page_" .. i]
            if i == current_page then
                indicator.color = { 255, 255, 255, 255 }  -- Активная
            else
                indicator.color = { 150, 150, 150, 150 }  -- Неактивная
            end
        end
    end,
}
```

---

## Заключение

Выбор дизайна зависит от:
- **Сложности реализации** - насколько вы готовы кодить
- **Визуального стиля** - соответствие тематике игры
- **Удобства использования** - как быстро игрок сможет переключаться
- **Производительности** - влияние на FPS

Рекомендуется начать с простого варианта (центральная кнопка) и постепенно добавлять функции по мере необходимости.

