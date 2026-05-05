local M = {}

local function _apply_color(style, theme, opacity, alpha_mul)
	local a = math.floor(255 * (opacity or 1) * (alpha_mul or 1) + 0.5)
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

M.update = function(widget, scanner_state, theme, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	local visible = scanner_state and scanner_state.visible == true
	widget.content.visible = visible

	if not visible then
		widget.dirty = true
		return
	end

	local st = widget.style

	if st.radar then
		_apply_color(st.radar, theme, opacity, 0.30)

		local a = scanner_state and scanner_state.compass_angle
		if type(a) ~= "number" then
			a = 0
		end

		-- Rotate compass background by camera yaw so that directions match the world.
		st.radar.angle = a
	end

	if st.radar_fx then
		_apply_color(st.radar_fx, theme, opacity, 0.22)
	end

	if st.player_dot and st.player_dot.color then
		st.player_dot.color[1] = math.floor(255 * (opacity or 1) + 0.5)
		st.player_dot.color[2] = 255
		st.player_dot.color[3] = 255
		st.player_dot.color[4] = 255
	end

	local blips = scanner_state and scanner_state.blips or nil
	local t = scanner_state and scanner_state.t or nil
	local now = (type(t) == "number") and t or nil
	local blip_count = scanner_state and scanner_state.blip_count or 0

	local radius = nil
	if widget.content and type(widget.content.radar_radius) == "number" then
		radius = widget.content.radar_radius
	elseif st.radar and st.radar.size and type(st.radar.size[1]) == "number" then
		radius = st.radar.size[1] * 0.5
	end
	if type(radius) ~= "number" then
		radius = 120
	end

	-- Update fixed slots
	for i = 1, (widget.content.max_blips or 24) do
		local style_id = "blip_" .. string.format("%02d", i)
		local bs = st[style_id]

		if bs then
			local e = blips and blips[i]
			if i <= blip_count and e and type(e.angle) == "number" and type(e.radius01) == "number" then
				local a = e.angle
				local r = math.clamp(e.radius01, 0, 1) * radius
				-- Radar mapping: angle=0 (forward) should be UP.
				-- Note: UI offset Y grows DOWN, so forward must be negative Y.
				bs.offset[1] = math.sin(a) * r
				bs.offset[2] = -math.cos(a) * r

				-- fade-out based on end_t if available
				local alpha_mul = 1
				if now and type(e.end_t) == "number" and type(e.start_t) == "number" and e.end_t > e.start_t then
					alpha_mul = math.clamp((e.end_t - now) / (e.end_t - e.start_t), 0, 1)
				end

				_apply_color(bs, theme, opacity, alpha_mul)
			else
				bs.color[1] = 0
			end
		end
	end

	widget.dirty = true
end

return M

