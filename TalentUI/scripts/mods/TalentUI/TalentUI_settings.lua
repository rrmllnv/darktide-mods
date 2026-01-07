local mod = get_mod("TalentUI")

local SETTINGS = {
	show_abilities_for_bots = false,

	local_cooldown_font_size = 40,

	teammate_ability_vertical_offset = -5,
	teammate_ability_horizontal_offset = 5,
	teammate_ability_orientation = "vertical", -- horizontal, vertical
	teammate_ability_text_alignment = "left", -- left, top, right, bottom, center
	teammate_ability_icon_size = 30,
	teammate_ability_spacing = -3,
	teammate_ability_cooldown_font_size = 12,
	teammate_ability_text_offset = 10,
	
	teammate_ability_position_presets = {
		default = {
			vertical_offset = -5,
			horizontal_offset = 5,
			orientation = "vertical",
			text_alignment = "left",
			icon_size = 30,
			spacing = -3,
			cooldown_font_size = 12,
			text_offset = 10,
		},
		portrait_side = {
			vertical_offset = -8,
			horizontal_offset = -5,
			orientation = "vertical",
			text_alignment = "center",
			icon_size = 40,
			spacing = 0,
			cooldown_font_size = 15,
			text_offset = 10,
			show_aura_icon = false,
		},
		health_below = {
			vertical_offset = 60,
			horizontal_offset = 120,
			orientation = "horizontal",
			text_alignment = "center",
			icon_size = 30,
			spacing = 0,
			cooldown_font_size = 12,
			text_offset = 10,
		},
		coherency_side = {
			vertical_offset = 10,
			horizontal_offset = 330,
			orientation = "horizontal",
			text_alignment = "center",
			icon_size = 45,
			spacing = 0,
			cooldown_font_size = 12,
			text_offset = 10,
		},
	},

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
	teammate_weapon_vertical_offset = 20, -- 20
	teammate_weapon_horizontal_offset = 325, -- 163
	teammate_weapon_orientation = "vertical", -- horizontal, vertical
	teammate_weapon_spacing = 0,
	teammate_weapon_show_ammo = true,
	teammate_weapon_text_alignment = "bottom", -- left, top, right, bottom, center
	teammate_weapon_ammo_font_size = 12,
	teammate_weapon_ammo_text_offset_x = 60,
	teammate_weapon_ammo_text_offset_y = 5,
	
	teammate_weapon_position_presets = {
		coherency_side = {
			icon_width = 70,
			icon_height = 26,
			vertical_offset = 20,
			horizontal_offset = 325,
			orientation = "vertical",
			spacing = 0,
			show_ammo = true,
			text_alignment = "bottom",
			ammo_font_size = 12,
			ammo_text_offset_x = 60,
			ammo_text_offset_y = 5,
		},
		default = {
			icon_width = 70,
			icon_height = 26,
			vertical_offset = 15,
			horizontal_offset = 160,
			orientation = "horizontal",
			spacing = 0,
			show_ammo = true,
			text_alignment = "bottom",
			ammo_font_size = 12,
			ammo_text_offset_x = 60,
			ammo_text_offset_y = 5,
		},
		player_name_above = {
			icon_width = 70,
			icon_height = 26,
			vertical_offset = -25,
			horizontal_offset = 110,
			orientation = "horizontal",
			spacing = 0,
			show_ammo = true,
			text_alignment = "bottom",
			ammo_font_size = 12,
			ammo_text_offset_x = 60,
			ammo_text_offset_y = 5,
		},
		health_below = {
			icon_width = 70,
			icon_height = 26,
			vertical_offset = 56,
			horizontal_offset = 110,
			orientation = "horizontal",
			spacing = 0,
			show_ammo = true,
			text_alignment = "bottom",
			ammo_font_size = 12,
			ammo_text_offset_x = 60,
			ammo_text_offset_y = 5,
		},
	},
}

return SETTINGS
