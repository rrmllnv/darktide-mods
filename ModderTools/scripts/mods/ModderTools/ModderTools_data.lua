local mod = get_mod("ModderTools")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "enable_random_names",
                type = "checkbox",
                default_value = false,
            },
            {
                setting_id = "enable_team_panel",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "enable_nameplate",
                type = "checkbox",
                default_value = true,
            },
        }
    }
}
