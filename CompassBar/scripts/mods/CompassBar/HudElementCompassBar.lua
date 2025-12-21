local mod = get_mod("CompassBar")

-- Константа PI для совместимости
local PI = 3.141592653589793

-- Список врагов для отслеживания на компасе (из TargetHunter)
local tracked_enemies = {
	-- Настоящие боссы
	["chaos_beast_of_nurgle"] = { enabled = true, is_boss = true },
	["chaos_spawn"] = { enabled = true, is_boss = true },
	["chaos_plague_ogryn"] = { enabled = true, is_boss = true },
	["chaos_daemonhost"] = { enabled = true, is_boss = true },
	["renegade_captain"] = { enabled = true, is_boss = true },
	["renegade_twin_captain"] = { enabled = true, is_boss = true },
	["renegade_twin_captain_two"] = { enabled = true, is_boss = true },
	["cultist_captain"] = { enabled = true, is_boss = true },
	-- Мощные элиты для отслеживания на компасе
	-- ["chaos_ogryn_gunner"] = { enabled = true, is_boss = false },
	-- ["chaos_ogryn_executor"] = { enabled = true, is_boss = false },
	-- ["chaos_ogryn_bulwark"] = { enabled = true, is_boss = false }
}

-- Хранилище отслеживаемых боссов
local tracked_bosses = {}

-- Функции для работы с боссами
local function fetch_breed(unit)
	local unit_data = ScriptUnit.has_extension and ScriptUnit.has_extension(unit, "unit_data_system")
	return unit_data and unit_data:breed()
end

local function is_unit_alive(unit)
	if not unit then
		return false
	end
	
	-- Проверяем через Unit.alive
	if not Unit.alive(unit) then
		return false
	end
	
	-- Дополнительная проверка через health_extension для более надежного определения смерти
	local health_ext = ScriptUnit.has_extension(unit, "health_system")
	if health_ext and type(health_ext.is_dead) == "function" and health_ext:is_dead() then
		return false
	end
	
	return true
end

local function should_track_enemy(breed)
	if not breed or not breed.name then
		return false
	end

	local config = tracked_enemies[breed.name]
	return config and config.enabled
end

-- Для обратной совместимости
local function should_track_boss(breed)
	local config = tracked_enemies[breed.name]
	return config and config.enabled and config.is_boss
end

local function add_enemy_marker(unit, breed)
	if tracked_bosses[unit] then
		return
	end

	local config = tracked_enemies[breed.name]
	local is_boss = config and config.is_boss or false

	tracked_bosses[unit] = {
		breed_name = breed.name,
		is_boss = is_boss
	}

	-- mod:echo("CompassBar: Обнаружен враг: " .. breed.name .. " (" .. (is_boss and "Босс" or "Элита") .. "), всего отслеживается: " .. table.size(tracked_bosses))
end

local function remove_boss_marker(unit)
	if tracked_bosses[unit] then
		tracked_bosses[unit] = nil
		-- mod:echo("Boss removed")
	end
end

local function cleanup_dead_bosses()
	for unit, data in pairs(tracked_bosses) do
		if not is_unit_alive(unit) then
			remove_boss_marker(unit)
		end
	end
end

-- Функция для поиска уже существующих боссов на карте
local function scan_existing_bosses()
	if not Managers.state then
		return
	end
	
	-- Пытаемся найти боссов через BossSystem
	local extension_manager = Managers.state.extension
	if extension_manager and extension_manager:has_system("boss_system") then
		local boss_system = extension_manager:system("boss_system")
		if boss_system and boss_system._unit_to_extension_map then
			for unit, extension in pairs(boss_system._unit_to_extension_map) do
				if is_unit_alive(unit) and not tracked_bosses[unit] then
					local breed = fetch_breed(unit)
					if breed and should_track_enemy(breed) then
						add_enemy_marker(unit, breed)
					end
				end
			end
		end
	end
	
	-- Альтернативный способ: ищем через extension напрямую
	if extension_manager then
		local boss_extensions = extension_manager:get_entities("boss_system")
		if boss_extensions then
			for unit, extension in pairs(boss_extensions) do
				if is_unit_alive(unit) and not tracked_bosses[unit] then
					local breed = fetch_breed(unit)
					if breed and should_track_enemy(breed) then
						add_enemy_marker(unit, breed)
					end
				end
			end
		end
	end
end

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Definitions = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_definitions")
local CompassBarSettings = mod:io_dofile("CompassBar/scripts/mods/CompassBar/compass_bar_settings")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIScenegraph = require("scripts/managers/ui/ui_scenegraph")
local UISettings = require("scripts/settings/ui/ui_settings")
local ScriptCamera = require("scripts/foundation/utilities/script_camera")

local HudElementCompassBar = class("HudElementCompassBar", "HudElementBase")

HudElementCompassBar.init = function(self, parent, draw_layer, start_scale)
	HudElementCompassBar.super.init(self, parent, draw_layer, start_scale, Definitions)

	-- Инициализируем кэш для отслеживания изменений настроек
	self._cached_width = nil
	
	-- Таймер для периодического сканирования существующих боссов
	self._boss_scan_timer = 0
	self._boss_scan_interval = 2.0  -- Сканируем каждые 2 секунды

	-- Настраиваем хуки для отслеживания боссов
	self:_setup_boss_tracking()
	
	-- Первое сканирование существующих боссов с небольшой задержкой
	self._initial_scan_done = false
end

-- Глобальный флаг для отслеживания, был ли хук уже создан
local boss_tracking_hook_setup = false

-- Настройка отслеживания боссов (вызывается только один раз глобально)
local function setup_boss_tracking_global()
	if boss_tracking_hook_setup then
		return
	end
	
	-- Хук на событие начала и окончания боя с боссом
	mod:hook_safe(Managers.event, "trigger", function(event_manager, event_name, ...)
		-- Проверяем, что это событие босса
		if event_name == "boss_encounter_start" or event_name == "boss_encounter_end" then
			-- Первый аргумент после event_name может быть unit
			local unit = select(1, ...)
			if unit then
				if event_name == "boss_encounter_start" then
					-- Отслеживаем боссов через событие начала боя с боссом
					local breed = fetch_breed(unit)
					if breed and should_track_enemy(breed) then
						add_enemy_marker(unit, breed)
					end
				elseif event_name == "boss_encounter_end" then
					-- Удаляем босса при завершении боя
					remove_boss_marker(unit)
				end
			end
		end
	end)
	
	boss_tracking_hook_setup = true
end

-- Настройка отслеживания боссов
HudElementCompassBar._setup_boss_tracking = function(self)
	-- Вызываем глобальную настройку хука (только один раз)
	setup_boss_tracking_global()
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

-- Получаем список тимейтов и их позиции относительно камеры
-- Используем ТОЧНО ТУ ЖЕ логику, что и в оригинальном коде Darktide
HudElementCompassBar._get_teammate_positions = function(self)
	local teammates = {}

	if not Managers.player then
		return teammates
	end

	local players = Managers.player:players()
	local local_player = Managers.player:local_player(1)

	if not local_player or not players then
		return teammates
	end

	-- Получаем позицию камеры, как в оригинальном коде Darktide
	local camera = self._parent:player_camera()
	if not camera then
		return teammates
	end

	local camera_position = ScriptCamera.position(camera)

	for _, player in pairs(players) do
		if player ~= local_player and player.player_unit then
			local unit = player.player_unit
			local position = Unit.world_position(unit, 1)

			-- Проверяем, что позиция валидна и не нулевая
			if position and camera_position then
				-- Вычисляем направление от камеры к тимейту, как в оригинальном коде
				local diff_vector = position - camera_position
				local distance = Vector3.length(diff_vector)

				-- Показываем метки только для тимейтов в радиусе 100 единиц
				if distance > 0.1 and distance < 100 then
					-- Используем ТОЧНО ТУ ЖЕ формулу вычисления угла, что и в оригинальном коде Darktide
					diff_vector.z = 0
					diff_vector = Vector3.normalize(diff_vector)

					local diff_right = Vector3.cross(diff_vector, Vector3.up())
					local direction = Vector3.forward()
					local forward_dot_dir = Vector3.dot(diff_vector, direction)
					local right_dot_dir = Vector3.dot(diff_right, direction)
					local angle = -math.atan2(right_dot_dir, forward_dot_dir) % (math.pi * 2)

					-- Получаем профиль игрока и иконку класса
					local profile = player:profile()
					local class_icon_text = nil

					-- Используем шрифтовые иконки классов как в оригинальном коде
					if profile and profile.archetype and profile.archetype.name then
						local archetype_font_icons = {
							veteran = "",
							psyker = "",
							ogryn = "",
							zealot = "",
							adamant = "",
							broker = ""
						}
						class_icon_text = archetype_font_icons[profile.archetype.name]
					end

					-- Получаем цвет игрока для окраски иконки
					local player_slot = player and player.slot and player:slot()
					local player_slot_colors = UISettings.player_slot_colors
					local player_color = player_slot and player_slot_colors and player_slot_colors[player_slot]

					table.insert(teammates, {
						angle = angle,
						position = position,
						player = player,
						distance = distance,
						class_icon_text = class_icon_text,
						player_color = player_color
					})
				end
			end
		end
	end

	return teammates
end

-- Получаем список боссов и их позиции
HudElementCompassBar._get_boss_positions = function(self)
	local bosses = {}

	-- mod:echo("CompassBar: _get_boss_positions called")

	if not Managers.player then
		-- mod:echo("CompassBar: Managers.player is nil")
		return bosses
	end

	local players = Managers.player:players()
	local local_player = Managers.player:local_player(1)

	if not local_player or not players then
		-- mod:echo("CompassBar: local_player or players is nil")
		return bosses
	end

	-- Получаем позицию камеры
	local camera = self._parent:player_camera()
	if not camera then
		-- mod:echo("CompassBar: camera is nil")
		return bosses
	end

	local camera_position = ScriptCamera.position(camera)
	if not camera_position then
		-- mod:echo("CompassBar: camera_position is nil")
		return bosses
	end

	-- mod:echo("CompassBar: camera_position = (" .. camera_position[1] .. ", " .. camera_position[2] .. ", " .. camera_position[3] .. ")")

	-- Очищаем мертвых боссов
	cleanup_dead_bosses()

	-- Отладка: показываем количество отслеживаемых боссов
	local boss_count = table.size(tracked_bosses)
	-- mod:echo("CompassBar: Tracking " .. boss_count .. " bosses after cleanup")

	if boss_count > 0 then
		for unit, data in pairs(tracked_bosses) do
			-- mod:echo("CompassBar: Boss in tracked_bosses: " .. data.breed_name .. ", unit alive: " .. tostring(is_unit_alive(unit)))
		end
	end

	-- Получаем позиции живых боссов
	for unit, data in pairs(tracked_bosses) do
		-- mod:echo("CompassBar: Processing boss: " .. data.breed_name)
		if is_unit_alive(unit) then
			-- mod:echo("CompassBar: Boss " .. data.breed_name .. " is alive")
			local position = Unit.world_position(unit, 1)

			if position and camera_position then
				local diff_vector = position - camera_position
				local distance = Vector3.length(diff_vector)

				-- Показываем метки боссов в радиусе 150 единиц
				if distance > 0.1 and distance < 500 then
					diff_vector.z = 0
					diff_vector = Vector3.normalize(diff_vector)

					local diff_right = Vector3.cross(diff_vector, Vector3.up())
					local direction = Vector3.forward()
					local forward_dot_dir = Vector3.dot(diff_vector, direction)
					local right_dot_dir = Vector3.dot(diff_right, direction)
					local angle = -math.atan2(right_dot_dir, forward_dot_dir) % (math.pi * 2)

					table.insert(bosses, {
						angle = angle,
						position = position,
						unit = unit,
						distance = distance,
						breed_name = data.breed_name
					})
				else
					-- Отладка: босс слишком далеко
					-- mod:echo("CompassBar: Boss " .. data.breed_name .. " too far: " .. string.format("%.1f", distance) .. " units")
				end
			else
				-- Отладка: нет позиции
				-- mod:echo("CompassBar: Boss " .. data.breed_name .. " has no position")
			end
		else
			-- Отладка: босс мертв
			-- mod:echo("CompassBar: Boss " .. data.breed_name .. " is dead")
		end
	end

	return bosses
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

	-- Очищаем боссов при входе в хаб (как в TargetHunter)
	local game_mode_name = self:_get_game_mode_name()
	if game_mode_name == "hub" or not game_mode_name then
		for unit, data in pairs(tracked_bosses) do
			remove_boss_marker(unit)
		end
		self._initial_scan_done = false
		return
	end
	
	-- Первое сканирование существующих боссов с задержкой после инициализации
	if not self._initial_scan_done then
		self._boss_scan_timer = self._boss_scan_timer + dt
		if self._boss_scan_timer >= 1.0 then  -- Задержка 1 секунда после инициализации
			scan_existing_bosses()
			self._initial_scan_done = true
			self._boss_scan_timer = 0
		end
	else
		-- Периодическое сканирование существующих боссов
		self._boss_scan_timer = self._boss_scan_timer + dt
		if self._boss_scan_timer >= self._boss_scan_interval then
			scan_existing_bosses()
			self._boss_scan_timer = 0
		end
	end
	
	-- Первое сканирование существующих боссов с задержкой после инициализации
	if not self._initial_scan_done then
		self._boss_scan_timer = self._boss_scan_timer + dt
		if self._boss_scan_timer >= 1.0 then  -- Задержка 1 секунда после инициализации
			scan_existing_bosses()
			self._initial_scan_done = true
			self._boss_scan_timer = 0
		end
	else
		-- Периодическое сканирование существующих боссов
		self._boss_scan_timer = self._boss_scan_timer + dt
		if self._boss_scan_timer >= self._boss_scan_interval then
			scan_existing_bosses()
			self._boss_scan_timer = 0
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
	-- mod:echo("CompassBar: _draw_widgets called")
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

	-- mod:echo("CompassBar: Location check - hub:" .. tostring(is_in_hub) .. ", psykh:" .. tostring(is_in_psykhanium) .. ", mission:" .. tostring(is_in_mission))
	-- mod:echo("CompassBar: Show settings - hub:" .. tostring(show_in_hub) .. ", psykh:" .. tostring(show_in_psykhanium) .. ", mission:" .. tostring(show_in_mission))

	-- Проверяем, нужно ли отображать компас в текущем месте
	local should_show = (is_in_hub and show_in_hub) or (is_in_psykhanium and show_in_psykhanium) or (is_in_mission and show_in_mission)
	-- mod:echo("CompassBar: Should show compass: " .. tostring(should_show))

	if not should_show then
		-- mod:echo("CompassBar: Compass not shown due to location settings")
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


	-- Отрисовка меток тимейтов
	local show_teammate_markers = mod:get("show_teammate_markers")
	if show_teammate_markers == nil then
		show_teammate_markers = true
	end

	-- Отрисовка меток тимейтов и боссов используя ТУ ЖЕ логику, что и в оригинальном коде Darktide
	-- Маркеры позиционируются относительно ближайшего деления компаса
	if show_teammate_markers then
		-- mod:echo("CompassBar: show_teammate_markers is true, getting positions")
		local teammates = self:_get_teammate_positions()
		-- mod:echo("CompassBar: Got " .. #teammates .. " teammates")
		local bosses = self:_get_boss_positions()
		-- mod:echo("CompassBar: Got " .. #bosses .. " bosses from _get_boss_positions")
		local teammate_marker_size = CompassBarSettings.teammate_marker_size
		local teammate_marker_color = CompassBarSettings.teammate_marker_color

		local teammate_color_table = {
			base_alpha,
			teammate_marker_color[2] or 255,
			teammate_marker_color[3] or 255,
			teammate_marker_color[4] or 255
		}

		-- Создаем таблицы иконок и цветов для тимейтов
		local teammate_class_icons = {}
		local teammate_player_colors = {}
		for i, teammate in ipairs(teammates) do
			teammate_class_icons[i] = teammate.class_icon_text or "?"
			teammate_player_colors[i] = teammate.player_color or teammate_color_table
		end

		-- Цвета для боссов (красный)
		local boss_color_table = {
			base_alpha,
			255, 0, 0  -- красный цвет для боссов
		}

		local half_height = area_size[2] * 0.5
		local icon_position = Vector3(0, 0, draw_layer)

		-- Функция для отрисовки маркеров (тимейтов и боссов)
		local function draw_markers(markers, marker_size, color_table, is_boss)
			-- Преобразуем углы в градусы
			local marker_angles_degrees = {}
			for i, marker in ipairs(markers) do
				local marker_angle_degrees = math.radians_to_degrees(marker.angle)
				marker_angles_degrees[i] = marker_angle_degrees
			end

			-- Проверяем каждый маркер для каждого видимого деления компаса
			for i = -visible_steps, visible_steps do
				local draw_index = start_index + i
				local read_index = (draw_index - 1) % num_steps + 1
				local local_x = start_offset + (draw_index - 1) * marker_spacing + area_position[1]

				-- Проверяем, находится ли деление в видимой области
				if local_x + size[1] >= area_position[1] and local_x <= area_position[1] + area_size[1] then
					local current_degree = (read_index * degrees_per_step) % DEGREES

					-- Проверяем каждый маркер
					for j, marker in ipairs(markers) do
						local marker_degrees = marker_angles_degrees[j]

						-- Проверяем видимость маркера
						local visible_angle_range = (visible_steps / 2) * degrees_per_step
						local relative_angle = player_direction_degree - marker_degrees
						local normalized_angle = relative_angle % DEGREES
						if normalized_angle > 180 then
							normalized_angle = normalized_angle - DEGREES
						end
						if normalized_angle < -180 then
							normalized_angle = normalized_angle + DEGREES
						end

						local abs_angle = math.abs(normalized_angle)

						-- Пропускаем если сзади
						if abs_angle > visible_angle_range then
							goto continue_marker
						end

						-- Нормализуем углы
						current_degree = current_degree % DEGREES
						local normalized_marker_degrees = marker_degrees % DEGREES

						-- Вычисляем разницу углов
						local degree_difference = normalized_marker_degrees - current_degree
						if degree_difference < 0 then
							degree_difference = degree_difference + DEGREES
						end

						-- Проверяем попадание в диапазон деления
						if degree_difference >= 0 and degree_difference <= degrees_per_step then
							local degree_difference_fraction = degree_difference / degrees_per_step
							local icon_x = local_x + marker_spacing * degree_difference_fraction

							-- Рисуем маркер
							if icon_x >= area_position[1] - marker_size and icon_x <= area_position[1] + area_size[1] + marker_size then
								icon_position[1] = icon_x - marker_size * 0.5
								icon_position[2] = area_position[2] + half_height - marker_size * 0.5

								if is_boss then
									-- Для врагов (боссов и элит) определяем тип
									local marker_unit = markers[j].unit
									local tracked_info = tracked_bosses[marker_unit]
									local marker_is_boss = tracked_info and tracked_info.is_boss

									-- Для всех врагов рисуем иконку врага (размер как у тимейтов)
									local enemy_icon = "content/ui/materials/hud/interactions/icons/enemy"
									local enemy_icon_size = Vector2(marker_size, marker_size)
									local enemy_color_table = {
										base_alpha,
										255, 0, 0  -- Красный цвет для всех врагов
									}
									UIRenderer.draw_texture(ui_renderer, enemy_icon, icon_position, enemy_icon_size, enemy_color_table)
									
								else
									-- Для тимейтов рисуем иконки классов
									local icon_text = teammate_class_icons[j]
									if icon_text then
										local icon_size = Vector3(marker_size, marker_size, 0)
										local icon_color = teammate_player_colors[j] or color_table
										UIRenderer.draw_text(ui_renderer, icon_text, marker_size, "machine_medium", icon_position, icon_size, icon_color, {})
									end
								end
							end
						end

						::continue_marker::
					end
				end
			end
		end

		-- Отрисовываем тимейтов
		draw_markers(teammates, teammate_marker_size, teammate_color_table, false)

		-- Отрисовываем боссов
		if #bosses > 0 then
			-- mod:echo("CompassBar: Рисуется " .. #bosses .. " маркеров боссов")
			draw_markers(bosses, teammate_marker_size, boss_color_table, true)
		end
	end

end

return HudElementCompassBar
