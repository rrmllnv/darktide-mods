local mod = get_mod("TeamKills")

local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")

local base_z = 0
local text_z_offset = 11
local bg_z_offset = 10
local FONT_SIZE = KillstreakWidgetSettings.killsboard_font_size
local function get_bg_offset(player_index)
    local total_column_width = KillstreakWidgetSettings.killsboard_column_kills_width + KillstreakWidgetSettings.killsboard_column_damage_width
    local k_start = KillstreakWidgetSettings.killsboard_column_header_width + (KillstreakWidgetSettings.killsboard_column_player_width * (player_index - 1))
    local d_end = k_start + total_column_width
    local center = (k_start + d_end) / 2
    return center - (KillstreakWidgetSettings.killsboard_column_player_bg_width / 2)
end

local blueprints = {
    killsboard_row = {
        size = {
            KillstreakWidgetSettings.killsboard_size[1],
            KillstreakWidgetSettings.killsboard_row_height,
        },
        pass_template = {
            {value_id = "text",
                value = "text",
                pass_type = "text",
                style = {
                    offset = {30, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_header_width + 200, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_category_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_category_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_category_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_category_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_category_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_category_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_category_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_category_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_category_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "k1",
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_kills_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d1", -- 3 = Damage for player 1
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_kills_width, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_damage_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg1", -- 4 = Column background 1
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.black(255, true),
                    disabled_color = Color.black(255, true),
                    default_color = Color.black(255, true),
                    hover_color = Color.black(255, true),
                    offset = {get_bg_offset(1), 0, bg_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_player_bg_width, KillstreakWidgetSettings.killsboard_row_height},
                    visible = false,
                }
            },
            -- Player 2: K and D
            {value_id = "k2", -- 5 = Kills for player 2
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_player_width, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_kills_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d2", -- 6 = Damage for player 2
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_player_width + KillstreakWidgetSettings.killsboard_column_kills_width, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_damage_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg2", -- 7 = Column background 2
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.black(200, true),
                    disabled_color = Color.black(200, true),
                    default_color = Color.black(200, true),
                    hover_color = Color.black(200, true),
                    offset = {get_bg_offset(2), 0, bg_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_player_bg_width, KillstreakWidgetSettings.killsboard_row_height},
                    visible = false,
                }
            },
            -- Player 3: K and D
            {value_id = "k3", -- 8 = Kills for player 3
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_player_width * 2, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_kills_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d3", -- 9 = Damage for player 3
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_player_width * 2 + KillstreakWidgetSettings.killsboard_column_kills_width, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_damage_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg3", -- 10 = Column background 3
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.black(255, true),
                    disabled_color = Color.black(255, true),
                    default_color = Color.black(255, true),
                    hover_color = Color.black(255, true),
                    offset = {get_bg_offset(3), 0, bg_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_player_bg_width, KillstreakWidgetSettings.killsboard_row_height},
                    visible = false,
                }
            },
            -- Player 4: K and D
            {value_id = "k4", -- 11 = Kills for player 4
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_player_width * 3, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_kills_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d4", -- 12 = Damage for player 4
                value = "",
                pass_type = "text",
                style = {
                    offset = {KillstreakWidgetSettings.killsboard_column_header_width + KillstreakWidgetSettings.killsboard_column_player_width * 3 + KillstreakWidgetSettings.killsboard_column_kills_width, 0, text_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_damage_width, KillstreakWidgetSettings.killsboard_row_height},
                    font_size = FONT_SIZE,
                    text_horizontal_alignment = KillstreakWidgetSettings.killsboard_column_text_horizontal_alignment,
                    text_vertical_alignment = KillstreakWidgetSettings.killsboard_column_text_vertical_alignment,
                    text_color = KillstreakWidgetSettings.killsboard_column_text_color_use_terminal and Color.terminal_text_header(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true) or Color.white(KillstreakWidgetSettings.killsboard_column_text_color_alpha, true),
                    color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    default_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    hover_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    disabled_color = Color.white(KillstreakWidgetSettings.killsboard_column_text_white_alpha, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg4", -- 13 = Column background 4
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.black(200, true),
                    disabled_color = Color.black(200, true),
                    default_color = Color.black(200, true),
                    hover_color = Color.black(200, true),
                    offset = {get_bg_offset(4), 0, bg_z_offset},
                    size = {KillstreakWidgetSettings.killsboard_column_player_bg_width, KillstreakWidgetSettings.killsboard_row_height},
                    visible = false,
                }
            },
            {value_id = "bg_category", -- 14 = Category column background
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.black(255, true),
                    disabled_color = Color.black(255, true),
                    default_color = Color.black(255, true),
                    hover_color = Color.black(255, true),
                    size = {KillstreakWidgetSettings.killsboard_column_header_width, KillstreakWidgetSettings.killsboard_row_height},
                    offset = {0, 0, bg_z_offset},
                    visible = false,
                }
            },
        }
    },
}

return settings("KillstreakWidgetBlueprints", blueprints)
