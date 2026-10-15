local mod = get_mod("TalentUI")

local pcall, tostring = pcall, tostring
local math_ceil, math_floor, math_clamp = math.ceil, math.floor, math.clamp
local string_format = string.format

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

-- Per player, per ability id: { ability_id, ability_type, icon, cached texts }; created on the first successful resolve,
-- and the last resolved icon is kept if resolution fails
local teammate_abilities_data = {}

mod.teammate_abilities_data = teammate_abilities_data

local player_previous_human_state = {}

-- Resolved CharacterSheet loadout per player name; rebuilt only when the profile or talents table changes
local teammate_talent_loadouts = {}

-- Cached ability settings; refreshed on load and from mod.on_setting_changed
local teammate_ability_icon_size
local show_teammate_ability_icon
local show_teammate_blitz_icon
local show_teammate_aura_icon
local show_teammate_ability_cooldown
local show_teammate_blitz_charges
local cooldown_format

local function refresh_teammate_ability_settings()
	teammate_ability_icon_size = mod:get("teammate_ability_icon_size") or TalentUISettings.teammate_ability_icon_size
	show_teammate_ability_icon = mod:get("show_teammate_ability_icon")
	show_teammate_blitz_icon = mod:get("show_teammate_blitz_icon")
	show_teammate_aura_icon = mod:get("show_teammate_aura_icon")
	show_teammate_ability_cooldown = mod:get("show_teammate_ability_cooldown")
	show_teammate_blitz_charges = mod:get("show_teammate_blitz_charges")
	cooldown_format = mod:get("cooldown_format")
end

refresh_teammate_ability_settings()

mod.refresh_teammate_ability_settings = refresh_teammate_ability_settings


local function get_cached_talent_loadout(player, player_name)
	local profile = player and player:profile()

	if not profile then
		return nil
	end

	local talents = profile.talents
	local cached_loadout = teammate_talent_loadouts[player_name]

	if cached_loadout and cached_loadout.profile == profile and cached_loadout.talents == talents then
		return cached_loadout.loadout_data
	end

	local loadout_data = {
		ability = {},
		blitz = {},
		aura = {},
	}

	-- mute_log = true suppresses the vanilla "[CharacterSheet] Selecting talent ..." info output
	local success = pcall(CharacterSheet.class_loadout, profile, loadout_data, false, talents or {}, true)

	if not success then
		loadout_data = nil
	end

	teammate_talent_loadouts[player_name] = {
		profile = profile,
		talents = talents,
		loadout_data = loadout_data,
	}

	return loadout_data
end

local function get_talent_from_character_sheet(player, player_name, ability_key)
	local loadout_data = get_cached_talent_loadout(player, player_name)

	return loadout_data and loadout_data[ability_key]
end

local TALENT_ABILITY_METADATA = mod.TALENT_ABILITY_METADATA

-- Returns ability_id, ability_type, icon for the metadata entry's slot, or nil if it can't be resolved
local function get_player_ability_by_type(player, extensions, ability_info, player_name)
	local slot_type = ability_info.slot
	
	if slot_type == "slot_coherency_ability" then
		local aura_entry = get_talent_from_character_sheet(player, player_name, "aura")

		if aura_entry and aura_entry.icon then
			return "aura", "coherency_ability", aura_entry.icon
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
	
	-- equipped_abilities is keyed by ability type; 1.13.0 ability_configuration maps combat/grenade_ability one-to-one to their slots
	local ability_type = ability_info.type
	local ability_settings = equipped_abilities[ability_type]
	
	if not ability_settings then
		-- empty slot entry from ability extension; skip (avoids errors after loadout sync changes)
		return nil
	end
	
	local icon = nil

	if slot_type == "slot_grenade_ability" then
		local blitz_entry = get_talent_from_character_sheet(player, player_name, "blitz")
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
	
	return ability_type, ability_type, icon
end

-- The teammate copy's get_ability_resource_regen_progress divides by the template cost, which ignores cost
-- modifiers. max_ability_resource, the resource and the charge count are synced with them, so the cost per
-- charge is taken from those.
local function get_regen_progress(ability_extension, ability_type)
	local ability = ability_extension:ability_is_equipped(ability_type)

	-- charges-only blitzes (grenades) and abilities without their own charge-based pool keep the vanilla value
	if not ability or ability.only_uses_charges or ability.resource_pool_override or (ability.usage_cost_type or "charges") ~= "charges" then
		return ability_extension:get_ability_resource_regen_progress(ability_type)
	end

	local max_charges = ability_extension:max_ability_charges(ability_type)
	local max_resource = ability_extension:max_ability_resource(ability_type)

	-- values that aren't synced yet keep the vanilla value
	if max_charges <= 0 or max_resource <= 0 then
		return ability_extension:get_ability_resource_regen_progress(ability_type)
	end

	local remaining_charges = ability_extension:remaining_ability_charges(ability_type)

	if remaining_charges >= max_charges then
		return 1
	end

	local cost_per_charge = max_resource / max_charges
	local charge_resource = ability_extension:remaining_ability_resource(ability_type) - remaining_charges * cost_per_charge

	return math_clamp(charge_resource / cost_per_charge, 0, 1)
end

-- regen_progress is the raw get_regen_progress value, read once per frame by the caller
local function get_ability_state(player, extensions, ability_type, regen_progress)
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
	
	local max_resource = ability_extension:max_ability_resource(ability_type)
	local is_paused = ability_extension:is_ability_resource_regen_paused(ability_type)
	local remaining_charges = ability_extension:remaining_ability_charges(ability_type)
	local max_charges = ability_extension:max_ability_charges(ability_type)
	
	local uses_charges = max_charges and max_charges > 1
	local has_charges_left = remaining_charges and remaining_charges > 0 or false
	
	local cooldown_progress
	
	-- Mirrors the 1.13.0 vanilla HudElementPlayerAbility resource logic (can_use_ability is not available on husks)
	if is_paused then
		cooldown_progress = 0
	elseif max_resource and max_resource > 0 then
		cooldown_progress = regen_progress or 0
		
		-- NaN guard, mirrors HudElementPlayerAbility._set_progress
		if cooldown_progress ~= cooldown_progress then
			cooldown_progress = 0
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

local NUM_ABILITY_TYPES = #TALENT_ABILITY_METADATA

-- Widget names and gradient maps are constant per ability, so build them once instead of every frame
local ABILITY_ICON_WIDGET_NAMES = {}
local ABILITY_TEXT_WIDGET_NAMES = {}
local ABILITY_GRADIENT_MAPS = {}

for i = 1, NUM_ABILITY_TYPES do
	local ability_info = TALENT_ABILITY_METADATA[i]
	
	ABILITY_ICON_WIDGET_NAMES[i] = "talent_ui_all_" .. ability_info.id .. "_icon"
	ABILITY_TEXT_WIDGET_NAMES[i] = "talent_ui_all_" .. ability_info.id .. "_text"
	ABILITY_GRADIENT_MAPS[i] = get_ability_gradient_map(ability_info.id)
end

-- Returns intensity, saturation for the ability's current state
local function get_ability_material_settings(ability_id, on_cooldown, uses_charges, has_charges_left, max_charges)
	local icon_settings = TalentUISettings and TalentUISettings.teammate_ability_icon_material_settings
	local ability_settings = icon_settings and icon_settings[ability_id]
	
	if not ability_settings then
		return 0, 1
	end
	
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
		return state_settings.intensity or 0, state_settings.saturation or 1
	end
	
	return 0, 1
end

local function set_team_talent_widget_visible(widget, visible)
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

local function hide_all_ability_widgets(self)
	local widgets_by_name = self._widgets_by_name

	for i = 1, NUM_ABILITY_TYPES do
		local icon_widget = widgets_by_name[ABILITY_ICON_WIDGET_NAMES[i]]
		local text_widget = widgets_by_name[ABILITY_TEXT_WIDGET_NAMES[i]]
		
		set_team_talent_widget_visible(icon_widget, false)
		set_team_talent_widget_visible(text_widget, false)
	end
end

-- Returns the cooldown text, cached on ability_data; the string is only formatted again when the displayed numbers or format change.
-- regen_progress must be the raw get_regen_progress value, not get_ability_state's guarded cooldown_progress
local function format_cooldown_text(ability_data, ability_ext, ability_type_name, format_type, uses_charges, remaining_charges, regen_progress)
	local charges = nil
	local cooldown = nil
	
	if uses_charges and remaining_charges ~= nil and remaining_charges > 0 then
		charges = remaining_charges
	end
	
	-- nil/NaN progress fails the comparison and produces no cooldown text
	if regen_progress and regen_progress < 1 then
		if format_type == "time" then
			local max_regen_time = ability_ext:max_regen_time_for_ability_charge(ability_type_name)
			if max_regen_time and max_regen_time > 0 then
				local remaining_time = (1 - regen_progress) * max_regen_time
				if remaining_time > 0 then
					cooldown = math_ceil(remaining_time)
				end
			end
		elseif format_type == "percent" then
			local percent = regen_progress * 100
			if percent < 99 then
				cooldown = math_floor(percent)
			end
		end
	end
	
	if ability_data.text_format == format_type and ability_data.text_charges == charges and ability_data.text_cooldown == cooldown then
		return ability_data.text
	end
	
	local charges_text = ""
	local cooldown_text = ""
	
	if charges then
		charges_text = tostring(charges)
	end
	
	if cooldown then
		if format_type == "time" then
			cooldown_text = string_format("%d", cooldown)
		else
			cooldown_text = string_format("%d%%", cooldown)
		end
	end
	
	local text
	
	if charges_text ~= "" and cooldown_text ~= "" then
		text = string_format("%s (%s)", charges_text, cooldown_text)
	elseif charges_text ~= "" then
		text = charges_text
	else
		text = cooldown_text
	end
	
	ability_data.text_format = format_type
	ability_data.text_charges = charges
	ability_data.text_cooldown = cooldown
	ability_data.text = text
	
	return text
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
	if (not show_for_bots and not is_human_controlled) or self._show_as_dead or self._dead or self._hogtied then
		hide_all_ability_widgets(self)
		return
	end
	
	local player_abilities_data = teammate_abilities_data[player_name]
	if not player_abilities_data then
		player_abilities_data = Script.new_map(NUM_ABILITY_TYPES)
		teammate_abilities_data[player_name] = player_abilities_data
	end
	
	local widgets_by_name = self._widgets_by_name
	local icon_size = teammate_ability_icon_size
	
	for i = 1, NUM_ABILITY_TYPES do
		-- if self._show_as_dead or self._dead or self._hogtied then
		-- 	hide_all_ability_widgets(self)
		-- 	return
		-- end
		
		local ability_info = TALENT_ABILITY_METADATA[i]
		local icon_widget = widgets_by_name[ABILITY_ICON_WIDGET_NAMES[i]]
		local text_widget = widgets_by_name[ABILITY_TEXT_WIDGET_NAMES[i]]
		
		if icon_widget then
			local ability_id = ability_info.id
			
			local ability_data = player_abilities_data[ability_id]
			
			local resolved_ability_id, resolved_ability_type, resolved_icon = get_player_ability_by_type(player, extensions, ability_info, player_name)
			if resolved_ability_type and resolved_icon then
				if not ability_data then
					ability_data = {
						ability_id = resolved_ability_id,
						ability_type = resolved_ability_type,
						icon = resolved_icon,
						-- Last formatted texts and the values they were built from
						text = "",
						text_format = nil,
						text_charges = nil,
						text_cooldown = nil,
						charges_value = nil,
						charges_text = nil,
					}
					player_abilities_data[ability_id] = ability_data
				elseif ability_data.ability_type ~= resolved_ability_type or ability_data.icon ~= resolved_icon then
					ability_data.ability_id = resolved_ability_id
					ability_data.ability_type = resolved_ability_type
					ability_data.icon = resolved_icon
				end
			end

			local has_ability = ability_data and ability_data.ability_type
			local show_icon = true
			if ability_id == "ability" then
				show_icon = show_teammate_ability_icon
			elseif ability_id == "blitz" then
				show_icon = show_teammate_blitz_icon
			elseif ability_id == "aura" then
				show_icon = show_teammate_aura_icon
			end
			
			if has_ability and show_icon then
				local ability_type = ability_data.ability_type
				local icon = ability_data.icon
				
				local text_style = text_widget and text_widget.style
				text_style = text_style and text_style.text
				local text_size = text_style and text_style.size
				
				if text_size then
					if text_size[1] ~= icon_size or text_size[2] ~= icon_size then
						text_size[1] = icon_size
						text_size[2] = icon_size
						text_widget.dirty = true
					end
				end
				
				local ability_extension = extensions.ability
				
				-- Read once per frame; get_ability_state and format_cooldown_text both use this raw value
				local regen_progress = nil
				if ability_extension and ability_type ~= "coherency_ability" then
					regen_progress = get_regen_progress(ability_extension, ability_type)
				end
				
				local cooldown_progress, on_cooldown, remaining_charges, has_charges_left, max_charges = get_ability_state(player, extensions, ability_type, regen_progress)
				local uses_charges = max_charges and max_charges > 1
				
				local icon_style = icon_widget.style
				icon_style = icon_style and icon_style.icon
				local material_values = icon_style and icon_style.material_values
				
				local gradient_map = ABILITY_GRADIENT_MAPS[i]
				if gradient_map and material_values and material_values.gradient_map ~= gradient_map then
					material_values.gradient_map = gradient_map
					icon_widget.dirty = true
				end
				
				local intensity, saturation = get_ability_material_settings(ability_id, on_cooldown, uses_charges, has_charges_left, max_charges)
				
				if material_values then
					local needs_update = false
					
					if material_values.intensity ~= intensity then
						material_values.intensity = intensity
						needs_update = true
					end
					
					if material_values.saturation ~= saturation then
						material_values.saturation = saturation
						needs_update = true
					end
					
					if needs_update then
						icon_widget.dirty = true
					end
				end
				
				if icon and material_values then
					if material_values.icon ~= icon then
						material_values.icon = icon
						icon_widget.dirty = true
					end
				end
				
				local needs_icon_update = false

				if icon_widget.content.visible ~= true then
					set_team_talent_widget_visible(icon_widget, true)
					needs_icon_update = true
				end

				if needs_icon_update then
					icon_widget.dirty = true
				end
				
				if text_widget then
					local display_text = ""
					local show_text = true
					
					if ability_id == "ability" then
						show_text = show_teammate_ability_cooldown
						
						if show_text and ability_extension then
							display_text = format_cooldown_text(ability_data, ability_extension, "combat_ability", cooldown_format, uses_charges, remaining_charges, regen_progress)
						end
					elseif ability_id == "blitz" then
						show_text = show_teammate_blitz_charges
						
						if show_text and ability_extension then
							if uses_charges then
								-- remaining_charges was read by get_ability_state; uses_charges implies it got past the equip check
								if remaining_charges ~= nil and remaining_charges >= 0 then
									if ability_data.charges_value ~= remaining_charges then
										ability_data.charges_value = remaining_charges
										ability_data.charges_text = tostring(remaining_charges)
									end
									
									display_text = ability_data.charges_text
								end
							else
								display_text = format_cooldown_text(ability_data, ability_extension, "grenade_ability", cooldown_format, uses_charges, remaining_charges, regen_progress)
							end
						end
					end
					
					local text_content = text_widget.content
					local needs_text_update = false
					local new_visible = show_text and display_text ~= ""
					
					if text_content.text ~= display_text then
						text_content.text = display_text
						needs_text_update = true
					end
					
					if text_content.visible ~= new_visible then
						set_team_talent_widget_visible(text_widget, new_visible)
						needs_text_update = true
					end
					
					if needs_text_update then
						text_widget.dirty = true
					end
				end
			else
				set_team_talent_widget_visible(icon_widget, false)

				if text_widget then
					set_team_talent_widget_visible(text_widget, false)
				end
			end
		end
	end
end

mod.update_teammate_all_abilities = update_teammate_all_abilities

mod.clear_teammate_all_abilities_data = function(player_name)
	teammate_abilities_data[player_name] = nil
	teammate_talent_loadouts[player_name] = nil
	player_previous_human_state[player_name] = nil
end
