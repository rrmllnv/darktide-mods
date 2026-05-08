local M = {}

function M.append_passes(passes, settings, templates)
	passes[#passes + 1] = templates.rect_pass(settings, "toughness_fill", settings.color_toughness, { settings.bar_left, settings.toughness_bar_y, 4 }, { settings.bar_width, settings.bar_height })
	passes[#passes + 1] = {
		pass_type = "rect",
		style_id = "toughness_overshield_spent",
		style = {
			color = templates.clone_color(settings.color_toughness_overshield, 0),
			offset = {
				settings.bar_left,
				settings.toughness_bar_y,
				5,
			},
			size = {
				0,
				settings.bar_height,
			},
			size_addition = {
				0,
				0,
			},
		},
		visibility_function = function(content)
			return content.visible == true and content.toughness_overshield_spent_visible == true
		end,
	}
	passes[#passes + 1] = templates.rect_pass(settings, "revive_fill", settings.color_revive, { settings.bar_left, settings.toughness_bar_y, 5 }, { 0, settings.bar_height })

	for i = 1, 10 do
		passes[#passes + 1] = templates.rect_pass(settings, "health_fill_" .. i, settings.color_health, { settings.bar_left, settings.health_bar_y, 4 }, { 0, settings.bar_height })
		passes[#passes + 1] = templates.rect_pass(settings, "corruption_fill_" .. i, settings.color_corruption, { settings.bar_left, settings.health_bar_y, 5 }, { 0, settings.bar_height })
	end

	-- Hub (Mourningstar) info rendered in bar area (class only).
	do
		local class_style = templates.text_style(settings, settings.hub_info_font_size, "left", "center", settings.color_text_default)
		class_style.offset = { settings.hub_info_x, settings.hub_info_y, 6 }
		class_style.size = { settings.hub_text_width, settings.hub_info_height }

		passes[#passes + 1] = {
			pass_type = "text",
			style_id = "hub_class_text",
			value_id = "hub_class_text",
			value = "",
			style = class_style,
			visibility_function = function(content)
				return content.visible == true and content.hub_class_visible == true
			end,
		}
	end
end

return M
