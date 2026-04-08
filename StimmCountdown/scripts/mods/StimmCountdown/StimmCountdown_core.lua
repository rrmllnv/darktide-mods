local StimmCountdownCore = {}

local function is_finite_cooldown_seconds_for_ui(t)
	if type(t) ~= "number" or t ~= t then
		return false
	end

	if t == math.huge or t == -math.huge then
		return false
	end

	return t >= 0.05
end

function StimmCountdownCore.get_buff_remaining_time(buff_extension, buff_template_name)
	if not buff_extension then
		return 0
	end

	local buffs_by_index = buff_extension._buffs_by_index

	if not buffs_by_index then
		return 0
	end

	local timer = 0

	for _, buff in pairs(buffs_by_index) do
		if buff then
			local template = buff:template()

			if template and template.name == buff_template_name then
				local remaining = buff:duration_progress() or 1
				local duration = buff:duration() or 15

				timer = math.max(timer, duration * remaining)
			end
		end
	end

	return timer
end

local function empty_timer_result()
	return {
		visible = false,
		text = "",
		phase = "none",
		has_matched_pocketable = false,
		has_active_buff = false,
		has_cooldown = false,
		is_ready = false,
		profile_id = nil,
	}
end

function StimmCountdownCore.compute_pocketable_stimm_timer_state(player_unit, settings, profiles)
	local result = empty_timer_result()

	if not player_unit then
		return result
	end

	if type(profiles) ~= "table" then
		return result
	end

	local player = Managers.player and Managers.player:local_player(1)

	if not player or not player:unit_is_alive() then
		return result
	end

	if player.player_unit ~= player_unit then
		return result
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension then
		return result
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension then
		return result
	end

	local equipped_abilities = ability_extension:equipped_abilities()
	local player_archetype = player:archetype_name()
	local matched_profile = nil

	for _, profile in ipairs(profiles) do
		if type(profile) == "table" and type(profile.archetype_name) == "string" and type(profile.ability_group) == "string" and type(profile.active_buff_template) == "string" then
			if player_archetype == profile.archetype_name then
				local ability_type = type(profile.ability_type) == "string" and profile.ability_type or "pocketable_ability"
				local pocketable_ability = equipped_abilities and equipped_abilities[ability_type]
				local group_ok = pocketable_ability and pocketable_ability.ability_group == profile.ability_group

				if group_ok then
					matched_profile = profile

					break
				end
			end
		end
	end

	if not matched_profile then
		return result
	end

	result.has_matched_pocketable = true
	result.profile_id = matched_profile.id or matched_profile.ability_group

	local ability_type = type(matched_profile.ability_type) == "string" and matched_profile.ability_type or "pocketable_ability"
	local raw_remaining_cooldown = ability_extension:remaining_ability_cooldown(ability_type)
	local remaining_cooldown = is_finite_cooldown_seconds_for_ui(raw_remaining_cooldown) and raw_remaining_cooldown or nil
	local has_cooldown = remaining_cooldown ~= nil

	result.has_cooldown = has_cooldown

	local remaining_buff_time = StimmCountdownCore.get_buff_remaining_time(buff_extension, matched_profile.active_buff_template)
	local has_active_buff = remaining_buff_time and remaining_buff_time >= 0.05

	result.has_active_buff = not not has_active_buff

	local is_ready = result.has_matched_pocketable and not has_active_buff and not has_cooldown

	result.is_ready = not not is_ready

	local show_decimals = not settings or settings.show_decimals ~= false
	local show_active = not settings or settings.show_active ~= false
	local show_cooldown = not settings or settings.show_cooldown ~= false

	if show_active and has_active_buff then
		if show_decimals then
			result.text = string.format("%.1f", remaining_buff_time)
		else
			result.text = string.format("%.0f", math.ceil(remaining_buff_time))
		end

		result.visible = true
		result.phase = "active"
	elseif is_ready then
		result.visible = false
		result.phase = "none"
	elseif show_cooldown and has_cooldown and remaining_cooldown then
		if show_decimals then
			result.text = string.format("%.1f", remaining_cooldown)
		else
			result.text = string.format("%.0f", math.ceil(remaining_cooldown))
		end

		result.visible = true
		result.phase = "cooldown"
	end

	return result
end

function StimmCountdownCore.compute_timer_display_for_consuming_mods(player_unit, settings, pocketable_profiles, buff_entries)
	local player = Managers.player and Managers.player:local_player(1)

	if not player_unit or not player or not player:unit_is_alive() or player.player_unit ~= player_unit then
		return empty_timer_result()
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension then
		return empty_timer_result()
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension then
		return empty_timer_result()
	end

	local show_decimals = not settings or settings.show_decimals ~= false
	local show_active = not settings or settings.show_active ~= false
	local show_cooldown = not settings or settings.show_cooldown ~= false
	local player_archetype = player:archetype_name()

	local function format_seconds(seconds)
		if show_decimals then
			return string.format("%.1f", seconds)
		end

		return string.format("%.0f", math.ceil(seconds))
	end

	if player_archetype == "broker" and show_cooldown then
		local raw_cd = ability_extension:remaining_ability_cooldown("pocketable_ability")
		local remaining_cooldown = is_finite_cooldown_seconds_for_ui(raw_cd) and raw_cd or nil

		if remaining_cooldown then
			local r = empty_timer_result()

			r.has_matched_pocketable = true
			r.profile_id = "broker_pocketable_cooldown"
			r.has_cooldown = true
			r.has_active_buff = false
			r.is_ready = false
			r.text = format_seconds(remaining_cooldown)
			r.visible = true
			r.phase = "cooldown"

			return r
		end
	end

	local pocket_result = StimmCountdownCore.compute_pocketable_stimm_timer_state(player_unit, settings, pocketable_profiles)

	if pocket_result.visible and pocket_result.text ~= "" then
		return pocket_result
	end

	if show_active and type(buff_entries) == "table" then
		local best_time = 0
		local best_template = nil

		for _, entry in ipairs(buff_entries) do
			if type(entry) == "table" and type(entry.template) == "string" then
				local arch_ok = not entry.archetype_name or entry.archetype_name == player_archetype

				if arch_ok then
					local t = StimmCountdownCore.get_buff_remaining_time(buff_extension, entry.template)

					if t >= 0.05 and t > best_time then
						best_time = t
						best_template = entry.template
					end
				end
			end
		end

		if best_time > 0 and best_template then
			local r = empty_timer_result()

			r.has_matched_pocketable = true
			r.profile_id = best_template
			r.has_active_buff = true
			r.has_cooldown = false
			r.is_ready = false
			r.text = format_seconds(best_time)
			r.visible = true
			r.phase = "active"

			return r
		end
	end

	return empty_timer_result()
end

return StimmCountdownCore
