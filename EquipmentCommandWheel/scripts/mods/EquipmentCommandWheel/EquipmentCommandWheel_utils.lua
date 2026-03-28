local mod = get_mod("EquipmentCommandWheel")

local HudElementPlayerWeaponHandlerSettings = require("scripts/ui/hud/elements/player_weapon_handler/hud_element_player_weapon_handler_settings")
local ItemSlotSettings = require("scripts/settings/item/item_slot_settings")

local function sort_equipment_entries_by_order(a, b)
	return a.order_index < b.order_index
end

local function collect_equipment_wheel_slots(extensions)
	if not extensions then
		return {}
	end

	local visual_loadout_extension = extensions.visual_loadout
	local unit_data = extensions.unit_data
	local ability_extension = extensions.ability

	if not visual_loadout_extension or not unit_data or not ability_extension then
		return {}
	end

	local inventory_component = unit_data:read_component("inventory")
	local equipped_abilities = ability_extension:equipped_abilities()
	local grenade_ability = equipped_abilities.grenade_ability
	local slots_settings = HudElementPlayerWeaponHandlerSettings.slots_settings
	local max_slots = table.size(slots_settings)
	local num_weapons = 0
	local entries = {}

	for slot_id, settings in pairs(slots_settings) do
		local item_slot_settings = ItemSlotSettings[slot_id]
		local weapon_name

		if settings.ability then
			local ability_name = grenade_ability and grenade_ability.name

			weapon_name = inventory_component[slot_id] ~= "not_equipped" and inventory_component[slot_id] or ability_name or "not_equipped"
		else
			weapon_name = inventory_component[slot_id]
		end

		local weapon_template = weapon_name and visual_loadout_extension:weapon_template_from_slot(slot_id)
		local item = weapon_name and visual_loadout_extension:item_from_slot(slot_id)

		if weapon_template and not weapon_template.hide_slot and num_weapons < max_slots then
			local order_index = settings.order_index
			local icon = weapon_template.hud_icon

			if not icon and item then
				icon = item.hud_icon
			end

			if not icon then
				icon = settings.default_icon
			end

			if not icon then
				icon = "content/ui/materials/base/ui_default_base"
			end

			local label_key = item_slot_settings and item_slot_settings.display_name or "loc_ingame_grenade_ability"

			entries[#entries + 1] = {
				slot_id = slot_id,
				icon = icon,
				label_key = label_key,
				order_index = order_index,
			}
			num_weapons = num_weapons + 1
		elseif not weapon_template and settings.ability and grenade_ability and grenade_ability.hud_configuration and num_weapons < max_slots then
			local order_index = settings.order_index
			local icon = grenade_ability.hud_icon

			if not icon then
				icon = settings.default_icon
			end

			if not icon then
				icon = "content/ui/materials/base/ui_default_base"
			end

			local label_key = item_slot_settings and item_slot_settings.display_name or "loc_ingame_grenade_ability"

			entries[#entries + 1] = {
				slot_id = slot_id,
				icon = icon,
				label_key = label_key,
				order_index = order_index,
			}
			num_weapons = num_weapons + 1
		end
	end

	table.sort(entries, sort_equipment_entries_by_order)

	return entries
end

local EQUIPMENT_WHEEL_DISALLOWED_GAME_MODES = {
	hub = true,
	hub_singleplay = true,
	prologue_hub = true,
}

local function is_equipment_wheel_game_mode_allowed()
	if not Managers or not Managers.state or not Managers.state.game_mode then
		return false
	end

	local game_mode_name = Managers.state.game_mode:game_mode_name()

	if not game_mode_name then
		return false
	end

	if EQUIPMENT_WHEEL_DISALLOWED_GAME_MODES[game_mode_name] then
		return false
	end

	return true
end

local function is_equipment_wheel_context_valid(parent)
	if not is_equipment_wheel_game_mode_allowed() then
		return false
	end

	if not parent or not parent.player or not parent.player_extensions then
		return false
	end

	local extensions = parent:player_extensions()

	if not extensions or not extensions.unit_data or not extensions.visual_loadout then
		return false
	end

	local player = parent:player()

	if not player then
		return false
	end

	local unit = player.player_unit

	if not unit or not ALIVE[unit] then
		return false
	end

	return true
end

local function localize_text(label_key)
	if not label_key then
		return ""
	end

	if string.sub(label_key, 1, 4) == "loc_" then
		return Localize(label_key)
	end

	return mod:localize(label_key)
end

local function find_device_for_key(key, supported_devices)
	if not key or not supported_devices then
		return nil
	end

	for _, device_type in ipairs(supported_devices) do
		local device = Managers.input:_find_active_device(device_type)

		if device then
			local index = device:button_index(key)

			if index then
				return {
					device = device,
					index = index,
				}
			end
		end
	end

	return nil
end

local function apply_style_offset(style, offset_x, offset_y)
	if style then
		style.offset[1] = offset_x
		style.offset[2] = offset_y
	end
end

local function apply_style_color(style, color)
	if style and color then
		style.color[1] = color[1]
		style.color[2] = color[2]
		style.color[3] = color[3]
		style.color[4] = color[4]
	end
end

return {
	collect_equipment_wheel_slots = collect_equipment_wheel_slots,
	is_equipment_wheel_game_mode_allowed = is_equipment_wheel_game_mode_allowed,
	is_equipment_wheel_context_valid = is_equipment_wheel_context_valid,
	localize_text = localize_text,
	find_device_for_key = find_device_for_key,
	apply_style_offset = apply_style_offset,
	apply_style_color = apply_style_color,
}
