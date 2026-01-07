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

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local FixedFrame = require("scripts/utilities/fixed_frame")

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

local teammate_abilities_data = {}

mod.teammate_abilities_data = teammate_abilities_data

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

local TALENT_ABILITY_METADATA = mod.TALENT_ABILITY_METADATA

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

		return nil
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
		return 1, false, nil, false, nil
	end
	
	if not extensions or not extensions.ability then
		return 1, false, nil, false, nil
	end
	
	local ability_extension = extensions.ability
	
	if not ability_extension:ability_is_equipped(ability_type) then
		return 1, false, nil, false, nil
	end
	
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(ability_type)
	local max_cooldown = ability_extension:max_ability_cooldown(ability_type)
	local remaining_charges = ability_extension:remaining_ability_charges(ability_type)
	local max_charges = ability_extension:max_ability_charges(ability_type)
	
	local uses_charges = max_charges and max_charges > 1
	local has_charges_left = remaining_charges and remaining_charges > 0 or false
	
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
	
	return cooldown_progress, on_cooldown, remaining_charges, has_charges_left, max_charges
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
	if not TalentUISettings or not TalentUISettings.teammate_ability_icon_material_settings then
		return {intensity = 0, saturation = 1}
	end
	
	local icon_settings = TalentUISettings.teammate_ability_icon_material_settings
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

local function hide_all_ability_widgets(self)
	for _, ability_type in ipairs(TALENT_ABILITY_METADATA) do
		local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_icon"]
		local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_text"]
		if icon_widget then
			icon_widget.visible = false
			icon_widget.dirty = true
		end
		if text_widget then
			text_widget.visible = false
			text_widget.dirty = true
		end
	end
end

local function format_cooldown_text(ability_ext, ability_type_name, format_type, uses_charges, remaining_charges)
	local charges_text = ""
	local cooldown_text = ""
	
	if uses_charges and remaining_charges ~= nil and remaining_charges > 0 then
		charges_text = tostring(remaining_charges)
	end
	
	local remaining_cooldown = ability_ext:remaining_ability_cooldown(ability_type_name)
	if remaining_cooldown and remaining_cooldown > 0 then
		if format_type == "time" then
			cooldown_text = string.format("%d", math.ceil(remaining_cooldown))
		elseif format_type == "percent" then
			local max_cooldown = ability_ext:max_ability_cooldown(ability_type_name)
			if max_cooldown and max_cooldown > 0 then
				local percent = (1 - remaining_cooldown / max_cooldown) * 100
				if percent < 99 then
					cooldown_text = string.format("%d%%", math.floor(percent))
				end
			end
		end
	end
	
	if charges_text ~= "" and cooldown_text ~= "" then
		return string.format("%s (%s)", charges_text, cooldown_text)
	elseif charges_text ~= "" then
		return charges_text
	elseif cooldown_text ~= "" then
		return cooldown_text
	end
	
	return ""
end

local function update_teammate_all_abilities(self, player, dt)
	local player_name = player:name()

	-- if self._show_as_dead or self._dead or self._hogtied then
	-- 	hide_all_ability_widgets(self)
	-- 	return
	-- end

	if not player_name then
		hide_all_ability_widgets(self)
		return
	end

	local extensions = self:_player_extensions(player)

	if not extensions then
		hide_all_ability_widgets(self)
		return
	end

	local is_human_controlled = player:is_human_controlled()
	local was_human_controlled = player_previous_human_state[player_name]

	if was_human_controlled and not is_human_controlled then
		mod.clear_teammate_all_abilities_data(player_name)
	end

	player_previous_human_state[player_name] = is_human_controlled

	local show_for_bots = TalentUISettings and TalentUISettings.show_abilities_for_bots ~= false
	if (not show_for_bots and not player:is_human_controlled()) or self._show_as_dead or self._dead or self._hogtied then
		hide_all_ability_widgets(self)
		return
	end
	
	local icon_size = mod:get("teammate_ability_icon_size") or TalentUISettings.teammate_ability_icon_size
	
	for i = 1, #TALENT_ABILITY_METADATA do
		-- if self._show_as_dead or self._dead or self._hogtied then
		-- 	hide_all_ability_widgets(self)
		-- 	return
		-- end
		
		local ability_info = TALENT_ABILITY_METADATA[i]
		local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_icon"]
		local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_text"]
		
		if icon_widget then
			local data_key = player_name .. "_" .. ability_info.id
			
			local ability_data = get_player_ability_by_type(player, extensions, ability_info.slot)
			if ability_data and ability_data.ability_type and ability_data.icon then
				local cached_data = teammate_abilities_data[data_key]
				if not cached_data or cached_data.ability_type ~= ability_data.ability_type or cached_data.icon ~= ability_data.icon then
					teammate_abilities_data[data_key] = {
						ability_id = ability_data.ability_id,
						ability_type = ability_data.ability_type,
						icon = ability_data.icon,
					}
				end
			end

			local has_ability = teammate_abilities_data[data_key] and teammate_abilities_data[data_key].ability_type
			local show_icon = true
			if ability_info.id == "ability" then
				show_icon = mod:get("show_teammate_ability_icon")
			elseif ability_info.id == "blitz" then
				show_icon = mod:get("show_teammate_blitz_icon")
			elseif ability_info.id == "aura" then
				show_icon = mod:get("show_teammate_aura_icon")
			end
			
			if has_ability and show_icon and not self._show_as_dead and not self._dead and not self._hogtied then
				local ability_type = teammate_abilities_data[data_key].ability_type
				local icon = teammate_abilities_data[data_key].icon
				
				if text_widget and text_widget.style and text_widget.style.text then
					if text_widget.style.text.size then
						if text_widget.style.text.size[1] ~= icon_size or text_widget.style.text.size[2] ~= icon_size then
							text_widget.style.text.size[1] = icon_size
							text_widget.style.text.size[2] = icon_size
							text_widget.dirty = true
						end
					end
				end
				
				local cooldown_progress, on_cooldown, remaining_charges, has_charges_left, max_charges = get_ability_state(player, extensions, ability_type)
				local uses_charges = max_charges and max_charges > 1
				
				local gradient_map = get_ability_gradient_map(ability_info.id)
				if gradient_map and icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.material_values and icon_widget.style.icon.material_values.gradient_map ~= gradient_map then
					icon_widget.style.icon.material_values.gradient_map = gradient_map
					icon_widget.dirty = true
				end
				
				local material_settings = get_ability_material_settings(ability_info.id, on_cooldown, uses_charges, has_charges_left, max_charges)
				
				if icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.material_values then
					local material_values = icon_widget.style.icon.material_values
					local needs_update = false
					
					if material_values.intensity ~= material_settings.intensity then
						material_values.intensity = material_settings.intensity
						needs_update = true
					end
					
					if material_values.saturation ~= material_settings.saturation then
						material_values.saturation = material_settings.saturation
						needs_update = true
					end
					
					if needs_update then
						icon_widget.dirty = true
					end
				end
				
				if icon and icon_widget.style and icon_widget.style.icon and icon_widget.style.icon.material_values then
					local material_values = icon_widget.style.icon.material_values
					if material_values.icon ~= icon then
						material_values.icon = icon
						icon_widget.dirty = true
					end
				end
				
				local needs_icon_update = false
				if icon_widget.visible ~= true then
					icon_widget.visible = true
					needs_icon_update = true
				end
				
				if needs_icon_update then
					icon_widget.dirty = true
				end
				
				if text_widget then
					local display_text = ""
					local show_text = true
					
					if ability_info.id == "ability" then
						show_text = mod:get("show_teammate_ability_cooldown")
						
						if show_text and extensions and extensions.ability then
							local ability_ext = extensions.ability
							local format_type = mod:get("cooldown_format")
							display_text = format_cooldown_text(ability_ext, "combat_ability", format_type, uses_charges, remaining_charges)
						end
					elseif ability_info.id == "blitz" then
						show_text = mod:get("show_teammate_blitz_charges")
						
						if show_text and extensions and extensions.ability then
							local ability_ext = extensions.ability
							if uses_charges then
								local charges = ability_ext:remaining_ability_charges("grenade_ability")
								if charges ~= nil and charges >= 0 then
									display_text = tostring(charges)
								end
							else
								local format_type = mod:get("cooldown_format")
								display_text = format_cooldown_text(ability_ext, "grenade_ability", format_type, uses_charges, remaining_charges)
							end
						end
					end
					
					local needs_text_update = false
					local new_visible = show_text and display_text ~= ""
					
					if text_widget.content.text ~= display_text then
						text_widget.content.text = display_text
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
