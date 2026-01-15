local mod = get_mod("StimmCountdown")

local color_options = {}

for _, color_name in ipairs(Color.list) do
	table.insert(
		color_options,
		{
			text = color_name,
			value = color_name,
		}
	)
end

table.sort(color_options, function(a, b)
	return a.text < b.text
end)

local function get_color_options()
	return table.clone(color_options)
end

local sound_options = {
	{
		text = "sound_option_hud_heal",
		value = "wwise/events/ui/play_hud_heal_2d",
	},
	{
		text = "sound_option_hud_health_station",
		value = "wwise/events/ui/play_hud_health_station_2d",
	},
	{
		text = "sound_option_hud_coherency_on",
		value = "wwise/events/ui/play_hud_coherency_on",
	},
	{
		text = "sound_option_hud_coherency_off",
		value = "wwise/events/ui/play_hud_coherency_off",
	},
	{
		text = "sound_option_ammo_refill",
		value = "wwise/events/player/play_horde_mode_buff_ammo_refill",
	},
	{
		text = "sound_option_grenade_refill",
		value = "wwise/events/player/play_horde_mode_buff_grenade_refill",
	},
	{
		text = "sound_option_dodge_melee_success",
		value = "wwise/events/player/play_player_dodge_melee_success",
	},
	{
		text = "sound_option_dodge_ranged_success",
		value = "wwise/events/player/play_player_dodge_ranged_success",
	},
	{
		text = "sound_option_indicator_crit",
		value = "wwise/events/weapon/play_indicator_crit",
	},
	{
		text = "sound_option_indicator_weakspot",
		value = "wwise/events/weapon/play_indicator_weakspot",
	},
	{
		text = "sound_option_heal_self_confirmation",
		value = "wwise/events/weapon/play_horde_mode_heal_self_confirmation",
	},
	{
		text = "sound_option_syringe_healed_by_ally",
		value = "wwise/events/player/play_syringe_healed_by_ally",
	},
}

local function get_sound_options()
	return table.clone(sound_options)
end

local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local hud_body_font_settings = UIFontSettings.hud_body or {}

local font_type_options = {
	{
		text = "font_option_machine_medium",
		value = "machine_medium",
	},
	{
		text = "font_option_proxima_nova_bold",
		value = "proxima_nova_bold",
	},
	{
		text = "font_option_proxima_nova_medium",
		value = "proxima_nova_medium",
	},
	{
		text = "font_option_itc_novarese_medium",
		value = "itc_novarese_medium",
	},
	{
		text = "font_option_itc_novarese_bold",
		value = "itc_novarese_bold",
	},
}

local function get_font_type_options()
	return table.clone(font_type_options)
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "display_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_active",
						type = "checkbox",
						default_value = true,
						tooltip = "show_active_tooltip",
					},
					{
						setting_id = "show_cooldown",
						type = "checkbox",
						default_value = true,
						tooltip = "show_cooldown_tooltip",
					},
					{
						setting_id = "show_decimals",
						type = "checkbox",
						default_value = true,
						tooltip = "show_decimals_tooltip",
					},
					{
						setting_id = "show_ready_notification",
						type = "checkbox",
						default_value = true,
						tooltip = "show_ready_notification_tooltip",
					},
				},
			},
			{
				setting_id = "colors_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "ready_timer_color_group",
						type = "group",
						sub_widgets = {
							{
								setting_id = "enable_ready_color_override",
								type = "checkbox",
								default_value = false,
								tooltip = "enable_ready_color_override_tooltip",
								sub_widgets = {
									-- {
									-- 	setting_id = "ready_countdown_color",
									-- 	type = "dropdown",
									-- 	default_value = "ui_hud_green_light",
									-- 	options = get_color_options(),
									-- 	disabled = function()
									-- 		return mod:get("enable_ready_color_override") ~= true
									-- 	end,
									-- },
									{
										setting_id = "ready_icon_color",
										type = "dropdown",
										default_value = "ui_hud_green_light",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_ready_color_override") ~= true
										end,
									},
								},
							},
						},
					},
					{
						setting_id = "active_timer_color_group",
						type = "group",
						sub_widgets = {
							{
								setting_id = "enable_active_color_override",
								type = "checkbox",
								default_value = false,
								tooltip = "enable_active_color_override_tooltip",
								sub_widgets = {
									{
										setting_id = "active_countdown_color",
										type = "dropdown",
										default_value = "ui_terminal_highlight",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_active_color_override") ~= true
										end,
									},
									{
										setting_id = "active_icon_color",
										type = "dropdown",
										default_value = "ui_terminal_highlight",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_active_color_override") ~= true
										end,
									},
								},
							},
						},
					},
					{
						setting_id = "cooldown_timer_color_group",
						type = "group",
						sub_widgets = {
							{
								setting_id = "enable_cooldown_color_override",
								type = "checkbox",
								default_value = false,
								tooltip = "enable_cooldown_color_override_tooltip",
								sub_widgets = {
									{
										setting_id = "cooldown_countdown_color",
										type = "dropdown",
										default_value = "ui_interaction_critical",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_cooldown_color_override") ~= true
										end,
									},
									{
										setting_id = "cooldown_icon_color",
										type = "dropdown",
										default_value = "ui_interaction_critical",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_cooldown_color_override") ~= true
										end,
									},
								},
							},
						},
					},
					{
						setting_id = "notification_color_group",
						type = "group",
						sub_widgets = {
							{
								setting_id = "enable_notification_color_override",
								type = "checkbox",
								default_value = false,
								tooltip = "enable_notification_color_override_tooltip",
								sub_widgets = {
									{
										setting_id = "notification_text_color",
										type = "dropdown",
										default_value = "terminal_text_body",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_notification_color_override") ~= true
										end,
									},
									{
										setting_id = "notification_icon_color",
										type = "dropdown",
										default_value = "terminal_text_body",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_notification_color_override") ~= true
										end,
									},
									{
										setting_id = "notification_background_color",
										type = "dropdown",
										default_value = "terminal_grid_background",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_notification_color_override") ~= true
										end,
									},
									{
										setting_id = "notification_line_color",
										type = "dropdown",
										default_value = "terminal_corner_selected",
										options = get_color_options(),
										disabled = function()
											return mod:get("enable_notification_color_override") ~= true
										end,
									},
								},
							},
						},
					},
				},
			},
			{
				setting_id = "fonts_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "font_type",
						type = "dropdown",
						default_value = "machine_medium",
						options = get_font_type_options(),
					},
					{
						setting_id = "font_size",
						type = "numeric",
						default_value = 30,
						range = {20, 50},
					},
				},
			},
			{
				setting_id = "sounds_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "enable_ready_sound",
						type = "checkbox",
						default_value = false,
						tooltip = "enable_ready_sound_tooltip",
					},
					{
					setting_id = "ready_sound_event",
					type = "dropdown",
					default_value = "wwise/events/ui/play_hud_heal_2d",
						options = get_sound_options(),
						disabled = function()
							return mod:get("enable_ready_sound") ~= true
						end,
					},
				},
			},
			{
				setting_id = "system_settings_group",
				type = "group",
				sub_widgets = {
					{
						setting_id = "reset_color_settings",
						type = "dropdown",
						default_value = 0,
						options = {
							{ text = "", value = 0 },
							{ text = "reset_color_settings", value = 1 },
						},
					},
					{
						setting_id = "reset_font_settings",
						type = "dropdown",
						default_value = 0,
						options = {
							{ text = "", value = 0 },
							{ text = "reset_font_settings", value = 1 },
						},
					},
					{
						setting_id = "reset_sound_settings",
						type = "dropdown",
						default_value = 0,
						options = {
							{ text = "", value = 0 },
							{ text = "reset_sound_settings", value = 1 },
						},
					},
				},
			},
		},
	},
}
