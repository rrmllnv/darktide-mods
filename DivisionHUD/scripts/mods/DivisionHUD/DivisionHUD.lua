local mod = get_mod("DivisionHUD")

mod.tracked_deployables = mod.tracked_deployables or {}

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/hud_registration")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/hud_hooks")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/deployable_tracker")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/module_loader")

function mod.divisionhud_toggle_visible_keybind(_)
	local cur = mod:get("divisionhud_visible")
	local on = cur ~= false and cur ~= 0

	mod:set("divisionhud_visible", not on, true)
end
