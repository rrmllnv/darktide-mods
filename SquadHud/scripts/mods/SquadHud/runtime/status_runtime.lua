local mod = get_mod("SquadHud")

local M = {}

local FLASH_INTERVAL = 1
local CRITICAL_HEALTH_THRESHOLD = 0.1

function M.resolve(player, extensions, status, health_fraction, revive_state, rescue_timer_status)
	if revive_state and revive_state.in_progress then
		if status ~= "down" then
			return {
				alternate_with_name = false,
				id = "rescuing",
				is_critical = false,
				priority = 400,
				text_key = "squadhud_status_rescuing",
			}
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
		local text_key = show_timer and "squadhud_status_rescue_available_in" or "squadhud_status_rescue_available"
		local text = mod:localize(text_key)

		if show_timer then
			text = text .. " " .. tostring(math.round_with_precision(time_left))
		end

		return {
			alternate_with_name = true,
			id = "rescue_available",
			is_critical = false,
			priority = 350,
			text = text,
		}
	end

	if status == "down" then
		return {
			alternate_with_name = true,
			id = "unconscious",
			is_critical = true,
			priority = 300,
			text_key = "squadhud_status_down",
		}
	end

	if status == "disabled" then
		return nil
	end

	if player and extensions and health_fraction < CRITICAL_HEALTH_THRESHOLD then
		return {
			alternate_with_name = true,
			id = "critical_health",
			is_critical = true,
			priority = 100,
			text_key = "squadhud_status_critical_health",
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
