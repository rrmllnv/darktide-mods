local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local WwiseGameSyncSettings = require("scripts/settings/wwise_game_sync/wwise_game_sync_settings")

local view_templates = {
    player_progress_stats_view = {
        display_name = "Player Progress Stats",
        view_name = "player_progress_stats_view",
        view_settings = {
            init_view_function = function(ingame_ui_context)
                return true
            end,
            state_bound = true,
            disable_game_world = false,
            game_world_blur = 1.1,
            path = [[GlobalStat\scripts\mods\GlobalStat\views\view_main]],
            class = "GlobalStatView",
            load_always = true,
            enter_sound_events = {
                UISoundEvents.system_menu_enter,
            },
            exit_sound_events = {
                UISoundEvents.system_menu_exit,
            },
            wwise_states = {
                options = WwiseGameSyncSettings.state_groups.options.ingame_menu,
            },
        },
        view_transitions = {},
        view_options = {},
    },
}

return view_templates

