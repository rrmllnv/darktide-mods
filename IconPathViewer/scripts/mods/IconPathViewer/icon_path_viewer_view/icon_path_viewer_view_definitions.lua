local mod = get_mod("IconPathViewer")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")

local grid_width = 1270
local edge_padding = 60
local window_size = {
	grid_width + edge_padding,
	810,
}
local grid_size = {
	grid_width,
	window_size[2]
}
local grid_spacing = {
	10,
	10
}
local elements_size = {
	120,
	120,
}

local grid_settings = {
	scrollbar_width = 7,
	use_terminal_background = true,
	title_height = 0,
	grid_spacing = grid_spacing,
	grid_size = grid_size,
	mask_size = window_size,
	edge_padding = edge_padding
}

local blueprints = {
	unicode_icon = {
		size = { 120, 120 },
		pass_template = {
			{
				content_id = "hotspot",
				pass_type = "hotspot",
				content = {
					on_hover_sound   = UISoundEvents.default_mouse_hover,
					on_pressed_sound = UISoundEvents.default_click
				}
			},
			{ pass_type = "rect", style = { color = { 100, 0, 0, 0 } } },
			{
				pass_type = "texture",
				style_id = "background",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					default_color = Color.terminal_background(nil, true),
					selected_color = Color.terminal_background_selected(nil, true)
				},
				change_function = ButtonPassTemplates.terminal_button_change_function,
			},
			{
				pass_type = "texture",
				style_id = "background_gradient",
				value = "content/ui/materials/gradients/gradient_vertical",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					default_color = Color.terminal_background_gradient(nil, true),
					selected_color = Color.terminal_frame_selected(nil, true),
					offset = { 0, 0, 2 }
				},
				change_function = function (content, style)
					ButtonPassTemplates.terminal_button_change_function(content, style)
					ButtonPassTemplates.terminal_button_hover_change_function(content, style)
				end,
			},
			{
				value = "content/ui/materials/frames/dropshadow_medium",
				style_id = "outer_shadow",
				pass_type = "texture",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					scale_to_material = true,
					color = Color.black(100, true),
					size_addition = { 20, 20 },
					offset = { 0, 0, 3 }
				}
			},
			{
				pass_type = "texture",
				value = "content/ui/materials/frames/inner_shadow_thin",
				style = {
					scale_to_material = true,
					color = Color.terminal_corner_selected(nil, true),
					offset = { 0, 0, 1 }
				},
				visibility_function = function(content)
					if content.force_glow or content.equipped or (content.hotspot and content.hotspot.is_selected) then
						return true
					end
					local ik = content.icon_key or (content.element and content.element.icon_key)
					local ck = content.current_key or (content.element and content.element.current_key)
					if type(ik) == "string" then ik = string.lower(ik) end
					if type(ck) == "string" then ck = string.lower(ck) end
					return (ik ~= nil and ck ~= nil and ik == ck)
				end
			},
			{
				pass_type = "texture",
				style_id = "frame",
				value = "content/ui/materials/frames/frame_tile_2px",
				style = {
					horizontal_alignment = "center",
					vertical_alignment   = "center",
					offset               = { 0, 0, 6 },
					color                = Color.terminal_frame(nil, true),
					default_color        = Color.terminal_frame(nil, true),
					selected_color       = Color.terminal_frame_selected(nil, true),
					hover_color          = Color.terminal_frame_hover(nil, true)
				},
				change_function = ButtonPassTemplates.default_button_hover_change_function
			},
			{
				pass_type = "texture",
				style_id = "corner",
				value = "content/ui/materials/frames/frame_corner_2px",
				style = {
					horizontal_alignment = "center",
					vertical_alignment   = "center",
					offset               = { 0, 0, 7 },
					color                = Color.terminal_corner(nil, true),
					default_color        = Color.terminal_corner(nil, true),
					selected_color       = Color.terminal_corner_selected(nil, true),
					hover_color          = Color.terminal_corner_hover(nil, true)
				},
				change_function = ButtonPassTemplates.default_button_hover_change_function
			},
			{
				pass_type = "texture",
				value = "content/ui/materials/frames/frame_tile_1px",
				style = { color = { 255, 0, 0, 0 }, offset = { 0, 0, 3 } }
			},
			{
				pass_type = "text",
				value_id = "text",
				style = {
					font_size                 = 28,
					font_type                 = "proxima_nova_bold",
					text_horizontal_alignment = "center",
					text_vertical_alignment   = "center",
					offset                    = { 0, 0, 2 },
					text_color                = Color.terminal_icon(255, true)
				}
			},
			-- Текст Unicode глифа (для копирования)
			{
				style_id = "unicode_text",
				pass_type = "text",
				value = "",
				value_id = "unicode_text",
				style = {
					vertical_alignment = "bottom",
					horizontal_alignment = "center",
					text_vertical_alignment = "bottom",
					text_horizontal_alignment = "center",
					offset = { 0, -5, 10 },
					size = { elements_size[1], 30 },
					text_color = Color.terminal_text_header(255, true),
					font_type = "proxima_nova_bold",
					font_size = 12,
				},
			},
			-- Unicode код (при наведении)
			{
				style_id = "unicode_code",
				pass_type = "text",
				value = "",
				value_id = "unicode_code",
				style = {
					vertical_alignment = "top",
					horizontal_alignment = "center",
					text_vertical_alignment = "top",
					text_horizontal_alignment = "center",
					offset = { 0, 0, 10 },
					size = { elements_size[1], 40 },
					text_color = Color.terminal_text_header(200, true),
					font_type = "proxima_nova_bold",
					font_size = 10,
				},
				visibility_function = function(content)
					return content.hotspot and content.hotspot.is_hover
				end,
			},
		},
		init = function (parent, widget, element, callback_name)
			local content = widget.content
			local style = widget.style

			content.hotspot.pressed_callback = callback_name and callback(parent, callback_name, widget, element)
			content.icon_index = element.icon_index
			content.text = element.text or "?"
			content.unicode_text = element.unicode_text or element.text or "?"
			content.unicode_code = element.unicode_code or element.icon_key or ""
		end
	},
	icon_box = {
		size = elements_size,
		pass_template = {
			{
				pass_type = "hotspot",
				content_id = "hotspot",
				style = {
					on_hover_sound = UISoundEvents.default_mouse_hover,
					on_pressed_sound = UISoundEvents.default_click,
				}
			},
			{
				pass_type = "texture",
				style_id = "background",
				value = "content/ui/materials/backgrounds/default_square",
				style = {
					default_color = Color.terminal_background(nil, true),
					selected_color = Color.terminal_background_selected(nil, true)
				},
				change_function = ButtonPassTemplates.terminal_button_change_function,
			},
			{
				pass_type = "texture",
				style_id = "background_gradient",
				value = "content/ui/materials/gradients/gradient_vertical",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					default_color = Color.terminal_background_gradient(nil, true),
					selected_color = Color.terminal_frame_selected(nil, true),
					offset = {
						0,
						0,
						2,
					}
				},
				change_function = function (content, style)
					ButtonPassTemplates.terminal_button_change_function(content, style)
					ButtonPassTemplates.terminal_button_hover_change_function(content, style)
				end,
			},
			{
				value = "content/ui/materials/frames/dropshadow_medium",
				style_id = "outer_shadow",
				pass_type = "texture",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					scale_to_material = true,
					color = Color.black(100, true),
					size_addition = {
						20,
						20,
					},
					offset = {
						0,
						0,
						3,
					}
				}
			},
			-- Иконка
			{
				pass_type = "texture",
				value_id = "icon",
				value = "content/ui/materials/base/ui_default_base",
				style_id = "icon",
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "center",
					size = {
						64,
						64,
					},
					offset = {
						0,
						-15,
						10,
					},
					color = {
						255,
						255,
						255,
						255,
					},
				},
			},
			-- Путь иконки (короткое имя)
			{
				style_id = "icon_path_short",
				pass_type = "text",
				value = "",
				value_id = "icon_path_short",
				style = {
					vertical_alignment = "bottom",
					horizontal_alignment = "center",
					text_vertical_alignment = "bottom",
					text_horizontal_alignment = "center",
					offset = { 0, -5, 10 },
					size = { elements_size[1], 30 },
					text_color = Color.terminal_text_header(255, true),
					font_type = "proxima_nova_bold",
					font_size = 12,
				},
			},
			-- Полный путь (при наведении)
			{
				style_id = "icon_path",
				pass_type = "text",
				value = "",
				value_id = "icon_path",
				style = {
					vertical_alignment = "top",
					horizontal_alignment = "center",
					text_vertical_alignment = "top",
					text_horizontal_alignment = "center",
					offset = { 0, 0, 10 },
					size = { elements_size[1], 40 },
					text_color = Color.terminal_text_header(200, true),
					font_type = "proxima_nova_bold",
					font_size = 10,
				},
				visibility_function = function(content)
					return content.hotspot and content.hotspot.is_hover
				end,
			},
			{
				pass_type = "texture",
				style_id = "frame",
				value = "content/ui/materials/frames/frame_tile_2px",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					color = Color.terminal_frame(nil, true),
					default_color = Color.terminal_frame(nil, true),
					selected_color = Color.terminal_frame_selected(nil, true),
					hover_color = Color.terminal_frame_hover(nil, true),
					offset = {
						0,
						0,
						2,
					}
				},
			},
			{
				pass_type = "texture",
				style_id = "corner",
				value = "content/ui/materials/frames/frame_corner_2px",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					color = Color.terminal_corner(nil, true),
					default_color = Color.terminal_corner(nil, true),
					selected_color = Color.terminal_corner_selected(nil, true),
					hover_color = Color.terminal_corner_hover(nil, true),
					offset = {
						0,
						0,
						13,
					}
				},
			},
		},
		init = function (parent, widget, element, callback_name)
			local content = widget.content
			local style = widget.style

			content.hotspot.pressed_callback = callback_name and callback(parent, callback_name, widget, element)
			content.icon_index = element.icon_index
			content.icon_path = element.icon_path or element.icon
			content.icon_path_short = element.icon_path_short
			content.icon = element.icon or element.icon_path -- Используем icon для отображения
		end
	},
	spacing_vertical = {
		size = {
			grid_width,
			20,
		}
	}
}

local scenegraph_definition = {
	screen = {
		scale = "fit",
		size = {
			1920,
			1080,
		},
		position = {
			0,
			0,
			100,
		},
	},
	title_divider = {
		parent = "screen",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {
			335,
			18,
		},
		position = {
			180,
			145,
			101,
		}
	},
	title_text = {
		parent = "title_divider",
		vertical_alignment = "bottom",
		horizontal_alignment = "left",
		size = {
			500,
			50,
		},
		position = {
			0,
			-35,
			101,
		}
	},
	canvas = {
		parent = "screen",
		horizontal_alignment = "center",
		vertical_alignment = "top",
		size = {
			1920,
			915,
		},
		position = {
			0,
			165,
			102,
		},
	},
	icon_table_pivot = {
		parent = "canvas",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = {
			0,
			0,
		},
		position = {
			180,
			30,
			103,
		}
	},
}

local widget_definitions = {
	background = UIWidget.create_definition({
		{
			value = "content/ui/materials/backgrounds/terminal_basic",
			pass_type = "texture",
			style = {
				horizontal_alignemt = "center",
				scale_to_material = true,
				vertical_alignemnt = "center",
				size_addition = {
					40,
					40
				},
				offset = {
					-20,
					-20,
					1
				},
				color = Color.terminal_grid_background_gradient(255, true),
			}
		},
		{
			pass_type = "rect",
			style = {
				color = Color.black(255, true)
			},
			offset = {
				0,
				0,
				0
			}
		},
	}, "screen"),
	title_divider = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/dividers/skull_rendered_left_01",
		}
	}, "title_divider"),
	title_text = UIWidget.create_definition({
		{
			value_id = "title_text",
			style_id = "title_text",
			pass_type = "text",
			value = mod:localize("icon_viewer_title"),
			style = table.clone(UIFontSettings.header_1),
		}
	}, "title_text"),
	desc_text = UIWidget.create_definition({
		{
			value_id = "desc_text",
			style_id = "desc_text",
			pass_type = "text",
			value = mod:localize("icon_viewer_desc"),
			style = {
				line_spacing = 1.2,
				font_size = 22,
				font_type = "proxima_nova_bold",
				text_color = Color.text_default(255, true),
				default_color = Color.text_default(255, true),
				offset = {
					180,
					0,
					0
				},
			}
		}
	}, "canvas"),
}

local legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "_on_back_pressed",
		display_name = "loc_class_selection_button_back",
		alignment = "left_alignment",
	},
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	blueprints = blueprints,
	legend_inputs = legend_inputs,
	grid_settings = grid_settings,
}

