local M = {}

function M.append_passes(passes, settings, templates)
	passes[#passes + 1] = {
		pass_type = "rect",
		style_id = "toughness_hit_indicator",
		style = {
			color = templates.clone_color(settings.color_toughness_hit_indicator, 0),
			offset = {
				settings.status_background_x - settings.toughness_hit_indicator_padding,
				settings.status_background_y - settings.toughness_hit_indicator_padding,
				1,
			},
			size = {
				settings.status_background_width + settings.toughness_hit_indicator_padding * 2,
				settings.status_background_height + settings.toughness_hit_indicator_padding * 2,
			},
		},
		visibility_function = function(content)
			return content.visible == true and content.toughness_hit_indicator_visible == true
		end,
	}
	passes[#passes + 1] = {
		pass_type = "rect",
		style_id = "toughness_armor_break_indicator",
		style = {
			color = templates.clone_color(settings.color_toughness_armor_break_indicator, 0),
			offset = {
				settings.status_background_x - settings.toughness_hit_indicator_padding,
				settings.status_background_y - settings.toughness_hit_indicator_padding,
				3,
			},
			size = {
				settings.status_background_width + settings.toughness_hit_indicator_padding * 2,
				settings.status_background_height + settings.toughness_hit_indicator_padding * 2,
			},
		},
		visibility_function = function(content)
			return content.visible == true and content.toughness_armor_break_indicator_visible == true
		end,
	}
	passes[#passes + 1] = templates.rect_pass(settings, "status_background", settings.color_status_background_default, { settings.status_background_x, settings.status_background_y, 2 }, { settings.status_background_width, settings.status_background_height })
	passes[#passes + 1] = templates.rect_pass(settings, "coherency_border", settings.color_coherency_border_in, { settings.coherency_border_x, settings.coherency_border_y, 3 }, { 0, settings.coherency_border_height })
	passes[#passes + 1] = templates.text_pass(settings, "class_icon", "class_icon", settings.class_icon_font_size, { settings.class_icon_x, 0, 4 }, { settings.icon_column_width, settings.class_icon_height }, settings.color_text_default, "center")
	passes[#passes + 1] = templates.status_texture_pass(settings, "class_status_icon", "class_status_icon", { settings.class_status_icon_x, settings.class_status_icon_y, 5 }, { settings.class_status_icon_size, settings.class_status_icon_size })
	passes[#passes + 1] = templates.text_pass(settings, "player_name", "player_name", settings.name_font_size, { settings.name_x, settings.name_y, 4 }, { settings.name_width, settings.name_height }, settings.color_text_default, "left", "proxima_nova_bold_no_render_flags")
	passes[#passes + 1] = templates.text_pass(settings, "relation_status", "relation_status", settings.relation_status_font_size, { settings.relation_status_x, settings.relation_status_y, 7 }, { settings.relation_status_width, settings.relation_status_height }, settings.color_text_default, "right")
end

return M
