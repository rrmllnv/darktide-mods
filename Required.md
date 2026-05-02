## Required Package Management Fixes

Нужно добавить явное `Managers.package:load(..., true)` / `release` для HUD/UI ресурсов, чтобы материалы не выгружались раньше, пока моды ещё рисуют их через HUD widgets, notifications или `UIRenderer`.

### CommunicationCommandWheel
- Добавить package/resource management для собственного `HudElementCommunicationCommandWheel`.
- Удерживать материалы `content/ui/materials/hud/communication_wheel/...`, `weapon_icon_container` и иконки команд из `CommunicationCommandWheel_buttons.lua`.

### EquipmentCommandWheel
- Добавить package/resource management для собственного `HudElementEquipmentWheel`.
- Удерживать `weapon_icon_container`, материалы communication wheel и динамические item/weapon icons.

### MourningstarCommandWheel
- Добавить package/resource management для собственного HUD wheel.
- Удерживать материалы communication wheel и interaction/system icons из `MourningstarCommandWheel_buttons.lua`.

### VoxCommsWheel
- Добавить package/resource management для собственного HUD wheel.
- Удерживать материалы `content/ui/materials/hud/communication_wheel/...` и иконки команд.

### TalentUI
- Добавить package/resource management для HUD widgets, которые мод добавляет в vanilla team panel.
- Удерживать `talent_icon_container`, talent frame/mask/gradient textures и weapon HUD icons.

### RunTimer
- Добавить package/resource management для `HudElementRunTimer`.
- Удерживать HUD background/frame materials: `terminal_background_team_panels`, `terminal_background_weapon`, `weapon_frame`, `faded_line_01`.

### CompassBar
- Добавить package/resource management для материала, который рисуется напрямую через `UIRenderer.draw_texture`.
- Удерживать `content/ui/materials/hud/interactions/icons/enemy`.

### TeamKillTracker
- Добавить package/resource management для `HudElementPlayerStats`.
- Удерживать `terminal_background_team_panels`, `dropshadow_medium`, `inner_shadow_medium`.

### TeamKills
- Привести существующий `Managers.package:load` к текущему lifecycle-паттерну.
- Сохранять load ids и делать `release` в `mod.on_unload`.
