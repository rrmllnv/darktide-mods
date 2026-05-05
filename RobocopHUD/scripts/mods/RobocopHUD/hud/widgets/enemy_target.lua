local M = {}

local MAX_DEBUFF_ROWS = 16

local function color_text(text, color)
	if text == "" or type(color) ~= "table" then
		return text
	end

	return "{#color(" .. tostring(color[2] or 255) .. "," .. tostring(color[3] or 255) .. "," .. tostring(color[4] or 255) .. ")}" .. text .. "{#reset()}"
end

local function _apply_text_color(style, color, alpha)
	if not style or not style.text_color then
		return
	end

	style.text_color[1] = alpha
	style.text_color[2] = color[2]
	style.text_color[3] = color[3]
	style.text_color[4] = color[4]
end

local function _apply_rect_color(style, color, alpha, alpha_scale)
	if not style or not style.color then
		return
	end

	local scaled = math.floor(alpha * (alpha_scale or 1) + 0.5)
	style.color[1] = math.min(255, math.max(0, scaled))
	style.color[2] = color[2]
	style.color[3] = color[3]
	style.color[4] = color[4]
end

local function _reset_widget(widget)
	if not widget or not widget.content or not widget.style then
		return
	end

	widget.content.visible = false
	widget.content.name_text = ""
	widget.content.health_text = ""
	widget.content.type_text = ""

	local health_fill_style = widget.style.health_bar_fill
	local default_size = health_fill_style and health_fill_style.default_size

	if health_fill_style and default_size then
		health_fill_style.size[1] = default_size[1]
	end

	for i = 1, MAX_DEBUFF_ROWS do
		widget.content["debuff_icon_" .. i] = nil
		widget.content["debuff_text_" .. i] = ""
		widget.content["debuff_text_" .. i .. "_outline_text"] = ""
	end

	widget.alpha_multiplier = 0
	widget.dirty = true
end

M.update = function(widget, data, theme, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	local active = data and data.active == true

	if not active then
		_reset_widget(widget)
		return
	end

	local text_color = theme and theme.text or { 255, 120, 255, 160 }
	local accent_color = theme and theme.accent or { 255, 60, 255, 120 }
	local alpha = math.floor(255 * (opacity or 1) + 0.5)

	widget.content.visible = true
	widget.content.name_text = data.name or ""
	widget.content.health_text = data.health_percent_text or ""
	widget.content.type_text = data.type_text or ""

	local name_style = widget.style.name_text
	local health_text_style = widget.style.health_text
	local type_text_style = widget.style.type_text
	local debuff_label_style = widget.style.debuff_text_1
	local debuff_outline_style = widget.style.debuff_text_1_outline
	local frame_style = widget.style.panel_frame
	local background_style = widget.style.panel_background
	local health_bg_style = widget.style.health_bar_background
	local health_fill_style = widget.style.health_bar_fill

	_apply_text_color(name_style, text_color, alpha)
	_apply_text_color(health_text_style, accent_color, alpha)
	_apply_text_color(type_text_style, text_color, math.floor(alpha * 0.85 + 0.5))
	_apply_rect_color(frame_style, accent_color, alpha, 0.85)
	_apply_rect_color(background_style, { 255, 0, 0, 0 }, alpha, 0.45)
	_apply_rect_color(health_bg_style, text_color, alpha, 0.20)
	_apply_rect_color(health_fill_style, accent_color, alpha, 0.95)

	if health_fill_style and health_fill_style.default_size then
		local health_fraction = math.max(0, math.min(1, data.health_fraction or 0))
		health_fill_style.size[1] = math.max(2, math.floor(health_fill_style.default_size[1] * health_fraction + 0.5))
	end

	local debuffs = data.debuffs or {}

	for i = 1, MAX_DEBUFF_ROWS do
		local debuff = debuffs[i]
		local icon_id = "debuff_icon_" .. i
		local text_id = "debuff_text_" .. i
		local outline_id = text_id .. "_outline_text"
		local icon_style = widget.style[icon_id]
		local text_style = widget.style[text_id]
		local outline_style = widget.style[text_id .. "_outline"]

		if debuff then
			local label = debuff.label or ""
			local value_text = debuff.value_text or ""
			local colored_value_text = value_text ~= "" and color_text(value_text, accent_color) or ""

			widget.content[icon_id] = debuff.icon

			if label ~= "" and value_text ~= "" then
				widget.content[text_id] = label .. " " .. colored_value_text
				widget.content[outline_id] = label .. " " .. value_text
			else
				widget.content[text_id] = label ~= "" and label or colored_value_text
				widget.content[outline_id] = label ~= "" and label or value_text
			end

			if icon_style then
				icon_style.color[1] = alpha
				icon_style.color[2] = accent_color[2]
				icon_style.color[3] = accent_color[3]
				icon_style.color[4] = accent_color[4]
			end

			_apply_text_color(text_style, text_color, alpha)

			if outline_style and outline_style.text_color then
				outline_style.text_color[1] = alpha
			end
		else
			widget.content[icon_id] = nil
			widget.content[text_id] = ""
			widget.content[outline_id] = ""

			if icon_style then
				icon_style.color[1] = alpha
				icon_style.color[2] = accent_color[2]
				icon_style.color[3] = accent_color[3]
				icon_style.color[4] = accent_color[4]
			end
		end
	end

	if debuff_label_style then
		_apply_text_color(debuff_label_style, text_color, alpha)
	end
	if debuff_outline_style and debuff_outline_style.text_color then
		debuff_outline_style.text_color[1] = alpha
	end

	widget.alpha_multiplier = opacity or 1
	widget.dirty = true
end

M.destroy = function(widget)
	_reset_widget(widget)
end

return M
