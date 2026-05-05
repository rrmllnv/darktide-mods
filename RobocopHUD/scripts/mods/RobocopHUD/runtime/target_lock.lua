local M = {}

local function _safe_number(v, fallback)
	if type(v) == "number" and v == v then
		return v
	end

	return fallback
end

local function _enabled(settings)
	return settings.targeting_enabled ~= false and settings.targeting_enabled ~= 0
end

local function _is_unit_alive(unit)
	return unit and HEALTH_ALIVE[unit] and Unit.alive(unit)
end

M.update = function(state, t, best_unit, settings)
	state = state or {}
	settings = settings or {}

	if not _enabled(settings) then
		state.unit = nil
		state.stage = "OFF"
		state.stage_t = nil
		state.last_seen_t = nil
		return state
	end

	local scan_s = _safe_number(settings.lock_scan_seconds, 0.20)
	local track_s = _safe_number(settings.lock_track_seconds, 0.25)
	local hold_s = _safe_number(settings.target_hold_seconds, 1.0)

	if scan_s < 0 then
		scan_s = 0
	end
	if track_s < 0 then
		track_s = 0
	end
	if hold_s < 0 then
		hold_s = 0
	end

	local cur = state.unit
	local cur_alive = _is_unit_alive(cur)

	-- update last seen based on best_unit presence
	if best_unit and _is_unit_alive(best_unit) then
		state.last_seen_t = t
	end

	-- Switch target whenever scoring picks a different best_unit.
	-- Hysteresis is handled in ThreatScoring via sticky_bonus so no extra guard needed here.
	if best_unit and best_unit ~= cur then
		state.unit = best_unit
		state.stage = "SCAN"
		state.stage_t = t
		state.last_seen_t = t
		return state
	end

	-- keep current if alive
	if cur and cur_alive then
		state.last_seen_t = t

		local stage = state.stage or "SCAN"
		local stage_t = state.stage_t or t
		local elapsed = (t or 0) - (stage_t or 0)

		if stage == "SCAN" and elapsed >= scan_s then
			state.stage = "TRACK"
			state.stage_t = t
		elseif stage == "TRACK" and elapsed >= track_s then
			state.stage = "LOCK"
			state.stage_t = t
		elseif stage == "LOCK" then
			-- stay
		else
			state.stage = stage
			state.stage_t = stage_t
		end

		-- loss handling: if nothing seen for hold_s, clear
		local last_seen = state.last_seen_t
		if type(last_seen) == "number" and (t - last_seen) > hold_s then
			state.unit = nil
			state.stage = "IDLE"
			state.stage_t = t
		end
	else
		state.unit = nil
		state.stage = "IDLE"
		state.stage_t = t
	end

	return state
end

return M

