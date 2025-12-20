# Mourningstar Command Wheel - Документация

## Общее описание

**Mourningstar Command Wheel** - это мод для Warhammer 40,000: Darktide, который добавляет радиальное меню для быстрого доступа ко всем меню и функциям хаба. Мод позволяет открывать различные вью (views) через удобное колесо команд, которое появляется при удержании назначенной клавиши.

## Основные возможности

- **Радиальное меню** - удобное колесо команд с кнопками для всех основных функций хаба
- **Настраиваемый порядок кнопок** - возможность перетаскивать кнопки для изменения их порядка
- **Динамическая замена кнопок** - автоматическая замена кнопки "training_grounds" на "exit_psychanium" при входе в псайкинариум
- **Поддержка клавиатуры и геймпада** - работает как с клавиатурой/мышью, так и с геймпадом
- **Настраиваемые параметры** - множество настроек для визуального оформления колеса

## Структура мода

Мод состоит из следующих файлов:

1. **MourningstarCommandWheel.mod** - файл регистрации мода
2. **MourningstarCommandWheel.lua** - основной файл мода с логикой и хуками
3. **MourningstarCommandWheel_data.lua** - данные мода (настройки, опции)
4. **MourningstarCommandWheel_localization.lua** - локализация мода
5. **command_wheel_settings.lua** - настройки визуального оформления колеса
6. **command_wheel_definitions.lua** - определения UI виджетов и scenegraph
7. **HudElementCommandWheel.lua** - HUD элемент колеса команд

## Где работает мод

Мод активен в следующих локациях:
- `hub` - основной хаб
- `shooting_range` - тир
- `training_grounds` - псайкинариум

## Доступные кнопки

Мод поддерживает следующие кнопки:

- `barber` - Парикмахерская
- `contracts` - Контракты
- `crafting` - Крафтинг
- `credits_vendor` - Торговец кредитами
- `mission_board` - Доска миссий
- `premium_store` - Премиум магазин
- `training_grounds` - Псайкинариум (заменяется на `exit_psychanium` в псайкинариуме)
- `exit_psychanium` - Выход из псайкинариума (появляется только в псайкинариуме)
- `social` - Социальное меню
- `commissary` - Комиссариат
- `penance` - Достижения
- `inventory` - Инвентарь
- `change_character` - Смена персонажа
- `havoc` - Хаос

## Настройки

### Клавиша открытия колеса

В настройках мода можно назначить клавишу для открытия колеса команд. По умолчанию клавиша не назначена.

### Порядок кнопок

Порядок кнопок можно изменить, перетаскивая их правой кнопкой мыши при открытом колесе. Новый порядок сохраняется автоматически.

## Технические детали

### Архитектура

Мод использует систему HUD элементов игры для отображения колеса. Основной класс `HudElementCommandWheel` наследуется от `HudElementBase` и интегрируется в систему HUD через хук `UIHud.init`.

### Обработка ввода

Мод обрабатывает ввод через систему keybind DMF (Darktide Mod Framework). При нажатии назначенной клавиши создается функция проверки состояния клавиши, которая учитывает enablers и disablers.

### Управление курсором

При открытии колеса курсор автоматически перемещается в центр экрана. При закрытии курсор возвращается в исходное положение.

### Анимации

Колесо использует плавные анимации для появления и исчезновения. Скорость анимации настраивается через `CommandWheelSettings.anim_speed`.

## Дополнительная документация

Подробная документация по каждому файлу:

- [MourningstarCommandWheel.mod](MourningstarCommandWheel.mod.md) - Файл регистрации мода
- [MourningstarCommandWheel.lua](MourningstarCommandWheel.lua.md) - Основной файл мода
- [MourningstarCommandWheel_data.lua](MourningstarCommandWheel_data.lua.md) - Данные мода
- [MourningstarCommandWheel_localization.lua](MourningstarCommandWheel_localization.lua.md) - Локализация
- [command_wheel_settings.lua](command_wheel_settings.lua.md) - Настройки колеса
- [command_wheel_definitions.lua](command_wheel_definitions.lua.md) - Определения UI
- [HudElementCommandWheel.lua](HudElementCommandWheel.lua.md) - HUD элемент

