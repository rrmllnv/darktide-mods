local mod = get_mod("DivisionHUD")

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

UIHudSettings.element_draw_layers["HudElementDivisionHUD"] = 301

mod.divisionhud_hud_elements = {
	{
		filename = "DivisionHUD/scripts/mods/DivisionHUD/hud/hud_element_division_hud",
		class_name = "HudElementDivisionHUD",
		visibility_groups = {
			"alive",
		},
	},
}

for _, hud_element in ipairs(mod.divisionhud_hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/hud/definitions/main_hud_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/hud/data/slot_data")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/hud/definitions/alerts_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/hud/definitions/stamina_dodge_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/hud/widgets/stamina_dodge")

return mod
