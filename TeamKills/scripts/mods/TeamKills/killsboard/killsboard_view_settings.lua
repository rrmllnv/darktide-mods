local mod = get_mod("TeamKills")

local killsboard_view_settings = {
    shading_environment = "content/shading_environments/ui/system_menu",
    killsboard_size = {900, 900},
    killsboard_row_height = 20,
    killsboard_row_header_height = 30,
    killsboard_column_width = 65, -- ширина для K или D столбца
    killsboard_column_player_width = 130, -- ширина для пары K+D (2 столбца)
    killsboard_column_header_width = 300,
    killsboard_fade_length = 0.1,
}
return settings("KillsboardViewSettings", killsboard_view_settings)

