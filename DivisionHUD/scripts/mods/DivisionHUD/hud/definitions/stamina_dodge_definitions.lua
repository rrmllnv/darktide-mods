local HudElementStaminaSettings = require("scripts/ui/hud/elements/blocking/hud_element_stamina_settings")
local HudElementDodgeCounterSettings = require("scripts/ui/hud/elements/dodge_counter/hud_element_dodge_counter_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local stm_bar_size = HudElementStaminaSettings.bar_size
local stm_spacing = HudElementStaminaSettings.spacing
local stm_area_size = HudElementStaminaSettings.area_size
local ddg_bar_size = HudElementDodgeCounterSettings.bar_size
local ddg_area_size = HudElementDodgeCounterSettings.area_size
local stm_center_off = HudElementStaminaSettings.center_offset
local ddg_center_off = HudElementDodgeCounterSettings.center_offset

local STAMINA_BAR_BACKGROUND_COLOR = HudElementStaminaSettings.STAMINA_BAR_BACKGROUND_COLOR
local STAMINA_NODGES_COLOR = HudElementStaminaSettings.STAMINA_NODGES_COLOR
local STAMINA_BAR_COLOR = HudElementStaminaSettings.STAMINA_BAR_COLOR

local DODGE_STATE_COLORS_OVERLAP_BAR = HudElementDodgeCounterSettings.DODGE_STATE_COLORS_OVERLAP_BAR
local DODGE_BAR_STATE_COLORS_BAR_FILL = HudElementDodgeCounterSettings.DODGE_BAR_STATE_COLORS_BAR_FILL
local DODGE_BAR_STATE_COLORS_BAR_BACKGROUND = HudElementDodgeCounterSettings.DODGE_BAR_STATE_COLORS_BAR_BACKGROUND

local function build_scenegraph(main_row_height, track_width_px)
	local stm_h = stm_area_size[2]
	local ddg_h = ddg_area_size[2]
	local stm_top = main_row_height + 6
	local between_centers = ddg_center_off - stm_center_off
	local stm_center_y = stm_top + stm_h * 0.5
	local ddg_center_y = stm_center_y + between_centers
	local ddg_top = math.floor(ddg_center_y - ddg_h * 0.5 + 0.5)
	local bottom_y = ddg_top + ddg_h
	local extend_below_main = bottom_y - main_row_height + 4
	local ddg_bar_h = ddg_bar_size[2]
	local ddg_visual_bottom_local = math.max(-5 + 10, 2 + ddg_bar_h)
	local buff_layout_from_stm_ddg = {
		ddg_top                   = ddg_top,
		ddg_visual_bottom_local    = ddg_visual_bottom_local,
		stm_top                   = stm_top,
		ddg_bottom_from_boxes_row = bottom_y,
	}
	local stm_bar_size_layout = {
		track_width_px,
		stm_bar_size[2],
	}
	local ddg_bar_size_layout = {
		track_width_px,
		ddg_bar_size[2],
	}
	local stm_area_size_layout = {
		math.max(stm_area_size[1], track_width_px),
		stm_area_size[2],
	}
	local ddg_area_size_layout = {
		math.max(ddg_area_size[1], track_width_px),
		ddg_area_size[2],
	}
	local gauge_width_px = track_width_px + 12

	return {
		div_stamina_area = {
			horizontal_alignment = "center",
			parent = "boxes_row",
			vertical_alignment = "top",
			size = stm_area_size_layout,
			position = {
				0,
				stm_top,
				0,
			},
		},
		div_stamina_gauge = {
			horizontal_alignment = "center",
			parent = "div_stamina_area",
			vertical_alignment = "top",
			size = {
				gauge_width_px,
				10,
			},
			position = {
				0,
				6,
				1,
			},
		},
		div_stamina_bar = {
			horizontal_alignment = "center",
			parent = "div_stamina_area",
			vertical_alignment = "top",
			size = stm_bar_size_layout,
			position = {
				0,
				1,
				1,
			},
		},
		div_dodge_area = {
			horizontal_alignment = "center",
			parent = "boxes_row",
			vertical_alignment = "top",
			size = ddg_area_size_layout,
			position = {
				0,
				ddg_top,
				0,
			},
		},
		div_dodge_gauge = {
			horizontal_alignment = "center",
			parent = "div_dodge_area",
			vertical_alignment = "top",
			size = {
				gauge_width_px,
				10,
			},
			position = {
				0,
				-5,
				1,
			},
		},
		div_dodge_overlap_bar = {
			horizontal_alignment = "center",
			parent = "div_dodge_area",
			vertical_alignment = "top",
			size = ddg_bar_size_layout,
			position = {
				0,
				2,
				1,
			},
		},
		div_dodge_bar = {
			horizontal_alignment = "center",
			parent = "div_dodge_area",
			vertical_alignment = "top",
			size = ddg_bar_size_layout,
			position = {
				0,
				2,
				1,
			},
		},
	}, extend_below_main, buff_layout_from_stm_ddg
end

local value_text_style = table.clone(UIFontSettings.body_small)

value_text_style.offset = {
	-82,
	-12,
	3,
}
value_text_style.size = {
	78,
	30,
}
value_text_style.vertical_alignment = "top"
value_text_style.horizontal_alignment = "left"
value_text_style.text_horizontal_alignment = "right"
value_text_style.text_vertical_alignment = "top"
value_text_style.text_color = UIHudSettings.color_tint_main_1

local function build_widget_definitions()
	return {
		stamina_gauge = UIWidget.create_definition({
			{
				pass_type = "text",
				style_id = "value_text",
				value_id = "value_text",
				value = Utf8.upper(Localize("loc_hud_display_overheat_death_danger")),
				style = value_text_style,
			},
			{
				pass_type = "texture",
				style_id = "warning",
				value = "content/ui/materials/hud/stamina_gauge",
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "center",
					offset = {
						0,
						0,
						1,
					},
					color = UIHudSettings.color_tint_main_2,
				},
			},
		}, "div_stamina_gauge"),
		stamina_bar = UIWidget.create_definition({
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
					color = STAMINA_BAR_COLOR.fill,
				},
			},
		}, "div_stamina_bar"),
		stamina_depleted_bar = UIWidget.create_definition({
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
		}, "div_stamina_bar"),
		dodge_gauge = UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "warning",
				value = "content/ui/materials/hud/dodge_gauge",
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "center",
					offset = {
						0,
						0,
						1,
					},
					color = UIHudSettings.color_tint_main_2,
				},
			},
		}, "div_dodge_gauge"),
		wide_bar = UIWidget.create_definition({
			{
				pass_type = "rect",
				style_id = "bar_overlap",
				value = "content/ui/materials/hud/stamina_full",
				style = {
					horizontal_alignment = "center",
					vertical_alignment = "top",
					offset = {
						0,
						0,
						5,
					},
					size_addition = {
						0,
						0,
					},
					color = DODGE_STATE_COLORS_OVERLAP_BAR.hidden,
				},
			},
		}, "div_dodge_overlap_bar"),
	}
end

local stamina_nodges_definition = UIWidget.create_definition({
	{
		pass_type = "rect",
		style_id = "nodges",
		value = "content/ui/materials/hud/stamina_full",
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
}, "div_stamina_bar")

local function build_dodge_bar_definition(track_width_px)
	local bar_size_template = {
		track_width_px,
		ddg_bar_size[2],
	}

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "bar_fill",
			value = "content/ui/materials/hud/stamina_full",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "top",
				size = bar_size_template,
				offset = {
					0,
					0,
					3,
				},
				size_addition = {
					0,
					0,
				},
				color = DODGE_BAR_STATE_COLORS_BAR_FILL.available,
			},
		},
		{
			pass_type = "rect",
			style_id = "bar_background",
			value = "content/ui/materials/hud/stamina_full",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "top",
				size = bar_size_template,
				offset = {
					0,
					0,
					2,
				},
				size_addition = {
					0,
					0,
				},
				color = DODGE_BAR_STATE_COLORS_BAR_BACKGROUND.default,
			},
		},
	}, "div_dodge_bar")
end

local animations = {
	on_stamina_depleted = {
		{
			end_time = 0.3,
			name = "bar_overlap_flash",
			start_time = 0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local stamina_depleted_bar_widget = widgets.stamina_depleted_bar
				local widget_style = stamina_depleted_bar_widget.style
				local anim_progress = math.easeOutCubic(progress)
				local bar_size_addition = widget_style.bar_overlap.size_addition

				bar_size_addition[2] = anim_progress * 15

				local color_anim_progress = math.easeOutCubic(progress)
				local fill_widget_color = widget_style.bar_overlap.color

				fill_widget_color[1] = 255 * (1 - color_anim_progress)
			end,
		},
	},
	on_bar_spent = {
		{
			end_time = 0.3,
			name = "on_bar_spent",
			start_time = 0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local anim_progress = math.easeOutCubic(progress)
				local widget = params.dodge_bar_widget
				local widget_style = widget.style
				local bar_size_addition = widget_style.bar_fill.size_addition

				bar_size_addition[2] = anim_progress * 16

				local fill_widget_color = widget_style.bar_fill.color
				local color_anim_progress = math.easeOutCubic(progress)

				fill_widget_color[1] = 255 * (1 - anim_progress)
				fill_widget_color[2] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[2], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[2], color_anim_progress)
				fill_widget_color[3] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[3], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[3], color_anim_progress)
				fill_widget_color[4] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[4], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[4], color_anim_progress)
			end,
			on_complete = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local dodge_bar = params.dodge_bar

				dodge_bar.animation_id = nil
			end,
		},
	},
	on_bar_enter_cooldown = {
		{
			end_time = 0.3,
			name = "on_bar_enter_cooldown",
			start_time = 0,
			init = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local dodge_bar_widget = params.dodge_bar_widget
				local widget_style = dodge_bar_widget.style
				local bar_size_addition = widget_style.bar_fill.size_addition

				bar_size_addition[2] = 0

				local fill_widget_color = widget_style.bar_fill.color

				fill_widget_color[1] = 255
			end,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local dodge_bar_widget = params.dodge_bar_widget
				local widget_style = dodge_bar_widget.style
				local color_anim_progress = math.easeOutCubic(progress)
				local fill_widget_color = widget_style.bar_fill.color

				fill_widget_color[2] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[2], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[2], color_anim_progress)
				fill_widget_color[3] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[3], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[3], color_anim_progress)
				fill_widget_color[4] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[4], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[4], color_anim_progress)
			end,
			on_complete = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local dodge_bar = params.dodge_bar

				dodge_bar.animation_id = nil
			end,
		},
	},
	on_bar_exit_cooldown = {
		{
			end_time = 0.2,
			name = "on_bar_exit_cooldown",
			start_time = 0,
			init = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local dodge_bar_widget = params.dodge_bar_widget
				local widget_style = dodge_bar_widget.style
				local bar_size_addition = widget_style.bar_fill.size_addition

				bar_size_addition[2] = 0

				local fill_widget_color = widget_style.bar_fill.color

				fill_widget_color[1] = 255
			end,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local dodge_bar_widget = params.dodge_bar_widget
				local widget_style = dodge_bar_widget.style
				local color_anim_progress = math.easeOutCubic(1 - progress)
				local fill_widget_color = widget_style.bar_fill.color

				fill_widget_color[2] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[2], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[2], color_anim_progress)
				fill_widget_color[3] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[3], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[3], color_anim_progress)
				fill_widget_color[4] = math.lerp(DODGE_BAR_STATE_COLORS_BAR_FILL.available[4], DODGE_BAR_STATE_COLORS_BAR_FILL.available_on_cooldown[4], color_anim_progress)
			end,
			on_complete = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local dodge_bar = params.dodge_bar

				dodge_bar.animation_id = nil
			end,
		},
	},
	on_bar_restored = {
		{
			end_time = 0.2,
			name = "on_bar_restored",
			start_time = 0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local dodge_bar_widget = params.dodge_bar_widget
				local widget_style = dodge_bar_widget.style
				local anim_progress = math.easeOutCubic(progress)
				local bar_size_addition = widget_style.bar_fill.size_addition

				bar_size_addition[2] = (1 - anim_progress) * 25

				local color_anim_progress = math.easeOutCubic(progress)
				local fill_widget_color = widget_style.bar_fill.color

				fill_widget_color[1] = 255 * color_anim_progress
				fill_widget_color[2] = DODGE_BAR_STATE_COLORS_BAR_FILL.available[2]
				fill_widget_color[3] = DODGE_BAR_STATE_COLORS_BAR_FILL.available[3]
				fill_widget_color[4] = DODGE_BAR_STATE_COLORS_BAR_FILL.available[4]
			end,
			on_complete = function (parent, ui_scenegraph, scenegraph_definition, widgets, params)
				local dodge_bar = params.dodge_bar

				dodge_bar.animation_id = nil
			end,
		},
	},
	on_inefficient_dodge = {
		{
			end_time = 0.3,
			name = "on_inefficient_dodge",
			start_time = 0,
			update = function (parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
				local wide_bar_widget = widgets.wide_bar
				local widget_style = wide_bar_widget.style
				local anim_progress = math.easeOutCubic(progress)
				local bar_size_addition = widget_style.bar_overlap.size_addition

				bar_size_addition[2] = anim_progress * 15

				local color_anim_progress = math.easeOutCubic(progress)
				local fill_widget_color = widget_style.bar_overlap.color

				fill_widget_color[1] = 255 * (1 - color_anim_progress)
			end,
		},
	},
}

local function build(main_row_height, bar_fill_width)
	local vanilla_track = stm_bar_size[1]
	local requested = type(bar_fill_width) == "number" and bar_fill_width or vanilla_track
	local track_width_px = math.max(1, math.floor(requested + 0.5))
	local sg, extend_below, buff_layout_from_stm_ddg = build_scenegraph(main_row_height, track_width_px)
	local wdefs = build_widget_definitions()
	local ddg_top_from_boxes_row = 0

	if type(buff_layout_from_stm_ddg) == "table" and type(buff_layout_from_stm_ddg.ddg_top) == "number" and buff_layout_from_stm_ddg.ddg_top == buff_layout_from_stm_ddg.ddg_top then
		ddg_top_from_boxes_row = buff_layout_from_stm_ddg.ddg_top
	elseif sg and sg.div_dodge_area and type(sg.div_dodge_area.position) == "table" then
		ddg_top_from_boxes_row = sg.div_dodge_area.position[2] or 0
	end

	return {
		scenegraph_definition = sg,
		widget_definitions = wdefs,
		animations = animations,
		stamina_nodges_definition = stamina_nodges_definition,
		dodge_bar_definition = build_dodge_bar_definition(track_width_px),
		extend_below_main_row = extend_below,
		ddg_top_from_boxes_row = ddg_top_from_boxes_row,
		buff_layout_from_stm_ddg = buff_layout_from_stm_ddg,
		division_stamina_bar_width = track_width_px,
		division_dodge_bar_track_width = track_width_px,
	}
end

return {
	build = build,
}
