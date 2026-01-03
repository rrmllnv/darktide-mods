local mod = get_mod("ClipIt")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local ChatHistory = mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history")

mod.version = "1.0.0"
mod.history = ChatHistory:new()

-- Регистрация view истории чата
mod:add_require_path("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view")
mod:add_require_path("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_definitions")
mod:add_require_path("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_settings")
mod:add_require_path("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view_blueprints")

mod:register_view({
	view_name = "chat_history_view",
	view_settings = {
		init_view_function = function(ingame_ui_context)
			return true
		end,
		state_bound = true,
		path = "ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view",
		class = "ChatHistoryView",
		disable_game_world = false,
		load_in_hub = true,
		load_always = true,
		game_world_blur = 1,
		enter_sound_events = {
			"wwise/events/ui/play_ui_enter",
		},
		exit_sound_events = {
			"wwise/events/ui/play_ui_back",
		},
	},
	view_transitions = {},
	view_options = {
		close_all = false,
		close_previous = false,
		close_transition_time = nil,
		transition_time = nil
	}
})

mod:io_dofile("ClipIt/scripts/mods/ClipIt/chat_history_view/chat_history_view")

-- Кеш для настроек и состояния
local _cached_settings = {
	block_chat_enabled = false,
	fade_audio_enabled = false,
	fade_audio_channel = 1,
	fade_audio_volume = 20,
	save_chat_history = true,
	last_check_time = 0,
	check_interval = 0.5
}

local _input_state = {
	is_blocked = false,
	ui_using_input = false
}

-- Состояние звука
local _audio_state = {
	is_faded = false,
	original_volume = nil,
	current_channel = nil
}

-- Каналы звука
local _audio_channels = {
	[1] = "option_master_slider",        -- Мастер-громкость (всё)
	[2] = "options_sfx_slider",          -- Звуковые эффекты
	[3] = "options_music_slider",        -- Музыка
}

-- Обновление кеша настроек
local function update_settings_cache()
	local current_time = os.clock()
	if current_time - _cached_settings.last_check_time > _cached_settings.check_interval then
		_cached_settings.block_chat_enabled = mod:get("auto_block") or false
		_cached_settings.fade_audio_enabled = mod:get("fade_audio_unfocused") or false
		_cached_settings.fade_audio_channel = mod:get("fade_audio_channel") or 1
		_cached_settings.fade_audio_volume = mod:get("fade_audio_volume") or 20
		_cached_settings.save_chat_history = mod:get("save_chat_history")
		if _cached_settings.save_chat_history == nil then
			_cached_settings.save_chat_history = true
		end
		_cached_settings.last_check_time = current_time
	end
end

-- Получение текущей громкости из настроек
local function get_current_volume(channel_param)
	if Application.user_setting then
		return Application.user_setting("sound_settings", channel_param) or 100
	end
	return 100
end

-- Установка громкости
local function set_volume(channel_param, volume)
	if Wwise and Wwise.set_parameter then
		Wwise.set_parameter(channel_param, volume)
	end
end

-- Затухание звука
local function fade_audio_out()
	if _audio_state.is_faded then
		return
	end
	
	local channel_param = _audio_channels[_cached_settings.fade_audio_channel]
	if not channel_param then
		return
	end
	
	_audio_state.current_channel = channel_param
	_audio_state.original_volume = get_current_volume(channel_param)
	set_volume(channel_param, _cached_settings.fade_audio_volume)
	_audio_state.is_faded = true
end

-- Восстановление звука
local function fade_audio_in()
	if not _audio_state.is_faded then
		return
	end
	
	if _audio_state.original_volume and _audio_state.current_channel then
		set_volume(_audio_state.current_channel, _audio_state.original_volume)
		_audio_state.original_volume = nil
		_audio_state.current_channel = nil
	end
	_audio_state.is_faded = false
end

-- Проверка условий для затухания звука
local function should_fade_audio()
	if not _cached_settings.fade_audio_enabled then
		return false
	end
	
	-- Окно не в фокусе
	if IS_WINDOWS and not Window.has_focus() then
		return true
	end
	
	-- Steam overlay активен
	if HAS_STEAM and Managers.steam and Managers.steam:is_overlay_active() then
		return true
	end
	
	-- Интерфейс использует ввод (чат или меню открыты)
	if _input_state.is_blocked then
		return true
	end
	
	return false
end

local function can_weapon_block()
	local player = Managers.player:local_player(1)
	if not player or not player.player_unit then
		return false
	end
	
	local unit = player.player_unit
	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	
	if not unit_data_extension then
		return false
	end
	
	local weapon_action_component = unit_data_extension:read_component("weapon_action")
	local current_weapon_template = WeaponTemplate.current_weapon_template(weapon_action_component)
	
	return current_weapon_template and current_weapon_template.actions and current_weapon_template.actions.action_block
end

local function should_auto_block()
	if not _cached_settings.block_chat_enabled then
		return false
	end
	
	if not can_weapon_block() then
		return false
	end
	
	if IS_WINDOWS and not Window.has_focus() then
		return true
	end
	
	if HAS_STEAM and Managers.steam and Managers.steam:is_overlay_active() then
		return true
	end
	
	if _input_state.is_blocked then
		return true
	end
	
	return false
end

local function handle_input_service(func, self, action_name)
	if self.type ~= "Ingame" or action_name == "voip_push_to_talk" then
		return func(self, action_name)
	end
	
	update_settings_cache()
	
	if action_name == "action_two_hold" and should_auto_block() then
		return true
	end
	
	local ui_manager = Managers.ui
	if ui_manager and ui_manager:using_input() then
		local original_result = func(self, action_name)
		local result_type = type(original_result)
		
		if result_type == "boolean" then
			return false
		elseif result_type == "number" then
			return 0
		elseif result_type == "userdata" then
			return Vector3.zero()
		end
		
		return original_result
	end
	
	return func(self, action_name)
end

-- Хукаем InputService для перехвата ввода
mod:hook("InputService", "_get", handle_input_service)
mod:hook("InputService", "_get_simulate", handle_input_service)

-- Управление активностью ввода
mod:hook("HumanGameplay", "_input_active", function(func, ...)
	update_settings_cache()
	
	if not _cached_settings.block_chat_enabled then
		return func(...)
	end
	
	-- Сохраняем состояние блокировки ввода
	_input_state.is_blocked = not func(...)
	
	-- Отключаем ввод во время синематиков
	if Managers.state.cinematic and Managers.state.cinematic:cinematic_active() then
		return false
	end
	
	-- Оставляем ввод активным для возможности блокировки
	return true
end)

-- ============================================================================
-- Функционал истории чата
-- ============================================================================

-- Определение типа локации и названия по mission_name
local function get_location_info(mission_name)
	if not mission_name or mission_name == "" then
		return "mourningstar", "hub_ship"
	end
	
	if mission_name == "hub_ship" then
		return "mourningstar", "hub_ship"
	end
	
	if mission_name == "tg_shooting_range" or mission_name == "tg_training_grounds" then
		return "psykhanium", mission_name
	end
	
	return "mission", mission_name
end

-- Текущая информация о локации
local _current_location_type = nil
local _current_mission_name = nil

-- Хук для определения начала миссии
mod:hook(CLASS.StateGameplay, "on_enter", function(func, self, parent, params, ...)
	func(self, parent, params, ...)
	
	if not _cached_settings.save_chat_history then
		return
	end
	
	local mission_name = params.mission_name
	
	if not mission_name or mission_name == "" then
		return
	end
	
	local location_type, location_name = get_location_info(mission_name)
	
	-- Если локация изменилась, сохраняем предыдущую сессию
	if _current_location_type and (_current_location_type ~= location_type or _current_mission_name ~= mission_name) then
		mod.history:save_current_session()
	end
	
	-- Начинаем новую сессию
	mod.history:start_session(location_type, location_name)
	_current_location_type = location_type
	_current_mission_name = mission_name
end)

-- Хук для сохранения при выходе из миссии
mod:hook(CLASS.StateGameplay, "on_exit", function(func, self, ...)
	if _cached_settings.save_chat_history and _current_location_type then
		mod.history:save_current_session()
		_current_location_type = nil
		_current_mission_name = nil
	end
	
	func(self, ...)
end)

-- Обновление состояния (вызывается каждый кадр)
mod.update = function(dt)
	update_settings_cache()
	
	-- Управление затуханием звука
	if should_fade_audio() then
		fade_audio_out()
	else
		fade_audio_in()
	end
end

-- ============================================================================
-- Функционал копирования чата
-- ============================================================================

-- Очистка текста от форматирования
local function clean_formatting_tags(text)
	if not text or text == "" then
		return ""
	end
	
	local cleaned = text
	local scrubbed_text
	
	while text ~= scrubbed_text do
		text = scrubbed_text or text
		scrubbed_text = string.gsub(text, "{#.-}", "")
	end
	
	scrubbed_text = string.gsub(scrubbed_text, "{#.-$", "")
	
	return scrubbed_text
end

local function clipboard_copy(text, message_count)
	if not text or text == "" then
		return false
	end
	
	local clipboard = rawget(_G, "Clipboard")
	if not clipboard or not clipboard.put then
		return false
	end
	
	clipboard.put(text)
	
	if message_count and message_count > 1 then
		mod:notify(mod:localize("msgs_copied") .. message_count)
	else
		mod:notify(mod:localize("msg_copied"))
	end
	
	return true
end

local function extract_message_text(widget_content)
	if not widget_content then
		return nil
	end
	
	local text = widget_content._clipit_original_message
	
	if not text or text == "" then
		local formatted = widget_content.message
		if formatted and formatted ~= "" then
			text = clean_formatting_tags(formatted)
		end
	else
		text = clean_formatting_tags(text)
	end
	
	return text
end

local function extract_sender_name(widget_content)
	if not widget_content then
		return ""
	end
	
	return widget_content._clipit_original_sender or ""
end

local function format_message(text, sender_name, include_sender)
	if not text or text == "" then
		return nil
	end
	
	if include_sender and sender_name and sender_name ~= "" then
		return sender_name .. ": " .. text
	end
	
	return text
end

local function get_chat_element()
	local ui_manager = Managers.ui
	if not ui_manager then
		return nil
	end
	
	local constant_elements = ui_manager._ui_constant_elements
	if not constant_elements or not constant_elements._elements then
		return nil
	end
	
	return constant_elements._elements.ConstantElementChat
end

mod:hook("ConstantElementChat", "_add_message_widget_to_message_list", function(func, self, new_message, new_message_widget)
	func(self, new_message, new_message_widget)
	
	if not new_message_widget or not new_message_widget.content then
		return
	end
	
	local widget_content = new_message_widget.content
	
	if new_message.message_text and new_message.message_text ~= "" then
		widget_content._clipit_original_message = new_message.message_text
	end
	
	if new_message.author_name and new_message.author_name ~= "" then
		local cleaned_name = clean_formatting_tags(new_message.author_name)
		widget_content._clipit_original_sender = cleaned_name ~= "" and cleaned_name or new_message.author_name
	end
	
	-- Сохраняем в историю чата если включено
	if _cached_settings.save_chat_history and new_message.message_text and new_message.message_text ~= "" then
		local sender = new_message.author_name or ""
		local message = new_message.message_text
		local channel = new_message.channel_tag or "Strike Team"
		
		-- Очищаем от форматирования для сохранения
		sender = clean_formatting_tags(sender)
		message = clean_formatting_tags(message)
		
		mod.history:add_message(sender, message, channel)
	end
end)

mod.copy_last_message = function()
	local chat_element = get_chat_element()
	if not chat_element then
		return
	end
	
	local message_widgets = chat_element._message_widgets
	local last_message_index = chat_element._last_message_index
	
	if not message_widgets or #message_widgets == 0 or not last_message_index then
		return
	end
	
	local requested_count = mod:get("messages_count") or 1
	local include_sender_names = mod:get("copy_sender_names")
	if include_sender_names == nil then
		include_sender_names = true
	end
	
	local max_available = #message_widgets
	local messages_to_copy = math.min(requested_count, max_available)
	
	local messages_buffer = {}
	
	for offset = 0, messages_to_copy - 1 do
		local widget_index = math.index_wrapper(last_message_index - offset, max_available)
		local widget = message_widgets[widget_index]
		
		if widget and widget.content then
			local message_text = extract_message_text(widget.content)
			
			if message_text then
				local sender_name = extract_sender_name(widget.content)
				local formatted = format_message(message_text, sender_name, include_sender_names)
				
				if formatted then
					table.insert(messages_buffer, 1, formatted)
				end
			end
		end
	end
	
	if #messages_buffer > 0 then
		local final_text = table.concat(messages_buffer, "\n")
		clipboard_copy(final_text, #messages_buffer)
	end
end

-- Функция открытия истории чата
mod.open_chat_history = function()
	local ui_manager = Managers.ui
	if not ui_manager then
		mod:notify("UI Manager not available")
		return
	end
	
	-- Открываем view истории
	ui_manager:open_view("chat_history_view")
end


