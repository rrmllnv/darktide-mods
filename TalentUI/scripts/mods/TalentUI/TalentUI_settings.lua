local mod = get_mod("TalentUI")

local SETTINGS = {
	show_abilities_for_bots = true,

	cooldown_font_size = 20,
	local_cooldown_font_size = 40,

	icon_position_vertical_offset = -10,
	ability_icon_size = 35,
	ability_spacing = 0,

	
	weapon_icon_width = 128,
	weapon_icon_height = 48,
	weapon_spacing = 128,
	weapon_vertical_offset = -40,

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
