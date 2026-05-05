local M = {}

local function _safe_number(v, fallback)
	if type(v) == "number" and v == v then
		return v
	end

	return fallback
end

M.update = function(state, t, context, settings)
	state = state or {}
	settings = settings or {}
	state.queue = state.queue or {}

	local cooldown = _safe_number(settings.warning_cooldown, 2.0)
	if cooldown < 0 then
		cooldown = 0
	end

	state.last_warning_t = state.last_warning_t or -1000

	-- v1: placeholder. We keep the pipeline stable; real warnings will be added later.
	if context and context.target_lost == true and (t - state.last_warning_t) >= cooldown then
		state.last_warning_t = t
		state.queue[1] = {
			id = "TARGET_LOST",
			t = t,
		}
	end

	return state
end

return M

