local AbilityTemplates = require("scripts/settings/ability/ability_templates/ability_templates")
local Ammo = require("scripts/utilities/ammo")
local MasterItems = require("scripts/backend/master_items")
local Text = require("scripts/utilities/ui/text")
local WalletSettings = require("scripts/settings/wallet_settings")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

local M = {}

local pcall = pcall

local POCKETABLE_SLOT_NAME = "slot_pocketable"
local POCKETABLE_SMALL_SLOT_NAME = "slot_pocketable_small"
local GRENADE_ABILITY_SLOT_NAME = "slot_grenade_ability"
local GRENADE_ABILITY_ID = "grenade_ability"
local RANGED_SLOT_NAME = "slot_secondary"
local AMMO_ICON = "content/ui/materials/hud/icons/party_ammo"
local MAX_STATUS = 3
local AMMO_UPDATE_INTERVAL = 0.1
local NO_ICONS = {}

-- Per player (weak keys, so a player who leaves is dropped): the reused result table and the last ammo read
local icons_by_player = setmetatable({}, { __mode = "k" })
local ammo_by_player = setmetatable({}, { __mode = "k" })

-- Item name -> master item hud icon / weapon template id (false for none). Both are fixed per item, so only lookups
-- that found the item are kept, and an item that isn't loaded yet is looked up again.
local icon_by_item_name = {}
local template_id_by_item_name = {}

local WEAPON_SLOTS = {
	"slot_primary",
	"slot_secondary",
}

local function safe_call(object, method_name, ...)
	local method = object and object[method_name]

	if type(method) ~= "function" then
		return false, nil
	end

	return pcall(method, object, ...)
end

local function safe_read_component(unit_data_extension, component_name)
	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return nil
	end

	local ok, component = pcall(unit_data_extension.read_component, unit_data_extension, component_name)

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

	local ok, human_controlled = pcall(player.is_human_controlled, player)

	return not ok or human_controlled == true
end

local function player_profile(player)
	if type(player) ~= "table" or type(player.profile) ~= "function" then
		return nil
	end

	local ok, profile = pcall(player.profile, player)

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

	local ok, item = pcall(MasterItems.get_item, item_name)

	if not ok or not item then
		return nil
	end

	return item
end

hud_icon_from_master_item_name = function(item_name)
	local icon = icon_by_item_name[item_name]

	if icon ~= nil then
		return icon or nil
	end

	local item = master_item_from_name(item_name)

	if not item then
		return nil
	end

	icon = hud_icon_from_item(item)
	icon_by_item_name[item_name] = icon or false

	return icon
end

local function weapon_template_id_from_slot(inventory_component, slot_name)
	if not inventory_component then
		return nil
	end

	local item_name = inventory_component[slot_name]
	local template_id = template_id_by_item_name[item_name]

	if template_id ~= nil then
		return template_id or nil
	end

	local item = master_item_from_name(item_name)

	if not item then
		return nil
	end

	local weapon_template_id = item.weapon_template

	template_id = type(weapon_template_id) == "string" and weapon_template_id or false
	template_id_by_item_name[item_name] = template_id

	return template_id or nil
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
		return MAX_STATUS, true, nil, nil
	end

	local abilities = equipped_abilities(ability_extension)
	local ability = abilities and abilities[GRENADE_ABILITY_ID]

	if not ability then
		return MAX_STATUS, false, nil, nil
	end

	local ok_max, max_ability_charges = safe_call(ability_extension, "max_ability_charges", GRENADE_ABILITY_ID)
	local ok_remaining, remaining_ability_charges = safe_call(ability_extension, "remaining_ability_charges", GRENADE_ABILITY_ID)

	if not ok_max or not ok_remaining or type(max_ability_charges) ~= "number" or type(remaining_ability_charges) ~= "number" then
		return MAX_STATUS, true, nil, nil
	end

	if max_ability_charges > 0 then
		local ability_charges_fraction = remaining_ability_charges / max_ability_charges
		local ability_charges_status = math.ceil(ability_charges_fraction / (1 / MAX_STATUS))

		if max_ability_charges == 1 and remaining_ability_charges == 1 then
			ability_charges_status = MAX_STATUS
		elseif max_ability_charges == 2 and remaining_ability_charges == 1 then
			ability_charges_status = 2
		end

		return ability_charges_status, true, remaining_ability_charges, max_ability_charges
	elseif max_ability_charges == 0 then
		return MAX_STATUS, true, nil, nil
	end

	return 0, true, remaining_ability_charges, max_ability_charges
end

local function weapon_ammo_status(player, unit_data_extension, visual_loadout_extension)
	if not is_human_controlled(player) then
		return true, MAX_STATUS, true, nil, nil, nil, nil, nil
	end

	if not unit_data_extension or not visual_loadout_extension then
		return false, MAX_STATUS, false, nil, nil, nil, nil, nil
	end

	local ranged_current_ammo
	local ranged_max_ammo
	local uses_ammo = false

	for i = 1, #WEAPON_SLOTS do
		local slot_name = WEAPON_SLOTS[i]
		local has_component = true

		if type(unit_data_extension.has_component) == "function" then
			local ok, result = pcall(unit_data_extension.has_component, unit_data_extension, slot_name)

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
				local free_transfer = inventory_component.free_ammunition_transfer == true
				local current_clip_for_total = free_transfer and 0 or current_clip
				local max_clip_for_total = free_transfer and 0 or max_clip

				if slot_name == RANGED_SLOT_NAME then
					ranged_current_ammo = current_clip_for_total + current_reserve
					ranged_max_ammo = max_clip_for_total + max_reserve
				end
			end
		end
	end

	local ammo_status = MAX_STATUS
	local ammo_fraction

	if ranged_max_ammo and ranged_max_ammo > 0 then
		local weapon_ammo_fraction = math.clamp((ranged_current_ammo or 0) / ranged_max_ammo, 0, 1)

		ammo_status = math.ceil(weapon_ammo_fraction / (1 / MAX_STATUS))
		ammo_fraction = weapon_ammo_fraction
	end

	return uses_ammo, ammo_status, true, ammo_fraction, ranged_current_ammo, ranged_max_ammo, ranged_current_ammo, ranged_max_ammo
end

-- Ammo only changes when a player shoots, reloads or picks some up, so it is read at most every AMMO_UPDATE_INTERVAL
-- per player, as NumericUI's team panel does. Without a time every call reads it.
local function throttled_weapon_ammo_status(player, unit_data_extension, visual_loadout_extension, t)
	local ammo = ammo_by_player[player]

	if ammo and t and t < ammo.next_t then
		return ammo[1], ammo[2], ammo[3], ammo[4], ammo[5], ammo[6], ammo[7], ammo[8]
	end

	local uses_ammo, ammo_status, ammo_visible, ammo_fraction, ammo_current, ammo_max, ammo_count_current, ammo_count_max = weapon_ammo_status(player, unit_data_extension, visual_loadout_extension)

	if t and type(player) == "table" then
		if not ammo then
			ammo = {}
			ammo_by_player[player] = ammo
		end

		ammo.next_t = t + AMMO_UPDATE_INTERVAL
		ammo[1], ammo[2], ammo[3], ammo[4] = uses_ammo, ammo_status, ammo_visible, ammo_fraction
		ammo[5], ammo[6], ammo[7], ammo[8] = ammo_current, ammo_max, ammo_count_current, ammo_count_max
	end

	return uses_ammo, ammo_status, ammo_visible, ammo_fraction, ammo_current, ammo_max, ammo_count_current, ammo_count_max
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

	local ok, amount = pcall(game_mode.expedition_currency, game_mode, peer_id)

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

-- t, when given, throttles the ammo reads. The returned table is reused for the player, so read it before the next call.
function M.icons(player, extensions, status, t)
	if status == "dead" or status == "hogtied" then
		-- read ammo straight away once they are back
		if type(player) == "table" then
			ammo_by_player[player] = nil
		end

		return NO_ICONS
	end

	local unit_data_extension = extensions and extensions.unit_data
	local visual_loadout_extension = extensions and extensions.visual_loadout
	local ability_extension = extensions and extensions.ability

	local inventory_component = safe_read_component(unit_data_extension, "inventory")
	local grenade_icon = grenade_hud_icon(player, inventory_component, visual_loadout_extension, ability_extension)
	local grenade_ability_status, grenade_visible, grenade_current, grenade_max = grenade_status(player, ability_extension)
	local uses_ammo, ammo_status, ammo_visible, ammo_fraction, ammo_current, ammo_max, ammo_count_current, ammo_count_max = throttled_weapon_ammo_status(player, unit_data_extension, visual_loadout_extension, t)
	local pocketable_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, POCKETABLE_SLOT_NAME)
	local pocketable_template_id = weapon_template_id_from_slot(inventory_component, POCKETABLE_SLOT_NAME)
	local pocketable_small_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, POCKETABLE_SMALL_SLOT_NAME)
	local pocketable_small_template_id = weapon_template_id_from_slot(inventory_component, POCKETABLE_SMALL_SLOT_NAME)
	local salvage_text = expedition_salvage_text(player)

	local result = icons_by_player[player]

	if not result then
		result = {}

		if type(player) == "table" then
			icons_by_player[player] = result
		end
	end

	result.ammo_icon = ammo_visible and AMMO_ICON or nil
	result.ammo_count_current = ammo_count_current
	result.ammo_count_max = ammo_count_max
	result.ammo_current = ammo_current
	result.ammo_fraction = ammo_fraction
	result.ammo_max = ammo_max
	result.ammo_percent = ammo_fraction and math.floor(ammo_fraction * 100 + 0.5) or nil
	result.ammo_status = ammo_status
	result.grenade_icon = (grenade_visible or grenade_icon ~= nil) and grenade_icon or nil
	result.grenade_current = grenade_current
	result.grenade_max = grenade_max
	result.grenade_status = grenade_ability_status
	result.pocketable_icon = pocketable_icon
	result.pocketable_template_id = pocketable_template_id
	result.pocketable_small_icon = pocketable_small_icon
	result.pocketable_small_template_id = pocketable_small_template_id
	result.salvage_text = salvage_text
	result.uses_ammo = uses_ammo

	return result
end

return M
