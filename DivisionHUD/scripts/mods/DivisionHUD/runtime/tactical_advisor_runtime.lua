local mod = get_mod("DivisionHUD")

local Ammo = require("scripts/utilities/ammo")

local AMMO_CRATE_POCKETABLE_NAME = "ammo_cache_pocketable"
local AMMO_CRATE_INVENTORY_ITEM_NAME = "content/items/pocketable/ammo_cache_pocketable"
local MEDICAL_CRATE_POCKETABLE_NAME = "medical_crate_pocketable"
local MEDICAL_CRATE_INVENTORY_ITEM_NAME = "content/items/pocketable/med_crate_pocketable"
local HEALTH_STIMM_POCKETABLE_NAME = "syringe_corruption_pocketable"
local HEALTH_STIMM_INVENTORY_ITEM_NAME = "content/items/pocketable/syringe_corruption_pocketable"
local GRENADE_ABILITY_TYPE = "grenade_ability"

local AMMO_CRATE_NAMES = {
	[AMMO_CRATE_POCKETABLE_NAME] = true,
	[AMMO_CRATE_INVENTORY_ITEM_NAME] = true,
}

local MEDICAL_CRATE_NAMES = {
	[MEDICAL_CRATE_POCKETABLE_NAME] = true,
	[MEDICAL_CRATE_INVENTORY_ITEM_NAME] = true,
}

local HEALTH_STIMM_NAMES = {
	[HEALTH_STIMM_POCKETABLE_NAME] = true,
	[HEALTH_STIMM_INVENTORY_ITEM_NAME] = true,
}

local function _setting_enabled(key, fallback)
	local settings = mod._settings
	local value = settings and settings[key]

	if value == false or value == 0 then
		return false
	end

	if value == true or value == 1 then
		return true
	end

	return fallback
end

local function _setting_number(key, fallback)
	local settings = mod._settings
	local value = settings and settings[key]

	if type(value) == "number" and value == value then
		return value
	end

	return fallback
end

local function _total_ammo_fraction(unit_data_extension, visual_loadout_extension)
	if not unit_data_extension or not visual_loadout_extension then
		return 1
	end

	local weapon_slot_configuration = visual_loadout_extension:slot_configuration_by_type("weapon")

	if type(weapon_slot_configuration) ~= "table" then
		return 1
	end

	local total_current_ammo = 0
	local total_max_ammo = 0

	for slot_name, _ in pairs(weapon_slot_configuration) do
		local slot_component = unit_data_extension:read_component(slot_name)

		if slot_component and (slot_component.max_ammunition_reserve or 0) > 0 then
			total_current_ammo = total_current_ammo + (Ammo.current_ammo_in_reserve(slot_component) or 0)
			total_max_ammo = total_max_ammo + (Ammo.max_ammo_in_reserve(slot_component) or 0)

			for i = 1, NetworkConstants.clips_in_use.max_size do
				total_current_ammo = total_current_ammo + (Ammo.current_ammo_in_clips(slot_component, i) or 0)
				total_max_ammo = total_max_ammo + (Ammo.max_ammo_in_clips(slot_component, i) or 0)
			end
		end
	end

	if total_max_ammo <= 0 then
		return 1
	end

	return math.clamp(total_current_ammo / total_max_ammo, 0, 1)
end

local function _inventory_component(unit_data_extension)
	if not unit_data_extension then
		return nil
	end

	return unit_data_extension:read_component("inventory")
end

local function _slot_matches_name_map(inventory_component, visual_loadout_extension, slot_name, name_map)
	if type(name_map) ~= "table" or type(slot_name) ~= "string" then
		return false
	end

	local inventory_value = inventory_component and inventory_component[slot_name]

	if type(inventory_value) == "string" and name_map[inventory_value] == true then
		return true
	end

	local item = visual_loadout_extension and visual_loadout_extension.item_from_slot and visual_loadout_extension:item_from_slot(slot_name)
	local item_name = item and item.name
	local item_weapon_template = item and item.weapon_template

	if type(item_name) == "string" and name_map[item_name] == true then
		return true
	end

	if type(item_weapon_template) == "string" and name_map[item_weapon_template] == true then
		return true
	end

	local weapon_template = visual_loadout_extension and visual_loadout_extension.weapon_template_from_slot and visual_loadout_extension:weapon_template_from_slot(slot_name)

	if type(weapon_template) == "table" then
		if type(weapon_template.name) == "string" and name_map[weapon_template.name] == true then
			return true
		end

		if type(weapon_template.swap_pickup_name) == "string" and name_map[weapon_template.swap_pickup_name] == true then
			return true
		end

		if type(weapon_template.give_pickup_name) == "string" and name_map[weapon_template.give_pickup_name] == true then
			return true
		end
	end

	return false
end

local function _has_inventory_ammo_crate(inventory_component, visual_loadout_extension)
	return _slot_matches_name_map(inventory_component, visual_loadout_extension, "slot_pocketable", AMMO_CRATE_NAMES)
end

local function _has_inventory_medical_crate(inventory_component, visual_loadout_extension)
	return _slot_matches_name_map(inventory_component, visual_loadout_extension, "slot_pocketable", MEDICAL_CRATE_NAMES)
end

local function _has_inventory_health_stimm(inventory_component, visual_loadout_extension)
	return _slot_matches_name_map(inventory_component, visual_loadout_extension, "slot_pocketable_small", HEALTH_STIMM_NAMES)
end

local function _health_fraction(player_unit)
	local health_extension = player_unit and ScriptUnit.has_extension(player_unit, "health_system")

	if not health_extension then
		return 1
	end

	local ok, current_health_percent = pcall(function()
		return health_extension:current_health_percent()
	end)

	if not ok or type(current_health_percent) ~= "number" or current_health_percent ~= current_health_percent then
		return 1
	end

	return math.clamp(current_health_percent, 0, 1)
end

local function _grenade_fraction(player_unit)
	local ability_extension = player_unit and ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension then
		return 1
	end

	local ok_max, max_charges = pcall(function()
		return ability_extension:max_ability_charges(GRENADE_ABILITY_TYPE)
	end)

	local ok_remaining, remaining_charges = pcall(function()
		return ability_extension:remaining_ability_charges(GRENADE_ABILITY_TYPE)
	end)

	if not ok_max or not ok_remaining then
		return 1
	end

	if type(max_charges) ~= "number" or max_charges <= 0 or type(remaining_charges) ~= "number" then
		return 1
	end

	return math.clamp(remaining_charges / max_charges, 0, 1)
end

local function scan(player_unit)
	if not player_unit or not Unit.alive(player_unit) then
		return {
			active = false,
		}
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")

	if not unit_data_extension or not visual_loadout_extension then
		return {
			active = false,
		}
	end

	local inventory_component = _inventory_component(unit_data_extension)
	local low_ammo_enabled = _setting_enabled("tactical_advisor_low_ammo_enabled", true)
	local low_health_enabled = _setting_enabled("tactical_advisor_low_health_enabled", true)
	local low_grenade_enabled = _setting_enabled("tactical_advisor_low_grenade_enabled", true)
	local low_ammo_threshold_percent = math.clamp(_setting_number("tactical_advisor_low_ammo_threshold", 25), 0, 100)
	local low_health_threshold_percent = math.clamp(_setting_number("tactical_advisor_low_health_threshold", 25), 0, 100)
	local low_grenade_threshold_percent = math.clamp(_setting_number("tactical_advisor_low_grenade_threshold", 35), 0, 100)
	local low_ammo_threshold_fraction = low_ammo_threshold_percent / 100
	local low_health_threshold_fraction = low_health_threshold_percent / 100
	local low_grenade_threshold_fraction = low_grenade_threshold_percent / 100
	local ammo_fraction = _total_ammo_fraction(unit_data_extension, visual_loadout_extension)
	local health_fraction = _health_fraction(player_unit)
	local grenade_fraction = _grenade_fraction(player_unit)
	local low_ammo_active = low_ammo_enabled and ammo_fraction < low_ammo_threshold_fraction
	local low_health_active = low_health_enabled and health_fraction < low_health_threshold_fraction
	local low_grenade_active = low_grenade_enabled and grenade_fraction < low_grenade_threshold_fraction
	local has_inventory_ammo_crate = _has_inventory_ammo_crate(inventory_component, visual_loadout_extension)
	local has_inventory_medical_crate = _has_inventory_medical_crate(inventory_component, visual_loadout_extension)
	local has_inventory_health_stimm = _has_inventory_health_stimm(inventory_component, visual_loadout_extension)

	return {
		active = low_ammo_active or low_health_active or low_grenade_active,
		low_ammo = {
			active = low_ammo_active,
			fraction = ammo_fraction,
			threshold = low_ammo_threshold_fraction,
			highlight_proximity = {
				ammo_small = true,
				ammo_large = true,
				ammo_crate = true,
			},
			highlight_slots = {
				slot_pickup = has_inventory_ammo_crate,
			},
		},
		low_health = {
			active = low_health_active,
			fraction = health_fraction,
			threshold = low_health_threshold_fraction,
			highlight_proximity = {
				medical_station = true,
				medical = true,
				medical_deployed = true,
				stimm_corruption = true,
			},
			highlight_slots = {
				slot_stimm = has_inventory_health_stimm,
				slot_pickup = has_inventory_medical_crate,
			},
		},
		low_grenade = {
			active = low_grenade_active,
			fraction = grenade_fraction,
			threshold = low_grenade_threshold_fraction,
			highlight_proximity = {
				grenade = true,
			},
			highlight_slots = {},
		},
	}
end

local TacticalAdvisorRuntime = {
	scan = scan,
}

mod.tactical_advisor_runtime = TacticalAdvisorRuntime

return TacticalAdvisorRuntime
