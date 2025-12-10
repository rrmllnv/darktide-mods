local mod = get_mod("TeamKillTracker")

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
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				style = get_team_kill_style(),
			},
		},
		"teamKillContainer"
	),
}

local HudElementPlayerStats = class("HudElementPlayerStats", "HudElementBase")

HudElementPlayerStats.init = function(self, parent, draw_layer, start_scale)
	HudElementPlayerStats.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	self.is_in_hub = mod._is_in_hub()
end

HudElementPlayerStats.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementPlayerStats.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	local widget = self._widgets_by_name.teamKillCounter

	if self.is_in_hub then
		widget.content.visible = false
		widget.content.text = ""

		return
	else
		widget.content.visible = true
	end
	
    -- Сдвиг по стилю текста, если скрыты строки пользователей, но показывается строка Team Kills
    -- Обновление текста
    local total_kills = 0
    local total_damage = 0
    local total_last_damage = 0
    local players_with_kills = {}
    local local_account_id
    do
        local local_player = Managers.player and Managers.player:local_player(1)
        if local_player then
            local_account_id = local_player:account_id() or local_player:name()
        end
    end
	
	-- Получаем список текущих игроков в команде
	local current_players = {}
    if Managers.player then
        local players = Managers.player:players()
        for _, player in pairs(players) do
            if player then
                local account_id = player:account_id() or player:name()
				local character_name = player.character_name and player:character_name()
                if account_id then
                    current_players[account_id] = character_name or player:name() or account_id
                end
            end
        end
    end
	
	-- Собираем убийства только текущих игроков с убийствами > 0
    for account_id, kills in pairs(mod.player_kills or {}) do
        local display_name = current_players[account_id]
        if kills > 0 and display_name then
            total_kills = total_kills + kills
            local damage = (mod.player_damage and mod.player_damage[account_id]) or 0
            total_damage = total_damage + math.floor(damage)
            local last_damage = (mod.player_last_damage and mod.player_last_damage[account_id]) or 0
            total_last_damage = total_last_damage + math.floor(last_damage)
            table.insert(players_with_kills, {name = display_name, kills = kills, damage = damage, last_damage = last_damage, account_id = account_id})
        end
    end
	
	-- Сортируем по убийствам (больше сверху)
    table.sort(players_with_kills, function(a, b)
        if a.kills == b.kills then
            return (a.damage or 0) > (b.damage or 0)
        end
        return a.kills > b.kills
    end)
	
    -- Формируем текст с учетом настроек
	local lines = {}
    local mode = mod.hud_counter_mode or mod:get("hud_counter_mode") or 1
    local display_mode = mod.display_mode or mod:get("display_mode") or 1
    local team_summary_setting = mod.show_team_summary or mod:get("show_team_summary") or 1
    local show_team_summary = team_summary_setting == 1
    local show_player_lines = display_mode ~= 3
    local show_only_me = display_mode == 2
    local exclude_me = display_mode == 4
    local kills_color = mod.get_kills_color_string()
    local damage_color = mod.get_damage_color_string()
    local last_damage_color = mod.get_last_damage_color_string()
    local reset_color = "{#reset()}"
    
    if show_team_summary then
        if mode == 1 then
            table.insert(lines, "TEAM KILLS: " .. kills_color .. total_kills .. reset_color .. " (" .. damage_color .. mod.format_number(total_damage) .. reset_color .. ")")
        elseif mode == 2 then
            table.insert(lines, "TEAM KILLS: " .. kills_color .. total_kills .. reset_color)
        elseif mode == 3 then
            table.insert(lines, "TEAM DAMAGE: " .. damage_color .. mod.format_number(total_damage) .. reset_color)
        elseif mode == 4 then
            table.insert(lines, "TEAM LAST DAMAGE: " .. last_damage_color .. mod.format_number(total_last_damage) .. reset_color)
        elseif mode == 5 then
            table.insert(lines, "TEAM KILLS: " .. kills_color .. total_kills .. reset_color .. " [" .. last_damage_color .. mod.format_number(total_last_damage) .. reset_color .. "]")
        elseif mode == 6 then
            table.insert(lines, "TEAM KILLS: " .. kills_color .. total_kills .. reset_color .. " (" .. damage_color .. mod.format_number(total_damage) .. reset_color .. ") [" .. last_damage_color .. mod.format_number(total_last_damage) .. reset_color .. "]")
        end
    end

    if show_player_lines and #players_with_kills > 0 then
        for _, player in ipairs(players_with_kills) do
            if show_only_me and (not local_account_id or player.account_id ~= local_account_id) then
                goto continue
            end

            if exclude_me and local_account_id and player.account_id == local_account_id then
                goto continue
            end

            local dmg = math.floor(player.damage or 0)
            local last_dmg = math.floor(player.last_damage or 0)

            if mode == 1 then
                table.insert(lines, player.name .. ": " .. kills_color .. player.kills .. reset_color .. " (" .. damage_color .. mod.format_number(dmg) .. reset_color .. ")")
            elseif mode == 2 then
                table.insert(lines, player.name .. ": " .. kills_color .. player.kills .. reset_color)
            elseif mode == 3 then
                table.insert(lines, player.name .. ": " .. damage_color .. mod.format_number(dmg) .. reset_color)
            elseif mode == 4 then
                table.insert(lines, player.name .. ": [" .. last_damage_color .. mod.format_number(last_dmg) .. reset_color .. "]")
            elseif mode == 5 then
                table.insert(lines, player.name .. ": " .. kills_color .. player.kills .. reset_color .. " [" .. last_damage_color .. mod.format_number(last_dmg) .. reset_color .. "]")
            elseif mode == 6 then
                table.insert(lines, player.name .. ": " .. kills_color .. player.kills .. reset_color .. " (" .. damage_color .. mod.format_number(dmg) .. reset_color .. ") [" .. last_damage_color .. mod.format_number(last_dmg) .. reset_color .. "]")
            end
            ::continue::
        end
    end

	-- Скрываем виджет если нет строк для отображения
	if #lines == 0 then
		widget.content.visible = false
		widget.content.text = ""
		return
	end

	local panel_height = calculate_panel_height(#lines)

    apply_panel_height(self, panel_height)

    local display_text = table.concat(lines, "\n")
    self._widgets_by_name.teamKillCounter.content.text = display_text
end

return HudElementPlayerStats