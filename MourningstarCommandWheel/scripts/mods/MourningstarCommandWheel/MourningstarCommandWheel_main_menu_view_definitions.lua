local mod = get_mod("MourningstarCommandWheel")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UISettings = require("scripts/settings/ui/ui_settings")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local button_size = { 300, 50 }
local button_spacing = 60
local buttons_per_column = 7
local column_width = 320

-- Определяем кнопки и их view
local button_definitions = {
	{ name = "inventory_button", view_name = "inventory_background_view", localization_key = "main_menu_inventory_button" },
	{ name = "barber_button", view_name = "barber_vendor_background_view", localization_key = "main_menu_barber_button" },
	{ name = "contracts_button", view_name = "contracts_background_view", localization_key = "main_menu_contracts_button" },
	{ name = "crafting_button", view_name = "crafting_view", localization_key = "main_menu_crafting_button" },
	{ name = "credits_vendor_button", view_name = "credits_vendor_background_view", localization_key = "main_menu_credits_vendor_button" },
	{ name = "mission_board_button", view_name = "mission_board_view", localization_key = "main_menu_mission_board_button" },
	{ name = "store_button", view_name = "store_view", localization_key = "main_menu_store_button" },
	{ name = "training_grounds_button", view_name = "training_grounds_view", localization_key = "main_menu_training_grounds_button" },
	{ name = "social_button", view_name = "social_menu_view", localization_key = "main_menu_social_button" },
	{ name = "commissary_button", view_name = "cosmetics_vendor_background_view", localization_key = "main_menu_commissary_button" },
	{ name = "penance_button", view_name = "penance_overview_view", localization_key = "main_menu_penance_button" },
	--{ name = "havoc_button", view_name = "havoc_background_view", localization_key = "main_menu_havoc_button" },
	{ name = "group_finder_button", view_name = "group_finder_view", localization_key = "main_menu_group_finder_button" },
}

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	background = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = { 800, 500 },
		position = { 0, 0, 1 }
	},
	title = {
		vertical_alignment = "top",
		horizontal_alignment = "center",
		parent = "background",
		size = { 600, 50 },
		position = { 0, 10, 10 }
	},
	buttons_pivot = {
		vertical_alignment = "center",
		horizontal_alignment = "center",
		parent = "background",
		size = { column_width * 2, buttons_per_column * button_spacing },
		position = { 0, 50, 10 }
	},
}

-- Создаем scenegraph для кнопок (две колонки)
for i, button_def in ipairs(button_definitions) do
	local column = (i - 1) % 2
	local row = math.floor((i - 1) / 2)
	
	scenegraph_definition[button_def.name] = {
		vertical_alignment = "top",
		horizontal_alignment = "left",
		parent = "buttons_pivot",
		size = button_size,
		position = { column * column_width, row * button_spacing, 0 }
	}
end

-- Создаем виджеты
local widget_definitions = {
	background = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "background",
			value = "content/ui/materials/backgrounds/terminal_basic",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "center",
				size_addition = {
					40,
					40,
				},
				offset = {
					0,
					0,
					0,
				},
				color = Color.terminal_grid_background(255, true),
			},
		},
		-- {
		-- 	pass_type = "rect",
		-- 	style = {
		-- 		color = Color.black(100, true)
		-- 	},
		-- 	offset = {
		-- 		0,
		-- 		0,
		-- 		1
		-- 	}
		-- },
		{
			pass_type = "texture_uv",
			style_id = "top_divider",
			value = "content/ui/materials/dividers/horizontal_frame_big_lower",
			value_id = "top_divider",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "top",
				size_addition = {
					30,
					0,
				},
				size = {
					nil,
					36,
				},
				offset = {
					0,
					-20,
					2,
				},
				uvs = {
					{
						0,
						1,
					},
					{
						1,
						0,
					},
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "bottom_divider",
			value = "content/ui/materials/dividers/horizontal_frame_big_lower",
			value_id = "bottom_divider",
			style = {
				horizontal_alignment = "center",
				scale_to_material = true,
				vertical_alignment = "bottom",
				size_addition = {
					30,
					0,
				},
				size = {
					nil,
					36,
				},
				offset = {
					0,
					20,
					2,
				},
			},
		},
	}, "background"),
	
	title = UIWidget.create_definition({
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			value = mod:localize("main_menu_view_title"),
			style = {
				font_type = "proxima_nova_bold",
				font_size = 36,
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				text_color = Color.terminal_text_header(255, true),
			}
		}
	}, "title"),
}

-- Создаем виджеты для кнопок
for _, button_def in ipairs(button_definitions) do
	widget_definitions[button_def.name] = UIWidget.create_definition(
		ButtonPassTemplates.terminal_button_small,
		button_def.name,
		{
			text = mod:localize(button_def.localization_key),
			view_name = button_def.view_name
		}
	)
end

local legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "_on_back_pressed",
		display_name = "loc_class_selection_button_back",
		alignment = "center_alignment",
	},
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	legend_inputs = legend_inputs,
	button_definitions = button_definitions,
}

