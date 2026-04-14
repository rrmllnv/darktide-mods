local AbilityTemplates = require("scripts/settings/ability/ability_templates/ability_templates")
local HudElementPlayerWeaponHandlerSettings = require("scripts/ui/hud/elements/player_weapon_handler/hud_element_player_weapon_handler_settings")

local VALID_DEVICE_ITEM_NAMES = {
	["content/items/devices/auspex_map"] = true,
}

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

local function resolve_team_player_panel_grenade_throwable_hud_icon(inventory_component, visual_loadout_extension, ability_extension)
	local hud_icon

	if inventory_component and visual_loadout_extension then
		local item_name = inventory_component.slot_grenade_ability
		local weapon_template = item_name and select(1, visual_loadout_extension:weapon_template_from_slot("slot_grenade_ability"))

		if weapon_template then
			hud_icon = weapon_template.hud_icon_small
		end
	end

	if not hud_icon and ability_extension then
		local equipped_abilities = ability_extension:equipped_abilities()
		local ability = equipped_abilities and equipped_abilities.grenade_ability
		local ability_template_name = ability and ability.ability_template
		local ability_template = ability_template_name and AbilityTemplates[ability_template_name]

		hud_icon = ability_template and ability_template.hud_icon_small
	end

	return hud_icon
end

local function resolve_grenade_ability_icon(grenade_ability, settings)
	if not grenade_ability then
		return nil
	end

	local icon = grenade_ability.hud_icon

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	icon = grenade_ability.hud_icon_small

	if has_meaningful_hud_icon(icon) then
		return icon
	end

	local template_name = grenade_ability.ability_template
	local ability_template = template_name and AbilityTemplates[template_name]

	if ability_template then
		icon = ability_template.hud_icon

		if has_meaningful_hud_icon(icon) then
			return icon
		end

		icon = ability_template.hud_icon_small

		if has_meaningful_hud_icon(icon) then
			return icon
		end
	end

	if settings and has_meaningful_hud_icon(settings.default_icon) then
		return settings.default_icon
	end

	return nil
end

local function resolve_wielded_slot_icon_as_equipment_wheel_collects(wielded_slot, extensions)
	local visual_loadout_extension = extensions.visual_loadout
	local unit_data = extensions.unit_data
	local ability_extension = extensions.ability
	local slots_settings = HudElementPlayerWeaponHandlerSettings.slots_settings
	local settings = slots_settings[wielded_slot]

	if not visual_loadout_extension or not unit_data or not ability_extension or not settings then
		return DEFAULT_GRENADE_FLAT_ICON, nil, nil, false
	end

	local inventory_component = unit_data:read_component("inventory")
	local equipped_abilities = ability_extension:equipped_abilities()
	local grenade_ability = equipped_abilities and equipped_abilities.grenade_ability
	local weapon_name

	if settings.ability then
		local ability_name = grenade_ability and grenade_ability.name

		weapon_name = inventory_component[wielded_slot] ~= "not_equipped" and inventory_component[wielded_slot] or ability_name or "not_equipped"
	else
		weapon_name = inventory_component[wielded_slot]
	end

	local weapon_template = weapon_name and visual_loadout_extension:weapon_template_from_slot(wielded_slot)
	local item = weapon_name and visual_loadout_extension:item_from_slot(wielded_slot)
	local weapon_template_icon = weapon_template and weapon_template.hud_icon
	local item_icon = item and item.hud_icon
	local allow_hidden_template = false

	if wielded_slot == "slot_device" and VALID_DEVICE_ITEM_NAMES[weapon_name] then
		allow_hidden_template = true
	end

	local icon
	local has_equipment

	if weapon_template and (not weapon_template.hide_slot or allow_hidden_template) then
		icon = weapon_template_icon

		if not icon then
			icon = item_icon
		end

		if not has_meaningful_hud_icon(icon) then
			icon = settings.default_icon
		end

		if not icon then
			icon = "content/ui/materials/base/ui_default_base"
		end

		has_equipment = true
	elseif weapon_template and weapon_template.hide_slot and not allow_hidden_template and settings.ability and grenade_ability and grenade_ability.hud_configuration then
		icon = grenade_ability.hud_icon

		if not icon then
			icon = settings.default_icon
		end

		if not icon then
			icon = "content/ui/materials/base/ui_default_base"
		end

		has_equipment = true
	elseif not weapon_template and settings.ability and grenade_ability and grenade_ability.hud_configuration then
		icon = grenade_ability.hud_icon

		if not icon then
			icon = settings.default_icon
		end

		if not icon then
			icon = "content/ui/materials/base/ui_default_base"
		end

		has_equipment = true
	else
		icon = guaranteed_icon(settings and settings.default_icon, wielded_slot, settings)
		has_equipment = weapon_name ~= nil and weapon_name ~= "not_equipped"
	end

	return icon, weapon_template, item, has_equipment
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

	if slot_id == "slot_grenade_ability" then
		local team_panel_hud_icon = resolve_team_player_panel_grenade_throwable_hud_icon(inventory_component, visual_loadout_extension, ability_extension)
		local icon = guaranteed_icon(team_panel_hud_icon, slot_id, settings)
		local weapon_template = select(1, visual_loadout_extension:weapon_template_from_slot(slot_id))
		local item = visual_loadout_extension:item_from_slot(slot_id)

		return {
			slot_id = slot_id,
			icon = icon,
			has_equipment = weapon_name ~= nil and weapon_name ~= "not_equipped",
			weapon_template = weapon_template,
			item = item,
		}
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

local function try_weapon_handler_wield_slot(slot_id, slots_settings)
	if slot_id and slot_id ~= "none" and slots_settings[slot_id] then
		return slot_id
	end

	return nil
end

local function try_weapon_strip_display_slot(slot_id, slots_settings)
	if slot_id ~= "slot_primary" and slot_id ~= "slot_secondary" then
		return nil
	end

	return try_weapon_handler_wield_slot(slot_id, slots_settings)
end

local function pick_division_hud_wielded_display_slot(inventory_component, slots_settings, default_wield_slot, cached_slot_id)
	if not slots_settings then
		return nil
	end

	if not inventory_component then
		return try_weapon_strip_display_slot(cached_slot_id, slots_settings)
			or try_weapon_strip_display_slot(default_wield_slot, slots_settings)
			or try_weapon_strip_display_slot("slot_primary", slots_settings)
	end

	local current = try_weapon_strip_display_slot(inventory_component.wielded_slot, slots_settings)

	if current then
		return current
	end

	return try_weapon_strip_display_slot(cached_slot_id, slots_settings)
		or try_weapon_strip_display_slot(inventory_component.previously_wielded_weapon_slot, slots_settings)
		or try_weapon_strip_display_slot(inventory_component.previously_wielded_slot, slots_settings)
		or try_weapon_strip_display_slot(default_wield_slot, slots_settings)
		or try_weapon_strip_display_slot("slot_primary", slots_settings)
end

local function resolve_wielded_weapon_display_entry(extensions, cached_slot_id)
	local slots_settings = HudElementPlayerWeaponHandlerSettings.slots_settings
	local default_wield_slot

	for slot_id_iter, slot_settings in pairs(slots_settings) do
		if slot_settings.default_wield_slot then
			default_wield_slot = slot_id_iter

			break
		end
	end

	local unit_data = extensions.unit_data
	local inventory_component = unit_data:read_component("inventory")
	local wielded_slot = pick_division_hud_wielded_display_slot(inventory_component, slots_settings, default_wield_slot, cached_slot_id)
	local settings = wielded_slot and slots_settings[wielded_slot]

	if not settings then
		return {
			slot_id = "slot_wielded_display",
			wielded_source_slot_id = nil,
			icon = DEFAULT_GRENADE_FLAT_ICON,
			has_equipment = false,
			weapon_template = nil,
			item = nil,
		}
	end

	local icon, weapon_template, item, has_equipment = resolve_wielded_slot_icon_as_equipment_wheel_collects(wielded_slot, extensions)

	if not has_meaningful_hud_icon(icon) then
		icon = guaranteed_icon(nil, wielded_slot, settings)
	end

	return {
		slot_id = "slot_wielded_display",
		wielded_source_slot_id = wielded_slot,
		icon = icon,
		has_equipment = has_equipment,
		weapon_template = weapon_template,
		item = item,
	}
end

local function resolve_auspex_display_entry(extensions)
	local slots_settings = HudElementPlayerWeaponHandlerSettings.slots_settings
	local device_settings = slots_settings and slots_settings.slot_device

	if not device_settings or not extensions.unit_data then
		return {
			slot_id = "slot_auspex_display",
			icon = nil,
			has_equipment = false,
			weapon_template = nil,
			item = nil,
		}
	end

	local inventory_component = extensions.unit_data:read_component("inventory")
	local weapon_name = inventory_component and inventory_component.slot_device

	if not weapon_name or weapon_name == "not_equipped" or not VALID_DEVICE_ITEM_NAMES[weapon_name] then
		return {
			slot_id = "slot_auspex_display",
			icon = nil,
			has_equipment = false,
			weapon_template = nil,
			item = nil,
		}
	end

	local resolved = resolve_weapon_handler_slot("slot_device", device_settings, extensions)

	return {
		slot_id = "slot_auspex_display",
		icon = resolved.icon,
		has_equipment = resolved.has_equipment,
		weapon_template = resolved.weapon_template,
		item = resolved.item,
	}
end

local function build_division_right_slots(extensions, cached_slot_id)
	local slots_settings = HudElementPlayerWeaponHandlerSettings.slots_settings

	return {
		resolve_wielded_weapon_display_entry(extensions, cached_slot_id),
		resolve_weapon_handler_slot("slot_grenade_ability", slots_settings.slot_grenade_ability, extensions),
		resolve_weapon_handler_slot("slot_pocketable_small", slots_settings.slot_pocketable_small, extensions),
		resolve_weapon_handler_slot("slot_pocketable", slots_settings.slot_pocketable, extensions),
	}
end

return {
	build_division_right_slots = build_division_right_slots,
	resolve_auspex_display_entry = resolve_auspex_display_entry,
	DEFAULT_GRENADE_FLAT_ICON = DEFAULT_GRENADE_FLAT_ICON,
	HUD_WEAPON_ICON_CONTAINER_MATERIAL = "content/ui/materials/hud/icons/weapon_icon_container",
	VALID_DEVICE_ITEM_NAMES = VALID_DEVICE_ITEM_NAMES,
	DEFAULT_POCKETABLE_ICON_AMMO = DEFAULT_POCKETABLE_ICON_AMMO,
	DEFAULT_STIM_ICON_HEAL = DEFAULT_STIM_ICON_HEAL,
}
