local mod = get_mod("MourningstarCommandWheel")

return {
  name = mod:localize("mod_name"),
  description = mod:localize("mod_description"),
  is_togglable = false,
  options = {
    widgets = {
      {
        setting_id      = "open_command_wheel_key",
        type            = "keybind",
        default_value   = {},
        keybind_trigger = "pressed",
        keybind_type    = "function_call",
        function_name   = "command_wheel_pressed",
      },
      {
        setting_id      = "open_command_wheel_key_release",
        type            = "keybind",
        default_value   = {},
        keybind_trigger = "released",
        keybind_type    = "function_call",
        function_name   = "command_wheel_released",
      },
    }
  }
}
