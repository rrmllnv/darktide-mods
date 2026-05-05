local mod = get_mod("RobocopHUD")

mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/bootstrap/hud_registration")
mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/bootstrap/module_loader")

-- Targeting mode state: "AUTO" (default) or "SCAN" (cycle all visible enemies automatically).
mod._robocophud_mode = "AUTO"
mod._robocophud_scan_state = nil

-- Called by the cycle_target_keybind hotkey (default: Left Ctrl).
-- DMF calls this exactly once per physical keypress (keybind_trigger = "pressed").
-- Toggles between AUTO and SCAN mode.
mod.robocophud_cycle_target_keybind = function()
	if mod._robocophud_mode == "AUTO" then
		mod._robocophud_mode = "SCAN"
		mod._robocophud_scan_state = { shown_set = {}, current_unit = nil, show_until_t = 0 }
	else
		mod._robocophud_mode = "AUTO"
		mod._robocophud_scan_state = nil
	end
end
