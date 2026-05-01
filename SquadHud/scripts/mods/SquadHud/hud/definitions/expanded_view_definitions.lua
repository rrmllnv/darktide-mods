local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}

function M.append_scenegraph(scenegraph_definition, settings)
	scenegraph_definition.squadhud_expanded_view_hint = {
		horizontal_alignment = "left",
		parent = "squadhud_root",
		vertical_alignment = "top",
		size = {
			settings.expanded_view_hint_width,
			settings.expanded_view_hint_height,
		},
		position = {
			settings.expanded_view_hint_x,
			settings.root_height + settings.expanded_view_hint_gap,
			2,
		},
	}
end

function M.create_widget_definition(scenegraph_id, settings, templates)
	local passes = {
		templates.rect_pass(settings, "background", settings.color_expanded_view_hint_background, { 0, 0, 1 }, { settings.expanded_view_hint_width, settings.expanded_view_hint_height }),
		templates.text_pass(settings, "text", "text", settings.expanded_view_hint_font_size, { settings.expanded_view_hint_padding_x, 0, 2 }, { settings.expanded_view_hint_width - settings.expanded_view_hint_padding_x * 2, settings.expanded_view_hint_height }, settings.color_text_default, "center"),
	}

	return UIWidget.create_definition(passes, scenegraph_id)
end

return M
