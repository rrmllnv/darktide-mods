local mod = get_mod("ModderTools")

mod._info = {
    title = "ModderTools",
    author = "Assistant",
    date = "2025/01/01",
    version = "1.0.0"
}
mod:info("Version " .. mod._info.version)

-- Список случайных имен для замены (из исходников Darktide)
local RANDOM_NAMES = {
    "Ackor",
    "Barbor",
    "Baudlarn",
    "Brack",
    "Candorick",
    "Claren",
    "Cockerill",
    "Corot",
    "Derlin",
    "Dickot",
    "Doran",
    "Dorfan",
    "Dorsworth",
    "Farridge",
    "Fascal",
    "Foronat",
    "Fusell",
    "Goyan",
    "Harken",
    "Haveloch",
    "Henam",
    "Hugot",
    "Jerican",
    "Keating",
    "Kradd",
    "Lamark",
    "Lukas",
    "Martack",
    "Mikel",
    "Montov",
    "Mussat",
    "Narvast",
    "Nura",
    "Nzoni",
    "Onceda",
    "Rossel",
    "Rudge",
    "Salcan",
    "Saldar",
    "Scottor",
    "Shaygor",
    "Shiller",
    "Skyv",
    "Smither",
    "Tademar",
    "Taur",
    "Tecker",
    "Tuttor",
    "Verbal",
    "Victor",
    "Villan",
    "Xavier",
    "Zapard",
    "Zek",
    "Erith",
    "Agda",
    "Ambre",
    "Amelia",
    "Avrilia",
    "Axella",
    "Beretille",
    "Blonthe",
    "Clea",
    "Coletta",
    "Constanze",
    "Dalilla",
    "Diana",
    "Doriana",
    "Edithia",
    "Eglantia",
    "Elodine",
    "Ephrael",
    "Felicia",
    "Genevieve",
    "Greyla",
    "Guendolys",
    "Guenhvya",
    "Guenievre",
    "Heinrike",
    "Helene",
    "Helmia",
    "Honorine",
    "Ines",
    "Iris",
    "Isaure",
    "Jacinta",
    "Josea",
    "Justine",
    "Kelvi",
    "Kerstin",
    "Kinnia",
    "Kline",
    "Lassana",
    "Leana",
    "Leatha",
    "Liari",
    "Lorette",
    "Lyta",
    "Maia",
    "Mallava",
    "Marakanthe",
    "Maylin",
    "Mejara",
    "Meliota",
    "Melisande",
    "Mira",
    "Mylene",
    "Nadia",
    "Nalana",
    "Natacha",
    "Ophelia",
    "Prothei",
    "Rosemonde",
    "Rosine",
    "Ruby",
    "Sanei",
    "Sarine",
    "Severa",
    "Silvana",
    "Undine",
    "Unkara",
    "Valleni",
    "Vissia",
    "Waynoka",
    "Yvette",
    "Zelie",
    "Zellith"
}

-- Кэш замененных имен: account_id -> random_name
mod._name_cache = {}

mod._account_cache = {}

local function preserve_local_player_identity_enabled()
	local v = mod:get("preserve_local_player_identity")

	return v ~= false and v ~= 0
end

local CONSOLE_PLATFORMS = {
	"steam",
	"xbox",
	"psn",
}

local WH40K_CONSOLE_ACCOUNT_BASES = {
	"SebastianYarrick",
	"GideonRavenor",
	"CiaphasCain",
	"SlyMarbo",
	"Malcador",
	"NorkDeddog",
	"PiousVorne",
	"Torquemada",
}

local function hash_string(seed_str)
	local h = 5381

	for i = 1, #seed_str do
		h = ((h * 33) + string.byte(seed_str, i)) % 4294967296
	end

	return h
end

local function deterministic_mix(seed, salt)
	return (seed * 1103515245 + salt * 2654435761 + 12345) % 4294967296
end

local function ensure_generated_console_account(cache_key)
	if cache_key == nil then
		return nil
	end

	local key = tostring(cache_key)
	local cached = mod._account_cache[key]

	if cached then
		return cached
	end

	local seed = hash_string(key)
	local plat_index = (deterministic_mix(seed, 11) % #CONSOLE_PLATFORMS) + 1
	local platform = CONSOLE_PLATFORMS[plat_index]
	local nb = #WH40K_CONSOLE_ACCOUNT_BASES
	local idx_a = (deterministic_mix(seed, 13) % nb) + 1
	local idx_b = (deterministic_mix(seed, 17) % nb) + 1

	if idx_b == idx_a then
		idx_b = (idx_a % nb) + 1
	end

	local base_a = WH40K_CONSOLE_ACCOUNT_BASES[idx_a]
	local base_b = WH40K_CONSOLE_ACCOUNT_BASES[idx_b]
	local num_a = deterministic_mix(seed, 19) % 9000 + 1000
	local num_b = deterministic_mix(seed, 23) % 99
	local account_name

	if platform == "steam" then
		account_name = string.lower(base_a) .. "_" .. tostring(num_a)
	elseif platform == "xbox" then
		account_name = base_a .. tostring(deterministic_mix(seed, 29) % 99999)
	else
		account_name = string.lower(base_a) .. "-" .. tostring(num_b) .. "_" .. string.lower(string.sub(base_b, 1, 6)) .. "_psn"
	end

	cached = {
		account_name = account_name,
		platform = platform,
	}
	mod._account_cache[key] = cached

	return cached
end

-- Генерация случайного имени
local function generate_random_name(account_id)
    -- Используем account_id как seed для детерминированной генерации
    -- Это гарантирует, что один и тот же игрок всегда получает одно и то же случайное имя
    local seed = 0
    local account_id_str = tostring(account_id)
    for i = 1, #account_id_str do
        seed = seed + string.byte(account_id_str, i)
    end

    math.randomseed(seed)
    local random_index = math.random(1, #RANDOM_NAMES)
    return RANDOM_NAMES[random_index]
end

mod.player_name_cache_key = function(player)
	if not player or player.__deleted then
		return nil
	end

	local ok_account, account_id = pcall(function()
		return player:account_id()
	end)

	if ok_account and account_id ~= nil then
		return account_id
	end

	if type(player.unique_id) == "function" then
		local ok_uid, unique_id = pcall(function()
			return player:unique_id()
		end)

		if ok_uid and unique_id ~= nil then
			return tostring(unique_id)
		end
	end

	local ok_peer, peer_id = pcall(function()
		return player:peer_id()
	end)

	local ok_lpid, local_player_id = pcall(function()
		return player:local_player_id()
	end)

	if ok_peer and peer_id ~= nil then
		if ok_lpid and local_player_id ~= nil then
			return tostring(peer_id) .. ":" .. tostring(local_player_id)
		end

		return peer_id
	end

	return nil
end

mod._substitution_allowed_for_random_names_key = function(cache_key)
	if not preserve_local_player_identity_enabled() then
		return true
	end

	if cache_key == nil then
		return true
	end

	local pm = Managers.player

	if not pm or not pm.local_player then
		return true
	end

	local lp = pm:local_player(1)

	if not lp or lp.__deleted then
		return true
	end

	local local_key = mod.player_name_cache_key(lp)

	if local_key == nil then
		return true
	end

	return tostring(cache_key) ~= tostring(local_key)
end

mod.is_local_human_player = function(player)
	if not player or type(player) ~= "table" or player.__deleted then
		return false
	end

	local pm = Managers.player

	if not pm or not pm.local_player then
		return false
	end

	local lp = pm:local_player(1)

	if not lp or lp.__deleted then
		return false
	end

	return lp == player
end

mod.get_player_name = function(account_id, original_name)
	if not mod:get("enable_random_names") then
		return original_name
	end

	if not mod._substitution_allowed_for_random_names_key(account_id) then
		return original_name
	end

	if not mod._name_cache[account_id] then
		mod._name_cache[account_id] = generate_random_name(account_id)
	end

	return mod._name_cache[account_id]
end

mod.resolve_substituted_player_account_info = function(player, account_info)
	if mod:get("enable_random_console_accounts") ~= true then
		return account_info
	end

	if preserve_local_player_identity_enabled() and mod.is_local_human_player(player) then
		return account_info
	end

	if not player or type(player) ~= "table" or player.__deleted then
		return account_info
	end

	local key = mod.player_name_cache_key(player)

	if key == nil then
		return account_info
	end

	local generated = ensure_generated_console_account(key)

	if not generated then
		return account_info
	end

	return {
		account_name = generated.account_name,
		platform = generated.platform,
	}
end

mod.resolve_substituted_player_display_name = function(player, original_name)
	if type(original_name) ~= "string" or original_name == "" then
		return original_name
	end

	if not player or type(player) ~= "table" or player.__deleted then
		return original_name
	end

	if preserve_local_player_identity_enabled() and mod.is_local_human_player(player) then
		return original_name
	end

	local key = mod.player_name_cache_key(player)

	if key == nil then
		return original_name
	end

	return mod.get_player_name(key, original_name)
end

-- Очистка кэша имен (при выходе из миссии)
mod.clear_account_cache = function()
	table.clear(mod._account_cache)
end

mod.clear_name_cache = function()
	table.clear(mod._name_cache)
	mod.clear_account_cache()
	mod:info("Name cache cleared")
end

-- Функция замены имени в тексте
mod.replace_name_in_text = function(text, account_id, original_player_name)
    if not text or not account_id then
        return text
    end

	if not mod._substitution_allowed_for_random_names_key(account_id) then
		return text
	end

    -- Если передано реальное имя игрока, используем его для замены
    if original_player_name and original_player_name ~= "" then
        local random_name = mod.get_player_name(account_id, original_player_name)
        if random_name ~= original_player_name then
            -- Заменяем имя игрока в тексте (с учетом возможного форматирования)
            local escaped_name = original_player_name:gsub("([%%%+%-%*%?%[%^%$%(%)])", "%%%1")
            return text:gsub(escaped_name, random_name)
        end
    else
        -- Если имя не передано, пытаемся заменить весь текст
        local random_name = mod.get_player_name(account_id, text)
        if random_name ~= text then
            return random_name
        end
    end

    return text
end

-- Элементы UI для модификации
mod._elements = {
    "team_panel",
    "nameplate"
}

-- Проверка, включена ли фича для определенного элемента
mod.is_enabled_feature = function(ref)
    return mod:is_enabled() and mod:get("enable_" .. ref)
end

-- Проверка, нужно ли заменять имена
mod.should_replace = function(ref)
    if mod.is_enabled_feature(ref) then
        return true
    end
    return false
end

-- ############################################################
-- Загрузка файлов элементов
-- ############################################################

for _, element in ipairs(mod._elements) do
    local path = "ModderTools/scripts/mods/ModderTools/elements/" .. element

    mod:io_dofile(path)
end

-- ############################################################
-- Очистка кэша при выходе из игры
-- ############################################################

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" and status == "exit" then
        mod.clear_name_cache()
    end
end

mod.on_setting_changed = function(id)
	if id == "enable_random_names" then
		if not mod:get("enable_random_names") then
			mod.clear_name_cache()
		end
	elseif id == "enable_random_console_accounts" then
		if not mod:get("enable_random_console_accounts") then
			mod.clear_account_cache()
		end
	end
end
