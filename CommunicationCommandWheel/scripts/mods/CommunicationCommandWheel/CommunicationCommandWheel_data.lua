local mod = get_mod("CommunicationCommandWheel")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "communication_command_wheel_group",
				type = "group",
				title = "communication_command_wheel_group",
				sub_widgets = {
					{
						setting_id = "open_communication_command_wheel_key",
						type = "keybind",
						default_value = {},
						title = "open_communication_command_wheel_key",
						tooltip_text = "open_communication_command_wheel_key_description",
						keybind_trigger = "held",
						keybind_type = "function_call",
						function_name = "communication_command_wheel_held",
					},
					{
						setting_id = "communication_wheel_open_hold_delay_sec",
						type = "dropdown",
						default_value = 100,
						title = "communication_wheel_open_hold_delay_sec",
						tooltip_text = "communication_wheel_open_hold_delay_description",
						options = {
							{
								text = "communication_wheel_hold_0_1s",
								value = 100,
							},
							{
								text = "communication_wheel_hold_0_15s",
								value = 150,
							},
							{
								text = "communication_wheel_hold_0_2s",
								value = 200,
							},
							{
								text = "communication_wheel_hold_0_25s",
								value = 250,
							},
							{
								text = "communication_wheel_hold_0_5s",
								value = 500,
							},
							{
								text = "communication_wheel_hold_0_75s",
								value = 750,
							},
							{
								text = "communication_wheel_hold_1s",
								value = 1000,
							},
						},
					},
				},
			},
		},
	},
}
