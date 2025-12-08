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
}
