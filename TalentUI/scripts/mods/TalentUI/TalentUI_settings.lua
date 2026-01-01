local mod = get_mod("TalentUI")

local SETTINGS = {
	icon_position_left_shift = 0,
	icon_position_vertical_offset = -20,
	ability_icon_size = 60,
	ability_spacing = 50,
	cooldown_font_size = 20,
	local_cooldown_font_size = 40,
	blitz_icon_position_offset = 40,
	blitz_icon_position_left_shift = 60,
	blitz_icon_position_vertical_offset = 0,
	show_abilities_for_bots = false,
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
