local mod = get_mod("DivisionHUD")

local HudHealthBarLogic = require("scripts/ui/hud/elements/hud_health_bar_logic")
local HudElementPlayerHealthSettings = require("scripts/ui/hud/elements/player_health/hud_element_player_health_settings")
local HudElementPlayerToughnessSettings = require("scripts/ui/hud/elements/player_health/hud_element_player_toughness_settings")
local HudElementStaminaSettings = require("scripts/ui/hud/elements/blocking/hud_element_stamina_settings")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local Stamina = require("scripts/utilities/attack/stamina")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local STAMINA_NODGES_COLOR = HudElementStaminaSettings.STAMINA_NODGES_COLOR

local DEFAULT_TOUGHNESS_BAR_FILL_COLOR = UIHudSettings.color_tint_6
local OVERSHIELDED_TOUGHNESS_BAR_FILL_COLOR = UIHudSettings.color_tint_10

local M = {}

local HEALTH_WIDGETS_ALPHA = {
	"health",
}

local TOUGHNESS_WIDGETS_ALPHA = {
	"toughness",
}

local HEALTH_WIDGETS_ALL = {
	"health",
	"health_max",
	"death_pulse",
}

local HEALTH_WIDGETS_ROW_NO_PULSE = {
	"health",
	"health_max",
}

local TOUGHNESS_WIDGETS_ALL = {
	"toughness",
	"toughness_max",
	"toughness_death_pulse",
}

local TOUGHNESS_WIDGETS_ROW_NO_PULSE = {
	"toughness",
	"toughness_max",
}

local function update_value_label_widget(widget, current_val, opacity)
	if not widget or not widget.content then
		return
	end

	local c = math.floor(current_val + 0.5)

	if c < 0 then
		c = 0
	end

	local text = tostring(c)
	local r = math.floor(255 * opacity + 0.5)
	local changed = false

	if widget.content.text ~= text then
		widget.content.text = text
		changed = true
	end

	local text_style = widget.style and widget.style.text

	if text_style and text_style.text_color then
		local tc = text_style.text_color

		if tc[1] ~= r then
			tc[1] = r
			changed = true
		end
	end

	if changed then
		widget.dirty = true
	end
end

local TIMED_GOLD_BAR_BUFF_TEMPLATE_NAMES = {
	bolstering_prayer_resist_death = true,
	veteran_combat_ability_increase_toughness_to_coherency = true,
	zealot_channel_toughness_bonus = true,
}

local function buff_template_is_timed_gold_bar_visual(buff_template)
	if type(buff_template) ~= "table" then
		return false
	end

	local template_name = buff_template.name

	if template_name and TIMED_GOLD_BAR_BUFF_TEMPLATE_NAMES[template_name] then
		return true
	end

	return false
end

local function timed_gold_bar_template_progress(buff_extension, buff_template_name)
	if not buff_extension or type(buff_template_name) ~= "string" then
		return nil
	end

	if type(buff_extension.current_stacks) == "function" and buff_extension:current_stacks(buff_template_name) > 0 and type(buff_extension.buff_duration_progress) == "function" then
		local progress = buff_extension:buff_duration_progress(buff_template_name)

		if type(progress) == "number" and progress == progress and progress > 0 and progress <= 1 then
			return progress
		end
	end

	local buff_instances = buff_extension._buffs

	if type(buff_instances) ~= "table" then
		return nil
	end

	for i = 1, #buff_instances do
		local buff_instance = buff_instances[i]
		local template = buff_instance and buff_instance:template()

		if type(template) == "table" and template.name == buff_template_name then
			local progress = buff_instance:duration_progress()

			if type(progress) == "number" and progress == progress and progress > 0 and progress <= 1 then
				return progress
			end
		end
	end

	return nil
end

local function buff_instance_remaining_time(buff_instance, progress, template)
	if type(progress) ~= "number" or progress ~= progress or progress <= 0 or progress > 1 then
		return nil
	end

	local duration = type(buff_instance.duration) == "function" and buff_instance:duration() or nil

	if type(duration) ~= "number" or duration <= 0 then
		duration = type(template) == "table" and template.duration or nil
	end

	return type(duration) == "number" and duration > 0 and progress * duration or nil
end

-- Доля заливки полоски по оставшемуся времени эффекта (1 = полная, к 0 сужается). Только реально активные окна.
local function timed_gold_toughness_bar_fill_fraction(buff_extension)
	if not buff_extension then
		return nil
	end

	local best_progress = nil

	for buff_template_name, enabled in pairs(TIMED_GOLD_BAR_BUFF_TEMPLATE_NAMES) do
		if enabled then
			local progress = timed_gold_bar_template_progress(buff_extension, buff_template_name)

			if type(progress) == "number" and progress == progress and progress > 0 and progress <= 1 then
				if best_progress == nil or progress > best_progress then
					best_progress = progress
				end
			end
		end
	end

	return best_progress
end

local function apply_toughness_bar_fill_color(toughness_widget, target_color)
	if not toughness_widget or not toughness_widget.style or not toughness_widget.style.bar_fill or not target_color then
		return
	end

	local c = toughness_widget.style.bar_fill.color

	if c[1] ~= target_color[1] or c[2] ~= target_color[2] or c[3] ~= target_color[3] or c[4] ~= target_color[4] then
		c[1] = target_color[1]
		c[2] = target_color[2]
		c[3] = target_color[3]
		c[4] = target_color[4]
		toughness_widget.dirty = true
	end
end

local function reset_toughness_overshield_visual_state(self, widgets)
	self._vdth_has_toughness_overshield = false

	local tw = widgets and widgets.toughness

	apply_toughness_bar_fill_color(tw, DEFAULT_TOUGHNESS_BAR_FILL_COLOR)
end

M.init = function(self, definitions)
	self._vdth_bar_width = definitions.BAR_WIDTH
	self._vdth_health_bar_logic = HudHealthBarLogic:new(HudElementPlayerHealthSettings)
	self._vdth_toughness_bar_logic = HudHealthBarLogic:new(HudElementPlayerToughnessSettings)
	self._vdth_disabled = nil
	self._vdth_knocked_down = nil
	self._vdth_has_toughness_overshield = false

	self._vdth_num_stamina_chunks = 0
	self._vdth_stamina_chunk_width = 0
	self._vdth_stamina_fraction_for_nodges = 1

	self._vdth_num_health_wounds = 0
	self._vdth_health_chunk_width = 0
	self._vdth_health_fraction_for_nodges = 1

	local save_data = Managers.save:account_data()
	local interface_settings = save_data.interface_settings

	self._vdth_use_percentage_based_division = interface_settings.show_stamina_with_fixed_dividers or false

	self._vdth_health_stamina_nodge_widget = self:_create_widget("health_stamina_nodge", definitions.health_stamina_nodges_definition)
	self._vdth_toughness_stamina_nodge_widget = self:_create_widget("toughness_stamina_nodge", definitions.toughness_stamina_nodges_definition)
end

M.destroy = function(self, ui_renderer)
	if ui_renderer and self._vdth_health_stamina_nodge_widget then
		self:_unregister_widget_name("health_stamina_nodge")
		UIWidget.destroy(ui_renderer, self._vdth_health_stamina_nodge_widget)

		self._vdth_health_stamina_nodge_widget = nil
	end

	if ui_renderer and self._vdth_toughness_stamina_nodge_widget then
		self:_unregister_widget_name("toughness_stamina_nodge")
		UIWidget.destroy(ui_renderer, self._vdth_toughness_stamina_nodge_widget)

		self._vdth_toughness_stamina_nodge_widget = nil
	end
end

local function _compute_chunk_width(bar_width, num_chunks)
	local spacing = HudElementStaminaSettings.spacing
	local total_spacing = spacing * math.max(math.floor(num_chunks), 0)
	local total_bar = bar_width - total_spacing

	return num_chunks > 0 and total_bar / num_chunks or total_bar
end

M._update_vdth_toughness_nodge_chunk_layout = function(self, player_unit)
	local num_stamina_chunks = 0

	if not self._vdth_use_percentage_based_division and player_unit then
		local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

		if unit_data_extension then
			local stamina_component = unit_data_extension:read_component("stamina")
			local archetype = unit_data_extension:archetype()
			local base_stamina_template = archetype.stamina

			if stamina_component and base_stamina_template then
				local _, max = Stamina.current_and_max_value(player_unit, stamina_component, base_stamina_template)

				num_stamina_chunks = max
			end
		end
	else
		num_stamina_chunks = 4
	end

	if num_stamina_chunks < 1 then
		num_stamina_chunks = 4
	end

	if num_stamina_chunks ~= self._vdth_num_stamina_chunks then
		self._vdth_num_stamina_chunks = num_stamina_chunks
		self._vdth_stamina_chunk_width = _compute_chunk_width(self._vdth_bar_width, num_stamina_chunks)
	end
end

M._update_vdth_health_nodge_chunk_layout = function(self, player_unit)
	local num_wounds = 0

	if player_unit then
		local health_extension = ScriptUnit.has_extension(player_unit, "health_system")

		if health_extension and health_extension.max_wounds then
			num_wounds = health_extension:max_wounds()
		end
	end

	if num_wounds < 1 then
		num_wounds = 4
	end

	if num_wounds ~= self._vdth_num_health_wounds then
		self._vdth_num_health_wounds = num_wounds
		self._vdth_health_chunk_width = _compute_chunk_width(self._vdth_bar_width, num_wounds)
	end
end

M._update_vdth_stamina_fraction_for_nodges = function(self, player_unit)
	local stamina_fraction = 1
	local unit_data = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if unit_data then
		local stamina_component = unit_data:read_component("stamina")

		if stamina_component and stamina_component.current_fraction then
			stamina_fraction = stamina_component.current_fraction
		end
	end

	self._vdth_stamina_fraction_for_nodges = stamina_fraction
end

M._draw_style_nodges = function(self, ui_renderer, render_settings, nodge_widget, row_alpha_multiplier, num_chunks, chunk_width, fill_fraction)
	if not nodge_widget then
		return
	end

	if num_chunks < 1 then
		num_chunks = 4
	end

	if not chunk_width or chunk_width <= 0 then
		chunk_width = _compute_chunk_width(self._vdth_bar_width, num_chunks)
	end

	if not nodge_widget.offset then
		nodge_widget.offset = { 0, 0, 0 }
	end

	local nodge_widget_style = nodge_widget.style and nodge_widget.style.nodges

	if not nodge_widget_style or not nodge_widget_style.color then
		return
	end

	fill_fraction = fill_fraction or 1

	local spacing = HudElementStaminaSettings.spacing
	local show_last_nodge = num_chunks - math.floor(num_chunks) > 0
	local num_to_show = show_last_nodge and num_chunks or num_chunks - 1
	local nodge_widget_offset = nodge_widget.offset
	local nodge_widget_color = nodge_widget_style.color
	local nodge_offset = chunk_width
	local previous_alpha_multiplier = render_settings.alpha_multiplier

	render_settings.alpha_multiplier = (previous_alpha_multiplier or 1) * row_alpha_multiplier

	for i = 1, num_to_show do
		nodge_widget_offset[1] = nodge_offset

		local is_above = i > fill_fraction * num_chunks
		local nodge_color = is_above and STAMINA_NODGES_COLOR.empty or STAMINA_NODGES_COLOR.filled

		nodge_widget_color[1] = nodge_color[1]
		nodge_widget_color[2] = nodge_color[2]
		nodge_widget_color[3] = nodge_color[3]
		nodge_widget_color[4] = nodge_color[4]

		nodge_widget.dirty = true

		UIWidget.draw(nodge_widget, ui_renderer)

		nodge_offset = nodge_offset + (chunk_width + spacing)
	end

	render_settings.alpha_multiplier = previous_alpha_multiplier
end

M.draw = function(self, dt, t, input_service, ui_renderer, render_settings)
	local widgets = self._widgets_by_name
	local health_w = widgets.health
	local toughness_w = widgets.toughness

	if health_w and health_w.content and health_w.content.visible and self._vdth_health_stamina_nodge_widget and not self._vdth_knocked_down then
		M._draw_style_nodges(
			self,
			ui_renderer,
			render_settings,
			self._vdth_health_stamina_nodge_widget,
			health_w.alpha_multiplier or 1,
			self._vdth_num_health_wounds,
			self._vdth_health_chunk_width,
			self._vdth_health_fraction_for_nodges
		)
	end
end

M._set_health_row_visible = function(self, widgets, visible)
	if visible then
		for i = 1, #HEALTH_WIDGETS_ROW_NO_PULSE do
			local name = HEALTH_WIDGETS_ROW_NO_PULSE[i]
			local w = widgets[name]

			if w and w.content then
				w.content.visible = true
				w.dirty = true
			end
		end
	else
		for i = 1, #HEALTH_WIDGETS_ALL do
			local name = HEALTH_WIDGETS_ALL[i]
			local w = widgets[name]

			if w and w.content then
				w.content.visible = false
				w.dirty = true
			end
		end
	end
end

M._set_toughness_row_visible = function(self, widgets, visible)
	if visible then
		for i = 1, #TOUGHNESS_WIDGETS_ROW_NO_PULSE do
			local name = TOUGHNESS_WIDGETS_ROW_NO_PULSE[i]
			local w = widgets[name]

			if w and w.content then
				w.content.visible = true
				w.dirty = true
			end
		end
	else
		for i = 1, #TOUGHNESS_WIDGETS_ALL do
			local name = TOUGHNESS_WIDGETS_ALL[i]
			local w = widgets[name]

			if w and w.content then
				w.content.visible = false
				w.dirty = true
			end
		end
	end
end

M._set_bar_alpha_health = function(self, widgets, alpha_fraction)
	for i = 1, #HEALTH_WIDGETS_ALPHA do
		local name = HEALTH_WIDGETS_ALPHA[i]
		local w = widgets[name]

		if w then
			w.alpha_multiplier = alpha_fraction
			w.dirty = true
		end
	end
end

M._set_bar_alpha_toughness = function(self, widgets, alpha_fraction)
	for i = 1, #TOUGHNESS_WIDGETS_ALPHA do
		local name = TOUGHNESS_WIDGETS_ALPHA[i]
		local w = widgets[name]

		if w then
			w.alpha_multiplier = alpha_fraction
			w.dirty = true
		end
	end
end

M._apply_health_fraction = function(self, health_fraction, health_ghost_fraction, health_max_fraction)
	local widgets = self._widgets_by_name
	local bar_width = self._vdth_bar_width
	local health_id = "health"
	local health_width = math.floor(bar_width * health_fraction)
	local health_widget = widgets[health_id]

	if not health_widget or not health_widget.style or not health_widget.style.bar_fill then
		return
	end

	local health_ghost_width = math.max(bar_width * health_ghost_fraction - health_width, 0)
	local ghost_total_width = health_width + health_ghost_width

	health_widget.style.bar_fill.size_addition[1] = -(bar_width - health_width)
	health_widget.style.bar_spent.size_addition[1] = -(bar_width - ghost_total_width)

	local health_max_id = "health_max"
	local health_max_width = bar_width - math.max(bar_width * health_max_fraction, 0)

	health_max_width = math.max(health_max_width, 0)

	local health_max_widget = widgets[health_max_id]

	if health_max_widget and health_max_widget.style and health_max_widget.style.bar_fill and health_max_widget.style.bar_background then
		health_max_widget.style.bar_fill.size[1] = health_max_width
		health_max_widget.style.bar_background.size[1] = health_max_width
		health_max_widget.content.visible = health_max_width > 0
		health_max_widget.dirty = true
	end

	health_widget.dirty = true
end

M._apply_toughness_fraction = function(self, health_fraction, health_ghost_fraction, health_max_fraction)
	local widgets = self._widgets_by_name
	local bar_width = self._vdth_bar_width
	local health_id = "toughness"
	local health_width = math.floor(bar_width * health_fraction)
	local health_widget = widgets[health_id]

	if not health_widget or not health_widget.style or not health_widget.style.bar_fill then
		return
	end

	local health_ghost_width = math.max(bar_width * health_ghost_fraction - health_width, 0)
	local ghost_total_width = health_width + health_ghost_width

	health_widget.style.bar_fill.size_addition[1] = -(bar_width - health_width)
	health_widget.style.bar_spent.size_addition[1] = -(bar_width - ghost_total_width)

	local health_max_id = "toughness_max"
	local health_max_width = bar_width - math.max(bar_width * health_max_fraction, 0)

	health_max_width = math.max(health_max_width, 0)

	local health_max_widget = widgets[health_max_id]

	if health_max_widget and health_max_widget.style and health_max_widget.style.bar_fill and health_max_widget.style.bar_background then
		health_max_widget.style.bar_fill.size[1] = health_max_width
		health_max_widget.style.bar_background.size[1] = health_max_width
		health_max_widget.content.visible = health_max_width > 0
		health_max_widget.dirty = true
	end

	health_widget.dirty = true
end

M._set_disabled = function(self, widgets, disabled)
	local dp = widgets.death_pulse
	local tdp = widgets.toughness_death_pulse

	if dp and dp.content then
		dp.content.visible = disabled
		dp.dirty = true
	end

	if tdp and tdp.content then
		tdp.content.visible = disabled
		tdp.dirty = true
	end
end

M.update = function(self, dt, t, player_unit, opacity)
	opacity = opacity or 1

	M._update_vdth_toughness_nodge_chunk_layout(self, player_unit)
	M._update_vdth_health_nodge_chunk_layout(self, player_unit)
	M._update_vdth_stamina_fraction_for_nodges(self, player_unit)

	local widgets = self._widgets_by_name
	local label_t = widgets.toughness_value_label
	local label_h = widgets.health_value_label
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local disabled = false
	local knocked_down = false

	if unit_data_extension then
		local character_state_component = unit_data_extension:read_component("character_state")

		disabled = PlayerUnitStatus.is_disabled(character_state_component) or false
		knocked_down = PlayerUnitStatus.is_knocked_down(character_state_component) or false
	end

	if disabled ~= self._vdth_disabled then
		self._vdth_disabled = disabled

		M._set_disabled(self, widgets, disabled)
	end

	if knocked_down ~= self._vdth_knocked_down then
		self._vdth_knocked_down = knocked_down

		local health_widget = widgets.health

		if health_widget and health_widget.style and health_widget.style.bar_fill then
			local target_color = knocked_down and UIHudSettings.color_tint_alert_2 or UIHudSettings.color_tint_1
			local bar_fill_color = health_widget.style.bar_fill.color

			bar_fill_color[1] = target_color[1]
			bar_fill_color[2] = target_color[2]
			bar_fill_color[3] = target_color[3]
			bar_fill_color[4] = target_color[4]

			health_widget.dirty = true
		end
	end

	local s = mod._settings
	local show_tough = s and s.show_toughness_bar
	local show_hp = s and s.show_health_bar
	local show_toughness = show_tough ~= false and show_tough ~= 0
	local show_health = show_hp ~= false and show_hp ~= 0

	if not show_toughness then
		reset_toughness_overshield_visual_state(self, widgets)
		M._set_toughness_row_visible(self, widgets, false)

		if label_t and label_t.content then
			label_t.content.visible = false
			label_t.dirty = true
		end
	else
		local toughness_extension = ScriptUnit.has_extension(player_unit, "toughness_system")

		if not toughness_extension then
			reset_toughness_overshield_visual_state(self, widgets)
			M._set_toughness_row_visible(self, widgets, false)

			if label_t and label_t.content then
				label_t.content.visible = false
				label_t.dirty = true
			end
		else
			local toughness_percentage = toughness_extension:current_toughness_percent()

			if toughness_percentage == nil then
				reset_toughness_overshield_visual_state(self, widgets)
				M._set_toughness_row_visible(self, widgets, false)

				if label_t and label_t.content then
					label_t.content.visible = false
					label_t.dirty = true
				end
			else
				toughness_percentage = math.clamp(toughness_percentage, 0, 1)

				local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
				local timed_gold_bar_fill = timed_gold_toughness_bar_fill_fraction(buff_extension)

				local max_toughness = toughness_extension.max_toughness and toughness_extension:max_toughness() or 0
				local max_toughness_visual = toughness_extension.max_toughness_visual and toughness_extension:max_toughness_visual() or 0
				local current_toughness = toughness_percentage * max_toughness
				local current_toughness_visual = toughness_percentage * max_toughness_visual
				local overshield_amount = current_toughness_visual < max_toughness and math.max(current_toughness - max_toughness_visual, 0) or 0
				local has_overshield = math.floor(overshield_amount) > 0
				local toughness_percentage_bar = toughness_extension.current_toughness_percent_visual and toughness_extension:current_toughness_percent_visual() or 0

				if has_overshield and not self._vdth_has_toughness_overshield and toughness_percentage_bar >= 1 then
					self._vdth_has_toughness_overshield = true
				elseif (not has_overshield and self._vdth_has_toughness_overshield) or toughness_percentage_bar and toughness_percentage_bar < 1 then
					self._vdth_has_toughness_overshield = false
				end

				local toughness_w = widgets.toughness
				local use_timed_gold_fill = timed_gold_bar_fill ~= nil
				local show_gold_fill = use_timed_gold_fill or self._vdth_has_toughness_overshield
				local fill_target = show_gold_fill and OVERSHIELDED_TOUGHNESS_BAR_FILL_COLOR or DEFAULT_TOUGHNESS_BAR_FILL_COLOR
				local bar_progress = use_timed_gold_fill and timed_gold_bar_fill or toughness_percentage

				apply_toughness_bar_fill_color(toughness_w, fill_target)

				local bar_logic = self._vdth_toughness_bar_logic

				bar_logic:update(dt, t, bar_progress, 1)

				local alpha = opacity

				M._set_bar_alpha_toughness(self, widgets, alpha)

				local tf, tgf, tmf = bar_logic:animated_health_fractions()

				if tf and tgf then
					M._apply_toughness_fraction(self, tf, tgf, tmf)
				end

				M._set_toughness_row_visible(self, widgets, true)

				if label_t and label_t.content then
					label_t.content.visible = true
					update_value_label_widget(label_t, toughness_extension:remaining_toughness(), alpha)
				end

				for i = 1, #TOUGHNESS_WIDGETS_ALL do
					local w = widgets[TOUGHNESS_WIDGETS_ALL[i]]

					if w then
						w.dirty = true
					end
				end
			end
		end
	end

	if not show_health then
		M._set_health_row_visible(self, widgets, false)

		if label_h and label_h.content then
			label_h.content.visible = false
			label_h.dirty = true
		end
	else
		local health_extension = ScriptUnit.has_extension(player_unit, "health_system")

		if not health_extension then
			M._set_health_row_visible(self, widgets, false)

			if label_h and label_h.content then
				label_h.content.visible = false
				label_h.dirty = true
			end
		else
			local health_percentage = health_extension:current_health_percent() or 0
			local max_health = health_extension:max_health()
			local permanent_damage = health_extension:permanent_damage_taken()
			local health_max_percentage = 1

			if max_health > 0 then
				health_max_percentage = (max_health - permanent_damage) / max_health
			end

			health_percentage = math.clamp(health_percentage, 0, 1)
			health_max_percentage = math.clamp(health_max_percentage, 0, 1)

			local bar_logic = self._vdth_health_bar_logic

			bar_logic:update(dt, t, health_percentage, health_max_percentage)

			local alpha = opacity

			M._set_bar_alpha_health(self, widgets, alpha)

			local hf, hgf, hmf = bar_logic:animated_health_fractions()

			if hf and hgf then
				M._apply_health_fraction(self, hf, hgf, hmf)
				self._vdth_health_fraction_for_nodges = hf
			end

			M._set_health_row_visible(self, widgets, true)

			if label_h and label_h.content then
				label_h.content.visible = true
				update_value_label_widget(label_h, health_extension:current_health(), alpha)
			end

			for i = 1, #HEALTH_WIDGETS_ALL do
				local w = widgets[HEALTH_WIDGETS_ALL[i]]

				if w then
					w.dirty = true
				end
			end
		end
	end
end

return M
