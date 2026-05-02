local mod = get_mod("DivisionHUD")

mod.tracked_deployables = mod.tracked_deployables or {}

local DIVISIONHUD_PACKAGE_REFERENCE_NAME = "DivisionHUD"
local DIVISIONHUD_HUD_PACKAGE_NAMES = {
	"packages/ui/hud/team_player_panel/team_player_panel",
	"packages/ui/hud/player_ability/player_ability",
	"packages/ui/hud/player_weapon/player_weapon",
	"packages/ui/hud/player_buffs/player_buffs",
	"packages/ui/hud/blocking/blocking",
	"packages/ui/hud/dodge_counter/dodge_counter",
}
local DIVISIONHUD_HUD_MATERIAL_NAMES = {
	"content/ui/materials/backgrounds/default_square",
	"content/ui/materials/effects/hud/combat_talent_glow",
	"content/ui/materials/frames/dropshadow_medium",
	"content/ui/materials/frames/frame_corner_2px",
	"content/ui/materials/frames/frame_tile_2px",
	"content/ui/materials/gradients/gradient_vertical",
	"content/ui/materials/hud/backgrounds/player_health_fill",
	"content/ui/materials/hud/backgrounds/terminal_background_weapon",
	"content/ui/materials/hud/dodge_gauge",
	"content/ui/materials/hud/icons/party_ammo",
	"content/ui/materials/hud/icons/party_throwable",
	"content/ui/materials/hud/icons/weapon_icon_container",
	"content/ui/materials/hud/interactions/icons/pocketable_medkit",
	"content/ui/materials/hud/interactions/icons/pocketable_syringe_corruption",
	"content/ui/materials/hud/interactions/icons/pocketable_syringe_power",
	"content/ui/materials/hud/stamina_gauge",
	"content/ui/materials/icons/buffs/hud/buff_container_with_background",
	"content/ui/materials/icons/buffs/hud/buff_frame_with_opacity",
	"content/ui/materials/icons/circumstances/havoc/havoc_mutator_ember",
	"content/ui/materials/icons/circumstances/havoc/havoc_mutator_rampaging_enemies",
	"content/ui/materials/icons/circumstances/havoc/havoc_mutator_rotten_armor",
	"content/ui/materials/icons/circumstances/ventilation_purge_01",
	"content/ui/materials/icons/generic/danger",
	"content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	"content/ui/materials/icons/pocketables/hud/small/party_grimoire",
	"content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	"content/ui/materials/icons/pocketables/hud/small/party_scripture",
	"content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	"content/ui/materials/icons/presets/preset_11",
	"content/ui/materials/icons/presets/preset_13",
	"content/ui/materials/icons/presets/preset_18",
	"content/ui/materials/icons/presets/preset_20",
	"content/ui/materials/icons/talents/hud/combat_container",
	"content/ui/materials/icons/talents/hud/combat_frame_inner",
	"content/ui/materials/icons/throwables/hud/small/party_non_grenade",
	"content/ui/materials/icons/weapons/actions/melee",
	"content/ui/materials/icons/weapons/actions/melee_hand",
	"content/ui/materials/icons/weapons/flat/grenade",
}

mod._divisionhud_hud_resource_load_ids = mod._divisionhud_hud_resource_load_ids or {}

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

	for i = 1, #DIVISIONHUD_HUD_MATERIAL_NAMES do
		local material_name = DIVISIONHUD_HUD_MATERIAL_NAMES[i]

		if not mod._divisionhud_hud_resource_load_ids[material_name] then
			local ok, load_id = pcall(function()
				return package_manager:load(material_name, DIVISIONHUD_PACKAGE_REFERENCE_NAME, nil, true)
			end)

			if ok then
				mod._divisionhud_hud_resource_load_ids[material_name] = load_id
			end
		end
	end
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

ensure_divisionhud_hud_resources_loaded()

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/hud_registration")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/deployable_tracker")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/bootstrap/module_loader")

local previous_on_all_mods_loaded = mod.on_all_mods_loaded

mod.on_all_mods_loaded = function(...)
	ensure_divisionhud_hud_resources_loaded()

	if type(previous_on_all_mods_loaded) == "function" then
		previous_on_all_mods_loaded(...)
	end
end

function mod.divisionhud_toggle_visible_keybind(_)
	local cur = mod:get("divisionhud_visible")
	local on = cur ~= false and cur ~= 0

	mod:set("divisionhud_visible", not on, true)
end
