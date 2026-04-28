local M = {}

function M.append_passes(passes, settings, templates)
	passes[#passes + 1] = templates.rect_pass(settings, "toughness_fill", settings.color_toughness, { settings.bar_left, settings.toughness_bar_y, 4 }, { settings.bar_width, settings.bar_height })
	passes[#passes + 1] = templates.rect_pass(settings, "revive_fill", settings.color_revive, { settings.bar_left, settings.toughness_bar_y, 5 }, { 0, settings.bar_height })

	for i = 1, 10 do
		passes[#passes + 1] = templates.rect_pass(settings, "health_fill_" .. i, settings.color_health, { settings.bar_left, settings.health_bar_y, 4 }, { 0, settings.bar_height })
		passes[#passes + 1] = templates.rect_pass(settings, "corruption_fill_" .. i, settings.color_corruption, { settings.bar_left, settings.health_bar_y, 5 }, { 0, settings.bar_height })
	end
end

return M
