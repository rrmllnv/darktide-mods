local mod = get_mod("TeamKills")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementTeamPanelHandlerSettings = require("scripts/ui/hud/elements/team_panel_handler/hud_element_team_panel_handler_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")

local hud_body_font_settings = UIFontSettings.hud_body or {}
local panel_size = HudElementTeamPanelHandlerSettings.panel_size
local BORDER_PADDING = 5
local function get_font_size()
	return mod.font_size or mod:get("font_size") or 16
end

local function get_default_panel_height()
	local font_size = get_font_size()
	return math.floor(font_size * (hud_body_font_settings.line_spacing or 1.2)) + BORDER_PADDING * 2
end

local function get_opacity_alpha()
	local opacity = mod.opacity or mod:get("opacity") or 100
	return math.floor((opacity / 100) * 255)
end
local panel_offset = {550, -200, 0}
local background_color = UIHudSettings.color_tint_7
local background_gradient = "content/ui/materials/hud/backgrounds/team_player_panel_background"
local width = panel_size[1]
local base_size = {width, get_default_panel_height()}
local function apply_panel_height(self, panel_height)
	local width = base_size[1]

	self:_set_scenegraph_size("teamKillContainer", width, panel_height)

	local widget = self._widgets_by_name.teamKillCounter
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

	local hit_indicator = styles.hit_indicator

	if hit_indicator then
		local alpha = get_opacity_alpha()
		if hit_indicator.color then
			hit_indicator.color[1] = alpha
		end
		hit_indicator.size = hit_indicator.size or {
			width + 20,
			panel_height + 20,
		}
		hit_indicator.size[1] = width + 20
		hit_indicator.size[2] = panel_height + 20
	end

	local hit_indicator_armor_break = styles.hit_indicator_armor_break

	if hit_indicator_armor_break then
		local alpha = get_opacity_alpha()
		if hit_indicator_armor_break.color then
			hit_indicator_armor_break.color[1] = alpha
		end
		hit_indicator_armor_break.size = hit_indicator_armor_break.size or {
			width,
			panel_height,
		}
		hit_indicator_armor_break.size[1] = width
		hit_indicator_armor_break.size[2] = panel_height
	end

	local text_style = styles.text

	if text_style then
		local font_size = get_font_size()
		local alpha = get_opacity_alpha()
		text_style.font_size = font_size
		if text_style.text_color then
			text_style.text_color[1] = alpha
		end
		text_style.size = text_style.size or {
			width - BORDER_PADDING * 2,
			panel_height - BORDER_PADDING * 2,
		}
		text_style.size[1] = width - BORDER_PADDING * 2
		text_style.size[2] = math.max(BORDER_PADDING * 2, panel_height - BORDER_PADDING * 2)
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
	teamKillContainer = {
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

local function get_team_kill_style()
	local font_size = get_font_size()
	local panel_height = get_default_panel_height()
	return {
		line_spacing = 1.2,
		font_size = font_size,
		drop_shadow = true,
		font_type = hud_body_font_settings.font_type or "machine_medium",
		text_color = {255, 255, 255, 255},
		size = {
			width - BORDER_PADDING * 2,
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
	teamKillCounter = UIWidget.create_definition(
		{
			{
				value = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
				pass_type = "texture",
				style_id = "panel_background",
				style = {
					horizontal_alignment = "left",
					color = Color.terminal_background_gradient(178.5, true),
					size = {
						base_size[1],
						base_size[2],
					},
					offset = {
						0,
						0,
						0,
					},
				},
				visibility_function = function (content)
					local show_background = mod.show_background or mod:get("show_background") or 1
					return content.visible and show_background == 1
				end,
			},
			{
				value = "content/ui/materials/frames/dropshadow_medium",
				pass_type = "texture",
				style_id = "hit_indicator",
				style = {
					horizontal_alignment = "center",
					scale_to_material = true,
					vertical_alignment = "center",
					color = color_copy({}, UIHudSettings.color_tint_6, 0),
					size_addition = {
						20,
						20,
					},
					default_size_addition = {
						20,
						20,
					},
					offset = {
						0,
						0,
						1,
					},
				},
				visibility_function = function (content)
					local show_background = mod.show_background or mod:get("show_background") or 1
					return content.visible and show_background == 1
				end,
			},
			{
				value = "content/ui/materials/frames/inner_shadow_medium",
				pass_type = "texture",
				style_id = "hit_indicator_armor_break",
				style = {
					horizontal_alignment = "center",
					scale_to_material = true,
					vertical_alignment = "center",
					color = color_copy({}, UIHudSettings.color_tint_6, 0),
					size_addition = {
						0,
						0,
					},
					offset = {
						0,
						0,
						1,
					},
				},
				visibility_function = function (content)
					local show_background = mod.show_background or mod:get("show_background") or 1
					return content.visible and show_background == 1
				end,
			},
			{
				pass_type = "text",
				value = "",
				value_id = "text",
				style_id = "text",
				style = get_team_kill_style(),
				visibility_function = function (content)
					return content.visible
				end,
			},
		},
		"teamKillContainer"
	),
}

local function create_team_kill_text()
    local lines = {}

    local mode = mod.hud_counter_mode or mod:get("hud_counter_mode") or 1
    local show_team_summary = mod.show_team_summary or mod:get("show_team_summary") or 1

    local players = Managers.player:players()

    -- Сортируем игроков по количеству убийств
    local sorted_players = {}
    for _, player in pairs(players) do
        local account_id = player:account_id() or player:name() or "Player"
        table.insert(sorted_players, {
            player = player,
            account_id = account_id,
            kills = mod.player_kills[account_id] or 0,
            damage = mod.player_damage[account_id] or 0,
            last_damage = mod.player_last_damage[account_id] or 0,
        })
    end

    table.sort(sorted_players, function(a, b)
        return a.kills > b.kills
    end)

    local kills_color = mod.get_kills_color_string()
    local damage_color = mod.get_damage_color_string()
    local last_damage_color = mod.get_last_damage_color_string()

    local function should_show_player(account_id)
        if mod.display_mode == 2 then -- only me
            return account_id == (Managers.player:local_player() and Managers.player:local_player():account_id())
        elseif mod.display_mode == 3 then -- hide all
            return false
        elseif mod.display_mode == 4 then -- everyone except me
            return account_id ~= (Managers.player:local_player() and Managers.player:local_player():account_id())
        end
        return true -- mode 1: show all
    end

    local total_kills = 0
    local total_damage = 0
    local total_last_damage = 0

    for _, data in ipairs(sorted_players) do
        total_kills = total_kills + data.kills
        total_damage = total_damage + data.damage
        total_last_damage = total_last_damage + data.last_damage

        if should_show_player(data.account_id) then
            local name = data.player and data.player:name() or "Player"
            local kills_str = string.format("%s%s{#color(255,255,255)}", kills_color, mod.format_number(data.kills))
            local damage_str = string.format("%s%s{#color(255,255,255)}", damage_color, mod.format_number(data.damage))
            local last_damage_str = string.format("%s%s{#color(255,255,255)}", last_damage_color, mod.format_number(data.last_damage))

            local line = ""

            if mode == 1 then -- kills + total damage
                line = string.format("%s: Kills %s / Dmg %s", name, kills_str, damage_str)
            elseif mode == 2 then -- kills only
                line = string.format("%s: Kills %s", name, kills_str)
            elseif mode == 3 then -- total damage only
                line = string.format("%s: Dmg %s", name, damage_str)
            elseif mode == 4 then -- last hit damage only
                line = string.format("%s: Last %s", name, last_damage_str)
            elseif mode == 5 then -- kills + last damage
                line = string.format("%s: Kills %s / Last %s", name, kills_str, last_damage_str)
            elseif mode == 6 then -- kills + total + last
                line = string.format("%s: Kills %s / Dmg %s / Last %s", name, kills_str, damage_str, last_damage_str)
            end

            table.insert(lines, line)
        end
    end

    if show_team_summary == 1 then
        local kills_str = string.format("%s%s{#color(255,255,255)}", kills_color, mod.format_number(total_kills))
        local damage_str = string.format("%s%s{#color(255,255,255)}", damage_color, mod.format_number(total_damage))
        local last_damage_str = string.format("%s%s{#color(255,255,255)}", last_damage_color, mod.format_number(total_last_damage))

        local summary_line = string.format("TEAM KILLS: %s / DMG: %s / LAST: %s", kills_str, damage_str, last_damage_str)
        table.insert(lines, 1, summary_line)
    end

    return lines
end

local HudElementPlayerStats = class("HudElementPlayerStats", "HudElementBase")

HudElementPlayerStats.init = function(self, parent, draw_layer, start_scale, definitions)
	local definitions = definitions or {}
	definitions = table.clone(definitions)
	definitions.scenegraph_definition = scenegraph_definition
	definitions.widget_definitions = widget_definitions

	HudElementPlayerStats.super.init(self, parent, draw_layer, start_scale, definitions)

	mod.hud_element = self

	self:force_update()
end

HudElementPlayerStats.destroy = function(self, ui_renderer)
	mod.hud_element = nil
	HudElementPlayerStats.super.destroy(self, ui_renderer)
end

HudElementPlayerStats.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	if mod._is_in_hub() then
		self:set_widgets_visibility(false)
		return
	end
    
	if self._dirty then
		self:force_update()
	end

	HudElementPlayerStats.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

HudElementPlayerStats.set_dirty = function(self)
	if self._dirty then
		return
	end

	self._dirty = true
end

HudElementPlayerStats.force_update = function(self)
	self._dirty = false

	local widget = self._widgets_by_name.teamKillCounter
	local content = widget.content
	local style = widget.style

	local lines = create_team_kill_text()
	local text = table.concat(lines, "\n")
	content.text = text
	content.visible = text ~= ""

	local line_count = #lines
	local panel_height = calculate_panel_height(line_count)

	apply_panel_height(self, panel_height)

	widget.dirty = true
end

HudElementPlayerStats.set_widgets_visibility = function(self, visible)
	local widget = self._widgets_by_name.teamKillCounter
	widget.content.visible = visible
	widget.dirty = true
end

return HudElementPlayerStats

