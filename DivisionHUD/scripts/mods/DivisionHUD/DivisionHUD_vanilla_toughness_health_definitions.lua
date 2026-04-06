--[[
	Определения для полос здоровья и стойкости DivisionHUD.
	Паттерн такой же, как в DivisionHUD_vanilla_stamina_dodge_definitions.lua:
	  build(bar_w, bar_h, bar_label_w, bar_stack_gap) → { scenegraph_definition, widget_definitions,
	    health_stamina_nodges_definition, toughness_stamina_nodges_definition }
	Scenegraph-узлы: toughness_value_label, toughness_bar, health_value_label, health_bar.
	Цвета:
	  - Стойкость (bar_fill): UIHudSettings.color_tint_6 = Color.ui_toughness_default (синий, как в ваниле).
	  - Здоровье (bar_fill): UIHudSettings.color_tint_1 (белый, как в hud_element_player_health_definitions.lua).
	  - Ранения/скверна (health_max bar_fill): UIHudSettings.color_tint_3 = Color.ui_orange_dark(153) (как в ваниле).
	Цифры: body_small, только текущее значение (без слеша), правое выравнивание — как value_text_style в stamina/dodge defs.
	Засечки (nodges): только через VanillaToughnessHealth.draw (не в стандартном _draw_widgets).
]]

local mod = get_mod("DivisionHUD")

local StaminaDodgeDefs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_vanilla_stamina_dodge_definitions")

local HudElementStaminaSettings = require("scripts/ui/hud/elements/blocking/hud_element_stamina_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local stm_spacing = HudElementStaminaSettings.spacing

local STAMINA_NODGES_COLOR = HudElementStaminaSettings.STAMINA_NODGES_COLOR
local STAMINA_BAR_BACKGROUND_COLOR = HudElementStaminaSettings.STAMINA_BAR_BACKGROUND_COLOR
local STAMINA_BAR_COLOR = HudElementStaminaSettings.STAMINA_BAR_COLOR

local HEALTH_BAR_FILL_COLOR = UIHudSettings.color_tint_1
local TOUGHNESS_BAR_FILL_COLOR = UIHudSettings.color_tint_6
local WOUNDS_BAR_FILL_COLOR = UIHudSettings.color_tint_8

local function build_scenegraph(bar_w, bar_h, health_bar_h, bar_label_w, bar_stack_gap)
	return {
		toughness_value_label = {
			parent = "root",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = {
				bar_label_w,
				bar_h,
			},
			position = {
				0,
				0,
				0,
			},
		},
		toughness_bar = {
			parent = "root",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = {
				bar_w,
				bar_h,
			},
			position = {
				bar_label_w,
				0,
				0,
			},
		},
		health_value_label = {
			parent = "root",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = {
				bar_label_w,
				health_bar_h,
			},
			position = {
				0,
				bar_h + bar_stack_gap,
				0,
			},
		},
		health_bar = {
			parent = "toughness_bar",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = {
				bar_w,
				health_bar_h,
			},
			position = {
				0,
				bar_h + bar_stack_gap,
				0,
			},
		},
	}
end

local function create_value_label_style(y_offset)
	local style = table.clone(UIFontSettings.body_small)

	style.offset = {
		-4,
		y_offset or 0,
		3,
	}
	style.size = nil
	style.vertical_alignment = "center"
	style.horizontal_alignment = "right"
	style.text_horizontal_alignment = "right"
	style.text_vertical_alignment = "center"
	style.text_color = UIHudSettings.color_tint_main_1
	style.drop_shadow = true

	return style
end

local function create_value_label_widget(scenegraph_id, y_offset)
	return UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "text",
			value_id = "text",
			value = "0",
			style = create_value_label_style(y_offset),
		},
	}, scenegraph_id)
end

local function build(bar_w, bar_h, health_bar_h, bar_label_w, bar_stack_gap)
	local bar_size = {
		bar_w,
		bar_h,
	}
	local health_bar_size = {
		bar_w,
		health_bar_h,
	}

	return {
		scenegraph_definition = build_scenegraph(bar_w, bar_h, health_bar_h, bar_label_w, bar_stack_gap),
		widget_definitions = {
		toughness_value_label = create_value_label_widget("toughness_value_label", -3),
		health_value_label = create_value_label_widget("health_value_label", bar_h + bar_stack_gap - 3),
			health = UIWidget.create_definition({
				{
					pass_type = "rect",
					style_id = "bar_background",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "left",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							4,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_COLOR.background,
					},
				},
				{
					pass_type = "rect",
					style_id = "bar_spent",
					value = "content/ui/materials/hud/stamina_spent",
					style = {
						horizontal_alignment = "left",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							5,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_COLOR.spent,
					},
				},
				{
					pass_type = "rect",
					style_id = "bar_fill",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "left",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							6,
						},
						size_addition = {
							0,
							0,
						},
						color = {
							HEALTH_BAR_FILL_COLOR[1],
							HEALTH_BAR_FILL_COLOR[2],
							HEALTH_BAR_FILL_COLOR[3],
							HEALTH_BAR_FILL_COLOR[4],
						},
					},
				},
			}, "health_bar"),
			toughness = UIWidget.create_definition({
				{
					pass_type = "rect",
					style_id = "bar_background",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "left",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							4,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_COLOR.background,
					},
				},
				{
					pass_type = "rect",
					style_id = "bar_spent",
					value = "content/ui/materials/hud/stamina_spent",
					style = {
						horizontal_alignment = "left",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							5,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_COLOR.spent,
					},
				},
				{
					pass_type = "rect",
					style_id = "bar_fill",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "left",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							6,
						},
						size_addition = {
							0,
							0,
						},
						color = {
							TOUGHNESS_BAR_FILL_COLOR[1],
							TOUGHNESS_BAR_FILL_COLOR[2],
							TOUGHNESS_BAR_FILL_COLOR[3],
							TOUGHNESS_BAR_FILL_COLOR[4],
						},
					},
				},
			}, "toughness_bar"),
			death_pulse = UIWidget.create_definition({
				{
					pass_type = "rect",
					style_id = "bar_overlap",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "center",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							8,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_BACKGROUND_COLOR,
					},
				},
			}, "health_bar"),
			toughness_death_pulse = UIWidget.create_definition({
				{
					pass_type = "rect",
					style_id = "bar_overlap",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "center",
						vertical_alignment = "bottom",
						offset = {
							0,
							0,
							8,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_BACKGROUND_COLOR,
					},
				},
			}, "toughness_bar"),
			health_max = UIWidget.create_definition({
				{
					pass_type = "texture",
					style_id = "bar_fill",
					value = "content/ui/materials/hud/backgrounds/player_health_fill",
					style = {
						horizontal_alignment = "right",
						vertical_alignment = "center",
						size = health_bar_size,
						offset = {
							0,
							0,
							3,
						},
						size_addition = {
							0,
							0,
						},
						color = {
							WOUNDS_BAR_FILL_COLOR[1],
							WOUNDS_BAR_FILL_COLOR[2],
							WOUNDS_BAR_FILL_COLOR[3],
							WOUNDS_BAR_FILL_COLOR[4],
						},
					},
				},
				{
					pass_type = "rect",
					style_id = "bar_background",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "right",
						vertical_alignment = "bottom",
						size = health_bar_size,
						offset = {
							0,
							0,
							2,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_COLOR.background,
					},
				},
			}, "health_bar"),
			toughness_max = UIWidget.create_definition({
				{
					pass_type = "rect",
					style_id = "bar_fill",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "right",
						vertical_alignment = "bottom",
						size = bar_size,
						offset = {
							0,
							0,
							3,
						},
						size_addition = {
							0,
							0,
						},
						color = {
							WOUNDS_BAR_FILL_COLOR[1],
							WOUNDS_BAR_FILL_COLOR[2],
							WOUNDS_BAR_FILL_COLOR[3],
							WOUNDS_BAR_FILL_COLOR[4],
						},
					},
				},
				{
					pass_type = "rect",
					style_id = "bar_background",
					value = "content/ui/materials/hud/stamina_full",
					style = {
						horizontal_alignment = "right",
						vertical_alignment = "bottom",
						size = bar_size,
						offset = {
							0,
							0,
							2,
						},
						size_addition = {
							0,
							0,
						},
						color = STAMINA_BAR_COLOR.background,
					},
				},
			}, "toughness_bar"),
		},
		health_stamina_nodges_definition = UIWidget.create_definition({
			{
				pass_type = "rect",
				style_id = "nodges",
				value = StaminaDodgeDefs.STAMINA_NODGE_DIVIDER_MATERIAL,
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "top",
					size = {
						stm_spacing,
						health_bar_h,
					},
					offset = {
						0,
						0,
						7,
					},
					size_addition = {
						0,
						0,
					},
					color = STAMINA_NODGES_COLOR.filled,
				},
			},
		}, "health_bar"),
		toughness_stamina_nodges_definition = UIWidget.create_definition({
			{
				pass_type = "rect",
				style_id = "nodges",
				value = StaminaDodgeDefs.STAMINA_NODGE_DIVIDER_MATERIAL,
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "top",
					size = {
						stm_spacing,
						6,
					},
					offset = {
						0,
						0,
						7,
					},
					size_addition = {
						0,
						0,
					},
					color = STAMINA_NODGES_COLOR.filled,
				},
			},
		}, "toughness_bar"),
	}
end

return {
	build = build,
}
