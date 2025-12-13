local mod = get_mod("TeamKills")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

-- Добавляем слой в тактический оверлей (TAB)
mod:hook_require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_definitions", function(instance)
	local width = 800
	local height = 500
	instance.scenegraph_definition.killsboard = {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = {width, height},
		position = {0, 0, 150},
	}

	instance.widget_definitions.killsboard = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = {160, 10, 10, 10},
				size = {width, height},
				offset = {0, 0, 0},
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			value = "Killsboard (WIP)",
			style = {
				font_type = "machine_medium",
				font_size = 28,
				text_horizontal_alignment = "center",
				text_vertical_alignment = "top",
				text_color = {255, 255, 255, 255},
				offset = {0, height / 2 - 60, 2},
				size = {width, 40},
			},
		},
	}, "killsboard")
end)

-- Рисуем виджет при активном тактическом оверлее
mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings, ...)
	func(self, dt, t, input_service, ui_renderer, render_settings, ...)

	local widget = self._widgets_by_name and self._widgets_by_name["killsboard"]
	if widget then
		widget.alpha_multiplier = self._alpha_multiplier or 1
		UIWidget.draw(widget, ui_renderer)
	end
end)

