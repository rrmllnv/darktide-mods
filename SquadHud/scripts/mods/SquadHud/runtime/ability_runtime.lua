local M = {}

local COMBAT_ABILITY_TYPE = "combat_ability"

local function equipped_combat_ability(player_unit)
	if not player_unit or not Unit.alive(player_unit) then
		return nil
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(COMBAT_ABILITY_TYPE) then
		return nil
	end

	local equipped_abilities = ability_extension:equipped_abilities()
	local ability_settings = equipped_abilities and equipped_abilities[COMBAT_ABILITY_TYPE]

	if type(ability_settings) == "table" then
		return ability_extension, ability_settings
	end

	return nil
end

local function duration_buff_progress(buff_extension, buff_name)
	if not buff_extension or type(buff_name) ~= "string" or buff_name == "" then
		return nil
	end

	if (buff_extension:current_stacks(buff_name) or 0) <= 0 then
		return nil
	end

	return buff_extension:buff_duration_progress(buff_name)
end

local function duration_buff_is_active(buff_extension, tracking)
	if not buff_extension or not tracking then
		return false
	end

	if type(tracking) == "table" then
		for i = 1, #tracking do
			local name = tracking[i]

			if type(name) == "string" and (buff_extension:current_stacks(name) or 0) > 0 then
				local progress = buff_extension:buff_duration_progress(name) or 0

				if progress > 0 then
					return true
				end
			end
		end

		return false
	end

	if type(tracking) ~= "string" or (buff_extension:current_stacks(tracking) or 0) <= 0 then
		return false
	end

	return (buff_extension:buff_duration_progress(tracking) or 0) > 0
end

local function safe_ability_pause_cooldown_settings(ability_extension)
	if not ability_extension or type(ability_extension.ability_pause_cooldown_settings) ~= "function" then
		return nil
	end

	local ok, pause_settings = pcall(function()
		return ability_extension:ability_pause_cooldown_settings(COMBAT_ABILITY_TYPE)
	end)

	if ok and type(pause_settings) == "table" then
		return pause_settings
	end

	return nil
end

local function cooldown_progress(player_unit, ability_extension)
	local max_cooldown = ability_extension:max_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local progress

	if max_cooldown > 0 then
		progress = 1 - math.min(1, math.max(0, remaining_cooldown / max_cooldown))

		if progress == 0 then
			progress = 1
		end
	else
		progress = 0
	end

	local pause_settings = safe_ability_pause_cooldown_settings(ability_extension)

	if type(pause_settings) ~= "table" then
		return progress
	end

	local tracking = pause_settings.duration_tracking_buff

	if not tracking then
		return progress
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension then
		return progress
	end

	if type(tracking) == "table" then
		for i = 1, #tracking do
			local tracked_progress = duration_buff_progress(buff_extension, tracking[i])

			if tracked_progress then
				return tracked_progress
			end
		end
	else
		local tracked_progress = duration_buff_progress(buff_extension, tracking)

		if tracked_progress then
			return tracked_progress
		end
	end

	return progress
end

local function is_on_cooldown(player_unit, ability_extension)
	local max_cooldown = ability_extension:max_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local progress = 1

	if max_cooldown > 0 then
		progress = 1 - math.min(1, math.max(0, remaining_cooldown / max_cooldown))

		if progress == 0 then
			progress = 1
		end
	end

	local in_process_of_going_on_cooldown = false
	local force_on_cooldown = false

	local pause_settings = safe_ability_pause_cooldown_settings(ability_extension)

	if type(pause_settings) == "table" then
		local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

		if duration_buff_is_active(buff_extension, pause_settings.duration_tracking_buff) then
			in_process_of_going_on_cooldown = true
		end

		if duration_buff_is_active(buff_extension, pause_settings.on_cooldown_tracking_buff) then
			force_on_cooldown = true
		end
	end

	return (progress ~= 1 and not in_process_of_going_on_cooldown) or force_on_cooldown
end

local function is_effect_active(player_unit)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return false
	end

	local combat_ability_component = unit_data_extension:read_component("combat_ability")

	return combat_ability_component ~= nil and combat_ability_component.active == true
end

function M.combat_ability_state(player_unit)
	local ability_extension, ability_settings = equipped_combat_ability(player_unit)

	if not ability_extension or not ability_settings then
		return nil
	end

	local icon = ability_settings.hud_icon

	if type(icon) == "string" and icon ~= "" then
		local on_cooldown = is_on_cooldown(player_unit, ability_extension)
		local effect_active = is_effect_active(player_unit)
		local state = on_cooldown and "cooldown" or effect_active and "active" or "ready"

		return {
			icon = icon,
			progress = cooldown_progress(player_unit, ability_extension),
			state = state,
			is_active_or_on_cooldown = on_cooldown or effect_active,
		}
	end

	return nil
end

return M
