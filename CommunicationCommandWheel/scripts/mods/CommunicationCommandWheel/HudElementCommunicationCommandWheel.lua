local mod = get_mod("CommunicationCommandWheel")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")

local CommunicationCommandWheelSettings = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_settings")

local Definitions = mod:io_dofile("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_definitions")
local Utils = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_utils")
local Buttons = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_buttons")
local Pages = require("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_pages")
local InputDevice = require("scripts/managers/input/input_device")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Vector3 = Vector3
local RESOLUTION_LOOKUP = RESOLUTION_LOOKUP

local is_in_valid_lvl = function()
	if Managers and Managers.state and Managers.state.game_mode then
		local game_mode_name = Managers.state.game_mode:game_mode_name()

		return game_mode_name ~= nil
	end

	return false
end

local localize_text = Utils.localize_text
local activate_option = Utils.activate_option
local apply_style_offset = Utils.apply_style_offset
local apply_style_color = Utils.apply_style_color

local button_definitions_by_id = Buttons.button_definitions_by_id

local function ccw_read_mouse_wheel_axis_z()
	local im = Managers and Managers.input

	if not im or not im._find_active_device then
		return nil
	end

	local mouse = im:_find_active_device("mouse")

	if not mouse then
		return nil
	end

	local idx = mouse:axis_index("wheel")

	if not idx then
		return nil
	end

	local raw = mouse:raw_device()

	if not raw or type(raw.axis) ~= "function" then
		return nil
	end

	local v = raw:axis(idx)

	if v == nil then
		return nil
	end

	if type(v) == "number" then
		return v
	end

	if v.z ~= nil then
		return v.z
	end

	if v[3] ~= nil then
		return v[3]
	end

	return nil
end

local function ccw_input_action_truthy(input_service, action_name)
	if not input_service or type(input_service.has) ~= "function" then
		return false
	end

	if not input_service:has(action_name) then
		return false
	end

	local v = input_service:get(action_name)

	if v == nil then
		return false
	end

	if type(v) == "boolean" then
		return v
	end

	if type(v) == "number" then
		return v ~= 0
	end

	return not not v
end

local function ccw_largest_scroll_axis_component(scroll_axis)
	if not scroll_axis then
		return 0
	end

	local x = scroll_axis.x or scroll_axis[1] or 0
	local y = scroll_axis.y or scroll_axis[2] or 0
	local z = scroll_axis.z or scroll_axis[3] or 0
	local best = x

	if math.abs(y) > math.abs(best) then
		best = y
	end

	if math.abs(z) > math.abs(best) then
		best = z
	end

	return best
end

local function communication_wheel_open_hold_delay_seconds()
	local v = mod:get("communication_wheel_open_hold_delay_sec")

	if type(v) == "number" and v == v and v >= 0 then
		if v <= 2 then
			return v
		end

		return v * 0.001
	end

	v = CommunicationCommandWheelSettings.open_hold_delay_seconds

	if type(v) == "number" and v >= 0 then
		return v
	end

	return 0.1
end

local function communication_wheel_apply_icon_style_size(widget, option)
	if not widget or not widget.style or not widget.style.icon then
		return
	end

	local icon_style = widget.style.icon
	local square = CommunicationCommandWheelSettings.icon_size_square

	if type(square) ~= "table" or type(square[1]) ~= "number" or type(square[2]) ~= "number" then
		square = {
			96,
			96,
		}
	end

	local w = square[1]
	local h = square[2]

	icon_style.size[1] = w
	icon_style.size[2] = h

	if icon_style.default_size then
		icon_style.default_size[1] = w
		icon_style.default_size[2] = h
	end
end

local CONFIGURED_SLOT_COUNT = Pages and Pages.CONFIGURED_SLOT_COUNT or 8
local MAX_WHEEL_PAGES = Pages and Pages.MAX_PAGES or 3
local CCW_INGAME_INPUT_SERVICE = "Ingame"

local function page_slot_setting_id(page_index, slot_index)
	return string.format("page_%d_slot_%d", page_index, slot_index)
end

local function generate_options_from_page(current_page)
	local options = {}
	local wheel_slots = CommunicationCommandWheelSettings.wheel_slots
	local max_slot = math.min(wheel_slots, CONFIGURED_SLOT_COUNT)

	for slot_index = 1, max_slot do
		local raw = mod:get(page_slot_setting_id(current_page, slot_index))
		local command_id = type(raw) == "string" and raw or ""

		if command_id ~= "" and button_definitions_by_id and button_definitions_by_id[command_id] then
			options[slot_index] = button_definitions_by_id[command_id]
		end
	end

	return options
end

local function page_has_any_filled_slot(page_index)
	local wheel_slots = CommunicationCommandWheelSettings.wheel_slots
	local max_slot = math.min(wheel_slots, CONFIGURED_SLOT_COUNT)

	for slot_index = 1, max_slot do
		local raw = mod:get(page_slot_setting_id(page_index, slot_index))
		local command_id = type(raw) == "string" and raw or ""

		if command_id ~= "" and button_definitions_by_id and button_definitions_by_id[command_id] then
			return true
		end
	end

	return false
end

local function build_visible_page_numbers()
	local list = {}

	for page_index = 1, MAX_WHEEL_PAGES do
		if page_has_any_filled_slot(page_index) then
			list[#list + 1] = page_index
		end
	end

	return list
end

local function visible_pages_contains(visible_pages, page_num)
	for i = 1, #visible_pages do
		if visible_pages[i] == page_num then
			return true
		end
	end

	return false
end

local _communication_wheel_cursor_seq = 0

local HudElementCommunicationCommandWheel = class("HudElementCommunicationCommandWheel", "HudElementBase")

HudElementCommunicationCommandWheel.init = function(self, parent, draw_layer, start_scale)
	HudElementCommunicationCommandWheel.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._wheel_active_progress = 0
	self._wheel_active = false
	self._entries = {}
	self._last_widget_hover_data = {
		index = nil,
		t = nil,
	}
	self._wheel_context = {}
	self._close_delay = nil
	self._controller_stick_moved = false
	self._cursor_pushed = false
	self._center_switch_zone_hovered = false
	self._ccw_wants_camera_prev = false
	self._ccw_page_scroll_cooldown_until = nil
	self._ccw_last_mouse_wheel_z = nil
	self._ccw_switch_page_key_prev_held = false
	self._ccw_wield_scroll_reserved = false

	_communication_wheel_cursor_seq = _communication_wheel_cursor_seq + 1
	self._cursor_reference = "HudElementCommunicationCommandWheel_" .. tostring(_communication_wheel_cursor_seq)

	self._current_page = 1
	self._max_pages = MAX_WHEEL_PAGES
	self._visible_pages = {}

	local wheel_slots = CommunicationCommandWheelSettings.wheel_slots

	self:_setup_entries(wheel_slots)
	self:_ensure_current_page_visible()

	local options = generate_options_from_page(self._current_page)

	self:_populate_wheel(options)

	self._wheel_background_widget = self._widgets_by_name.wheel_background
	self._page_indicators_widget = self._widgets_by_name.page_indicators

	self:_sync_page_indicators()
end

HudElementCommunicationCommandWheel._rebuild_visible_pages = function(self)
	self._visible_pages = build_visible_page_numbers()
end

HudElementCommunicationCommandWheel._ensure_current_page_visible = function(self)
	self:_rebuild_visible_pages()

	local visible = self._visible_pages or {}

	if #visible > 0 then
		if not visible_pages_contains(visible, self._current_page) then
			self._current_page = visible[1]
		end
	else
		self._current_page = 1
	end
end

HudElementCommunicationCommandWheel._sync_page_indicators = function(self)
	if self._page_indicators_widget then
		for i = 1, self._max_pages do
			local style = self._page_indicators_widget.style["page_" .. i]

			if style then
				if i == self._current_page then
					style.color = {
						255,
						255,
						255,
						255,
					}
				else
					style.color = {
						150,
						150,
						150,
						150,
					}
				end
			end
		end
	end
end

HudElementCommunicationCommandWheel._refresh_wheel_layout_from_settings = function(self)
	self:_ensure_current_page_visible()

	local options = generate_options_from_page(self._current_page)

	self:_populate_wheel(options)
	self:_sync_page_indicators()

	if self._wheel_active then
		self:_ccw_sync_wield_scroll_input_capture()
	end
end

HudElementCommunicationCommandWheel._ccw_wants_capture_wield_scroll = function(self)
	local v = mod:get("ccw_scroll_switch_page")

	if v ~= true and v ~= 1 then
		return false
	end

	local visible = self._visible_pages or {}

	return #visible > 1
end

HudElementCommunicationCommandWheel._ccw_clear_wield_scroll_input_capture = function(self)
	if not self._ccw_wield_scroll_reserved then
		return
	end

	local ui = Managers and Managers.ui

	if ui and ui.remove_inputs_in_use_by_ui then
		ui:remove_inputs_in_use_by_ui("wield_scroll_down", CCW_INGAME_INPUT_SERVICE)
		ui:remove_inputs_in_use_by_ui("wield_scroll_up", CCW_INGAME_INPUT_SERVICE)
	end

	self._ccw_wield_scroll_reserved = false
end

HudElementCommunicationCommandWheel._ccw_sync_wield_scroll_input_capture = function(self)
	local ui = Managers and Managers.ui

	if not ui or not ui.add_inputs_in_use_by_ui or not ui.remove_inputs_in_use_by_ui then
		return
	end

	local want = self:_ccw_wants_capture_wield_scroll()

	if want and not self._ccw_wield_scroll_reserved then
		ui:add_inputs_in_use_by_ui("wield_scroll_down", CCW_INGAME_INPUT_SERVICE)
		ui:add_inputs_in_use_by_ui("wield_scroll_up", CCW_INGAME_INPUT_SERVICE)
		self._ccw_wield_scroll_reserved = true
	elseif not want and self._ccw_wield_scroll_reserved then
		ui:remove_inputs_in_use_by_ui("wield_scroll_down", CCW_INGAME_INPUT_SERVICE)
		ui:remove_inputs_in_use_by_ui("wield_scroll_up", CCW_INGAME_INPUT_SERVICE)
		self._ccw_wield_scroll_reserved = false
	end
end

HudElementCommunicationCommandWheel._setup_entries = function(self, num_entries)
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

HudElementCommunicationCommandWheel._populate_wheel = function(self, options)
	local entries = self._entries
	local wheel_slots = CommunicationCommandWheelSettings.wheel_slots

	for i = 1, wheel_slots do
		local option = options[i]
		local entry = entries[i]

		if entry then
			local widget = entry.widget
			local content = widget.content

			content.visible = option ~= nil
			entry.option = option

			if option then
				local icon_path = option.icon or "content/ui/materials/base/ui_default_base"

				content.icon = icon_path

				local icon_style = widget.style and widget.style.icon

				if icon_style and icon_style.material_values then
					icon_style.material_values.texture_map = nil
					icon_style.material_values.use_placeholder_texture = nil
				end

				content.text = localize_text(option.label_key)
				communication_wheel_apply_icon_style_size(widget, option)
				widget.dirty = true
			end
		end
	end
end

HudElementCommunicationCommandWheel.switch_page = function(self, direction)
	direction = direction or 1

	local visible = self._visible_pages or {}

	if #visible <= 1 then
		return
	end

	local idx = 1

	for i = 1, #visible do
		if visible[i] == self._current_page then
			idx = i

			break
		end
	end

	idx = idx + direction

	if idx > #visible then
		idx = 1
	elseif idx < 1 then
		idx = #visible
	end

	self._current_page = visible[idx]

	local options = generate_options_from_page(self._current_page)

	self:_populate_wheel(options)
	self:_sync_page_indicators()

	if UISoundEvents.emote_wheel_open then
		Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
	end
end

HudElementCommunicationCommandWheel._reset_hover_state = function(self)
	for i = 1, #self._entries do
		local entry = self._entries[i]

		if entry and entry.widget then
			entry.widget.content.hotspot.force_hover = false
		end
	end

	if self._wheel_background_widget then
		self._wheel_background_widget.content.force_hover = false
		self._wheel_background_widget.style.mark.color[1] = 0
	end

	self._center_switch_zone_hovered = false
	self._ccw_last_mouse_wheel_z = nil
	self._ccw_switch_page_key_prev_held = false

	self._last_widget_hover_data.index = nil
	self._last_widget_hover_data.t = nil
end

HudElementCommunicationCommandWheel._ccw_sync_switch_page_key_baseline = function(self)
	if mod._is_switch_page_key_held then
		self._ccw_switch_page_key_prev_held = mod._is_switch_page_key_held()
	else
		self._ccw_switch_page_key_prev_held = false
	end
end

HudElementCommunicationCommandWheel._ccw_try_scroll_switch_page = function(self, t, input_service)
	local v = mod:get("ccw_scroll_switch_page")

	if v ~= true and v ~= 1 then
		return false
	end

	local visible_pages = self._visible_pages or {}

	if #visible_pages <= 1 then
		return false
	end

	local cooldown_until = self._ccw_page_scroll_cooldown_until

	if cooldown_until and t < cooldown_until then
		return false
	end

	local direction = 0

	if input_service and input_service.has and input_service:has("scroll_axis") then
		local scroll_axis = input_service:get("scroll_axis")
		local mag = ccw_largest_scroll_axis_component(scroll_axis)

		if math.abs(mag) > 0.1 then
			direction = mag > 0 and -1 or 1
		end
	end

	if direction == 0 then
		local ingame_ok, ingame = pcall(function()
			return Managers.input:get_input_service("Ingame")
		end)

		if ingame_ok and ingame and type(ingame.has) == "function" then
			if ingame:has("wield_scroll_up") and ccw_input_action_truthy(ingame, "wield_scroll_up") then
				direction = -1
			elseif ingame:has("wield_scroll_down") and ccw_input_action_truthy(ingame, "wield_scroll_down") then
				direction = 1
			end
		end
	end

	if direction == 0 and input_service then
		if ccw_input_action_truthy(input_service, "wield_scroll_up") then
			direction = -1
		elseif ccw_input_action_truthy(input_service, "wield_scroll_down") then
			direction = 1
		end
	end

	if direction == 0 then
		local z = ccw_read_mouse_wheel_axis_z()

		if z ~= nil then
			local last_z = self._ccw_last_mouse_wheel_z

			self._ccw_last_mouse_wheel_z = z

			if last_z ~= nil then
				local dz = z - last_z

				if dz > 0.5 then
					direction = -1
				elseif dz < -0.5 then
					direction = 1
				end
			end
		end
	end

	if direction == 0 then
		return false
	end

	self._ccw_page_scroll_cooldown_until = t + 0.12
	self:switch_page(direction)

	return true
end

HudElementCommunicationCommandWheel.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementCommunicationCommandWheel.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	if rawget(_G, "PLATFORM") == "win32" and self._cursor_pushed and Managers.input then
		local ok, cursor_stack_active = pcall(function()
			return Managers.input:cursor_active()
		end)

		if ok and cursor_stack_active == false then
			self._cursor_pushed = false
		end
	end

	self:_update_active_progress(dt)
	self:_update_widget_locations()

	if self._wheel_active then
		self:_update_wheel_presentation(dt, t, ui_renderer, render_settings, input_service)
	end

	self:_handle_input(t, dt, ui_renderer, render_settings, input_service)

	local wants_camera = self._wheel_active or self._close_delay ~= nil

	if wants_camera ~= self._ccw_wants_camera_prev then
		if wants_camera then
			Managers.event:trigger("event_set_communication_wheel_state", "camera_lock")
		else
			Managers.event:trigger("event_set_communication_wheel_state", false)
		end

		self._ccw_wants_camera_prev = wants_camera
	end
end

HudElementCommunicationCommandWheel._update_active_progress = function(self, dt)
	local active = self._wheel_active
	local anim_speed = CommunicationCommandWheelSettings.anim_speed
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

	if self._page_indicators_widget then
		self._page_indicators_widget.visible = progress > 0
	end
end

HudElementCommunicationCommandWheel._update_widget_locations = function(self)
	local entries = self._entries
	local start_angle = math.pi / 2
	local num_entries = #entries
	local radians_per_widget = math.pi * 2 / num_entries
	local active_progress = self._wheel_active_progress
	local anim_progress = math.smoothstep(active_progress, 0, 1)
	local wheel_slots = CommunicationCommandWheelSettings.wheel_slots
	local min_radius = CommunicationCommandWheelSettings.min_radius
	local max_radius = CommunicationCommandWheelSettings.max_radius
	local radius = min_radius + anim_progress * (max_radius - min_radius)

	if num_entries == 0 or wheel_slots == 0 then
		return
	end

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

HudElementCommunicationCommandWheel._update_wheel_presentation = function(self, dt, t, ui_renderer, render_settings, input_service)
	self._center_switch_zone_hovered = false

	if not input_service or type(input_service.has) ~= "function" then
		return
	end

	local screen_width, screen_height = RESOLUTION_LOOKUP.width, RESOLUTION_LOOKUP.height
	local scale = render_settings.scale
	local cursor = nil

	if input_service and InputDevice.gamepad_active then
		local controller_input = input_service:get("navigate_controller_right")

		if not controller_input or (math.abs(controller_input[1]) < 0.01 and math.abs(controller_input[2]) < 0.01) then
			controller_input = input_service:get("navigate_controller")
		end

		if controller_input and (math.abs(controller_input[1]) > 0.01 or math.abs(controller_input[2]) > 0.01) then
			self._controller_stick_moved = true
			cursor = {
				screen_width * 0.5 + controller_input[1] * screen_width * 0.5,
				screen_height * 0.5 - controller_input[2] * screen_height * 0.5,
				0,
			}
		else
			if self._controller_stick_moved then
				self:_reset_hover_state()
			end

			return
		end
	else
		cursor = input_service and input_service:get("cursor")
	end

	if not cursor then
		return
	end

	local cursor_distance_from_center = math.distance_2d(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2])
	local cursor_angle_from_center = math.angle(screen_width * 0.5, screen_height * 0.5, cursor[1], cursor[2]) - math.pi * 0.5
	local cursor_angle_degrees_from_center = math.radians_to_degrees(cursor_angle_from_center) % 360

	local hover_min_distance = CommunicationCommandWheelSettings.hover_min_distance or 130
	local entry_hover_degrees = CommunicationCommandWheelSettings.hover_angle_degrees or 44
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

	local center_x = screen_width * 0.5
	local center_y = screen_height * 0.5
	local center_radius = 60
	local distance_to_center = math.distance_2d(center_x, center_y, cursor[1], cursor[2])
	local center_button_hover = distance_to_center <= center_radius * scale

	local visible_pages = self._visible_pages or {}

	self._center_switch_zone_hovered = center_button_hover and #visible_pages > 1

	local wheel_background_widget = self._wheel_background_widget

	if wheel_background_widget then
		if any_hover then
			wheel_background_widget.content.angle = cursor_angle_from_center
		end

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
		elseif center_button_hover and #visible_pages > 1 then
			wheel_background_widget.content.text = localize_text("ccw_page_switch")
		elseif not any_hover then
			wheel_background_widget.content.text = ""
		end
	end
end

HudElementCommunicationCommandWheel._is_wheel_entry_hovered = function(self, t)
	local entries = self._entries

	for i = 1, #entries do
		local entry = entries[i]
		local widget = entry.widget
		local hotspot = widget.content.hotspot
		local hovered = entry.option ~= nil and (hotspot.is_hover or hotspot.force_hover)

		if hovered then
			self._last_widget_hover_data.index = i
			self._last_widget_hover_data.t = t

			return entry, i
		end
	end

	if InputDevice.gamepad_active and not self._controller_stick_moved then
		return nil, nil
	end

	local last_hover = self._last_widget_hover_data
	local hover_grace_period = CommunicationCommandWheelSettings.hover_grace_period or 0.4

	if last_hover.t and t < last_hover.t + hover_grace_period then
		local i = last_hover.index

		return entries[i], i
	end
end

HudElementCommunicationCommandWheel._is_center_switch_zone_active = function(self)
	return self._center_switch_zone_hovered == true
end

HudElementCommunicationCommandWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
	if self._close_delay then
		self._close_delay = self._close_delay - dt

		if self._close_delay <= 0 then
			self._close_delay = nil
			self:_pop_cursor()
			self:_reset_hover_state()
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
		input_pressed = mod:_is_communication_wheel_key_pressed()
	end

	local wheel_context = self._wheel_context
	local start_time = wheel_context.input_start_time

	if input_pressed and not start_time then
		self:_on_wheel_start(t, input_service)
	elseif not input_pressed and start_time then
		local hovered_entry = self:_is_wheel_entry_hovered(t)

		if hovered_entry then
			activate_option(hovered_entry.option)
		end

		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
	end

	local draw_wheel = false

	start_time = wheel_context.input_start_time

	if start_time then
		draw_wheel = self._wheel_active

		if not draw_wheel then
			local hold_delay = communication_wheel_open_hold_delay_seconds()

			if hold_delay <= 0 then
				draw_wheel = input_pressed
			elseif t > start_time + hold_delay then
				draw_wheel = true
			end
		end
	end

	if draw_wheel and not self._wheel_active then
		self._wheel_active = true
		self._controller_stick_moved = false
		self:_reset_hover_state()
		self:_ccw_sync_switch_page_key_baseline()

		self:_ensure_current_page_visible()

		local options = generate_options_from_page(self._current_page)

		self:_populate_wheel(options)
		self:_sync_page_indicators()

		if UISoundEvents.emote_wheel_open then
			Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
		end

		if not InputDevice.gamepad_active then
			self:_push_cursor()
		end

		self:_ccw_sync_wield_scroll_input_capture()
	elseif not draw_wheel and self._wheel_active then
		self:_ccw_clear_wield_scroll_input_capture()
		self._wheel_active = false
		self._close_delay = InputDevice.gamepad_active and 0.15 or 0

		if self._close_delay == 0 then
			self:_reset_hover_state()
		end
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

	if self:_ccw_try_scroll_switch_page(t, input_service) then
		return
	end

	local visible_for_switch = self._visible_pages or {}

	if #visible_for_switch > 1 and mod._is_switch_page_key_held then
		local switch_held = mod._is_switch_page_key_held()
		local switch_prev = self._ccw_switch_page_key_prev_held

		self._ccw_switch_page_key_prev_held = switch_held

		if switch_held and not switch_prev then
			local cd_switch = self._ccw_page_scroll_cooldown_until

			if not cd_switch or t >= cd_switch then
				self:switch_page(1)
				self._ccw_page_scroll_cooldown_until = t + 0.12

				return
			end
		end
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

	if not right_mouse_held and input_service and type(input_service.has) == "function" then
		if self:_is_center_switch_zone_active() then
			local center_activate = false

			if input_service:has("left_pressed") and input_service:get("left_pressed") then
				center_activate = true
			elseif InputDevice.gamepad_active and input_service:has("gamepad_confirm_pressed") and input_service:get("gamepad_confirm_pressed") then
				center_activate = true
			end

			if center_activate then
				self:switch_page(1)

				return
			end
		end

		local hovered_entry = self:_is_wheel_entry_hovered(t)

		if hovered_entry then
			local should_activate = false

			if input_service:has("left_pressed") and input_service:get("left_pressed") then
				should_activate = true
			elseif InputDevice.gamepad_active and input_service:has("gamepad_confirm_pressed") and input_service:get("gamepad_confirm_pressed") then
				should_activate = true
			end

			if should_activate then
				local option = hovered_entry.option

				if activate_option(option) then
					self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
				end
			end
		end
	end
end

HudElementCommunicationCommandWheel._on_wheel_start = function(self, t, input_service)
	self._wheel_context = self._wheel_context or {}
	self._wheel_context.input_start_time = t
end

HudElementCommunicationCommandWheel._release_communication_wheel_cursor_and_flags = function(self, play_close_sound, snap_visible_progress)
	local wheel_context = self._wheel_context or {}

	wheel_context.input_start_time = nil

	self:_ccw_clear_wield_scroll_input_capture()

	local was_active = self._wheel_active

	if was_active or self._close_delay or self._cursor_pushed then
		self:_pop_cursor()
	end

	self._wheel_active = false
	self._close_delay = nil

	if snap_visible_progress then
		self._wheel_active_progress = 0
	end

	self._controller_stick_moved = false
	self._last_widget_hover_data.index = nil
	self._last_widget_hover_data.t = nil

	self:_reset_hover_state()
	self:_reset_slice_styles_default()

	if play_close_sound and was_active and Managers.ui and UISoundEvents.emote_wheel_close then
		Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_close)
	end
end

HudElementCommunicationCommandWheel._reset_slice_styles_default = function(self)
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

		local default_slice_color = {
			150,
			0,
			0,
			0,
		}

		apply_style_color(highlight_style, default_slice_color)
		apply_style_color(slice_style, default_slice_color)
	end
end

HudElementCommunicationCommandWheel._on_wheel_stop = function(self, t, ui_renderer, render_settings, input_service)
	self:_release_communication_wheel_cursor_and_flags(true, false)
end

HudElementCommunicationCommandWheel.destroy = function(self, ui_renderer)
	local wants_camera = self._wheel_active or self._close_delay ~= nil

	self:_release_communication_wheel_cursor_and_flags(false, true)

	if wants_camera then
		Managers.event:trigger("event_set_communication_wheel_state", false)
	end

	self._ccw_wants_camera_prev = false

	if mod._communication_wheel_element == self then
		mod._communication_wheel_element = nil
	end

	HudElementCommunicationCommandWheel.super.destroy(self, ui_renderer)
end

HudElementCommunicationCommandWheel.using_input = function(self)
	return false
end

HudElementCommunicationCommandWheel._push_cursor = function(self)
	local input_manager = Managers.input
	local reference = self._cursor_reference
	local position = Vector3(0.5, 0.5, 0)

	input_manager:push_cursor(reference)
	input_manager:set_cursor_position(reference, position)

	self._cursor_pushed = true
end

HudElementCommunicationCommandWheel._pop_cursor = function(self)
	if self._cursor_pushed then
		local input_manager = Managers.input
		local reference = self._cursor_reference

		input_manager:pop_cursor(reference)

		self._cursor_pushed = false
	end
end

HudElementCommunicationCommandWheel._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
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

	HudElementCommunicationCommandWheel.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

return HudElementCommunicationCommandWheel
