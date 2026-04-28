local mod = get_mod("SquadHud")

mod:io_dofile("SquadHud/scripts/mods/SquadHud/bootstrap/hud_registration")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/debug_runtime")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/vanilla_hud_suppression")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/runtime/settings_cache")

return mod
