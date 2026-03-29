local communication_command_wheel_settings = {
	anim_speed = 25,
	max_radius = 190,
	min_radius = 185,
	scan_delay = 0,
	hover_grace_period = 0.1,
	wheel_slots = 8,
	hover_min_distance = 130,
	hover_angle_degrees = 44,
	icon_size_square = {
		96,
		96,
	},
	weapon_icon_layout_scale = 0.5,
	open_hold_delay_seconds = 0.1,
	center_circle_size = 250,
	rhombus_width = nil,
	rhombus_height = nil,
	page_indicator_size = 20,
	page_indicator_spacing = 10,
	background_color = {
		255,
		0,
		0,
		0,
	},
	rhombus_color = {
		120,
		0,
		0,
		0,
	},
}

return settings("CommunicationCommandWheelSettings", communication_command_wheel_settings)
