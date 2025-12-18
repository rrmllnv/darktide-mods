local mod = get_mod("CompassBar")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local Definitions = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_definitions")
local CompassBarSettings = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_settings")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local ScriptCamera = require("scripts/foundation/utilities/script_camera")
local Vector3 = Vector3
local Vector2 = Vector2
local Quaternion = Quaternion
local Color = Color
local POSITION_LOOKUP = POSITION_LOOKUP

local HudElementCompassBar = class("HudElementCompassBar", "HudElementBase")

HudElementCompassBar.init = function(self, parent, draw_layer, start_scale)
	HudElementCompassBar.super.init(self, parent, draw_layer, start_scale, Definitions)
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

-- Получаем список тимейтов (исключая локального игрока)
HudElementCompassBar._get_teammates = function(self)
	local teammates = {}
	
	if not Managers or not Managers.player then
		return teammates
	end
	
	local local_player = Managers.player:local_player(1)
	if not local_player then
		return teammates
	end
	
	local local_player_unit = local_player.player_unit
	if not local_player_unit then
		return teammates
	end
	
	-- Проверяем, что юнит жив
	if not Unit.alive(local_player_unit) then
		return teammates
	end
	
	local all_players = Managers.player:players()
	if not all_players then
		return teammates
	end
	
	-- Получаем всех игроков (и людей, и ботов)
	for unique_id, player in pairs(all_players) do
		if player and player ~= local_player and type(player) == "table" then
			local player_unit = player.player_unit
			if player_unit and player_unit ~= local_player_unit and Unit.alive(player_unit) then
				local player_position = POSITION_LOOKUP[player_unit]
				if player_position then
					-- Пробуем получить профиль
					local success, profile = pcall(function() return player:profile() end)
					if success and profile then
						local archetype = profile.archetype
						if archetype then
							local archetype_name = archetype.name or "veteran"
							local icon_path = archetype.archetype_icon_large or ("content/ui/materials/icons/classes/" .. archetype_name)
							
							table.insert(teammates, {
								player = player,
								unit = player_unit,
								position = player_position,
								archetype_name = archetype_name,
								icon_path = icon_path,
							})
						end
					else
						-- Если профиль недоступен, используем дефолтную иконку
						table.insert(teammates, {
							player = player,
							unit = player_unit,
							position = player_position,
							archetype_name = "veteran",
							icon_path = "content/ui/materials/icons/classes/veteran",
						})
					end
				end
			end
		end
	end
	
	return teammates
end

-- Вычисляем направление тимейта относительно игрока (в радианах, точно как в оригинальном коде)
HudElementCompassBar._get_teammate_direction_angle = function(self, teammate_position, player_position)
	local camera = self._parent:player_camera()
	if not camera then
		return 0
	end
	
	-- Используем позицию камеры (как в оригинальном коде _get_position_direction_angle)
	local camera_position = ScriptCamera.position(camera)
	local diff_vector = teammate_position - camera_position
	
	diff_vector.z = 0
	diff_vector = Vector3.normalize(diff_vector)
	
	local diff_right = Vector3.cross(diff_vector, Vector3.up())
	local direction = Vector3.forward()
	local forward_dot_dir = Vector3.dot(diff_vector, direction)
	local right_dot_dir = Vector3.dot(diff_right, direction)
	local angle = -math.atan2(right_dot_dir, forward_dot_dir) % (math.pi * 2)
	
	return angle
end

HudElementCompassBar.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementCompassBar.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

local step_color_table = {}
local text_color_table = {}
local cardinal_color_table = {}
local _compass_text_options = {}

HudElementCompassBar._draw_widgets = function(self, dt, t, input_service, ui_renderer)
	HudElementCompassBar.super._draw_widgets(self, dt, t, input_service, ui_renderer)
	
	-- Проверяем, включен ли компас
	local enabled = mod:get("enabled")
	if enabled == false then
		return
	end
	
	-- Получаем настройки из mod:get()
	local position_y = mod:get("position_y") or CompassBarSettings.position_y
	local width = mod:get("width") or CompassBarSettings.width
	local opacity = mod:get("opacity")
	if opacity == nil then
		opacity = 100
	end
	-- Преобразуем opacity (0-100) в alpha (0-255)
	local base_alpha = math.floor((opacity / 100) * 255)
	
	local scale = ui_renderer.scale
	local inverse_scale = ui_renderer.inverse_scale
	
	-- Обновляем scenegraph с актуальными значениями
	local ui_scenegraph = self._ui_scenegraph
	if ui_scenegraph and ui_scenegraph.compass_area then
		-- Сохраняем текущую позицию Z
		local current_z = ui_scenegraph.compass_area.position[3] or 100
		self:_set_scenegraph_size("compass_area", width, CompassBarSettings.height)
		-- Используем set_scenegraph_position с X=0 для центрирования (horizontal_alignment = "center" пересчитает позицию)
		self:set_scenegraph_position("compass_area", 0, position_y, current_z, "center", "top")
	end
	
	-- Получаем область компаса (после обновления scenegraph)
	local area_scenegraph = ui_scenegraph.compass_area
	local area_size = area_scenegraph.size
	local area_position = area_scenegraph.world_position
	
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
	local degrees = 360
	local degrees_per_step = degrees / num_steps
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
	local player_direction_degree = degrees - (0 + math.radians_to_degrees(player_direction_angle))
	local rotation_progress = player_direction_degree / degrees
	
	-- Вычисляем общую длину и начальное смещение
	local total_length = marker_spacing * num_steps
	local start_offset = -total_length * rotation_progress
	local start_index = math.floor(math.abs(start_offset) / marker_spacing)
	start_offset = start_offset + area_size[1] * 0.5 + marker_spacing
	
	local area_middle_x = area_position[1] + area_size[1] * 0.5
	local position = Vector3(0, area_position[2], draw_layer)
	local size = Vector2(step_width, step_height_small)
	local step_width_offset = -step_width * 0.5
	
	-- Получаем опции шрифта
	local header_font_settings = UIFontSettings[font_type] or UIFontSettings.hud_body
	UIFonts.get_font_options_by_style(header_font_settings, _compass_text_options)
	
	-- Получаем иконки тимейтов перед циклом делений
	local teammate_icons = {}
	local local_player = Managers.player:local_player(1)
	if local_player then
		local local_player_unit = local_player.player_unit
		if local_player_unit and Unit.alive(local_player_unit) then
			local player_position = POSITION_LOOKUP[local_player_unit]
			if player_position then
				local teammates = self:_get_teammates()
				for idx, teammate in ipairs(teammates) do
					if teammate.unit and Unit.alive(teammate.unit) then
						teammate.position = POSITION_LOOKUP[teammate.unit]
					end
					if teammate.position then
						local teammate_angle = self:_get_teammate_direction_angle(teammate.position, player_position)
						table.insert(teammate_icons, {
							angle = teammate_angle,
							icon_path = teammate.icon_path or ("content/ui/materials/icons/classes/" .. (teammate.archetype_name or "veteran")),
							archetype_name = teammate.archetype_name or "veteran",
						})
					end
				end
			end
		end
	end
	
	-- Рисуем деления
	for i = -visible_steps, visible_steps do
		local draw_index = start_index + i
		local read_index = (draw_index - 1) % num_steps + 1
		local local_x = start_offset + (draw_index - 1) * marker_spacing + area_position[1]
		
		-- Проверяем, находится ли деление в видимой области
		if local_x + size[1] >= area_position[1] and local_x <= area_position[1] + area_size[1] then
			-- Вычисляем расстояние от центра и альфа-канал для затухания
			local distance_from_center = math.abs(local_x - area_middle_x)
			local distance_from_center_norm = distance_from_center / (area_size[1] * 0.5)
			local fade_alpha_fraction = step_fade_start <= distance_from_center_norm and 
				1 - math.min((distance_from_center_norm - step_fade_start) / (1 - step_fade_start), 1) or 1
			-- Учитываем и настройку opacity из мода, и затухание по краям
			local final_alpha = math.floor(base_alpha * fade_alpha_fraction)
			
			-- Текущий градус
			local current_degree = read_index * degrees_per_step
			current_degree = current_degree % degrees
			
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
			position[2] = area_position[2] + area_size[2] * 0.5 - size[2] * 0.5
			
			-- Рисуем деление
			UIRenderer.draw_rect(ui_renderer, position, size, step_color_table)
			
			-- Рисуем текст (цифры или буквы направлений)
			if read_index % 2 == 0 or is_cardinal then
				local text = degree_abbreviation or tostring(math.floor(current_degree))
				local text_width = UIRenderer.text_size(ui_renderer, text, font_type, is_cardinal and font_size_big or font_size_small)
				
				-- Устанавливаем цвет текста с учетом прозрачности
				if is_cardinal then
					cardinal_color_table[1] = final_alpha
					text_color_table = cardinal_color_table
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
			
			-- Рисуем иконки тимейтов для текущего деления (точно как в оригинальном коде)
			-- ВРЕМЕННО: Рисуем все иконки в центре для отладки
			if i == 0 and #teammate_icons > 0 then
				local icon_size = CompassBarSettings.teammate_icon_size or 20
				local icon_offset_y = CompassBarSettings.teammate_icon_offset_y or -30
				local icon_spacing = 25
				
				for idx, icon_data in ipairs(teammate_icons) do
					local icon_half_size = icon_size * 0.5
					local icon_x = area_middle_x + (idx - 1) * icon_spacing - (#teammate_icons * icon_spacing * 0.5)
					local icon_position = Vector3(
						icon_x - icon_half_size,
						area_position[2] + area_size[2] * 0.5 + icon_offset_y,
						draw_layer + 10
					)
					local icon_size_vec = Vector2(icon_size, icon_size)
					local icon_color = {255, 255, 255, 255}
					
					-- ВРЕМЕННО: Рисуем красный прямоугольник
					local debug_color = {255, 255, 0, 0}
					UIRenderer.draw_rect(ui_renderer, icon_position, icon_size_vec, debug_color)
					
					-- Рисуем иконку
					UIRenderer.draw_texture(ui_renderer, icon_data.icon_path, icon_position, icon_size_vec, icon_color)
				end
			end
			
			if #teammate_icons > 0 then
				local icon_size = CompassBarSettings.teammate_icon_size or 20
				local icon_offset_y = CompassBarSettings.teammate_icon_offset_y or -30
				
				for j = #teammate_icons, 1, -1 do
					local icon_data = teammate_icons[j]
					local marker_angle = icon_data.angle
					local marker_degrees = math.radians_to_degrees(marker_angle)
					
					-- Используем ту же логику, что и в оригинальном коде
					local current_degree_check = current_degree % degrees
					local degree_difference = marker_degrees - current_degree_check
					
					-- Нормализуем разницу для правильной проверки (учитываем переход через 0/360)
					if degree_difference > 180 then
						degree_difference = degree_difference - 360
					elseif degree_difference < -180 then
						degree_difference = degree_difference + 360
					end
					
					-- Проверяем, попадает ли маркер в текущее деление
					if degree_difference >= 0 and degree_difference <= degrees_per_step then
						local degree_difference_fraction = degree_difference / degrees_per_step
						local icon_x = local_x + marker_spacing * degree_difference_fraction
						local icon_distance_from_center = math.abs(icon_x - area_middle_x)
						local icon_distance_from_center_norm = icon_distance_from_center / (area_size[1] * 0.5)
						local icon_alpha_fraction = step_fade_start <= icon_distance_from_center_norm and 
							1 - math.min((icon_distance_from_center_norm - step_fade_start) / (1 - step_fade_start), 1) or 1
						local icon_alpha = math.floor(base_alpha * icon_alpha_fraction)
						
						-- Минимальная прозрачность
						if icon_alpha < 100 then
							icon_alpha = 100
						end
						
						-- Позиция иконки
						local icon_half_size = icon_size * 0.5
						local icon_position = Vector3(
							icon_x - icon_half_size,
							area_position[2] + area_size[2] * 0.5 + icon_offset_y,
							draw_layer + 10
						)
						local icon_size_vec = Vector2(icon_size, icon_size)
						
						-- Цвет иконки с прозрачностью (RGBA)
						local icon_color = {icon_alpha, 255, 255, 255}
						
						-- Рисуем иконку класса
						UIRenderer.draw_texture(ui_renderer, icon_data.icon_path, icon_position, icon_size_vec, icon_color)
					end
				end
			end
		end
	end
end

return HudElementCompassBar
