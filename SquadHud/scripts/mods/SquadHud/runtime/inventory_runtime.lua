local AbilityTemplates = require("scripts/settings/ability/ability_templates/ability_templates")
local Ammo = require("scripts/utilities/ammo")
local MasterItems = require("scripts/backend/master_items")
local Text = require("scripts/utilities/ui/text")
local WalletSettings = require("scripts/settings/wallet_settings")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

local M = {}

local POCKETABLE_SLOT_NAME = "slot_pocketable"
local POCKETABLE_SMALL_SLOT_NAME = "slot_pocketable_small"
local GRENADE_ABILITY_SLOT_NAME = "slot_grenade_ability"
local GRENADE_ABILITY_ID = "grenade_ability"
local AMMO_ICON = "content/ui/materials/hud/icons/party_ammo"
local MAX_STATUS = 3

local WEAPON_SLOTS = {
	"slot_primary",
	"slot_secondary",
}

local function safe_call(object, method_name, ...)
	if not object or type(object[method_name]) ~= "function" then
		return false, nil
	end

	local args = {
		...
	}

	return pcall(function()
		return object[method_name](object, unpack(args))
	end)
end

local function safe_read_component(unit_data_extension, component_name)
	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return nil
	end

	local ok, component = pcall(function()
		return unit_data_extension:read_component(component_name)
	end)

	return ok and component or nil
end

local hud_icon_from_weapon_template
local hud_icon_from_master_item_name

local function item_hud_icon_from_slot(inventory_component, visual_loadout_extension, slot_name)
	if not inventory_component then
		return nil
	end

	local item_name = inventory_component[slot_name]
	local hud_icon

	if visual_loadout_extension and type(visual_loadout_extension.weapon_template_from_slot) == "function" then
		local ok_weapon_template, weapon_template = item_name and safe_call(visual_loadout_extension, "weapon_template_from_slot", slot_name)

		if ok_weapon_template then
			hud_icon = hud_icon_from_weapon_template(weapon_template)
		end
	end

	if hud_icon then
		return hud_icon
	end

	return hud_icon_from_master_item_name(item_name)
end

local function is_human_controlled(player)
	if type(player) ~= "table" or type(player.is_human_controlled) ~= "function" then
		return true
	end

	local ok, human_controlled = pcall(function()
		return player:is_human_controlled()
	end)

	return not ok or human_controlled == true
end

local function player_profile(player)
	if type(player) ~= "table" or type(player.profile) ~= "function" then
		return nil
	end

	local ok, profile = pcall(function()
		return player:profile()
	end)

	return ok and profile or nil
end

hud_icon_from_weapon_template = function(weapon_template)
	if not weapon_template then
		return nil
	end

	local hud_icon = weapon_template.hud_icon_small

	if type(hud_icon) == "string" and hud_icon ~= "" then
		return hud_icon
	end

	hud_icon = weapon_template.hud_icon

	if type(hud_icon) == "string" and hud_icon ~= "" then
		return hud_icon
	end

	return nil
end

local function hud_icon_from_item(item)
	local weapon_template = WeaponTemplate.weapon_template_from_item(item)

	return hud_icon_from_weapon_template(weapon_template)
end

local function master_item_from_name(item_name)
	if type(item_name) ~= "string" or item_name == "" then
		return nil
	end

	local ok, item = pcall(function()
		return MasterItems.get_item(item_name)
	end)

	if not ok or not item then
		return nil
	end

	return item
end

hud_icon_from_master_item_name = function(item_name)
	return hud_icon_from_item(master_item_from_name(item_name))
end

local function weapon_template_id_from_slot(inventory_component, slot_name)
	if not inventory_component then
		return nil
	end

	local item_name = inventory_component[slot_name]
	local item = master_item_from_name(item_name)
	local weapon_template_id = item and item.weapon_template

	return type(weapon_template_id) == "string" and weapon_template_id or nil
end

local function grenade_hud_icon_from_profile(player)
	local profile = player_profile(player)
	local loadout = profile and profile.loadout
	local item = loadout and loadout[GRENADE_ABILITY_SLOT_NAME]

	return hud_icon_from_item(item)
end

local function equipped_abilities(ability_extension)
	local ok, abilities = safe_call(ability_extension, "equipped_abilities")

	return ok and abilities or nil
end

local function grenade_hud_icon(player, inventory_component, visual_loadout_extension, ability_extension)
	local hud_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, GRENADE_ABILITY_SLOT_NAME)

	if hud_icon then
		return hud_icon
	end

	hud_icon = grenade_hud_icon_from_profile(player)

	if hud_icon then
		return hud_icon
	end

	local abilities = equipped_abilities(ability_extension)
	local ability = abilities and abilities[GRENADE_ABILITY_ID]
	local inventory_item_name = ability and ability.inventory_item_name

	hud_icon = hud_icon_from_master_item_name(inventory_item_name)

	if hud_icon then
		return hud_icon
	end

	local ability_template_name = ability and ability.ability_template
	local ability_template = ability_template_name and AbilityTemplates[ability_template_name]

	return ability_template and (ability_template.hud_icon_small or ability_template.hud_icon) or ability and ability.hud_icon
end

local function grenade_status(player, ability_extension)
	if not is_human_controlled(player) then
		return MAX_STATUS, true
	end

	local abilities = equipped_abilities(ability_extension)
	local ability = abilities and abilities[GRENADE_ABILITY_ID]

	if not ability then
		return MAX_STATUS, false
	end

	local ok_max, max_ability_charges = safe_call(ability_extension, "max_ability_charges", GRENADE_ABILITY_ID)
	local ok_remaining, remaining_ability_charges = safe_call(ability_extension, "remaining_ability_charges", GRENADE_ABILITY_ID)

	if not ok_max or not ok_remaining or type(max_ability_charges) ~= "number" or type(remaining_ability_charges) ~= "number" then
		return MAX_STATUS, true
	end

	if max_ability_charges > 0 then
		local ability_charges_fraction = remaining_ability_charges / max_ability_charges
		local ability_charges_status = math.ceil(ability_charges_fraction / (1 / MAX_STATUS))

		if max_ability_charges == 1 and remaining_ability_charges == 1 then
			ability_charges_status = MAX_STATUS
		elseif max_ability_charges == 2 and remaining_ability_charges == 1 then
			ability_charges_status = 2
		end

		return ability_charges_status, true
	elseif max_ability_charges == 0 then
		return MAX_STATUS, true
	end

	return 0, true
end

local function weapon_ammo_status(player, unit_data_extension, visual_loadout_extension)
	if not is_human_controlled(player) then
		return true, MAX_STATUS, true
	end

	if not unit_data_extension or not visual_loadout_extension then
		return false, MAX_STATUS, false
	end

	local total_current_ammo = 0
	local total_max_ammo = 0
	local uses_ammo = false

	for i = 1, #WEAPON_SLOTS do
		local slot_name = WEAPON_SLOTS[i]
		local has_component = true

		if type(unit_data_extension.has_component) == "function" then
			local ok, result = pcall(function()
				return unit_data_extension:has_component(slot_name)
			end)

			has_component = ok and result == true
		end

		if has_component then
			local inventory_component = safe_read_component(unit_data_extension, slot_name)
			local ok_weapon_template, weapon_template = safe_call(visual_loadout_extension, "weapon_template_from_slot", slot_name)
			local hud_configuration = ok_weapon_template and weapon_template and weapon_template.hud_configuration
			local uses_ammunition = hud_configuration and hud_configuration.uses_ammunition

			if inventory_component and uses_ammunition then
				uses_ammo = true

				local max_clip = Ammo.max_ammo_in_clips(inventory_component) or 0
				local max_reserve = inventory_component.max_ammunition_reserve or 0
				local current_clip = Ammo.current_ammo_in_clips(inventory_component) or 0
				local current_reserve = inventory_component.current_ammunition_reserve or 0

				total_current_ammo = total_current_ammo + current_clip + current_reserve
				total_max_ammo = total_max_ammo + max_clip + max_reserve
			end
		end
	end

	local ammo_status = MAX_STATUS

	if total_max_ammo > 0 then
		local weapon_ammo_fraction = total_current_ammo / total_max_ammo

		ammo_status = math.ceil(weapon_ammo_fraction / (1 / MAX_STATUS))
	end

	return uses_ammo, ammo_status, true
end

local function expedition_salvage_text(player)
	local game_mode_manager = Managers.state and Managers.state.game_mode
	local game_mode = game_mode_manager and game_mode_manager:game_mode()
	local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()

	if game_mode_name ~= "expedition" or not game_mode or type(game_mode.expedition_currency) ~= "function" then
		return nil
	end

	if not is_human_controlled(player) then
		return nil
	end

	local peer_id = type(player) == "table" and type(player.peer_id) == "function" and player:peer_id() or nil

	if not peer_id then
		return nil
	end

	local ok, amount = pcall(function()
		return game_mode:expedition_currency(peer_id)
	end)

	if not ok then
		return nil
	end

	amount = tonumber(amount) or 0

	local salvage_settings = WalletSettings.expedition_salvage
	local string_symbol = salvage_settings and salvage_settings.string_symbol or ""
	local amount_text = Text.format_currency(math.floor(amount + 0.5))

	if string_symbol == "" then
		return amount_text
	end

	return string.format("%s %s", string_symbol, amount_text)
end

function M.icons(player, extensions, status)
	if status == "dead" or status == "hogtied" then
		return {
			ammo_icon = nil,
			grenade_icon = nil,
			pocketable_icon = nil,
			pocketable_small_icon = nil,
			salvage_text = nil,
		}
	end

	local unit_data_extension = extensions and extensions.unit_data
	local visual_loadout_extension = extensions and extensions.visual_loadout
	local ability_extension = extensions and extensions.ability

	local inventory_component = safe_read_component(unit_data_extension, "inventory")
	local grenade_icon = grenade_hud_icon(player, inventory_component, visual_loadout_extension, ability_extension)
	local grenade_ability_status, grenade_visible = grenade_status(player, ability_extension)
	local uses_ammo, ammo_status, ammo_visible = weapon_ammo_status(player, unit_data_extension, visual_loadout_extension)
	local pocketable_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, POCKETABLE_SLOT_NAME)
	local pocketable_template_id = weapon_template_id_from_slot(inventory_component, POCKETABLE_SLOT_NAME)
	local pocketable_small_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, POCKETABLE_SMALL_SLOT_NAME)
	local pocketable_small_template_id = weapon_template_id_from_slot(inventory_component, POCKETABLE_SMALL_SLOT_NAME)
	local salvage_text = expedition_salvage_text(player)

	return {
		ammo_icon = ammo_visible and AMMO_ICON or nil,
		ammo_status = ammo_status,
		grenade_icon = (grenade_visible or grenade_icon ~= nil) and grenade_icon or nil,
		grenade_status = grenade_ability_status,
		pocketable_icon = pocketable_icon,
		pocketable_template_id = pocketable_template_id,
		pocketable_small_icon = pocketable_small_icon,
		pocketable_small_template_id = pocketable_small_template_id,
		salvage_text = salvage_text,
		uses_ammo = uses_ammo,
	}
end

return M
