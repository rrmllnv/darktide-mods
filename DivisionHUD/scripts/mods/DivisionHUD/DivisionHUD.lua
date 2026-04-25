local mod = get_mod("DivisionHUD")

mod.tracked_deployables = mod.tracked_deployables or {}

local AccessPayload = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/security/access_payload")
local AccessGuard = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/security/access_guard")

mod.divisionhud_access_is_denied = function()
	return AccessGuard.is_denied(AccessPayload, "DivisionHUD")
end

mod.divisionhud_access_encode_identifier = function(identifier)
	return AccessGuard.encoded_entry_for_identifier(identifier, AccessPayload, "DivisionHUD")
end

mod.divisionhud_access_encode_identifier_string = function(identifier)
	return AccessGuard.encoded_entry_string_for_identifier(identifier, AccessPayload, "DivisionHUD")
end

mod.divisionhud_access_current_identifier = function()
	return AccessGuard.current_identifier()
end

if mod.divisionhud_access_is_denied() then
	mod.divisionhud_access_blocked = true

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
