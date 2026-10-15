local mod = get_mod("TalentUI")

local pairs, pcall, tostring, type = pairs, pcall, tostring, type
local string_format = string.format

local MasterItems = require("scripts/backend/master_items")
local Ammo = require("scripts/utilities/ammo")

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

local AMMO_UPDATE_INTERVAL = 0.1
local WEAPON_ICON_PACKAGE_REFERENCE = "TalentUI_team_weapon_icon"
local DEFAULT_WEAPON_ICON = "content/ui/materials/icons/weapons/hud/combat_blade_01"

-- Per player, per slot: { item_name, icon, icon_held, ammo_current, ammo_max, ammo_text, ammo_visible }; icon is re-resolved only when the equipped item changes
local teammate_weapons_data = {}

-- Package references on the item icons the team panels show, per HUD: hud -> icon -> load id. An item's hud_icon is
-- loaded with its owner's loadout, and PackageSynchronizer unloads it 3 seconds after the teammate leaves or a player
-- takes over their bot; the game crashes if the HUD's renderer still references it then, even after the panel was
-- destroyed. So an icon stays held until its HUD has destroyed its renderer. Persistent, so a mod reload doesn't lose
-- the load ids
local held_weapon_icons = mod:persistent_table("held_weapon_icons")

local player_previous_human_state_weapons = {}

local WEAPON_SLOTS = mod.WEAPON_SLOTS
local NUM_WEAPON_SLOTS = #WEAPON_SLOTS

local WEAPON_ICON_WIDGET_NAMES = {}
local WEAPON_TEXT_WIDGET_NAMES = {}

for i = 1, NUM_WEAPON_SLOTS do
	local weapon_slot = WEAPON_SLOTS[i]
	
	WEAPON_ICON_WIDGET_NAMES[i] = "talent_ui_weapon_" .. weapon_slot.id .. "_icon"
	WEAPON_TEXT_WIDGET_NAMES[i] = "talent_ui_weapon_" .. weapon_slot.id .. "_text"
end

-- Cached weapon settings; refreshed on load and from mod.on_setting_changed
local show_teammate_weapon_primary_icon
local show_teammate_weapon_secondary_icon
local teammate_weapon_show_ammo

local function refresh_teammate_weapon_settings()
	show_teammate_weapon_primary_icon = mod:get("show_teammate_weapon_primary_icon")
	show_teammate_weapon_secondary_icon = mod:get("show_teammate_weapon_secondary_icon")
	teammate_weapon_show_ammo = mod:get("teammate_weapon_show_ammo")
end

refresh_teammate_weapon_settings()

mod.refresh_teammate_weapon_settings = refresh_teammate_weapon_settings

-- Vanilla bot weapon items have no usable hud_icon; resolve icons through the equivalent player item.
local BOT_WEAPON_ICON_ITEMS = {
	["content/items/weapons/player/melee/bot_combatsword_linesman_p1"] = "content/items/weapons/player/melee/combatsword_p1_m1",
	["content/items/weapons/player/melee/bot_combatsword_linesman_p2"] = "content/items/weapons/player/melee/combatsword_p2_m1",
	["content/items/weapons/player/melee/bot_combataxe_linesman"] = "content/items/weapons/player/melee/combataxe_p1_m1",
	["content/items/weapons/player/ranged/bot_lasgun_killshot"] = "content/items/weapons/player/ranged/lasgun_p1_m1",
	["content/items/weapons/player/ranged/high_bot_lasgun_killshot"] = "content/items/weapons/player/ranged/lasgun_p1_m1",
	["content/items/weapons/player/ranged/bot_autogun_killshot"] = "content/items/weapons/player/ranged/autogun_p3_m1",
	["content/items/weapons/player/ranged/high_bot_autogun_killshot"] = "content/items/weapons/player/ranged/autogun_p3_m1",
	["content/items/weapons/player/ranged/bot_laspistol_killshot"] = "content/items/weapons/player/ranged/laspistol_p1_m1",
	["content/items/weapons/player/ranged/bot_zola_laspistol"] = "content/items/weapons/player/ranged/laspistol_p1_m1",
}

local function valid_icon(icon)
	return type(icon) == "string" and icon ~= ""
end

-- An icon that comes with no item package can only be drawn while something else keeps it loaded
local function resident_icon(icon)
	return valid_icon(icon) and Application.can_get_resource("material", icon) and icon or nil
end

local function item_icon(item_name)
	local item = MasterItems.item_exists(item_name) and MasterItems.get_item(item_name)

	return item and valid_icon(item.hud_icon) and item.hud_icon or nil
end

-- Returns the slot's icon, the name of the item it was resolved from, and whether the icon is an item's hud_icon that
-- has to be held (see held_weapon_icons), or nil if the slot can't be resolved yet
local function get_player_weapon_by_slot(player, extensions, slot_name, item_name)
	if not extensions or not extensions.visual_loadout then
		return nil
	end
	
	local visual_loadout_extension = extensions.visual_loadout
	
	if not item_name or item_name == "not_equipped" then
		return nil
	end
	
	local success, item = pcall(visual_loadout_extension.item_from_slot, visual_loadout_extension, slot_name)
	
	if not success or not item then
		return nil
	end
	
	local resolved_item_name = item.name
	local icon = nil

	if resolved_item_name then
		local icon_item_name = BOT_WEAPON_ICON_ITEMS[resolved_item_name]
		if icon_item_name then
			icon = item_icon(icon_item_name)
		end

		if not icon then
			icon = item_icon(resolved_item_name)
		end
	end

	if not icon and valid_icon(item.hud_icon) then
		icon = item.hud_icon
	end

	if icon then
		return icon, resolved_item_name, true
	end

	local success_template, weapon_template = pcall(visual_loadout_extension.weapon_template_from_slot, visual_loadout_extension, slot_name)

	if success_template and weapon_template then
		icon = resident_icon(weapon_template.hud_icon) or resident_icon(weapon_template.hud_icon_small)
	end

	if not icon then
		icon = resident_icon(DEFAULT_WEAPON_ICON)
	end

	if not icon then
		return nil
	end

	return icon, resolved_item_name, false
end

local function hold_weapon_icon(hud, icon)
	local icons = held_weapon_icons[hud]

	if not icons then
		icons = {}
		held_weapon_icons[hud] = icons
	end

	local load_id = icons[icon]

	if not load_id then
		load_id = Managers.package:load(icon, WEAPON_ICON_PACKAGE_REFERENCE)
		icons[icon] = load_id
	end

	return load_id
end

-- runs after the HUD destroyed its elements and its renderer, so nothing can draw the icons any more
mod:hook_safe("UIHud", "destroy", function(self)
	local icons = held_weapon_icons[self]

	if not icons then
		return
	end

	held_weapon_icons[self] = nil

	for _, load_id in pairs(icons) do
		Managers.package:release(load_id)
	end
end)

local function set_team_weapon_widget_visible(widget, visible)
	local content = widget and widget.content

	if not content then
		return
	end

	widget.visible = true

	if content.visible ~= visible then
		content.visible = visible
		widget.dirty = true
	end
end

local function hide_all_weapon_widgets(self)
	local widgets_by_name = self._widgets_by_name

	-- the ammo text refreshes on the frame the widgets come back instead of up to an interval later
	self._talentui_ammo_t = nil

	for i = 1, NUM_WEAPON_SLOTS do
		local icon_widget = widgets_by_name[WEAPON_ICON_WIDGET_NAMES[i]]
		local text_widget = widgets_by_name[WEAPON_TEXT_WIDGET_NAMES[i]]

		set_team_weapon_widget_visible(icon_widget, false)
		set_team_weapon_widget_visible(text_widget, false)
	end
end

local function update_teammate_weapons(self, player, dt)
	local widgets_by_name = self._widgets_by_name
	
	if not widgets_by_name then
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
	
	local player_identifier = player:unique_id() or tostring(player_peer_id)

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
	if (not show_for_bots and not is_human_controlled) or self._show_as_dead or self._dead or self._hogtied then
		hide_all_weapon_widgets(self)
		return
	end
	
	local player_weapons_data = teammate_weapons_data[player_identifier]
	if not player_weapons_data then
		player_weapons_data = {}
		teammate_weapons_data[player_identifier] = player_weapons_data
	end
	
	local unit_data_extension = extensions.unit_data
	local inventory_component = unit_data_extension and unit_data_extension:read_component("inventory")
	
	local weapon_icon_width = TalentUISettings.teammate_weapon_icon_width
	local weapon_icon_height = TalentUISettings.teammate_weapon_icon_height

	-- ammo is read ten times a second rather than every frame, like NumericUI's team panel
	local ammo_elapsed = (self._talentui_ammo_t or AMMO_UPDATE_INTERVAL) + dt
	local refresh_ammo = ammo_elapsed >= AMMO_UPDATE_INTERVAL

	self._talentui_ammo_t = refresh_ammo and 0 or ammo_elapsed

	for i = 1, NUM_WEAPON_SLOTS do
		-- if self._show_as_dead or self._dead or self._hogtied then
		-- 	hide_all_weapon_widgets(self)
		-- 	return
		-- end
		
		local weapon_slot = WEAPON_SLOTS[i]
		local icon_widget = widgets_by_name[WEAPON_ICON_WIDGET_NAMES[i]]
		
		if icon_widget then
			local slot_id = weapon_slot.id
			local slot_name = weapon_slot.slot
			local text_widget = widgets_by_name[WEAPON_TEXT_WIDGET_NAMES[i]]
			
			local weapon_data = player_weapons_data[slot_id]
			if not weapon_data then
				weapon_data = {}
				player_weapons_data[slot_id] = weapon_data
			end
			
			-- Cache the resolved item's own name, so an inventory/visual loadout mismatch is retried next frame
			local item_name = inventory_component and inventory_component[slot_name]
			if weapon_data.item_name ~= item_name then
				local icon, resolved_item_name, icon_held = get_player_weapon_by_slot(player, extensions, slot_name, item_name)
				if icon then
					weapon_data.icon = icon
					weapon_data.icon_held = icon_held
					weapon_data.item_name = resolved_item_name
				end
			end

			local show_weapon_icon = true
			if slot_id == "primary" then
				show_weapon_icon = show_teammate_weapon_primary_icon
			elseif slot_id == "secondary" then
				show_weapon_icon = show_teammate_weapon_secondary_icon
			end

			local icon = weapon_data.icon

			-- an item's icon is only drawn once this HUD holds it, so it can't be unloaded while the renderer uses it
			if icon and show_weapon_icon and weapon_data.icon_held and not Managers.package:has_loaded_id(hold_weapon_icon(self._parent, icon)) then
				icon = nil
			end

			local has_weapon = icon ~= nil

			if has_weapon and show_weapon_icon then
				local icon_content = icon_widget.content
				local needs_icon_update = false
				
				local icon_style = icon_widget.style
				icon_style = icon_style and icon_style.icon
				
				if icon_style then
					local icon_size = icon_style.size
					if icon_size then
						if icon_size[1] ~= weapon_icon_width or icon_size[2] ~= weapon_icon_height then
							icon_size[1] = weapon_icon_width
							icon_size[2] = weapon_icon_height
							needs_icon_update = true
						end
					end
				end
				
				if icon and icon_content then
					if icon_content.icon ~= icon then
						icon_content.icon = icon
						needs_icon_update = true
					end
				end
				
				if icon_content.visible ~= true then
					set_team_weapon_widget_visible(icon_widget, true)
					needs_icon_update = true
				end
				
				if needs_icon_update then
					icon_widget.dirty = true
				end
				
				if text_widget then
					local needs_text_update = false
					local new_text = ""
					local new_visible = false
					
					if teammate_weapon_show_ammo then
						if refresh_ammo or weapon_data.ammo_visible == nil then
							local slot_component = unit_data_extension and unit_data_extension:has_component(slot_name) and unit_data_extension:read_component(slot_name)
							local ammo_visible = false

							if slot_component then
								local total_max_ammo = (Ammo.max_ammo_in_clips(slot_component) or 0) + (Ammo.max_ammo_in_reserve(slot_component) or 0)
								local total_current_ammo = (Ammo.current_ammo_in_clips(slot_component) or 0) + (Ammo.current_ammo_in_reserve(slot_component) or 0)

								if total_max_ammo ~= 0 then
									ammo_visible = true

									if weapon_data.ammo_current ~= total_current_ammo or weapon_data.ammo_max ~= total_max_ammo then
										weapon_data.ammo_current = total_current_ammo
										weapon_data.ammo_max = total_max_ammo
										weapon_data.ammo_text = string_format("%d/%d", total_current_ammo, total_max_ammo)
									end
								end
							end

							weapon_data.ammo_visible = ammo_visible
						end

						if weapon_data.ammo_visible then
							new_text = weapon_data.ammo_text
							new_visible = true
						end
					end
					
					local text_content = text_widget.content
					
					if text_content.text ~= new_text then
						text_content.text = new_text
						needs_text_update = true
					end
					
					if text_content.visible ~= new_visible then
						set_team_weapon_widget_visible(text_widget, new_visible)
						needs_text_update = true
					end
					
					if needs_text_update then
						text_widget.dirty = true
					end
				end
			else
				set_team_weapon_widget_visible(icon_widget, false)
				set_team_weapon_widget_visible(text_widget, false)
			end
		end
	end
end

mod.update_teammate_weapons = update_teammate_weapons

mod.clear_teammate_weapons_data = function(player_identifier)
	teammate_weapons_data[player_identifier] = nil
	player_previous_human_state_weapons[player_identifier] = nil
end

