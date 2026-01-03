local mod = get_mod("ClipIt")
local DMF = get_mod("DMF")

-- Получаем доступ к файловой системе через DMF
local _io = DMF:persistent_table("_io")
_io.initialized = _io.initialized or false
if not _io.initialized then
	_io = DMF.deepcopy(Mods.lua.io)
	_io.initialized = true
end

local _os = DMF:persistent_table("_os")
_os.initialized = _os.initialized or false
if not _os.initialized then
	_os = DMF.deepcopy(Mods.lua.os)
	_os.initialized = true
end

-- ============================================================================
-- Вспомогательные функции для работы с файловой системой
-- ============================================================================

-- Проверка существования файла или директории
local function exists(file)
	local ok, _, code = _os.rename(file, file)
	if not ok then
		if code == 13 then
			-- Отказано в доступе, но файл существует
			return true
		end
	end
	return ok
end

-- Проверка, является ли путь директорией
local function isdir(path)
	return exists(path .. "/")
end

-- Сканирование директории и возврат списка файлов
local function scandir(directory)
	local i, file_names, popen = 0, {}, _io.popen
	local pfile = popen('dir "' .. directory .. '" /b')
	if not pfile then
		return {}
	end
	for filename in pfile:lines() do
		i = i + 1
		file_names[i] = filename
	end
	pfile:close()
	return file_names
end

-- Создание директории если не существует
local function mkdir(path)
	if not isdir(path) then
		_os.execute('mkdir "' .. path .. '"')
	end
end

-- ============================================================================
-- Класс ChatHistory
-- ============================================================================

local ChatHistory = class("ChatHistory")

function ChatHistory:init()
	self._history_entries_cache = nil
	self._current_session_messages = {}
	self._current_session_type = nil -- "mission", "mourningstar" или "psykhanium"
	self._current_session_name = nil
	self._last_save_time = 0
	self._cache_initialized = false
	self._loaded_files_cache = {} -- Кеш загруженных файлов
end

-- Получение пути к папке с историей чата
function ChatHistory:get_path()
	return string.format("%s/Fatshark/Darktide/clipit_history/", _os.getenv("APPDATA"))
end

-- Предварительная инициализация кеша (вызывается при первом сообщении)
function ChatHistory:init_cache_async()
	if not self._cache_initialized then
		self._history_entries_cache = scandir(self:get_path())
		self._cache_initialized = true
	end
end

-- Парсинг имени файла истории
function ChatHistory:parse_filename(file_name)
	-- Формат: timestamp_type_location.json
	-- type: mission, mourningstar или psykhanium
	local name_without_ext = file_name:match("(.+)%.json$")
	if not name_without_ext then
		return nil
	end
	
	-- Извлекаем timestamp (первый сегмент)
	local timestamp_str = name_without_ext:match("^(%d+)_")
	if not timestamp_str then
		return nil
	end
	
	-- Извлекаем тип и название локации
	local after_timestamp = name_without_ext:match("^%d+_(.+)$")
	if not after_timestamp then
		return nil
	end
	
	local session_type, location_name = after_timestamp:match("^([^_]+)_(.+)$")
	if not session_type or not location_name then
		return nil
	end
	
	local timestamp = tonumber(timestamp_str)
	local date_str = timestamp and _os.date("%Y-%m-%d %H:%M:%S", timestamp)
	if not timestamp or not date_str then
		return nil
	end
	
	return {
		file = file_name,
		timestamp = timestamp,
		date = date_str,
		session_type = session_type,
		location_name = location_name,
	}
end

-- Добавление сообщения в текущую сессию
function ChatHistory:add_message(sender, message, channel)
	if not message or message == "" then
		return
	end
	
	-- Инициализируем кеш при первом сообщении (чтобы потом открытие view было быстрым)
	if not self._cache_initialized then
		self:init_cache_async()
	end
	
	local timestamp = _os.time()
	local message_entry = {
		timestamp = timestamp,
		time_str = _os.date("%H:%M:%S", timestamp),
		sender = sender or "",
		message = message,
		channel = channel or "Strike Team",
	}
	
	table.insert(self._current_session_messages, message_entry)
end

-- Начало новой сессии
function ChatHistory:start_session(session_type, location_name)
	-- Сохраняем предыдущую сессию если есть сообщения
	if #self._current_session_messages > 0 then
		self:save_current_session()
	end
	
	self._current_session_type = session_type
	self._current_session_name = location_name
	self._current_session_messages = {}
end

-- Сохранение текущей сессии
function ChatHistory:save_current_session()
	if #self._current_session_messages == 0 then
		return nil
	end
	
	if not self._current_session_type or not self._current_session_name then
		return nil
	end
	
	mkdir(self:get_path())
	
	local timestamp = tostring(_os.time())
	local file_name = string.format("%s_%s_%s.json", timestamp, self._current_session_type, self._current_session_name)
	local path = self:get_path() .. file_name
	
	local data = {
		session_type = self._current_session_type,
		location_name = self._current_session_name,
		message_count = #self._current_session_messages,
		messages = self._current_session_messages,
	}
	
	local ok, json_str = pcall(cjson.encode, data)
	if not ok then
		return nil
	end
	
	local file, err = _io.open(path, "w")
	if not file then
		return nil
	end
	file:write(json_str)
	file:close()
	
	-- Добавляем в кеш если он загружен
	if self._history_entries_cache ~= nil then
		self._history_entries_cache[#self._history_entries_cache + 1] = file_name
	end
	
	-- Очищаем кеш загруженных файлов чтобы новый файл загрузился свежим
	self._loaded_files_cache = {}
	
	self._last_save_time = _os.time()
	
	return file_name
end

-- Сохранение с очисткой текущего состояния
function ChatHistory:finalize_session()
	local saved_file = self:save_current_session()
	
	self._current_session_messages = {}
	self._current_session_type = nil
	self._current_session_name = nil
	
	return saved_file
end

-- Загрузка записи истории
function ChatHistory:load_history_entry(file_name)
	-- Проверяем кеш загруженных файлов
	if self._loaded_files_cache[file_name] then
		return self._loaded_files_cache[file_name]
	end
	
	local path = self:get_path() .. file_name
	local file, err = _io.open(path, "r")
	if not file then
		return nil
	end
	
	local json_str = file:read("*all")
	file:close()
	
	local ok, data = pcall(cjson.decode, json_str)
	if not ok then
		return nil
	end
	
	local file_info = self:parse_filename(file_name)
	if file_info then
		data.file = file_name
		data.date = file_info.date
		data.timestamp = file_info.timestamp
		data.session_type = file_info.session_type
		data.location_name = file_info.location_name
	end
	
	-- Сохраняем в кеш
	self._loaded_files_cache[file_name] = data
	
	return data
end

-- Получение списка записей истории
function ChatHistory:get_history_entries(scan_dir)
	-- Если кеш не инициализирован, инициализируем его один раз
	if self._history_entries_cache == nil then
		self._history_entries_cache = scandir(self:get_path())
	end
	
	-- Принудительное сканирование только если явно запрошено
	if scan_dir then
		self._history_entries_cache = scandir(self:get_path())
	end
	
	local entries = {}
	for _, file in ipairs(self._history_entries_cache) do
		if file:match("%.json$") then
			local file_info = self:parse_filename(file)
			if file_info then
				entries[#entries + 1] = file_info
			end
		end
	end
	
	-- Сортируем по дате (новые первыми)
	table.sort(entries, function(a, b)
		return a.timestamp > b.timestamp
	end)
	
	return entries
end

-- Удаление записи истории
function ChatHistory:delete_history_entry(file_name)
	local path = self:get_path() .. file_name
	
	if _os.remove(path) then
		-- Удаляем из кеша если он загружен
		if self._history_entries_cache ~= nil then
			local new_cache = {}
			for _, c in ipairs(self._history_entries_cache) do
				if c ~= file_name then
					new_cache[#new_cache + 1] = c
				end
			end
			self._history_entries_cache = new_cache
		end
		
		return true
	end
	
	return false
end

-- Получение текущих сообщений сессии
function ChatHistory:get_current_session_messages()
	return self._current_session_messages
end

-- Получение информации о текущей сессии
function ChatHistory:get_current_session_info()
	return {
		type = self._current_session_type,
		name = self._current_session_name,
		message_count = #self._current_session_messages,
	}
end

return ChatHistory

