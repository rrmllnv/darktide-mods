local mod = get_mod("TalentUI")

local SETTINGS = {
	show_abilities_for_bots = true,

	cooldown_font_size = 15,
	local_cooldown_font_size = 40,

	icon_vertical_offset = -10,
	icon_horizontal_offset = 0,
	ability_icon_size = 33,
	ability_spacing = 0,

	
	weapon_icon_width = 70, -- 96,
	weapon_icon_height = 26, -- 36,
	weapon_spacing = 60,
	weapon_horizontal_offset = 115,
	weapon_vertical_offset = 16,

	icon_material_settings = {
		ability = {
			active = {intensity = 0, saturation = 1},
			on_cooldown = {intensity = -0.5, saturation = 0.5},
			has_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.5, saturation = 0.5},
		},
		blitz = {
			active = {intensity = 0, saturation = 1},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			on_cooldown = {intensity = 0, saturation = 1},
			has_charges_cooldown = {intensity = 0, saturation = 1},
			inactive = {intensity = -0.5, saturation = 0.5},
		},
		aura = {
			active = {intensity = 0, saturation = 1},
			on_cooldown = {intensity = -0.5, saturation = 0.5},
			has_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.5, saturation = 0.5},
		},
	},
}

return SETTINGS
