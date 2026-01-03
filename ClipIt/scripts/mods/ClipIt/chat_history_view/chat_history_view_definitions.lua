local mod = get_mod("ClipIt")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIFontSettings = mod:original_require("scripts/managers/ui/ui_font_settings")
local ScrollbarPassTemplates = mod:original_require("scripts/ui/pass_templates/scrollbar_pass_templates")
local ButtonPassTemplates = mod:original_require("scripts/ui/pass_templates/button_pass_templates")
local Color = Color

local constants = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_constants")

local category_panel_size = constants.category_panel_size
local messages_panel_size = constants.messages_panel_size
local scrollbar_width = constants.scrollbar_width
local grid_size = constants.grid_size
local mask_size = constants.mask_size

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	dim_background = {
		parent = "screen",
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = {1920, 1080},
		position = {0, 0, -5},
	},
	background_icon = {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = {1250, 1250},
		position = {0, 0, -4},
	},
	title_divider = {
		vertical_alignment = "top",
		parent = "screen",
		horizontal_alignment = "left",
		size = {335, 18},
		position = {180, 145, 1},
	},
	title_text = {
		vertical_alignment = "bottom",
		parent = "title_divider",
		horizontal_alignment = "left",
		size = {500, 50},
		position = {0, -35, 1},
	},
	category_panel = {
		vertical_alignment = "top",
		parent = "screen",
		horizontal_alignment = "left",
		size = category_panel_size,
		position = {140, 190, 0},
	},
	messages_panel = {
		vertical_alignment = "top",
		parent = "screen",
		horizontal_alignment = "right",
		size = messages_panel_size,
		position = {-180, 130, 0},
	},
	messages_panel_background = {
		vertical_alignment = "top",
		parent = "messages_panel",
		horizontal_alignment = "center",
		size = {messages_panel_size[1], messages_panel_size[2]},
		position = {0, 0, -1},
	},
	grid_pivot = {
		vertical_alignment = "top",
		parent = "messages_panel",
		horizontal_alignment = "left",
		size = {0, 0},
		position = {20, 20, 3},
	},
	grid_scrollbar = {
		vertical_alignment = "top",
		parent = "messages_panel",
		horizontal_alignment = "right",
		size = {scrollbar_width, messages_panel_size[2] - 60},
		position = {30, 30, 2},
	},
	sessions_list_pivot = {
		vertical_alignment = "top",
		parent = "category_panel",
		horizontal_alignment = "left",
		size = {0, 0},
		position = {0, 0, 2},
	},
}

-- Генерируем scenegraph для кнопок сессий динамически (будет создано в runtime)

local title_style = table.clone(UIFontSettings.header_1 or {})
title_style.text_horizontal_alignment = "left"
title_style.text_vertical_alignment = "bottom"

local widget_definitions = {
	dim_background = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = {180, 0, 0, 0},
			},
		},
	}, "dim_background"),
	background_icon = UIWidget.create_definition({
		{
			value = "content/ui/vector_textures/symbols/cog_skull_01",
			pass_type = "slug_icon",
			style = {
				color = {80, 0, 0, 0},
			},
		},
	}, "background_icon"),
	title_divider = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/dividers/skull_rendered_left_01",
		},
	}, "title_divider"),
	title_text = UIWidget.create_definition({
		{
			value_id = "text",
			pass_type = "text",
			style = title_style,
			value = "",
		},
	}, "title_text"),
	messages_panel = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = Color.black(0, true),
			},
		},
	}, "messages_panel_background"),
	grid_scrollbar = UIWidget.create_definition(ScrollbarPassTemplates.default_scrollbar, "grid_scrollbar", {
		scroll_speed = 10,
		scroll_amount = 0.1,
	}),
}

local legend_inputs = constants.legend_inputs

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	legend_inputs = legend_inputs,
	grid_size = grid_size,
	mask_size = mask_size,
}

