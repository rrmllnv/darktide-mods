local mod = get_mod("DivisionHUD")

local AbilityTemplates = require("scripts/settings/ability/ability_templates/ability_templates")
local Action = require("scripts/utilities/action/action")
local FixedFrame = require("scripts/utilities/fixed_frame")
local LungeTemplates = require("scripts/settings/lunge/lunge_templates")
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

local M = {}

-- Не показывать оверлей по total_time длиннее этого (в т.ч. отсекает math.huge у фазы прицеливания рывка).
local TIMED_OVERLAY_MAX_TOTAL_TIME = 120

local function append_unique(candidate_list, buff_template_name)
	if type(buff_template_name) ~= "string" or buff_template_name == "" then
		return
	end

	for i = 1, #candidate_list do
		if candidate_list[i] == buff_template_name then
			return
		end
	end

	candidate_list[#candidate_list + 1] = buff_template_name
end

local function append_delayed_buffs(candidate_list, delayed_spec)
	if type(delayed_spec) == "string" then
		append_unique(candidate_list, delayed_spec)
	elseif type(delayed_spec) == "table" then
		for i = 1, #delayed_spec do
			append_unique(candidate_list, delayed_spec[i])
		end
	end
end

local function collect_action_buff_references(action_settings, candidate_list)
	if type(action_settings) ~= "table" then
		return
	end

	append_unique(candidate_list, action_settings.add_buff)
	append_delayed_buffs(candidate_list, action_settings.add_delayed_buff)

	local proc_buffs = action_settings.proc_buffs

	if type(proc_buffs) == "table" then
		for i = 1, #proc_buffs do
			local proc_entry = proc_buffs[i]

			if type(proc_entry) == "table" then
				append_delayed_buffs(candidate_list, proc_entry.add_delayed_buff)
				append_unique(candidate_list, proc_entry.buff_to_add)
			end
		end
	end
end

local function collect_duration_buff_candidates(ability_template, ability_template_tweak_data, candidate_list)
	if type(candidate_list) ~= "table" then
		candidate_list = {}
	end

	if type(ability_template_tweak_data) == "table" and ability_template_tweak_data.buff_to_add then
		append_unique(candidate_list, ability_template_tweak_data.buff_to_add)
	end

	local actions = ability_template and ability_template.actions

	if type(actions) == "table" then
		for _, action_settings in pairs(actions) do
			collect_action_buff_references(action_settings, candidate_list)
		end
	end

	if type(ability_template_tweak_data) == "table" then
		local lunge_template_name = ability_template_tweak_data.lunge_template_name
		local lunge_template = lunge_template_name and LungeTemplates[lunge_template_name]

		if type(lunge_template) == "table" then
			append_unique(candidate_list, lunge_template.add_buff)
			append_delayed_buffs(candidate_list, lunge_template.add_delayed_buff)
		end
	end

	return candidate_list
end

local function buff_template_supports_timed_bar(template)
	if type(template) ~= "table" then
		return false
	end

	if type(template.duration_func) == "function" then
		return true
	end

	if type(template.duration) == "number" and template.duration > 0 then
		return true
	end

	return false
end

local function buff_template_duration_progress(buff_extension, buff_template_name)
	if not buff_extension or type(buff_template_name) ~= "string" then
		return nil
	end

	if buff_extension:current_stacks(buff_template_name) > 0 then
		return buff_extension:buff_duration_progress(buff_template_name)
	end

	if not buff_extension:has_buff_using_buff_template(buff_template_name) then
		return nil
	end

	local buff_instances = buff_extension._buffs

	if type(buff_instances) ~= "table" then
		return nil
	end

	for i = 1, #buff_instances do
		local buff_instance = buff_instances[i]
		local instance_template = buff_instance:template()

		if instance_template and instance_template.name == buff_template_name then
			if not buff_template_supports_timed_bar(instance_template) then
				return nil
			end

			return buff_instance:duration_progress()
		end
	end

	return nil
end

local function best_buff_overlay_progress(buff_extension, candidate_list)
	if not buff_extension or type(candidate_list) ~= "table" then
		return nil
	end

	local best_progress = nil

	for i = 1, #candidate_list do
		local template_name = candidate_list[i]
		local progress = buff_template_duration_progress(buff_extension, template_name)

		if type(progress) == "number" and progress == progress and progress > 0 then
			if best_progress == nil or progress > best_progress then
				best_progress = progress
			end
		end
	end

	return best_progress
end

local function lunge_remaining_progress(player_unit)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return nil
	end

	local lunge_state = unit_data_extension:read_component("lunge_character_state")

	if not lunge_state or not lunge_state.is_lunging then
		return nil
	end

	local lunge_template_name = lunge_state.lunge_template
	local lunge_template = lunge_template_name and LungeTemplates[lunge_template_name]
	local max_distance = lunge_template and lunge_template.distance

	if type(max_distance) ~= "number" or max_distance <= 0 then
		return nil
	end

	local distance_left = lunge_state.distance_left

	if type(distance_left) ~= "number" or distance_left ~= distance_left then
		return nil
	end

	return math.clamp01(distance_left / max_distance)
end

local function timed_action_remaining_progress(player_unit, ability_extension)
	local running_settings = ability_extension:running_action_settings()

	if type(running_settings) ~= "table" then
		return nil
	end

	local action_kind = running_settings.kind

	if action_kind == "stance_change" or action_kind == "targeted_dash_aim" or action_kind == "directional_dash_aim" then
		return nil
	end

	local total_time = running_settings.total_time

	if type(total_time) ~= "number" or total_time <= 0 or total_time ~= total_time or total_time > TIMED_OVERLAY_MAX_TOTAL_TIME then
		return nil
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return nil
	end

	local combat_ability_action = unit_data_extension:read_component("combat_ability_action")

	if not combat_ability_action or combat_ability_action.current_action_name == "none" then
		return nil
	end

	local fixed_t = FixedFrame.get_latest_fixed_time()
	local time_left = Action.time_left(combat_ability_action, fixed_t)

	if type(time_left) ~= "number" or time_left ~= time_left then
		return nil
	end

	return math.clamp01(time_left / total_time)
end

-- Заполнение полоски по каналу реликвии (Bolstering Prayer): идёт через weapon_action, не combat_ability_action.
local function weapon_zealot_channel_bar_fill_progress(player_unit)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return nil
	end

	local weapon_action = unit_data_extension:read_component("weapon_action")

	if not weapon_action or weapon_action.current_action_name == "none" then
		return nil
	end

	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")

	if not visual_loadout_extension then
		return nil
	end

	local inventory = unit_data_extension:read_component("inventory")
	local weapon_template = PlayerUnitVisualLoadout.wielded_weapon_template(visual_loadout_extension, inventory)

	if not weapon_template or type(weapon_template.actions) ~= "table" then
		return nil
	end

	local action_settings = Action.current_action_settings_from_component(weapon_action, weapon_template.actions)

	if type(action_settings) ~= "table" then
		return nil
	end

	if action_settings.kind ~= "zealot_channel" then
		return nil
	end

	local total_time = action_settings.total_time

	if type(total_time) ~= "number" or total_time <= 0 or total_time ~= total_time or total_time > TIMED_OVERLAY_MAX_TOTAL_TIME then
		return nil
	end

	local fixed_t = FixedFrame.get_latest_fixed_time()
	local time_left = Action.time_left(weapon_action, fixed_t)

	if type(time_left) ~= "number" or time_left ~= time_left then
		return nil
	end

	return math.clamp01(time_left / total_time)
end

local function compute_combat_ability_cooldown_state(ability_extension, buff_extension, ability_id)
	local state = {
		equipped = false,
		cooldown_progress = 0,
		uses_charges = false,
		has_charges_left = true,
		in_process_of_going_on_cooldown = false,
		force_on_cooldown = false,
		remaining_ability_charges = 0,
		max_ability_charges = 0,
		max_ability_cooldown = 0,
	}

	if not ability_extension or not ability_extension:ability_is_equipped(ability_id) then
		return state
	end

	state.equipped = true

	local remaining_ability_cooldown = ability_extension:remaining_ability_cooldown(ability_id)
	local max_ability_cooldown = ability_extension:max_ability_cooldown(ability_id)
	local is_paused = ability_extension:is_cooldown_paused(ability_id)
	local remaining_ability_charges = ability_extension:remaining_ability_charges(ability_id)
	local max_ability_charges = ability_extension:max_ability_charges(ability_id)

	state.remaining_ability_charges = remaining_ability_charges
	state.max_ability_charges = max_ability_charges
	state.max_ability_cooldown = max_ability_cooldown

	state.uses_charges = max_ability_charges and max_ability_charges > 1
	state.has_charges_left = remaining_ability_charges > 0

	local cooldown_progress
	local in_process_of_going_on_cooldown = false
	local force_on_cooldown = false
	local should_show_empty_cooldown = is_paused

	if should_show_empty_cooldown then
		cooldown_progress = 0
	elseif max_ability_cooldown and max_ability_cooldown > 0 then
		cooldown_progress = 1 - math.lerp(0, 1, remaining_ability_cooldown / max_ability_cooldown)

		if cooldown_progress == 0 then
			cooldown_progress = 1
		end
	else
		cooldown_progress = state.uses_charges and 1 or 0
	end

	local pause_cooldown_settings = ability_extension:ability_pause_cooldown_settings(ability_id)

	if pause_cooldown_settings and buff_extension then
		local duration_tracking_buff = pause_cooldown_settings.duration_tracking_buff

		if duration_tracking_buff then
			if type(duration_tracking_buff) == "table" then
				for _, duration_tracking_buff_name in ipairs(duration_tracking_buff) do
					if buff_extension:current_stacks(duration_tracking_buff_name) > 0 then
						cooldown_progress = buff_extension:buff_duration_progress(duration_tracking_buff_name)
						in_process_of_going_on_cooldown = cooldown_progress > 0

						break
					end
				end
			elseif buff_extension:current_stacks(duration_tracking_buff) > 0 then
				cooldown_progress = buff_extension:buff_duration_progress(duration_tracking_buff)
				in_process_of_going_on_cooldown = cooldown_progress > 0
			end
		end

		local on_cooldown_tracking_buff = pause_cooldown_settings.on_cooldown_tracking_buff

		if on_cooldown_tracking_buff then
			if type(on_cooldown_tracking_buff) == "table" then
				for j = 1, #on_cooldown_tracking_buff do
					if buff_extension:current_stacks(on_cooldown_tracking_buff[j]) > 0 then
						force_on_cooldown = true

						break
					end
				end
			else
				force_on_cooldown = buff_extension:current_stacks(on_cooldown_tracking_buff) > 0
			end
		end
	end

	state.cooldown_progress = cooldown_progress
	state.in_process_of_going_on_cooldown = in_process_of_going_on_cooldown
	state.force_on_cooldown = force_on_cooldown

	return state
end

local function apply_ability_segment_style(seg_style, offset_x, width, rgba, opacity)
	if not seg_style then
		return
	end

	seg_style.offset[1] = offset_x
	seg_style.size[1] = math.max(0, math.floor(width))
	seg_style.color[1] = math.floor((rgba[1] or 255) * opacity)
	seg_style.color[2] = rgba[2] or 255
	seg_style.color[3] = rgba[3] or 255
	seg_style.color[4] = rgba[4] or 255
end

function M.update(player_unit, widget, opacity, definitions, combat_ability_type)
	local settings = mod._settings
	local show_ability = settings and settings.show_ability_timer

	if not show_ability then
		widget.content.visible = false

		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not ability_extension then
		widget.content.visible = false

		return
	end

	local st = compute_combat_ability_cooldown_state(ability_extension, buff_extension, combat_ability_type)

	if not st.equipped then
		widget.content.visible = false

		return
	end

	if (st.max_ability_charges or 0) <= 0 and (st.max_ability_cooldown or 0) <= 0 then
		widget.content.visible = false

		return
	end

	local cooldown_progress = st.cooldown_progress or 0
	local vanilla_on_cooldown = cooldown_progress ~= 1 and not st.in_process_of_going_on_cooldown or st.force_on_cooldown
	local active_partial_fill = vanilla_on_cooldown or st.in_process_of_going_on_cooldown
	local remaining = st.remaining_ability_charges or 0
	local max_charges = st.max_ability_charges or 0

	local ready_color = definitions.ABILITY_BAR_READY_COLOR
	local cooldown_color = definitions.ABILITY_BAR_COOLDOWN_COLOR
	local partial_fill_color = cooldown_color

	local equipped_abilities = ability_extension:equipped_abilities()
	local ability_row = equipped_abilities and equipped_abilities[combat_ability_type]
	local template_key = ability_row and ability_row.ability_template
	local tweak_data = ability_row and ability_row.ability_template_tweak_data
	local ability_template = template_key and AbilityTemplates[template_key]
	local buff_candidates = collect_duration_buff_candidates(ability_template, tweak_data, {})
	local buff_overlay_progress = buff_extension and best_buff_overlay_progress(buff_extension, buff_candidates)
	local relic_channel_fill = weapon_zealot_channel_bar_fill_progress(player_unit)
	local lunge_overlay_progress = lunge_remaining_progress(player_unit)
	local timed_overlay_progress = timed_action_remaining_progress(player_unit, ability_extension)

	if buff_overlay_progress then
		cooldown_progress = buff_overlay_progress
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif relic_channel_fill and relic_channel_fill > 0 then
		cooldown_progress = relic_channel_fill
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif lunge_overlay_progress and lunge_overlay_progress > 0 then
		cooldown_progress = lunge_overlay_progress
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif timed_overlay_progress and timed_overlay_progress > 0 then
		cooldown_progress = timed_overlay_progress
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif st.in_process_of_going_on_cooldown then
		partial_fill_color = ready_color
	end

	local bar_width = definitions.BAR_WIDTH
	local max_segments = definitions.ABILITY_BAR_MAX_SEGMENTS
	local segment_gap = definitions.ABILITY_BAR_SEGMENT_GAP

	widget.content.visible = true

	if widget.style.background then
		widget.style.background.color[1] = math.floor(160 * opacity)
	end

	local function clear_segments_from(start_index)
		for j = start_index, max_segments do
			local seg_style = widget.style["segment_" .. j]

			apply_ability_segment_style(seg_style, 0, 0, ready_color, opacity)
		end
	end

	if max_charges > max_segments then
		local seg1 = widget.style.segment_1

		if active_partial_fill then
			apply_ability_segment_style(seg1, 0, bar_width * cooldown_progress, partial_fill_color, opacity)
		else
			apply_ability_segment_style(seg1, 0, bar_width, ready_color, opacity)
		end

		clear_segments_from(2)
	else
		local use_segments = max_charges > 1
		local n = use_segments and math.min(max_charges, max_segments) or 1
		local total_gap = (n - 1) * segment_gap
		local seg_w = n > 0 and math.max(1, math.floor((bar_width - total_gap) / n)) or bar_width
		local ox = 0

		if use_segments then
			for i = 1, max_segments do
				local seg_style = widget.style["segment_" .. i]

				if i > n then
					apply_ability_segment_style(seg_style, 0, 0, ready_color, opacity)
				elseif i <= remaining then
					apply_ability_segment_style(seg_style, ox, seg_w, ready_color, opacity)
					ox = ox + seg_w + segment_gap
				elseif i == remaining + 1 then
					local w_fill = active_partial_fill and seg_w * cooldown_progress or seg_w
					local seg_color = active_partial_fill and partial_fill_color or ready_color

					apply_ability_segment_style(seg_style, ox, w_fill, seg_color, opacity)
					ox = ox + seg_w + segment_gap
				else
					apply_ability_segment_style(seg_style, ox, 0, ready_color, opacity)
					ox = ox + seg_w + segment_gap
				end
			end
		else
			local seg1 = widget.style.segment_1

			if active_partial_fill then
				apply_ability_segment_style(seg1, 0, bar_width * cooldown_progress, partial_fill_color, opacity)
			else
				apply_ability_segment_style(seg1, 0, bar_width, ready_color, opacity)
			end

			clear_segments_from(2)
		end
	end

	widget.dirty = true
end

return M
