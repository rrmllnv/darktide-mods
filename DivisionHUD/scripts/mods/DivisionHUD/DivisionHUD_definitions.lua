local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementPlayerWeaponHandlerSettings = require("scripts/ui/hud/elements/player_weapon_handler/hud_element_player_weapon_handler_settings")

local LAYOUT_SCALE = 0.8

local function sc(n)
	if n == 0 then
		return 0
	end

	local sign = n < 0 and -1 or 1
	local a = math.abs(n)

	return sign * math.max(1, math.floor(a * LAYOUT_SCALE + 0.5))
end

local BIG_AMMO_W = sc(120)
local GAP_LEFT_TO_GRID = sc(12)
local RIGHT_CELL = sc(58)
local RIGHT_GAP = sc(4)
local RIGHT_GRID_WIDTH = RIGHT_CELL * 2 + RIGHT_GAP
local RIGHT_BOTTOM_ROW_GAP = sc(4)
local RIGHT_BOTTOM_SLOT_HEIGHT = sc(40)
local REFERENCE_AMMO_BOX_FOR_WIELDED_ROW = sc(120)
local REFERENCE_BOTTOM_CELL_FOR_WIELDED_ROW = sc(58)
local WIELDED_ROW_HEIGHT = math.max(
	sc(28),
	REFERENCE_AMMO_BOX_FOR_WIELDED_ROW - REFERENCE_BOTTOM_CELL_FOR_WIELDED_ROW - RIGHT_BOTTOM_ROW_GAP
)
local RIGHT_BOTTOM_SLOT_WIDTH = math.max(sc(26), math.floor((RIGHT_GRID_WIDTH - 2 * RIGHT_GAP) / 3))
local RIGHT_COLUMN_TOTAL_HEIGHT = WIELDED_ROW_HEIGHT + RIGHT_BOTTOM_ROW_GAP + RIGHT_BOTTOM_SLOT_HEIGHT
local BIG_AMMO_H = RIGHT_COLUMN_TOTAL_HEIGHT
local MAIN_ROW_HEIGHT = RIGHT_COLUMN_TOTAL_HEIGHT
local ROW_WIDTH = BIG_AMMO_W + GAP_LEFT_TO_GRID + RIGHT_GRID_WIDTH
local BAR_WIDTH = ROW_WIDTH
local BAR_HEIGHT = sc(8)
local BAR_STACK_GAP = sc(2)
local BOXES_ROW_TOP_GAP = sc(8)
local ROOT_HEIGHT = sc(212) - sc(32) - sc(8)
local SLOT_ICON_TEXTURE_SIZE = sc(22)
local ECW_WEAPON_ICON_LAYOUT_SCALE = 0.5
local _weapon_icon_sz = HudElementPlayerWeaponHandlerSettings.weapon_icon_size
local WEAPON_ICON_NATIVE_W = 256
local WEAPON_ICON_NATIVE_H = 96

if type(_weapon_icon_sz) == "table" and type(_weapon_icon_sz[1]) == "number" and type(_weapon_icon_sz[2]) == "number" and _weapon_icon_sz[2] > 0 then
	WEAPON_ICON_NATIVE_W = _weapon_icon_sz[1]
	WEAPON_ICON_NATIVE_H = _weapon_icon_sz[2]
end

local WEAPON_STRIP_ICON_ASPECT_RATIO = WEAPON_ICON_NATIVE_W / WEAPON_ICON_NATIVE_H
local WEAPON_STRIP_ICON_H = sc(math.floor(WEAPON_ICON_NATIVE_H * ECW_WEAPON_ICON_LAYOUT_SCALE + 0.5))
local WEAPON_STRIP_ICON_W = math.max(1, math.floor(WEAPON_STRIP_ICON_H * WEAPON_STRIP_ICON_ASPECT_RATIO + 0.5))
local WEAPON_STRIP_MAX_W = math.max(1, RIGHT_GRID_WIDTH - sc(4))

if WEAPON_STRIP_ICON_W > WEAPON_STRIP_MAX_W then
	WEAPON_STRIP_ICON_W = WEAPON_STRIP_MAX_W
	WEAPON_STRIP_ICON_H = math.max(1, math.floor(WEAPON_STRIP_ICON_W / WEAPON_STRIP_ICON_ASPECT_RATIO + 0.5))
end

if WEAPON_STRIP_ICON_H > WIELDED_ROW_HEIGHT then
	WEAPON_STRIP_ICON_H = math.max(1, WIELDED_ROW_HEIGHT - sc(2))
	WEAPON_STRIP_ICON_W = math.max(1, math.floor(WEAPON_STRIP_ICON_H * WEAPON_STRIP_ICON_ASPECT_RATIO + 0.5))

	if WEAPON_STRIP_ICON_W > WEAPON_STRIP_MAX_W then
		WEAPON_STRIP_ICON_W = WEAPON_STRIP_MAX_W
		WEAPON_STRIP_ICON_H = math.max(1, math.floor(WEAPON_STRIP_ICON_W / WEAPON_STRIP_ICON_ASPECT_RATIO + 0.5))
	end
end

local _handler_icon_sz = HudElementPlayerWeaponHandlerSettings.icon_size
local WIELDED_SQUARE_ICON_SOURCE = 84

if type(_handler_icon_sz) == "table" and type(_handler_icon_sz[1]) == "number" then
	local a = _handler_icon_sz[1]
	local b = type(_handler_icon_sz[2]) == "number" and _handler_icon_sz[2] or a

	WIELDED_SQUARE_ICON_SOURCE = math.min(a, b)
end

local WIELDED_STRIP_SQUARE_ICON = math.min(
	sc(WIELDED_SQUARE_ICON_SOURCE),
	math.max(1, WIELDED_ROW_HEIGHT - sc(2)),
	math.max(1, RIGHT_GRID_WIDTH - sc(4))
)
local SLOT_TEXT_FONT = sc(16)
local SLOT_ICON_LEFT_INSET = sc(3)
local SLOT_TEXT_RIGHT_INSET = sc(4)
local AMMO_CLIP_FONT = sc(56)
local AMMO_RESERVE_FONT = sc(26)
local AMMO_CLIP_OFFSET_Y = sc(14)
local AMMO_RESERVE_OFFSET_Y = sc(30)

local HUD_GLASS_PLATE_ALPHA_BASE = 48
local HUD_GLASS_PLATE_COLOR = {
	HUD_GLASS_PLATE_ALPHA_BASE,
	232,
	240,
	255,
}

local HUD_WEAPON_ICON_CONTAINER = "content/ui/materials/hud/icons/weapon_icon_container"
local RIGHT_SLOT_ICON_FALLBACK = "content/ui/materials/icons/weapons/flat/grenade"
local RIGHT_GRID_ORIGIN_X = BIG_AMMO_W + GAP_LEFT_TO_GRID
local RIGHT_BOTTOM_ROW_Y = WIELDED_ROW_HEIGHT + RIGHT_BOTTOM_ROW_GAP

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

local function text_style_slot_counter_right(font_size, right_inset)
	local style = table.clone(UIFontSettings.hud_body)
	style.font_size = font_size
	style.drop_shadow = true
	style.text_horizontal_alignment = "right"
	style.text_vertical_alignment = "center"
	style.horizontal_alignment = "right"
	style.vertical_alignment = "center"
	style.text_color = UIHudSettings.color_tint_main_1
	style.offset = { -right_inset, 0, 3 }
	return style
end

local ROOT_LAYOUT_OFFSET_X = 300
local ROOT_LAYOUT_OFFSET_Y = 200
local ROOT_LAYOUT_OFFSET_Z = 100

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
		size = { ROW_WIDTH, ROOT_HEIGHT },
		position = { ROOT_LAYOUT_OFFSET_X, ROOT_LAYOUT_OFFSET_Y, ROOT_LAYOUT_OFFSET_Z },
	},
	stamina_bar = {
		parent = "root",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, 0, 0 },
	},
	toughness_bar = {
		parent = "stamina_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, BAR_HEIGHT + BAR_STACK_GAP, 0 },
	},
	health_bar = {
		parent = "toughness_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, BAR_HEIGHT + BAR_STACK_GAP, 0 },
	},
	ability_bar = {
		parent = "health_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, BAR_HEIGHT + BAR_STACK_GAP, 0 },
	},
	boxes_row = {
		parent = "ability_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { ROW_WIDTH, MAIN_ROW_HEIGHT },
		position = { 0, BAR_HEIGHT + BOXES_ROW_TOP_GAP, 0 },
	},
	ammo_big = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BIG_AMMO_W, BIG_AMMO_H },
		position = { 0, 0, 0 },
	},
	slot_weapon_wielded = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_GRID_WIDTH, WIELDED_ROW_HEIGHT },
		position = { RIGHT_GRID_ORIGIN_X, 0, 0 },
	},
	slot_blitz = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_BOTTOM_SLOT_WIDTH, RIGHT_BOTTOM_SLOT_HEIGHT },
		position = { RIGHT_GRID_ORIGIN_X, RIGHT_BOTTOM_ROW_Y, 0 },
	},
	slot_stimm = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_BOTTOM_SLOT_WIDTH, RIGHT_BOTTOM_SLOT_HEIGHT },
		position = { RIGHT_GRID_ORIGIN_X + RIGHT_BOTTOM_SLOT_WIDTH + RIGHT_GAP, RIGHT_BOTTOM_ROW_Y, 0 },
	},
	slot_pickup = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { RIGHT_BOTTOM_SLOT_WIDTH, RIGHT_BOTTOM_SLOT_HEIGHT },
		position = { RIGHT_GRID_ORIGIN_X + (RIGHT_BOTTOM_SLOT_WIDTH + RIGHT_GAP) * 2, RIGHT_BOTTOM_ROW_Y, 0 },
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
	local text_style = text_style_from_hud_body(AMMO_CLIP_FONT, { 0, -AMMO_CLIP_OFFSET_Y, 2 })
	local text_style_reserve = text_style_from_hud_body(AMMO_RESERVE_FONT, { 0, AMMO_RESERVE_OFFSET_Y, 2 })

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = table.clone(HUD_GLASS_PLATE_COLOR),
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
	local text_style = text_style_slot_counter_right(SLOT_TEXT_FONT, SLOT_TEXT_RIGHT_INSET)

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = table.clone(HUD_GLASS_PLATE_COLOR),
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "texture",
			style_id = "icon",
			value = RIGHT_SLOT_ICON_FALLBACK,
			value_id = "icon",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				size = { SLOT_ICON_TEXTURE_SIZE, SLOT_ICON_TEXTURE_SIZE },
				offset = { SLOT_ICON_LEFT_INSET, 0, 1 },
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

local function create_weapon_wielded_slot_widget(scenegraph_id)
	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = table.clone(HUD_GLASS_PLATE_COLOR),
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
				size = { WEAPON_STRIP_ICON_W, WEAPON_STRIP_ICON_H },
				default_size = { WEAPON_STRIP_ICON_W, WEAPON_STRIP_ICON_H },
				aspect_ratio = WEAPON_STRIP_ICON_ASPECT_RATIO,
				offset = { 0, 0, 1 },
				color = { 255, 255, 255, 255 },
			},
		},
	}, scenegraph_id)
end

local widget_definitions = {
	stamina_bar = create_bar_widget("stamina_bar", { 255, 255, 255, 255 }),
	toughness_bar = create_bar_widget("toughness_bar", { 255, 100, 200, 255 }),
	health_bar = create_bar_widget("health_bar", { 255, 100, 255, 100 }),
	ability_bar = create_bar_widget("ability_bar", { 255, 255, 50, 50 }),
	ammo_big = create_ammo_big_widget("ammo_big"),
	slot_weapon_wielded = create_weapon_wielded_slot_widget("slot_weapon_wielded"),
	slot_blitz = create_right_slot_widget("slot_blitz"),
	slot_stimm = create_right_slot_widget("slot_stimm"),
	slot_pickup = create_right_slot_widget("slot_pickup"),
}

local right_slot_widget_names = {
	"slot_weapon_wielded",
	"slot_blitz",
	"slot_stimm",
	"slot_pickup",
}

return {
	scenegraph_definition = scenegraph_definition,
	widget_definitions = widget_definitions,
	ROOT_LAYOUT_OFFSET_X = ROOT_LAYOUT_OFFSET_X,
	ROOT_LAYOUT_OFFSET_Y = ROOT_LAYOUT_OFFSET_Y,
	ROOT_LAYOUT_OFFSET_Z = ROOT_LAYOUT_OFFSET_Z,
	HUD_LAYOUT_SCALE = LAYOUT_SCALE,
	BAR_WIDTH = BAR_WIDTH,
	ROW_WIDTH = ROW_WIDTH,
	RIGHT_SLOT_COUNT = 4,
	right_slot_widget_names = right_slot_widget_names,
	HUD_WEAPON_ICON_CONTAINER = HUD_WEAPON_ICON_CONTAINER,
	RIGHT_SLOT_ICON_FALLBACK = RIGHT_SLOT_ICON_FALLBACK,
	HUD_GLASS_PLATE_COLOR = HUD_GLASS_PLATE_COLOR,
	HUD_GLASS_PLATE_ALPHA_BASE = HUD_GLASS_PLATE_ALPHA_BASE,
	WEAPON_STRIP_ICON_W = WEAPON_STRIP_ICON_W,
	WEAPON_STRIP_ICON_H = WEAPON_STRIP_ICON_H,
	WEAPON_STRIP_ICON_ASPECT_RATIO = WEAPON_STRIP_ICON_ASPECT_RATIO,
	WIELDED_STRIP_SQUARE_ICON = WIELDED_STRIP_SQUARE_ICON,
}
