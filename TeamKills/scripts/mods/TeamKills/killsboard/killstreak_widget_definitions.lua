local mod = get_mod("TeamKills")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Color = Color
local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_settings")
local base_z = 100

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    killsboard = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "center",
        size = {KillstreakWidgetSettings.killsboard_size[1], KillstreakWidgetSettings.killsboard_size[2]},
        position = {0, 0, base_z}
    },
    killsboard_rows = {
        vertical_alignment = "top",
        parent = "killsboard",
        horizontal_alignment = "center",
        size = {KillstreakWidgetSettings.killsboard_size[1], KillstreakWidgetSettings.killsboard_size[2] - 100},
        position = {0, 40, base_z + 1}
    },
}

-- Используем определение виджета из killstreak_tactical_overlay.lua
-- Виджет создается через hook_require в killstreak_tactical_overlay.lua
-- Здесь мы создаем копию для View
local widget_definitions = {}

-- Создаем виджет killsboard используя то же определение, что и в killstreak_tactical_overlay.lua
local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_settings")
local base_z = 100
local base_x = 0

widget_definitions.killsboard = UIWidget.create_definition({
    {
        pass_type = "texture",
        value = "content/ui/materials/frames/dropshadow_heavy",
        style = {
            vertical_alignment = "center",
            scale_to_material = true,
            horizontal_alignment = "center",
            offset = {base_x, 0, base_z + 200},
            size = {KillstreakWidgetSettings.killsboard_size[1] - 4, KillstreakWidgetSettings.killsboard_size[2] - 3},
            color = Color.black(255, true),
            disabled_color = Color.black(255, true),
            default_color = Color.black(255, true),
            hover_color = Color.black(255, true),
        }
    },
    {
        pass_type = "texture",
        value = "content/ui/materials/frames/inner_shadow_medium",
        style = {
            vertical_alignment = "center",
            scale_to_material = true,
            horizontal_alignment = "center",
            offset = {base_x, 0, base_z + 100},
            size = {KillstreakWidgetSettings.killsboard_size[1] - 24, KillstreakWidgetSettings.killsboard_size[2] - 28},
            color = Color.black(255, true),
            disabled_color = Color.black(255, true),
            default_color = Color.black(255, true),
            hover_color = Color.black(255, true),
        }
    },
    {
        value = "content/ui/materials/backgrounds/terminal_basic",
        pass_type = "texture",
        style = {
            vertical_alignment = "center",
            scale_to_material = true,
            horizontal_alignment = "center",
            offset = {base_x, 0, base_z},
            size = {KillstreakWidgetSettings.killsboard_size[1] - 4, KillstreakWidgetSettings.killsboard_size[2]},
            color = Color.black(255, true),
            disabled_color = Color.black(255, true),
            default_color = Color.black(255, true),
            hover_color = Color.black(255, true),
        }
    },
    {
        value = "content/ui/materials/backgrounds/hud/tactical_overlay_background",
        pass_type = "texture",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "center",
            offset = {base_x, 0, base_z - 1},
            size = {KillstreakWidgetSettings.killsboard_size[1] - 4 - (KillstreakWidgetSettings.killsboard_background_width_offset * 2), KillstreakWidgetSettings.killsboard_size[2]},
            color = Color.black(KillstreakWidgetSettings.killsboard_background_alpha, true),
        }
    },
    {
        pass_type = "texture",
        value = "content/ui/materials/frames/premium_store/details_upper",
        style = {
            vertical_alignment = "center",
            scale_to_material = true,
            horizontal_alignment = "center",
            offset = {base_x, -KillstreakWidgetSettings.killsboard_size[2] / 2, base_z + 200},
            size = {KillstreakWidgetSettings.killsboard_size[1], 80},
            color = Color.gray(255, true),
            disabled_color = Color.gray(255, true),
            default_color = Color.gray(255, true),
            hover_color = Color.gray(255, true),
        }
    },
    {
        pass_type = "texture",
        value = "content/ui/materials/frames/premium_store/details_lower_basic",
        style = {
            vertical_alignment = "center",
            scale_to_material = true,
            horizontal_alignment = "center",
            offset = {base_x, KillstreakWidgetSettings.killsboard_size[2] / 2 - 50, base_z + 200},
            size = {KillstreakWidgetSettings.killsboard_size[1] + 50, 120},
            color = Color.gray(255, true),
            disabled_color = Color.gray(255, true),
            default_color = Color.gray(255, true),
            hover_color = Color.gray(255, true),
        }
    },
}, "killsboard")

local KillsboardViewDefinitions = {
    widget_definitions = widget_definitions,
    scenegraph_definition = scenegraph_definition
}

return settings("KillstreakWidgetDefinitions", KillsboardViewDefinitions)

