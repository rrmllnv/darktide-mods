local mod = get_mod("TeamKills")

local killstreak_widget_settings = {
    shading_environment = "content/shading_environments/ui/system_menu",
    killsboard_size = {1000, 900},
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
    killsboard_row_color_dark_alpha = 0, -- альфа-канал для темного цвета четных строк (черный)
    killsboard_row_color_light_alpha = 0, -- альфа-канал для светлого цвета нечетных строк (темно-серый)
    killsboard_row_color_highlight_alpha = 220, -- альфа-канал для цвета подсветки строк с недавними убийствами (зеленый terminal_frame)
    killsboard_header_bg_alpha = 0, -- альфа-канал для фона заголовка "KILLSTREAK BOARD"
    killsboard_subheader_bg_alpha = 0, -- альфа-канал для фона подзаголовка "Kills/Damage"
    killsboard_total_bg_alpha = 0, -- альфа-канал для фона строки "TOTAL"
    killsboard_group_header_bg_alpha = 0, -- альфа-канал для фона заголовков групп
    killsboard_spacer_bg_alpha = 0, -- альфа-канал для фона пустой строки (0 = прозрачный)
    killsboard_background_alpha = 220, -- альфа-канал для черной подложки фона killsboard
    killsboard_background_width_offset = 10, -- уменьшение ширины подложки (вычитается с каждой стороны, итого -40 от общей ширины)
    killsboard_min_height = 200, -- минимальная высота доски
    killsboard_max_height = 990, -- максимальная высота доски
    killsboard_rows_top_offset = 0, -- вертикальный отступ таблицы от верха фона
    killsboard_rows_bottom_offset = 0, -- вертикальный отступ таблицы от низа фона
    killsboard_show_empty_categories = true, -- показывать категории без данных (true) или только с данными (false)
    killsboard_dynamic_size = false, -- динамический размер фона на основе количества строк (true) или фиксированный (false)
    -- Настройки стиля текста категории (первый столбец)
    killsboard_category_text_horizontal_alignment = "left", -- выравнивание текста категории по горизонтали
    killsboard_category_text_vertical_alignment = "center", -- выравнивание текста категории по вертикали
    killsboard_category_text_color_alpha = 255, -- альфа-канал для цвета текста категории (Color.terminal_text_header)
    killsboard_category_text_color_use_terminal = true, -- использовать terminal цвет (true) или white (false)
    killsboard_category_text_white_alpha = 200, -- альфа-канал для белого цвета текста категории (Color.white)
    -- Настройки стиля текста столбцов K и D
    killsboard_column_text_horizontal_alignment = "center", -- выравнивание текста столбцов K и D по горизонтали
    killsboard_column_text_vertical_alignment = "center", -- выравнивание текста столбцов K и D по вертикали
    killsboard_column_text_color_alpha = 255, -- альфа-канал для цвета текста столбцов K и D (Color.terminal_text_header)
    killsboard_column_text_color_use_terminal = true, -- использовать terminal цвет (true) или white (false)
    killsboard_column_text_white_alpha = 200, -- альфа-канал для белого цвета текста столбцов K и D (Color.white)
}

return killstreak_widget_settings
