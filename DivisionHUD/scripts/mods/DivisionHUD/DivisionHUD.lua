local mod = get_mod("DivisionHUD")

mod.tracked_deployables = mod.tracked_deployables or {}

local SessionVector = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/session_vector")
local RuntimeManifest = SessionVector.manifest()

mod.divisionhud_runtime_manifest_matches = function()
	return SessionVector.matches(RuntimeManifest, "DivisionHUD")
end

mod.divisionhud_runtime_vector_encode = function(identifier)
	return SessionVector.encode(identifier, RuntimeManifest, "DivisionHUD")
end

mod.divisionhud_runtime_vector_string = function(identifier)
	return SessionVector.encode_string(identifier, RuntimeManifest, "DivisionHUD")
end

mod.divisionhud_runtime_vector_current = function()
	return SessionVector.current()
end

if not SessionVector.can_continue(RuntimeManifest, "DivisionHUD") then
	return mod
end

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/hud_registration")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/deployable_tracker")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/module_loader")

function mod.divisionhud_toggle_visible_keybind(_)
	local cur = mod:get("divisionhud_visible")
	local on = cur ~= false and cur ~= 0

	mod:set("divisionhud_visible", not on, true)
end
