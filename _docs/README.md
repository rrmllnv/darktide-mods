# TeamKillTracker

A mod for Warhammer 40,000: Darktide that tracks team kills in real time.

## Description

TeamKillTracker keeps a permanent HUD that displays the total team score and a descending list of players with their kills, total damage, and last-hit damage (the player with the most kills stays on top). You can switch the display to "all stats", "only my stats", "team total only", or "everyone except me", and customize colors independently for kills, total damage, and last-hit damage. Additionally, you can adjust the font size (15-30px), toggle background visibility, and control the opacity (0-100%) of the entire HUD element for a fully personalized experience.

## Features

- **Real-time**: Counter updates instantly with each kill
- **Team statistics**: Shows results for all team players
- **Automatic reset**: Counters reset when starting a new mission
- **Hub hiding**: Interface automatically hides in Mourningstar
- **Minimal design**: Compact counter doesn't clutter the screen

## Installation

1. Make sure you have [Darktide Mod Framework](https://github.com/danreeves/dt-mod-framework) installed
2. Download the TeamKillTracker mod
3. Place the `TeamKillTracker` folder in your Darktide mods directory
4. Launch the game and activate the mod in settings

## Interface

The counter displays in format:
```
TEAM KILLS: 125 (56,789) [12,345]
PlayerName1: 45 (15,432) [1,234]
PlayerName2: 38 (12,345) [987]
PlayerName3: 27 (9,876) [654]
PlayerName4: 15 (4,321) [543]
```

**Position**: Bottom left corner of screen  
**Font**: Machine Medium (configurable size: 15-30px)  
**Color**: White with shadow (customizable colors and opacity)

## Technical Information

### Main Components

- `TeamKillTracker.lua` - Main kill counting logic
- `HudElementPlayerStats.lua` - UI element for displaying statistics
- `TeamKillTracker_data.lua` - Mod settings
- `TeamKillTracker_localization.lua` - Localization (EN/RU)

### How It Works

The mod uses the `AttackReportManager.add_attack_result` hook to track attack results. When receiving a "died" result for a minion unit, the mod increases the kill counter for the corresponding player.

### Compatibility

- **Game**: Warhammer 40,000: Darktide
- **Framework**: Darktide Mod Framework
- **Version**: Current game version
- **Conflicts**: No known conflicts with other mods

## Settings

The mod supports the following settings:
- **HUD Counter Mode**: Choose what to display (Kills + Damage, Kills only, Damage only, etc.)
- **Show TEAM KILLS line**: Toggle visibility of the team total line (Show / Hide)
- **Player lines display**: Control what player lines are shown (All players / Only me / Everyone except me / Hide all players)
- **Font Size**: Adjustable slider from 15 to 30 pixels (default: 16)
- **Show Background**: Toggle background visibility (Show / Hide)
- **Opacity**: Control transparency of the entire HUD element (0-100%, default: 100)
- **Color Customization**: Separate color options for kills, damage, and last-hit damage
- Enable/disable mod
- Ability to reload without game restart

## Support

If you encounter problems:
1. Make sure Darktide Mod Framework is updated to the latest version
2. Check that the mod is properly installed in the mods folder
3. Restart the game after installation

## Versions
1.9.0

## Changelogs
- 1.9.0 – separated TEAM KILLS line and player lines display controls: added independent "Show TEAM KILLS line" toggle, redesigned "Player lines display" setting with "Hide all players" option. HUD now fully hides when no lines are visible.
- 1.8.0 – added font size slider (15-30), background visibility toggle, and opacity slider (0-100) for HUD element transparency.
- 1.7.0 – added "everyone except me" display mode and expanded HUD color presets.
- 1.6.1 – last-hit damage now rounds up to the nearest integer.
- 1.6.0 – new display modes (all / only me / team total), last-damage color option, dynamic HUD height and layout tweaks.
- 1.5.0 – added color customization for kills and damage display (8 color presets available).
- 1.4.0 – fixed kill counting and damage calculation.
- 1.3.0 – added HUD Counter Mode setting (dropdown: Kills (Damage), Kills only, Damage only).
- 1.2.0 – added damage tracking and HUD output in "kills (damage)" format; switched to account_id keys; prevented double-counting on death events.
- 1.1.0 – added settings to hide the team total line and per-user lines; prevented counter reset on settings change; updated localization.
- 1.0.0 – first version of the mod


### Current Version
- Tracking kills and damage for all team players (HUD shows kills (damage))
- Automatic hiding in hub
- Sorting by kill count
- Support for Russian and English localization
- Customizable font size (15-30px)
- Background visibility toggle
- Opacity control (0-100%) for HUD element

## License

This mod is distributed as is. Use at your own risk.

---

*Mod created to enhance the gaming experience in Warhammer 40,000: Darktide*

---

# TeamKillTracker (RU)

Мод для Warhammer 40,000: Darktide, который отслеживает убийства команды в реальном времени.

## Описание

TeamKillTracker поддерживает постоянный HUD, который отображает общий счёт команды и нисходящий список игроков с их убийствами, общим уроном и уроном последнего удара (игрок с наибольшим количеством убийств остаётся сверху). Вы можете переключить отображение на «все строки», «только моя строка», «только общий счёт» или «все, кроме меня», а также настроить цвета независимо для убийств, общего урона и урона последнего удара. Дополнительно вы можете настроить размер шрифта (15-30px), переключить видимость фона и управлять прозрачностью (0-100%) всего HUD элемента для полностью персонализированного опыта.

## Особенности

- **Реальное время**: Счетчик обновляется мгновенно при каждом убийстве
- **Командная статистика**: Показывает результаты всех игроков в команде
- **Автоматический сброс**: Счетчики обнуляются при начале новой миссии
- **Скрытие в хабе**: Интерфейс автоматически скрывается в Mourningstar
- **Минимальный дизайн**: Компактный счетчик не загромождает экран

## Установка

1. Убедитесь, что у вас установлен [Darktide Mod Framework](https://github.com/danreeves/dt-mod-framework)
2. Скачайте мод TeamKillTracker
3. Поместите папку `TeamKillTracker` в директорию модов Darktide
4. Запустите игру и активируйте мод в настройках

## Интерфейс

Счетчик отображается в формате:
```
TEAM KILLS: 125 (56,789) [12,345]
PlayerName1: 45 (15,432) [1,234]
PlayerName2: 38 (12,345) [987]
PlayerName3: 27 (9,876) [654]
PlayerName4: 15 (4,321) [543]
```

**Позиция**: Левый нижний угол экрана  
**Шрифт**: Machine Medium (настраиваемый размер: 15-30px)  
**Цвет**: Белый с тенью (настраиваемые цвета и прозрачность)

## Техническая информация

### Основные компоненты

- `TeamKillTracker.lua` - Основная логика подсчета убийств
- `HudElementPlayerStats.lua` - UI элемент для отображения статистики
- `TeamKillTracker_data.lua` - Настройки мода
- `TeamKillTracker_localization.lua` - Локализация (EN/RU)

### Как работает

Мод использует хук `AttackReportManager.add_attack_result` для отслеживания результатов атак. При получении результата "died" для юнита-миньона, мод увеличивает счетчик убийств для соответствующего игрока.

### Совместимость

- **Игра**: Warhammer 40,000: Darktide
- **Фреймворк**: Darktide Mod Framework
- **Версия**: Актуальная версия игры
- **Конфликты**: Нет известных конфликтов с другими модами

## Настройки

Мод поддерживает следующие настройки:
- **Режим счетчика в HUD**: Выбор отображаемой информации (Убийства + Урон, Только убийства, Только урон и т.д.)
- **Показывать строку TEAM KILLS**: Переключатель видимости строки общего счёта (Показать / Скрыть)
- **Отображение строк игроков**: Управление отображением строк игроков (Все игроки / Только я / Все, кроме меня / Скрыть всех игроков)
- **Размер шрифта**: Настраиваемый слайдер от 15 до 30 пикселей (по умолчанию: 16)
- **Показывать фон**: Переключатель видимости фона (Показать / Скрыть)
- **Прозрачность**: Управление прозрачностью всего HUD элемента (0-100%, по умолчанию: 100)
- **Настройка цветов**: Отдельные опции цвета для убийств, урона и последнего удара
- Включение/выключение мода
- Возможность перезагрузки без перезапуска игры

## Поддержка

При возникновении проблем:
1. Убедитесь, что Darktide Mod Framework обновлен до последней версии
2. Проверьте, что мод правильно установлен в папку модов
3. Перезапустите игру после установки

## Версии
1.9.0

## Журнал изменений
- 1.9.0 — разделено управление строкой TEAM KILLS и строками игроков: добавлен независимый переключатель «Показывать строку TEAM KILLS», переработана настройка «Отображение строк игроков» с опцией «Скрыть всех игроков». HUD теперь полностью скрывается при отсутствии видимых строк.
- 1.8.0 — добавлен слайдер размера шрифта (15-30), переключатель видимости фона и слайдер прозрачности (0-100) для HUD элемента.
- 1.7.0 — добавлен режим отображения «все, кроме меня» и расширен набор цветовых пресетов HUD.
- 1.6.1 — последний удар округляется вверх до ближайшего целого.
- 1.6.0 — новые режимы отображения (всё / только я / только общий счёт), отдельный цвет последнего урона и адаптивная высота HUD.
- 1.5.0 — добавлена настройка цвета для отображения убийств и урона (доступно 8 готовых цветов).
- 1.4.0 — исправлен подсчёт убийств и расчёт урона.
- 1.3.0 — добавлена настройка «Режим счётчика в HUD» (выпадающий список: Убийства (Урон), Только убийства, Только урон).
- 1.2.0 — добавлен подсчёт урона и вывод в HUD в формате «киллы (урон)»; переход на ключи account_id; защита от двойного учёта при смерти.
- 1.1.0 — добавлены настройки скрытия строки Team Kills и строк пользователей; предотвращён сброс счётчика при смене настроек; обновлена локализация.
- 1.0.0 — первая версия мода

### Текущая версия
- Отслеживание убийств и урона всех игроков команды (HUD показывает «киллы (урон)»)
- Автоматическое скрытие в хабе
- Сортировка по количеству убийств
- Поддержка русской и английской локализации
- Настраиваемый размер шрифта (15-30px)
- Переключатель видимости фона
- Управление прозрачностью HUD элемента (0-100%)

## Лицензия

Данный мод распространяется как есть. Используйте на свой риск.

---

*Мод создан для улучшения игрового опыта в Warhammer 40,000: Darktide*