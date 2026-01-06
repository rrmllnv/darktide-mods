local mod = get_mod("ConsoleLog")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local HudElementConsoleLog = class("HudElementConsoleLog", HudElementBase)

-- Scenegraph definition
local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	console_log_panel = {
		parent = "screen",
		size = {800, 400},
		position = {50, 50, 100},
	},
}

-- Widget definitions
local widget_definitions = {
	console_log_panel = UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = {200, 0, 0, 0},
				offset = {0, 0, 0},
			},
		},
		{
			pass_type = "text",
			style_id = "text",
			value = "",
			value_id = "text",
			style = table.clone(UIFontSettings.body, {
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				horizontal_alignment = "left",
				vertical_alignment = "top",
				font_size = 16,
				offset = {10, 10, 1},
			}),
		},
	}, "console_log_panel"),
}

HudElementConsoleLog.init = function(self, parent, draw_layer, start_scale)
	HudElementConsoleLog.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	
	self._logs = {}
	self._max_lines = mod:get("max_lines") or 20
end

HudElementConsoleLog.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	if not mod:get("enabled") then
		return
	end
	
	HudElementConsoleLog.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	-- Получаем логи из глобального API
	local console_log_mod = get_mod("ConsoleLog")
	if console_log_mod and console_log_mod._logs then
		self._logs = console_log_mod._logs
	end
	
	-- Обновляем текст
	local widget = self._widgets_by_name.console_log_panel
	if widget then
		-- Объединяем все логи в один текст
		local text_lines = {}
		local max_lines = math.min(#self._logs, self._max_lines)
		
		for i = math.max(1, #self._logs - max_lines + 1), #self._logs do
			local log_entry = self._logs[i]
			if log_entry then
				local prefix = string.format("[%s]: ", log_entry.mod_name or "Unknown")
				local line = prefix .. (log_entry.text or "")
				table.insert(text_lines, line)
			end
		end
		
		local full_text = table.concat(text_lines, "\n")
		widget.content.text = full_text
		widget.content.visible = #self._logs > 0
		
		-- Обновляем стиль текста
		local text_style = widget.style.text
		if text_style then
			text_style.font_size = mod:get("font_size") or 16
		end
		
		-- Обновляем фон
		local bg_style = widget.style.background
		if bg_style then
			local opacity = mod:get("background_opacity") or 200
			bg_style.color = {opacity, 0, 0, 0}
		end
		
		-- Обновляем позицию
		local position = mod:get("position") or "top_left"
		local scenegraph_id = "console_log_panel"
		local scenegraph = self._ui_scenegraph
		
		if scenegraph and scenegraph[scenegraph_id] then
			local pos = scenegraph[scenegraph_id].position
			if position == "top_left" then
				pos[1] = 50
				pos[2] = 50
			elseif position == "top_right" then
				pos[1] = -850
				pos[2] = 50
			elseif position == "bottom_left" then
				pos[1] = 50
				pos[2] = -450
			elseif position == "bottom_right" then
				pos[1] = -850
				pos[2] = -450
			end
		end
	end
end

return HudElementConsoleLog

