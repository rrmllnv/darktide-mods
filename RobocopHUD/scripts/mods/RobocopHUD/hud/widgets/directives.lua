local M = {}

local DIRECTIVES = {
	combat = "SERVE THE PUBLIC TRUST  |  PROTECT THE INNOCENT  |  UPHOLD THE LAW",
	engage = "DIRECTIVE: NEUTRALIZE HOSTILE THREATS",
	scan = "DIRECTIVE: ACQUIRE TARGET",
	track = "DIRECTIVE: TRACK TARGET",
	lock = "DIRECTIVE: LOCK CONFIRMED",
	idle = "DIRECTIVE: PATROL",
}

M.update = function(widget, lock_state, theme, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	local stage = lock_state and lock_state.stage or "IDLE"
	local text = DIRECTIVES.combat

	if stage == "SCAN" then
		text = DIRECTIVES.scan
	elseif stage == "TRACK" then
		text = DIRECTIVES.track
	elseif stage == "LOCK" then
		text = DIRECTIVES.lock
	elseif stage == "IDLE" or stage == "OFF" then
		text = DIRECTIVES.idle
	end

	widget.content.text = text

	local c = widget.style.text.text_color
	local a = math.floor(255 * (opacity or 1) + 0.5)
	local tc = theme and theme.text

	if tc then
		c[1] = a
		c[2] = tc[2]
		c[3] = tc[3]
		c[4] = tc[4]
	else
		c[1] = a
	end

	widget.content.visible = true
	widget.dirty = true
end

return M

