local mod = get_mod("SquadHud")

mod:io_dofile("SquadHud/scripts/mods/SquadHud/bootstrap/hud_registration")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/debug_runtime")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/vanilla_hud_suppression")
mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/runtime/settings_cache")

mod._squadhud_expanded_view = mod._squadhud_expanded_view == true
mod._squadhud_expanded_view_key_held = false

local function expanded_view_keybind_mode()
	local mode = mod:get("squadhud_expanded_view_keybind_mode")

	if mode == "hold" then
		return "hold"
	end

	return "toggle"
end

local function refresh_expanded_view_keybind()
	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" then
		return
	end

	local ok, dmf = pcall(get_mod_fn, "DMF")

	if not ok or not dmf or type(dmf.local_keys_to_keywatch_result) ~= "function" or type(dmf.add_mod_keybind) ~= "function" then
		return
	end

	local keywatch_result = dmf.local_keys_to_keywatch_result(mod:get("squadhud_expanded_view_keybind"))

	if keywatch_result and keywatch_result.main then
		dmf.add_mod_keybind(mod, "squadhud_expanded_view_keybind", {
			trigger = "held",
			type = "function_call",
			main = keywatch_result.main,
			enablers = keywatch_result.enablers,
			disablers = keywatch_result.disablers,
			function_name = "squadhud_expanded_view_keybind",
		})
	else
		dmf.add_mod_keybind(mod, "squadhud_expanded_view_keybind", {})
	end
end

mod.squadhud_expanded_view_keybind = function(...)
	local ui_manager = Managers.ui

	if ui_manager and type(ui_manager.chat_using_input) == "function" and ui_manager:chat_using_input() then
		return
	end

	local a, b = ...
	local pressed = type(b) == "boolean" and b or type(a) == "boolean" and a or false
	local mode = expanded_view_keybind_mode()

	if mode == "hold" then
		mod._squadhud_expanded_view = pressed == true
	else
		if pressed == true and mod._squadhud_expanded_view_key_held ~= true then
			mod._squadhud_expanded_view = not mod._squadhud_expanded_view
		end
	end

	mod._squadhud_expanded_view_key_held = pressed == true
end

mod.squadhud_toggle_expanded_view = function()
	mod._squadhud_expanded_view = not mod._squadhud_expanded_view
end

mod.squadhud_expanded_view_apply_settings = function(setting_id)
	if setting_id ~= "squadhud_expanded_view_keybind" and setting_id ~= "squadhud_expanded_view_keybind_mode" and setting_id ~= "squadhud_reset_all_settings" then
		return
	end

	mod._squadhud_expanded_view_key_held = false

	if expanded_view_keybind_mode() == "hold" or setting_id == "squadhud_reset_all_settings" then
		mod._squadhud_expanded_view = false
	end

	if setting_id == "squadhud_expanded_view_keybind" or setting_id == "squadhud_reset_all_settings" then
		refresh_expanded_view_keybind()
	end
end

return mod
