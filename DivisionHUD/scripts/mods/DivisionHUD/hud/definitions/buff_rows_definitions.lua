local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementPlayerBuffsSettings = require("scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_settings")

local BUFF_COLS       = 5
local BUFF_ROWS_COUNT = 3
local BUFF_MAX_SLOTS  = BUFF_COLS * BUFF_ROWS_COUNT

local M = {}

M.BUFF_COLS       = BUFF_COLS
M.BUFF_ROWS_COUNT = BUFF_ROWS_COUNT
M.BUFF_MAX_SLOTS  = BUFF_MAX_SLOTS

local LAYOUT_SCALE = 0.8
local mod = rawget(_G, "get_mod") and get_mod("DivisionHUD") or nil
local runtime_cfg = nil

if mod and type(mod._settings) == "table" then
	runtime_cfg = mod._settings
else
	runtime_cfg = mod and mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/defaults") or nil
end

if type(runtime_cfg) == "table" and type(runtime_cfg.hud_layout_scale) == "number" and runtime_cfg.hud_layout_scale == runtime_cfg.hud_layout_scale then
	LAYOUT_SCALE = runtime_cfg.hud_layout_scale
end

local function sc(n)
	if n == 0 then
		return 0
	end

	local sign = n < 0 and -1 or 1
	local a    = math.abs(n)

	return sign * math.max(1, math.floor(a * LAYOUT_SCALE + 0.5))
end

local BUFF_SLOT_SIZE = 38
local BUFF_FRAME_SIZE = 59
local BUFF_SLOT_SPACING = HudElementPlayerBuffsSettings.horizontal_spacing

if type(BUFF_SLOT_SPACING) ~= "number" or BUFF_SLOT_SPACING ~= BUFF_SLOT_SPACING or BUFF_SLOT_SPACING <= 0 then
	BUFF_SLOT_SPACING = 42
end

local BUFF_ROW_SPACING = BUFF_SLOT_SPACING
local BUFF_AREA_TOP_GAP = sc(10)
local BUFF_AREA_LEFT_NUDGE = sc(1) 
local BUFF_SLIDE_PX     = sc(18)

M.BUFF_SLOT_SPACING = BUFF_SLOT_SPACING
M.BUFF_ROW_SPACING  = BUFF_ROW_SPACING
M.BUFF_SLIDE_PX     = BUFF_SLIDE_PX

M.build = function(buff_layout_from_stm_ddg, main_row_height, extend_below_main_row, bar_fill_width)
	local ddg_top = 0
	local ddg_visual_bottom_local = 0

	if type(buff_layout_from_stm_ddg) == "table" then
		local lt = buff_layout_from_stm_ddg.ddg_top
		local lv = buff_layout_from_stm_ddg.ddg_visual_bottom_local

		if type(lt) == "number" and lt == lt then
			ddg_top = lt
		end

		if type(lv) == "number" and lv == lv then
			ddg_visual_bottom_local = lv
		end
	end
	-- determine how many columns fit into available width (allow increasing columns if space allows)
	local cols        = BUFF_COLS
	local buff_strip_w = BUFF_COLS * BUFF_SLOT_SPACING
	-- if caller provided bar_fill_width use it as available width
	if type(bar_fill_width) == "number" and bar_fill_width == bar_fill_width and bar_fill_width > 0 then
		buff_strip_w = math.max(BUFF_SLOT_SIZE, math.floor(bar_fill_width + 0.5))
	end

	-- compute columns that fit into buff_strip_w using slot spacing
	local computed_cols = math.max(1, math.floor(buff_strip_w / BUFF_SLOT_SPACING + 0.5))
	cols = math.max(1, computed_cols)

	local h_step      = BUFF_SLOT_SPACING
	local row_step    = BUFF_ROW_SPACING
	local buff_total_h = BUFF_FRAME_SIZE

	local buff_x_span = 0

	if cols > 1 then
		buff_x_span = math.max(0, buff_strip_w - BUFF_SLOT_SIZE)
		h_step = math.max(1, math.floor(buff_x_span / (cols - 1) + 0.5))
	end

	row_step = h_step

	if BUFF_ROWS_COUNT > 1 then
		buff_total_h = (BUFF_ROWS_COUNT - 1) * row_step + BUFF_FRAME_SIZE
	end

	local main_h   = (type(main_row_height) == "number" and main_row_height == main_row_height) and main_row_height or 0
	local ext_main = (type(extend_below_main_row) == "number" and extend_below_main_row == extend_below_main_row) and extend_below_main_row or 0

	local buff_anchor_y          = ddg_top + ddg_visual_bottom_local + BUFF_AREA_TOP_GAP
	local buff_bottom_from_boxes = buff_anchor_y + buff_total_h
	local boxes_base_bottom      = main_h + ext_main
	local extend_below_buff_rows = math.max(0, math.ceil(buff_bottom_from_boxes - boxes_base_bottom))

	local grid_positions = {}

	for row = 0, BUFF_ROWS_COUNT - 1 do
		for col = 0, cols - 1 do
			local pos_x = 0

			if cols > 1 then
				pos_x = math.floor((buff_x_span * col) / (cols - 1) + 0.5)
			end

			grid_positions[#grid_positions + 1] = {
				x = pos_x,
				y = row * row_step,
			}
		end
	end

	local scenegraph_definition = {
		division_buff_rows = {
			parent               = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment   = "top",
			size                 = { BUFF_SLOT_SIZE, BUFF_SLOT_SIZE },
			position             = { BUFF_AREA_LEFT_NUDGE, buff_anchor_y, 0 },
		},
	}

	local text_style = table.clone(UIFontSettings.hud_body)

	text_style.horizontal_alignment      = "right"
	text_style.vertical_alignment        = "bottom"
	text_style.text_horizontal_alignment = "center"
	text_style.text_vertical_alignment   = "bottom"
	text_style.size                      = { 0, BUFF_SLOT_SIZE }
	text_style.offset                    = { -2, 2, 7 }
	text_style.drop_shadow               = true

	local buff_widget_definition = UIWidget.create_definition({
		{
			pass_type  = "text",
			style_id   = "text",
			value      = "",
			value_id   = "text",
			style      = text_style,
			visibility_function = function(content, style)
				return content.text ~= nil
			end,
		},
		{
			pass_type = "rect",
			style_id  = "text_background",
			style     = {
				horizontal_alignment = "right",
				vertical_alignment   = "bottom",
				size                 = { 0, 19 },
				color                = { 150, 0, 0, 0 },
				offset               = { -1, -1, 5 },
			},
			visibility_function = function(content, style)
				return content.text ~= nil
			end,
		},
		{
			pass_type = "texture",
			style_id  = "frame",
			value     = "content/ui/materials/icons/buffs/hud/buff_frame_with_opacity",
			style     = {
				horizontal_alignment = "center",
				vertical_alignment   = "center",
				material_values      = { opacity = 1 },
			size                 = { BUFF_FRAME_SIZE, BUFF_FRAME_SIZE },
				offset               = { 0, 0, 1 },
				color                = { 150, 0, 0, 0 },
			},
			change_function = function(content, style)
				style.material_values.opacity = content.opacity or 1
			end,
		},
		{
			pass_type = "texture",
			style_id  = "icon",
			value     = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
			style     = {
				horizontal_alignment = "center",
				vertical_alignment   = "center",
				material_values      = { opacity = 1, progress = 1 },
				size                 = { BUFF_SLOT_SIZE, BUFF_SLOT_SIZE },
				offset               = { 0, 0, 0 },
				color                = { 150, 102, 102, 102 },
			},
			change_function = function(content, style)
				style.material_values.progress = content.duration_progress or 1
				style.material_values.opacity  = content.opacity or 1
			end,
		},
	}, "division_buff_rows")

	local widget_definitions = {}
	local buff_widget_names  = {}

	-- number of widget slots depends on computed columns
	local buff_max_slots = cols * BUFF_ROWS_COUNT

	for i = 1, buff_max_slots do
		local name             = "div_buff_" .. i
		widget_definitions[name] = buff_widget_definition
		buff_widget_names[i]     = name
	end

	return {
		scenegraph_definition    = scenegraph_definition,
		widget_definitions       = widget_definitions,
		buff_widget_names        = buff_widget_names,
		grid_positions           = grid_positions,
		BUFF_MAX_SLOTS           = buff_max_slots,
		BUFF_COLS                = cols,
		BUFF_SLOT_SPACING        = h_step,
		BUFF_ROW_SPACING         = row_step,
		BUFF_SLOT_SIZE           = BUFF_SLOT_SIZE,
		BUFF_SLIDE_PX            = BUFF_SLIDE_PX,
		extend_below_buff_rows   = extend_below_buff_rows,
	}
end

return M
