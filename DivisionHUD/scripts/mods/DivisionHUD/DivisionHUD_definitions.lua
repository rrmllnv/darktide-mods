local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local BIG_AMMO_BOX = 120
local GAP_LEFT_TO_GRID = 40
local RIGHT_CELL = 58
local RIGHT_GAP = 4
local RIGHT_GRID_WIDTH = RIGHT_CELL * 2 + RIGHT_GAP
local MAIN_ROW_HEIGHT = BIG_AMMO_BOX
local ROW_WIDTH = BIG_AMMO_BOX + GAP_LEFT_TO_GRID + RIGHT_GRID_WIDTH
local BUFF_SIZE = 32
local BUFF_SPACING = 4
local BAR_WIDTH = ROW_WIDTH
local BAR_HEIGHT = 8

local HUD_WEAPON_ICON_CONTAINER = "content/ui/materials/hud/icons/weapon_icon_container"
local RIGHT_SLOT_ICON_FALLBACK = "content/ui/materials/icons/weapons/flat/grenade"
local DEFAULT_COMBAT_ABILITY_ICON_TEXTURE = "content/ui/materials/icons/abilities/throwables/default"

local RIGHT_GRID_ORIGIN_X = BIG_AMMO_BOX + GAP_LEFT_TO_GRID

local function text_style_from_hud_body(font_size, offset)
	local style = table.clone(UIFontSettings.hud_body)
	style.font_size = font_size
	style.drop_shadow = true
	style.text_horizontal_alignment = "center"
	style.text_vertical_alignment = "center"
	style.text_color = UIHudSettings.color_tint_main_1
	style.offset = offset or { 0, 0, 2 }
	return style
end

local scenegraph_definition = {
	screen = {
		scale = "fit",
		size = { 1920, 1080 },
		position = { 0, 0, 0 },
	},
	root = {
		parent = "screen",
		horizontal_alignment = "center",
		vertical_alignment = "center",
		size = { ROW_WIDTH, 200 },
		position = { 300, 200, 100 },
	},
	stamina_bar = {
		parent = "root",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, 0, 0 },
	},
	health_bar = {
		parent = "stamina_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, BAR_HEIGHT + 2, 0 },
	},
	ability_bar = {
		parent = "health_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, BAR_HEIGHT + 2, 0 },
	},
	boxes_row = {
		parent = "ability_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { ROW_WIDTH, MAIN_ROW_HEIGHT },
		position = { 0, BAR_HEIGHT + 8, 0 },
	},
	ammo_big = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BIG_AMMO_BOX, BIG_AMMO_BOX },
		position = { 0, 0, 0 },
	},
	slot_blitz = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_CELL, RIGHT_CELL },
		position = { RIGHT_GRID_ORIGIN_X, 0, 0 },
	},
	slot_stimm = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_CELL, RIGHT_CELL },
		position = { RIGHT_GRID_ORIGIN_X + RIGHT_CELL + RIGHT_GAP, 0, 0 },
	},
	slot_pickup = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_CELL, RIGHT_CELL },
		position = { RIGHT_GRID_ORIGIN_X, RIGHT_CELL + RIGHT_GAP, 0 },
	},
	slot_ultimate = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_CELL, RIGHT_CELL },
		position = { RIGHT_GRID_ORIGIN_X + RIGHT_CELL + RIGHT_GAP, RIGHT_CELL + RIGHT_GAP, 0 },
	},
	buffs_row = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { ROW_WIDTH, BUFF_SIZE },
		position = { 0, MAIN_ROW_HEIGHT + 8, 0 },
	},
}

local function create_bar_widget(scenegraph_id, color)
	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 160, 0, 0, 0 },
				offset = { 0, 0, 0 },
				size = { BAR_WIDTH, BAR_HEIGHT },
			},
		},
		{
			pass_type = "rect",
			style_id = "fill",
			value_id = "fill",
			style = {
				horizontal_alignment = "left",
				color = color or { 255, 100, 200, 100 },
				offset = { 0, 0, 1 },
				size = { BAR_WIDTH, BAR_HEIGHT },
			},
		},
	}, scenegraph_id)
end

local function create_ammo_big_widget(scenegraph_id)
	local text_style = text_style_from_hud_body(56, { 0, -14, 2 })
	local text_style_reserve = text_style_from_hud_body(26, { 0, 30, 2 })

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 200, 0, 0, 0 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "0",
			style_id = "text",
			style = text_style,
		},
		{
			pass_type = "text",
			value_id = "text_reserve",
			value = "0",
			style_id = "text_reserve",
			style = text_style_reserve,
		},
	}, scenegraph_id)
end

local function create_right_slot_widget(scenegraph_id)
	local text_style = text_style_from_hud_body(14, { 0, 18, 3 })

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 200, 60, 60, 60 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "texture",
			style_id = "icon",
			value = RIGHT_SLOT_ICON_FALLBACK,
			value_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 38, 38 },
				offset = { 0, -8, 1 },
				color = { 255, 255, 255, 255 },
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "0",
			style_id = "text",
			style = text_style,
		},
	}, scenegraph_id)
end

local function create_combat_ability_right_slot_widget(scenegraph_id)
	local text_style = text_style_from_hud_body(14, { 0, 18, 3 })

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 200, 60, 60, 60 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "texture",
			style_id = "icon",
			value = HUD_WEAPON_ICON_CONTAINER,
			value_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 38, 38 },
				offset = { 0, -8, 1 },
				color = { 255, 255, 255, 255 },
				material_values = {
					texture_map = DEFAULT_COMBAT_ABILITY_ICON_TEXTURE,
					use_placeholder_texture = 0,
				},
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "0",
			style_id = "text",
			style = text_style,
		},
	}, scenegraph_id)
end

local widget_definitions = {
	stamina_bar = create_bar_widget("stamina_bar", { 255, 100, 200, 255 }),
	health_bar = create_bar_widget("health_bar", { 255, 100, 255, 100 }),
	ability_bar = create_bar_widget("ability_bar", { 255, 255, 50, 50 }),
	ammo_big = create_ammo_big_widget("ammo_big"),
	slot_blitz = create_right_slot_widget("slot_blitz"),
	slot_stimm = create_right_slot_widget("slot_stimm"),
	slot_pickup = create_right_slot_widget("slot_pickup"),
	slot_ultimate = create_combat_ability_right_slot_widget("slot_ultimate"),
}

local right_slot_widget_names = {
	"slot_blitz",
	"slot_stimm",
	"slot_pickup",
	"slot_ultimate",
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	BAR_WIDTH = BAR_WIDTH,
	ROW_WIDTH = ROW_WIDTH,
	BUFF_SIZE = BUFF_SIZE,
	BUFF_SPACING = BUFF_SPACING,
	RIGHT_SLOT_COUNT = 4,
	right_slot_widget_names = right_slot_widget_names,
	HUD_WEAPON_ICON_CONTAINER = HUD_WEAPON_ICON_CONTAINER,
	RIGHT_SLOT_ICON_FALLBACK = RIGHT_SLOT_ICON_FALLBACK,
	DEFAULT_COMBAT_ABILITY_ICON_TEXTURE = DEFAULT_COMBAT_ABILITY_ICON_TEXTURE,
}
