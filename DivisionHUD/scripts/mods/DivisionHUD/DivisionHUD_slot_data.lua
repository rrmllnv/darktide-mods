--[[
	Статические пути иконок (взяты из Darktide-Source-Code):
	- DEFAULT_GRENADE_FLAT_ICON … scripts/ui/hud/elements/player_weapon_handler/hud_element_player_weapon_handler_settings.lua (slot_grenade_ability.default_icon)
	- DEFAULT_POCKETABLE_ICON_AMMO … scripts/settings/equipment/weapon_templates/pocketables/ammo_cache_pocketable.lua (weapon_template.hud_icon_small)
	- DEFAULT_STIM_ICON_HEAL … scripts/settings/equipment/weapon_templates/pocketables/syringe_corruption_pocketable.lua (hud_icon_small)
	- DEFAULT_COMBAT_ABILITY_PLACEHOLDER … scripts/settings/ability/player_abilities/abilities/psyker_abilities.lua (hud_icon для гранатных слотов, throwables/default)
	Материал пасса текстуры для HUD-иконок (не подставлять ui_default_base):
	- content/ui/materials/hud/icons/weapon_icon_container … hud_element_player_weapon_definitions.lua, EquipmentCommandWheel_definitions.lua
]]

local AbilityTemplates = require("scripts/settings/ability/ability_templates/ability_templates")
local HudElementPlayerWeaponHandlerSettings = require("scripts/ui/hud/elements/player_weapon_handler/hud_element_player_weapon_handler_settings")

local VALID_DEVICE_ITEM_NAMES = {
	["content/items/devices/auspex_map"] = true,
}

local DEFAULT_COMBAT_ABILITY_PLACEHOLDER = "content/ui/materials/icons/abilities/throwables/default"
local DEFAULT_GRENADE_FLAT_ICON = "content/ui/materials/icons/weapons/flat/grenade"
local DEFAULT_POCKETABLE_ICON_AMMO = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate"
local DEFAULT_STIM_ICON_HEAL = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption"

local AMMO_BOX_WEAPON_NAMES = {
	ammo_cache_pocketable = true,
	medical_crate_pocketable = true,
}

local function has_meaningful_hud_icon(icon)
	return type(icon) == "string"
		and icon ~= ""
		and icon ~= "content/ui/materials/base/ui_default_base"
end

local function default_stim_icon_for_archetype()
	return DEFAULT_STIM_ICON_HEAL
end

local function slot_fallback_icon_for_slot(slot_id, settings)
	if slot_id == "slot_pocketable_small" then
		return default_stim_icon_for_archetype()
	end

	if slot_id == "slot_pocketable" then
		return DEFAULT_POCKETABLE_ICON_AMMO
	end

	if settings and settings.default_icon then
		return settings.default_icon
	end

	return DEFAULT_GRENADE_FLAT_ICON
end

local function guaranteed_icon(icon, slot_id, settings)
	if has_meaningful_hud_icon(icon) then
		return icon
	end

	local fb = slot_fallback_icon_for_slot(slot_id, settings)

	if has_meaningful_hud_icon(fb) then
		return fb
	end

	if settings and has_meaningful_hud_icon(settings.default_icon) then
		return settings.default_icon
	end

	return DEFAULT_GRENADE_FLAT_ICON
end

local function resolve_template_and_item_icon(weapon_template, item)
	if not weapon_template and not item then
		return nil
	end

	local icon = weapon_template and weapon_template.hud_icon

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	icon = weapon_template and weapon_template.hud_icon_small

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	icon = item and item.hud_icon

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	icon = item and item.hud_icon_small

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	return nil
end

local function override_slot_icon(slot_id, weapon_name)
	if slot_id == "slot_pocketable" and weapon_name and AMMO_BOX_WEAPON_NAMES[weapon_name] then
		return DEFAULT_POCKETABLE_ICON_AMMO
	end

	return nil
end

local function resolve_grenade_ability_icon(grenade_ability, settings)
	if not grenade_ability then
		return nil
	end

	local icon = grenade_ability.hud_icon_small

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	icon = grenade_ability.hud_icon

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	local template_name = grenade_ability.ability_template
	local ability_template = template_name and AbilityTemplates[template_name]

	if ability_template then
		icon = ability_template.hud_icon_small or ability_template.hud_icon

		if has_meaningful_hud_icon(icon) then
			return icon
		end
	end

	if settings and has_meaningful_hud_icon(settings.default_icon) then
		return settings.default_icon
	end

	return nil
end

local function resolve_weapon_handler_slot(slot_id, settings, extensions)
	local visual_loadout_extension = extensions.visual_loadout
	local unit_data = extensions.unit_data
	local ability_extension = extensions.ability

	if not visual_loadout_extension or not unit_data or not ability_extension then
		return {
			slot_id = slot_id,
			icon = guaranteed_icon(nil, slot_id, settings),
			has_equipment = false,
			weapon_template = nil,
			item = nil,
		}
	end

	local inventory_component = unit_data:read_component("inventory")
	local equipped_abilities = ability_extension:equipped_abilities()
	local grenade_ability = equipped_abilities and equipped_abilities.grenade_ability
	local weapon_name

	if settings.ability then
		local ability_name = grenade_ability and grenade_ability.name
		weapon_name = inventory_component[slot_id] ~= "not_equipped" and inventory_component[slot_id] or ability_name or "not_equipped"
	else
		weapon_name = inventory_component[slot_id]
	end

	local weapon_template = weapon_name and visual_loadout_extension:weapon_template_from_slot(slot_id)
	local item = weapon_name and visual_loadout_extension:item_from_slot(slot_id)
	local allow_hidden_template = false

	if slot_id == "slot_device" and VALID_DEVICE_ITEM_NAMES[weapon_name] then
		allow_hidden_template = true
	end

	if weapon_template and weapon_template.hide_slot and not allow_hidden_template and settings.ability and grenade_ability and grenade_ability.hud_configuration then
		local icon = guaranteed_icon(resolve_grenade_ability_icon(grenade_ability, settings), slot_id, settings)

		return {
			slot_id = slot_id,
			icon = icon,
			has_equipment = true,
			weapon_template = weapon_template,
			item = item,
			grenade_ability = grenade_ability,
		}
	end

	if weapon_template and (not weapon_template.hide_slot or allow_hidden_template) then
		local icon = resolve_template_and_item_icon(weapon_template, item)

		icon = override_slot_icon(slot_id, weapon_name) or icon
		icon = guaranteed_icon(icon, slot_id, settings)

		return {
			slot_id = slot_id,
			icon = icon,
			has_equipment = true,
			weapon_template = weapon_template,
			item = item,
		}
	end

	if not weapon_template and settings.ability and grenade_ability and grenade_ability.hud_configuration then
		local icon = guaranteed_icon(resolve_grenade_ability_icon(grenade_ability, settings), slot_id, settings)

		return {
			slot_id = slot_id,
			icon = icon,
			has_equipment = true,
			weapon_template = nil,
			item = item,
			grenade_ability = grenade_ability,
		}
	end

	local empty_icon = slot_fallback_icon_for_slot(slot_id, settings)

	if slot_id == "slot_grenade_ability" and grenade_ability and grenade_ability.hud_configuration then
		local resolved = resolve_grenade_ability_icon(grenade_ability, settings)

		if has_meaningful_hud_icon(resolved) then
			empty_icon = resolved
		end
	end

	empty_icon = guaranteed_icon(empty_icon, slot_id, settings)

	return {
		slot_id = slot_id,
		icon = empty_icon,
		has_equipment = false,
		weapon_template = nil,
		item = nil,
	}
end

local function resolve_combat_ability_slot(extensions)
	local ability_extension = extensions.ability

	if not ability_extension then
		return {
			slot_id = "slot_combat_ability",
			icon = DEFAULT_COMBAT_ABILITY_PLACEHOLDER,
			has_equipment = false,
			combat_ability = nil,
		}
	end

	local equipped_abilities = ability_extension:equipped_abilities()
	local combat_ability = equipped_abilities and equipped_abilities.combat_ability

	if not combat_ability then
		return {
			slot_id = "slot_combat_ability",
			icon = DEFAULT_COMBAT_ABILITY_PLACEHOLDER,
			has_equipment = false,
			combat_ability = nil,
		}
	end

	local icon = combat_ability.hud_icon_small or combat_ability.hud_icon or DEFAULT_COMBAT_ABILITY_PLACEHOLDER

	if not has_meaningful_hud_icon(icon) then
		icon = DEFAULT_COMBAT_ABILITY_PLACEHOLDER
	end

	return {
		slot_id = "slot_combat_ability",
		icon = icon,
		has_equipment = true,
		combat_ability = combat_ability,
	}
end

local function build_division_right_slots(extensions)
	local slots_settings = HudElementPlayerWeaponHandlerSettings.slots_settings

	return {
		resolve_weapon_handler_slot("slot_grenade_ability", slots_settings.slot_grenade_ability, extensions),
		resolve_weapon_handler_slot("slot_pocketable_small", slots_settings.slot_pocketable_small, extensions),
		resolve_weapon_handler_slot("slot_pocketable", slots_settings.slot_pocketable, extensions),
		resolve_combat_ability_slot(extensions),
	}
end

return {
	build_division_right_slots = build_division_right_slots,
	DEFAULT_COMBAT_ABILITY_PLACEHOLDER = DEFAULT_COMBAT_ABILITY_PLACEHOLDER,
	DEFAULT_GRENADE_FLAT_ICON = DEFAULT_GRENADE_FLAT_ICON,
	HUD_WEAPON_ICON_CONTAINER_MATERIAL = "content/ui/materials/hud/icons/weapon_icon_container",
	VALID_DEVICE_ITEM_NAMES = VALID_DEVICE_ITEM_NAMES,
	DEFAULT_POCKETABLE_ICON_AMMO = DEFAULT_POCKETABLE_ICON_AMMO,
	DEFAULT_STIM_ICON_HEAL = DEFAULT_STIM_ICON_HEAL,
}

