local mod = get_mod("PerspectivesRedux")
local CameraTransitionTemplates = require("scripts/settings/camera/camera_transition_templates")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")

-- Загрузка дополнительных модулей
mod:io_dofile("PerspectivesRedux/scripts/mods/PerspectivesRedux/Utils")
mod:io_dofile("PerspectivesRedux/scripts/mods/PerspectivesRedux/CameraTree")
mod:io_dofile("PerspectivesRedux/scripts/mods/PerspectivesRedux/TracerBeam")

-- ============================================================================
-- КОНСТАНТЫ
-- ============================================================================
local OPT_PREFIX_AUTOSWITCH = "^autoswitch_"
local ZOOM_SUFFIX = "_zoom"

-- ============================================================================
-- СОХРАНЕНИЕ ОРИГИНАЛЬНЫХ ЗНАЧЕНИЙ (для восстановления при выгрузке)
-- ============================================================================
local original_transition_duration = {
	to_third_person = nil,
	to_first_person = nil,
}

-- ============================================================================
-- ФЛАГИ И СОСТОЯНИЕ
-- ============================================================================
local is_initialized = false

-- Кэшированные значения настроек (ОПТИМИЗАЦИЯ: уменьшение вызовов mod:get)
local cached_settings = {
	aim_selection = 0,
	nonaim_selection = 0,
	cycle_includes_center = false,
	center_to_1p_human = false,
	center_to_1p_ogryn = true,
	xhair_fallback = "assault",
	use_lookaround_node = true,
}

-- Таблицы причин включения/выключения 3P режима
local enable_reasons = {}
local disable_reasons = {}

-- ОПТИМИЗАЦИЯ: Счётчики для быстрой проверки (O(1) вместо O(n))
local enable_reasons_count = 0
local disable_reasons_count = 0

-- ОПТИМИЗАЦИЯ: Lookup-таблица для autoswitch событий (предварительно распарсенная)
local autoswitch_events = {}

-- Состояние игрока и камеры
local use_3p_freelook_node = false
local holding_primary = false
local holding_secondary = false
local is_spectating = false
local is_in_hub = false

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

-- Получить юнит за которым следует камера
local _get_followed_unit = function()
	local camera_handler = mod.get_camera_handler()
	return camera_handler and camera_handler:camera_follow_unit()
end

-- Получить следующую точку обзора в цикле
local _get_next_viewpoint = function(previous)
	if previous == "pspv_right" then
		return "pspv_left"
	end
	if previous == "pspv_left" and cached_settings.cycle_includes_center then
		return "pspv_center"
	end
	return "pspv_right"
end

-- Текущая точка обзора (инициализируется правильно в _initialize_settings)
local current_viewpoint = "pspv_right"

-- Преобразование индекса в название viewpoint
local _idx_to_viewpoint = function(idx)
	if idx == 1 then
		return "pspv_center"
	elseif idx == 2 then
		return "pspv_right"
	elseif idx == 3 then
		return "pspv_left"
	end
	return current_viewpoint
end

-- Получить ноду прицеливания
local _get_aim_node = function()
	return _idx_to_viewpoint(cached_settings.aim_selection) .. ZOOM_SUFFIX
end

-- Получить ноду без прицеливания
local _get_nonaim_node = function()
	return _idx_to_viewpoint(cached_settings.nonaim_selection)
end

-- Кэшированные ноды
local aim_node = _get_aim_node()
local nonaim_node = _get_nonaim_node()

-- ============================================================================
-- ЭКСПОРТИРУЕМЫЕ ФУНКЦИИ
-- ============================================================================

-- Функция для циклического переключения плеча (keybind)
mod.kb_cycle_shoulder = function()
	if not mod.is_cursor_active() then
		current_viewpoint = _get_next_viewpoint(current_viewpoint)
		aim_node = _get_aim_node()
		nonaim_node = _get_nonaim_node()
	end
end

-- Хук для совместимости с другими модами при загрузке всех модов
mod.on_all_mods_loaded = function()
	-- Инициализация трассера после загрузки всех модов (когда мир уже готов)
	if mod.set_tracer_enabled then
		local tracer_enabled = mod:get("tracer_enabled")
		if tracer_enabled then
			mod.set_tracer_enabled(tracer_enabled)
		end
	end
	
	-- Интеграция с camera_freeflight
	local freeflight_mod = get_mod("camera_freeflight")
	if freeflight_mod then
		mod:hook(freeflight_mod, "set_3p", function(func, self, enabled)
			func(self, enabled or mod.is_requesting_third_person())
		end)
	end

	-- Интеграция с LookAround
	local lookaround_mod = get_mod("LookAround")
	if lookaround_mod then
		mod:hook_safe(lookaround_mod, "on_freelook_changed", function(value)
			use_3p_freelook_node = value and cached_settings.use_lookaround_node
		end)
	end
	
	-- Отметить мод как инициализированный
	is_initialized = true
end

-- ОПТИМИЗАЦИЯ: Проверка есть ли причины для отключения 3P (O(1))
local _has_disable_reason = function()
	return disable_reasons_count > 0
end

-- ОПТИМИЗАЦИЯ: Проверка есть ли причины для включения 3P (O(1))
local _has_enable_reason = function()
	return enable_reasons_count > 0
end

-- Определить нужен ли режим третьего лица
mod.is_requesting_third_person = function()
	local enable = false
	local disable = false
	
	if is_spectating then
		-- При наблюдении проверяем только базовые и специфичные причины
		enable = not not (enable_reasons["_base"] or enable_reasons["spectate"])
		disable = disable_reasons["_base"] or disable_reasons["spectate"]
	else
		enable = _has_enable_reason()
		disable = _has_disable_reason()
	end
	
	return enable and not disable
end

-- ИСПРАВЛЕНИЕ: Безопасное применение перспективы с pcall
mod.apply_perspective = function()
	local unit = _get_followed_unit()
	if not unit then
		return
	end
	
	-- Безопасная проверка и установка third person режима
	local success, error_msg = pcall(function()
		if ScriptUnit.has_extension(unit, "first_person_system") then
			local ext = ScriptUnit.extension(unit, "first_person_system")
			-- Проверяем что extension валидный и имеет нужное поле
			if ext and type(ext._force_third_person_mode) ~= "nil" then
				ext._force_third_person_mode = mod.is_requesting_third_person()
			end
		end
	end)
	
	if not success then
		mod:error("Failed to apply perspective: %s", error_msg)
	end
end

-- ОПТИМИЗАЦИЯ: Отключить 3P по определенной причине (со счётчиком)
mod.disable_3p_due_to = function(reason, d, apply_if_different)
	local prev = disable_reasons[reason]
	
	if d then
		if not prev then
			disable_reasons_count = disable_reasons_count + 1
		end
		disable_reasons[reason] = d
	else
		if prev then
			disable_reasons_count = disable_reasons_count - 1
		end
		disable_reasons[reason] = nil
	end
	
	local diff = prev ~= disable_reasons[reason]
	if (apply_if_different == nil or apply_if_different) and diff then
		mod.apply_perspective()
	end
	return diff
end

-- ОПТИМИЗАЦИЯ: Включить 3P по определенной причине (со счётчиком)
mod.enable_3p_due_to = function(reason, e, apply_if_different)
	local prev = enable_reasons[reason]
	
	if e then
		if not prev then
			enable_reasons_count = enable_reasons_count + 1
		end
		enable_reasons[reason] = true
	else
		if prev then
			enable_reasons_count = enable_reasons_count - 1
		end
		enable_reasons[reason] = nil
	end
	
	local diff = prev ~= enable_reasons[reason]
	if (apply_if_different == nil or apply_if_different) and diff then
		mod.apply_perspective()
	end
	return diff
end

-- Мультиплексировать включение/отключение 3P
mod.mux_3p_due_to = function(reason, enable, disable)
	local diff = mod.enable_3p_due_to(reason, enable, false)
	diff = mod.disable_3p_due_to(reason, disable, false) or diff
	if diff then
		mod.apply_perspective()
	end
	return diff
end

-- Очистить причину
mod.clear_reason = function(reason)
	return mod.mux_3p_due_to(reason, false, false)
end

-- Автопереключение на основе события
local _autoswitch_from_event = function(reason, event, condition)
	if not event then
		return mod.clear_reason(reason)
	end
	
	local autoswitch_mode = 0
	if autoswitch_events[event] and (condition == nil or condition) then
		autoswitch_mode = autoswitch_events[event]
	end
	return mod.mux_3p_due_to(reason, autoswitch_mode == 2, autoswitch_mode == 1)
end

-- ИСПРАВЛЕНИЕ: Обработчик изменения настроек с отложенной инициализацией
mod.on_setting_changed = function(id)
	-- ИСПРАВЛЕНИЕ: Откладываем применение настроек до инициализации (кроме критичных)
	if not is_initialized and id ~= "perspective_transition_time" and id ~= "allow_switching" then
		return
	end
	
	local val = mod:get(id)
	
	if id == "allow_switching" then
		mod.disable_3p_due_to("_mod", not val)
	elseif id == "xhair_fallback" then
		cached_settings.xhair_fallback = val
	elseif id == "cycle_includes_center" then
		cached_settings.cycle_includes_center = val
	elseif id == "center_to_1p_human" then
		cached_settings.center_to_1p_human = val
	elseif id == "center_to_1p_ogryn" then
		cached_settings.center_to_1p_ogryn = val
	elseif id == "aim_mode" then
		cached_settings.aim_selection = val
		aim_node = _get_aim_node()
	elseif id == "nonaim_mode" then
		cached_settings.nonaim_selection = val
		nonaim_node = _get_nonaim_node()
	elseif id == "use_lookaround_node" then
		cached_settings.use_lookaround_node = val
	elseif id == "perspective_transition_time" then
		-- ИСПРАВЛЕНИЕ: Безопасное изменение глобальных настроек камеры
		if CameraTransitionTemplates.to_third_person and 
		   CameraTransitionTemplates.to_third_person.position then
			-- Сохраняем оригинал при первом изменении
			if not original_transition_duration.to_third_person then
				original_transition_duration.to_third_person = CameraTransitionTemplates.to_third_person.position.duration
			end
			CameraTransitionTemplates.to_third_person.position.duration = val
		end
		
		if CameraTransitionTemplates.to_first_person and 
		   CameraTransitionTemplates.to_first_person.position then
			if not original_transition_duration.to_first_person then
				original_transition_duration.to_first_person = CameraTransitionTemplates.to_first_person.position.duration
			end
			CameraTransitionTemplates.to_first_person.position.duration = val
		end
	elseif id == "custom_distance"
		or id == "custom_offset"
		or id == "custom_distance_zoom"
		or id == "custom_offset_zoom"
		or id == "custom_distance_ogryn"
		or id == "custom_offset_ogryn"
		then
		mod.apply_custom_viewpoint()
	elseif string.find(id, OPT_PREFIX_AUTOSWITCH) then
		-- ОПТИМИЗАЦИЯ: Обновляем lookup-таблицу autoswitch событий
		local key = string.sub(id, string.len(OPT_PREFIX_AUTOSWITCH) + 1)
		autoswitch_events[key] = val
	elseif id == "tracer_enabled" then
		mod.set_tracer_enabled(val)
	elseif id == "tracer_duration" or id == "tracer_color_r" or id == "tracer_color_g" or id == "tracer_color_b" then
		-- Настройки трассера обновляются автоматически при следующем кадре
	end
end

-- ИСПРАВЛЕНИЕ: Централизованная инициализация настроек
local _initialize_settings = function()
	-- Загрузка кэшированных настроек
	cached_settings.aim_selection = mod:get("aim_mode")
	cached_settings.nonaim_selection = mod:get("nonaim_mode")
	cached_settings.cycle_includes_center = mod:get("cycle_includes_center")
	cached_settings.center_to_1p_human = mod:get("center_to_1p_human")
	cached_settings.center_to_1p_ogryn = mod:get("center_to_1p_ogryn")
	cached_settings.xhair_fallback = mod:get("xhair_fallback")
	cached_settings.use_lookaround_node = mod:get("use_lookaround_node")
	
	-- ИСПРАВЛЕНИЕ: Правильная инициализация current_viewpoint на основе настроек
	current_viewpoint = _idx_to_viewpoint(cached_settings.nonaim_selection)
	aim_node = _get_aim_node()
	nonaim_node = _get_nonaim_node()
	
	-- Применение критичных настроек
	mod.on_setting_changed("perspective_transition_time")
	mod.on_setting_changed("allow_switching")
	
	-- Инициализация трассера
	mod.on_setting_changed("tracer_enabled")
	
	-- ОПТИМИЗАЦИЯ: Загрузка всех autoswitch настроек одним блоком
	local autoswitch_settings = {
		"autoswitch_spectate",
		"autoswitch_slot_device",
		"autoswitch_slot_primary",
		"autoswitch_slot_secondary",
		"autoswitch_slot_grenade_ability",
		"autoswitch_slot_pocketable",
		"autoswitch_slot_pocketable_small",
		"autoswitch_slot_luggable",
		"autoswitch_slot_unarmed",
		"autoswitch_sprint",
		"autoswitch_lunge_ogryn",
		"autoswitch_lunge_human",
		"autoswitch_act2_primary",
		"autoswitch_act2_secondary",
	}
	
	for _, setting_id in ipairs(autoswitch_settings) do
		mod.on_setting_changed(setting_id)
	end
	
	-- Применение кастомных настроек камеры
	mod.apply_custom_viewpoint()
end

-- Выполнить инициализацию
_initialize_settings()

-- Переключить режим третьего лица
mod.toggle_third_person = function()
	local prev = mod.is_requesting_third_person()
	mod.clear_reason("slot")
	mod.clear_reason("spectate")
	
	if prev == mod.is_requesting_third_person() then
		mod.enable_3p_due_to("_base", not prev)
	end
end

-- Keybind для переключения третьего лица
mod.kb_toggle_third_person = function()
	if not mod.is_cursor_active() then
		mod.toggle_third_person()
	end
end

-- ИСПРАВЛЕНИЕ: Полная очистка при выгрузке мода
mod.on_unload = function(quitting)
	if not quitting then
		-- Отключаем 3P режим при выгрузке
		mod.disable_3p_due_to("_unload", true)
		
		-- ИСПРАВЛЕНИЕ: Восстанавливаем оригинальные значения переходов камеры
		if original_transition_duration.to_third_person and 
		   CameraTransitionTemplates.to_third_person and 
		   CameraTransitionTemplates.to_third_person.position then
			CameraTransitionTemplates.to_third_person.position.duration = original_transition_duration.to_third_person
		end
		
		if original_transition_duration.to_first_person and 
		   CameraTransitionTemplates.to_first_person and 
		   CameraTransitionTemplates.to_first_person.position then
			CameraTransitionTemplates.to_first_person.position.duration = original_transition_duration.to_first_person
		end
		
		-- Очищаем кэш camera handler
		mod.clear_camera_handler_cache()
		
		-- ИСПРАВЛЕНИЕ: Очищаем таблицы reasons и счётчики
		enable_reasons = {}
		disable_reasons = {}
		enable_reasons_count = 0
		disable_reasons_count = 0
		autoswitch_events = {}
	end
end

-- ============================================================================
-- ХУКИ
-- ============================================================================

-- Хук на смену оружия
mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
	_autoswitch_from_event("slot", slot_name)
	_autoswitch_from_event("act2", nil)
	holding_primary = slot_name == "slot_primary"
	holding_secondary = slot_name == "slot_secondary"
end)

-- ОПТИМИЗАЦИЯ: Общий хук для обработки action_two_hold (объединенная версия)
local _input_action_hook = function(func, self, action_name)
	local val = func(self, action_name)
	
	if action_name == "action_two_hold" then
		if holding_primary then
			_autoswitch_from_event("act2", "act2_primary", val)
		elseif holding_secondary then
			_autoswitch_from_event("act2", "act2_secondary", val)
		end
	end
	
	return val
end

-- Применяем хук один раз для обоих методов
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

-- Хук на определение принудительного режима третьего лица
mod:hook(CLASS.MissionManager, "force_third_person_mode", function(func, self)
	local mode = mod:get("default_perspective_mode")
	
	local request_3p = func(self)
	if mode == -1 then
		request_3p = not request_3p
	elseif mode == 1 then
		request_3p = false
	elseif mode == 2 then
		request_3p = true
	end
	
	mod.enable_3p_due_to("_base", request_3p)
	return request_3p
end)

-- Определить нужно ли переходить в 1P при прицеливании
local _should_aim_to_1p = function(is_aiming, is_ogryn)
	if not is_aiming then
		return false
	end
	
	if cached_settings.aim_selection == -1 then
		return true
	end
	
	if cached_settings.aim_selection == 0 and current_viewpoint == "pspv_center" then
		if is_ogryn then
			return cached_settings.center_to_1p_ogryn
		end
		return cached_settings.center_to_1p_human
	end
	
	return false
end

-- Константы для специальных нод
local NODE_IGNORE_SCALED_TRANSFORM_OFFSETS = {
	consumed = true
}

local NODE_OBJECT_NAMES = {
	consumed = "j_hips"
}

-- Хук на оценку дерева камеры (основная логика мода)
mod:hook(CLASS.PlayerUnitCameraExtension, "_evaluate_camera_tree", function(func, self)
	-- Применяем только к локальному игроку
	if self._unit ~= mod.get_player_unit() then
		func(self)
		return
	end
	
	-- Логика определения дерева и ноды камеры (из оригинального кода игры)
	local wants_first_person_camera = self._first_person_extension:wants_first_person_camera()
	local character_state_component = self._character_state_component
	local assisted_state_input_component = self._assisted_state_input_component
	local sprint_character_state_component = self._sprint_character_state_component
	local disabling_type = self._disabled_character_state_component.disabling_type
	local is_ledge_hanging = PlayerUnitStatus.is_ledge_hanging(character_state_component)
	local is_assisted = PlayerUnitStatus.is_assisted(assisted_state_input_component)
	local is_pounced = disabling_type == "pounced"
	local is_netted = disabling_type == "netted"
	local is_warp_grabbed = disabling_type == "warp_grabbed"
	local is_mutant_charged = disabling_type == "mutant_charged"
	local is_grabbed = disabling_type == "grabbed"
	local is_consumed = disabling_type == "consumed"
	local alternate_fire_is_active = self._alternate_fire_component.is_active
	local tree, node = nil, nil
	
	local is_ogryn = self._breed.name == "ogryn"
	mod.disable_3p_due_to("aim", _should_aim_to_1p(alternate_fire_is_active, is_ogryn))
	
	-- Автопереключение при спринте/рывке
	local wants_sprint_camera = sprint_character_state_component.wants_sprint_camera
	local is_lunging = self._lunge_character_state_component.is_lunging
	
	if wants_sprint_camera then
		_autoswitch_from_event("movt", "sprint")
	elseif is_lunging then
		if is_ogryn then
			_autoswitch_from_event("movt", "lunge_ogryn")
		else
			_autoswitch_from_event("movt", "lunge_human")
		end
	else
		_autoswitch_from_event("movt", nil)
	end
	
	-- Определение дерева и ноды камеры
	if wants_first_person_camera then
		local sprint_overtime = sprint_character_state_component.sprint_overtime
		local have_sprint_over_time = sprint_overtime and sprint_overtime > 0
		
		if is_assisted then
			node = "first_person_assisted"
		elseif alternate_fire_is_active then
			node = "aim_down_sight"
		elseif wants_sprint_camera and have_sprint_over_time then
			node = "sprint_overtime"
		elseif wants_sprint_camera then
			node = "sprint"
		elseif is_lunging then
			node = "lunge"
		else
			node = "first_person"
		end
		
		tree = "first_person"
	elseif self._use_third_person_hub_camera then
		tree = "third_person_hub"
		
		if is_ogryn then
			node = "third_person_ogryn"
		else
			node = "third_person_human"
		end
	else
		local is_disabled, requires_help = PlayerUnitStatus.is_disabled(character_state_component)
		local is_hogtied = PlayerUnitStatus.is_hogtied(character_state_component)
		
		if is_hogtied then
			node = "hogtied"
		elseif is_ledge_hanging then
			node = "ledge_hanging"
		elseif is_pounced or is_netted or is_warp_grabbed or is_mutant_charged or is_grabbed then
			node = "pounced"
		elseif is_consumed then
			node = "consumed"
		elseif is_disabled and requires_help then
			node = "disabled"
		else
			-- Кастомная логика мода для выбора ноды третьего лица
			if mod.is_requesting_third_person() then
				if use_3p_freelook_node then
					node = "pspv_lookaround"
				elseif alternate_fire_is_active then
					node = aim_node
				else
					node = nonaim_node
				end
				
				if is_ogryn then
					node = node .. "_ogryn"
				end
			else
				node = "third_person"
			end
		end
		
		tree = "third_person"
	end
	
	-- Применение дерева и ноды к компоненту камеры
	local camera_tree_component = self._camera_tree_component
	camera_tree_component.tree = tree
	camera_tree_component.node = node
	self._tree = tree
	self._node = node
	
	local object_name = NODE_OBJECT_NAMES[node]
	local object = nil
	
	if object_name then
		object = Unit.node(self._unit, object_name)
	end
	
	self._object = object
	local ignore_offset = NODE_IGNORE_SCALED_TRANSFORM_OFFSETS[node]
	
	if self._ignore_offset ~= ignore_offset then
		local player_unit_spawn_manager = Managers.state.player_unit_spawn
		local player = player_unit_spawn_manager:owner(self._unit)
		
		if player:is_human_controlled() then
			local viewport_name = player.viewport_name
			
			if viewport_name then
				Managers.state.camera:set_variable(viewport_name, "ignore_offset", ignore_offset)
			end
		end
	end
	
	self._ignore_offset = ignore_offset
end)

-- Хук на камеру Husk (для других игроков/наблюдения)
mod:hook(CLASS.PlayerHuskCameraExtension, "camera_tree_node", function(func, self)
	local tree, node, object = func(self)
	
	if mod.is_requesting_third_person() then
		tree = "third_person"
		node = nonaim_node
	else
		tree = "first_person"
		node = "first_person"
	end
	
	return tree, node, object
end)

-- Хук для фикса получения следующего юнита для наблюдения
mod:hook(CLASS.CameraHandler, "_next_follow_unit", function(func, self, except_unit)
	if not self._side_id and self._side_system then
		local side = self._side_system:get_side_from_name("heroes")
		self._side_id = side and side.side_id
	end
	return func(self, except_unit)
end)

-- Хук на переключение цели наблюдения
mod:hook_safe(CLASS.CameraHandler, "_switch_follow_target", function(self, new_unit)
	if self._player then
		is_spectating = new_unit ~= self._player.player_unit
		_autoswitch_from_event("spectate", "spectate", is_spectating)
	end
	mod.apply_perspective()
end)

-- Хук на обновление first person режима для Husk
mod:hook(CLASS.PlayerHuskFirstPersonExtension, "_update_first_person_mode", function(func, self, t)
	if self._is_first_person_spectated then
		local in_1p = not mod.is_requesting_third_person()
		return in_1p, in_1p
	end
	return func(self, t)
end)

-- Хук на инициализацию игрового режима (для определения хаба)
mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
	is_in_hub = game_mode_name == "hub"
end)

-- Хук на получение типа прицела
mod:hook(CLASS.HudElementCrosshair, "_get_current_crosshair_type", function(func, self, crosshair_settings)
	local type = func(self, crosshair_settings)
	
	-- Применяем fallback прицел в 3P если оригинальный "none" или "ironsight"
	if crosshair_settings and 
	   cached_settings.xhair_fallback ~= "none" and 
	   (type == "none" or type == "ironsight") and 
	   not is_in_hub and 
	   mod.is_requesting_third_person() then
		return cached_settings.xhair_fallback
	end
	
	return type
end)

-- Хук для обновления трассера каждый кадр
mod:hook(CLASS.PlayerUnitFirstPersonExtension, "update", function(func, self, unit, dt, t, ...)
	func(self, unit, dt, t, ...)
	
	-- Обновляем систему трассера если она включена
	-- Проверяем что это юнит игрока (не husk)
	if unit == mod.get_player_unit() and mod.update_tracer_system then
		mod.update_tracer_system()
	end
end)
