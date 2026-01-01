local mod = get_mod("TalentUI")

local CharacterSheet
local success_require = pcall(function()
	CharacterSheet = require("scripts/utilities/character_sheet")
end)

if not success_require or not CharacterSheet then
	mod:error("Failed to load CharacterSheet module")
	CharacterSheet = {}
	CharacterSheet.class_loadout = function() end
end

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local FixedFrame = require("scripts/utilities/fixed_frame")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local hud_body_font_settings = UIFontSettings.hud_body

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

local teammate_abilities_data = {}

local player_previous_human_state = {}

local function get_talent_from_character_sheet(player, ability_key)
	local profile = player and player:profile()

	if not profile then
		return nil
	end

	local loadout_data = {
		ability = {},
		blitz = {},
		aura = {},
	}

	local success, entry = pcall(function()
		CharacterSheet.class_loadout(profile, loadout_data, false, profile.talents or {})

		local entry = loadout_data[ability_key]

		return entry
	end)

	if success then
		return entry
	end

	return nil
end

local TALENT_ABILITY_METADATA = {
	{
		id = "ability",
		slot = "slot_combat_ability",
		type = "combat_ability",
		name = "talent_ui_all_ability",
		frame = "hex_frame",
		mask = "hex_frame_mask",
	},
	{
		id = "blitz",
		slot = "slot_grenade_ability",
		type = "grenade_ability",
		name = "talent_ui_all_blitz",
		frame = "square_frame",
		mask = "square_frame_mask",
	},
	{
		id = "aura",
		slot = "slot_coherency_ability",
		type = "coherency_ability",
		name = "talent_ui_all_aura",
		frame = "circular_frame",
		mask = "circular_frame_mask",
	},
}

local function get_player_ability_by_type(player, extensions, slot_type)
	if slot_type == "slot_coherency_ability" then
		local aura_entry = get_talent_from_character_sheet(player, "aura")

		if aura_entry and aura_entry.icon then
			return {
				ability_id = "aura",
				ability_type = "coherency_ability",
				icon = aura_entry.icon,
				name = aura_entry.talent and aura_entry.talent.display_name or "Aura",
			}
		end

		local success, result = pcall(function()
			local profile = player:profile()
			if profile then
				local loadout_data = {
					ability = {},
					blitz = {},
					aura = {},
				}
				local loadout_success = pcall(function()
					CharacterSheet.class_loadout(profile, loadout_data, false, profile.talents or {})
				end)
				if loadout_success and loadout_data and loadout_data.aura then
					local icon = loadout_data.aura.icon
					
					if icon then
						return {
							ability_id = "aura",
							ability_type = "coherency_ability",
							icon = icon,
							name = loadout_data.aura.talent and loadout_data.aura.talent.display_name or "Aura",
						}
					end
				end
			end
			return nil
		end)
		
		if success and result then
			return result
		end

		return nil
	end
	
	if slot_type == "slot_grenade_ability" then
		local blitz_entry = get_talent_from_character_sheet(player, "blitz")

		if blitz_entry and blitz_entry.talent then
			return {
				ability_id = "blitz",
				ability_type = "grenade_ability",
				icon = blitz_entry.icon,
				name = blitz_entry.talent.display_name or "Blitz",
			}
		else
			return nil
		end
	end
	
	if not extensions or not extensions.ability then
		return nil
	end
	
	local ability_extension = extensions.ability
	local equipped_abilities = ability_extension:equipped_abilities()
	
	if not equipped_abilities then
		return nil
	end
	
	local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")
	local ability_configuration = PlayerCharacterConstants.ability_configuration
	
	for ability_id, ability_settings in pairs(equipped_abilities) do
		local slot_id = ability_configuration[ability_id]
		if slot_id == slot_type then
			local ability_type
			if slot_type == "slot_combat_ability" then
				ability_type = "combat_ability"
			elseif slot_type == "slot_grenade_ability" then
				ability_type = "grenade_ability"
			else
				ability_type = nil
			end
			
			if ability_type then
				local icon = nil

				if slot_type == "slot_grenade_ability" then
					local blitz_entry = get_talent_from_character_sheet(player, "blitz")
					icon = blitz_entry and blitz_entry.icon

					if not icon and extensions.visual_loadout and extensions.unit_data then
						local inventory_component = extensions.unit_data:read_component("inventory")
						if inventory_component then
							local visual_loadout_extension = extensions.visual_loadout
							local slot_name = "slot_grenade_ability"
							local item_name = inventory_component[slot_name]
							local weapon_template = item_name and visual_loadout_extension:weapon_template_from_slot(slot_name)

							if weapon_template and weapon_template.hud_icon_small then
								icon = weapon_template.hud_icon_small
							end
						end
					end

					if not icon then
						icon = ability_settings.hud_icon
					end
				else
					icon = ability_settings.hud_icon
				end
				
				return {
					ability_id = ability_id,
					ability_type = ability_type,
					icon = icon,
					name = ability_settings.name,
				}
			end
		end
	end
	
	return nil
end

local function get_ability_state(player, extensions, ability_type)
	if ability_type == "coherency_ability" then
		return 1, false, 1, true, 1
	end
	
	if not extensions or not extensions.ability then
		return 1, false, 1, true, 1
	end
	
	local ability_extension = extensions.ability
	
	if not ability_extension:ability_is_equipped(ability_type) then
		return 1, false, 1, true, 1
	end
	
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(ability_type)
	local max_cooldown = ability_extension:max_ability_cooldown(ability_type)
	local remaining_charges = ability_extension:remaining_ability_charges(ability_type)
	local max_charges = ability_extension:max_ability_charges(ability_type)
	
	local uses_charges = max_charges and max_charges > 1
	local has_charges_left = remaining_charges > 0
	
	local cooldown_progress = 1
	
	if max_cooldown and max_cooldown > 0 then
		cooldown_progress = 1 - math.lerp(0, 1, remaining_cooldown / max_cooldown)
		if cooldown_progress == 0 then
			cooldown_progress = 1
		end
	else
		cooldown_progress = uses_charges and 1 or 0
	end
	
	local on_cooldown = cooldown_progress ~= 1
	
	return cooldown_progress, on_cooldown, remaining_charges or 1, has_charges_left, max_charges or 1
end

local function get_ability_state_colors(on_cooldown, uses_charges, has_charges_left)
	local source_colors
	
	if on_cooldown then
		if uses_charges then
			if has_charges_left then
				source_colors = HudElementPlayerAbilitySettings.has_charges_cooldown_colors
			else
				source_colors = HudElementPlayerAbilitySettings.out_of_charges_cooldown_colors
			end
		else
			source_colors = HudElementPlayerAbilitySettings.cooldown_colors
		end
	elseif not uses_charges or uses_charges and has_charges_left then
		source_colors = HudElementPlayerAbilitySettings.active_colors
	else
		source_colors = HudElementPlayerAbilitySettings.inactive
	end
	
	return source_colors
end

local function get_ability_gradient_map(ability_id)
	if ability_id == "ability" then
		return "content/ui/textures/color_ramps/talent_ability"
	elseif ability_id == "blitz" then
		return "content/ui/textures/color_ramps/talent_blitz"
	elseif ability_id == "aura" then
		return "content/ui/textures/color_ramps/talent_aura"
	end
	
	return nil
end

local function get_ability_material_settings(ability_id, on_cooldown, uses_charges, has_charges_left, max_charges)
	if not TalentUISettings or not TalentUISettings.icon_material_settings then
		return {intensity = 0, saturation = 1}
	end
	
	local icon_settings = TalentUISettings.icon_material_settings
	if not icon_settings[ability_id] then
		return {intensity = 0, saturation = 1}
	end
	
	local ability_settings = icon_settings[ability_id]
	local state_key
	
	if ability_id == "aura" then
		state_key = "active"
	elseif ability_id == "blitz" then
		if max_charges == 0 then
			if on_cooldown then
				state_key = "on_cooldown"
			else
				state_key = "active"
			end
		else
			if has_charges_left then
				state_key = "active"
			else
				state_key = "inactive"
			end
		end
	elseif ability_id == "ability" then
		if on_cooldown then
			state_key = "on_cooldown"
		else
			state_key = "active"
		end
	else
		if on_cooldown then
			if uses_charges then
				if has_charges_left then
					state_key = "has_charges_cooldown"
				else
					state_key = "out_of_charges_cooldown"
				end
			else
				state_key = "on_cooldown"
			end
		elseif not uses_charges or (uses_charges and has_charges_left) then
			state_key = "active"
		else
			state_key = "inactive"
		end
	end
	
	local state_settings = ability_settings[state_key]
	if state_settings then
		local intensity = state_settings.intensity or 0
		local saturation = state_settings.saturation or 1
		return {
			intensity = intensity,
			saturation = saturation,
		}
	end
	
	return {intensity = 0, saturation = 1}
end

mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
	local bar_size = HudElementTeamPlayerPanelSettings.size
	local icon_size = TalentUISettings.ability_icon_size
	local coherency_icon_offset_x = 34
	local coherency_icon_size = 24
	local ability_spacing = TalentUISettings.ability_spacing or 50
	local vertical_offset = TalentUISettings.icon_position_vertical_offset or 0

	for i = 1, #TALENT_ABILITY_METADATA do
		local ability_type = TALENT_ABILITY_METADATA[i]
		local offset_x = coherency_icon_offset_x + coherency_icon_size + ability_spacing + (i - 1) * ability_spacing
		
		instance.widget_definitions[ability_type.name .. "_icon"] = UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "icon",
				value = "content/ui/materials/frames/talents/talent_icon_container",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					scale_to_material = true,
					material_values = {
						frame = "content/ui/textures/frames/talents/" .. ability_type.frame,
						icon_mask = "content/ui/textures/frames/talents/" .. ability_type.mask,
						icon = nil,
						gradient_map = nil,
						intensity = 0,
						saturation = 1,
					},
					offset = {
						offset_x,
						vertical_offset,
						1,
					},
					size = {
						icon_size,
						icon_size,
					},
					color = UIHudSettings.color_tint_main_2,
				},
			},
		}, "bar")
		
		instance.widget_definitions[ability_type.name .. "_text"] = UIWidget.create_definition({
			{
				pass_type = "text",
				style_id = "text",
				value_id = "text",
				value = "",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					text_horizontal_alignment = "center",
					text_vertical_alignment = "center",
					font_type = hud_body_font_settings.font_type or "machine_medium",
					font_size = TalentUISettings.cooldown_font_size,
					line_spacing = 1.2,
					text_color = UIHudSettings.color_tint_main_1,
					drop_shadow = true,
					offset = {
						offset_x,
						vertical_offset,
						3,
					},
					size = {
						icon_size,
						icon_size,
					},
				},
			},
		}, "bar")
	end
end)

local function update_teammate_all_abilities(self, player, dt)
	local player_name = player:name()

	local player_peer_id = player:peer_id()
	if not player_peer_id then
		for _, ability_type in ipairs(TALENT_ABILITY_METADATA) do
			local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_icon"]
			local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_text"]
			if icon_widget then
				icon_widget.visible = false
			end
			if text_widget then
				text_widget.visible = false
			end
		end
		return
	end

	local extensions = self:_player_extensions(player)

	if not extensions then
		for _, ability_type in ipairs(TALENT_ABILITY_METADATA) do
			local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_icon"]
			local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_text"]
			if icon_widget then
				icon_widget.visible = false
			end
			if text_widget then
				text_widget.visible = false
			end
		end
		return
	end

	local is_human_controlled = player:is_human_controlled()
	local was_human_controlled = player_previous_human_state[player_name]

	if was_human_controlled and not is_human_controlled then
		mod.clear_teammate_all_abilities_data(player_name)
	end

	player_previous_human_state[player_name] = is_human_controlled

	if self._show_as_dead or self._dead or self._hogtied then
		for _, ability_type in ipairs(TALENT_ABILITY_METADATA) do
			local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_icon"]
			local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_text"]
			if icon_widget then
				icon_widget.visible = false
			end
			if text_widget then
				text_widget.visible = false
			end
		end
		return
	end

	local show_for_bots = TalentUISettings and TalentUISettings.show_abilities_for_bots ~= false
	if not show_for_bots and not player:is_human_controlled() then
		for _, ability_type in ipairs(TALENT_ABILITY_METADATA) do
			local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_icon"]
			local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_text"]
			if icon_widget then
				icon_widget.visible = false
			end
			if text_widget then
				text_widget.visible = false
			end
		end
		return
	end
	
	local coherency_widget = self._widgets_by_name.coherency_indicator
	local coherency_icon_offset_x = 34
	local coherency_icon_size = 24
	
	if coherency_widget and coherency_widget.style and coherency_widget.style.texture and coherency_widget.style.texture.offset then
		coherency_icon_offset_x = coherency_widget.style.texture.offset[1] - 15
		if coherency_widget.style.texture.size then
			coherency_icon_size = coherency_widget.style.texture.size[1]
		end
	end
	
	local ability_spacing = TalentUISettings.ability_spacing or 60
	local vertical_offset = TalentUISettings.icon_position_vertical_offset or 0
	
	local abilities_to_show = {}
	
	for i = 1, #TALENT_ABILITY_METADATA do
		local ability_info = TALENT_ABILITY_METADATA[i]
		local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_icon"]
		
		if icon_widget then
			local data_key = player_name .. "_" .. ability_info.id
			
			if not teammate_abilities_data[data_key] or not teammate_abilities_data[data_key].ability_type then
				local ability_data = get_player_ability_by_type(player, extensions, ability_info.slot)
				if ability_data then
					teammate_abilities_data[data_key] = {
						ability_id = ability_data.ability_id,
						ability_type = ability_data.ability_type,
						icon = ability_data.icon,
					}
				end
			end
			
			local has_ability = teammate_abilities_data[data_key] and teammate_abilities_data[data_key].ability_type ~= nil
			local show_icon = true
			if ability_info.id == "ability" then
				show_icon = mod:get("show_teammate_ability_icon")
			elseif ability_info.id == "blitz" then
				show_icon = mod:get("show_teammate_blitz_icon")
			elseif ability_info.id == "aura" then
				show_icon = mod:get("show_teammate_aura_icon")
			end
			
			if has_ability and show_icon then
				table.insert(abilities_to_show, {
					ability_info = ability_info,
					data_key = data_key,
				})
			end
		end
	end
	
	local enabled_abilities = {}
	local total_abilities = #abilities_to_show
	for position_index = 1, total_abilities do
		local ability_data = abilities_to_show[position_index]
		local offset_x = coherency_icon_offset_x + coherency_icon_size + ability_spacing + (total_abilities - position_index) * ability_spacing
		enabled_abilities[ability_data.ability_info.id] = {
			ability_info = ability_data.ability_info,
			position = position_index,
			offset_x = offset_x,
		}
	end
	
	for i = 1, #TALENT_ABILITY_METADATA do
		local ability_info = TALENT_ABILITY_METADATA[i]
		local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_icon"]
		local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_text"]
		
		if icon_widget then
			local data_key = player_name .. "_" .. ability_info.id
			
			if icon_widget and teammate_abilities_data[data_key] and teammate_abilities_data[data_key].ability_type then
				local ability_type = teammate_abilities_data[data_key].ability_type
				local icon = teammate_abilities_data[data_key].icon
				
				local show_icon = true
				if ability_info.id == "ability" then
					show_icon = mod:get("show_teammate_ability_icon")
				elseif ability_info.id == "blitz" then
					show_icon = mod:get("show_teammate_blitz_icon")
				elseif ability_info.id == "aura" then
					show_icon = mod:get("show_teammate_aura_icon")
				end
				
				local ability_position = enabled_abilities[ability_info.id]
				
				if not show_icon or not ability_position then
					icon_widget.visible = false
					if text_widget then
						text_widget.visible = false
					end
				else
					local new_offset_x = ability_position.offset_x
					if icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.offset and icon_widget.style.icon.offset[1] ~= new_offset_x then
						icon_widget.style.icon.offset[1] = new_offset_x
						icon_widget.dirty = true
					end
					if text_widget and text_widget.style and text_widget.style.text and text_widget.style.text.offset and text_widget.style.text.offset[1] ~= new_offset_x then
						text_widget.style.text.offset[1] = new_offset_x
						text_widget.dirty = true
					end
					
					local cooldown_progress, on_cooldown, remaining_charges, has_charges_left, max_charges = get_ability_state(player, extensions, ability_type)
					local uses_charges = max_charges > 1
					
					local gradient_map = get_ability_gradient_map(ability_info.id)
					if gradient_map and icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.material_values and icon_widget.style.icon.material_values.gradient_map ~= gradient_map then
						icon_widget.style.icon.material_values.gradient_map = gradient_map
						icon_widget.dirty = true
					end
					
					local material_settings = get_ability_material_settings(ability_info.id, on_cooldown, uses_charges, has_charges_left, max_charges)
					
					if icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.material_values then
						icon_widget.style.icon.material_values.intensity = material_settings.intensity
						icon_widget.style.icon.material_values.saturation = material_settings.saturation
						icon_widget.dirty = true
					end
					
					if icon and icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.material_values then
						icon_widget.style.icon.material_values.icon = icon
						icon_widget.dirty = true
					end
					
					icon_widget.visible = true
					
					if text_widget then
					local display_text = ""
					local show_text = true
					
					if ability_info.id == "ability" then
						show_text = mod:get("show_teammate_ability_cooldown")
						
						if show_text then
							local charges_text = ""
							local cooldown_text = ""
							
							if uses_charges and remaining_charges >= 1 then
								charges_text = tostring(remaining_charges)
							end
							
							if on_cooldown then
								local format_type = mod:get("cooldown_format")
								if format_type == "time" then
									local unit_data_extension = extensions.unit_data
									if unit_data_extension then
										local ability_component = unit_data_extension:read_component("combat_ability")
										if ability_component and ability_component.cooldown then
											local fixed_frame_t = FixedFrame.get_latest_fixed_time()
											local time_remaining = math.max(ability_component.cooldown - fixed_frame_t, 0)
											if time_remaining > 0 then
												cooldown_text = string.format("%d", math.ceil(time_remaining))
											end
										end
									end
								elseif format_type == "percent" then
									local percent = (1 - cooldown_progress) * 100
									if percent < 99 then
										cooldown_text = string.format("%d%%", math.floor(percent))
									end
								end
							end
							
							if charges_text ~= "" and cooldown_text ~= "" then
								display_text = string.format("%s (%s)", charges_text, cooldown_text)
							elseif charges_text ~= "" then
								display_text = charges_text
							elseif cooldown_text ~= "" then
								display_text = cooldown_text
							end
						end
					elseif ability_info.id == "blitz" then
						show_text = mod:get("show_teammate_blitz_charges")
						
						if show_text then
							if uses_charges then
								if remaining_charges >= 1 then
									display_text = tostring(remaining_charges)
								end
							else
								if on_cooldown then
									local format_type = mod:get("cooldown_format")
									if format_type == "time" then
										local unit_data_extension = extensions.unit_data
										if unit_data_extension then
											local grenade_ability_component = unit_data_extension:read_component("grenade_ability")
											if grenade_ability_component and grenade_ability_component.cooldown then
												local fixed_frame_t = FixedFrame.get_latest_fixed_time()
												local time_remaining = math.max(grenade_ability_component.cooldown - fixed_frame_t, 0)
												if time_remaining > 0 then
													display_text = string.format("%d", math.ceil(time_remaining))
												end
											end
										end
									elseif format_type == "percent" then
										local percent = (1 - cooldown_progress) * 100
										if percent < 99 then
											display_text = string.format("%d%%", math.floor(percent))
										end
									end
								end
							end
						end
					end
					
						text_widget.content.text = display_text
						text_widget.visible = show_text and display_text ~= ""
						text_widget.dirty = true
					end
				end
			else
				icon_widget.visible = false
				if text_widget then
					text_widget.visible = false
				end
			end
		end
	end
end

mod.update_teammate_all_abilities = update_teammate_all_abilities

mod.clear_teammate_all_abilities_data = function(player_name)
	local keys_to_remove = {}
	
	for key, _ in pairs(teammate_abilities_data) do
		if string.find(key, player_name .. "_", 1, true) == 1 then
			table.insert(keys_to_remove, key)
		end
	end
	
	for _, key in ipairs(keys_to_remove) do
		teammate_abilities_data[key] = nil
	end
	
	player_previous_human_state[player_name] = nil
end

local function update_player_features_hook(func, self, dt, t, player, ui_renderer)
	func(self, dt, t, player, ui_renderer)
	
	update_teammate_all_abilities(self, player, dt)
end

mod:hook("HudElementTeamPlayerPanel", "_update_player_features", update_player_features_hook)

mod:hook_safe("HudElementTeamPlayerPanel", "destroy", function(self)
	local player = self._data.player
	if player then
		local success, player_name = pcall(function()
			return player:name()
		end)
		if success and player_name then
			mod.clear_teammate_all_abilities_data(player_name)
		end
	end
end)


