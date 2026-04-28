local M = {}

function M.append_passes(passes, settings, templates)
	passes[#passes + 1] = templates.rect_pass(settings, "status_background", settings.color_status_background_default, { settings.status_background_x, settings.status_background_y, 2 }, { settings.status_background_width, settings.status_background_height })
	passes[#passes + 1] = templates.rect_pass(settings, "coherency_border", settings.color_coherency_border_in, { settings.coherency_border_x, settings.coherency_border_y, 3 }, { 0, settings.coherency_border_height })
	passes[#passes + 1] = templates.text_pass(settings, "class_icon", "class_icon", 22, { settings.class_icon_x, 0, 4 }, { settings.icon_column_width, 22 }, settings.color_text_default, "center")
	passes[#passes + 1] = templates.status_texture_pass(settings, "class_status_icon", "class_status_icon", { settings.class_status_icon_x, settings.class_status_icon_y, 5 }, { settings.class_status_icon_size, settings.class_status_icon_size })
	passes[#passes + 1] = templates.text_pass(settings, "player_name", "player_name", 16, { settings.name_x, settings.name_y, 4 }, { settings.name_width, settings.name_height }, settings.color_text_default, "left", "proxima_nova_bold_no_render_flags")
	passes[#passes + 1] = templates.text_pass(settings, "relation_status", "relation_status", 15, { settings.relation_status_x, settings.relation_status_y, 7 }, { settings.relation_status_width, settings.relation_status_height }, settings.color_text_default, "left")
end

return M
