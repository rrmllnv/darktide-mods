local mod = get_mod("DivisionHUD")

local AbilityTemplates = require("scripts/settings/ability/ability_templates/ability_templates")
local Action = require("scripts/utilities/action/action")
local FixedFrame = require("scripts/utilities/fixed_frame")
local LungeTemplates = require("scripts/settings/lunge/lunge_templates")
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

local M = {}

local TIMED_OVERLAY_MAX_TOTAL_TIME = 120
local OVERLAY_GROUP_START_TIME_EPSILON = 0.05

local MANUAL_ABILITY_GROUP_BUFF_TEMPLATES = {
	volley_fire_stance = {
		"veteran_combat_ability_stance_master",
		"veteran_combat_ability_stance_master_increased_duration",
	},
	veteran_stealth = {
		"veteran_invisibility",
	},
	voice_of_command = {
		"veteran_combat_ability_increase_toughness_to_coherency",
	},
	zealot_dash = {
		"zealot_dash_buff",
		"zealot_combat_ability_attack_speed_increase",
		"zealot_combat_ability_attack_speed_increased_duration",
	},
	bolstering_prayer = {
		"zealot_channel_toughness_bonus",
	},
	zealot_invisibility = {
		"zealot_invisibility",
		"zealot_invisibility_increased_duration",
	},
	psyker_shout = {
		"psyker_shout_warp_generation_reduction",
	},
	psyker_overcharge_stance = {
		"psyker_overcharge_stance_damage",
		"psyker_overcharge_stance_finesse_damage",
	},
	ogryn_charge = {
		"ogryn_charge_speed_on_lunge",
	},
	ogryn_gunlugger_stance = {
		"ogryn_ranged_stance",
	},
	ogryn_taunt_shout = {
		"ogryn_repeat_taunt",
	},
	adamant_charge = {
		"adamant_post_charge_buff",
	},
	adamant_stance = {
		"adamant_hunt_stance",
	},
	broker_focus_stance = {
		"broker_focus_stance",
		"broker_focus_stance_improved",
	},
	broker_punk_rage_stance = {
		"broker_punk_rage_stance",
	},
}

local DEPLOYABLE_ABILITY_GROUP_TO_TRACKED_NAME = {
	adamant_area_buff_drone = "adamant_drone",
	broker_stimm_field = "broker_stimm_field",
}

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

local function append_manual_ability_group_buff_candidates(ability_row, candidate_list)
	if type(candidate_list) ~= "table" or type(ability_row) ~= "table" then
		return candidate_list
	end

	local ability_group = ability_row.ability_group
	local manual_templates = ability_group and MANUAL_ABILITY_GROUP_BUFF_TEMPLATES[ability_group]

	if type(manual_templates) ~= "table" then
		return candidate_list
	end

	for i = 1, #manual_templates do
		append_unique(candidate_list, manual_templates[i])
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

local function append_overlay_entry(entry_list, progress, remaining_time, start_time, color, key)
	if type(entry_list) ~= "table" then
		return
	end

	if type(progress) ~= "number" or progress ~= progress or progress <= 0 then
		return
	end

	entry_list[#entry_list + 1] = {
		progress = math.clamp01(progress),
		remaining_time = type(remaining_time) == "number" and remaining_time or nil,
		start_time = type(start_time) == "number" and start_time or nil,
		color = color,
		key = key,
	}
end

local function sort_overlay_entries(entry_list)
	if type(entry_list) ~= "table" or #entry_list <= 1 then
		return entry_list
	end

	table.sort(entry_list, function(a, b)
		local a_start = a.start_time
		local b_start = b.start_time

		if a_start ~= nil and b_start ~= nil and a_start ~= b_start then
			return a_start < b_start
		end

		local a_remaining = a.remaining_time
		local b_remaining = b.remaining_time

		if a_remaining ~= nil and b_remaining ~= nil and a_remaining ~= b_remaining then
			return a_remaining < b_remaining
		end

		return (a.progress or 0) < (b.progress or 0)
	end)

	return entry_list
end

local function compact_overlay_entries(entry_list)
	if type(entry_list) ~= "table" or #entry_list <= 1 then
		return entry_list
	end

	local compacted_entries = {}

	for i = 1, #entry_list do
		local current_entry = entry_list[i]
		local last_entry = compacted_entries[#compacted_entries]
		local current_start = current_entry and current_entry.start_time
		local last_start = last_entry and last_entry.start_time
		local should_merge = false

		if type(current_start) == "number" and type(last_start) == "number" then
			should_merge = math.abs(current_start - last_start) <= OVERLAY_GROUP_START_TIME_EPSILON
		end

		if should_merge then
			local current_remaining = current_entry.remaining_time
			local last_remaining = last_entry.remaining_time
			local should_replace_progress = false

			if type(current_remaining) == "number" and type(last_remaining) == "number" then
				should_replace_progress = current_remaining > last_remaining
			elseif type(current_remaining) == "number" then
				should_replace_progress = true
			elseif type(current_entry.progress) == "number" and type(last_entry.progress) == "number" then
				should_replace_progress = current_entry.progress > last_entry.progress
			end

			if should_replace_progress then
				last_entry.progress = current_entry.progress
				last_entry.remaining_time = current_entry.remaining_time
			end

			if last_entry.color == nil then
				last_entry.color = current_entry.color
			end

			if last_entry.key == nil then
				last_entry.key = current_entry.key
			end
		else
			compacted_entries[#compacted_entries + 1] = current_entry
		end
	end

	table.clear(entry_list)

	for i = 1, #compacted_entries do
		entry_list[i] = compacted_entries[i]
	end

	return entry_list
end

local function assign_overlay_entries_to_slots(entry_list, spent_segments, slot_keys)
	if spent_segments <= 0 then
		if type(slot_keys) == "table" then
			table.clear(slot_keys)
		end

		return {}
	end

	local assigned_entries = {}
	local next_slot_keys = {}
	local entry_by_key = {}
	local unassigned_entries = {}

	if type(entry_list) == "table" then
		for i = 1, #entry_list do
			local entry = entry_list[i]
			local entry_key = entry and entry.key

			if type(entry_key) == "string" and entry_by_key[entry_key] == nil then
				entry_by_key[entry_key] = entry
			else
				unassigned_entries[#unassigned_entries + 1] = entry
			end
		end
	end

	if type(slot_keys) == "table" then
		for slot_index = 1, spent_segments do
			local slot_key = slot_keys[slot_index]
			local existing_entry = type(slot_key) == "string" and entry_by_key[slot_key] or nil

			if existing_entry then
				assigned_entries[slot_index] = existing_entry
				next_slot_keys[slot_index] = slot_key
				entry_by_key[slot_key] = nil
			end
		end
	end

	if type(entry_list) == "table" then
		for i = 1, #entry_list do
			local entry = entry_list[i]
			local entry_key = entry and entry.key

			if type(entry_key) == "string" and entry_by_key[entry_key] ~= nil then
				unassigned_entries[#unassigned_entries + 1] = entry
				entry_by_key[entry_key] = nil
			end
		end
	end

	local unassigned_index = 1

	for slot_index = 1, spent_segments do
		if assigned_entries[slot_index] == nil then
			local entry = unassigned_entries[unassigned_index]
			unassigned_index = unassigned_index + 1
			assigned_entries[slot_index] = entry
			next_slot_keys[slot_index] = entry and entry.key or nil
		end
	end

	if type(slot_keys) == "table" then
		table.clear(slot_keys)

		for i = 1, spent_segments do
			slot_keys[i] = next_slot_keys[i]
		end
	end

	return assigned_entries
end

local function collect_buff_overlay_entries(buff_extension, candidate_list, entry_list)
	if not buff_extension or type(candidate_list) ~= "table" or type(entry_list) ~= "table" or #candidate_list == 0 then
		return entry_list
	end

	local wanted_templates = {}

	for i = 1, #candidate_list do
		wanted_templates[candidate_list[i]] = true
	end

	local buff_instances = buff_extension._buffs

	if type(buff_instances) ~= "table" then
		return entry_list
	end

	for i = 1, #buff_instances do
		local buff_instance = buff_instances[i]
		local template = buff_instance and buff_instance:template()
		local template_name = template and template.name

		if template_name and wanted_templates[template_name] and buff_template_supports_timed_bar(template) then
			local progress = buff_instance:duration_progress()
			local duration = type(buff_instance.duration) == "function" and buff_instance:duration() or nil
			local remaining_time = type(duration) == "number" and duration > 0 and progress * duration or nil
			local start_time = type(buff_instance.start_time) == "function" and buff_instance:start_time() or nil
			local entry_key = string.format("buff:%s:%s", template_name, tostring(buff_instance))

			append_overlay_entry(entry_list, progress, remaining_time, start_time, nil, entry_key)
		end
	end

	return entry_list
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

local function timed_action_remaining_progress(player_unit, ability_extension, ability_row)
	if type(ability_row) == "table" and ability_row.ability_group == "psyker_shout" then
		return nil
	end

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

local function combat_ability_is_active(player_unit)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return false
	end

	local combat_ability_component = unit_data_extension:read_component("combat_ability")

	return combat_ability_component ~= nil and combat_ability_component.active == true
end

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

local function psyker_force_field_bar_fill_progress(player_unit, ability_row)
	if not player_unit or type(ability_row) ~= "table" then
		return nil
	end

	if ability_row.ability_group ~= "psyker_shield" then
		return nil
	end

	local extension_manager = Managers.state.extension

	if not extension_manager then
		return nil
	end

	local force_field_system = extension_manager:system("force_field_system")

	if not force_field_system or type(force_field_system.get_extensions_by_owner_unit) ~= "function" then
		return nil
	end

	local extensions = force_field_system:get_extensions_by_owner_unit(player_unit)

	if type(extensions) ~= "table" or #extensions == 0 then
		return nil
	end

	local best_progress = nil
	local best_time_left = nil

	for i = 1, #extensions do
		local extension = extensions[i]
		local remaining_duration = extension and extension:remaining_duration()
		local max_duration = extension and extension._max_duration

		if type(remaining_duration) == "number" and remaining_duration > 0 and type(max_duration) == "number" and max_duration > 0 then
			local progress = math.clamp01(remaining_duration / max_duration)

			if best_time_left == nil or remaining_duration > best_time_left then
				best_time_left = remaining_duration
				best_progress = progress
			end
		end
	end

	return best_progress
end

local function collect_psyker_force_field_overlay_entries(player_unit, ability_row, entry_list)
	if not player_unit or type(ability_row) ~= "table" or type(entry_list) ~= "table" then
		return entry_list
	end

	if ability_row.ability_group ~= "psyker_shield" then
		return entry_list
	end

	local extension_manager = Managers.state.extension

	if not extension_manager then
		return entry_list
	end

	local force_field_system = extension_manager:system("force_field_system")

	if not force_field_system or type(force_field_system.get_extensions_by_owner_unit) ~= "function" then
		return entry_list
	end

	local Hu = mod.hud_utils
	local gameplay_time = Hu and type(Hu.safe_gameplay_time) == "function" and Hu.safe_gameplay_time() or nil
	local extensions = force_field_system:get_extensions_by_owner_unit(player_unit)

	if type(extensions) ~= "table" or #extensions == 0 then
		return entry_list
	end

	for i = 1, #extensions do
		local extension = extensions[i]
		local remaining_duration = extension and extension:remaining_duration()
		local max_duration = extension and extension._max_duration

		if type(remaining_duration) == "number" and remaining_duration > 0 and type(max_duration) == "number" and max_duration > 0 then
			local progress = math.clamp01(remaining_duration / max_duration)
			local start_time = type(gameplay_time) == "number" and gameplay_time - (max_duration - remaining_duration) or nil
			local entry_key = string.format("force_field:%s", tostring(extension))

			append_overlay_entry(entry_list, progress, remaining_duration, start_time, nil, entry_key)
		end
	end

	return entry_list
end

local function psyker_overcharge_stance_bar_fill_progress(player_unit, ability_row, buff_extension)
	if not player_unit or type(ability_row) ~= "table" or not buff_extension then
		return nil
	end

	if ability_row.ability_group ~= "psyker_overcharge_stance" then
		return nil
	end

	if not buff_extension:has_buff_using_buff_template("psyker_overcharge_stance") then
		return nil
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return nil
	end

	local warp_charge_component = unit_data_extension:read_component("warp_charge")
	local current_percentage = warp_charge_component and warp_charge_component.current_percentage

	if type(current_percentage) ~= "number" or current_percentage ~= current_percentage then
		return nil
	end

	return math.clamp01(1 - current_percentage)
end

local function collect_psyker_overcharge_overlay_entries(player_unit, ability_row, buff_extension, entry_list)
	if type(entry_list) ~= "table" then
		return entry_list
	end

	local progress = psyker_overcharge_stance_bar_fill_progress(player_unit, ability_row, buff_extension)

	append_overlay_entry(entry_list, progress, progress, nil, nil, "psyker_overcharge_stance")

	return entry_list
end

local function tracked_deployable_bar_fill_progress(ability_row)
	if type(ability_row) ~= "table" then
		return nil
	end

	local tracked_name = DEPLOYABLE_ABILITY_GROUP_TO_TRACKED_NAME[ability_row.ability_group]
	local tracked_deployables = mod.tracked_deployables

	if type(tracked_name) ~= "string" or type(tracked_deployables) ~= "table" then
		return nil
	end

	local Hu = mod.hud_utils
	local gameplay_time = Hu and type(Hu.safe_gameplay_time) == "function" and Hu.safe_gameplay_time() or nil

	if type(gameplay_time) ~= "number" then
		return nil
	end

	local best_progress = nil
	local best_remaining = nil

	for unit, data in pairs(tracked_deployables) do
		local duration = data and data.duration
		local start_time = data and data.start_time

		if data and data.name == tracked_name and type(duration) == "number" and duration > 0 and type(start_time) == "number" then
			local elapsed = gameplay_time - start_time
			local remaining = duration - elapsed

			if remaining > 0 then
				local progress = math.clamp01(remaining / duration)

				if best_remaining == nil or remaining > best_remaining then
					best_remaining = remaining
					best_progress = progress
				end
			else
				tracked_deployables[unit] = nil
			end
		end
	end

	return best_progress
end

local function collect_tracked_deployable_overlay_entries(ability_row, entry_list)
	if type(ability_row) ~= "table" or type(entry_list) ~= "table" then
		return entry_list
	end

	local tracked_name = DEPLOYABLE_ABILITY_GROUP_TO_TRACKED_NAME[ability_row.ability_group]
	local tracked_deployables = mod.tracked_deployables

	if type(tracked_name) ~= "string" or type(tracked_deployables) ~= "table" then
		return entry_list
	end

	local Hu = mod.hud_utils
	local gameplay_time = Hu and type(Hu.safe_gameplay_time) == "function" and Hu.safe_gameplay_time() or nil

	if type(gameplay_time) ~= "number" then
		return entry_list
	end

	for unit, data in pairs(tracked_deployables) do
		local duration = data and data.duration
		local start_time = data and data.start_time

		if data and data.name == tracked_name and type(duration) == "number" and duration > 0 and type(start_time) == "number" then
			local elapsed = gameplay_time - start_time
			local remaining = duration - elapsed

			if remaining > 0 then
				local entry_key = string.format("deployable:%s", tostring(unit))

				append_overlay_entry(entry_list, remaining / duration, remaining, start_time, nil, entry_key)
			else
				tracked_deployables[unit] = nil
			end
		end
	end

	return entry_list
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

function M.is_ability_in_use_or_on_cooldown(player_unit, combat_ability_type)
	if not player_unit then
		return false
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(combat_ability_type) then
		return false
	end

	local max_cooldown = ability_extension:max_ability_cooldown(combat_ability_type) or 0
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(combat_ability_type) or 0

	if max_cooldown > 0 and remaining_cooldown > 0 then
		return true
	end

	return M.is_ability_effect_active(player_unit, combat_ability_type)
end

function M.is_ability_effect_active(player_unit, combat_ability_type)
	if not player_unit then
		return false
	end

	if combat_ability_is_active(player_unit) then
		return true
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(combat_ability_type) then
		return false
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
	local equipped_abilities = ability_extension:equipped_abilities()
	local ability_row = equipped_abilities and equipped_abilities[combat_ability_type]
	local template_key = ability_row and ability_row.ability_template
	local tweak_data = ability_row and ability_row.ability_template_tweak_data
	local ability_template = template_key and AbilityTemplates[template_key]
	local buff_candidates = collect_duration_buff_candidates(ability_template, tweak_data, {})

	append_manual_ability_group_buff_candidates(ability_row, buff_candidates)

	local buff_overlay_progress = buff_extension and best_buff_overlay_progress(buff_extension, buff_candidates)

	if buff_overlay_progress and buff_overlay_progress > 0 then
		return true
	end

	local psyker_force_field_overlay_progress = psyker_force_field_bar_fill_progress(player_unit, ability_row)

	if psyker_force_field_overlay_progress and psyker_force_field_overlay_progress > 0 then
		return true
	end

	local psyker_overcharge_overlay_progress = psyker_overcharge_stance_bar_fill_progress(player_unit, ability_row, buff_extension)

	if psyker_overcharge_overlay_progress and psyker_overcharge_overlay_progress > 0 then
		return true
	end

	local tracked_deployable_overlay_progress = tracked_deployable_bar_fill_progress(ability_row)

	if tracked_deployable_overlay_progress and tracked_deployable_overlay_progress > 0 then
		return true
	end

	local relic_channel_fill = weapon_zealot_channel_bar_fill_progress(player_unit)

	if relic_channel_fill and relic_channel_fill > 0 then
		return true
	end

	local lunge_overlay_progress = lunge_remaining_progress(player_unit)

	if lunge_overlay_progress and lunge_overlay_progress > 0 then
		return true
	end

	local timed_overlay_progress = timed_action_remaining_progress(player_unit, ability_extension, ability_row)

	if timed_overlay_progress and timed_overlay_progress > 0 then
		return true
	end

	return false
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
	local base_cooldown_progress = cooldown_progress
	local base_active_partial_fill = active_partial_fill
	local base_partial_fill_color = st.in_process_of_going_on_cooldown and ready_color or cooldown_color
	local partial_fill_color = base_partial_fill_color

	local equipped_abilities = ability_extension:equipped_abilities()
	local ability_row = equipped_abilities and equipped_abilities[combat_ability_type]
	local template_key = ability_row and ability_row.ability_template
	local tweak_data = ability_row and ability_row.ability_template_tweak_data
	local ability_template = template_key and AbilityTemplates[template_key]
	local buff_candidates = collect_duration_buff_candidates(ability_template, tweak_data, {})
	local suppress_base_cooldown_visual = ability_row and ability_row.ability_group == "psyker_shout" and combat_ability_is_active(player_unit)

	append_manual_ability_group_buff_candidates(ability_row, buff_candidates)

	local active_overlay_entries = {}
	local buff_overlay_progress = buff_extension and best_buff_overlay_progress(buff_extension, buff_candidates)
	local psyker_force_field_overlay_progress = psyker_force_field_bar_fill_progress(player_unit, ability_row)
	local psyker_overcharge_overlay_progress = psyker_overcharge_stance_bar_fill_progress(player_unit, ability_row, buff_extension)
	local tracked_deployable_overlay_progress = tracked_deployable_bar_fill_progress(ability_row)
	local relic_channel_fill = weapon_zealot_channel_bar_fill_progress(player_unit)
	local lunge_overlay_progress = lunge_remaining_progress(player_unit)
	local timed_overlay_progress = timed_action_remaining_progress(player_unit, ability_extension, ability_row)

	if suppress_base_cooldown_visual then
		cooldown_progress = 0
		active_partial_fill = false
		base_cooldown_progress = 0
		base_active_partial_fill = false
	end

	collect_buff_overlay_entries(buff_extension, buff_candidates, active_overlay_entries)
	collect_psyker_force_field_overlay_entries(player_unit, ability_row, active_overlay_entries)
	collect_psyker_overcharge_overlay_entries(player_unit, ability_row, buff_extension, active_overlay_entries)
	collect_tracked_deployable_overlay_entries(ability_row, active_overlay_entries)
	sort_overlay_entries(active_overlay_entries)
	compact_overlay_entries(active_overlay_entries)

	if psyker_overcharge_overlay_progress and psyker_overcharge_overlay_progress > 0 then
		cooldown_progress = psyker_overcharge_overlay_progress
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif buff_overlay_progress then
		cooldown_progress = buff_overlay_progress
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif psyker_force_field_overlay_progress and psyker_force_field_overlay_progress > 0 then
		cooldown_progress = psyker_force_field_overlay_progress
		active_partial_fill = true
		partial_fill_color = ready_color
	elseif tracked_deployable_overlay_progress and tracked_deployable_overlay_progress > 0 then
		cooldown_progress = tracked_deployable_overlay_progress
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
		local spent_segments = math.max(n - remaining, 0)
		local overlay_slot_keys = widget.content.overlay_slot_keys or {}
		local slotted_overlay_entries = assign_overlay_entries_to_slots(active_overlay_entries, spent_segments, overlay_slot_keys)
		local recharge_slot_index = nil

		for slot_index = 1, spent_segments do
			if slotted_overlay_entries[slot_index] == nil then
				recharge_slot_index = slot_index

				break
			end
		end

		widget.content.overlay_slot_keys = overlay_slot_keys

		if use_segments then
			for i = 1, max_segments do
				local seg_style = widget.style["segment_" .. i]

				if i > n then
					apply_ability_segment_style(seg_style, 0, 0, ready_color, opacity)
				else
					local spent_slot_index = n - i + 1

					if spent_slot_index <= spent_segments then
						local overlay_entry = slotted_overlay_entries[spent_slot_index]

						if overlay_entry then
							local overlay_progress = overlay_entry.progress or 0
							local overlay_color = overlay_entry.color or ready_color

							apply_ability_segment_style(seg_style, ox, seg_w * overlay_progress, overlay_color, opacity)
							ox = ox + seg_w + segment_gap
						elseif recharge_slot_index == spent_slot_index then
							local w_fill = base_active_partial_fill and seg_w * base_cooldown_progress or seg_w
							local seg_color = base_active_partial_fill and base_partial_fill_color or ready_color

							apply_ability_segment_style(seg_style, ox, w_fill, seg_color, opacity)
							ox = ox + seg_w + segment_gap
						else
							apply_ability_segment_style(seg_style, ox, 0, ready_color, opacity)
							ox = ox + seg_w + segment_gap
						end
					else
						apply_ability_segment_style(seg_style, ox, seg_w, ready_color, opacity)
						ox = ox + seg_w + segment_gap
					end
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
