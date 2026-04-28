local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local S = {}

S.max_players = 4
S.panel_height = 38
S.panel_gap = 6

S.ability_icon_size = 30
S.ability_icon_frame_size = 48
S.ability_icon_frame_padding = math.floor((S.ability_icon_frame_size - S.ability_icon_size) * 0.5)
S.ability_icon_x = 0
S.ability_block_width = 42
S.ability_icon_material = "content/ui/materials/icons/talents/hud/combat_container"
S.ability_icon_frame_material = "content/ui/materials/icons/talents/hud/combat_frame_inner"
S.ability_icon_glow_material = "content/ui/materials/effects/hud/combat_talent_glow"

S.icon_column_width = 28
S.inner_padding = 8
S.class_icon_x = S.ability_block_width + S.inner_padding
S.class_status_icon_size = 20
S.class_status_icon_x = S.class_icon_x + math.floor((S.icon_column_width - S.class_status_icon_size) * 0.5)
S.class_status_icon_y = 1
S.text_column_x = S.class_icon_x + S.icon_column_width + 2

S.bar_left = S.class_icon_x
S.health_bar_y = 24
S.toughness_bar_y = 31
S.bar_height = 6
S.toughness_bar_bottom_y = S.toughness_bar_y + S.bar_height
S.bar_active_height = 8
S.bar_inactive_height = 4
S.bar_gap = 1
S.active_bar_visible_duration = 5

S.inventory_icon_size = 16
S.inventory_icon_gap = 4
S.inventory_value_max_width = 110
S.previous_inventory_block_width = S.inventory_icon_size * 2 + S.inventory_icon_gap
S.inventory_block_width = S.inventory_value_max_width + S.inventory_icon_gap + S.inventory_icon_size * 4 + S.inventory_icon_gap * 3
S.name_extra_width = 40
S.panel_width = 282 + S.inventory_block_width - S.previous_inventory_block_width + S.name_extra_width
S.inventory_block_x = S.panel_width - S.inner_padding - S.inventory_block_width
S.inventory_icon_y = S.toughness_bar_bottom_y - S.inventory_icon_size
S.grenade_icon_x = S.inventory_block_x + S.inventory_value_max_width + S.inventory_icon_gap
S.ammo_icon_x = S.grenade_icon_x + S.inventory_icon_size + S.inventory_icon_gap
S.inventory_icon_x = S.ammo_icon_x + S.inventory_icon_size + S.inventory_icon_gap
S.inventory_small_icon_x = S.inventory_icon_x + S.inventory_icon_size + S.inventory_icon_gap
S.bar_width = S.inventory_block_x - S.inventory_icon_gap - S.bar_left
S.inventory_value = {
	font_size = 14,
	height = S.inventory_icon_size,
	gap = S.inventory_icon_gap,
	text_width = S.inventory_value_max_width,
	x = S.inventory_block_x,
	y = S.inventory_icon_y,
}

S.ability_icon_y = S.toughness_bar_bottom_y - S.ability_icon_size
S.ability_icon_frame_y = S.ability_icon_y - S.ability_icon_frame_padding
S.ability_icon_frame_x = S.ability_icon_x - S.ability_icon_frame_padding
S.health_segment_gap = 3
S.default_revive_duration = 3
S.root_height = S.panel_height * S.max_players + S.panel_gap * (S.max_players - 1)

S.name_x = S.text_column_x
S.name_y = 0
S.name_height = 22
S.name_right_x = S.inventory_block_x - S.inventory_icon_gap
S.relation_status_right_padding = 4
S.relation_status_left_padding = 2
S.relation_status_y = 0
S.relation_status_width = 42
S.relation_status_x = S.name_right_x - S.relation_status_right_padding - S.relation_status_width
S.relation_status_height = 20
S.name_width = S.relation_status_x - S.name_x - S.relation_status_left_padding
S.status_background_x = S.class_icon_x
S.status_background_y = 1
S.status_background_width = S.name_right_x - S.status_background_x
S.status_background_height = 20

S.name_marquee_start_pause = 0.6
S.name_marquee_move_duration = 1.6
S.name_marquee_end_pause = 0.9
S.name_marquee_return_duration = 1.35
S.name_marquee_total_duration = S.name_marquee_start_pause + S.name_marquee_move_duration + S.name_marquee_end_pause + S.name_marquee_return_duration

S.coherency_border_width = 3
S.coherency_border_x = S.status_background_x + S.status_background_width - S.coherency_border_width
S.coherency_border_y = S.status_background_y
S.coherency_border_height = S.status_background_height

S.color_text_default = UIHudSettings.color_tint_main_1
S.color_toughness = UIHudSettings.color_tint_6
S.color_toughness_overshield = UIHudSettings.color_tint_10
S.color_health = UIHudSettings.color_tint_main_1
S.color_health_critical = UIHudSettings.color_tint_alert_2
S.color_rescue_available = UIHudSettings.player_status_colors and UIHudSettings.player_status_colors.hogtied or UIHudSettings.color_tint_main_1
S.color_revive = {
	255,
	75,
	220,
	120,
}
S.color_ability_icon = UIHudSettings.color_tint_main_2
S.color_ability_frame = UIHudSettings.color_tint_main_2
S.color_ability_glow = UIHudSettings.color_tint_main_1
S.color_ability_ready_glow = UIHudSettings.color_tint_main_1
S.color_ability_cooldown_icon = UIHudSettings.color_tint_main_3
S.color_ability_cooldown_frame = UIHudSettings.color_tint_main_3
S.color_ability_cooldown_glow = {
	0,
	255,
	255,
	255,
}
S.color_status_background_default = {
	38,
	255,
	255,
	255,
}
S.color_status_background_critical = {
	90,
	255,
	40,
	40,
}
S.color_coherency_border_in = {
	220,
	75,
	220,
	120,
}
S.color_coherency_border_out = {
	220,
	255,
	40,
	40,
}
S.color_ammo_not_in_use = UIHudSettings.color_tint_ammo_not_in_use
S.color_ammo_high = UIHudSettings.color_tint_ammo_high
S.color_ammo_medium = UIHudSettings.color_tint_ammo_medium
S.color_ammo_low = UIHudSettings.color_tint_ammo_low
S.color_ammo_full = UIHudSettings.color_tint_ammo_full
S.color_corruption = {
	210,
	130,
	70,
	180,
}
S.color_stimm_by_template = {
	syringe_ability_boost_pocketable = {
		255,
		230,
		192,
		13,
	},
	syringe_broker_pocketable = {
		255,
		208,
		69,
		255,
	},
	syringe_corruption_pocketable = {
		255,
		38,
		205,
		26,
	},
	syringe_power_boost_pocketable = {
		255,
		205,
		51,
		26,
	},
	syringe_speed_boost_pocketable = {
		255,
		0,
		127,
		218,
	},
}

return S
