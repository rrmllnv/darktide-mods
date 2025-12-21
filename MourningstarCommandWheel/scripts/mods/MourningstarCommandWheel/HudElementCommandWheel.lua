local mod = get_mod("MourningstarCommandWheel")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")

local CommandWheelSettings = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_settings")

local Definitions = mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_definitions")
local Utils = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_utils")
local Buttons = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_buttons")
local InputDevice = require("scripts/managers/input/input_device")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Vector3 = Vector3
local RESOLUTION_LOOKUP = RESOLUTION_LOOKUP

local HOVER_GRACE_PERIOD = 0.4

local is_in_valid_lvl = Utils.is_in_valid_lvl
local is_in_psychanium = Utils.is_in_psychanium
local localize_text = Utils.localize_text
local activate_option = Utils.activate_option
local apply_style_offset = Utils.apply_style_offset
local apply_style_color = Utils.apply_style_color

local button_definitions = Buttons.button_definitions
local button_definitions_by_id = Buttons.button_definitions_by_id


local function load_wheel_config()
	local saved_config = mod:get("wheel_config")
	if saved_config and #saved_config > 0 then

		local valid_config = {}
		for _, id in ipairs(saved_config) do
			if button_definitions_by_id[id] then
				table.insert(valid_config, id)
			end
		end


		for _, button in ipairs(button_definitions) do
			if button.id == "exit_psychanium" then

				goto continue
			end
			local found = false
			for _, saved_id in ipairs(valid_config) do
				if saved_id == button.id then
					found = true
					break
				end
			end
			if not found then
				table.insert(valid_config, button.id)
			end
			::continue::
		end
		return valid_config
	end


	local default_config = {}
	for _, button in ipairs(button_definitions) do
		if button.id ~= "exit_psychanium" then
			table.insert(default_config, button.id)
		end
	end
	return default_config
end


local function save_wheel_config(wheel_config)

	mod:set("wheel_config", wheel_config)

	local dmf = get_mod("DMF")
	if dmf and dmf.save_unsaved_settings_to_file then
		dmf.save_unsaved_settings_to_file()
	end
end


local function generate_options_from_config(wheel_config)
	local options = {}
	local in_psychanium = is_in_psychanium()
	
	for i, id in ipairs(wheel_config) do

		if in_psychanium and id == "training_grounds" then
			options[i] = button_definitions_by_id["exit_psychanium"]


		elseif not in_psychanium and id == "exit_psychanium" then
			options[i] = nil

		else
			options[i] = button_definitions_by_id[id]
		end
	end
	return options
end

local HudElementCommandWheel = class("HudElementCommandWheel", "HudElementBase")

HudElementCommandWheel.init = function(self, parent, draw_layer, start_scale)
	HudElementCommandWheel.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._wheel_active_progress = 0
	self._wheel_active = false
	self._entries = {}
	self._last_widget_hover_data = {
		index = nil,
		t = nil,
	}
	self._wheel_context = {}
	self._close_delay = nil
	

	self._wheel_config = load_wheel_config()
	

	local active_buttons_count = #self._wheel_config
	local wheel_slots = math.max(active_buttons_count, CommandWheelSettings.wheel_slots)
	self:_setup_entries(wheel_slots)
	

	local options = generate_options_from_config(self._wheel_config)
	self:_populate_wheel(options)
	
	self._wheel_background_widget = self._widgets_by_name.wheel_background
end

HudElementCommandWheel._setup_entries = function(self, num_entries)
	if self._entries then
		for i = 1, #self._entries do
			local entry = self._entries[i]
			local widget = entry.widget
			local widget_name = widget.name

			self:_unregister_widget_name(widget_name)
		end
	end

	local entries = {}
	local definition = Definitions.entry_widget_definition

	for i = 1, num_entries do
		local name = "entry_" .. i
		local widget = self:_create_widget(name, definition)

		entries[i] = {
			widget = widget,
		}
	end

	self._entries = entries
end

HudElementCommandWheel._populate_wheel = function(self, options)
	local entries = self._entries
	local wheel_slots = CommandWheelSettings.wheel_slots

	for i = 1, wheel_slots do
		local option = options[i]
		local entry = entries[i]
		
		if entry then
			local widget = entry.widget
			local content = widget.content

			content.visible = option ~= nil
			entry.option = option

			if option then
				content.icon = option.icon or "content/ui/materials/base/ui_default_base"
				content.text = localize_text(option.label_key)
			end
		end
	end
end

HudElementCommandWheel.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementCommandWheel.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	self:_update_active_progress(dt)
	self:_update_widget_locations()

	if self._wheel_active then
		self:_update_wheel_presentation(dt, t, ui_renderer, render_settings, input_service)
	end

	self:_handle_input(t, dt, ui_renderer, render_settings, input_service)
end

HudElementCommandWheel._update_active_progress = function(self, dt)
	local active = self._wheel_active
	local anim_speed = CommandWheelSettings.anim_speed
	local progress = self._wheel_active_progress

	if active then
		progress = math.min(progress + dt * anim_speed, 1)
	else
		progress = math.max(progress - dt * anim_speed, 0)
	end

	self._wheel_active_progress = progress
	

	local wheel_background_widget = self._wheel_background_widget
	if wheel_background_widget then
		wheel_background_widget.visible = progress > 0
	end
end

HudElementCommandWheel._update_widget_locations = function(self)
	local entries = self._entries
	local start_angle = math.pi / 2
	local num_entries = #entries
	local radians_per_widget = math.pi * 2 / num_entries
	local active_progress = self._wheel_active_progress
	local anim_progress = math.smoothstep(active_progress, 0, 1)
	local wheel_slots = CommandWheelSettings.wheel_slots
	local min_radius = CommandWheelSettings.min_radius
	local max_radius = CommandWheelSettings.max_radius
	local radius = min_radius + anim_progress * (max_radius - min_radius)

	for i = 1, wheel_slots do
		local entry = entries[i]

		if entry then
			local widget = entry.widget
			local content = widget.content
			

			if content.visible or active_progress > 0 then
				local angle = start_angle + (i - 1) * radians_per_widget
				local position_x = math.sin(angle) * radius
				local position_y = math.cos(angle) * radius
				local offset = widget.offset

				content.angle = angle
				offset[1] = position_x
				offset[2] = position_y
			end
		end
	end
end

HudElementCommandWheel._update_wheel_presentation = function(self, dt, t, ui_renderer, render_settings, input_service)
	if not input_service or type(input_service.has) ~= "function" then
		return
	end


	if not input_service:has("cursor") and not (InputDevice.gamepad_active and input_service:has("navigate_controller_right")) then
		return
	end

	local screen_width, screen_height = RESOLUTION_LOOKUP.width, RESOLUTION_LOOKUP.height
	local scale = render_settings.scale
	local cursor = nil

	if input_service:has("cursor") then
		cursor = input_service:get("cursor")
	end

	if not cursor and InputDevice.gamepad_active and input_service:has("navigate_controller_right") then
		cursor = input_service:get("navigate_controller_right")
		if cursor then
			cursor[1] = screen_width * 0.5 + cursor[1] * screen_width * 0.5
			cursor[2] = screen_height * 0.5 - cursor[2] * screen_height * 0.5
		end
	end

	if not cursor then
		return
	end

	local cursor_distance_from_center = math.distance_2d(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2])
	local cursor_angle_from_center = math.angle(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2]) - math.pi * 0.5
	local cursor_angle_degrees_from_center = math.radians_to_degrees(cursor_angle_from_center) % 360
	

	local hover_min_distance = CommandWheelSettings.hover_min_distance or 130
	local entry_hover_degrees = CommandWheelSettings.hover_angle_degrees or 44
	local entry_hover_degrees_half = entry_hover_degrees * 0.5
	local any_hover = false
	local hovered_entry
	local is_hover_started = false
	local entries = self._entries

	for i = 1, #entries do
		local entry = entries[i]
		local widget = entry.widget
		local content = widget.content
		local widget_angle = content.angle
		local is_populated = entry.option ~= nil
		local is_hover = false


		if widget_angle and is_populated and cursor_distance_from_center > hover_min_distance * scale then
			local widget_angle_degrees = -(math.radians_to_degrees(widget_angle) - math.pi * 0.5) % 360
			local angle_diff = (widget_angle_degrees - cursor_angle_degrees_from_center + 180 + 360) % 360 - 180

			if angle_diff <= entry_hover_degrees_half and angle_diff >= -entry_hover_degrees_half then
				is_hover = true
				any_hover = true
				hovered_entry = entry
			end
		end

		if is_hover and not widget.content.hotspot.force_hover then
			is_hover_started = true
		end

		widget.content.hotspot.force_hover = is_hover
	end

	local wheel_background_widget = self._wheel_background_widget

	if wheel_background_widget then
		wheel_background_widget.content.angle = cursor_angle_from_center
		wheel_background_widget.content.force_hover = any_hover
		wheel_background_widget.style.mark.color[1] = any_hover and 255 or 0

		if hovered_entry then
			local option = hovered_entry.option
			wheel_background_widget.content.text = localize_text(option.label_key)

			if is_hover_started then
				if UISoundEvents.emote_wheel_entry_hover then
					Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_entry_hover)
				end
			end
		end
	end
end

HudElementCommandWheel._is_wheel_entry_hovered = function(self, t)
	local entries = self._entries

	for i = 1, #entries do
		local entry = entries[i]
		local widget = entry.widget

		if widget.content.hotspot.is_hover then
			self._last_widget_hover_data.index = i
			self._last_widget_hover_data.t = t
			return entry, i
		end
	end

	local last_hover = self._last_widget_hover_data
	local hover_grace_period = CommandWheelSettings.hover_grace_period or 0.4

	if last_hover.t and t < last_hover.t + hover_grace_period then
		local i = last_hover.index

		return entries[i], i
	end
end

HudElementCommandWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
	if self._close_delay then
		self._close_delay = self._close_delay - dt

		if self._close_delay <= 0 then
			self._close_delay = nil
			self:_pop_cursor()
		end

		return
	end


	if Managers.ui and Managers.ui:chat_using_input() then

		if self._wheel_active then
			self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
		end
		return
	end



	local input_pressed = false
	if is_in_valid_lvl() then
		input_pressed = mod:_is_command_wheel_key_pressed()
	end
	
	local wheel_context = self._wheel_context
	local start_time = wheel_context.input_start_time

	if input_pressed and not start_time then
		self:_on_wheel_start(t, input_service)
	elseif not input_pressed and start_time then

		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
		if hovered_entry then
			activate_option(hovered_entry.option)
		end
		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
	end


	local draw_wheel = false
	local start_time = wheel_context.input_start_time

	if start_time then
		draw_wheel = self._wheel_active
		local always_draw_t = start_time + 0.1

		if always_draw_t < t then
			draw_wheel = true
		end
	end

	if draw_wheel and not self._wheel_active then
		self._wheel_active = true
		

		local options = generate_options_from_config(self._wheel_config)
		self:_populate_wheel(options)

		if UISoundEvents.emote_wheel_open then
			Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
		end

		if not InputDevice.gamepad_active then
			self:_push_cursor()
		end
	elseif not draw_wheel and self._wheel_active then
		self._wheel_active = false
		self._close_delay = InputDevice.gamepad_active and 0.15 or 0
	end

	if not self._wheel_active then
		return
	end


	if not input_service or type(input_service.has) ~= "function" then
		return
	end


	if input_service:has("cancel_pressed") and input_service:get("cancel_pressed") then
		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
		return
	end


	local Mouse = rawget(_G, "Mouse")
	local right_mouse_held = false
	if Mouse then
		right_mouse_held = Mouse.button(1) == 1
	else

		if input_service:has("right_hold") then
			right_mouse_held = input_service:get("right_hold") or false
		end
	end


	local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
	
	if hovered_entry and right_mouse_held then

		if not mod.dragged_entry then
			mod.dragged_entry = hovered_entry
			mod.dragged_index = hovered_index
		end


		if hovered_index ~= mod.dragged_index then
			local wheel_config = self._wheel_config
			local replaced_id = wheel_config[hovered_index]
			wheel_config[hovered_index] = wheel_config[mod.dragged_index]
			wheel_config[mod.dragged_index] = replaced_id

			mod.dragged_entry = hovered_entry
			mod.dragged_index = hovered_index


			local options = generate_options_from_config(wheel_config)
			self:_populate_wheel(options)
			

			save_wheel_config(wheel_config)
		end


		local wheel_background_widget = self._wheel_background_widget
		if wheel_background_widget and mod.dragged_entry then
			local option = mod.dragged_entry.option
			if option then
				wheel_background_widget.content.text = localize_text(option.label_key)
			end
		end


		self:_update_drag_visual_feedback(hovered_index)
	else

		self:_reset_drag_visual_feedback()
		

		mod.dragged_entry = nil
		mod.dragged_index = nil
	end


	if not right_mouse_held and input_service and type(input_service.has) == "function" then
		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)
		

		if hovered_entry and input_service:has("left_pressed") and input_service:get("left_pressed") then
			if activate_option(hovered_entry.option) then
				self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
			end
		end
	end
end

HudElementCommandWheel._on_wheel_start = function(self, t, input_service)
	self._wheel_context = self._wheel_context or {}
	self._wheel_context.input_start_time = t
end

HudElementCommandWheel._on_wheel_stop = function(self, t, ui_renderer, render_settings, input_service)
	local wheel_context = self._wheel_context or {}
	wheel_context.input_start_time = nil
	
	local was_active = self._wheel_active
	
	if was_active or self._close_delay then
		self:_pop_cursor()
	end

	self._wheel_active = false
	self._close_delay = nil
	

	mod.dragged_entry = nil
	mod.dragged_index = nil
	self:_reset_drag_visual_feedback()

	if was_active and UISoundEvents.emote_wheel_close then
		Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_close)
	end
end


HudElementCommandWheel.using_input = function(self)
	return self._wheel_active
end

HudElementCommandWheel._push_cursor = function(self)
	local input_manager = Managers.input
	local name = self.__class_name
	local position = Vector3(0.5, 0.5, 0)

	input_manager:push_cursor(name)
	input_manager:set_cursor_position(name, position)

	self._cursor_pushed = true
end

HudElementCommandWheel._pop_cursor = function(self)
	if self._cursor_pushed then
		local input_manager = Managers.input
		local name = self.__class_name

		input_manager:pop_cursor(name)

		self._cursor_pushed = false
	end
end

HudElementCommandWheel._update_drag_visual_feedback = function(self, hovered_index)
	local entries = self._entries
	local drag_offset = 30

	for i, entry in ipairs(entries) do
		local widget = entry.widget
		local style = widget.style
		local icon_style = style.icon
		local highlight_style = style.slice_highlight
		local slice_style = style.slice

		if i == hovered_index and entry.option then
			local angle = entry.widget.content.angle or 0
			local offset_x = math.sin(angle) * drag_offset
			local offset_y = math.cos(angle) * drag_offset

			apply_style_offset(icon_style, offset_x, offset_y)
			apply_style_offset(highlight_style, offset_x, offset_y)
			apply_style_offset(slice_style, offset_x, offset_y)

			local hover_color = CommandWheelSettings.button_color_hover or {220, 0, 0, 0}
			local bright_color = {math.min(255, hover_color[1] + 30), hover_color[2], hover_color[3], hover_color[4]}
			apply_style_color(highlight_style, bright_color)
			apply_style_color(slice_style, bright_color)
		else
			apply_style_offset(icon_style, 0, 0)
			apply_style_offset(highlight_style, 0, 0)
			apply_style_offset(slice_style, 0, 0)

			local default_color = CommandWheelSettings.button_color_default or {190, 0, 0, 0}
			local dimmed_color = {math.max(50, default_color[1] - 140), default_color[2], default_color[3], default_color[4]}
			apply_style_color(highlight_style, dimmed_color)
			apply_style_color(slice_style, dimmed_color)
		end
	end
end

HudElementCommandWheel._reset_drag_visual_feedback = function(self)
	local entries = self._entries

	for _, entry in ipairs(entries) do
		local widget = entry.widget
		local style = widget.style
		local icon_style = style.icon
		local highlight_style = style.slice_highlight
		local slice_style = style.slice

		apply_style_offset(icon_style, 0, 0)
		apply_style_offset(highlight_style, 0, 0)
		apply_style_offset(slice_style, 0, 0)

		local default_color = CommandWheelSettings.button_color_default or {190, 0, 0, 0}
		apply_style_color(highlight_style, default_color)
		apply_style_color(slice_style, default_color)
	end
end

HudElementCommandWheel._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	local active_progress = self._wheel_active_progress


	if active_progress == 0 then
		return
	end


	render_settings.alpha_multiplier = active_progress


	local entries = self._entries

	if entries then
		for i = 1, #entries do
			local entry = entries[i]
			local widget = entry.widget

			UIWidget.draw(widget, ui_renderer)

			if widget.content.hotspot.is_hover then
				local hover_data = self._last_widget_hover_data

				hover_data.t = t
				hover_data.index = i
			end
		end
	end


	HudElementCommandWheel.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

return HudElementCommandWheel
