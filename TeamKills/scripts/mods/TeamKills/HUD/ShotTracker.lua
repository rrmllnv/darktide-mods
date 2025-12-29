local mod = get_mod("TeamKills")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementTeamPanelHandlerSettings = require("scripts/ui/hud/elements/team_panel_handler/hud_element_team_panel_handler_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")

local icons = {
	shots_fired = "content/ui/materials/icons/weapons/actions/special_bullet",
	shots_missed = "content/ui/materials/icons/weapons/actions/smiter",
	head_shot_kill = "content/ui/materials/icons/weapons/actions/ads",
}

local hud_body_font_settings = UIFontSettings.hud_body or {}
local panel_size = HudElementTeamPanelHandlerSettings.panel_size
local BORDER_PADDING = 5
local function get_font_size()
	return mod.font_size or mod:get("opt_font_size") or 16
end

local function get_icon_size()
	local font_size = get_font_size()
	return math.floor(font_size * 1.25)
end

local function get_icon_spacing()
	local font_size = get_font_size()
	return math.floor(font_size * 0.3)
end

local function get_default_panel_height()
	local font_size = get_font_size()
	return math.floor(font_size * (hud_body_font_settings.line_spacing or 1.2)) + BORDER_PADDING * 2
end

local function get_opacity_alpha()
	local opacity = mod.opacity or mod:get("opt_opacity") or 100
	return math.floor((opacity / 100) * 255)
end

local function hide_shot_tracker_widget(widget)
	widget.content.visible = false
	widget.content.text_shots_fired = ""
	widget.content.text_shots_missed = ""
	widget.content.text_head_shot_kill = ""
	widget.content.icon_shots_fired = nil
	widget.content.icon_shots_missed = nil
	widget.content.icon_head_shot_kill = nil
end

local team_kills_width = panel_size[1]
local shot_tracker_width = team_kills_width
local panel_offset = {550, -160, 0}
local background_color = UIHudSettings.color_tint_7
local background_gradient = "content/ui/materials/hud/backgrounds/team_player_panel_background"
local base_size = {shot_tracker_width, get_default_panel_height()}

local function apply_panel_height(self, panel_height)
	local width = base_size[1]

	self:_set_scenegraph_size("ShotTrackerContainer", width, panel_height)

	local widget = self._widgets_by_name.ShotTrackerWidget
	local styles = widget.style
	local panel_background = styles.panel_background

	if panel_background then
		local alpha = get_opacity_alpha()
		if panel_background.color then
			panel_background.color[1] = alpha
		end
		panel_background.size = panel_background.size or {
			width,
			panel_height,
		}
		panel_background.size[1] = width
		panel_background.size[2] = panel_height
	end

	local font_size = get_font_size()
	local alpha = get_opacity_alpha()
	
	local text_shots_fired_style = styles.text_shots_fired
	if text_shots_fired_style then
		text_shots_fired_style.font_size = font_size
		if text_shots_fired_style.text_color then
			text_shots_fired_style.text_color[1] = alpha
		end
	end
	
	local text_shots_missed_style = styles.text_shots_missed
	if text_shots_missed_style then
		text_shots_missed_style.font_size = font_size
		if text_shots_missed_style.text_color then
			text_shots_missed_style.text_color[1] = alpha
		end
	end
	
	local text_head_shot_kill_style = styles.text_head_shot_kill
	if text_head_shot_kill_style then
		text_head_shot_kill_style.font_size = font_size
		if text_head_shot_kill_style.text_color then
			text_head_shot_kill_style.text_color[1] = alpha
		end
	end
	
	local icon_shots_fired_style = styles.icon_shots_fired
	if icon_shots_fired_style and icon_shots_fired_style.color then
		icon_shots_fired_style.color[1] = alpha
	end
	local icon_shots_missed_style = styles.icon_shots_missed
	if icon_shots_missed_style and icon_shots_missed_style.color then
		icon_shots_missed_style.color[1] = alpha
	end
	local icon_head_shot_kill_style = styles.icon_head_shot_kill
	if icon_head_shot_kill_style and icon_head_shot_kill_style.color then
		icon_head_shot_kill_style.color[1] = alpha
	end

	widget.dirty = true
end

local function color_copy(target, source, alpha)
	target[1] = alpha or source[1]
	target[2] = source[2]
	target[3] = source[3]
	target[4] = source[4]

	return target
end

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	ShotTrackerContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "left",
		size = base_size,
		position = {
			panel_offset[1],
			panel_offset[2],
			panel_offset[3] or 10,
		},
	},
}

local function get_shot_tracker_style()
	local font_size = get_font_size()
	local panel_height = get_default_panel_height()
	return {
		line_spacing = 1.2,
		font_size = font_size,
		drop_shadow = true,
		font_type = hud_body_font_settings.font_type or "machine_medium",
		text_color = {255, 255, 255, 255},
		size = {
			shot_tracker_width - BORDER_PADDING * 2,
			panel_height - BORDER_PADDING * 2,
		},
		text_horizontal_alignment = "left",
		text_vertical_alignment = "top",
		offset = {
			BORDER_PADDING,
			BORDER_PADDING,
			0,
		},
	}
end

local function calculate_panel_height(line_count)
	local font_size = get_font_size()
	local line_height = math.floor(font_size * 1.2)
	local default_height = get_default_panel_height()

	if line_count <= 0 then
		return default_height
	end

	local content_height = (line_count * line_height) + BORDER_PADDING * 2

	return math.max(default_height, content_height)
end

local widget_definitions = {
	ShotTrackerWidget = UIWidget.create_definition(
		{
			{
				pass_type = "texture",
				style_id = "icon_shots_fired",
				value_id = "icon_shots_fired",
				style = {
					size = {
						get_icon_size(),
						get_icon_size(),
					},
					offset = {
						BORDER_PADDING,
						BORDER_PADDING + 2,
						3,
					},
					color = UIHudSettings.color_tint_main_2,
				},
				visibility_function = function (content, style)
					local show_tracker = mod:get("opt_show_shot_tracker")
					if show_tracker == false then
						return false
					end
					local show_shots_fired = mod:get("opt_show_shots_fired") ~= false
					return show_shots_fired and content.icon_shots_fired ~= nil
				end,
			},
			{
				pass_type = "text",
				style_id = "text_shots_fired",
				value_id = "text_shots_fired",
				style = {
					font_size = get_font_size(),
					text_vertical_alignment = "top",
					text_horizontal_alignment = "left",
					font_type = hud_body_font_settings.font_type or "machine_medium",
					text_color = Color.white(255, true),
					offset = {
						BORDER_PADDING + get_icon_size() + 4,
						BORDER_PADDING + 2,
						2,
					},
				},
				visibility_function = function (content, style)
					local show_tracker = mod:get("opt_show_shot_tracker")
					if show_tracker == false then
						return false
					end
					local show_shots_fired = mod:get("opt_show_shots_fired") ~= false
					return show_shots_fired and content.text_shots_fired ~= nil and content.text_shots_fired ~= ""
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_shots_missed",
				value_id = "icon_shots_missed",
				style = {
					size = {
						get_icon_size(),
						get_icon_size(),
					},
					offset = {
						BORDER_PADDING,
						BORDER_PADDING + 2,
						3,
					},
					color = UIHudSettings.color_tint_main_2,
				},
				visibility_function = function (content, style)
					local show_tracker = mod:get("opt_show_shot_tracker")
					if show_tracker == false then
						return false
					end
					local show_shots_missed = mod:get("opt_show_shots_missed") ~= false
					return show_shots_missed and content.icon_shots_missed ~= nil
				end,
			},
			{
				pass_type = "text",
				style_id = "text_shots_missed",
				value_id = "text_shots_missed",
				style = {
					font_size = get_font_size(),
					text_vertical_alignment = "top",
					text_horizontal_alignment = "left",
					font_type = hud_body_font_settings.font_type or "machine_medium",
					text_color = Color.white(255, true),
					offset = {
						BORDER_PADDING + get_icon_size() + 4,
						BORDER_PADDING + 2,
						2,
					},
				},
				visibility_function = function (content, style)
					local show_tracker = mod:get("opt_show_shot_tracker")
					if show_tracker == false then
						return false
					end
					local show_shots_missed = mod:get("opt_show_shots_missed") ~= false
					return show_shots_missed and content.text_shots_missed ~= nil and content.text_shots_missed ~= ""
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_head_shot_kill",
				value_id = "icon_head_shot_kill",
				style = {
					size = {
						get_icon_size(),
						get_icon_size(),
					},
					offset = {
						BORDER_PADDING,
						BORDER_PADDING + 2,
						3,
					},
					color = UIHudSettings.color_tint_main_2,
				},
				visibility_function = function (content, style)
					local show_tracker = mod:get("opt_show_shot_tracker")
					if show_tracker == false then
						return false
					end
					local show_head_shot_kill = mod:get("opt_show_head_shot_kill") ~= false
					return show_head_shot_kill and content.icon_head_shot_kill ~= nil
				end,
			},
			{
				pass_type = "text",
				style_id = "text_head_shot_kill",
				value_id = "text_head_shot_kill",
				style = {
					font_size = get_font_size(),
					text_vertical_alignment = "top",
					text_horizontal_alignment = "left",
					font_type = hud_body_font_settings.font_type or "machine_medium",
					text_color = Color.white(255, true),
					offset = {
						BORDER_PADDING + get_icon_size() + 4,
						BORDER_PADDING + 2,
						2,
					},
				},
				visibility_function = function (content, style)
					local show_tracker = mod:get("opt_show_shot_tracker")
					if show_tracker == false then
						return false
					end
					local show_head_shot_kill = mod:get("opt_show_head_shot_kill") ~= false
					return show_head_shot_kill and content.text_head_shot_kill ~= nil and content.text_head_shot_kill ~= ""
				end,
			},
		},
		"ShotTrackerContainer"
	),
}

local ShotTracker = class("ShotTracker", "HudElementBase")

ShotTracker.init = function(self, parent, draw_layer, start_scale)
	ShotTracker.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	self.is_in_hub = mod._is_in_hub()
end

ShotTracker.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	ShotTracker.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	local widget = self._widgets_by_name.ShotTrackerWidget

	if self.is_in_hub then
		hide_shot_tracker_widget(widget)
		return
	else
		widget.content.visible = true
	end
	
	local local_player = Managers.player and Managers.player:local_player(1)
	if not local_player then
		hide_shot_tracker_widget(widget)
		return
	end
	
	local local_account_id = local_player:account_id() or local_player:name()
	if not local_account_id then
		hide_shot_tracker_widget(widget)
		return
	end
	
	local shots_fired = mod.player_shots_fired and mod.player_shots_fired[local_account_id] or 0
	local shots_missed = mod.player_shots_missed and mod.player_shots_missed[local_account_id] or 0
	local head_shot_kill = mod.player_head_shot_kill and mod.player_head_shot_kill[local_account_id] or 0
	
	local show_shots_fired = mod:get("opt_show_shots_fired") ~= false
	local show_shots_missed = mod:get("opt_show_shots_missed") ~= false
	local show_head_shot_kill = mod:get("opt_show_head_shot_kill") ~= false
	
	local styles = widget.style
	local font_size = get_font_size()
	local icon_size = get_icon_size()
	local icon_spacing = get_icon_spacing()
	local current_x = BORDER_PADDING
	
	if show_shots_fired then
		widget.content.icon_shots_fired = icons.shots_fired
		widget.style.icon_shots_fired.color = UIHudSettings.color_tint_main_2
		widget.content.text_shots_fired = tostring(shots_fired)
		styles.icon_shots_fired.size[1] = icon_size
		styles.icon_shots_fired.size[2] = icon_size
		styles.icon_shots_fired.offset[1] = current_x
		styles.text_shots_fired.offset[1] = current_x + icon_size + 4
		local text_width, _ = Text.text_size(ui_renderer, widget.content.text_shots_fired, styles.text_shots_fired)
		current_x = current_x + icon_size + 4 + text_width + icon_spacing
	else
		widget.content.icon_shots_fired = nil
		widget.content.text_shots_fired = ""
	end
	
	if show_shots_missed then
		widget.content.icon_shots_missed = icons.shots_missed
		widget.style.icon_shots_missed.color = UIHudSettings.color_tint_main_2
		widget.content.text_shots_missed = tostring(shots_missed)
		styles.icon_shots_missed.size[1] = icon_size
		styles.icon_shots_missed.size[2] = icon_size
		styles.icon_shots_missed.offset[1] = current_x
		styles.text_shots_missed.offset[1] = current_x + icon_size + 4
		local text_width, _ = Text.text_size(ui_renderer, widget.content.text_shots_missed, styles.text_shots_missed)
		current_x = current_x + icon_size + 4 + text_width + icon_spacing
	else
		widget.content.icon_shots_missed = nil
		widget.content.text_shots_missed = ""
	end
	
	if show_head_shot_kill then
		widget.content.icon_head_shot_kill = icons.head_shot_kill
		widget.style.icon_head_shot_kill.color = UIHudSettings.color_tint_main_2
		widget.content.text_head_shot_kill = tostring(head_shot_kill)
		styles.icon_head_shot_kill.size[1] = icon_size
		styles.icon_head_shot_kill.size[2] = icon_size
		styles.icon_head_shot_kill.offset[1] = current_x
		styles.text_head_shot_kill.offset[1] = current_x + icon_size + 4
	else
		widget.content.icon_head_shot_kill = nil
		widget.content.text_head_shot_kill = ""
	end
	
	if not show_shots_fired and not show_shots_missed and not show_head_shot_kill then
		widget.content.visible = false
		return
	end
	
	local panel_height = calculate_panel_height(1)
	apply_panel_height(self, panel_height)
	
	widget.content.visible = true
	widget.dirty = true
end

ShotTracker.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
	if self.is_in_hub then
		return
	end

	local widget = self._widgets_by_name.ShotTrackerWidget
	if not widget or not widget.content.visible then
		return
	end

	ShotTracker.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return ShotTracker

