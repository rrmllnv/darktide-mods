## Необходимые исправления управления пакетами

Нужно добавить явное `Managers.package:load(..., true)` / `release` для HUD/UI ресурсов, чтобы материалы не выгружались раньше, пока моды ещё рисуют их через HUD widgets, notifications или `UIRenderer`.

## Уже добавлено

### StimmCountdown
- Добавлено управление пакетом для иконки уведомления.
- Удерживается `content/ui/materials/icons/pocketables/hud/syringe_broker`.

### SquadHud
- Добавлено управление HUD-пакетами для иконок способностей и предметов.
- Удерживаются `team_player_panel`, `player_ability`, `player_weapon`.

### DivisionHUD
- Добавлено управление HUD-пакетами и отдельными HUD/UI-материалами.
- Удерживаются пакеты `team_player_panel`, `player_ability`, `player_weapon`, `player_buffs`, `blocking`, `dodge_counter`.
- Удерживаются статические материалы для иконки способности, рядов баффов, иконок слотов, дебаффов врага, proximity-иконок, stamina/dodge-индикаторов и HUD-фонов.

## Ещё нужно сделать

### CommunicationCommandWheel
- Добавить управление пакетами/ресурсами для собственного `HudElementCommunicationCommandWheel`.
- Удерживать материалы `content/ui/materials/hud/communication_wheel/...`, `weapon_icon_container` и иконки команд из `CommunicationCommandWheel_buttons.lua`.

### EquipmentCommandWheel
- Добавить управление пакетами/ресурсами для собственного `HudElementEquipmentWheel`.
- Удерживать `weapon_icon_container`, материалы communication wheel и динамические иконки предметов/оружия.

### MourningstarCommandWheel
- Добавить управление пакетами/ресурсами для собственного HUD wheel.
- Удерживать материалы communication wheel и interaction/system-иконки из `MourningstarCommandWheel_buttons.lua`.

### VoxCommsWheel
- Добавить управление пакетами/ресурсами для собственного HUD wheel.
- Удерживать материалы `content/ui/materials/hud/communication_wheel/...` и иконки команд.

### TalentUI
- Добавить управление пакетами/ресурсами для HUD widgets, которые мод добавляет в vanilla team panel.
- Удерживать `talent_icon_container`, talent frame/mask/gradient textures и weapon HUD-иконки.

### RunTimer
- Добавить управление пакетами/ресурсами для `HudElementRunTimer`.
- Удерживать HUD background/frame materials: `terminal_background_team_panels`, `terminal_background_weapon`, `weapon_frame`, `faded_line_01`.

### CompassBar
- Добавить управление пакетами/ресурсами для материала, который рисуется напрямую через `UIRenderer.draw_texture`.
- Удерживать `content/ui/materials/hud/interactions/icons/enemy`.

### TeamKillTracker
- Добавить управление пакетами/ресурсами для `HudElementPlayerStats`.
- Удерживать `terminal_background_team_panels`, `dropshadow_medium`, `inner_shadow_medium`.

### TeamKills
- Привести существующий `Managers.package:load` к текущему паттерну жизненного цикла.
- Сохранять load ids и делать `release` в `mod.on_unload`.
