local mod = get_mod("TeamKills")

local KillsboardViewSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killsboard_view_settings")

local base_z = 0

local blueprints = {
    killsboard_row = {
        size = {
            900,
            KillsboardViewSettings.killsboard_row_height,
        },
        pass_template = {
            {value_id = "text", -- 1 = Row text (category name)
                value = "text",
                pass_type = "text",
                style = {
                    offset = {30, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_header_width - 30, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "left",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            -- Player 1: K and D
            {value_id = "k1", -- 2 = Kills for player 1
                value = "k1",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d1", -- 3 = Damage for player 1
                value = "d1",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_width, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg1", -- 4 = Column background 1
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.terminal_frame(100, true),
                    disabled_color = Color.terminal_frame(100, true),
                    default_color = Color.terminal_frame(100, true),
                    hover_color = Color.terminal_frame(100, true),
                    offset = {KillsboardViewSettings.killsboard_column_header_width, 0, base_z},
                    size = {KillsboardViewSettings.killsboard_column_player_width, KillsboardViewSettings.killsboard_row_height},
                    visible = false,
                }
            },
            -- Player 2: K and D
            {value_id = "k2", -- 5 = Kills for player 2
                value = "k2",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d2", -- 6 = Damage for player 2
                value = "d2",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width + KillsboardViewSettings.killsboard_column_width, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            -- Player 3: K and D
            {value_id = "k3", -- 7 = Kills for player 3
                value = "k3",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width * 2, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d3", -- 8 = Damage for player 3
                value = "d3",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width * 2 + KillsboardViewSettings.killsboard_column_width, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg3", -- 9 = Column background 3
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.terminal_frame(100, true),
                    disabled_color = Color.terminal_frame(100, true),
                    default_color = Color.terminal_frame(100, true),
                    hover_color = Color.terminal_frame(100, true),
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width * 2, 0, base_z},
                    size = {KillsboardViewSettings.killsboard_column_player_width, KillsboardViewSettings.killsboard_row_height},
                    visible = false,
                }
            },
            -- Player 4: K and D
            {value_id = "k4", -- 10 = Kills for player 4
                value = "k4",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width * 3, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "d4", -- 11 = Damage for player 4
                value = "d4",
                pass_type = "text",
                style = {
                    offset = {KillsboardViewSettings.killsboard_column_header_width + KillsboardViewSettings.killsboard_column_player_width * 3 + KillsboardViewSettings.killsboard_column_width, 0, base_z + 1},
                    size = {KillsboardViewSettings.killsboard_column_width, KillsboardViewSettings.killsboard_row_height},
                    font_size = 16,
                    text_horizontal_alignment = "center",
                    text_vertical_alignment = "center",
                    text_color = Color.terminal_text_header(255, true),
                    color = Color.white(200, true),
                    default_color = Color.white(200, true),
                    hover_color = Color.white(200, true),
                    disabled_color = Color.white(200, true),
                    visible = true
                },
                custom = true,
            },
            {value_id = "bg", -- 12 = Row background
                value = "",
                pass_type = "texture",
                style = {
                    horizontal_alignment = "left",
                    color = Color.terminal_frame(200, true),
                    disabled_color = Color.terminal_frame(200, true),
                    default_color = Color.terminal_frame(200, true),
                    hover_color = Color.terminal_frame(200, true),
                    size = {900 - 32, 0},
                    offset = {16, 0, base_z},
                    visible = false,
                }
            },
        }
    },
}

return settings("KillsboardViewBlueprints", blueprints)

