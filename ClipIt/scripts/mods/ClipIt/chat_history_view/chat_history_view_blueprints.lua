local mod = get_mod("ClipIt")

local session_entry = {
	size = {900, 60},
	passes = {
		{
			pass_type = "rect",
			style_id = "background",
			style = {
				color = {100, 30, 30, 30},
				offset = {0, 0, 0},
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 22,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				text_color = {255, 255, 255, 255},
				offset = {15, 0, 1},
			},
		},
		{
			pass_type = "text",
			value_id = "subtext",
			style_id = "subtext",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 16,
				text_horizontal_alignment = "right",
				text_vertical_alignment = "center",
				text_color = {200, 180, 180, 180},
				offset = {-15, 0, 1},
			},
		},
	},
}

local message_entry = {
	size = {900, 30},
	passes = {
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			style = {
				font_type = "proxima_nova_bold",
				font_size = 16,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				text_color = {255, 220, 220, 220},
				offset = {15, 0, 1},
			},
		},
	},
}

return {
	session_entry = session_entry,
	message_entry = message_entry,
}
