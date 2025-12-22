# Scoreboard Mod - Полная документация по программированию

## Обзор

Мод `scoreboard` - это система отслеживания статистики игроков в Warhammer 40,000: Darktide. Мод собирает данные о действиях игроков во время миссии и отображает их в виде таблицы результатов.

## Структура мода

Мод состоит из следующих основных компонентов:

1. **scoreboard.lua** - Главный файл мода, точка входа
2. **scoreboard_data.lua** - Конфигурация настроек и опций
3. **scoreboard_rows.lua** - Определение и регистрация строк статистики
4. **scoreboard_default_plugins.lua** - Хуки для отслеживания игровых событий
5. **scoreboard_hud.lua** - Интеграция с HUD (тактический обзор)
6. **scoreboard_definitions.lua** - Типы валидации и итерации данных
7. **scoreboard_history.lua** - Сохранение и загрузка истории результатов
8. **scoreboard_view.lua** - Основной UI view для отображения таблицы
9. **scoreboard_view_definitions.lua** - Определения UI элементов
10. **scoreboard_view_settings.lua** - Настройки размеров и стилей UI
11. **scoreboard_view_blueprints.lua** - Шаблоны виджетов для строк

## Документация по компонентам

- [scoreboard.lua - Главный файл](./scoreboard_main.md)
- [scoreboard_data.lua - Настройки](./scoreboard_data.md)
- [scoreboard_rows.lua - Строки статистики](./scoreboard_rows.md)
- [scoreboard_default_plugins.lua - Отслеживание событий](./scoreboard_plugins.md)
- [scoreboard_hud.lua - HUD интеграция](./scoreboard_hud.md)
- [scoreboard_definitions.lua - Типы данных](./scoreboard_definitions.md)
- [scoreboard_history.lua - История](./scoreboard_history.md)
- [scoreboard_view.lua - UI View](./scoreboard_view.md)
- [scoreboard_view_definitions.lua - UI определения](./scoreboard_view_definitions.md)
- [scoreboard_view_settings.lua - UI настройки](./scoreboard_view_settings.md)
- [scoreboard_view_blueprints.lua - UI шаблоны](./scoreboard_view_blueprints.md)

## Основные концепции

### Регистрация строк (Rows)

Строка статистики - это единица данных, которая отслеживает определенный показатель (например, убийства, урон, поднятые предметы). Каждая строка имеет:
- `name` - уникальное имя строки
- `text` - локализованное название для отображения
- `validation` - тип валидации (ASC/DESC) для определения лучшего/худшего значения
- `iteration` - тип итерации (ADD/DIFF) для обновления значений
- `group` - группа, к которой относится строка (offense/defense/team)
- `setting` - настройка, которая контролирует видимость строки

### Группы строк

Строки объединяются в группы:
- `offense` - наступательная статистика (урон, убийства)
- `defense` - оборонительная статистика (блоки, полученный урон)
- `team` - командная статистика (поднятые предметы, помощь союзникам)

### Система подсчета очков

Мод автоматически вычисляет очки для каждой строки на основе:
- Типа валидации (ASC - больше лучше, DESC - меньше лучше)
- Нормализации значений (приведение к среднему значению 100)
- Суммирования очков из дочерних строк

### История результатов

Мод сохраняет результаты каждой миссии в файлы в папке `%APPDATA%/Fatshark/Darktide/scoreboard_history/`. Каждый файл содержит:
- Информацию о миссии
- Список игроков
- Все строки статистики с данными

## Расширяемость

Мод поддерживает добавление собственных строк статистики из других модов. Для этого нужно:

1. Определить массив `scoreboard_rows` в своем моде
2. Каждая строка должна следовать структуре, описанной в документации

Пример:
```lua
local mod = get_mod("my_mod")
mod.scoreboard_rows = {
    {
        name = "my_stat",
        text = "row_my_stat",
        validation = "ASC",
        iteration = "ADD",
        group = "offense",
        setting = "plugin_my_stat"
    }
}
```
