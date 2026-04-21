local mod = get_mod("DivisionHUD")
local Localization = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/localization")
local language_id = Application.user_setting("language_id")

local M = {}

if type(Localization) ~= "table" then
	Localization = {}
end

local function danger_zone_label()
	local entry = Localization.danger_zone_label

	if type(entry) == "table" then
		local localized = entry[language_id] or entry.en

		if type(localized) == "string" and localized ~= "" then
			return localized
		end
	end

	return "Danger zone"
end

local function danger_zone_reset_widget(widget)
	if not widget or not widget.content then
		return
	end

	widget.content.visible = false
	widget.content.label_text = danger_zone_label()
	widget.content.source_text = ""
	widget.content.distance_text = "0m"
	widget.alpha_multiplier = 0
	widget.dirty = true
end

function M.init(self)
	self._danger_zone_alpha_mult = 0
	self._danger_zone_active = false

	local widget = self._widgets_by_name and self._widgets_by_name.danger_zone

	danger_zone_reset_widget(widget)
end

function M.update(self, opacity, dt)
	dt = (type(dt) == "number" and dt == dt and dt > 0) and dt or 0

	local widget = self._widgets_by_name and self._widgets_by_name.danger_zone
	local data = self._danger_zone_data or {}
	local is_requested = data.active == true
	local alpha = self._danger_zone_alpha_mult or 0
	local alpha_speed = is_requested and 10 or 6

	if is_requested then
		alpha = math.min(alpha + dt * alpha_speed, 1)
	else
		alpha = math.max(alpha - dt * alpha_speed, 0)
	end

	self._danger_zone_alpha_mult = alpha
	self._danger_zone_active = is_requested or alpha > 0

	if not widget or not widget.content then
		return
	end

	if is_requested then
		widget.content.label_text = danger_zone_label()
		widget.content.source_text = data.source_name or ""
		widget.content.distance_text = string.format("%dm", math.max(0, data.distance_m or 0))
	end

	if alpha <= 0 and not is_requested then
		danger_zone_reset_widget(widget)
		return
	end

	widget.content.visible = true
	widget.alpha_multiplier = opacity * alpha
	widget.dirty = true
end

function M.destroy(self)
	local widget = self._widgets_by_name and self._widgets_by_name.danger_zone

	danger_zone_reset_widget(widget)

	self._danger_zone_alpha_mult = 0
	self._danger_zone_active = false
end

return M
