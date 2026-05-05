local M = {}

local THREAT_BASE_SCORE = {
	monster = 4000,
	special = 1200,
	elite = 1200,
	
	trash = 0,
}

-- Targeting the player adds a small priority boost (~15m equivalent at distance_weight=10).
-- Must not let a farther enemy of the same type outrank a closer one.
local TARGETING_PLAYER_BONUS = 150

local function _base(threat_kind)
	return THREAT_BASE_SCORE[threat_kind] or 0
end

local function _safe_number(v, fallback)
	if type(v) == "number" and v == v then
		return v
	end

	return fallback
end

M.rank = function(state, candidates, count, current_target_unit, settings)
	state = state or {}
	state.top_threats = state.top_threats or {}
	state.targeting_me = state.targeting_me or {}

	local sticky_bonus = _safe_number(settings and settings.sticky_bonus, 30)
	local distance_weight = _safe_number(settings and settings.distance_weight, 10)

	local best_unit = nil
	local best_score = -math.huge

	-- top_threats: all enemies targeting the player (sorted by score descending), up to top_n.
	local top = state.top_threats
	local top_n = 20

	for i = 1, top_n do
		local e = top[i]

		if e then
			e.unit = nil
			e.score = nil
			e.threat_kind = nil
			e.distance = nil
			e.breed = nil
			e.targeting_player = nil
		else
			top[i] = {}
		end
	end

	local targeting_me_count = 0

	for i = 1, count do
		local c = candidates[i]
		local unit = c and c.unit

		if unit and Unit.alive(unit) then
			local dist = _safe_number(c.distance, 9999)
			local threat_kind = c.threat_kind
			local targeting_player = c.targeting_player == true
			local score = _base(threat_kind)

			-- Closer enemies rank higher.
			score = score + math.max(0, 1000 - dist) * distance_weight

			-- Enemies targeting the player have very high priority.
			if targeting_player then
				score = score + TARGETING_PLAYER_BONUS
				targeting_me_count = targeting_me_count + 1
			end

			if current_target_unit and unit == current_target_unit then
				score = score + sticky_bonus
			end

			if score > best_score then
				best_score = score
				best_unit = unit
			end

			-- Build top list from enemies targeting the player only.
			-- If no enemies target the player, fall back to all candidates.
			if targeting_player then
				for slot = 1, top_n do
					if top[slot].unit == nil or score > (top[slot].score or -math.huge) then
						for j = top_n, slot + 1, -1 do
							local prev = top[j - 1]
							local cur = top[j]
							cur.unit = prev.unit
							cur.score = prev.score
							cur.threat_kind = prev.threat_kind
							cur.distance = prev.distance
							cur.breed = prev.breed
							cur.targeting_player = prev.targeting_player
						end

						top[slot].unit = unit
						top[slot].score = score
						top[slot].threat_kind = threat_kind
						top[slot].distance = dist
						top[slot].breed = c.breed
						top[slot].targeting_player = targeting_player

						break
					end
				end
			end
		end
	end

	-- If no enemies are targeting the player, fall back top list to all candidates by score.
	if targeting_me_count == 0 then
		for i = 1, count do
			local c = candidates[i]
			local unit = c and c.unit

			if unit and Unit.alive(unit) then
				local dist = _safe_number(c.distance, 9999)
				local threat_kind = c.threat_kind
				local score = _base(threat_kind) + math.max(0, 1000 - dist) * distance_weight

				if current_target_unit and unit == current_target_unit then
					score = score + sticky_bonus
				end

				for slot = 1, top_n do
					if top[slot].unit == nil or score > (top[slot].score or -math.huge) then
						for j = top_n, slot + 1, -1 do
							local prev = top[j - 1]
							local cur = top[j]
							cur.unit = prev.unit
							cur.score = prev.score
							cur.threat_kind = prev.threat_kind
							cur.distance = prev.distance
							cur.breed = prev.breed
							cur.targeting_player = prev.targeting_player
						end

						top[slot].unit = unit
						top[slot].score = score
						top[slot].threat_kind = threat_kind
						top[slot].distance = dist
						top[slot].breed = c.breed
						top[slot].targeting_player = false

						break
					end
				end
			end
		end
	end

	state.best_unit = best_unit
	state.best_score = best_score
	state.targeting_me_count = targeting_me_count

	return best_unit, top, state
end

return M
