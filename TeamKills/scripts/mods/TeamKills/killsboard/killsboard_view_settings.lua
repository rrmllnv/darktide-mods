local mod = get_mod("TeamKills")

local killsboard_view_settings = {
    shading_environment = "content/shading_environments/ui/system_menu",
    killsboard_size = {1060, 900},
    killsboard_row_height = 16, -- 20
    killsboard_row_header_height = 22, -- 30
    killsboard_column_kills_width = 60, -- ширина для столбца K (убийства)
    killsboard_column_damage_width = 140, -- ширина для столбца D (урон)
    killsboard_column_player_width = 200, -- ширина для пары K+D (2 столбца) - используется для позиционирования, должна быть равна kills_width + damage_width
    killsboard_column_player_bg_width = 199, -- ширина фона столбца игрока
    killsboard_column_header_width = 200,
    killsboard_category_text_offset = 10, -- отступ текста категории от левого края столбца
    killsboard_fade_length = 0.1,
    killsboard_font_size = 12, -- размер шрифта для обычных строк
    killsboard_font_size_header = 13, -- размер шрифта для заголовка
    killsboard_row_color_dark_alpha = 200, -- альфа-канал для темного цвета четных строк (черный)
    killsboard_row_color_light_alpha = 150, -- альфа-канал для светлого цвета нечетных строк (темно-серый)
    killsboard_header_bg_alpha = 180, -- альфа-канал для фона заголовка "KILLSTREAK BOARD"
    killsboard_subheader_bg_alpha = 180, -- альфа-канал для фона подзаголовка "Kills/Damage"
    killsboard_total_bg_alpha = 180, -- альфа-канал для фона строки "TOTAL"
    killsboard_group_header_bg_alpha = 160, -- альфа-канал для фона заголовков групп
    killsboard_spacer_bg_alpha = 180, -- альфа-канал для фона пустой строки (0 = прозрачный)
    killsboard_background_alpha = 200, -- альфа-канал для черной подложки фона killsboard
    killsboard_background_width_offset = 10, -- уменьшение ширины подложки (вычитается с каждой стороны, итого -40 от общей ширины)
}
return settings("KillsboardViewSettings", killsboard_view_settings)

