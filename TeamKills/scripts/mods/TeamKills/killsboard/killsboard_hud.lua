local mod = get_mod("TeamKills")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local categories = {
	{"melee_lessers", "Melee lessers"},
	{"ranged_lessers", "Ranged lessers"},
	{"melee_elites", "Melee elites"},
	{"ranged_elites", "Ranged elites"},
	{"specials", "Specials"},
	{"disablers", "Disablers"},
	{"bosses", "Bosses"},
}

local function build_lines()
	local kills_color = mod.get_kills_color_string()
	local damage_color = mod.get_damage_color_string()
	local reset = "{#reset()}"

	local lines = {}
	local total_kills = 0
	local total_damage = 0

	for _, data in ipairs(categories) do
		local key, label = data[1], data[2]
		local kills_sum = 0
		local dmg_sum = 0

		for _, account_data in pairs(mod.kills_by_category or {}) do
			kills_sum = kills_sum + (account_data[key] or 0)
		end
		for _, account_data in pairs(mod.damage_by_category or {}) do
			dmg_sum = dmg_sum + (account_data[key] or 0)
		end

		total_kills = total_kills + kills_sum
		total_damage = total_damage + dmg_sum

		table.insert(lines, string.format("%s: %s%d%s (%s%s%s)", label, kills_color, kills_sum, reset, damage_color, mod.format_number(dmg_sum), reset))
	end

	table.insert(lines, 1, string.format("TOTAL: %s%d%s (%s%s%s)", kills_color, total_kills, reset, damage_color, mod.format_number(total_damage), reset))

	return table.concat(lines, "\n")
end

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
				offset = {-width / 2, -height / 2, 0},
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			value = "",
			style = {
				font_type = "machine_medium",
				font_size = 22,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = UIHudSettings.color_tint_1,
				-- Отступы внутрь фона
				offset = {-width / 2 + 10, height / 2 - 20, 1},
				size = {width - 20, height - 40},
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
		widget.content.text = build_lines()
		UIWidget.draw(widget, ui_renderer)
	end
end)

