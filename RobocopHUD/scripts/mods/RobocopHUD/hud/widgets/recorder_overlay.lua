local M = {}

local function _format_time_seconds(t)
	if type(t) ~= "number" or t ~= t or t < 0 then
		return "00:00:00"
	end

	local s = math.floor(t)
	local h = math.floor(s / 3600)
	local m = math.floor((s % 3600) / 60)
	local ss = s % 60

	return string.format("%02d:%02d:%02d", h, m, ss)
end

M.update = function(widget, t, theme, opacity, targeting_mode)
	if not widget or not widget.content or not widget.style then
		return
	end

	local mode_label = (targeting_mode == "SCAN") and "AUTO SCAN" or "AUTO TARGET"
	widget.content.text = string.format("REC %s  |  %s", _format_time_seconds(t), mode_label)

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

