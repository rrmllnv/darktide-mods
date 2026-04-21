local mod = get_mod("DivisionHUD")
local Localization = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/localization")
local language_id = Application.user_setting("language_id")

local M = {}

if type(Localization) ~= "table" then
	Localization = {}
end

local function localized_text(key, fallback)
	local entry = Localization[key]

	if type(entry) == "table" then
		local localized = entry[language_id] or entry.en

		if type(localized) == "string" and localized ~= "" then
			return localized
		end
	end

	return fallback
end

local function danger_zone_label()
	return localized_text("danger_zone_label", "Danger zone")
end

local function danger_zone_warning_label()
	return localized_text("danger_zone_in_zone", "In blast\nzone")
end

local function danger_zone_reset_widget(widget)
	if not widget or not widget.content then
		return
	end

	widget.content.visible = false
	widget.content.label_text = danger_zone_label()
	widget.content.source_text = ""
	widget.content.distance_text = ""
	widget.alpha_multiplier = 0
	widget.dirty = true
end

local function danger_zone_reset_warning_widget(widget)
	if not widget or not widget.content then
		return
	end

	widget.content.visible = false
	widget.content.warning_text = danger_zone_warning_label()
	widget.alpha_multiplier = 0
	widget.dirty = true
end

local function round_to_int(value)
	if value >= 0 then
		return math.floor(value + 0.5)
	end

	return math.ceil(value - 0.5)
end

local function danger_zone_reset_warning_anim(self)
	self._danger_zone_warning_anim = {
		state = "hidden",
		timer = 0,
		alpha = 0,
		x_offset = self._danger_zone_warning_hidden_x or 0,
	}
end

function M.init(self, definitions)
	self._danger_zone_alpha_mult = 0
	self._danger_zone_active = false
	self._danger_zone_warning_slide_px = math.max(
		0,
		(definitions and definitions.DANGER_ZONE_WARNING_WIDTH or 84) - (definitions and definitions.DANGER_ZONE_WARNING_OVERLAP or 10)
	)
	self._danger_zone_warning_enter_dur = (definitions and definitions.DANGER_ZONE_WARNING_ENTER_DUR) or 0.2
	self._danger_zone_warning_exit_dur = (definitions and definitions.DANGER_ZONE_WARNING_EXIT_DUR) or 0.16
	self._danger_zone_warning_hidden_x = -self._danger_zone_warning_slide_px
	danger_zone_reset_warning_anim(self)

	local widget = self._widgets_by_name and self._widgets_by_name.danger_zone
	local warning_widget = self._widgets_by_name and self._widgets_by_name.danger_zone_warning

	danger_zone_reset_widget(widget)
	danger_zone_reset_warning_widget(warning_widget)

	if self.set_scenegraph_position then
		self:set_scenegraph_position("div_danger_zone_warning_area", self._danger_zone_warning_hidden_x or 0, 0)
	end
end

function M.update(self, opacity, dt)
	dt = (type(dt) == "number" and dt == dt and dt > 0) and dt or 0

	local widget = self._widgets_by_name and self._widgets_by_name.danger_zone
	local warning_widget = self._widgets_by_name and self._widgets_by_name.danger_zone_warning
	local data = self._danger_zone_data or {}
	local is_requested = data.active == true
	local is_inside_zone = is_requested and math.max(0, data.distance_m or 0) <= 0
	local alpha = self._danger_zone_alpha_mult or 0
	local alpha_speed = is_requested and 10 or 6
	local warning_anim = self._danger_zone_warning_anim
	local slide_px = self._danger_zone_warning_slide_px or 0
	local hidden_x = self._danger_zone_warning_hidden_x or -slide_px
	local enter_dur = self._danger_zone_warning_enter_dur or 0.2
	local exit_dur = self._danger_zone_warning_exit_dur or 0.16

	if is_requested then
		alpha = math.min(alpha + dt * alpha_speed, 1)
	else
		alpha = math.max(alpha - dt * alpha_speed, 0)
	end

	if is_inside_zone and warning_anim.state == "exit" then
		warning_anim.state = "enter"
		warning_anim.timer = enter_dur * (1 - warning_anim.alpha)
		warning_anim.x_offset = round_to_int(hidden_x * (1 - warning_anim.alpha))
	elseif is_inside_zone and warning_anim.state == "hidden" then
		warning_anim.state = "enter"
		warning_anim.timer = 0
		warning_anim.alpha = 0
		warning_anim.x_offset = hidden_x
	elseif not is_inside_zone and (warning_anim.state == "enter" or warning_anim.state == "hold") then
		warning_anim.state = "exit"
		warning_anim.timer = exit_dur * (1 - warning_anim.alpha)
	end

	self._danger_zone_alpha_mult = alpha
	self._danger_zone_active = is_requested or alpha > 0

	if not widget or not widget.content or not warning_widget or not warning_widget.content then
		return
	end

	if is_requested then
		widget.content.label_text = danger_zone_label()
		widget.content.source_text = data.source_name or ""
		local distance_m = math.max(0, data.distance_m or 0)
		widget.content.distance_text = distance_m > 0 and string.format("%dm", distance_m) or ""
		warning_widget.content.warning_text = danger_zone_warning_label()
	end

	if alpha <= 0 and not is_requested then
		danger_zone_reset_widget(widget)
		danger_zone_reset_warning_widget(warning_widget)
		danger_zone_reset_warning_anim(self)

		if self.set_scenegraph_position then
			self:set_scenegraph_position("div_danger_zone_warning_area", hidden_x, 0)
		end

		return
	end

	widget.content.visible = true
	widget.alpha_multiplier = opacity * alpha
	widget.dirty = true

	warning_anim.timer = warning_anim.timer + dt

	if warning_anim.state == "enter" then
		local p = math.min(1, warning_anim.timer / enter_dur)
		local ep = math.easeOutCubic(p)

		warning_anim.alpha = ep
		warning_anim.x_offset = round_to_int(hidden_x * (1 - ep))

		if p >= 1 then
			warning_anim.state = "hold"
			warning_anim.alpha = 1
			warning_anim.x_offset = 0
		end
	elseif warning_anim.state == "hold" then
		warning_anim.alpha = 1
		warning_anim.x_offset = 0
	elseif warning_anim.state == "exit" then
		local p = math.min(1, warning_anim.timer / exit_dur)
		local ep = math.easeOutCubic(p)

		warning_anim.alpha = 1 - ep
		warning_anim.x_offset = round_to_int(hidden_x * ep)

		if p >= 1 then
			warning_anim.state = "hidden"
			warning_anim.alpha = 0
			warning_anim.x_offset = hidden_x
		end
	end

	if self.set_scenegraph_position then
		self:set_scenegraph_position("div_danger_zone_warning_area", warning_anim.x_offset or 0, 0)
	end

	if warning_anim.state ~= "hidden" and (warning_anim.alpha or 0) > 0 then
		warning_widget.content.visible = true
		warning_widget.alpha_multiplier = opacity * alpha * warning_anim.alpha
		warning_widget.dirty = true
	else
		danger_zone_reset_warning_widget(warning_widget)
	end
end

function M.destroy(self)
	local widget = self._widgets_by_name and self._widgets_by_name.danger_zone
	local warning_widget = self._widgets_by_name and self._widgets_by_name.danger_zone_warning

	danger_zone_reset_widget(widget)
	danger_zone_reset_warning_widget(warning_widget)
	danger_zone_reset_warning_anim(self)

	self._danger_zone_alpha_mult = 0
	self._danger_zone_active = false

	if self.set_scenegraph_position then
		self:set_scenegraph_position("div_danger_zone_warning_area", self._danger_zone_warning_hidden_x or 0, 0)
	end
end

return M
