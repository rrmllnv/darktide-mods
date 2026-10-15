local M = {}

local COMBAT_ABILITY_TYPE = "combat_ability"

-- Reused per player (weak keys, so a player who leaves is dropped)
local state_by_player = setmetatable({}, { __mode = "k" })

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

-- A teammate's buff extension on a client (PlayerHuskBuffExtension) holds no buffs: buffs() is always empty and
-- current_stacks errors, so the tracking buffs can only be read from a full buff extension (the local player, and bots
-- in solo play). Vanilla's team panel shows no teammate ability durations either.
local function readable_buff_extension(player_unit)
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension or buff_extension.__class_name == "PlayerHuskBuffExtension" then
		return nil
	end

	return buff_extension
end

local function has_tracking_buff(buff_extension, tracking)
	if type(tracking) == "table" then
		for i = 1, #tracking do
			if buff_extension:current_stacks(tracking[i]) > 0 then
				return true
			end
		end

		return false
	end

	return buff_extension:current_stacks(tracking) > 0
end

-- The vanilla progress towards the next charge: 1 while every charge is ready, so a recharging extra charge still
-- counts as cooldown. Nil for an unknown usage cost type and NaN for an empty resource pool read as 0.
local function vanilla_regen_progress(ability_extension)
	local progress = ability_extension:get_ability_resource_regen_progress(COMBAT_ABILITY_TYPE)

	if type(progress) ~= "number" or progress ~= progress then
		return 0
	end

	return progress
end

-- On a teammate (husk), get_ability_resource_regen_progress divides by the template cost per charge, which ignores
-- cost modifiers. max_ability_resource, the resource and the charge count are synced with them, so the cost per
-- charge is taken from those. On the local player both give the same value.
local function regen_progress(ability_extension, ability_settings)
	-- charges-only abilities and abilities without their own charge-based pool keep the vanilla value
	if ability_settings.only_uses_charges or ability_settings.resource_pool_override or (ability_settings.usage_cost_type or "charges") ~= "charges" then
		return vanilla_regen_progress(ability_extension)
	end

	local max_charges = ability_extension:max_ability_charges(COMBAT_ABILITY_TYPE)
	local max_resource = ability_extension:max_ability_resource(COMBAT_ABILITY_TYPE)

	-- values that aren't synced yet keep the vanilla value
	if max_charges <= 0 or max_resource <= 0 then
		return vanilla_regen_progress(ability_extension)
	end

	local remaining_charges = ability_extension:remaining_ability_charges(COMBAT_ABILITY_TYPE)

	if remaining_charges >= max_charges then
		return 1
	end

	local cost_per_charge = max_resource / max_charges
	local charge_resource = ability_extension:remaining_ability_resource(COMBAT_ABILITY_TYPE) - remaining_charges * cost_per_charge

	return math.clamp(charge_resource / cost_per_charge, 0, 1)
end

-- Mirrors the 1.13.2 HudElementPlayerAbility.update resource logic, without can_use_ability (it errors on husks), so a
-- recharging extra charge keeps the ability on cooldown as before 1.13.0. The pause settings are read from the
-- ability itself, because ability_pause_cooldown_settings errors on husks too, and their buffs only where readable.
local function cooldown_state(player_unit, ability_extension, ability_settings)
	local max_ability_resource = ability_extension:max_ability_resource(COMBAT_ABILITY_TYPE)
	local max_ability_charges = ability_extension:max_ability_charges(COMBAT_ABILITY_TYPE)
	local progress

	if ability_extension:is_ability_resource_regen_paused(COMBAT_ABILITY_TYPE) then
		progress = 0
	elseif max_ability_resource > 0 then
		progress = regen_progress(ability_extension, ability_settings)
	else
		progress = max_ability_charges > 1 and 1 or 0
	end

	local in_process_of_going_on_cooldown = false
	local force_on_cooldown = false
	local pause_settings = ability_settings.pause_cooldown_settings
	local buff_extension = type(pause_settings) == "table" and readable_buff_extension(player_unit)

	if buff_extension then
		local duration_tracking_buff = pause_settings.duration_tracking_buff

		if type(duration_tracking_buff) == "table" then
			for i = 1, #duration_tracking_buff do
				local buff_name = duration_tracking_buff[i]

				if buff_extension:current_stacks(buff_name) > 0 then
					progress = buff_extension:buff_duration_progress(buff_name)
					in_process_of_going_on_cooldown = progress > 0

					break
				end
			end
		elseif duration_tracking_buff and buff_extension:current_stacks(duration_tracking_buff) > 0 then
			progress = buff_extension:buff_duration_progress(duration_tracking_buff)
			in_process_of_going_on_cooldown = progress > 0
		end

		local on_cooldown_tracking_buff = pause_settings.on_cooldown_tracking_buff

		if on_cooldown_tracking_buff then
			force_on_cooldown = has_tracking_buff(buff_extension, on_cooldown_tracking_buff)
		end
	end

	local on_cooldown = progress ~= 1 and not in_process_of_going_on_cooldown or force_on_cooldown

	return progress, on_cooldown
end

local function is_effect_active(player_unit)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		return false
	end

	local combat_ability_component = unit_data_extension:read_component("combat_ability")

	return combat_ability_component ~= nil and combat_ability_component.active == true
end

-- The returned table is reused for the player when one is given, so read it before the next call
function M.combat_ability_state(player_unit, player)
	local ability_extension, ability_settings = equipped_combat_ability(player_unit)

	if not ability_extension or not ability_settings then
		return nil
	end

	local icon = ability_settings.hud_icon

	if type(icon) == "string" and icon ~= "" then
		local progress, on_cooldown = cooldown_state(player_unit, ability_extension, ability_settings)
		local effect_active = is_effect_active(player_unit)
		local state = on_cooldown and "cooldown" or effect_active and "active" or "ready"

		local result = player and state_by_player[player]

		if not result then
			result = {}

			if type(player) == "table" then
				state_by_player[player] = result
			end
		end

		result.icon = icon
		result.progress = progress
		result.state = state
		result.is_active_or_on_cooldown = on_cooldown or effect_active

		return result
	end

	return nil
end

return M
