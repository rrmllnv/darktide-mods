local mod = get_mod("ThirdPersonLight")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = false,

    options = {
        widgets = {
            {
                setting_id = "general_group",
                type = "group",
                text = mod:localize("general_settings"),
                sub_widgets = {
                    {
                        setting_id = "enable_mod",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "mod_toggle_key",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_mod",
                    },
                    {
                        setting_id = "only_dark_missions",
                        type = "checkbox",
                        default_value = true,
                    },
                },
            },

            {
                setting_id = "player_light_group",
                type = "group",
                text = mod:localize("player_light_settings"),
                sub_widgets = {
                    {
                        setting_id = "enable_player_light",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "player_light_toggle_key",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_player_light",
                    },
                    {
                        setting_id = "flashlight_mode",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "flashlight_toggle_key",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_flashlight",
                    },
                    {
                        setting_id = "flicker_mode",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "light_radius",
                        type = "numeric",
                        default_value = 10,
                        range = {10, 100},
                        unit = "m",
                    },
                    {
                        setting_id = "light_intensity",
                        type = "numeric",
                        default_value = 20,
                        range = {10, 300},
                    },
                    {
                        setting_id = "light_color_r",
                        type = "numeric",
                        default_value = 255,
                        range = {0, 255},
                        interval = 1,
                    },
                    {
                        setting_id = "light_color_g",
                        type = "numeric",
                        default_value = 255,
                        range = {0, 255},
                        interval = 1,
                    },
                    {
                        setting_id = "light_color_b",
                        type = "numeric",
                        default_value = 255,
                        range = {0, 255},
                        interval = 1,
                    },
                },
            },
        },
    },
}
