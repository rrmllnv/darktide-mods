local mod = get_mod("PlayerProgressStats")

local view_templates = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/templates/view_templates")
local views = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/modules/views")
local commands = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/modules/commands")
local utilities = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/modules/utilities")
local init = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/modules/init")

local VIEW_NAME = "player_progress_stats_view"

mod.version = "1.0.0"

init.setup(mod, VIEW_NAME, view_templates, views, utilities)
commands.setup(mod)

