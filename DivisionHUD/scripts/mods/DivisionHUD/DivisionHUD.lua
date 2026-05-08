local mod = get_mod("DivisionHUD")

mod.tracked_deployables = mod.tracked_deployables or {}

local GameFlowContext = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/context/game_flow")

local DIVISIONHUD_PACKAGE_REFERENCE_NAME = "DivisionHUD"
local DIVISIONHUD_HUD_PACKAGE_NAMES = {
	"packages/ui/hud/team_player_panel/team_player_panel",
	"packages/ui/hud/player_ability/player_ability",
	"packages/ui/hud/player_weapon/player_weapon",
	"packages/ui/hud/player_buffs/player_buffs",
	"packages/ui/hud/blocking/blocking",
	"packages/ui/hud/dodge_counter/dodge_counter",
}

mod._divisionhud_hud_resource_load_ids = mod._divisionhud_hud_resource_load_ids or {}
mod._divisionhud_hud_resources_loaded_once = mod._divisionhud_hud_resources_loaded_once or false

local function ensure_divisionhud_hud_resources_loaded()
	local package_manager = Managers.package

	if not package_manager or type(package_manager.load) ~= "function" then
		return
	end

	for i = 1, #DIVISIONHUD_HUD_PACKAGE_NAMES do
		local package_name = DIVISIONHUD_HUD_PACKAGE_NAMES[i]

		if not mod._divisionhud_hud_resource_load_ids[package_name] then
			local ok, load_id = pcall(function()
				return package_manager:load(package_name, DIVISIONHUD_PACKAGE_REFERENCE_NAME, nil, true)
			end)

			if ok then
				mod._divisionhud_hud_resource_load_ids[package_name] = load_id
			end
		end
	end
end

local function try_load_divisionhud_hud_resources()
	if mod._divisionhud_hud_resources_loaded_once then
		return
	end

	if GameFlowContext and type(GameFlowContext.is_hub_like) == "function" and GameFlowContext.is_hub_like() then
		return
	end

	local package_manager = Managers.package

	if not package_manager or type(package_manager.load) ~= "function" then
		return
	end

	ensure_divisionhud_hud_resources_loaded()

	mod._divisionhud_hud_resources_loaded_once = true
end

local function release_divisionhud_hud_resources()
	local package_manager = Managers.package
	local resource_load_ids = mod._divisionhud_hud_resource_load_ids

	if not package_manager or type(package_manager.release) ~= "function" or not resource_load_ids then
		mod._divisionhud_hud_resource_load_ids = {}

		return
	end

	for resource_name, load_id in pairs(resource_load_ids) do
		if load_id then
			pcall(function()
				package_manager:release(load_id)
			end)
		end

		resource_load_ids[resource_name] = nil
	end
end

mod.on_unload = function()
	release_divisionhud_hud_resources()
end

mod.update = function()
	try_load_divisionhud_hud_resources()
end

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/hud_registration")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/deployable_tracker")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/module_loader")

local previous_on_all_mods_loaded = mod.on_all_mods_loaded

mod.on_all_mods_loaded = function(...)
	try_load_divisionhud_hud_resources()

	if type(previous_on_all_mods_loaded) == "function" then
		previous_on_all_mods_loaded(...)
	end
end

local previous_on_game_state_changed = mod.on_game_state_changed

mod.on_game_state_changed = function(status, state_name)
	if status == "enter" then
		try_load_divisionhud_hud_resources()
	end

	if type(previous_on_game_state_changed) == "function" then
		previous_on_game_state_changed(status, state_name)
	end
end

function mod.divisionhud_toggle_visible_keybind(_)
	local cur = mod:get("divisionhud_visible")
	local on = cur ~= false and cur ~= 0

	mod:set("divisionhud_visible", not on, true)
end
