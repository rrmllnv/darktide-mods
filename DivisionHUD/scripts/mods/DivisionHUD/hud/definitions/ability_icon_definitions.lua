local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local M = {}

local ABILITY_ICON_BASE_GAP = 8
local ABILITY_ICON_BASE_HEIGHT = 48
local ABILITY_ICON_BASE_OVERLAP = 12
local ABILITY_ICON_NATIVE_W = 92
local ABILITY_ICON_NATIVE_H = 80
local ABILITY_ICON_FRAME_NATIVE = 128
local ABILITY_ICON_ENTER_DUR = 0.2
local ABILITY_ICON_EXIT_DUR = 0.16
local ABILITY_ICON_MATERIAL = "content/ui/materials/icons/talents/hud/combat_container"
local ABILITY_ICON_FRAME_MATERIAL = "content/ui/materials/icons/talents/hud/combat_frame_inner"
local ABILITY_ICON_GLOW_MATERIAL = "content/ui/materials/effects/hud/combat_talent_glow"

local function _identity_sc(n)
	return n
end

local function _resolve_metrics(sc)
	local sc_fn = type(sc) == "function" and sc or _identity_sc
	local height = math.max(1, sc_fn(ABILITY_ICON_BASE_HEIGHT))
	local width = math.max(1, math.floor(height * ABILITY_ICON_NATIVE_W / ABILITY_ICON_NATIVE_H + 0.5))
	local frame_size = math.max(1, math.floor(ABILITY_ICON_FRAME_NATIVE * (height / ABILITY_ICON_NATIVE_H) + 0.5))
	local gap = math.max(0, sc_fn(ABILITY_ICON_BASE_GAP))
	local overlap = math.max(0, sc_fn(ABILITY_ICON_BASE_OVERLAP))

	return {
		width = width,
		height = height,
		frame_size = frame_size,
		gap = gap,
		overlap = overlap,
	}
end

local function _hud_color(name, alpha)
	local getter = UIHudSettings and UIHudSettings.get_hud_color

	if type(getter) == "function" then
		local ok, c = pcall(getter, name, alpha)

		if ok and type(c) == "table" then
			return c
		end
	end

	return { alpha or 255, 255, 255, 255 }
end

M.ACTIVE_COLORS = {
	icon = _hud_color("color_tint_main_2", 200),
	frame = _hud_color("color_tint_main_2", 255),
	frame_glow = _hud_color("color_tint_main_1", 255),
}

M.COOLDOWN_COLORS = {
	icon = _hud_color("color_tint_main_3", 200),
	frame = _hud_color("color_tint_main_3", 255),
	frame_glow = _hud_color("color_tint_main_3", 0),
}

local function build_scenegraph(ability_bar_width, metrics)
	local area_width = metrics.width
	local area_height = metrics.height
	local anchor_x = ability_bar_width + metrics.gap

	return {
		div_ability_icon_anchor = {
			parent = "ability_bar",
			horizontal_alignment = "left",
			vertical_alignment = "bottom",
			size = { area_width, area_height },
			position = { anchor_x, 0, 10 },
		},
		div_ability_icon_area = {
			parent = "div_ability_icon_anchor",
			horizontal_alignment = "left",
			vertical_alignment = "bottom",
			size = { area_width, area_height },
			position = { 0, 0, 0 },
		},
	}
end

local function build_widget_definition(metrics)
	local w = metrics.width
	local h = metrics.height
	local frame_size = metrics.frame_size

	return UIWidget.create_definition({
		{
			pass_type = "texture",
			value = ABILITY_ICON_MATERIAL,
			style_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				material_values = {
					progress = 1,
					talent_icon = nil,
				},
				size = { w, h },
				offset = { 0, 0, 1 },
				color = table.clone(M.ACTIVE_COLORS.icon),
			},
			change_function = function(content, style)
				style.material_values.progress = content.duration_progress or 1
			end,
		},
		{
			pass_type = "texture",
			value = ABILITY_ICON_FRAME_MATERIAL,
			style_id = "frame",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { frame_size, frame_size },
				offset = { 0, 0, 3 },
				color = table.clone(M.ACTIVE_COLORS.frame),
			},
		},
		{
			pass_type = "texture",
			value = ABILITY_ICON_GLOW_MATERIAL,
			style_id = "frame_glow",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { frame_size, frame_size },
				offset = { 0, 0, 4 },
				color = table.clone(M.ACTIVE_COLORS.frame_glow),
			},
		},
	}, "div_ability_icon_area")
end

function M.build(ability_bar_width, ability_bar_strip_height, sc)
	local metrics = _resolve_metrics(sc)
	local scenegraph_definition = build_scenegraph(ability_bar_width, metrics)

	return {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = {
			ability_icon = build_widget_definition(metrics),
		},
		ABILITY_ICON_SIZE = metrics.width,
		ABILITY_ICON_OVERLAP = metrics.overlap,
		ABILITY_ICON_ENTER_DUR = ABILITY_ICON_ENTER_DUR,
		ABILITY_ICON_EXIT_DUR = ABILITY_ICON_EXIT_DUR,
		ABILITY_ICON_ACTIVE_COLORS = M.ACTIVE_COLORS,
		ABILITY_ICON_COOLDOWN_COLORS = M.COOLDOWN_COLORS,
	}
end

return M
