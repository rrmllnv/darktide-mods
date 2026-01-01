local mod = get_mod("ModderTools")

mod._info = {
    title = "ModderTools",
    author = "Assistant",
    date = "2025/01/01",
    version = "1.0.0"
}
mod:info("Version " .. mod._info.version)

-- Список случайных имен для замены
local RANDOM_NAMES = {
    "PlayerOne", "ShadowHunter", "VoidWalker", "StormBringer", "BloodReaper",
    "IronFist", "SoulKeeper", "DeathDealer", "FlameBearer", "IceGuardian",
    "ThunderLord", "WindMaster", "EarthShaker", "WaterSpirit", "FireDemon",
    "DarkKnight", "LightBringer", "ChaosAgent", "OrderKeeper", "VoidSeeker",
    "StarGazer", "MoonHunter", "SunWarrior", "CometRider", "NebulaDrifter",
    "GalaxyGuard", "CosmicTraveler", "AetherWielder", "MysticSage", "ArcaneLord",
    "RuneMaster", "SpellWeaver", "PotionBrewer", "HerbGatherer", "CrystalMiner",
    "GemCutter", "MetalSmith", "LeatherWorker", "WoodCrafter", "StoneMason",
    "BoneCollector", "FleshRender", "SoulHarvester", "MindReader", "HeartSeeker",
    "SpiritCaller", "DemonBinder", "AngelSlayer", "GodKiller", "DevilHunter",
    "BeastMaster", "DragonRider", "PhoenixTamer", "GriffinLord", "UnicornKeeper",
    "WolfPack", "BearClan", "LionPride", "EagleFlight", "SharkSwarm",
    "TigerStrike", "PantherProwl", "FalconDive", "OwlWisdom", "RavenMystery",
    "CrowProphet", "HawkVision", "VultureScavenger", "CondorMajesty", "AlbatrossFreedom",
    "PenguinGuard", "SealHunter", "WalrusWarrior", "PolarBear", "ArcticFox",
    "SnowLeopard", "MountainGoat", "DesertScorpion", "JunglePython", "SavannaLion",
    "ForestDruid", "SwampWitch", "MountainDwarf", "CaveTroll", "UnderworldDemon",
    "SkySeraph", "SeaNymph", "RiverSpirit", "LakeGuardian", "OceanLord",
    "VolcanoForge", "CanyonEcho", "ValleyWhisper", "PeakSummit", "CliffDiver",
    "AbyssStalker", "DepthDiver", "SurfaceSurfer", "WaveRider", "TideTurner",
    "StormChaser", "LightningRod", "ThunderClap", "RainMaker", "CloudShaper",
    "WindWhisperer", "GustCaller", "BreezeDancer", "GaleForce", "HurricaneMaker",
    "EarthMender", "StoneHealer", "CrystalSinger", "GemWhisperer", "OreSeeker",
    "MetalMelter", "ForgeMaster", "AnvilLord", "HammerFall", "SwordSmith",
    "ShieldBearer", "ArmorWeaver", "HelmetMaker", "GauntletLord", "BootStomper",
    "CloakShadow", "RobeMystic", "TunicWarrior", "PantsNomad", "ShirtSailor",
    "HatWizard", "CrownKing", "MaskMystic", "VeilMystery", "CapeHero"
}

-- Кэш замененных имен: account_id -> random_name
mod._name_cache = {}

-- Генерация случайного имени
local function generate_random_name(account_id)
    -- Используем account_id как seed для детерминированной генерации
    -- Это гарантирует, что один и тот же игрок всегда получает одно и то же случайное имя
    local seed = 0
    for i = 1, #account_id do
        seed = seed + string.byte(account_id, i)
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
mod.replace_name_in_text = function(text, account_id)
    if not text or not account_id then
        return text
    end

    -- Ищем паттерн "Имя игрока" в тексте и заменяем
    -- Это простой подход - заменяем первое слово или всю строку если это имя
    local original_name = text:match("^([^\n]+)")
    if original_name then
        local random_name = mod.get_player_name(account_id, original_name)
        if random_name ~= original_name then
            return text:gsub(original_name, random_name, 1)
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
