local mod = get_mod("DivisionHUD")

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

local RIGHT_CELL = sc(58)
local RIGHT_GAP = sc(4)
local GAP_LEFT_TO_GRID_OLD = sc(12)
local GAP_LEFT_TO_GRID = RIGHT_GAP
local BIG_AMMO_W = sc(120) + GAP_LEFT_TO_GRID_OLD - GAP_LEFT_TO_GRID
local RIGHT_GRID_COLUMN_COUNT = 3
local RIGHT_GRID_WIDTH = RIGHT_CELL * RIGHT_GRID_COLUMN_COUNT + RIGHT_GAP * (RIGHT_GRID_COLUMN_COUNT - 1)
local AUSPEX_SLOT_WIDTH = RIGHT_CELL
local AUSPEX_TO_WEAPON_GAP = RIGHT_GAP
local WIELDED_STRIP_WIDTH = math.max(1, RIGHT_GRID_WIDTH - AUSPEX_SLOT_WIDTH - AUSPEX_TO_WEAPON_GAP)
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
local BAR_LABEL_W = sc(44)
local BAR_FILL_WIDTH = math.max(1, ROW_WIDTH - BAR_LABEL_W)
local BIG_AMMO_W_LAYOUT = math.max(1, BIG_AMMO_W - BAR_LABEL_W)
local BAR_WIDTH = BAR_FILL_WIDTH
local BAR_HEIGHT = sc(8)
local ABILITY_BAR_MAX_SEGMENTS = 4
local ABILITY_BAR_SEGMENT_GAP = sc(2)
local HEALTH_BAR_HEIGHT = sc(16)
local BAR_STACK_GAP = sc(2)
local BOXES_ROW_TOP_GAP = sc(8)
local ROOT_HEIGHT_BASE = sc(212) - sc(32) - sc(8)
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
local WEAPON_STRIP_MAX_W = math.max(1, WIELDED_STRIP_WIDTH - sc(4))

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
	math.max(1, WIELDED_STRIP_WIDTH - sc(4))
)
local AUSPEX_ICON_SIZE = math.max(1, math.min(AUSPEX_SLOT_WIDTH - sc(6), WIELDED_ROW_HEIGHT - sc(6)))
local SLOT_TEXT_FONT = sc(20)
local SLOT_ICON_LEFT_INSET = sc(3)
local SLOT_TEXT_AFTER_ICON_GAP = sc(2)
local AMMO_CLIP_FONT = sc(38)
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
local RIGHT_GRID_ORIGIN_X = BIG_AMMO_W_LAYOUT + GAP_LEFT_TO_GRID
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

local function text_style_slot_counter_after_icon(font_size, left_offset_x)
	local style = table.clone(UIFontSettings.hud_body)
	style.font_size = font_size
	style.drop_shadow = true
	style.text_horizontal_alignment = "left"
	style.text_vertical_alignment = "center"
	style.horizontal_alignment = "left"
	style.vertical_alignment = "center"
	style.text_color = UIHudSettings.color_tint_main_1
	style.offset = { left_offset_x, 0, 3 }
	return style
end

local ROOT_LAYOUT_OFFSET_X = 0
local ROOT_LAYOUT_OFFSET_Y = 0
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
		size = { ROW_WIDTH, ROOT_HEIGHT_BASE },
		position = { ROOT_LAYOUT_OFFSET_X, ROOT_LAYOUT_OFFSET_Y, ROOT_LAYOUT_OFFSET_Z },
	},
	ability_bar = {
		parent = "health_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_WIDTH, BAR_HEIGHT },
		position = { 0, HEALTH_BAR_HEIGHT + BAR_STACK_GAP, 0 },
	},
	boxes_row = {
		parent = "ability_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_FILL_WIDTH, MAIN_ROW_HEIGHT },
		position = { 0, BAR_HEIGHT + BOXES_ROW_TOP_GAP, 0 },
	},
	ammo_big = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BIG_AMMO_W_LAYOUT, BIG_AMMO_H },
		position = { 0, 0, 0 },
	},
	slot_auspex = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { AUSPEX_SLOT_WIDTH, WIELDED_ROW_HEIGHT },
		position = { RIGHT_GRID_ORIGIN_X, 0, 0 },
	},
	slot_weapon_wielded = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { WIELDED_STRIP_WIDTH, WIELDED_ROW_HEIGHT },
		position = { RIGHT_GRID_ORIGIN_X + AUSPEX_SLOT_WIDTH + AUSPEX_TO_WEAPON_GAP, 0, 0 },
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

local DivisionHUDVanillaToughnessHealthDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/vanilla_toughness_health_definitions")
local _division_vanilla_th = DivisionHUDVanillaToughnessHealthDefs.build(BAR_WIDTH, BAR_HEIGHT, HEALTH_BAR_HEIGHT, BAR_LABEL_W, BAR_STACK_GAP)

for k, v in pairs(_division_vanilla_th.scenegraph_definition) do
	scenegraph_definition[k] = v
end

local DivisionHUDVanillaStaminaDodgeDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/vanilla_stamina_dodge_definitions")
local _division_vanilla_stm_ddg = DivisionHUDVanillaStaminaDodgeDefs.build(MAIN_ROW_HEIGHT)

for k, v in pairs(_division_vanilla_stm_ddg.scenegraph_definition) do
	scenegraph_definition[k] = v
end

scenegraph_definition.boxes_row.size[2] = MAIN_ROW_HEIGHT + _division_vanilla_stm_ddg.extend_below_main_row

local ROOT_HEIGHT = ROOT_HEIGHT_BASE + _division_vanilla_stm_ddg.extend_below_main_row

scenegraph_definition.root.size[2] = ROOT_HEIGHT

local function create_combat_ability_bar_widget(scenegraph_id)
	local passes = {
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
	}

	for i = 1, ABILITY_BAR_MAX_SEGMENTS do
		passes[#passes + 1] = {
			pass_type = "rect",
			style_id = "segment_" .. i,
			value_id = "segment_" .. i,
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				color = { 255, 231, 145, 26 },
				offset = { 0, 0, i },
				size = { 0, BAR_HEIGHT },
			},
		}
	end

	return UIWidget.create_definition(passes, scenegraph_id)
end

local function create_slots_bg_widget(scenegraph_id, w, h)
	return UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "background",
			value = "content/ui/materials/hud/backgrounds/terminal_background_weapon",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.terminal_background_gradient(255, true),
				size = { w, h },
				offset = { 0, 0, 0 },
			},
		},
	}, scenegraph_id)
end

local function create_ammo_big_widget(scenegraph_id)
	local text_style = text_style_from_hud_body(AMMO_CLIP_FONT, { 0, -AMMO_CLIP_OFFSET_Y, 2 })
	local text_style_reserve = text_style_from_hud_body(AMMO_RESERVE_FONT, { 0, AMMO_RESERVE_OFFSET_Y, 2 })

	return UIWidget.create_definition({
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
	local text_left_x = SLOT_ICON_LEFT_INSET + SLOT_ICON_TEXTURE_SIZE + SLOT_TEXT_AFTER_ICON_GAP
	local text_style = text_style_slot_counter_after_icon(SLOT_TEXT_FONT, text_left_x)

	return UIWidget.create_definition({
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

local function create_auspex_slot_widget(scenegraph_id)
	return UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "icon",
			value = RIGHT_SLOT_ICON_FALLBACK,
			value_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { AUSPEX_ICON_SIZE, AUSPEX_ICON_SIZE },
				default_size = { AUSPEX_ICON_SIZE, AUSPEX_ICON_SIZE },
				offset = { 0, 0, 1 },
				color = { 255, 255, 255, 0 },
			},
		},
	}, scenegraph_id)
end

local function create_weapon_wielded_slot_widget(scenegraph_id)
	return UIWidget.create_definition({
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
	boxes_bg = create_slots_bg_widget("boxes_row", BAR_FILL_WIDTH, MAIN_ROW_HEIGHT),
	ability_bar = create_combat_ability_bar_widget("ability_bar"),
	ammo_big = create_ammo_big_widget("ammo_big"),
	slot_auspex = create_auspex_slot_widget("slot_auspex"),
	slot_weapon_wielded = create_weapon_wielded_slot_widget("slot_weapon_wielded"),
	slot_blitz = create_right_slot_widget("slot_blitz"),
	slot_stimm = create_right_slot_widget("slot_stimm"),
	slot_pickup = create_right_slot_widget("slot_pickup"),
}

for k, v in pairs(_division_vanilla_th.widget_definitions) do
	widget_definitions[k] = v
end

for k, v in pairs(_division_vanilla_stm_ddg.widget_definitions) do
	widget_definitions[k] = v
end

local VANILLA_STAMINA_DODGE_DRAW_LAYER_WIDGETS = {
	stamina_gauge = true,
	stamina_bar = true,
	stamina_depleted_bar = true,
	dodge_gauge = true,
	wide_bar = true,
	health_stamina_nodge = true,
	toughness_stamina_nodge = true,
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
	vanilla_stamina_dodge_animations = _division_vanilla_stm_ddg.animations,
	stamina_nodges_definition = _division_vanilla_stm_ddg.stamina_nodges_definition,
	health_stamina_nodges_definition = _division_vanilla_th.health_stamina_nodges_definition,
	toughness_stamina_nodges_definition = _division_vanilla_th.toughness_stamina_nodges_definition,
	dodge_bar_definition = _division_vanilla_stm_ddg.dodge_bar_definition,
	VANILLA_STAMINA_DODGE_DRAW_LAYER_WIDGETS = VANILLA_STAMINA_DODGE_DRAW_LAYER_WIDGETS,
	ROOT_LAYOUT_OFFSET_X = ROOT_LAYOUT_OFFSET_X,
	ROOT_LAYOUT_OFFSET_Y = ROOT_LAYOUT_OFFSET_Y,
	ROOT_LAYOUT_OFFSET_Z = ROOT_LAYOUT_OFFSET_Z,
	HUD_LAYOUT_SCALE = LAYOUT_SCALE,
	BAR_WIDTH = BAR_WIDTH,
	BAR_HEIGHT = BAR_HEIGHT,
	ABILITY_BAR_MAX_SEGMENTS = ABILITY_BAR_MAX_SEGMENTS,
	ABILITY_BAR_SEGMENT_GAP = ABILITY_BAR_SEGMENT_GAP,
	BAR_LABEL_W = BAR_LABEL_W,
	BAR_FILL_WIDTH = BAR_FILL_WIDTH,
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
	AUSPEX_ICON_SIZE = AUSPEX_ICON_SIZE,
}
