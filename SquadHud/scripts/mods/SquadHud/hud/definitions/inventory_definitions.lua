local M = {}

function M.append_passes(passes, settings, templates)
	passes[#passes + 1] = templates.inventory_texture_pass(settings, "grenade_icon", "grenade_icon", { settings.grenade_icon_x, settings.inventory_icon_y, 4 })
	passes[#passes + 1] = templates.inventory_texture_pass(settings, "ammo_icon", "ammo_icon", { settings.ammo_icon_x, settings.inventory_icon_y, 4 })
	passes[#passes + 1] = templates.inventory_texture_pass(settings, "pocketable_icon", "pocketable_icon", { settings.inventory_icon_x, settings.inventory_icon_y, 4 })
	passes[#passes + 1] = templates.inventory_texture_pass(settings, "pocketable_small_icon", "pocketable_small_icon", { settings.inventory_small_icon_x, settings.inventory_icon_y, 4 })
	passes[#passes + 1] = templates.text_pass(settings, "salvage_text", "salvage_text", settings.salvage_font_size, { settings.salvage_text_x, settings.salvage_text_y, 4 }, { settings.salvage_text_width, settings.salvage_text_height }, settings.color_text_default, "left", nil, true)
	passes[#passes + 1] = templates.text_pass(settings, "inventory_value_out_text", "inventory_value_out_text", settings.inventory_value.font_size, { settings.inventory_value.x, settings.inventory_value.y, 7 }, { settings.inventory_value.text_width, settings.inventory_value.height }, settings.color_health, "left", nil, true)
	passes[#passes + 1] = templates.text_pass(settings, "inventory_value_text", "inventory_value_text", settings.inventory_value.font_size, { settings.inventory_value.x, settings.inventory_value.y, 8 }, { settings.inventory_value.text_width, settings.inventory_value.height }, settings.color_health, "left", nil, true)
end

return M
