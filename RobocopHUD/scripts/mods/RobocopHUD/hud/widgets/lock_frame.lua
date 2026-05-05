local M = {}

local function _apply_color(style, theme, opacity)
	local a = math.floor(255 * (opacity or 1) + 0.5)
	local accent = theme and theme.accent

	if not accent then
		style.color[1] = a
		return
	end

	style.color[1] = math.min(a, accent[1] or a)
	style.color[2] = accent[2]
	style.color[3] = accent[3]
	style.color[4] = accent[4]
end

-- Visibility is fully managed by _update_lock_frame_offset in hud_element_robocop_hud.lua.
-- This function only applies colors/text so they are ready when the widget becomes visible.
M.update = function(widget, lock_state, theme, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	widget.content.text = ""

	_apply_color(widget.style.frame_top, theme, opacity)
	_apply_color(widget.style.frame_bottom, theme, opacity)
	_apply_color(widget.style.frame_left, theme, opacity)
	_apply_color(widget.style.frame_right, theme, opacity)
	_apply_color(widget.style.line_top, theme, opacity)
	_apply_color(widget.style.line_bottom, theme, opacity)
	_apply_color(widget.style.line_left, theme, opacity)
	_apply_color(widget.style.line_right, theme, opacity)

	local text_color = widget.style.text.text_color
	local a = math.floor(255 * (opacity or 1) + 0.5)
	local tc = theme and theme.text

	if tc then
		text_color[1] = a
		text_color[2] = tc[2]
		text_color[3] = tc[3]
		text_color[4] = tc[4]
	else
		text_color[1] = a
	end

	widget.dirty = true
end

return M

