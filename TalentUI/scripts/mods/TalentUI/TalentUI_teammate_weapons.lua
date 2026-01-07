local mod = get_mod("TalentUI")

local MasterItems = require("scripts/backend/master_items")
local Ammo = require("scripts/utilities/ammo")

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

local function hide_all_weapon_widgets(self)
	for _, weapon_slot in ipairs(WEAPON_SLOTS) do
		local icon_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_icon"]
		if icon_widget then
			icon_widget.visible = false
			icon_widget.dirty = true
		end
		local text_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_text"]
		if text_widget then
			text_widget.visible = false
			text_widget.dirty = true
		end
	end
end

local function update_teammate_weapons(self, player, dt)
	if not self._widgets_by_name then
		return
	end
	
	-- if self._show_as_dead or self._dead or self._hogtied then
	-- 	hide_all_weapon_widgets(self)
	-- 	return
	-- end
	
	local player_peer_id = player:peer_id()
	if not player_peer_id then
		hide_all_weapon_widgets(self)
		return
	end
	
	local player_unique_id = player:unique_id()
	local player_identifier = player_unique_id or tostring(player_peer_id)

	local extensions = self:_player_extensions(player)

	if not extensions then
		hide_all_weapon_widgets(self)
		return
	end

	local is_human_controlled = player:is_human_controlled()
	local was_human_controlled = player_previous_human_state_weapons[player_identifier]

	if was_human_controlled and not is_human_controlled then
		mod.clear_teammate_weapons_data(player_identifier)
	end

	player_previous_human_state_weapons[player_identifier] = is_human_controlled

	local show_for_bots = TalentUISettings and TalentUISettings.show_abilities_for_bots ~= false
	if (not show_for_bots and not player:is_human_controlled()) or self._show_as_dead or self._dead or self._hogtied then
		hide_all_weapon_widgets(self)
		return
	end
	
	local weapon_icon_width = TalentUISettings.teammate_weapon_icon_width
	local weapon_icon_height = TalentUISettings.teammate_weapon_icon_height
	
	for i = 1, #WEAPON_SLOTS do
		-- if self._show_as_dead or self._dead or self._hogtied then
		-- 	hide_all_weapon_widgets(self)
		-- 	return
		-- end
		
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
			
			local show_weapon_icon = true
			if weapon_slot.id == "primary" then
				show_weapon_icon = mod:get("show_teammate_weapon_primary_icon")
			elseif weapon_slot.id == "secondary" then
				show_weapon_icon = mod:get("show_teammate_weapon_secondary_icon")
			end
			
			if has_weapon and show_weapon_icon and not self._show_as_dead and not self._dead and not self._hogtied then
				local icon = teammate_weapons_data[data_key].icon
				local needs_icon_update = false
				
				if icon_widget.style and icon_widget.style.icon then
					if icon_widget.style.icon.size then
						if icon_widget.style.icon.size[1] ~= weapon_icon_width or icon_widget.style.icon.size[2] ~= weapon_icon_height then
							icon_widget.style.icon.size[1] = weapon_icon_width
							icon_widget.style.icon.size[2] = weapon_icon_height
							needs_icon_update = true
						end
					end
				end
				
				if icon and icon_widget.content then
					if icon_widget.content.icon ~= icon then
						icon_widget.content.icon = icon
						needs_icon_update = true
					end
				end
				
				if icon_widget.visible ~= true then
					icon_widget.visible = true
					needs_icon_update = true
				end
				
				if needs_icon_update then
					icon_widget.dirty = true
				end
				
				local show_ammo = mod:get("teammate_weapon_show_ammo")
				local text_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_text"]
				if text_widget then
					local needs_text_update = false
					local new_text = ""
					local new_visible = false
					
					if show_ammo then
						local unit_data_extension = extensions.unit_data
						local inventory_component = unit_data_extension and unit_data_extension:read_component(weapon_slot.slot)
						
						if inventory_component then
							local max_clip = Ammo.max_ammo_in_clips(inventory_component) or 0
							local max_reserve = Ammo.max_ammo_in_reserve(inventory_component) or 0
							local current_clip = Ammo.current_ammo_in_clips(inventory_component) or 0
							local current_reserve = Ammo.current_ammo_in_reserve(inventory_component) or 0
							local total_current_ammo = current_clip + current_reserve
							local total_max_ammo = max_clip + max_reserve
							
							if total_max_ammo == 0 or self._show_as_dead or self._dead or self._hogtied then
								new_text = ""
								new_visible = false
							else
								new_text = string.format("%d/%d", total_current_ammo, total_max_ammo)
								new_visible = true
							end
						else
							new_text = ""
							new_visible = false
						end
					else
						new_text = ""
						new_visible = false
					end
					
					if text_widget.content.text ~= new_text then
						text_widget.content.text = new_text
						needs_text_update = true
					end
					
					if text_widget.visible ~= new_visible then
						text_widget.visible = new_visible
						needs_text_update = true
					end
					
					if needs_text_update then
						text_widget.dirty = true
					end
				end
			else
				if icon_widget.visible ~= false then
					icon_widget.visible = false
					icon_widget.dirty = true
				end
				
				local text_widget = self._widgets_by_name["talent_ui_weapon_" .. weapon_slot.id .. "_text"]
				if text_widget then
					if text_widget.visible ~= false then
						text_widget.visible = false
						text_widget.dirty = true
					end
				end
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

