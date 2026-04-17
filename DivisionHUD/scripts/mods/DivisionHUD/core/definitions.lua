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
local BAR_LABEL_W = sc(64)
local AMMO_CLIP_FONT = sc(38)
local AMMO_RESERVE_FONT = sc(26)
local AMMO_CLIP_OFFSET_Y = sc(14)
local AMMO_RESERVE_OFFSET_Y = sc(30)
local AMMO_BIG_MAX_DIGITS = 4
local AMMO_BIG_TEXT_CHAR_WIDTH_MUL = 0.62
local AMMO_BIG_MIN_TEXT_PIXEL_W = math.max(
	math.ceil(AMMO_CLIP_FONT * AMMO_BIG_MAX_DIGITS * AMMO_BIG_TEXT_CHAR_WIDTH_MUL),
	math.ceil(AMMO_RESERVE_FONT * AMMO_BIG_MAX_DIGITS * AMMO_BIG_TEXT_CHAR_WIDTH_MUL)
)
local BIG_AMMO_W_REFERENCE = sc(120) + GAP_LEFT_TO_GRID_OLD - GAP_LEFT_TO_GRID
local BIG_AMMO_W_LAYOUT = math.max(1, BIG_AMMO_W_REFERENCE - BAR_LABEL_W, AMMO_BIG_MIN_TEXT_PIXEL_W)
local BIG_AMMO_W = BIG_AMMO_W_LAYOUT + BAR_LABEL_W
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
local BAR_FILL_WIDTH = math.max(1, ROW_WIDTH - BAR_LABEL_W)
local BAR_WIDTH = BAR_FILL_WIDTH
local TOUGHNESS_BAR_HEIGHT = sc(10)
local ABILITY_BAR_STRIP_HEIGHT = sc(8)
local ABILITY_BAR_MAX_SEGMENTS = 4
local ABILITY_BAR_SEGMENT_GAP = sc(2)
local HEALTH_BAR_HEIGHT = sc(16)
local BAR_STACK_GAP = sc(2)
local BOXES_ROW_TOP_GAP = sc(8)
local ROOT_HEIGHT_BASE = sc(212) - sc(32) - sc(8) + sc(2)
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
local SLOT_LEAD_ZERO_CHAR_W = sc(12)

local PROX_BLOCK_GAP = sc(8)
local PROX_COL_GAP = sc(3)
local PROX_ROW_GAP = sc(3)
local PROX_SLOT_SIZE = math.floor((MAIN_ROW_HEIGHT - PROX_ROW_GAP) / 2)
local PROX_ICON_SIZE = math.max(sc(16), math.floor(PROX_SLOT_SIZE * 0.44 + 0.5))
local PROX_TEXT_FONT = math.max(sc(11), math.floor(PROX_SLOT_SIZE * 0.36 + 0.5))

local TextColorFractions = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/text_color_fractions")

if type(TextColorFractions) ~= "table" then
	TextColorFractions = {}
end

local AMMO_TEXT_COLOR_FRACTION_GT_MAIN = TextColorFractions.AMMO_TEXT_COLOR_FRACTION_GT_MAIN or 0.75
local AMMO_TEXT_COLOR_FRACTION_GT_LOW_BAND = TextColorFractions.AMMO_TEXT_COLOR_FRACTION_GT_LOW_BAND or 0.5
local AMMO_TEXT_COLOR_FRACTION_GT_MEDIUM_BAND = TextColorFractions.AMMO_TEXT_COLOR_FRACTION_GT_MEDIUM_BAND or 0.25
local ABILITY_BAR_READY_COLOR = TextColorFractions.ABILITY_BAR_READY_COLOR or { 255, 231, 145, 26 }
local ABILITY_BAR_COOLDOWN_COLOR = TextColorFractions.ABILITY_BAR_COOLDOWN_COLOR or { 255, 215, 80, 80 }

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

local EXPEDITION_SALVAGE_SLOT_W = math.max(RIGHT_BOTTOM_SLOT_WIDTH, sc(72))
local EXPEDITION_SALVAGE_TO_AMMO_GAP = RIGHT_GAP
local EXPEDITION_SALVAGE_SLOT_X = -(EXPEDITION_SALVAGE_SLOT_W + EXPEDITION_SALVAGE_TO_AMMO_GAP)

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
		size = { BAR_WIDTH, ABILITY_BAR_STRIP_HEIGHT },
		position = { 0, HEALTH_BAR_HEIGHT + BAR_STACK_GAP, 0 },
	},
	boxes_row = {
		parent = "ability_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_FILL_WIDTH, MAIN_ROW_HEIGHT },
		position = { 0, ABILITY_BAR_STRIP_HEIGHT + BOXES_ROW_TOP_GAP, 0 },
	},
	boxes_row_main_slots = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { BAR_FILL_WIDTH, MAIN_ROW_HEIGHT },
		position = { 0, 0, 0 },
	},
	division_expedition_salvage_slot = {
		parent = "boxes_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { EXPEDITION_SALVAGE_SLOT_W, RIGHT_BOTTOM_SLOT_HEIGHT },
		position = { EXPEDITION_SALVAGE_SLOT_X, RIGHT_BOTTOM_ROW_Y, 0 },
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
	proximity_row = {
		parent = "ability_bar",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE * 6 + PROX_COL_GAP * 5, MAIN_ROW_HEIGHT },
		position = { BAR_FILL_WIDTH + PROX_BLOCK_GAP, ABILITY_BAR_STRIP_HEIGHT + BOXES_ROW_TOP_GAP, 0 },
	},
	prox_medical_station = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_medical = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_stimm_corruption = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_stimm_power = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_stimm_speed = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_stimm_ability = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_ammo_small = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, PROX_SLOT_SIZE + PROX_ROW_GAP, 0 },
	},
	prox_ammo_large = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { PROX_SLOT_SIZE + PROX_COL_GAP, PROX_SLOT_SIZE + PROX_ROW_GAP, 0 },
	},
	prox_grenade = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_medical_deployed = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_ammo_crate = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_grimoire = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
	prox_tome = {
		parent = "proximity_row",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = { PROX_SLOT_SIZE, PROX_SLOT_SIZE },
		position = { 0, 0, 0 },
	},
}

local DivisionHUDAlertsDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/alerts_definitions")
local _division_alerts = DivisionHUDAlertsDefs.build(BAR_WIDTH, BAR_LABEL_W, sc)

for k, v in pairs(_division_alerts.scenegraph_definition) do
	scenegraph_definition[k] = v
end

local DivisionHUDVanillaToughnessHealthDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/vanilla_toughness_health_definitions")
local _division_vanilla_th = DivisionHUDVanillaToughnessHealthDefs.build(BAR_WIDTH, TOUGHNESS_BAR_HEIGHT, HEALTH_BAR_HEIGHT, BAR_LABEL_W, BAR_STACK_GAP)

for k, v in pairs(_division_vanilla_th.scenegraph_definition) do
	scenegraph_definition[k] = v
end

local DivisionHUDVanillaStaminaDodgeDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/vanilla_stamina_dodge_definitions")
local _division_vanilla_stm_ddg = DivisionHUDVanillaStaminaDodgeDefs.build(MAIN_ROW_HEIGHT, BAR_FILL_WIDTH)

for k, v in pairs(_division_vanilla_stm_ddg.scenegraph_definition) do
	scenegraph_definition[k] = v
end

local DivisionHUDBuffRowsDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/buff_rows_definitions")
local _division_buff_rows = DivisionHUDBuffRowsDefs.build(
	_division_vanilla_stm_ddg.buff_layout_from_stm_ddg,
	MAIN_ROW_HEIGHT,
	_division_vanilla_stm_ddg.extend_below_main_row,
	BAR_FILL_WIDTH
)
local _division_buff_rows_base_y = _division_buff_rows.scenegraph_definition
	and _division_buff_rows.scenegraph_definition.division_buff_rows
	and _division_buff_rows.scenegraph_definition.division_buff_rows.position
	and _division_buff_rows.scenegraph_definition.division_buff_rows.position[2]
	or 0
local _division_buff_rows_hidden_stamina_y = _division_vanilla_stm_ddg.buff_layout_from_stm_ddg
	and _division_vanilla_stm_ddg.buff_layout_from_stm_ddg.stm_top
	or _division_buff_rows_base_y

for k, v in pairs(_division_buff_rows.scenegraph_definition) do
	scenegraph_definition[k] = v
end

local _extend_total = _division_vanilla_stm_ddg.extend_below_main_row + _division_buff_rows.extend_below_buff_rows

scenegraph_definition.boxes_row.size[2] = MAIN_ROW_HEIGHT + _extend_total

local ROOT_HEIGHT = ROOT_HEIGHT_BASE + _extend_total

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
				size = { BAR_WIDTH, ABILITY_BAR_STRIP_HEIGHT },
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
				color = table.clone(ABILITY_BAR_READY_COLOR),
				offset = { 0, 0, i },
				size = { 0, ABILITY_BAR_STRIP_HEIGHT },
			},
		}
	end

	return UIWidget.create_definition(passes, scenegraph_id)
end

local function build_terminal_gradient_frame_corner_passes(w, h, z_gradient, z_shadow, z_frame, z_corner)
	local wh = { w, h }

	return {
		{
			pass_type = "texture",
			style_id = "background_gradient",
			value = "content/ui/materials/gradients/gradient_vertical",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = wh,
				default_color = Color.terminal_background_gradient(nil, true),
				selected_color = Color.terminal_frame_selected(nil, true),
				disabled_color = Color.ui_grey_medium(255, true),
				color = table.clone(Color.terminal_background_gradient(nil, true)),
				offset = { 0, 0, z_gradient },
			},
		},
		{
			pass_type = "texture",
			style_id = "outer_shadow",
			value = "content/ui/materials/frames/dropshadow_medium",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				scale_to_material = true,
				color = Color.black(200, true),
				size_addition = {
					20,
					20,
				},
				offset = {
					0,
					0,
					z_shadow,
				},
			},
		},
		{
			pass_type = "texture",
			style_id = "frame",
			value = "content/ui/materials/frames/frame_tile_2px",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				default_color = Color.terminal_frame(nil, true),
				selected_color = Color.terminal_frame_selected(nil, true),
				disabled_color = Color.ui_grey_medium(255, true),
				color = table.clone(Color.terminal_frame(nil, true)),
				offset = { 0, 0, z_frame },
			},
		},
		{
			pass_type = "texture",
			style_id = "corner",
			value = "content/ui/materials/frames/frame_corner_2px",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				default_color = Color.terminal_corner(nil, true),
				selected_color = Color.terminal_corner_selected(nil, true),
				disabled_color = Color.ui_grey_light(255, true),
				color = table.clone(Color.terminal_corner(nil, true)),
				offset = { 0, 0, z_corner },
			},
		},
	}
end

local BOXES_BG_Z_GRADIENT = 0
local BOXES_BG_Z_SHADOW = 1
local BOXES_BG_Z_FRAME = 2
local BOXES_BG_Z_CORNER = 3

local function create_slots_bg_widget(scenegraph_id, w, h)
	return UIWidget.create_definition(
		build_terminal_gradient_frame_corner_passes(
			w,
			h,
			BOXES_BG_Z_GRADIENT,
			BOXES_BG_Z_SHADOW,
			BOXES_BG_Z_FRAME,
			BOXES_BG_Z_CORNER
		),
		scenegraph_id
	)
end

local function create_ammo_big_widget(scenegraph_id)
	local text_style = text_style_from_hud_body(AMMO_CLIP_FONT, { 0, -AMMO_CLIP_OFFSET_Y, 2 })
	local text_style_reserve = text_style_from_hud_body(AMMO_RESERVE_FONT, { 0, AMMO_RESERVE_OFFSET_Y, 2 })

	text_style.horizontal_alignment = "center"
	text_style.vertical_alignment = "center"
	text_style.size = { BIG_AMMO_W_LAYOUT, math.ceil(AMMO_CLIP_FONT * 1.3) }

	text_style_reserve.horizontal_alignment = "center"
	text_style_reserve.vertical_alignment = "center"
	text_style_reserve.size = { BIG_AMMO_W_LAYOUT, math.ceil(AMMO_RESERVE_FONT * 1.3) }

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

local function create_expedition_salvage_widget(scenegraph_id)
	local text_style = table.clone(UIFontSettings.hud_body)

	text_style.font_size = SLOT_TEXT_FONT
	text_style.drop_shadow = true
	text_style.horizontal_alignment = "right"
	text_style.vertical_alignment = "center"
	text_style.text_horizontal_alignment = "right"
	text_style.text_vertical_alignment = "center"
	text_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
	text_style.size = { EXPEDITION_SALVAGE_SLOT_W, RIGHT_BOTTOM_SLOT_HEIGHT }
	text_style.offset = { 0, 0, 3 }

	return UIWidget.create_definition({
		{
			pass_type = "text",
			value_id = "text",
			value = "0",
			style_id = "text",
			style = text_style,
		},
	}, scenegraph_id)
end

local function create_right_slot_widget(scenegraph_id)
	local text_left_x = SLOT_ICON_LEFT_INSET + SLOT_ICON_TEXTURE_SIZE + SLOT_TEXT_AFTER_ICON_GAP
	local text_lead_style = text_style_slot_counter_after_icon(SLOT_TEXT_FONT, text_left_x)
	local text_main_style = text_style_slot_counter_after_icon(SLOT_TEXT_FONT, text_left_x + SLOT_LEAD_ZERO_CHAR_W)

	text_lead_style = table.clone(text_lead_style)
	text_lead_style.text_color = table.clone(UIHudSettings.color_tint_main_1)

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
			value_id = "text_lead",
			value = "",
			style_id = "text_lead",
			style = text_lead_style,
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "0",
			style_id = "text",
			style = text_main_style,
		},
	}, scenegraph_id)
end

local PROX_TERMINAL_BG_Z_GRADIENT = 0
local PROX_TERMINAL_BG_Z_SHADOW = 1
local PROX_TERMINAL_BG_Z_FRAME = 2
local PROX_TERMINAL_BG_Z_CORNER = 3
local PROX_FG_Z_ICON = 6
local PROX_FG_Z_DIST = 7
local PROX_FG_Z_COUNT_OUTLINE = 8
local PROX_FG_Z_COUNT = 9

local function create_prox_slot_bg_widget(scenegraph_id)
	local sz = PROX_SLOT_SIZE

	return UIWidget.create_definition(
		build_terminal_gradient_frame_corner_passes(
			sz,
			sz,
			PROX_TERMINAL_BG_Z_GRADIENT,
			PROX_TERMINAL_BG_Z_SHADOW,
			PROX_TERMINAL_BG_Z_FRAME,
			PROX_TERMINAL_BG_Z_CORNER
		),
		scenegraph_id
	)
end

local PROX_COUNT_FONT = math.max(sc(9), math.floor(PROX_TEXT_FONT * 0.8 + 0.5))

local function create_prox_slot_widget(scenegraph_id, default_icon)
	local icon_material = default_icon or RIGHT_SLOT_ICON_FALLBACK

	local dist_text_style = table.clone(UIFontSettings.hud_body)

	dist_text_style.font_size = PROX_TEXT_FONT
	dist_text_style.drop_shadow = true
	dist_text_style.horizontal_alignment = "center"
	dist_text_style.vertical_alignment = "center"
	dist_text_style.text_horizontal_alignment = "center"
	dist_text_style.text_vertical_alignment = "center"
	dist_text_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
	dist_text_style.size = { PROX_SLOT_SIZE, math.ceil(PROX_TEXT_FONT * 1.4) }
	dist_text_style.offset = { 0, math.floor(PROX_SLOT_SIZE * 0.5 - PROX_TEXT_FONT * 0.5 - sc(2)), PROX_FG_Z_DIST }

	local count_text_style = table.clone(UIFontSettings.hud_body)

	count_text_style.font_size = PROX_COUNT_FONT
	count_text_style.drop_shadow = true
	count_text_style.horizontal_alignment = "right"
	count_text_style.vertical_alignment = "top"
	count_text_style.text_horizontal_alignment = "right"
	count_text_style.text_vertical_alignment = "top"
	count_text_style.text_color = { 255, 255, 255, 255 }
	count_text_style.size = { PROX_SLOT_SIZE - sc(2), PROX_SLOT_SIZE }
	count_text_style.offset = { -sc(2), sc(2), PROX_FG_Z_COUNT }

	local ox = sc(1)

	local function count_outline_style(dx, dy, z)
		local s = table.clone(count_text_style)

		s.drop_shadow = false
		s.text_color = { 255, 0, 0, 0 }
		s.offset = { -sc(2) + dx, sc(2) + dy, z }

		return s
	end

	return UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "icon",
			value = icon_material,
			value_id = "icon",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { PROX_ICON_SIZE, PROX_ICON_SIZE },
				default_size = { PROX_ICON_SIZE, PROX_ICON_SIZE },
				offset = { 0, -math.floor(PROX_TEXT_FONT * 0.6), PROX_FG_Z_ICON },
				color = { 255, 255, 255, 255 },
			},
		},
		{
			pass_type = "text",
			value_id = "dist_text",
			value = "",
			style_id = "dist_text",
			style = dist_text_style,
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_w",
			style = count_outline_style(-ox, 0, PROX_FG_Z_COUNT_OUTLINE),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_e",
			style = count_outline_style(ox, 0, PROX_FG_Z_COUNT_OUTLINE),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_n",
			style = count_outline_style(0, -ox, PROX_FG_Z_COUNT_OUTLINE),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_s",
			style = count_outline_style(0, ox, PROX_FG_Z_COUNT_OUTLINE),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text",
			style = count_text_style,
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
				horizontal_alignment = "right",
				vertical_alignment = "center",
				size = { WEAPON_STRIP_ICON_W, WEAPON_STRIP_ICON_H },
				default_size = { WEAPON_STRIP_ICON_W, WEAPON_STRIP_ICON_H },
				aspect_ratio = WEAPON_STRIP_ICON_ASPECT_RATIO,
				offset = { -sc(2), 0, 1 },
				color = { 255, 255, 255, 255 },
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "",
			style_id = "text",
			style = {
				font_type = UIFontSettings.hud_body.font_type,
				font_size = sc(22),
				drop_shadow = true,
				horizontal_alignment = "left",
				vertical_alignment = "center",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				text_color = table.clone(UIHudSettings.color_tint_main_1),
				size = { WIELDED_STRIP_WIDTH - sc(6), WIELDED_ROW_HEIGHT },
				offset = { sc(4), 0, 3 },
			},
		},
	}, scenegraph_id)
end

local PROX_CATEGORY_ICONS = {
	medical_station  = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
	medical          = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	medical_deployed = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	stimm_corruption = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	stimm_power      = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	stimm_speed      = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	stimm_ability    = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	ammo_small       = "content/ui/materials/hud/icons/party_ammo",
	ammo_large       = "content/ui/materials/hud/icons/party_ammo",
	ammo_crate       = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	grenade          = "content/ui/materials/hud/icons/party_throwable",
	grimoire         = "content/ui/materials/icons/pocketables/hud/small/party_grimoire",
	tome             = "content/ui/materials/icons/pocketables/hud/small/party_scripture",
}

local widget_definitions = {
	boxes_bg = create_slots_bg_widget("boxes_row_main_slots", BAR_FILL_WIDTH, MAIN_ROW_HEIGHT),
	ability_bar = create_combat_ability_bar_widget("ability_bar"),
	expedition_salvage = create_expedition_salvage_widget("division_expedition_salvage_slot"),
	ammo_big = create_ammo_big_widget("ammo_big"),
	slot_auspex = create_auspex_slot_widget("slot_auspex"),
	slot_weapon_wielded = create_weapon_wielded_slot_widget("slot_weapon_wielded"),
	slot_blitz = create_right_slot_widget("slot_blitz"),
	slot_stimm = create_right_slot_widget("slot_stimm"),
	slot_pickup = create_right_slot_widget("slot_pickup"),
	prox_medical_station_bg  = create_prox_slot_bg_widget("prox_medical_station"),
	prox_medical_bg          = create_prox_slot_bg_widget("prox_medical"),
	prox_stimm_corruption_bg = create_prox_slot_bg_widget("prox_stimm_corruption"),
	prox_stimm_power_bg      = create_prox_slot_bg_widget("prox_stimm_power"),
	prox_stimm_speed_bg      = create_prox_slot_bg_widget("prox_stimm_speed"),
	prox_stimm_ability_bg    = create_prox_slot_bg_widget("prox_stimm_ability"),
	prox_ammo_small_bg       = create_prox_slot_bg_widget("prox_ammo_small"),
	prox_ammo_large_bg       = create_prox_slot_bg_widget("prox_ammo_large"),
	prox_grenade_bg          = create_prox_slot_bg_widget("prox_grenade"),
	prox_medical_deployed_bg = create_prox_slot_bg_widget("prox_medical_deployed"),
	prox_ammo_crate_bg       = create_prox_slot_bg_widget("prox_ammo_crate"),
	prox_grimoire_bg         = create_prox_slot_bg_widget("prox_grimoire"),
	prox_tome_bg             = create_prox_slot_bg_widget("prox_tome"),
	prox_medical_station  = create_prox_slot_widget("prox_medical_station",  PROX_CATEGORY_ICONS.medical_station),
	prox_medical          = create_prox_slot_widget("prox_medical",          PROX_CATEGORY_ICONS.medical),
	prox_medical_deployed = create_prox_slot_widget("prox_medical_deployed", PROX_CATEGORY_ICONS.medical_deployed),
	prox_stimm_corruption = create_prox_slot_widget("prox_stimm_corruption", PROX_CATEGORY_ICONS.stimm_corruption),
	prox_stimm_power      = create_prox_slot_widget("prox_stimm_power",      PROX_CATEGORY_ICONS.stimm_power),
	prox_stimm_speed      = create_prox_slot_widget("prox_stimm_speed",      PROX_CATEGORY_ICONS.stimm_speed),
	prox_stimm_ability    = create_prox_slot_widget("prox_stimm_ability",    PROX_CATEGORY_ICONS.stimm_ability),
	prox_ammo_small       = create_prox_slot_widget("prox_ammo_small",       PROX_CATEGORY_ICONS.ammo_small),
	prox_ammo_large       = create_prox_slot_widget("prox_ammo_large",       PROX_CATEGORY_ICONS.ammo_large),
	prox_ammo_crate       = create_prox_slot_widget("prox_ammo_crate",       PROX_CATEGORY_ICONS.ammo_crate),
	prox_grenade          = create_prox_slot_widget("prox_grenade",          PROX_CATEGORY_ICONS.grenade),
	prox_grimoire         = create_prox_slot_widget("prox_grimoire",         PROX_CATEGORY_ICONS.grimoire),
	prox_tome             = create_prox_slot_widget("prox_tome",             PROX_CATEGORY_ICONS.tome),
}

for k, v in pairs(_division_alerts.widget_definitions) do
	widget_definitions[k] = v
end

for k, v in pairs(_division_vanilla_th.widget_definitions) do
	widget_definitions[k] = v
end

for k, v in pairs(_division_vanilla_stm_ddg.widget_definitions) do
	widget_definitions[k] = v
end

for k, v in pairs(_division_buff_rows.widget_definitions) do
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
	buff_rows = _division_buff_rows,
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
	BAR_HEIGHT = ABILITY_BAR_STRIP_HEIGHT,
	TOUGHNESS_BAR_HEIGHT = TOUGHNESS_BAR_HEIGHT,
	ABILITY_BAR_MAX_SEGMENTS = ABILITY_BAR_MAX_SEGMENTS,
	ABILITY_BAR_SEGMENT_GAP = ABILITY_BAR_SEGMENT_GAP,
	ABILITY_BAR_READY_COLOR = ABILITY_BAR_READY_COLOR,
	ABILITY_BAR_COOLDOWN_COLOR = ABILITY_BAR_COOLDOWN_COLOR,
	BAR_LABEL_W = BAR_LABEL_W,
	BAR_FILL_WIDTH = BAR_FILL_WIDTH,
	division_stamina_bar_width = _division_vanilla_stm_ddg.division_stamina_bar_width,
	division_dodge_bar_track_width = _division_vanilla_stm_ddg.division_dodge_bar_track_width,
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
	ALERTS_MAX_SLOTS = _division_alerts.ALERTS_MAX_SLOTS,
	ALERTS_SLOT_HEIGHT = _division_alerts.ALERTS_SLOT_HEIGHT,
	ALERTS_STACK_TOTAL_HEIGHT = _division_alerts.ALERTS_STACK_TOTAL_HEIGHT,
	ALERTS_STRIP_HEIGHT = _division_alerts.ALERTS_STRIP_HEIGHT,
	ALERTS_SLOT_GAP = _division_alerts.ALERTS_SLOT_GAP,
	ALERTS_TOUGHNESS_GAP = _division_alerts.ALERTS_TOUGHNESS_GAP,
	ALERTS_BODY_HEIGHT_MIN = _division_alerts.ALERTS_BODY_HEIGHT_MIN,
	ALERTS_BODY_HEIGHT_MAX = _division_alerts.ALERTS_BODY_HEIGHT_MAX,
	ALERTS_MESSAGE_TEXT_VERTICAL_INSET = _division_alerts.ALERTS_MESSAGE_TEXT_VERTICAL_INSET,
	ALERTS_MESSAGE_TEXT_OFFSET_Y = _division_alerts.ALERTS_MESSAGE_TEXT_OFFSET_Y,
	ALERTS_MESSAGE_TEXT_WRAP_WIDTH = _division_alerts.ALERTS_MESSAGE_TEXT_WRAP_WIDTH,
	ALERT_PALETTE_DEFAULT = _division_alerts.ALERT_PALETTE_DEFAULT,
	ALERT_PALETTE_BOSS = _division_alerts.ALERT_PALETTE_BOSS,
	ALERT_PALETTE_MISSION_OBJECTIVE = _division_alerts.ALERT_PALETTE_MISSION_OBJECTIVE,
	ALERT_PALETTE_TEAM = _division_alerts.ALERT_PALETTE_TEAM,
	alert_slot_widget_names = _division_alerts.alert_slot_widget_names,
	AMMO_TEXT_COLOR_FRACTION_GT_MAIN = AMMO_TEXT_COLOR_FRACTION_GT_MAIN,
	AMMO_TEXT_COLOR_FRACTION_GT_LOW_BAND = AMMO_TEXT_COLOR_FRACTION_GT_LOW_BAND,
	AMMO_TEXT_COLOR_FRACTION_GT_MEDIUM_BAND = AMMO_TEXT_COLOR_FRACTION_GT_MEDIUM_BAND,
	AMMO_BIG_MAX_DIGITS = AMMO_BIG_MAX_DIGITS,
	AMMO_BIG_DISPLAY_VALUE_MAX = 10^AMMO_BIG_MAX_DIGITS - 1,
	SLOT_TEXT_FULL_OFFSET_X = SLOT_ICON_LEFT_INSET + SLOT_ICON_TEXTURE_SIZE + SLOT_TEXT_AFTER_ICON_GAP,
	SLOT_TEXT_MAIN_OFFSET_X = SLOT_ICON_LEFT_INSET + SLOT_ICON_TEXTURE_SIZE + SLOT_TEXT_AFTER_ICON_GAP + SLOT_LEAD_ZERO_CHAR_W,
	DIVISION_BUFF_ROWS_BASE_Y = _division_buff_rows_base_y,
	DIVISION_BUFF_ROWS_HIDDEN_STAMINA_Y = _division_buff_rows_hidden_stamina_y,
	PROX_GRID_POSITIONS = (function()
		local step = PROX_SLOT_SIZE + PROX_COL_GAP
		local row_y = PROX_SLOT_SIZE + PROX_ROW_GAP
		local t = {}

		for col = 0, 5 do
			local x = step * col

			t[#t + 1] = { x = x, y = 0,     is_bottom = false }
			t[#t + 1] = { x = x, y = row_y, is_bottom = true  }
		end

		return t
	end)(),
	PROX_SLIDE_PX = math.max(4, math.floor(PROX_SLOT_SIZE * 0.45 + 0.5)),
	PROX_SLOT_WIDGET_NAMES = {
		medical_station  = "prox_medical_station",
		medical          = "prox_medical",
		medical_deployed = "prox_medical_deployed",
		stimm_corruption = "prox_stimm_corruption",
		stimm_power      = "prox_stimm_power",
		stimm_speed      = "prox_stimm_speed",
		stimm_ability    = "prox_stimm_ability",
		ammo_small       = "prox_ammo_small",
		ammo_large       = "prox_ammo_large",
		ammo_crate       = "prox_ammo_crate",
		grenade          = "prox_grenade",
		grimoire         = "prox_grimoire",
		tome             = "prox_tome",
	},
}
