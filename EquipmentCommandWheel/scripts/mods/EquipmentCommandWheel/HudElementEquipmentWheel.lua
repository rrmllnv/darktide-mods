local mod = get_mod("EquipmentCommandWheel")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")

local EquipmentWheelSettings = require("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_settings")

local Definitions = mod:io_dofile("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_definitions")
local Utils = require("EquipmentCommandWheel/scripts/mods/EquipmentCommandWheel/EquipmentCommandWheel_utils")
local InputDevice = require("scripts/managers/input/input_device")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Vector3 = Vector3
local RESOLUTION_LOOKUP = RESOLUTION_LOOKUP
local FixedFrame = require("scripts/utilities/fixed_frame")
local Action = require("scripts/utilities/action/action")
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")

local collect_equipment_wheel_slots = Utils.collect_equipment_wheel_slots
local is_equipment_wheel_context_valid = Utils.is_equipment_wheel_context_valid
local localize_text = Utils.localize_text
local apply_style_offset = Utils.apply_style_offset
local apply_style_color = Utils.apply_style_color

local _equipment_wheel_cursor_seq = 0

local function equipment_entry_count(options_count, cap)
	local n = math.max(options_count, 1)

	if cap and n > cap then
		return cap
	end

	return n
end

local function equipment_wheel_wield_action_input_for_ability_slot(slot_id)
	if slot_id == "slot_grenade_ability" then
		return "grenade_ability"
	end

	if slot_id == "slot_combat_ability" then
		return "combat_ability"
	end

	return nil
end

local HudElementEquipmentWheel = class("HudElementEquipmentWheel", "HudElementBase")

HudElementEquipmentWheel.init = function(self, parent, draw_layer, start_scale)
	HudElementEquipmentWheel.super.init(self, parent, draw_layer, start_scale, Definitions)

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
	self._equipment_options = {}
	self._scan_delay_duration = 0
	self._last_entry_count = 0

	_equipment_wheel_cursor_seq = _equipment_wheel_cursor_seq + 1
	self._cursor_reference = "HudElementEquipmentWheel_" .. tostring(_equipment_wheel_cursor_seq)

	if is_equipment_wheel_context_valid(parent) then
		local extensions = parent:player_extensions()

		self._equipment_options = collect_equipment_wheel_slots(extensions)
	else
		self._equipment_options = {}
	end

	local cap = EquipmentWheelSettings.wheel_slots
	local n = equipment_entry_count(#self._equipment_options, cap)

	self._last_entry_count = n
	self:_setup_entries(n)
	self:_populate_wheel(self._equipment_options)

	self._wheel_background_widget = self._widgets_by_name.wheel_background
end

HudElementEquipmentWheel._sync_entries_to_option_count = function(self)
	local cap = EquipmentWheelSettings.wheel_slots
	local n = equipment_entry_count(#self._equipment_options, cap)

	if n ~= self._last_entry_count then
		self._last_entry_count = n
		self:_setup_entries(n)
	end

	self:_populate_wheel(self._equipment_options)
end

HudElementEquipmentWheel._try_wield_option = function(self, option, t)
	if not option or not option.slot_id then
		return false
	end

	local parent = self._parent

	if not is_equipment_wheel_context_valid(parent) then
		return false
	end

	local player = parent:player()
	local unit = player.player_unit
	local extensions = parent:player_extensions()
	local unit_data = extensions.unit_data
	local inventory = unit_data:read_component("inventory")
	local wielded_slot = inventory.wielded_slot

	if wielded_slot == option.slot_id then
		return true
	end

	local visual_loadout_extension = extensions.visual_loadout
	local weapon_extension = extensions.weapon

	if not visual_loadout_extension or not visual_loadout_extension.can_wield or not visual_loadout_extension:can_wield(option.slot_id) then
		return false
	end

	if not weapon_extension or not weapon_extension.can_wield or not weapon_extension:can_wield(option.slot_id) then
		return false
	end

	local wield_t = t
	local ok_fixed, fixed_t = pcall(function()
		return FixedFrame.get_latest_fixed_time()
	end)

	if ok_fixed and type(fixed_t) == "number" then
		wield_t = fixed_t
	elseif Managers and Managers.time then
		local ok_time, gameplay_t = pcall(function()
			return Managers.time:time("gameplay")
		end)

		if ok_time and type(gameplay_t) == "number" then
			wield_t = gameplay_t
		end
	end

	local input_extension = ScriptUnit.extension(unit, "input_system")
	local ability_extension = extensions.ability
	local used_input = nil
	local slot_cfg = PlayerUnitVisualLoadout.slot_config_from_slot_name(option.slot_id)
	local wield_inputs = slot_cfg and slot_cfg.wield_inputs

	if wield_inputs and input_extension then
		for ii = 1, #wield_inputs do
			local candidate = wield_inputs[ii]
			local resolved_slot = PlayerUnitVisualLoadout.slot_name_from_wield_input(candidate, inventory, visual_loadout_extension, weapon_extension, ability_extension, input_extension)

			if resolved_slot == option.slot_id then
				used_input = candidate

				break
			end
		end
	end

	if not used_input and wield_inputs then
		used_input = PlayerUnitVisualLoadout.wield_input_from_slot_name(option.slot_id)
	end

	local wielded_weapon = weapon_extension:_wielded_weapon(inventory, weapon_extension._weapons)
	local weapon_action_component = unit_data:read_component("weapon_action")
	local has_running_weapon_action = weapon_action_component and weapon_action_component.current_action_name ~= "none"

	local function play_select_sound()
		if Managers.ui and UISoundEvents.weapons_select_weapon then
			Managers.ui:play_2d_sound(UISoundEvents.weapons_select_weapon)
		end
	end

	local function wield_slot_direct()
		local ok = pcall(function()
			PlayerUnitVisualLoadout.wield_slot(option.slot_id, unit, wield_t)
		end)

		if ok then
			play_select_sound()
		end

		return ok
	end

	if wielded_slot == "none" or not wielded_weapon then
		return wield_slot_direct()
	end

	local ability_wield_action_input = equipment_wheel_wield_action_input_for_ability_slot(option.slot_id)

	if ability_wield_action_input then
		local handler = weapon_extension._action_handler
		local actions = wielded_weapon.weapon_template and wielded_weapon.weapon_template.actions

		if handler and actions and handler._valid_action_from_action_input then
			local condition_func_params = weapon_extension:condition_func_params(wielded_slot)
			local ability_action_name, ability_action_settings = handler:_valid_action_from_action_input(actions, ability_wield_action_input, wield_t, condition_func_params, nil)

			if ability_action_name and ability_action_settings and weapon_extension.action_input_is_currently_valid and weapon_extension:action_input_is_currently_valid("weapon_action", ability_wield_action_input, nil, wield_t) then
				local ability_transition = has_running_weapon_action and "chain" or "start"
				local ok_ability = pcall(function()
					weapon_extension:_start_action(ability_action_name, ability_action_settings, wield_t, nil, ability_transition)
				end)

				if ok_ability then
					play_select_sound()

					return true
				end
			end
		end

		return false
	end

	if not used_input then
		return false
	end

	local weapon_template = wielded_weapon.weapon_template
	local action_settings = weapon_template and Action.action_settings(weapon_template, "action_unwield")

	if not action_settings then
		return wield_slot_direct()
	end

	local start_input = action_settings.start_input

	if not start_input then
		return wield_slot_direct()
	end

	if not weapon_extension.action_input_is_currently_valid or not weapon_extension:action_input_is_currently_valid("weapon_action", start_input, used_input, wield_t) then
		return false
	end

	local transition_type = has_running_weapon_action and "chain" or "start"
	local ok_start = pcall(function()
		weapon_extension:_start_action("action_unwield", action_settings, wield_t, used_input, transition_type)
	end)

	if not ok_start then
		return false
	end

	play_select_sound()

	return true
end

HudElementEquipmentWheel._reset_hover_state = function(self)
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

	self._last_widget_hover_data.index = nil
	self._last_widget_hover_data.t = nil
end

HudElementEquipmentWheel._setup_entries = function(self, num_entries)
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

HudElementEquipmentWheel._populate_wheel = function(self, options)
	local entries = self._entries
	local num_entries = #entries

	for i = 1, num_entries do
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
				widget.dirty = true
			end
		end
	end
end

HudElementEquipmentWheel.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementEquipmentWheel.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	if not is_equipment_wheel_context_valid(self._parent) then
		local wheel_context = self._wheel_context
		local pending_open = wheel_context and wheel_context.input_start_time ~= nil

		if self._wheel_active or self._close_delay or self._cursor_pushed or pending_open then
			self:_release_equipment_wheel_cursor_and_flags(false, true)
		end
	elseif rawget(_G, "PLATFORM") == "win32" and self._cursor_pushed and Managers.input then
		local ok, cursor_stack_active = pcall(function()
			return Managers.input:cursor_active()
		end)

		if ok and cursor_stack_active == false then
			self._cursor_pushed = false
		end
	end

	local scan_delay = EquipmentWheelSettings.scan_delay or 0

	if scan_delay > 0 then
		if self._scan_delay_duration > 0 then
			self._scan_delay_duration = self._scan_delay_duration - dt
		else
			if is_equipment_wheel_context_valid(self._parent) then
				local extensions = self._parent:player_extensions()

				self._equipment_options = collect_equipment_wheel_slots(extensions)
			else
				self._equipment_options = {}
			end

			self._scan_delay_duration = scan_delay

			if self._wheel_active or self._wheel_active_progress > 0 then
				self:_sync_entries_to_option_count()
			end
		end
	else
		if is_equipment_wheel_context_valid(self._parent) then
			local extensions = self._parent:player_extensions()
			local new_opts = collect_equipment_wheel_slots(extensions)
			local changed = #new_opts ~= #self._equipment_options

			if not changed then
				for i = 1, #new_opts do
					local a = new_opts[i]
					local b = self._equipment_options[i]

					if not b or a.slot_id ~= b.slot_id then
						changed = true
						break
					end
				end
			end

			if changed then
				self._equipment_options = new_opts

				if self._wheel_active or self._wheel_active_progress > 0 then
					self:_sync_entries_to_option_count()
				end
			end
		else
			self._equipment_options = {}
		end
	end

	self:_update_active_progress(dt)
	self:_update_widget_locations()

	if self._wheel_active then
		self:_update_wheel_presentation(dt, t, ui_renderer, render_settings, input_service)
	end

	self:_handle_input(t, dt, ui_renderer, render_settings, input_service)
end

HudElementEquipmentWheel._update_active_progress = function(self, dt)
	local active = self._wheel_active
	local anim_speed = EquipmentWheelSettings.anim_speed
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

HudElementEquipmentWheel._update_widget_locations = function(self)
	local entries = self._entries
	local start_angle = math.pi / 2
	local num_entries = #entries

	if num_entries == 0 then
		return
	end

	local radians_per_widget = math.pi * 2 / num_entries
	local active_progress = self._wheel_active_progress
	local anim_progress = math.smoothstep(active_progress, 0, 1)
	local min_radius = EquipmentWheelSettings.min_radius
	local max_radius = EquipmentWheelSettings.max_radius
	local radius = min_radius + anim_progress * (max_radius - min_radius)

	for i = 1, num_entries do
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

HudElementEquipmentWheel._update_wheel_presentation = function(self, dt, t, ui_renderer, render_settings, input_service)
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

	local hover_min_distance = EquipmentWheelSettings.hover_min_distance or 121
	local entry_hover_degrees = EquipmentWheelSettings.hover_angle_degrees or 44
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

HudElementEquipmentWheel._is_wheel_entry_hovered = function(self, t)
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

	if InputDevice.gamepad_active and not self._controller_stick_moved then
		return nil, nil
	end

	local last_hover = self._last_widget_hover_data
	local hover_grace_period = EquipmentWheelSettings.hover_grace_period or 0.4

	if last_hover.t and t < last_hover.t + hover_grace_period then
		local i = last_hover.index

		return entries[i], i
	end
end

HudElementEquipmentWheel._has_any_equipment_option = function(self)
	return #self._equipment_options > 0
end

HudElementEquipmentWheel._handle_input = function(self, t, dt, ui_renderer, render_settings, input_service)
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

	if is_equipment_wheel_context_valid(self._parent) and self:_has_any_equipment_option() then
		input_pressed = mod:_is_equipment_wheel_key_pressed()
	end

	local wheel_context = self._wheel_context
	local start_time = wheel_context.input_start_time

	if input_pressed and not start_time then
		self:_on_wheel_start(t, input_service)
	elseif not input_pressed and start_time then
		local hovered_entry = self:_is_wheel_entry_hovered(t)

		if hovered_entry then
			local option = hovered_entry.option

			self:_try_wield_option(option, t)
		end

		self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
	end

	local draw_wheel = false

	start_time = wheel_context.input_start_time

	if start_time then
		draw_wheel = self._wheel_active
		local always_draw_t = start_time + 0.1

		if always_draw_t < t then
			draw_wheel = true
		end
	end

	if draw_wheel and not self._wheel_active then
		self:_sync_entries_to_option_count()

		if not self:_has_any_equipment_option() then
			wheel_context.input_start_time = nil

			return
		end

		self._wheel_active = true
		self._controller_stick_moved = false
		self:_reset_hover_state()

		self:_populate_wheel(self._equipment_options)

		if UISoundEvents.emote_wheel_open then
			Managers.ui:play_2d_sound(UISoundEvents.emote_wheel_open)
		end

		if not InputDevice.gamepad_active then
			self:_push_cursor()
		end
	elseif not draw_wheel and self._wheel_active then
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

	if input_service and type(input_service.has) == "function" then
		local hovered_entry = self:_is_wheel_entry_hovered(t)

		if hovered_entry then
			local should_activate = false

			if input_service:has("left_pressed") and input_service:get("left_pressed") then
				should_activate = true
			elseif InputDevice.gamepad_active and input_service:has("gamepad_confirm_pressed") and input_service:get("gamepad_confirm_pressed") then
				should_activate = true
			end

			if should_activate then
				if self:_try_wield_option(hovered_entry.option, t) then
					self:_on_wheel_stop(t, ui_renderer, render_settings, input_service)
				end
			end
		end
	end
end

HudElementEquipmentWheel._on_wheel_start = function(self, t, input_service)
	self._wheel_context = self._wheel_context or {}
	self._wheel_context.input_start_time = t
end

HudElementEquipmentWheel._release_equipment_wheel_cursor_and_flags = function(self, play_close_sound, snap_visible_progress)
	local wheel_context = self._wheel_context or {}

	wheel_context.input_start_time = nil

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

HudElementEquipmentWheel._reset_slice_styles_default = function(self)
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

		local default_color = EquipmentWheelSettings.button_color_default or {190, 0, 0, 0}

		apply_style_color(highlight_style, default_color)
		apply_style_color(slice_style, default_color)
	end
end

HudElementEquipmentWheel._on_wheel_stop = function(self, t, ui_renderer, render_settings, input_service)
	self:_release_equipment_wheel_cursor_and_flags(true, false)
end

HudElementEquipmentWheel.destroy = function(self, ui_renderer)
	self:_release_equipment_wheel_cursor_and_flags(false, true)

	if mod._equipment_wheel_element == self then
		mod._equipment_wheel_element = nil
	end

	HudElementEquipmentWheel.super.destroy(self, ui_renderer)
end

HudElementEquipmentWheel.using_input = function(self)
	return self._wheel_active
end

HudElementEquipmentWheel._push_cursor = function(self)
	local input_manager = Managers.input
	local reference = self._cursor_reference
	local position = Vector3(0.5, 0.5, 0)

	input_manager:push_cursor(reference)
	input_manager:set_cursor_position(reference, position)

	self._cursor_pushed = true
end

HudElementEquipmentWheel._pop_cursor = function(self)
	if self._cursor_pushed then
		local input_manager = Managers.input
		local reference = self._cursor_reference

		input_manager:pop_cursor(reference)

		self._cursor_pushed = false
	end
end

HudElementEquipmentWheel._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
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

	HudElementEquipmentWheel.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

return HudElementEquipmentWheel
