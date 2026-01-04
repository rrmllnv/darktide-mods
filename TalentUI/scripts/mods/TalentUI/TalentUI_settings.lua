local mod = get_mod("TalentUI")

local SETTINGS = {
	show_abilities_for_bots = true,

	local_cooldown_font_size = 40,

	teammate_ability_vertical_offset = -10,
	teammate_ability_horizontal_offset = 0,
	teammate_ability_orientation = "vertical", -- horizontal, vertical
	teammate_ability_text_alignment = "left", -- left, top, right, bottom, center
	teammate_ability_icon_size = 33,
	teammate_ability_spacing = 0,
	teammate_ability_cooldown_font_size = 15,
	teammate_ability_text_offset = 10,

	teammate_ability_icon_material_settings = {
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

	teammate_weapon_icon_width = 70, -- 96,
	teammate_weapon_icon_height = 26, -- 36,
	teammate_weapon_spacing = 0,
	teammate_weapon_horizontal_offset = 163,
	teammate_weapon_vertical_offset = 16,
	teammate_weapon_orientation = "horizontal", -- horizontal, vertical
}

return SETTINGS
