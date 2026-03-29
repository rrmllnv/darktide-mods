local mod = get_mod("RunTimer")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISettings = require("scripts/settings/ui/ui_settings")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")

local DEBUG_SHOW_IN_HUB = false
local hud_body_font_settings = UIFontSettings.hud_body or {}
local FONT_SIZE_MIN = 15
local FONT_SIZE_MAX = 40
local DEFAULT_FONT_SIZE = 20
local DEFAULT_COLOR_NAME = "white"
local DEFAULT_FONT_TYPE = "proxima_nova_bold"
local DEFAULT_POSITION = "left"
local DEFAULT_VERTICAL_POSITION = "top"
local TIMER_COLUMN_GAP = 10
-- Fallback до первого кадра с ui_renderer (см. measure_timer_text_column_width).
-- Формат 1: %02d по минутам — обычно 2 символа, до «999» мин (16+ ч) — 3 символа; не резервируем 4–5 цифр.
local TIMER_WIDTH_HEURISTIC_FMT1_MIN = 18
local TIMER_WIDTH_HEURISTIC_FMT1_FS_MULT = 0.98
local TIMER_WIDTH_HEURISTIC_FMT1_PAD = 6
local TIMER_WIDTH_HEURISTIC_FMT2_MIN = 34
local TIMER_WIDTH_HEURISTIC_FMT2_FS_MULT = 2.55
local TIMER_WIDTH_HEURISTIC_FMT2_PAD = 10
local TIMER_WIDTH_HEURISTIC_FMT3_MIN = 52
local TIMER_WIDTH_HEURISTIC_FMT3_FS_MULT = 4.35
local TIMER_WIDTH_HEURISTIC_FMT3_PAD = 14
-- Запас к измеренной ширине (тень/сглаживание), см. UIRenderer.styled_text_size в ui_renderer.lua.
local TIMER_WIDTH_MEASURE_PAD = 4
-- При HUD справа и пропорциональных шрифтах только для эвристики (измеренная ширина не сжимается).
local TIMER_RIGHT_NON_DIGITAL_WIDTH_FACTOR = 0.92
local SPEEDOMETER_COLUMN_WIDTH_MIN = 72
local SPEEDOMETER_WIDTH_PER_PX = 3.15
local SPEEDOMETER_WIDTH_EXTRA = 16

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

local VERTICAL_LAYOUT_PRESETS = {
	top = {
		vertical_alignment = "top",
		position_y = 10,
	},
	center = {
		vertical_alignment = "center",
		position_y = 0,
	},
	bottom = {
		vertical_alignment = "bottom",
		position_y = -10,
	},
}

local POSITION_PRESETS = {
	left = {
		background = {
			horizontal_alignment = "left",
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
			-- Левый край внутри колонок: при center по экрану центрирование строки давало дёрганье от ширины цифр.
			text_alignment = "left",
			offset = {10, 0, 0},
		},
	},
	right = {
		background = {
			horizontal_alignment = "right",
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

local TIMER_BACKGROUND_HIDE = "hide"
local TIMER_BACKGROUND_TERMINAL = "terminal"
local TIMER_BACKGROUND_WEAPON_FRAME = "weapon_frame"

-- Материал weapon_frame: hud_element_mission_speaker_popup_definitions.lua (style.color = UIHudSettings.color_tint_main_3, size_addition).
local WEAPON_FRAME_BACKGROUND_MATERIAL = "content/ui/materials/hud/backgrounds/weapon_frame"
local WEAPON_FRAME_TEXTURE_SIZE_ADDITION = {
	8,
	5,
}

local function timer_background_mode()
	local v = mod:get("timer_background")

	if v == TIMER_BACKGROUND_HIDE or v == TIMER_BACKGROUND_TERMINAL or v == TIMER_BACKGROUND_WEAPON_FRAME then
		return v
	end

	local legacy_show = mod:get("show_background")

	if legacy_show == 2 then
		return TIMER_BACKGROUND_HIDE
	end

	return TIMER_BACKGROUND_TERMINAL
end

local function timer_background_shows_texture()
	return timer_background_mode() ~= TIMER_BACKGROUND_HIDE
end

local function timer_background_shows_edge_line()
	return timer_background_mode() == TIMER_BACKGROUND_TERMINAL
end

local function current_font_size()
	local value = mod:get("font_size") or DEFAULT_FONT_SIZE

	return math.clamp(value, FONT_SIZE_MIN, FONT_SIZE_MAX)
end

local function effective_timer_format_for_column_width()
	local el = mod._run_timer_hud_element

	if el then
		return el._cached_timer_format or 2
	end

	return mod:get("timer_format") or 2
end

local function current_font_type()
	local font_type = mod:get("font_type")

	if font_type == "proxima_nova_bold"
		or font_type == "proxima_nova_medium"
		or font_type == "itc_novarese_medium"
		or font_type == "itc_novarese_bold"
	then
		return font_type
	end

	return DEFAULT_FONT_TYPE
end

local function current_font_color()
	local color_name = mod:get("font_color") or DEFAULT_COLOR_NAME

	return COLOR_PRESETS[color_name] or COLOR_PRESETS[DEFAULT_COLOR_NAME]
end

local function current_position()
	return mod:get("timer_position") or DEFAULT_POSITION
end

local function current_vertical_position()
	local v = mod:get("timer_vertical_position")

	if v == "center" or v == "bottom" then
		return v
	end

	return DEFAULT_VERTICAL_POSITION
end

local function timer_text_column_width_heuristic()
	local fs = current_font_size()
	local fmt = effective_timer_format_for_column_width()
	local w

	if fmt == 1 then
		w = math.max(
			TIMER_WIDTH_HEURISTIC_FMT1_MIN,
			math.ceil(fs * TIMER_WIDTH_HEURISTIC_FMT1_FS_MULT + TIMER_WIDTH_HEURISTIC_FMT1_PAD)
		)
	elseif fmt == 3 then
		w = math.max(
			TIMER_WIDTH_HEURISTIC_FMT3_MIN,
			math.ceil(fs * TIMER_WIDTH_HEURISTIC_FMT3_FS_MULT + TIMER_WIDTH_HEURISTIC_FMT3_PAD)
		)
	else
		w = math.max(
			TIMER_WIDTH_HEURISTIC_FMT2_MIN,
			math.ceil(fs * TIMER_WIDTH_HEURISTIC_FMT2_FS_MULT + TIMER_WIDTH_HEURISTIC_FMT2_PAD)
		)
	end

	if current_position() == "right" and current_font_type() ~= "machine_medium" then
		local min_for_fmt = (fmt == 1) and TIMER_WIDTH_HEURISTIC_FMT1_MIN
			or (fmt == 3) and TIMER_WIDTH_HEURISTIC_FMT3_MIN
			or TIMER_WIDTH_HEURISTIC_FMT2_MIN
		w = math.max(min_for_fmt, math.floor(w * TIMER_RIGHT_NON_DIGITAL_WIDTH_FACTOR + 0.5))
	end

	return w
end

local function timer_text_column_width()
	local el = mod._run_timer_hud_element

	if el and el._cached_timer_text_column_width then
		return el._cached_timer_text_column_width
	end

	return timer_text_column_width_heuristic()
end

local function speedometer_column_width()
	local fs = current_font_size()

	return math.max(SPEEDOMETER_COLUMN_WIDTH_MIN, math.ceil(fs * SPEEDOMETER_WIDTH_PER_PX + SPEEDOMETER_WIDTH_EXTRA))
end

local function timer_background_container_width()
	return timer_text_column_width() + TIMER_COLUMN_GAP + speedometer_column_width()
end

-- Локальные X колонок внутри run_timer_background: слева/центр — таймер, затем спидометр; справа — спидометр, затем таймер.
local function timer_speed_column_local_x(timer_horizontal_position)
	local text_w = timer_text_column_width()
	local speed_w = speedometer_column_width()
	local gap = TIMER_COLUMN_GAP

	if timer_horizontal_position == "right" then
		return speed_w + gap, 0
	end

	return 0, text_w + gap
end

local function get_opacity_alpha()
	local opacity = mod:get("opacity") or 100
	return math.floor((opacity / 100) * 255)
end

local function hud_line_spacing()
	return hud_body_font_settings.line_spacing or 1.2
end

local function calculate_timer_height()
	local font_size = current_font_size()

	return math.floor(font_size * hud_line_spacing()) + BORDER_PADDING * 2
end

local function clone_style(base_style, color)
	local style = table.clone(base_style)

	local color_override = color or current_font_color()

	style.text_color = color_override and table.clone(color_override) or style.text_color
	style.color = color and table.clone(color) or style.color
	style.font_size = current_font_size()
	style.font_type = current_font_type()
	style.text_vertical_alignment = "center"
	style.text_horizontal_alignment = "center"
	style.offset = {
		0,
		0,
		0,
	}

	return style
end

local function apply_mod_settings_to_text_pass(text_style)
	if not text_style then
		return
	end

	local alpha = get_opacity_alpha()

	text_style.font_size = current_font_size()
	text_style.font_type = current_font_type()
	local color = table.clone(current_font_color())
	color[1] = alpha
	text_style.text_color = color
	text_style.line_spacing = hud_line_spacing()

	if hud_body_font_settings.character_spacing ~= nil then
		text_style.character_spacing = hud_body_font_settings.character_spacing
	end

	if hud_body_font_settings.drop_shadow ~= nil then
		text_style.drop_shadow = hud_body_font_settings.drop_shadow
	end
end

local function create_scenegraph_definition()
	local timer_height = calculate_timer_height()
	local text_w = timer_text_column_width()
	local speed_w = speedometer_column_width()
	local container_width = text_w + TIMER_COLUMN_GAP + speed_w
	local timer_sg_x, speed_sg_x = timer_speed_column_local_x(current_position())

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
				text_w,
				timer_height,
			},
			position = {
				timer_sg_x,
				0,
				2,
			},
		},
		speedometer_text = {
			horizontal_alignment = "left",
			parent = "run_timer_background",
			vertical_alignment = "center",
			size = {
				speed_w,
				timer_height,
			},
			position = {
				speed_sg_x,
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
	255,
	255,
	255,
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
				return content.visible and timer_background_shows_texture()
			end,
		},
		{
			pass_type = "texture",
			style_id = "edge_line",
			value_id = "edge_line_texture",
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
				return content.visible and content.edge_line_visible and timer_background_shows_edge_line()
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
			style = table.clone(timer_active_text_style),
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
	local use_digital_glyphs = current_font_type() == "machine_medium"
	local plain_text

	if mode == 1 then
		plain_text = format_double_digit(minutes)
	elseif mode == 3 then
		plain_text = format_double_digit(minutes) .. ":" .. format_double_digit(seconds) .. ":" .. format_triple_digit(milliseconds)
	else
		plain_text = format_double_digit(minutes) .. ":" .. format_double_digit(seconds)
	end

	if use_digital_glyphs then
		return digits_to_symbols(plain_text)
	end

	return plain_text
end

-- Образцы строк по режиму timer_format (1 / 2 / 3): максимальная типичная длина + «широкие» цифры для пропорциональных шрифтов.
local function build_timer_width_sample_plain_strings(fmt)
	if fmt == 1 then
		return {
			"09",
			"99",
			"88",
			"999",
		}
	elseif fmt == 3 then
		return {
			"00:00:000",
			"09:09:009",
			"99:59:999",
			"999:59:999",
			"88:88:888",
		}
	end

	return {
		"00:00",
		"09:09",
		"99:59",
		"999:59",
		"88:88",
	}
end

local function build_timer_width_sample_strings(fmt)
	local use_digital = current_font_type() == "machine_medium"
	local plain_list = build_timer_width_sample_plain_strings(fmt)
	local out = {}

	for i = 1, #plain_list do
		local plain = plain_list[i]

		if use_digital then
			out[#out + 1] = digits_to_symbols(plain)
		else
			out[#out + 1] = plain
		end
	end

	return out
end

-- Реальная ширина по движку (Gui2_slug_text_extents), см. UIRenderer.styled_text_size в scripts/managers/ui/ui_renderer.lua.
local function measure_timer_text_column_width(ui_renderer, text_style, fmt)
	if not ui_renderer or not text_style then
		return nil
	end

	local samples = build_timer_width_sample_strings(fmt)
	local max_w = 0

	for i = 1, #samples do
		local w = UIRenderer.styled_text_size(ui_renderer, samples[i], text_style, nil, false)

		if w > max_w then
			max_w = w
		end
	end

	local pad = (fmt == 1) and 2 or TIMER_WIDTH_MEASURE_PAD

	return math.ceil(max_w + pad)
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

	local fmt = self._cached_timer_format or 2
	local width_cache_key = string.format("%s|%d|%d", current_font_type(), current_font_size(), fmt)

	if self._timer_width_style_key ~= width_cache_key then
		self._cached_timer_text_column_width = nil
		self._timer_width_style_key = width_cache_key
	end

	if ui_renderer and text_widget.style and text_widget.style.text then
		apply_mod_settings_to_text_pass(text_widget.style.text)
		local measured_w = measure_timer_text_column_width(ui_renderer, text_widget.style.text, fmt)

		if measured_w then
			self._cached_timer_text_column_width = measured_w
		end
	end

	local tw = timer_text_column_width()
	local sw = speedometer_column_width()
	local th = calculate_timer_height()

	if self._last_timer_layout_text_w ~= tw or self._last_timer_layout_speed_w ~= sw or self._last_timer_layout_h ~= th then
		self._last_timer_layout_text_w = tw
		self._last_timer_layout_speed_w = sw
		self._last_timer_layout_h = th
		self:_apply_style()
		self:_apply_layout()
	end

	local time_manager = Managers.time
	local gameplay_time = 0

	if time_manager and time_manager:has_timer("gameplay") then
		gameplay_time = time_manager:time("gameplay")
		local should_exclude_intro = self._cached_exclude_intro == 2
		if should_exclude_intro and mod._intro_end_time and mod._intro_end_time > 0 then
			gameplay_time = gameplay_time - mod._intro_end_time
		end
	end

	local digital_text = format_time_by_mode(gameplay_time, self._cached_timer_format)

	text_widget.content.text = digital_text
end

HudElementRunTimer._apply_style = function(self)
	-- Обновляем высоту на основе размера шрифта
	local timer_height = calculate_timer_height()
	local text_w = timer_text_column_width()
	local speed_w = speedometer_column_width()
	local container_width = timer_background_container_width()

	self:_set_scenegraph_size("run_timer_background", container_width, timer_height)
	self:_set_scenegraph_size("run_timer_text", text_w, timer_height)
	self:_set_scenegraph_size("speedometer_text", speed_w, timer_height)
	
	local text_widget = self._widgets_by_name and self._widgets_by_name.run_timer_text

	if text_widget and text_widget.style and text_widget.style.text then
		apply_mod_settings_to_text_pass(text_widget.style.text)
		text_widget.dirty = true
	end

	local speedometer_widget = self._widgets_by_name and self._widgets_by_name.speedometer_text
	if speedometer_widget and speedometer_widget.style and speedometer_widget.style.speed then
		apply_mod_settings_to_text_pass(speedometer_widget.style.speed)
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
	local vertical_key = current_vertical_position()
	local v_layout = VERTICAL_LAYOUT_PRESETS[vertical_key] or VERTICAL_LAYOUT_PRESETS[DEFAULT_VERTICAL_POSITION]
	local preset = POSITION_PRESETS[position] or POSITION_PRESETS[DEFAULT_POSITION]
	local style_preset = BACKGROUND_STYLE_PRESETS[position] or BACKGROUND_STYLE_PRESETS[DEFAULT_POSITION]
	local background_settings = preset.background
	local text_settings = preset.text

	if background_settings and background_settings.position then
		self:set_scenegraph_position(
			"run_timer_background",
			background_settings.position[1],
			v_layout.position_y,
			background_settings.position[3],
			background_settings.horizontal_alignment,
			v_layout.vertical_alignment
		)
	end

	if text_settings and text_settings.position then
		-- Колонки таймера и спидометра всегда считаются от левого края контейнера (position по X).
		-- preset.text.horizontal_alignment относится к выравниванию строки внутри виджета, не к scenegraph:
		-- при "center"/"right" на узле scenegraph второй колонки уезжала за пределы фона.
		local inner_h_align = "left"
		local timer_sg_x, speed_sg_x = timer_speed_column_local_x(position)

		self:set_scenegraph_position(
			"run_timer_text",
			text_settings.position[1] + timer_sg_x,
			text_settings.position[2],
			text_settings.position[3],
			inner_h_align,
			text_settings.vertical_alignment
		)

		self:set_scenegraph_position(
			"speedometer_text",
			text_settings.position[1] + speed_sg_x,
			text_settings.position[2],
			text_settings.position[3],
			inner_h_align,
			text_settings.vertical_alignment
		)

		local text_widget = self._widgets_by_name and self._widgets_by_name.run_timer_text

		local preset_h_align = text_settings.text_alignment or text_settings.horizontal_alignment or "left"
		local text_v_align = text_settings.vertical_alignment or "center"
		-- HUD справа: спидометр слева от колонки таймера — его текст к правому краю колонки (к таймеру).
		-- Таймер: при machine_medium глифы циферблата одной ширины — можно выровнять вправо к краю экрана без дёрганья;
		-- иначе текст слева в колонке + уже ширина колонки (timer_text_column_width).
		local timer_h_align = preset_h_align
		local speed_h_align = preset_h_align

		if position == "right" then
			speed_h_align = "right"
			-- Формат «только минуты»: 2–3 символа, дёрганье мало — прижимаем к правому краю колонки, без пустоты справа.
			if current_font_type() == "machine_medium" or self._cached_timer_format == 1 then
				timer_h_align = "right"
			else
				timer_h_align = "left"
			end
		end

		if text_widget and text_widget.style and text_widget.style.text then
			text_widget.style.text.text_horizontal_alignment = timer_h_align
			text_widget.style.text.text_vertical_alignment = text_v_align
			if text_settings.offset then
				text_widget.style.text.offset = table.clone(text_settings.offset)
			end
			text_widget.dirty = true
		end

		local speedometer_widget = self._widgets_by_name and self._widgets_by_name.speedometer_text
		if speedometer_widget and speedometer_widget.style and speedometer_widget.style.speed then
			speedometer_widget.style.speed.text_horizontal_alignment = speed_h_align
			speedometer_widget.style.speed.text_vertical_alignment = text_v_align
			if text_settings.offset then
				speedometer_widget.style.speed.offset = table.clone(text_settings.offset)
			end
			speedometer_widget.dirty = true
		end
	end

	local background_widget = self._widgets_by_name and self._widgets_by_name.run_timer_background

	if background_widget and background_widget.style and background_widget.style.texture then
		local texture_style = background_widget.style.texture
		local bg_mode = timer_background_mode()

		texture_style.horizontal_alignment = background_settings.horizontal_alignment or texture_style.horizontal_alignment
		texture_style.vertical_alignment = v_layout.vertical_alignment or texture_style.vertical_alignment

		if background_settings.offset then
			texture_style.offset = table.clone(background_settings.offset)
		end

		if bg_mode == TIMER_BACKGROUND_WEAPON_FRAME then
			background_widget.content.texture = WEAPON_FRAME_BACKGROUND_MATERIAL
			texture_style.color = table.clone(UIHudSettings.color_tint_main_3)
			texture_style.size_addition = {
				WEAPON_FRAME_TEXTURE_SIZE_ADDITION[1],
				WEAPON_FRAME_TEXTURE_SIZE_ADDITION[2],
			}
		else
			background_widget.content.texture = style_preset.material
			texture_style.color = table.clone(style_preset.color)
			texture_style.size_addition = nil
		end

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
			if bg_mode == TIMER_BACKGROUND_TERMINAL then
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
			else
				background_widget.content.edge_line_visible = false
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

