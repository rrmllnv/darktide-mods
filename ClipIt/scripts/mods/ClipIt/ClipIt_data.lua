local mod = get_mod("ClipIt")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "copy_last_message_key",
				type = "keybind",
				title = "copy_last_message_key",
				tooltip_text = "copy_last_message_key_tooltip",
				default_value = {},
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "copy_last_message",
			},
			{
				setting_id = "messages_count",
				type = "numeric",
				title = "messages_count_title",
				tooltip_text = "messages_count_tooltip",
				default_value = 1,
				range = {1, 20},
			},
			{
				setting_id = "copy_sender_names",
				type = "checkbox",
				title = "copy_sender_names_title",
				tooltip_text = "copy_sender_names_tooltip",
				default_value = true,
			},
		}
	}
}

