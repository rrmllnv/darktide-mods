local M = {}

function M.append_passes(passes, settings, templates)
	passes[#passes + 1] = templates.ability_texture_pass(settings, "ability_icon", settings.ability_icon_material, { settings.ability_icon_x, settings.ability_icon_y, 4 }, { settings.ability_icon_size, settings.ability_icon_size }, settings.color_ability_icon, {
		progress = 1,
		talent_icon = nil,
	})
	passes[#passes + 1] = templates.ability_texture_pass(settings, "ability_frame", settings.ability_icon_frame_material, { settings.ability_icon_frame_x, settings.ability_icon_frame_y, 5 }, { settings.ability_icon_frame_size, settings.ability_icon_frame_size }, settings.color_ability_frame)
	passes[#passes + 1] = templates.ability_texture_pass(settings, "ability_glow", settings.ability_icon_glow_material, { settings.ability_icon_frame_x, settings.ability_icon_frame_y, 6 }, { settings.ability_icon_frame_size, settings.ability_icon_frame_size }, settings.color_ability_glow)
end

return M
