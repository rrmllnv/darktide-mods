local mod = get_mod("QuickDeploy")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "keybind_deploy_pocketable",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "deploy_pocketable",
			},
			{
				setting_id = "keybind_deploy_pocketable_small",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "deploy_pocketable_small",
			},
			{
				setting_id = "keybind_inject_ally_small",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "inject_ally_small",
			},
		},
	},
}

