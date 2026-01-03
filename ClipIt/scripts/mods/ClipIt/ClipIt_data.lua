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
				range = {1, 40},
			},
			{
				setting_id = "copy_sender_names",
				type = "checkbox",
				title = "copy_sender_names_title",
				tooltip_text = "copy_sender_names_tooltip",
				default_value = true,
			},
		{
			setting_id = "auto_block",
			type = "checkbox",
			title = "auto_block_title",
			tooltip_text = "auto_block_tooltip",
			default_value = false,
		},
		{
			setting_id = "fade_audio_unfocused",
			type = "checkbox",
			title = "fade_audio_unfocused_title",
			tooltip_text = "fade_audio_unfocused_tooltip",
			default_value = false,
		},
		{
			setting_id = "fade_audio_channel",
			type = "dropdown",
			title = "fade_audio_channel_title",
			tooltip_text = "fade_audio_channel_tooltip",
			default_value = 1,
			options = {
				{text = "fade_audio_channel_master", value = 1},
				{text = "fade_audio_channel_sfx", value = 2},
				{text = "fade_audio_channel_music", value = 3},
			},
		},
		{
			setting_id = "fade_audio_volume",
			type = "numeric",
			title = "fade_audio_volume_title",
			tooltip_text = "fade_audio_volume_tooltip",
			default_value = 20,
			range = {0, 100},
		},
		}
	}
}

