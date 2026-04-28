local mod = get_mod("SquadHud")

local M = {}

local FLASH_INTERVAL = 1
local CRITICAL_HEALTH_THRESHOLD = 0.1
local STATUS_TEXT_KEYS = {
	consumed = "squadhud_status_consumed",
	disabled = "squadhud_status_disabled",
	grabbed = "squadhud_status_grabbed",
	ledge_hanging = "squadhud_status_ledge_hanging",
	mutant_charged = "squadhud_status_mutant_charged",
	netted = "squadhud_status_netted",
	pounced = "squadhud_status_pounced",
	vortex_grabbed = "squadhud_status_vortex_grabbed",
	warp_grabbed = "squadhud_status_warp_grabbed",
}

local function status_enabled(status_id)
	local value = mod:get("squadhud_show_status_" .. status_id)

	return value ~= false and value ~= 0
end

function M.resolve(player, extensions, status, health_fraction, revive_state, rescue_timer_status)
	if revive_state and revive_state.in_progress then
		if status ~= "down" then
			if not status_enabled("rescuing") then
				return nil
			end

			return {
				alternate_with_name = false,
				id = "rescuing",
				is_critical = false,
				priority = 400,
				text_key = "squadhud_status_rescuing",
			}
		end

		if not status_enabled("reviving") then
			return nil
		end

		return {
			alternate_with_name = false,
			id = "reviving",
			is_critical = false,
			priority = 400,
			text_key = "squadhud_status_reviving",
		}
	end

	if status == "dead" then
		local time_left = rescue_timer_status and rescue_timer_status.time_left
		local show_timer = time_left and time_left > 0
		local is_rescue_available = rescue_timer_status and rescue_timer_status.available == true
		local text_key = show_timer and "squadhud_status_rescue_available_in" or is_rescue_available and "squadhud_status_rescue_available" or "squadhud_status_dead"
		local text = mod:localize(text_key)

		if show_timer then
			text = text .. " " .. tostring(math.round_with_precision(time_left))
		end

		local status_id = (show_timer or is_rescue_available) and "rescue_available" or "dead"

		if not status_enabled(status_id) then
			return nil
		end

		return {
			alternate_with_name = true,
			id = status_id,
			is_critical = not show_timer and not is_rescue_available,
			priority = 350,
			text = text,
		}
	end

	if status == "hogtied" then
		if not status_enabled("rescue_available") then
			return nil
		end

		return {
			alternate_with_name = true,
			id = "rescue_available",
			is_critical = false,
			priority = 350,
			text_key = "squadhud_status_rescue_available",
		}
	end

	if status == "down" then
		if not status_enabled("unconscious") then
			return nil
		end

		return {
			alternate_with_name = true,
			id = "unconscious",
			is_critical = true,
			priority = 300,
			text_key = "squadhud_status_down",
		}
	end

	local status_text_key = STATUS_TEXT_KEYS[status]

	if status_text_key then
		if not status_enabled(status) then
			return nil
		end

		return {
			alternate_with_name = true,
			id = status,
			is_critical = true,
			priority = 300,
			text_key = status_text_key,
		}
	end

	if player and extensions and health_fraction < CRITICAL_HEALTH_THRESHOLD then
		if not status_enabled("critical_health") then
			return nil
		end

		return {
			alternate_with_name = true,
			id = "critical_health",
			is_critical = true,
			priority = 100,
			text_key = "squadhud_status_critical_health",
		}
	end

	if status == "luggable" then
		if not status_enabled("luggable") then
			return nil
		end

		return {
			alternate_with_name = true,
			id = "luggable",
			is_critical = false,
			priority = 50,
			text_key = "squadhud_status_luggable",
		}
	end

	return nil
end

function M.display_name(state_by_player, player_key, base_name, operational_status, t)
	if not operational_status then
		if state_by_player then
			state_by_player[player_key] = nil
		end

		return base_name, false
	end

	if operational_status.alternate_with_name ~= true then
		return operational_status.text or mod:localize(operational_status.text_key), true
	end

	local now = type(t) == "number" and t or 0
	local state = state_by_player[player_key]

	if not state or state.id ~= operational_status.id then
		state = {
			id = operational_status.id,
			next_switch_t = now + FLASH_INTERVAL,
			show_status = false,
		}
		state_by_player[player_key] = state
	elseif now >= state.next_switch_t then
		local elapsed_switches = math.floor((now - state.next_switch_t) / FLASH_INTERVAL) + 1

		if elapsed_switches % 2 == 1 then
			state.show_status = not state.show_status
		end

		state.next_switch_t = state.next_switch_t + elapsed_switches * FLASH_INTERVAL
	end

	if state.show_status then
		return operational_status.text or mod:localize(operational_status.text_key), true
	end

	return base_name, false
end

return M
