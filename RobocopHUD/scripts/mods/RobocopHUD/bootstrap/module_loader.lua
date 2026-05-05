local mod = get_mod("RobocopHUD")

mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/runtime/settings_cache")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/definitions/robocop_hud_definitions")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/themes/themes")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/vanilla_hud_suppression")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/threat_query")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/threat_scoring")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/target_lock")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/warnings_runtime")

return mod

