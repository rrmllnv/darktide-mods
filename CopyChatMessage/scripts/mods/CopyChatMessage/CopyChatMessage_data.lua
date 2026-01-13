local mod = get_mod("CopyChatMessage")

return {
	name = mod:localize("i18n_mod_name"),
	description = mod:localize("i18n_mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "copy_last_message_key",
				type = "keybind",
				title = "i18n_copy_last_message_key",
				tooltip_text = "i18n_copy_last_message_key_tooltip",
				default_value = {},
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "copy_last_message",
			},
			{
				setting_id = "messages_count",
				type = "numeric",
				title = "i18n_messages_count_title",
				tooltip_text = "i18n_messages_count_tooltip",
				default_value = 5,
				range = {1, 40},
			},
			{
				setting_id = "copy_sender_names",
				type = "checkbox",
				title = "i18n_copy_sender_names_title",
				tooltip_text = "i18n_copy_sender_names_tooltip",
				default_value = true,
			},
		}
	}
}
