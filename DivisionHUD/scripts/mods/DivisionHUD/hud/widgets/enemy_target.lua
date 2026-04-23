local M = {}

local function round_to_int(value)
	if value >= 0 then
		return math.floor(value + 0.5)
	end

	return math.ceil(value - 0.5)
end

local function reset_widget(widget, max_debuff_slots)
	if not widget or not widget.content or not widget.style then
		return
	end

	widget.content.visible = false
	widget.content.name_text = ""
	widget.content.health_text = ""
	widget.content.type_text = ""

	local health_fill_style = widget.style.health_bar_fill
	local default_size = health_fill_style and health_fill_style.default_size

	if health_fill_style and default_size then
		health_fill_style.size[1] = 0
		health_fill_style.size[2] = default_size[2]
	end

	for i = 1, max_debuff_slots do
		widget.content["debuff_icon_" .. i] = nil
		widget.content["debuff_name_" .. i] = ""
		widget.content["debuff_value_" .. i] = ""
	end

	widget.alpha_multiplier = 0
	widget.dirty = true
end

local function reset_anim(self)
	self._enemy_target_anim = {
		state = "hidden",
		timer = 0,
		alpha = 0,
		x_offset = self._enemy_target_hidden_x or 0,
	}
end

function M.init(self, definitions)
	self._enemy_target_max_debuff_slots = definitions.ENEMY_TARGET_MAX_DEBUFF_SLOTS or 6
	self._enemy_target_alpha_mult = 0
	self._enemy_target_slide_px = (definitions and definitions.ENEMY_TARGET_SLIDE_PX) or 40
	self._enemy_target_enter_dur = (definitions and definitions.ENEMY_TARGET_ENTER_DUR) or 0.2
	self._enemy_target_exit_dur = (definitions and definitions.ENEMY_TARGET_EXIT_DUR) or 0.16
	self._enemy_target_hidden_x = -self._enemy_target_slide_px

	reset_anim(self)

	local widget = self._widgets_by_name and self._widgets_by_name.enemy_target

	reset_widget(widget, self._enemy_target_max_debuff_slots)

	if self.set_scenegraph_position then
		self:set_scenegraph_position("division_enemy_target_area", self._enemy_target_hidden_x or 0, 0)
	end
end

function M.update(self, widget, opacity, dt)
	if not widget or not widget.content or not widget.style then
		return
	end

	dt = (type(dt) == "number" and dt == dt and dt > 0) and dt or 0

	local max_debuff_slots = self._enemy_target_max_debuff_slots or 6
	local data = self._enemy_target_data or {}
	local is_requested = data.active == true
	local alpha = self._enemy_target_alpha_mult or 0
	local alpha_speed = is_requested and 10 or 6
	local anim = self._enemy_target_anim
	local hidden_x = self._enemy_target_hidden_x or 0
	local enter_dur = self._enemy_target_enter_dur or 0.2
	local exit_dur = self._enemy_target_exit_dur or 0.16

	if is_requested and anim.state == "exit" then
		anim.state = "enter"
		anim.timer = enter_dur * (1 - anim.alpha)
		anim.x_offset = round_to_int(hidden_x * (1 - anim.alpha))
	elseif is_requested and anim.state == "hidden" then
		anim.state = "enter"
		anim.timer = 0
		anim.alpha = 0
		anim.x_offset = hidden_x
	elseif not is_requested and (anim.state == "enter" or anim.state == "hold") then
		anim.state = "exit"
		anim.timer = exit_dur * (1 - anim.alpha)
	end

	if is_requested then
		alpha = math.min(alpha + dt * alpha_speed, 1)
	else
		alpha = math.max(alpha - dt * alpha_speed, 0)
	end

	self._enemy_target_alpha_mult = alpha

	if alpha <= 0 and not is_requested then
		reset_widget(widget, max_debuff_slots)

		reset_anim(self)

		if self.set_scenegraph_position then
			self:set_scenegraph_position("division_enemy_target_area", hidden_x, 0)
		end

		return
	end

	if is_requested then
		widget.content.name_text = data.name or ""
		widget.content.health_text = string.format("%d / %d", math.floor(data.health_current or 0), math.floor(data.health_max or 0))
		widget.content.type_text = ""

		local health_fill_style = widget.style.health_bar_fill
		local default_size = health_fill_style and health_fill_style.default_size
		local health_fraction = math.max(0, math.min(1, data.health_fraction or 0))

		if health_fill_style and default_size then
			health_fill_style.size[1] = math.floor(default_size[1] * health_fraction + 0.5)
			health_fill_style.size[2] = default_size[2]
		end

		local debuffs = data.debuffs or {}

		for i = 1, max_debuff_slots do
			local debuff = debuffs[i]
			local icon_id = "debuff_icon_" .. i
			local name_id = "debuff_name_" .. i
			local value_id = "debuff_value_" .. i
			local icon_style = widget.style[icon_id]

			if debuff then
				widget.content[icon_id] = debuff.icon
				widget.content[name_id] = debuff.label or ""
				widget.content[value_id] = debuff.value_text or ""

				if icon_style and debuff.colour then
					icon_style.color[1] = 255
					icon_style.color[2] = debuff.colour[2] or 255
					icon_style.color[3] = debuff.colour[3] or 255
					icon_style.color[4] = debuff.colour[4] or 255
				end
			else
				widget.content[icon_id] = nil
				widget.content[name_id] = ""
				widget.content[value_id] = ""

				if icon_style then
					icon_style.color[1] = 255
					icon_style.color[2] = 255
					icon_style.color[3] = 255
					icon_style.color[4] = 255
				end
			end
		end
	end

	anim.timer = anim.timer + dt

	if anim.state == "enter" then
		local p = math.min(1, anim.timer / enter_dur)
		local ep = math.easeOutCubic(p)

		anim.alpha = ep
		anim.x_offset = round_to_int(hidden_x * (1 - ep))

		if p >= 1 then
			anim.state = "hold"
			anim.alpha = 1
			anim.x_offset = 0
		end
	elseif anim.state == "hold" then
		anim.alpha = 1
		anim.x_offset = 0
	elseif anim.state == "exit" then
		local p = math.min(1, anim.timer / exit_dur)
		local ep = math.easeOutCubic(p)

		anim.alpha = 1 - ep
		anim.x_offset = round_to_int(hidden_x * ep)

		if p >= 1 then
			anim.state = "hidden"
			anim.alpha = 0
			anim.x_offset = hidden_x
		end
	end

	if self.set_scenegraph_position then
		self:set_scenegraph_position("division_enemy_target_area", anim.x_offset or 0, 0)
	end

	if anim.state ~= "hidden" and (anim.alpha or 0) > 0 then
		widget.content.visible = true
		widget.alpha_multiplier = opacity * alpha * anim.alpha
	else
		reset_widget(widget, max_debuff_slots)
	end

	widget.dirty = true
end

function M.destroy(self)
	local widget = self._widgets_by_name and self._widgets_by_name.enemy_target

	reset_widget(widget, self._enemy_target_max_debuff_slots or 6)
	reset_anim(self)

	self._enemy_target_alpha_mult = 0

	if self.set_scenegraph_position then
		self:set_scenegraph_position("division_enemy_target_area", self._enemy_target_hidden_x or 0, 0)
	end
end

return M
