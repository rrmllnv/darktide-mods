local mod = get_mod("DivisionHUD")

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

UIHudSettings.element_draw_layers["HudElementDivisionHUD"] = 301

mod:register_hud_element({
	filename = "DivisionHUD/scripts/mods/DivisionHUD/hud/hud_element_division_hud",
	class_name = "HudElementDivisionHUD",
	use_hud_scale = true,
	visibility_groups = {
		"alive",
	},
})

return mod
