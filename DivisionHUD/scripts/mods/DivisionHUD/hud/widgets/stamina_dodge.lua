local HudElementStaminaSettings = require("scripts/ui/hud/elements/blocking/hud_element_stamina_settings")
local HudElementDodgeCounterSettings = require("scripts/ui/hud/elements/dodge_counter/hud_element_dodge_counter_settings")
local Stamina = require("scripts/utilities/attack/stamina")
local UIWidget = require("scripts/managers/ui/ui_widget")
local FixedFrame = require("scripts/utilities/fixed_frame")
local Dodge = require("scripts/extension_systems/character_state_machine/character_states/utilities/dodge")
local DODGE_BAR_STATE_COLORS_BAR_FILL = HudElementDodgeCounterSettings.DODGE_BAR_STATE_COLORS_BAR_FILL
local DODGE_BAR_STATE_COLORS_BAR_BACKGROUND = HudElementDodgeCounterSettings.DODGE_BAR_STATE_COLORS_BAR_BACKGROUND
local STAMINA_NODGES_COLOR = HudElementStaminaSettings.STAMINA_NODGES_COLOR

local M = {}

M.init = function(self, definitions)
	local stm_w = definitions and definitions.division_stamina_bar_width
	local ddg_track = definitions and definitions.division_dodge_bar_track_width

	self._division_stm_bar_width = type(stm_w) == "number" and stm_w > 0 and stm_w or HudElementStaminaSettings.bar_size[1]
	self._division_dodge_bar_track_width = type(ddg_track) == "number" and ddg_track > 0 and ddg_track or HudElementDodgeCounterSettings.bar_size[1]
	self._stamina_chunk_width = 0
	self._last_stamina_fraction = 1
	self._spent_stamina_animation = {
		running = false,
		stamina = 1,
		starting_stamina = 1,
	}
	self._stamina_nodge_widget = self:_create_widget("stamina_nodge", definitions.stamina_nodges_definition)
	self._division_dodge_bar_definition = definitions.dodge_bar_definition

	self._dodge_bars = {}
	self._dodge_bar_width = 0
	self._is_dodging = false
	self._is_dodge_on_cooldown = false
	self._effective_dodges_left = 0
	self._consecutive_dodges_performed = 0
	self._last_consecutive_dodges_performed = 0
	self._consecutive_dodges_cooldown = 0
	self._max_effective_dodges = 0

	local save_data = Managers.save:account_data()
	local interface_settings = save_data.interface_settings

	self._stamina_dodge_visibility_setting = interface_settings.stamina_and_dodge_visibility_setting or "dynamic"
	self._stamina_sync_with_dodge_bar = interface_settings.stamina_and_dodge_show_together or false
	self._dodge_sync_with_stamina_bar = interface_settings.stamina_and_dodge_show_together or false
	self._use_percentage_based_division = interface_settings.show_stamina_with_fixed_dividers or false
	self._show_stamina_percentage_text = interface_settings.show_stamina_percentage_text or false
	self._stamina_is_active = false
	self._dodge_is_active = false
	self._stamina_alpha_mult = 0
	self._dodge_alpha_mult = 0

	Managers.event:register(self, "event_update_stamina_and_dodge_hud_visibility_changed", "division_stamina_dodge_cb_visibility")
	Managers.event:register(self, "event_update_stamina_and_dodge_hud_syncronized", "division_stamina_dodge_cb_sync")
	Managers.event:register(self, "event_update_show_stamina_with_fixed_dividers", "division_stamina_dodge_cb_fixed_dividers")
	Managers.event:register(self, "event_update_show_stamina_percentage_text", "division_stamina_dodge_cb_percentage_text")
end

M.division_stamina_dodge_cb_sync = function(self, enabled)
	self._stamina_sync_with_dodge_bar = enabled
	self._dodge_sync_with_stamina_bar = enabled
end

M.division_stamina_dodge_cb_fixed_dividers = function(self, enabled)
	self._use_percentage_based_division = enabled
end

M.division_stamina_dodge_cb_percentage_text = function(self, enabled)
	self._show_stamina_percentage_text = enabled
end

M.division_stamina_dodge_cb_visibility = function(self, visibility_setting)
	self._stamina_dodge_visibility_setting = visibility_setting
end

M.destroy = function(self, ui_renderer)
	Managers.event:unregister(self, "event_update_stamina_and_dodge_hud_visibility_changed")
	Managers.event:unregister(self, "event_update_stamina_and_dodge_hud_syncronized")
	Managers.event:unregister(self, "event_update_show_stamina_with_fixed_dividers")
	Managers.event:unregister(self, "event_update_show_stamina_percentage_text")

	while #self._dodge_bars > 0 do
		M._remove_dodge_bar(self, ui_renderer)
	end

	if ui_renderer and self._stamina_nodge_widget then
		self:_unregister_widget_name("stamina_nodge")
		UIWidget.destroy(ui_renderer, self._stamina_nodge_widget)

		self._stamina_nodge_widget = nil
	end
end

M._update_stamina_amount = function(self)
	local num_stamina_chunks = 0
	local parent = self._parent
	local player_extensions = parent and parent:player_extensions()

	if not self._use_percentage_based_division and player_extensions then
		local unit_data_extension = player_extensions.unit_data

		if unit_data_extension then
			local stamina_component = unit_data_extension:read_component("stamina")
			local archetype = unit_data_extension:archetype()
			local base_stamina_template = archetype.stamina

			if stamina_component and base_stamina_template then
				local player_unit = player_extensions.unit
				local _, max = Stamina.current_and_max_value(player_unit, stamina_component, base_stamina_template)

				num_stamina_chunks = max
			end
		end
	else
		num_stamina_chunks = 4
	end

	if num_stamina_chunks ~= self._num_stamina_chunks then
		self._num_stamina_chunks = num_stamina_chunks

		local segment_spacing = HudElementStaminaSettings.spacing
		local total_segment_spacing = segment_spacing * math.max(math.floor(num_stamina_chunks), 0)
		local total_bar_length = self._division_stm_bar_width - total_segment_spacing

		self._stamina_chunk_width = self._num_stamina_chunks > 0 and total_bar_length / self._num_stamina_chunks or total_bar_length
	end
end

M._update_stamina_visibility_base = function(self)
	local visibility_setting = self._stamina_dodge_visibility_setting
	local should_always_be_visible = visibility_setting == "always_stamina" or visibility_setting == "always_both"
	local is_visibility_enabled = should_always_be_visible or visibility_setting ~= "stamina_disabled" and visibility_setting ~= "both_disabled"
	local draw = not not should_always_be_visible
	local parent = self._parent
	local player_extensions = parent and parent:player_extensions()
	local check_stamina_usage_status = is_visibility_enabled and not should_always_be_visible

	if check_stamina_usage_status and player_extensions then
		local player_unit_data = player_extensions.unit_data

		if player_unit_data then
			local block_component = player_unit_data:read_component("block")
			local sprint_component = player_unit_data:read_component("sprint_character_state")
			local stamina_component = player_unit_data:read_component("stamina")

			if block_component and block_component.is_blocking or sprint_component and sprint_component.is_sprinting or stamina_component and stamina_component.current_fraction < 1 then
				draw = true
			end
		end
	end

	self._stamina_is_active = draw
	self._stamina_draw_base = draw
	self._stamina_should_always_be_visible = should_always_be_visible
	self._stamina_is_visibility_enabled = is_visibility_enabled
end

M._update_stamina_visibility_alpha = function(self, dt)
	local draw = self._stamina_draw_base
	local should_always_be_visible = self._stamina_should_always_be_visible
	local is_visibility_enabled = self._stamina_is_visibility_enabled

	if is_visibility_enabled and not should_always_be_visible then
		draw = draw or self._dodge_is_active
	end

	local alpha_speed = draw and 8 or 3
	local alpha_multiplier = self._stamina_alpha_mult or 0

	if draw then
		alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
	else
		alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
	end

	self._stamina_alpha_mult = alpha_multiplier
end

M._draw_stamina_chunks = function(self, dt, t, ui_renderer)
	local num_stamina_chunks = self._num_stamina_chunks

	if num_stamina_chunks < 1 then
		return
	end

	local stamina_chunk_width = self._stamina_chunk_width
	local stamina_fraction = 1
	local parent = self._parent
	local player_extensions = parent and parent:player_extensions()

	if player_extensions then
		local player_unit_data = player_extensions.unit_data

		if player_unit_data then
			local stamina_component = player_unit_data:read_component("stamina")

			if stamina_component and stamina_component.current_fraction then
				stamina_fraction = stamina_component.current_fraction
			end
		end
	end

	if stamina_fraction <= 0 and self._last_stamina_fraction > 0 then
		self:_start_animation("on_stamina_depleted", self._widgets_by_name, 1)
	end

	local stamina_spent = self._last_stamina_fraction - stamina_fraction
	local spent_stamina_animation = self._spent_stamina_animation

	if stamina_spent > HudElementStaminaSettings.stamina_spent_threshold and not spent_stamina_animation.running then
		spent_stamina_animation.running = true
		spent_stamina_animation.start_t = t + HudElementStaminaSettings.stamina_spent_delay
		spent_stamina_animation.starting_stamina = self._last_stamina_fraction
		spent_stamina_animation.stamina = self._last_stamina_fraction
	end

	self._last_stamina_fraction = stamina_fraction

	local gauge_widget = self._widgets_by_name.stamina_gauge
	local stamina_text_style = gauge_widget.style.value_text
	local stamina_text_color = stamina_text_style.text_color

	local hide_stamina_value = self._enemy_target_overflow_active == true

	stamina_text_color[1] = (self._show_stamina_percentage_text and not hide_stamina_value) and 255 or 0
	gauge_widget.content.value_text = string.format("%.0f%%", math.clamp(stamina_fraction, 0, 1) * 100)

	local spacing = HudElementStaminaSettings.spacing
	local stamina_bar_widget = self._widgets_by_name.stamina_bar
	local stm_bar_w = self._division_stm_bar_width

	stamina_bar_widget.style.bar_fill.size_addition[1] = -(stm_bar_w * (1 - stamina_fraction))

	if spent_stamina_animation.running then
		if stamina_fraction >= spent_stamina_animation.stamina then
			spent_stamina_animation.running = false
		end

		if t >= spent_stamina_animation.start_t then
			spent_stamina_animation.stamina = spent_stamina_animation.stamina - dt * HudElementStaminaSettings.stamina_spent_drain_speed
		end

		stamina_bar_widget.style.bar_spent.size_addition[1] = -(stm_bar_w * (1 - spent_stamina_animation.stamina))
	else
		stamina_bar_widget.style.bar_spent.size_addition[1] = -(stm_bar_w * (1 - stamina_fraction))
	end

	local show_last_nodge = num_stamina_chunks - math.floor(num_stamina_chunks) > 0
	local num_stamina_chunks_to_show = show_last_nodge and num_stamina_chunks or num_stamina_chunks - 1
	local stamina_nodge_widget = self._stamina_nodge_widget
	local stamina_nodge_widget_offset = stamina_nodge_widget.offset
	local stamina_nodge_widget_style = stamina_nodge_widget.style.nodges
	local stamina_nodge_widget_color = stamina_nodge_widget_style.color
	local stamina_nodge_offset = stamina_chunk_width

	for i = 1, num_stamina_chunks_to_show do
		stamina_nodge_widget_offset[1] = stamina_nodge_offset

		local is_nodge_above_current_stamina = i > stamina_fraction * num_stamina_chunks
		local nodge_color = is_nodge_above_current_stamina and STAMINA_NODGES_COLOR.empty or STAMINA_NODGES_COLOR.filled

		stamina_nodge_widget_color[1] = nodge_color[1]
		stamina_nodge_widget_color[2] = nodge_color[2]
		stamina_nodge_widget_color[3] = nodge_color[3]
		stamina_nodge_widget_color[4] = nodge_color[4]

		UIWidget.draw(stamina_nodge_widget, ui_renderer)

		stamina_nodge_offset = stamina_nodge_offset + (stamina_chunk_width + spacing)
	end
end

M._add_dodge_bar = function(self)
	local dodge_bar_index = #self._dodge_bars + 1
	local dodge_bar_widget_name = "dodge_bar_" .. dodge_bar_index
	local is_available = self._effective_dodges_left >= self._max_effective_dodges - dodge_bar_index + 1
	local is_on_cooldown = self._is_dodging or self._is_dodge_on_cooldown
	local starting_status = "available"
	local override_starting_color

	if is_available and is_on_cooldown then
		override_starting_color = DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown
		starting_status = "available_on_cooldown"
	elseif not is_available then
		override_starting_color = DODGE_BAR_STATE_COLORS_BAR_FILL.spent
		starting_status = "spent"
	end

	local new_bar = {
		animation_id = nil,
		status = starting_status,
		widget_name = dodge_bar_widget_name,
		widget = self:_create_widget(dodge_bar_widget_name, self._division_dodge_bar_definition),
	}

	if override_starting_color then
		local widget = new_bar.widget
		local fill_widget_color = widget.style.bar_fill.color

		fill_widget_color[1] = override_starting_color[1]
		fill_widget_color[2] = override_starting_color[2]
		fill_widget_color[3] = override_starting_color[3]
		fill_widget_color[4] = override_starting_color[4]
	end

	self._dodge_bars[dodge_bar_index] = new_bar
end

M._remove_dodge_bar = function(self, ui_renderer)
	local dodge_bar_index = #self._dodge_bars
	local dodge_bar = self._dodge_bars[dodge_bar_index]
	local widget = dodge_bar.widget

	self:_unregister_widget_name(widget.name)
	UIWidget.destroy(ui_renderer, widget)

	self._dodge_bars[#self._dodge_bars] = nil
end

M._update_dodge_amount = function(self, t, ui_renderer)
	local parent = self._parent
	local player_extensions = parent:player_extensions()
	local current_max_effective_dodges = M._update_dodging_data(self, player_extensions)
	local max_effective_dodges_changed = current_max_effective_dodges ~= self._max_effective_dodges

	if max_effective_dodges_changed then
		local amount_difference = (self._max_effective_dodges or 0) - current_max_effective_dodges

		self._max_effective_dodges = current_max_effective_dodges

		local segment_spacing = HudElementDodgeCounterSettings.spacing
		local total_segment_spacing = segment_spacing * math.max(current_max_effective_dodges - 1, 0)
		local total_bar_length = self._division_dodge_bar_track_width - total_segment_spacing

		self._dodge_bar_width = math.round(current_max_effective_dodges > 0 and total_bar_length / current_max_effective_dodges or total_bar_length)

		local add_dodges = amount_difference < 0

		for i = 1, math.abs(amount_difference) do
			if add_dodges then
				M._add_dodge_bar(self)
			else
				M._remove_dodge_bar(self, ui_renderer)
			end
		end

		self._start_on_half_bar = false
	end
end

M._update_dodging_data = function(self, player_extensions)
	local current_max_effective_dodges = 0

	if player_extensions then
		local unit_data_extension = player_extensions.unit_data
		local weapon_extension = player_extensions.weapon

		if unit_data_extension and weapon_extension then
			local movement_state_component = unit_data_extension and unit_data_extension:read_component("movement_state")
			local dodge_character_state_component = unit_data_extension:read_component("dodge_character_state")
			local slide_character_state_component = unit_data_extension:read_component("slide_character_state")
			local character_state_component = unit_data_extension:read_component("character_state")
			local fixed_t = FixedFrame.get_latest_fixed_time()
			local num_effective_dodges = Dodge.num_effective_dodges(player_extensions.unit)

			current_max_effective_dodges = math.floor(num_effective_dodges)

			local is_vaulting = movement_state_component.method == "vaulting"
			local is_lunging = movement_state_component.method == "lunging"
			local is_dodging = movement_state_component.is_dodging and not is_vaulting and not is_lunging
			local is_sliding = movement_state_component.method == "sliding"
			local was_in_consecutive_dodge_cooldown = slide_character_state_component.was_in_dodge_cooldown
			local current_state_name = character_state_component.state_name
			local current_state_enter_t = character_state_component.entered_t
			local entered_dodge_cooldown_this_frame = is_dodging and (current_state_name == "dodging" or current_state_name == "sliding") and current_state_enter_t == fixed_t
			local can_consecutive_dodges_reset = not is_dodging or is_sliding and not was_in_consecutive_dodge_cooldown
			local effective_dodges_have_reset = can_consecutive_dodges_reset and fixed_t > dodge_character_state_component.consecutive_dodges_cooldown
			local consecutive_dodges_performed = effective_dodges_have_reset and 0 or dodge_character_state_component.consecutive_dodges
			local effective_dodges_left = math.floor(num_effective_dodges - consecutive_dodges_performed)
			local effective_dodges_left_capped = math.max(math.floor(num_effective_dodges - consecutive_dodges_performed), 0)
			local dodge_was_spent = consecutive_dodges_performed - self._last_consecutive_dodges_performed > 0
			local triggered_ineffective_dodge = consecutive_dodges_performed - self._last_consecutive_dodges_performed > 0 and effective_dodges_left < 0

			self._last_consecutive_dodges_performed = self._consecutive_dodges_performed
			self._consecutive_dodges_performed = consecutive_dodges_performed
			self._consecutive_dodges_cooldown = dodge_character_state_component.consecutive_dodges_cooldown
			self._effective_dodges_left = effective_dodges_left_capped
			self._is_dodging = is_dodging
			self._is_dodge_on_cooldown = fixed_t <= dodge_character_state_component.cooldown
			self._dodge_was_spent = dodge_was_spent
			self._entered_dodge_cooldown_this_frame = entered_dodge_cooldown_this_frame
			self._triggered_ineffective_dodge = triggered_ineffective_dodge
		end
	end

	return current_max_effective_dodges
end

M._update_dodge_visibility = function(self, dt)
	local consecutive_dodges_performed = self._consecutive_dodges_performed
	local consecutive_dodges_cooldown = self._consecutive_dodges_cooldown
	local fixed_t = FixedFrame.get_latest_fixed_time()
	local visibility_setting = self._stamina_dodge_visibility_setting
	local should_always_be_visible = visibility_setting == "always_dodge" or visibility_setting == "always_both"
	local is_visibility_enabled = should_always_be_visible or visibility_setting ~= "dodge_disabled" and visibility_setting ~= "both_disabled"
	local draw = should_always_be_visible or is_visibility_enabled and (consecutive_dodges_performed > 0 or fixed_t <= consecutive_dodges_cooldown + 1)

	self._dodge_is_active = draw

	local syncronize_with_stamina_bar = self._dodge_sync_with_stamina_bar

	if is_visibility_enabled and not should_always_be_visible and syncronize_with_stamina_bar then
		draw = draw or self._stamina_is_active
	end

	local alpha_speed = draw and 8 or 3
	local alpha_multiplier = self._dodge_alpha_mult or 0

	if draw then
		alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
	else
		alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
	end

	self._dodge_alpha_mult = alpha_multiplier
end

M._draw_dodge_bars = function(self, dt, t, ui_renderer)
	local max_effective_dodges = self._max_effective_dodges
	local effective_dodges_left = self._effective_dodges_left

	if self._triggered_ineffective_dodge then
		self:_start_animation("on_inefficient_dodge", self._widgets_by_name, 1)
	end

	local dodge_bar_width = self._dodge_bar_width
	local spacing = HudElementDodgeCounterSettings.spacing
	local x_offset = 0
	local dodge_was_spent = self._dodge_was_spent
	local is_dodge_on_cooldown = self._is_dodging or self._is_dodge_on_cooldown
	local entered_dodging_state_this_frame = self._entered_dodge_cooldown_this_frame
	local dodge_bars = self._dodge_bars

	for i = 1, max_effective_dodges do
		local bar_index = max_effective_dodges - i + 1
		local dodge_bar = dodge_bars[i]
		local dodge_bar_widget = dodge_bar.widget
		local dodge_bar_widget_style_fill = dodge_bar_widget.style.bar_fill
		local dodge_bar_widget_style_background = dodge_bar_widget.style.bar_background

		dodge_bar_widget_style_fill.size[1] = dodge_bar_width
		dodge_bar_widget_style_background.size[1] = dodge_bar_width

		local dodge_bar_widget_offset = dodge_bar_widget.offset
		local is_dodge_bar_available = bar_index <= effective_dodges_left

		M._check_animation_triggers(self, dodge_bar, entered_dodging_state_this_frame, dodge_was_spent, is_dodge_bar_available, is_dodge_on_cooldown)
		M._update_dodge_bars_background_colors(self, dodge_bar, is_dodge_bar_available, is_dodge_on_cooldown)

		dodge_bar_widget_offset[1] = x_offset

		UIWidget.draw(dodge_bar_widget, ui_renderer)

		x_offset = x_offset - dodge_bar_width - spacing
	end
end

M._check_animation_triggers = function(self, dodge_bar, entered_dodging_state_this_frame, dodge_was_spent, is_dodge_bar_available, is_dodge_on_cooldown)
	local bar_status = dodge_bar.status

	if not is_dodge_bar_available and (bar_status == "available" or bar_status == "available_on_cooldown") then
		dodge_bar.status = "spent"

		M._start_dodge_bar_animation(self, dodge_bar, "on_bar_spent")
	elseif is_dodge_bar_available and bar_status == "spent" then
		M._start_dodge_bar_animation(self, dodge_bar, "on_bar_restored")

		dodge_bar.status = "available"
	end

	if is_dodge_bar_available then
		if (dodge_was_spent or entered_dodging_state_this_frame) and is_dodge_on_cooldown and dodge_bar.status == "available" then
			M._start_dodge_bar_animation(self, dodge_bar, "on_bar_enter_cooldown")

			dodge_bar.status = "available_on_cooldown"
		elseif not is_dodge_on_cooldown and dodge_bar.status == "available_on_cooldown" then
			M._start_dodge_bar_animation(self, dodge_bar, "on_bar_exit_cooldown")

			dodge_bar.status = "available"
		end
	end
end

M._update_dodge_bars_background_colors = function(self, dodge_bar, is_dodge_bar_available, is_dodge_on_cooldown)
	local dodge_bar_widget = dodge_bar.widget
	local background_active_color
	local widget_style = dodge_bar_widget.style

	if is_dodge_bar_available then
		background_active_color = DODGE_BAR_STATE_COLORS_BAR_BACKGROUND.default
	else
		background_active_color = is_dodge_on_cooldown and DODGE_BAR_STATE_COLORS_BAR_BACKGROUND.on_cooldown or DODGE_BAR_STATE_COLORS_BAR_BACKGROUND.default
	end

	local background_widget_color = widget_style.bar_background.color

	background_widget_color[1] = background_active_color[1]
	background_widget_color[2] = background_active_color[2]
	background_widget_color[3] = background_active_color[3]
	background_widget_color[4] = background_active_color[4]
end

M._start_dodge_bar_animation = function(self, dodge_bar, animation_name)
	local dodge_bar_widget = dodge_bar.widget
	local running_animation_id = dodge_bar.animation_id

	if running_animation_id then
		self:_stop_animation(running_animation_id)

		dodge_bar.animation_id = nil
	end

	local animation_id = self:_start_animation(animation_name, self._widgets_by_name, 1, {
		dodge_bar = dodge_bar,
		dodge_bar_widget = dodge_bar_widget,
		name = dodge_bar.widget_name,
	})

	dodge_bar.animation_id = animation_id
end

M.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	M._update_stamina_amount(self)
	M._update_stamina_visibility_base(self)
	M._update_dodge_amount(self, t, ui_renderer)
	M._update_dodge_visibility(self, dt)
	M._update_stamina_visibility_alpha(self, dt)
end

M.draw = function(self, dt, t, input_service, ui_renderer, render_settings)
	local stm_a = self._stamina_alpha_mult or 0
	local ddg_a = self._dodge_alpha_mult or 0

	if stm_a ~= 0 then
		local previous_alpha_multiplier = render_settings.alpha_multiplier

		render_settings.alpha_multiplier = (previous_alpha_multiplier or 1) * stm_a

		UIWidget.draw(self._widgets_by_name.stamina_gauge, ui_renderer)
		UIWidget.draw(self._widgets_by_name.stamina_bar, ui_renderer)
		UIWidget.draw(self._widgets_by_name.stamina_depleted_bar, ui_renderer)
		M._draw_stamina_chunks(self, dt, t, ui_renderer)

		render_settings.alpha_multiplier = previous_alpha_multiplier
	end

	if ddg_a ~= 0 then
		local previous_alpha_multiplier = render_settings.alpha_multiplier

		render_settings.alpha_multiplier = (previous_alpha_multiplier or 1) * ddg_a

		UIWidget.draw(self._widgets_by_name.dodge_gauge, ui_renderer)
		UIWidget.draw(self._widgets_by_name.wide_bar, ui_renderer)
		M._draw_dodge_bars(self, dt, t, ui_renderer)

		render_settings.alpha_multiplier = previous_alpha_multiplier
	end
end

return M
