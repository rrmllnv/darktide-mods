local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local M = {}

local PROX_CATEGORY_ORDER = {
	"medical_station",
	"medical",
	"medical_deployed",
	"stimm_corruption",
	"stimm_power",
	"stimm_speed",
	"stimm_ability",
	"ammo_small",
	"ammo_large",
	"ammo_crate",
	"grenade",
	"grimoire",
	"tome",
}

local PROX_SLOT_WIDGET_NAMES = {
	medical_station = "prox_medical_station",
	medical = "prox_medical",
	medical_deployed = "prox_medical_deployed",
	stimm_corruption = "prox_stimm_corruption",
	stimm_power = "prox_stimm_power",
	stimm_speed = "prox_stimm_speed",
	stimm_ability = "prox_stimm_ability",
	ammo_small = "prox_ammo_small",
	ammo_large = "prox_ammo_large",
	ammo_crate = "prox_ammo_crate",
	grenade = "prox_grenade",
	grimoire = "prox_grimoire",
	tome = "prox_tome",
}

local PROX_CATEGORY_ICONS = {
	medical_station = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
	medical = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	medical_deployed = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	stimm_corruption = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	stimm_power = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	stimm_speed = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	stimm_ability = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
	ammo_small = "content/ui/materials/hud/icons/party_ammo",
	ammo_large = "content/ui/materials/hud/icons/party_ammo",
	ammo_crate = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	grenade = "content/ui/materials/hud/icons/party_throwable",
	grimoire = "content/ui/materials/icons/pocketables/hud/small/party_grimoire",
	tome = "content/ui/materials/icons/pocketables/hud/small/party_scripture",
}

local function create_prox_slot_bg_widget(scenegraph_id, slot_size, build_frame_fn, defaults_fn)
	return UIWidget.create_definition(
		build_frame_fn(
			slot_size,
			slot_size,
			0,
			1,
			2,
			3
		),
		scenegraph_id,
		defaults_fn()
	)
end

local function create_prox_slot_widget(scenegraph_id, default_icon, slot_size, icon_size, text_font, count_font, right_slot_icon_fallback, sc)
	local icon_material = default_icon or right_slot_icon_fallback
	local dist_text_style = table.clone(UIFontSettings.hud_body)

	dist_text_style.font_size = text_font
	dist_text_style.drop_shadow = true
	dist_text_style.horizontal_alignment = "center"
	dist_text_style.vertical_alignment = "center"
	dist_text_style.text_horizontal_alignment = "center"
	dist_text_style.text_vertical_alignment = "center"
	dist_text_style.text_color = table.clone(UIHudSettings.color_tint_main_1)
	dist_text_style.size = { slot_size, math.ceil(text_font * 1.4) }
	dist_text_style.offset = { 0, math.floor(slot_size * 0.5 - text_font * 0.5 - sc(2)), 7 }

	local count_text_style = table.clone(UIFontSettings.hud_body)

	count_text_style.font_size = count_font
	count_text_style.drop_shadow = true
	count_text_style.horizontal_alignment = "right"
	count_text_style.vertical_alignment = "top"
	count_text_style.text_horizontal_alignment = "right"
	count_text_style.text_vertical_alignment = "top"
	count_text_style.text_color = { 255, 255, 255, 255 }
	count_text_style.size = { slot_size - sc(2), slot_size }
	count_text_style.offset = { -sc(2), sc(2), 9 }

	local ox = sc(1)

	local function count_outline_style(dx, dy, z)
		local style = table.clone(count_text_style)

		style.drop_shadow = false
		style.text_color = { 255, 0, 0, 0 }
		style.offset = { -sc(2) + dx, sc(2) + dy, z }

		return style
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
				size = { icon_size, icon_size },
				default_size = { icon_size, icon_size },
				offset = { 0, -math.floor(text_font * 0.6), 6 },
				default_offset = { 0, -math.floor(text_font * 0.6), 6 },
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
			style = count_outline_style(-ox, 0, 8),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_e",
			style = count_outline_style(ox, 0, 8),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_n",
			style = count_outline_style(0, -ox, 8),
		},
		{
			pass_type = "text",
			value_id = "count_text",
			value = "",
			style_id = "count_text_outline_s",
			style = count_outline_style(0, ox, 8),
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

function M.build(params)
	local sc = params.sc
	local main_row_height = params.main_row_height
	local bar_fill_width = params.bar_fill_width
	local ability_bar_strip_height = params.ability_bar_strip_height
	local boxes_row_top_gap = params.boxes_row_top_gap
	local prox_block_gap = params.prox_block_gap
	local prox_col_gap = params.prox_col_gap
	local prox_row_gap = params.prox_row_gap
	local right_slot_icon_fallback = params.right_slot_icon_fallback
	local build_frame_fn = params.build_terminal_gradient_frame_corner_passes
	local defaults_fn = params.strip_bg_widget_content_defaults

	local prox_slot_size = math.floor((main_row_height - prox_row_gap) / 2)
	local prox_icon_size = math.max(sc(16), math.floor(prox_slot_size * 0.44 + 0.5))
	local prox_text_font = math.max(sc(11), math.floor(prox_slot_size * 0.36 + 0.5))
	local prox_count_font = math.max(sc(9), math.floor(prox_text_font * 0.8 + 0.5))
	local proximity_row_width = prox_slot_size * 6 + prox_col_gap * 5

	local scenegraph_definition = {
		proximity_row = {
			parent = "ability_bar",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { proximity_row_width, main_row_height },
			position = { bar_fill_width + prox_block_gap, ability_bar_strip_height + boxes_row_top_gap, 0 },
		},
	}

	local step = prox_slot_size + prox_col_gap
	local row_y = prox_slot_size + prox_row_gap
	local grid_positions = {}

	for col = 0, 5 do
		local x = step * col
		grid_positions[#grid_positions + 1] = { x = x, y = 0, is_bottom = false }
		grid_positions[#grid_positions + 1] = { x = x, y = row_y, is_bottom = true }
	end

	for i = 1, #PROX_CATEGORY_ORDER do
		local cat = PROX_CATEGORY_ORDER[i]
		local widget_name = PROX_SLOT_WIDGET_NAMES[cat]

		scenegraph_definition[widget_name] = {
			parent = "proximity_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { prox_slot_size, prox_slot_size },
			position = { 0, 0, 0 },
		}
	end

	local widget_definitions = {}

	for i = 1, #PROX_CATEGORY_ORDER do
		local cat = PROX_CATEGORY_ORDER[i]
		local widget_name = PROX_SLOT_WIDGET_NAMES[cat]
		local default_icon = PROX_CATEGORY_ICONS[cat]

		widget_definitions[widget_name .. "_bg"] = create_prox_slot_bg_widget(
			widget_name,
			prox_slot_size,
			build_frame_fn,
			defaults_fn
		)

		widget_definitions[widget_name] = create_prox_slot_widget(
			widget_name,
			default_icon,
			prox_slot_size,
			prox_icon_size,
			prox_text_font,
			prox_count_font,
			right_slot_icon_fallback,
			sc
		)
	end

	return {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
		PROX_GRID_POSITIONS = grid_positions,
		PROX_SLOT_WIDGET_NAMES = PROX_SLOT_WIDGET_NAMES,
		PROX_CATEGORIES = PROX_CATEGORY_ORDER,
		PROX_SLIDE_PX = math.max(4, math.floor(prox_slot_size * 0.45 + 0.5)),
		PROX_ANIM_ENTER_DUR = 0.2,
		PROX_ANIM_EXIT_DUR = 0.16,
		PROX_ICON_ENTER_SCALE = 0.82,
		PROX_ICON_EXIT_SCALE = 0.82,
	}
end

return M
