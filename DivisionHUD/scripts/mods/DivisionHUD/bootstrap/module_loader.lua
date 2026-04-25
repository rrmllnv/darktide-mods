local mod = get_mod("DivisionHUD")

local SessionVector = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/session_vector")

if not SessionVector.can_continue() then
	return mod
end

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/util/hud_utils")
mod.recolor_stimms_bridge = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/compat/recolor_stimms_bridge")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/vanilla_hud_suppression")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/runtime/settings_cache")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/wielded_weapon_icon_tint")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/alerts_runtime")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/debug_runtime")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/mission_objective_runtime")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/team_alerts_runtime")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/proximity_runtime")
mod.danger_zone_runtime = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/danger_zone_runtime")
mod.enemy_target_runtime = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/enemy_target_runtime")

mod.on_all_mods_loaded = function()
	local bridge = mod.recolor_stimms_bridge

	if bridge and type(bridge.refresh) == "function" then
		bridge.refresh()
	end
end

return mod
