local mod = get_mod("TeamKills")

local killsboard_view_settings = {
    shading_environment = "content/shading_environments/ui/system_menu",
    killsboard_size = {1200, 900},
    killsboard_row_height = 16, -- 20
    killsboard_row_header_height = 22, -- 30
    killsboard_column_width = 110, -- ширина для K или D столбца
    killsboard_column_player_width = 220, -- ширина для пары K+D (2 столбца) - используется для позиционирования
    killsboard_column_player_bg_width = 220, -- ширина фона столбца игрока
    killsboard_column_header_width = 220,
    killsboard_fade_length = 0.1,
    killsboard_font_size = 13, -- размер шрифта для обычных строк
    killsboard_font_size_header = 13, -- размер шрифта для заголовка
}
return settings("KillsboardViewSettings", killsboard_view_settings)

