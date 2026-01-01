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

-- Получение имени для игрока (случайное или оригинальное)
mod.get_player_name = function(account_id, original_name)
    if not mod:get("enable_random_names") then
        return original_name
    end

    -- Проверяем, есть ли уже сгенерированное имя для этого игрока
    if not mod._name_cache[account_id] then
        mod._name_cache[account_id] = generate_random_name(account_id)
    end

    return mod._name_cache[account_id]
end

-- Очистка кэша имен (при выходе из миссии)
mod.clear_name_cache = function()
    table.clear(mod._name_cache)
    mod:info("Name cache cleared")
end

-- Функция замены имени в тексте
mod.replace_name_in_text = function(text, account_id, original_player_name)
    if not text or not account_id then
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
    end
end
