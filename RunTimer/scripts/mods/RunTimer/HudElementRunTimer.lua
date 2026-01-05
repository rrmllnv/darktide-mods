local mod = get_mod("RunTimer")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISettings = require("scripts/settings/ui/ui_settings")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")

local DEBUG_SHOW_IN_HUB = false
local hud_body_font_settings = UIFontSettings.hud_body or {}
local FONT_SIZE_MIN = 15
local FONT_SIZE_MAX = 30
local DEFAULT_FONT_SIZE = 20
local DEFAULT_COLOR_NAME = "orange"
local DEFAULT_POSITION = "left"
local TIMER_WIDTH = 80
local BORDER_PADDING = 5

local COLOR_PRESETS = {
	white = {255, 255, 255, 255},
	red = {255, 255, 54, 36},
	green = {255, 61, 112, 55},
	blue = {255, 30, 144, 255},
	yellow = {255, 226, 199, 126},
	orange = {255, 255, 183, 44},
	purple = {255, 166, 93, 172},
	cyan = {255, 107, 209, 241},
	teal = {255, 62, 143, 155},
	gold = {255, 196, 195, 108},
	purple_deep = {255, 130, 66, 170},
	magenta = {255, 102, 38, 98},
	orange_dark = {255, 148, 46, 14},
	orange_medium = {255, 245, 121, 21},
	amber = {255, 191, 151, 73},
	grey = {255, 102, 102, 102},
}

local POSITION_PRESETS = {
	left = {
		background = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			position = {
				50,
				10,
				1,
			},
			flip_uvs = false,
		},
		text = {
			horizontal_alignment = "left",
			vertical_alignment = "center",
			position = {
				0,
				0,
				2,
			},
			text_alignment = "left",
			offset = {20, 0, 0},
		},
	},
	center = {
		background = {
			horizontal_alignment = "center",
			vertical_alignment = "top",
			position = {
				0,
				10,
				1,
			},
			flip_uvs = false,
		},
		text = {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			position = {
				0,
				0,
				2,
			},
			text_alignment = "center",
			offset = {10, 0, 0},
		},
	},
	right = {
		background = {
			horizontal_alignment = "right",
			vertical_alignment = "top",
			position = {
				-50,
				10,
				1,
			},
			flip_uvs = true,
		},
		text = {
			horizontal_alignment = "right",
			vertical_alignment = "center",
			position = {
				0,
				0,
				2,
			},
			text_alignment = "right",
			offset = {-20, 0, 0},
		},
	},
}

local BACKGROUND_STYLE_PRESETS = {
	left = {
		material = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
		color = Color.terminal_background_gradient(178.5, true),
	},
	center = {
		material = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
		color = Color.terminal_background_gradient(178.5, true),
	},
	right = {
		material = "content/ui/materials/hud/backgrounds/terminal_background_weapon",
		color = Color.terminal_background_gradient(255, true),
	},
}

local function current_font_size()
	local value = mod:get("font_size") or DEFAULT_FONT_SIZE

	return math.clamp(value, FONT_SIZE_MIN, FONT_SIZE_MAX)
end

local function current_font_color()
	local color_name = mod:get("font_color") or DEFAULT_COLOR_NAME

	return COLOR_PRESETS[color_name] or COLOR_PRESETS[DEFAULT_COLOR_NAME]
end

local function current_position()
	return mod:get("timer_position") or DEFAULT_POSITION
end

local function get_opacity_alpha()
	local opacity = mod:get("opacity") or 100
	return math.floor((opacity / 100) * 255)
end

local function calculate_timer_height()
	local font_size = current_font_size()
	return math.floor(font_size * (hud_body_font_settings.line_spacing or 1.2)) + BORDER_PADDING * 2
end

local function clone_style(base_style, color)
	local style = table.clone(base_style)

	local color_override = color or current_font_color()

	style.text_color = color_override and table.clone(color_override) or style.text_color
	style.color = color and table.clone(color) or style.color
	style.font_size = current_font_size()
	style.font_type = hud_body_font_settings.font_type or "machine_medium"
	style.text_vertical_alignment = "center"
	style.text_horizontal_alignment = "center"
	style.offset = {
		0,
		0,
		0,
	}

	return style
end

local function create_scenegraph_definition()
	local timer_height = calculate_timer_height()
	local container_width = TIMER_WIDTH -- * 2 + 10 -- Два таймера + отступ между ними
	return {
		screen = UIWorkspaceSettings.screen,
		run_timer_background = {
			horizontal_alignment = "left",
			parent = "screen",
			vertical_alignment = "top",
			size = {
				container_width,
				timer_height,
			},
			position = {
				0,
				0,
				1,
			},
		},
		run_timer_text = {
			horizontal_alignment = "left",
			parent = "run_timer_background",
			vertical_alignment = "center",
			size = {
				TIMER_WIDTH,
				timer_height,
			},
			position = {
				0,
				0,
				2,
			},
		},
		speedometer_text = {
			horizontal_alignment = "left",
			parent = "run_timer_background",
			vertical_alignment = "center",
			size = {
				TIMER_WIDTH,
				timer_height,
			},
			position = {
				0,
				0,
				2,
			},
		},
	}
end

local scenegraph_definition = create_scenegraph_definition()

local timer_background_color = Color.terminal_background_gradient(178.5, true)
local timer_active_text_style = clone_style(UIFontSettings.body, {
	255,
	221,
	153,
	51,
})

local widget_definitions = {
	run_timer_background = UIWidget.create_definition({
		{
			visible = false,
			pass_type = "texture",
			style_id = "texture",
			value = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
			value_id = "texture",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				offset = {
					0,
					0,
					0,
				},
				color = timer_background_color,
			},
			visibility_function = function(content)
				local show_background = mod:get("show_background") or 1
				return content.visible and show_background == 1
			end,
		},
		{
			pass_type = "texture",
			style_id = "edge_line",
			value_id = "edge_line_visible",
			value = "content/ui/materials/dividers/faded_line_01",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				color = Color.terminal_corner(255, true),
				size = {4, calculate_timer_height()},
				offset = {
					0,
					0,
					1,
				},
			},
			visibility_function = function(content)
				local show_background = mod:get("show_background") or 1
				return content.visible and content.edge_line_visible and show_background == 1
			end,
		},
	}, "run_timer_background"),
	run_timer_text = UIWidget.create_definition({
		{
			visible = false,
			pass_type = "text",
			style_id = "text",
			value = "",
			value_id = "text",
			style = timer_active_text_style,
		},
	}, "run_timer_text"),
	speedometer_text = UIWidget.create_definition({
		{
			visible = false,
			pass_type = "text",
			style_id = "speed",
			value = "",
			value_id = "speed",
			style = clone_style(UIFontSettings.body),
		},
	}, "speedometer_text"),
}

local function format_double_digit(value)
	return string.format("%02d", math.floor(value))
end

local function format_triple_digit(value)
	return string.format("%03d", math.floor(value))
end

local function digits_to_symbols(text)
	local result = {}

	for character in text:gmatch(".") do
		if character == ":" then
			result[#result + 1] = ":"
		else
			local number = tonumber(character)

			if number then
				result[#result + 1] = UISettings.digital_clock_numbers[number]
			end
		end
	end

	return table.concat(result)
end

local function format_time_by_mode(gameplay_time, mode)
	local minutes = gameplay_time / 60
	local seconds = gameplay_time % 60
	local milliseconds = (gameplay_time - math.floor(gameplay_time)) * 1000
	
	if mode == 1 then
		-- Только минуты
		local minutes_text = format_double_digit(minutes)
		return digits_to_symbols(minutes_text)
	elseif mode == 3 then
		-- Минуты:Секунды:Миллисекунды
		local minutes_text = format_double_digit(minutes)
		local seconds_text = format_double_digit(seconds)
		local ms_text = format_triple_digit(milliseconds)
		return digits_to_symbols(minutes_text .. ":" .. seconds_text .. ":" .. ms_text)
	else
		-- Минуты:Секунды (по умолчанию, mode == 2)
		local minutes_text = format_double_digit(minutes)
		local seconds_text = format_double_digit(seconds)
		return digits_to_symbols(minutes_text .. ":" .. seconds_text)
	end
end

local HUB_GAME_MODES = {
	hub = true,
	prologue_hub = true,
	shooting_range = true,
}

local function should_show_timer()
	if DEBUG_SHOW_IN_HUB then
		return true
	end

	local game_mode_manager = Managers.state and Managers.state.game_mode

	if not game_mode_manager then
		return false
	end

	local mode = game_mode_manager:game_mode_name()

	if HUB_GAME_MODES[mode] then
		return false
	end

	local time_manager = Managers.time

	return time_manager and time_manager:has_timer("gameplay")
end

local HudElementRunTimer = class("HudElementRunTimer", "HudElementBase")

HudElementRunTimer.init = function(self, parent, draw_layer, start_scale)
	HudElementRunTimer.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})

	mod._run_timer_hud_element = self
	
	-- Кэшируем настройки для оптимизации
	self._cached_exclude_intro = mod:get("exclude_intro_time") or 1
	self._cached_timer_format = mod:get("timer_format") or 2
	
	-- Инициализируем спидометр
	local speedometer_widget = self._widgets_by_name and self._widgets_by_name.speedometer_text
	if speedometer_widget then
		speedometer_widget.content.speed = ""
		speedometer_widget.content.visible = false
	end
	
	self:_apply_style()
	self:_apply_layout()
end

HudElementRunTimer.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementRunTimer.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local text_widget = self._widgets_by_name.run_timer_text
	local background_widget = self._widgets_by_name.run_timer_background
	local speedometer_widget = self._widgets_by_name.speedometer_text

	if not text_widget or not background_widget then
		return
	end

	local visible = should_show_timer()
	local speedometer_enabled = mod:get("speedometer_enabled") or false

	text_widget.content.visible = visible
	background_widget.content.visible = visible
	
	-- Обновляем спидометр независимо от видимости таймера, но только если включен
	if speedometer_enabled and speedometer_widget then
		local speed_text = ""
		local player = Managers.player:local_player(1)
		if player and player:unit_is_alive() then
			local player_unit = player.player_unit
			if player_unit then
				local locomotion_extension = ScriptUnit.has_extension(player_unit, "locomotion_system")
				if locomotion_extension then
					local velocity = locomotion_extension:current_velocity()
					if velocity ~= nil then
						local speed = Vector3.length(velocity)
						speed_text = string.format("%.2f", speed)
					end
				end
			end
		end
		speedometer_widget.content.speed = speed_text
		speedometer_widget.content.visible = visible
		speedometer_widget.dirty = true
	elseif speedometer_widget then
		speedometer_widget.content.visible = false
		speedometer_widget.content.speed = ""
		speedometer_widget.dirty = true
	end

	if not visible then
		return
	end

	local time_manager = Managers.time
	local gameplay_time = 0

	if time_manager and time_manager:has_timer("gameplay") then
		gameplay_time = time_manager:time("gameplay")
		-- Вычитаем время intro если настройка включена и время зафиксировано через хук
		local should_exclude_intro = self._cached_exclude_intro == 2
		if should_exclude_intro and mod._intro_end_time and mod._intro_end_time > 0 then
			gameplay_time = gameplay_time - mod._intro_end_time
		end
	end

	-- Используем кэшированный формат
	local digital_text = format_time_by_mode(gameplay_time, self._cached_timer_format)

	text_widget.content.text = digital_text
end

HudElementRunTimer._apply_style = function(self)
	-- Обновляем высоту на основе размера шрифта
	local timer_height = calculate_timer_height()
	local container_width = TIMER_WIDTH * 2 + 10 -- Два таймера + отступ между ними
	self:_set_scenegraph_size("run_timer_background", container_width, timer_height)
	self:_set_scenegraph_size("run_timer_text", TIMER_WIDTH, timer_height)
	self:_set_scenegraph_size("speedometer_text", TIMER_WIDTH, timer_height)
	
	local text_widget = self._widgets_by_name and self._widgets_by_name.run_timer_text

	if text_widget and text_widget.style and text_widget.style.text then
		local alpha = get_opacity_alpha()
		text_widget.style.text.font_size = current_font_size()
		local color = table.clone(current_font_color())
		color[1] = alpha
		text_widget.style.text.text_color = color
		text_widget.dirty = true
	end
	
	local speedometer_widget = self._widgets_by_name and self._widgets_by_name.speedometer_text
	if speedometer_widget and speedometer_widget.style and speedometer_widget.style.speed then
		local alpha = get_opacity_alpha()
		speedometer_widget.style.speed.font_size = current_font_size()
		local color = table.clone(current_font_color())
		color[1] = alpha
		speedometer_widget.style.speed.text_color = color
		speedometer_widget.dirty = true
	end
	
	local background_widget = self._widgets_by_name and self._widgets_by_name.run_timer_background
	if background_widget and background_widget.style then
		local alpha = get_opacity_alpha()
		
		if background_widget.style.texture and background_widget.style.texture.color then
			background_widget.style.texture.color[1] = alpha
		end
		
		if background_widget.style.edge_line and background_widget.style.edge_line.color then
			background_widget.style.edge_line.color[1] = alpha
			background_widget.style.edge_line.size[2] = timer_height
		end
		
		background_widget.dirty = true
	end
end

HudElementRunTimer._apply_layout = function(self)
	local position = current_position()
	local preset = POSITION_PRESETS[position] or POSITION_PRESETS[DEFAULT_POSITION]
	local style_preset = BACKGROUND_STYLE_PRESETS[position] or BACKGROUND_STYLE_PRESETS[DEFAULT_POSITION]
	local background_settings = preset.background
	local text_settings = preset.text

	if background_settings and background_settings.position then
		self:set_scenegraph_position(
			"run_timer_background",
			background_settings.position[1],
			background_settings.position[2],
			background_settings.position[3],
			background_settings.horizontal_alignment,
			background_settings.vertical_alignment
		)
	end

	if text_settings and text_settings.position then
		self:set_scenegraph_position(
			"run_timer_text",
			text_settings.position[1],
			text_settings.position[2],
			text_settings.position[3],
			text_settings.horizontal_alignment,
			text_settings.vertical_alignment
		)

		local text_widget = self._widgets_by_name and self._widgets_by_name.run_timer_text

		if text_widget and text_widget.style and text_widget.style.text then
			text_widget.style.text.text_horizontal_alignment = text_settings.text_alignment or text_settings.horizontal_alignment or "left"
			if text_settings.offset then
				text_widget.style.text.offset = table.clone(text_settings.offset)
			end
			text_widget.dirty = true
		end
		
		-- Настраиваем спидометр рядом с таймером (в том же контейнере)
		local speedometer_widget = self._widgets_by_name and self._widgets_by_name.speedometer_text
		if speedometer_widget then
			-- Спидометр уже позиционирован в scenegraph относительно контейнера
			-- Просто применяем те же настройки стиля, что и для таймера
			if speedometer_widget.style and speedometer_widget.style.speed then
				speedometer_widget.style.speed.text_horizontal_alignment = text_settings.text_alignment or text_settings.horizontal_alignment or "left"
				if text_settings.offset then
					speedometer_widget.style.speed.offset = table.clone(text_settings.offset)
				end
				speedometer_widget.dirty = true
			end
		end
	end

	local background_widget = self._widgets_by_name and self._widgets_by_name.run_timer_background

	if background_widget and background_widget.style and background_widget.style.texture then
		local texture_style = background_widget.style.texture

		texture_style.horizontal_alignment = background_settings.horizontal_alignment or texture_style.horizontal_alignment
		texture_style.vertical_alignment = background_settings.vertical_alignment or texture_style.vertical_alignment

		if background_settings.offset then
			texture_style.offset = table.clone(background_settings.offset)
		end

		background_widget.content.texture = style_preset.material
		texture_style.color = table.clone(style_preset.color)

		if background_settings.flip_uvs then
			texture_style.uvs = {
				{1, 0},
				{0, 1},
			}
		else
			texture_style.uvs = {
				{0, 0},
				{1, 1},
			}
		end

		local edge_line_style = background_widget.style.edge_line
		if edge_line_style then
			if position == "right" then
				edge_line_style.horizontal_alignment = "right"
				edge_line_style.offset = {0, 0, 1}
				background_widget.content.edge_line_visible = true
			elseif position == "left" then
				edge_line_style.horizontal_alignment = "left"
				edge_line_style.offset = {0, 0, 1}
				background_widget.content.edge_line_visible = true
			elseif position == "center" then
				edge_line_style.horizontal_alignment = "left"
				edge_line_style.offset = {0, 0, 1}
				background_widget.content.edge_line_visible = true
			end
		end

		background_widget.dirty = true
	end

	self._update_scenegraph = true
end

HudElementRunTimer.destroy = function(self, ui_renderer)
	if mod._run_timer_hud_element == self then
		mod._run_timer_hud_element = nil
	end

	HudElementRunTimer.super.destroy(self, ui_renderer)
end

return HudElementRunTimer

