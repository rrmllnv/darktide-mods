local mod = get_mod("CompassBar")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local Definitions = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_definitions")
local CompassBarSettings = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_settings")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIScenegraph = require("scripts/managers/ui/ui_scenegraph")

local HudElementCompassBar = class("HudElementCompassBar", "HudElementBase")

HudElementCompassBar.init = function(self, parent, draw_layer, start_scale)
	HudElementCompassBar.super.init(self, parent, draw_layer, start_scale, Definitions)
	
	-- Инициализируем кэш для отслеживания изменений настроек
	self._cached_width = nil
end

-- Получаем угол направления камеры
HudElementCompassBar._get_camera_direction_angle = function(self)
	local camera = self._parent:player_camera()
	
	if not camera then
		return 0
	end
	
	local camera_rotation = Camera.local_rotation(camera)
	local camera_forward = Quaternion.forward(camera_rotation)
	
	-- Игнорируем вертикальную составляющую
	camera_forward.z = 0
	camera_forward = Vector3.normalize(camera_forward)
	
	local camera_right = Vector3.cross(camera_forward, Vector3.up())
	local direction = Vector3.forward()
	local forward_dot_dir = Vector3.dot(camera_forward, direction)
	local right_dot_dir = Vector3.dot(camera_right, direction)
	local angle = math.atan2(right_dot_dir, forward_dot_dir)
	
	return angle
end


HudElementCompassBar.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementCompassBar.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	-- Обновляем размер контейнера, позиция НЕ изменяется в runtime, чтобы не конфликтовать с HUD offset
	local width = mod:get("width") or CompassBarSettings.width
	
	local ui_scenegraph = self._ui_scenegraph
	if ui_scenegraph and ui_scenegraph.CompassBarContainer then
		-- Обновляем размер контейнера только если изменился
		if self._cached_width ~= width then
			self:_set_scenegraph_size("CompassBarContainer", width, CompassBarSettings.height)
			self._cached_width = width
		end
	end
end

-- Получаем текущий game_mode_name (кэшируем для оптимизации)
HudElementCompassBar._get_game_mode_name = function(self)
	if not Managers.state or not Managers.state.game_mode then
		return nil
	end
	return Managers.state.game_mode:game_mode_name()
end

-- Проверяем, находимся ли мы в хабе
HudElementCompassBar._is_in_hub = function(self)
	local game_mode_name = self:_get_game_mode_name()
	return game_mode_name == "hub" or game_mode_name == "prologue_hub"
end

-- Проверяем, находимся ли мы в Псайканиуме
HudElementCompassBar._is_in_psykhanium = function(self)
	return self:_get_game_mode_name() == "shooting_range"
end

-- Проверяем, находимся ли мы на миссии
HudElementCompassBar._is_in_mission = function(self)
	local game_mode_name = self:_get_game_mode_name()
	return game_mode_name and game_mode_name ~= "hub" and game_mode_name ~= "prologue_hub" and game_mode_name ~= "shooting_range"
end

local DEGREES = 360

local step_color_table = {}
local text_color_table = {}
local cardinal_color_table = {}
local _compass_text_options = {}

HudElementCompassBar._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	HudElementCompassBar.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
	
	-- Проверяем условия отображения в зависимости от места игры
	local is_in_hub = self:_is_in_hub()
	local is_in_psykhanium = self:_is_in_psykhanium()
	local is_in_mission = self:_is_in_mission()
	
	local show_in_hub = mod:get("show_in_hub") or false
	local show_in_psykhanium = mod:get("show_in_psykhanium") or false
	local show_in_mission = mod:get("show_in_mission")
	if show_in_mission == nil then
		show_in_mission = true
	end
	
	-- Проверяем, нужно ли отображать компас в текущем месте
	if not ((is_in_hub and show_in_hub) or (is_in_psykhanium and show_in_psykhanium) or (is_in_mission and show_in_mission)) then
		return
	end
	
	-- Получаем настройки из mod:get()
	local width = mod:get("width") or CompassBarSettings.width
	local opacity = mod:get("opacity")
	if opacity == nil then
		opacity = 100
	end
	-- Преобразуем opacity (0-100) в alpha (0-255)
	local base_alpha = math.floor((opacity / 100) * 255)
	
	local scale = ui_renderer.scale
	local inverse_scale = ui_renderer.inverse_scale
	
	-- Получаем позицию контейнера с учетом HUD offset через UIScenegraph.world_position
	-- Контейнер двигается вместе с HUD, и все что внутри него (деления) тоже двигаются
	-- Используем ui_renderer.ui_scenegraph как виджеты, чтобы автоматически учитывался HUD offset
	local ui_scenegraph = ui_renderer.ui_scenegraph
	local area_position = UIScenegraph.world_position(ui_scenegraph, "CompassBarContainer")
	local area_size = ui_scenegraph.CompassBarContainer.size
	
	-- Получаем настройки цветов с учетом прозрачности
	local step_color = CompassBarSettings.step_color
	local text_color = CompassBarSettings.text_color
	local cardinal_color = CompassBarSettings.cardinal_color
	
	-- Базовые цвета (без прозрачности, она будет применяться динамически)
	step_color_table[2] = step_color[2] or 255
	step_color_table[3] = step_color[3] or 255
	step_color_table[4] = step_color[4] or 255
	
	text_color_table[2] = text_color[2] or 255
	text_color_table[3] = text_color[3] or 255
	text_color_table[4] = text_color[4] or 255
	
	cardinal_color_table[2] = cardinal_color[2] or 255
	cardinal_color_table[3] = cardinal_color[3] or 255
	cardinal_color_table[4] = cardinal_color[4] or 255
	local draw_layer = area_position[3] + 1
	
	-- Настройки делений
	local num_steps = CompassBarSettings.steps
	local degrees_per_step = DEGREES / num_steps
	local step_width = CompassBarSettings.step_width
	local step_height_small = CompassBarSettings.step_height_small
	local step_height_large = CompassBarSettings.step_height_large
	local visible_steps = CompassBarSettings.visible_steps
	-- Пересчитываем расстояние между делениями на основе актуальной ширины
	local marker_spacing = width / (visible_steps - 1)
	local step_fade_start = CompassBarSettings.step_fade_start
	local font_size_small = math.ceil(CompassBarSettings.font_size_small * scale)
	local font_size_big = math.ceil(CompassBarSettings.font_size_big * scale)
	local font_type = CompassBarSettings.font_type
	local degree_direction_abbreviations = CompassBarSettings.degree_direction_abbreviations
	
	-- Получаем угол направления камеры
	local player_direction_angle = self:_get_camera_direction_angle()
	local player_direction_degree = DEGREES - math.radians_to_degrees(player_direction_angle)
	local rotation_progress = player_direction_degree / DEGREES
	
	-- Вычисляем общую длину и начальное смещение
	local total_length = marker_spacing * num_steps
	local start_offset = -total_length * rotation_progress
	local start_index = math.floor(math.abs(start_offset) / marker_spacing)
	local half_width = area_size[1] * 0.5
	start_offset = start_offset + half_width + marker_spacing
	
	local area_middle_x = area_position[1] + half_width
	local half_height = area_size[2] * 0.5
	local position = Vector3(0, area_position[2], draw_layer)
	local size = Vector2(step_width, step_height_small)
	local step_width_offset = -step_width * 0.5
	
	-- Получаем опции шрифта
	local header_font_settings = UIFontSettings[font_type] or UIFontSettings.hud_body
	UIFonts.get_font_options_by_style(header_font_settings, _compass_text_options)
	
	-- Рисуем деления
	for i = -visible_steps, visible_steps do
		local draw_index = start_index + i
		local read_index = (draw_index - 1) % num_steps + 1
		local local_x = start_offset + (draw_index - 1) * marker_spacing + area_position[1]
		
		-- Проверяем, находится ли деление в видимой области
		if local_x + size[1] >= area_position[1] and local_x <= area_position[1] + area_size[1] then
			-- Вычисляем расстояние от центра и альфа-канал для затухания
			local distance_from_center_norm = math.abs(local_x - area_middle_x) / half_width
			local fade_alpha_fraction = 1
			if distance_from_center_norm > step_fade_start then
				fade_alpha_fraction = 1 - math.min((distance_from_center_norm - step_fade_start) / (1 - step_fade_start), 1)
			end
			local final_alpha = math.floor(base_alpha * fade_alpha_fraction)
			
			-- Текущий градус
			local current_degree = (read_index * degrees_per_step) % DEGREES
			
			-- Проверяем, является ли это направлением (N, S, E, W)
			local degree_abbreviation = degree_direction_abbreviations[current_degree]
			local is_cardinal = degree_abbreviation ~= nil
			
			-- Устанавливаем размер и цвет деления
			if is_cardinal then
				size[2] = step_height_large
				step_color_table[1] = final_alpha
				step_color_table[2] = cardinal_color[2]
				step_color_table[3] = cardinal_color[3]
				step_color_table[4] = cardinal_color[4]
			else
				size[2] = step_height_small
				step_color_table[1] = final_alpha
				step_color_table[2] = step_color[2]
				step_color_table[3] = step_color[3]
				step_color_table[4] = step_color[4]
			end
			
			-- Позиция деления
			position[1] = local_x + step_width_offset
			position[2] = area_position[2] + half_height - size[2] * 0.5
			
			-- Рисуем деление
			UIRenderer.draw_rect(ui_renderer, position, size, step_color_table)
			
			-- Рисуем текст (цифры или буквы направлений)
			if read_index % 2 == 0 or is_cardinal then
				local text = degree_abbreviation or tostring(math.floor(current_degree))
				local text_width = UIRenderer.text_size(ui_renderer, text, font_type, is_cardinal and font_size_big or font_size_small)
				
				-- Устанавливаем цвет текста с учетом прозрачности
				if is_cardinal then
					cardinal_color_table[1] = final_alpha
					text_color_table[1] = final_alpha
					text_color_table[2] = cardinal_color[2]
					text_color_table[3] = cardinal_color[3]
					text_color_table[4] = cardinal_color[4]
				else
					text_color_table[1] = final_alpha
				end
				
				-- Позиция текста
				position[2] = position[2] + size[2] + 5
				position[1] = local_x - text_width * inverse_scale * 0.5
				size[1] = text_width + 20
				size[2] = font_size_big + 10
				
				-- Рисуем текст
				UIRenderer.draw_text(ui_renderer, text, is_cardinal and font_size_big or font_size_small, font_type, position, size, text_color_table, _compass_text_options)
				
				-- Возвращаем размер обратно
				size[1] = step_width
			end
		end
	end
end

return HudElementCompassBar
