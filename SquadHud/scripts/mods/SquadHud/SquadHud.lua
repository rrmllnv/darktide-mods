local mod = get_mod("SquadHud")

local SQUADHUD_PACKAGE_REFERENCE_NAME = "SquadHud"
local SQUADHUD_HUD_PACKAGE_NAMES = {
	"packages/ui/hud/team_player_panel/team_player_panel",
	"packages/ui/hud/player_ability/player_ability",
	"packages/ui/hud/player_weapon/player_weapon",
}

mod._squadhud_hud_package_load_ids = mod._squadhud_hud_package_load_ids or {}

local function ensure_squadhud_hud_packages_loaded()
	local package_manager = Managers.package

	if not package_manager or type(package_manager.load) ~= "function" then
		return
	end

	for i = 1, #SQUADHUD_HUD_PACKAGE_NAMES do
		local package_name = SQUADHUD_HUD_PACKAGE_NAMES[i]

		if not mod._squadhud_hud_package_load_ids[package_name] then
			local ok, load_id = pcall(function()
				return package_manager:load(package_name, SQUADHUD_PACKAGE_REFERENCE_NAME, nil, true)
			end)

			if ok then
				mod._squadhud_hud_package_load_ids[package_name] = load_id
			end
		end
	end
end

local function release_squadhud_hud_packages()
	local package_manager = Managers.package
	local package_load_ids = mod._squadhud_hud_package_load_ids

	if not package_manager or type(package_manager.release) ~= "function" or not package_load_ids then
		mod._squadhud_hud_package_load_ids = {}

		return
	end

	for package_name, load_id in pairs(package_load_ids) do
		if load_id then
			pcall(function()
				package_manager:release(load_id)
			end)
		end

		package_load_ids[package_name] = nil
	end
end

mod.on_all_mods_loaded = function()
	ensure_squadhud_hud_packages_loaded()
end

mod.on_unload = function()
	release_squadhud_hud_packages()
end

ensure_squadhud_hud_packages_loaded()

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
	local was_held = mod._squadhud_expanded_view_key_held == true
	local key_down_edge = pressed == true and not was_held

	if mode == "hold" then
		mod._squadhud_expanded_view = pressed == true
	else
		if key_down_edge then
			mod._squadhud_expanded_view = not mod._squadhud_expanded_view
		end
	end

	if key_down_edge then
		mod._squadhud_expanded_view_hint_dismiss_token = (mod._squadhud_expanded_view_hint_dismiss_token or 0) + 1
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
