local mod = get_mod("DivisionHUD")

local CombatAbilityBar = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/hud/widgets/combat_ability_bar")

local M = {}

local COMBAT_ABILITY_TYPE = "combat_ability"

local function round_to_int(value)
	if value >= 0 then
		return math.floor(value + 0.5)
	end

	return math.ceil(value - 0.5)
end

local function reset_widget(widget)
	if not widget or not widget.content then
		return
	end

	widget.content.visible = false
	widget.content.duration_progress = 1
	widget.alpha_multiplier = 0

	local style = widget.style
	local icon_style = style and style.icon
	local material_values = icon_style and icon_style.material_values

	if material_values then
		material_values.talent_icon = nil
		material_values.progress = 1
	end

	widget.dirty = true
end

local function reset_anim(self)
	self._ability_icon_anim = {
		state = "hidden",
		timer = 0,
		alpha = 0,
		x_offset = self._ability_icon_hidden_x or 0,
	}
end

local function resolve_equipped_ability(player_unit)
	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(COMBAT_ABILITY_TYPE) then
		return nil
	end

	local equipped_abilities = ability_extension:equipped_abilities()
	local ability_settings = equipped_abilities and equipped_abilities[COMBAT_ABILITY_TYPE]

	if type(ability_settings) ~= "table" then
		return nil
	end

	return ability_settings
end

local function resolve_ability_icon(self, player_unit)
	if not player_unit or not ALIVE[player_unit] then
		return nil
	end

	local ability_settings = resolve_equipped_ability(player_unit)
	local ability_name = ability_settings and ability_settings.name

	if self._ability_icon_unit ~= player_unit or self._ability_icon_name ~= ability_name then
		self._ability_icon_unit = player_unit
		self._ability_icon_name = ability_name
		self._ability_icon_value = nil
	end

	local cached = self._ability_icon_value

	if type(cached) == "string" and cached ~= "" then
		return cached
	end

	local icon = ability_settings and ability_settings.hud_icon

	if type(icon) ~= "string" or icon == "" then
		return nil
	end

	self._ability_icon_value = icon

	return icon
end

local function _duration_buff_progress(buff_extension, buff_name)
	if not buff_extension or type(buff_name) ~= "string" or buff_name == "" then
		return nil
	end

	if (buff_extension:current_stacks(buff_name) or 0) <= 0 then
		return nil
	end

	return buff_extension:buff_duration_progress(buff_name)
end

local function compute_cooldown_progress(player_unit)
	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(COMBAT_ABILITY_TYPE) then
		return 1
	end

	local max_cd = ability_extension:max_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local rem_cd = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local progress

	if max_cd > 0 then
		progress = 1 - math.min(1, math.max(0, rem_cd / max_cd))

		if progress == 0 then
			progress = 1
		end
	else
		progress = 0
	end

	if not ability_extension.ability_pause_cooldown_settings then
		return progress
	end

	local pause_settings = ability_extension:ability_pause_cooldown_settings(COMBAT_ABILITY_TYPE)

	if type(pause_settings) ~= "table" then
		return progress
	end

	local tracking = pause_settings.duration_tracking_buff

	if not tracking then
		return progress
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension then
		return progress
	end

	if type(tracking) == "table" then
		for i = 1, #tracking do
			local p = _duration_buff_progress(buff_extension, tracking[i])

			if p then
				return p
			end
		end
	else
		local p = _duration_buff_progress(buff_extension, tracking)

		if p then
			return p
		end
	end

	return progress
end

local function copy_color_into(dst, src)
	if type(dst) ~= "table" or type(src) ~= "table" then
		return false
	end

	local changed = false

	for i = 1, 4 do
		if dst[i] ~= src[i] then
			dst[i] = src[i]
			changed = true
		end
	end

	return changed
end

local function apply_state_colors(self, widget, state)
	if not widget or not widget.style then
		return
	end

	local palette = state == "cooldown" and self._ability_icon_cooldown_colors or self._ability_icon_active_colors

	if type(palette) ~= "table" then
		return
	end

	local dirty = false
	local style = widget.style

	for pass_id, color in pairs(palette) do
		local pass_style = style[pass_id]

		if pass_style and pass_style.color and copy_color_into(pass_style.color, color) then
			dirty = true
		end
	end

	if dirty then
		widget.dirty = true
	end
end

local function is_ability_on_cooldown(player_unit)
	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(COMBAT_ABILITY_TYPE) then
		return false
	end

	local max_cd = ability_extension:max_ability_cooldown(COMBAT_ABILITY_TYPE) or 0
	local rem_cd = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE) or 0

	if max_cd > 0 and rem_cd > 0 then
		return true
	end

	if CombatAbilityBar.is_ability_effect_active and CombatAbilityBar.is_ability_effect_active(player_unit, COMBAT_ABILITY_TYPE) then
		return true
	end

	return false
end

function M.init(self, definitions)
	self._ability_icon_alpha_mult = 0
	self._ability_icon_unit = nil
	self._ability_icon_name = nil
	self._ability_icon_value = nil
	self._ability_icon_state = nil
	self._ability_icon_active_colors = definitions and definitions.ABILITY_ICON_ACTIVE_COLORS
	self._ability_icon_cooldown_colors = definitions and definitions.ABILITY_ICON_COOLDOWN_COLORS

	local size = (definitions and definitions.ABILITY_ICON_SIZE) or 28
	local overlap = (definitions and definitions.ABILITY_ICON_OVERLAP) or 8

	self._ability_icon_slide_px = math.max(0, size - overlap)
	self._ability_icon_enter_dur = (definitions and definitions.ABILITY_ICON_ENTER_DUR) or 0.2
	self._ability_icon_exit_dur = (definitions and definitions.ABILITY_ICON_EXIT_DUR) or 0.16
	self._ability_icon_hidden_x = self._ability_icon_slide_px

	reset_anim(self)

	local widget = self._widgets_by_name and self._widgets_by_name.ability_icon

	reset_widget(widget)

	if self.set_scenegraph_position then
		self:set_scenegraph_position("div_ability_icon_area", self._ability_icon_hidden_x or 0, 0)
	end
end

function M.update(self, player_unit, opacity, dt)
	dt = (type(dt) == "number" and dt == dt and dt > 0) and dt or 0

	local widget = self._widgets_by_name and self._widgets_by_name.ability_icon

	if not widget or not widget.content then
		return
	end

	local settings = mod._settings
	local feature_enabled = type(settings) ~= "table" or settings.show_ability_icon ~= false and settings.show_ability_icon ~= 0
	local is_requested = false

	if feature_enabled and player_unit and ALIVE[player_unit] then
		is_requested = CombatAbilityBar.is_ability_in_use_or_on_cooldown(player_unit, COMBAT_ABILITY_TYPE) and true or false
	end

	local alpha = self._ability_icon_alpha_mult or 0
	local alpha_speed = is_requested and 10 or 6
	local anim = self._ability_icon_anim
	local slide_px = self._ability_icon_slide_px or 0
	local hidden_x = self._ability_icon_hidden_x or -slide_px
	local enter_dur = self._ability_icon_enter_dur or 0.2
	local exit_dur = self._ability_icon_exit_dur or 0.16

	if is_requested then
		alpha = math.min(alpha + dt * alpha_speed, 1)
	else
		alpha = math.max(alpha - dt * alpha_speed, 0)
	end

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

	self._ability_icon_alpha_mult = alpha

	if alpha <= 0 and not is_requested then
		reset_widget(widget)
		reset_anim(self)
		self._ability_icon_state = nil

		if self.set_scenegraph_position then
			self:set_scenegraph_position("div_ability_icon_area", hidden_x, 0)
		end

		return
	end

	if is_requested then
		local icon = resolve_ability_icon(self, player_unit)
		local style = widget.style
		local icon_style = style and style.icon
		local material_values = icon_style and icon_style.material_values

		if material_values and material_values.talent_icon ~= icon then
			material_values.talent_icon = icon
			widget.dirty = true
		end

		local progress = compute_cooldown_progress(player_unit)

		if widget.content.duration_progress ~= progress then
			widget.content.duration_progress = progress
			widget.dirty = true
		end

		local on_cooldown = is_ability_on_cooldown(player_unit)
		local target_state = on_cooldown and "cooldown" or "active"

		if self._ability_icon_state ~= target_state then
			self._ability_icon_state = target_state

			apply_state_colors(self, widget, target_state)
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
		self:set_scenegraph_position("div_ability_icon_area", anim.x_offset or 0, 0)
	end

	if anim.state ~= "hidden" and (anim.alpha or 0) > 0 then
		widget.content.visible = true
		widget.alpha_multiplier = opacity * alpha * anim.alpha
		widget.dirty = true
	else
		reset_widget(widget)
	end
end

function M.destroy(self)
	local widget = self._widgets_by_name and self._widgets_by_name.ability_icon

	reset_widget(widget)
	reset_anim(self)

	self._ability_icon_alpha_mult = 0
	self._ability_icon_unit = nil
	self._ability_icon_name = nil
	self._ability_icon_value = nil
	self._ability_icon_state = nil

	if self.set_scenegraph_position then
		self:set_scenegraph_position("div_ability_icon_area", self._ability_icon_hidden_x or 0, 0)
	end
end

return M
