local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local M = {}

function M.clone_color(color, alpha)
	local c = table.clone(color)

	if type(alpha) == "number" then
		c[1] = alpha
	end

	return c
end

function M.text_style(settings, font_size, horizontal_alignment, vertical_alignment, color)
	local style = table.clone(UIFontSettings.hud_body)

	style.font_size = font_size
	style.font_type = "proxima_nova_bold"
	style.drop_shadow = true
	style.text_horizontal_alignment = horizontal_alignment or "left"
	style.text_vertical_alignment = vertical_alignment or "center"
	style.text_color = M.clone_color(color or settings.color_text_default)

	return style
end

function M.rect_pass(settings, style_id, color, offset, size)
	return {
		pass_type = "rect",
		style_id = style_id,
		style = {
			color = M.clone_color(color),
			offset = offset,
			size = size,
		},
		visibility_function = function(content)
			return content.visible == true
		end,
	}
end

function M.text_pass(settings, style_id, value_id, font_size, offset, size, color, horizontal_alignment, font_type, drop_shadow)
	local style = M.text_style(settings, font_size, horizontal_alignment or "left", "center", color)

	if font_type then
		style.font_type = font_type
	end

	if drop_shadow ~= nil then
		style.drop_shadow = drop_shadow
	end

	style.offset = offset
	style.size = size

	return {
		pass_type = "text",
		style_id = style_id,
		value_id = value_id,
		value = "",
		style = style,
		visibility_function = function(content)
			return content.visible == true
		end,
	}
end

function M.ability_texture_pass(settings, style_id, material, offset, size, color, material_values)
	return {
		pass_type = "texture",
		value = material,
		style_id = style_id,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			material_values = material_values,
			size = size,
			offset = offset,
			color = M.clone_color(color),
		},
		change_function = function(content, style)
			if style.material_values then
				style.material_values.progress = content.ability_progress or 1
			end
		end,
		visibility_function = function(content)
			return content.visible == true and content.ability_icon_visible == true
		end,
	}
end

function M.inventory_texture_pass(settings, style_id, value_id, offset)
	return {
		pass_type = "texture",
		style_id = style_id,
		value_id = value_id,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = {
				settings.inventory_icon_size,
				settings.inventory_icon_size,
			},
			default_offset = {
				offset[1],
				offset[2],
				offset[3],
			},
			offset = offset,
			color = M.clone_color(settings.color_text_default),
		},
		visibility_function = function(content)
			return content.visible == true and content[value_id] ~= nil
		end,
	}
end

function M.status_texture_pass(settings, style_id, value_id, offset, size)
	return {
		pass_type = "texture",
		style_id = style_id,
		value_id = value_id,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = size,
			offset = offset,
			color = M.clone_color(settings.color_text_default),
		},
		visibility_function = function(content)
			return content.visible == true and content[value_id] ~= nil
		end,
	}
end

return M
