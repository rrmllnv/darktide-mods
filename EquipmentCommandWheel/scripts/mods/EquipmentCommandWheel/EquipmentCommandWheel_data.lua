local mod = get_mod("EquipmentCommandWheel")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "equipment_wheel_group",
				type = "group",
				title = "equipment_wheel_group",
				sub_widgets = {
					{
						setting_id = "open_equipment_wheel_key",
						type = "keybind",
						default_value = {},
						title = "open_equipment_wheel_key",
						keybind_trigger = "held",
						keybind_type = "function_call",
						function_name = "equipment_wheel_held",
					},
				},
			},
		},
	},
}
