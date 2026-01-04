local mod = get_mod("TalentUI")

local MasterItems = require("scripts/backend/master_items")

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

local teammate_weapons_data = {}

local player_previous_human_state_weapons = {}

local WEAPON_SLOTS = mod.WEAPON_SLOTS

local function get_player_weapon_by_slot(player, extensions, slot_name)
	if not extensions or not extensions.visual_loadout or not extensions.unit_data then
		return nil
	end
	
	local visual_loadout_extension = extensions.visual_loadout
	local unit_data_extension = extensions.unit_data
	local inventory_component = unit_data_extension:read_component("inventory")
	
	if not inventory_component then
		return nil
	end
	
	local item_name = inventory_component[slot_name]
	
	if not item_name or item_name == "not_equipped" then
		return nil
	end
	
	local success, item = pcall(function()
		return visual_loadout_extension:item_from_slot(slot_name)
	end)
	
	if not success or not item then
		return nil
	end
	
	local icon = nil
	
	if item and item.name then
		local master_item = MasterItems.get_item(item.name)
		if master_item and master_item.hud_icon then
			icon = master_item.hud_icon
		end
	end
	
	if not icon and item and item.hud_icon then
		icon = item.hud_icon
	end
	
	if not icon then
		local success_template, weapon_template = pcall(function()
			return visual_loadout_extension:weapon_template_from_slot(slot_name)
		end)
		
		if success_template and weapon_template then
			icon = weapon_template.hud_icon or weapon_template.hud_icon_small
		end
	end
	
	if not icon then
		icon = "content/ui/materials/icons/weapons/hud/combat_blade_01"
	end
	
	local weapon_name = "Weapon"
	if item and item.name then
		local master_item = MasterItems.get_item(item.name)
		if master_item and master_item.display_name then
			weapon_name = master_item.display_name
		end
	end
	
	return {
		weapon_id = slot_name,
		icon = icon,
		name = weapon_name,
	}
end


local function update_teammate_weapons(self, player, dt)
	if not self._widgets_by_name then
		return
	end
	
	local player_peer_id = player:peer_id()
	if not player_peer_id then
		for _, weapon_slot in ipairs(WEAPON_SLOTS) do
			local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
			if icon_widget then
				icon_widget.visible = false
			end
		end
		return
	end
	
	local player_unique_id = player:unique_id()
	local player_identifier = player_unique_id or tostring(player_peer_id)

	local extensions = self:_player_extensions(player)

	if not extensions then
		for _, weapon_slot in ipairs(WEAPON_SLOTS) do
			local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
			if icon_widget then
				icon_widget.visible = false
			end
		end
		return
	end

	local is_human_controlled = player:is_human_controlled()
	local was_human_controlled = player_previous_human_state_weapons[player_identifier]

	if was_human_controlled and not is_human_controlled then
		mod.clear_teammate_weapons_data(player_identifier)
	end

	player_previous_human_state_weapons[player_identifier] = is_human_controlled

	if self._show_as_dead or self._dead or self._hogtied then
		for _, weapon_slot in ipairs(WEAPON_SLOTS) do
			local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
			if icon_widget then
				icon_widget.visible = false
			end
		end
		return
	end

	local show_for_bots = TalentUISettings and TalentUISettings.show_abilities_for_bots ~= false
	if not show_for_bots and not player:is_human_controlled() then
		for _, weapon_slot in ipairs(WEAPON_SLOTS) do
			local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
			if icon_widget then
				icon_widget.visible = false
			end
		end
		return
	end
	
	local weapon_spacing = TalentUISettings.teammate_weapon_spacing
	local weapon_horizontal_offset = mod:get("teammate_weapon_horizontal_offset") or TalentUISettings.teammate_weapon_horizontal_offset
	local weapon_vertical_offset = mod:get("teammate_weapon_vertical_offset") or TalentUISettings.teammate_weapon_vertical_offset
	local weapon_icon_width = TalentUISettings.teammate_weapon_icon_width
	local weapon_icon_height = TalentUISettings.teammate_weapon_icon_height
	local weapon_orientation = mod:get("teammate_weapon_orientation") or TalentUISettings.teammate_weapon_orientation
	
	local weapons_to_show = {}
	
	for i = 1, #WEAPON_SLOTS do
		local weapon_slot = WEAPON_SLOTS[i]
		local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
		
		if icon_widget then
			local data_key = player_identifier .. "_" .. weapon_slot.id
			
			local weapon_data = get_player_weapon_by_slot(player, extensions, weapon_slot.slot)
			if weapon_data then
				local cached_data = teammate_weapons_data[data_key]
				if not cached_data or cached_data.icon ~= weapon_data.icon or cached_data.weapon_id ~= weapon_data.weapon_id then
					teammate_weapons_data[data_key] = {
						weapon_id = weapon_data.weapon_id,
						icon = weapon_data.icon,
					}
				end
			end
			
			local has_weapon = teammate_weapons_data[data_key] and teammate_weapons_data[data_key].icon ~= nil
			
			if has_weapon then
				table.insert(weapons_to_show, {
					weapon_slot = weapon_slot,
					data_key = data_key,
				})
			end
		end
	end
	
	local enabled_weapons = {}
	local total_weapons = #weapons_to_show
	local is_horizontal = weapon_orientation == "horizontal"
	
	for position_index = 1, total_weapons do
		local weapon_data = weapons_to_show[position_index]
		local offset_x, offset_y
		
		if is_horizontal then
			offset_x = weapon_horizontal_offset + weapon_spacing + (position_index - 1) * (weapon_icon_width + weapon_spacing)
			offset_y = weapon_vertical_offset
		else
			offset_x = weapon_horizontal_offset + weapon_spacing
			offset_y = weapon_vertical_offset + (position_index - 1) * (weapon_icon_height + weapon_spacing)
		end
		
		enabled_weapons[weapon_data.weapon_slot.id] = {
			weapon_slot = weapon_data.weapon_slot,
			position = position_index,
			offset_x = offset_x,
			offset_y = offset_y,
		}
	end
	
	for i = 1, #WEAPON_SLOTS do
		local weapon_slot = WEAPON_SLOTS[i]
		local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
		
		if icon_widget then
			local data_key = player_identifier .. "_" .. weapon_slot.id
			
			if icon_widget and teammate_weapons_data[data_key] and teammate_weapons_data[data_key].icon then
				local icon = teammate_weapons_data[data_key].icon
				
				local weapon_position = enabled_weapons[weapon_slot.id]
				
				if not weapon_position then
					icon_widget.visible = false
				else
					local new_offset_x = weapon_position.offset_x
					local new_offset_y = weapon_position.offset_y
					
					if icon_widget.style and icon_widget.style.icon then
						if icon_widget.style.icon.offset then
							if icon_widget.style.icon.offset[1] ~= new_offset_x then
								icon_widget.style.icon.offset[1] = new_offset_x
								icon_widget.dirty = true
							end
							if icon_widget.style.icon.offset[2] ~= new_offset_y then
								icon_widget.style.icon.offset[2] = new_offset_y
								icon_widget.dirty = true
							end
						end
						
						if icon_widget.style.icon.size then
							if icon_widget.style.icon.size[1] ~= weapon_icon_width or icon_widget.style.icon.size[2] ~= weapon_icon_height then
								icon_widget.style.icon.size[1] = weapon_icon_width
								icon_widget.style.icon.size[2] = weapon_icon_height
								icon_widget.dirty = true
							end
						end
					end
					
					if icon and icon_widget.content then
						if icon_widget.content.icon ~= icon then
							icon_widget.content.icon = icon
							icon_widget.dirty = true
						end
					end
					
					icon_widget.visible = true
				end
			else
				icon_widget.visible = false
			end
		end
	end
end

mod.update_teammate_weapons = update_teammate_weapons

mod.clear_teammate_weapons_data = function(player_identifier)
	local keys_to_remove = {}
	
	for key, _ in pairs(teammate_weapons_data) do
		if string.find(key, player_identifier .. "_", 1, true) == 1 then
			table.insert(keys_to_remove, key)
		end
	end
	
	for _, key in ipairs(keys_to_remove) do
		teammate_weapons_data[key] = nil
	end
	
	player_previous_human_state_weapons[player_identifier] = nil
end

