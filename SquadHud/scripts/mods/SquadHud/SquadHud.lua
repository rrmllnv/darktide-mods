local mod = get_mod("SquadHud")

mod:io_dofile("SquadHud/scripts/mods/SquadHud/bootstrap/hud_registration")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/debug_runtime")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/vanilla_hud_suppression")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/runtime/settings_cache")

mod._squadhud_show_account_names = mod._squadhud_show_account_names == true
mod._squadhud_account_names_key_held = false

local function account_names_keybind_mode()
	local mode = mod:get("squadhud_account_names_keybind_mode")

	if mode == "hold" then
		return "hold"
	end

	return "toggle"
end

mod.squadhud_account_names_keybind = function(...)
	local ui_manager = Managers.ui

	if ui_manager and type(ui_manager.chat_using_input) == "function" and ui_manager:chat_using_input() then
		return
	end

	local a, b = ...
	local pressed = type(b) == "boolean" and b or type(a) == "boolean" and a or false
	local mode = account_names_keybind_mode()

	if mode == "hold" then
		mod._squadhud_show_account_names = pressed == true
	else
		if pressed == true and mod._squadhud_account_names_key_held ~= true then
			mod._squadhud_show_account_names = not mod._squadhud_show_account_names
		end
	end

	mod._squadhud_account_names_key_held = pressed == true
end

mod.squadhud_toggle_account_names = function()
	mod._squadhud_show_account_names = not mod._squadhud_show_account_names
end

mod.squadhud_social_apply_settings = function(setting_id)
	if setting_id ~= "squadhud_account_names_keybind_mode" and setting_id ~= "squadhud_reset_all_settings" then
		return
	end

	mod._squadhud_account_names_key_held = false

	if account_names_keybind_mode() == "hold" or setting_id == "squadhud_reset_all_settings" then
		mod._squadhud_show_account_names = false
	end
end

return mod
