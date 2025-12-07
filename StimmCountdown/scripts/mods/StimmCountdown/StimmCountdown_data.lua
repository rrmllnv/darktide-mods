local mod = get_mod("StimmCountdown")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
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
}
