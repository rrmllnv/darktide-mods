local mod = get_mod("TeamKills")

local Breed = mod:original_require("scripts/utilities/breed")

local hud_elements = {
	{
		filename = "TeamKills/scripts/mods/TeamKills/HudElementTeamKills",
		class_name = "HudElementTeamKills",
		visibility_groups = {
			"alive",
		},
	},
}

mod.player_kills = {}
mod.player_damage = {}
mod.player_last_damage = {}
mod.killed_units = {}
mod.player_killstreak = {}
mod.player_killstreak_timer = {}
mod.killstreak_duration_seconds = 2.5
mod.last_kill_time_by_category = {}  -- {account_id: {category_key: time}}
mod.last_enemy_interaction = {} -- Отслеживание последнего взаимодействия с врагом
mod.boss_damage = {} -- {[unit] = {[account_id] = damage}} - урон по боссам
mod.boss_last_damage = {} -- {[unit] = {[account_id] = last_damage}} - последний урон по боссам
-- Категории целей
mod.melee_lessers = {
	"chaos_newly_infected",
	"chaos_poxwalker",
	"chaos_mutated_poxwalker",
	"chaos_armored_infected",
	"cultist_melee",
	"cultist_ritualist",
	"renegade_melee",
}
mod.ranged_lessers = {
	"chaos_lesser_mutated_poxwalker",
	"cultist_assault",
	"renegade_assault",
	"renegade_rifleman",
}
mod.melee_elites = {
	"cultist_berzerker",
	"renegade_berzerker",
	"renegade_executor",
	"chaos_ogryn_bulwark",
	"chaos_ogryn_executor",
}
mod.ranged_elites = {
	"cultist_gunner",
	"renegade_gunner",
	"renegade_plasma_gunner",
	"renegade_radio_operator",
	"cultist_shocktrooper",
	"renegade_shocktrooper",
	"chaos_ogryn_gunner",
}
mod.specials = {
	"chaos_poxwalker_bomber",
	"renegade_grenadier",
	"cultist_grenadier",
	"renegade_sniper",
	"renegade_flamer",
	"renegade_flamer_mutator",
	"cultist_flamer",
}
mod.disablers = {
	"chaos_hound",
	"chaos_hound_mutator",
	"cultist_mutant",
	"cultist_mutant_mutator",
	"renegade_netgunner",
}
mod.bosses = {
	"chaos_beast_of_nurgle",
	"chaos_daemonhost",
	"chaos_spawn",
	"chaos_plague_ogryn",
	"chaos_plague_ogryn_sprayer",
	"renegade_captain",
	"cultist_captain",
	"renegade_twin_captain",
	"renegade_twin_captain_two",
}
mod.kills_by_category = {}
mod.damage_by_category = {}
mod.saved_kills_by_category = {}
mod.saved_damage_by_category = {}
mod.saved_player_kills = {}
mod.saved_player_damage = {}
mod.display_mode = mod:get("display_mode") or 1
mod.show_background = mod:get("show_background") or 1
mod.opacity = mod:get("opacity") or 100

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	for _, hud_element in ipairs(hud_elements) do
		if not table.find_by_key(elements, "class_name", hud_element.class_name) then
			table.insert(elements, {
				class_name = hud_element.class_name,
				filename = hud_element.filename,
				use_hud_scale = true,
				visibility_groups = hud_element.visibility_groups or {
					"alive",
				},
			})
		end
	end

	return func(self, elements, visibility_groups, params)
end)

mod._is_in_hub = function()
	if Managers.state and Managers.state.game_mode then
		local game_mode_name = Managers.state.game_mode:game_mode_name()
		return game_mode_name == "hub"
	end
	return false
end

-- Форматирование числа с разделителем тысяч (запятая)
mod.format_number = function(number)
	local num = math.floor(number)
	if num < 1000 then
		return tostring(num)
	end
	
	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

-- Предопределённые цвета
local color_presets = {
	white = {255, 255, 255},
	red = {255, 54, 36},        -- ui_red_light
	green = {61, 112, 55},      -- ui_green_medium
	blue = {30, 144, 255},      -- dodger_blue
	yellow = {226, 199, 126},   -- ui_terminal
	orange = {255, 183, 44},    -- ui_orange_light
	purple = {166, 93, 172},    -- ui_corruption_default
	cyan = {107, 209, 241},     -- ui_blue_light
	teal = {62, 143, 155},          -- ui_toughness_medium
	gold = {196, 195, 108},         -- ui_toughness_buffed
	purple_deep = {130, 66, 170},   -- ui_corruption_medium
	magenta = {102, 38, 98},        -- ui_ability_purple
	orange_dark = {148, 46, 14},    -- ui_orange_dark
	orange_medium = {245, 121, 21}, -- ui_orange_medium
	amber = {191, 151, 73},         -- ui_terminal_dark
	grey = {102, 102, 102},         -- ui_grey_medium
}

-- Получить строку цвета для убийств
mod.get_kills_color_string = function()
	local color_name = mod.kills_color or "white"
	local rgb = color_presets[color_name] or color_presets["white"]
	return string.format("{#color(%d,%d,%d)}", rgb[1], rgb[2], rgb[3])
end

-- Получить строку цвета для урона
mod.get_damage_color_string = function()
	local color_name = mod.damage_color or "orange"
	local rgb = color_presets[color_name] or color_presets["orange"]
	return string.format("{#color(%d,%d,%d)}", rgb[1], rgb[2], rgb[3])
end

mod.get_last_damage_color_string = function()
	local color_name = mod.last_damage_color or "orange"
	local rgb = color_presets[color_name] or color_presets["orange"]
	return string.format("{#color(%d,%d,%d)}", rgb[1], rgb[2], rgb[3])
end

local function recreate_hud()
    mod.player_kills = {}
    mod.player_damage = {}
    mod.player_last_damage = {}
    mod.killed_units = {}
    mod.player_killstreak = {}
    mod.player_killstreak_timer = {}
    mod.last_enemy_interaction = {}
    mod.kills_by_category = {}
    mod.damage_by_category = {}
    mod.last_kill_time_by_category = {}  -- {account_id: {category_key: time}}
    mod.highlighted_categories = {}  -- {account_id: {category_key: true}} - категории для подсветки
    mod.killstreak_kills_by_category = {}  -- {account_id: {category_key: count}} - убийства в текущем killstreak (рабочий)
    mod.killstreak_damage_by_category = {}  -- {account_id: {category_key: damage}} - урон в текущем killstreak (рабочий)
    mod.display_killstreak_kills_by_category = {}  -- {account_id: {category_key: count}} - убийства для отображения
    mod.display_killstreak_damage_by_category = {}  -- {account_id: {category_key: damage}} - урон для отображения
    mod.boss_damage = {}  -- {[unit] = {[account_id] = damage}} - урон по боссам
    mod.boss_last_damage = {}  -- {[unit] = {[account_id] = last_damage}} - последний урон по боссам
    mod.display_mode = mod:get("display_mode") or 1
    mod.hud_counter_mode = mod:get("hud_counter_mode") or 1
    mod.show_killstreaks = mod:get("show_killstreaks") or 1
    local ks_diff = mod:get("killstreak_difficulty") or 2
    if ks_diff == 1 then
        mod.killstreak_duration_seconds = 4
    elseif ks_diff == 2 then
        mod.killstreak_duration_seconds = 2.5
    elseif ks_diff == 3 then
        mod.killstreak_duration_seconds = 1
    end
    mod.kills_color = mod:get("kills_color") or "white"
    mod.damage_color = mod:get("damage_color") or "orange"
    mod.last_damage_color = mod:get("last_damage_color") or "orange"
    mod.font_size = mod:get("font_size") or 16
    mod.show_background = mod:get("show_background") or 1
    mod.opacity = mod:get("opacity") or 100
    mod.show_killsboard = mod:get("show_killsboard") or 1
end

mod.on_all_mods_loaded = function()
	-- Load packages for materials
	local package_manager = Managers.package
	if package_manager then
		if not package_manager:is_loading("packages/ui/views/store_item_detail_view/store_item_detail_view") and not package_manager:has_loaded("packages/ui/views/store_item_detail_view/store_item_detail_view") then
			package_manager:load("packages/ui/views/store_item_detail_view/store_item_detail_view", "TeamKills", nil, true)
		end
		if not package_manager:is_loading("packages/ui/views/end_player_view/end_player_view") and not package_manager:has_loaded("packages/ui/views/end_player_view/end_player_view") then
			package_manager:load("packages/ui/views/end_player_view/end_player_view", "TeamKills", nil, true)
		end
	end
	recreate_hud()
	mod:io_dofile("TeamKills/scripts/mods/TeamKills/killstreak/killstreak_tactical_overlay")
	mod:register_killstreak_view()
end

mod.on_setting_changed = function()
    mod.display_mode = mod:get("display_mode") or 1
    mod.hud_counter_mode = mod:get("hud_counter_mode") or 1
    mod.show_team_summary = mod:get("show_team_summary") or 1
    mod.show_killstreaks = mod:get("show_killstreaks") or 1
    local ks_diff = mod:get("killstreak_difficulty") or 2
    if ks_diff == 1 then
        mod.killstreak_duration_seconds = 4
    elseif ks_diff == 2 then
        mod.killstreak_duration_seconds = 2.5
    elseif ks_diff == 3 then
        mod.killstreak_duration_seconds = 1
    end
    mod.kills_color = mod:get("kills_color") or "white"
    mod.damage_color = mod:get("damage_color") or "orange"
    mod.last_damage_color = mod:get("last_damage_color") or "orange"
    mod.font_size = mod:get("font_size") or 16
    mod.show_background = mod:get("show_background") or 1
    mod.opacity = mod:get("opacity") or 100
    mod.show_killsboard = mod:get("show_killsboard") or 1
    local show_killsboard_end_view = mod:get("show_killsboard_end_view") or 1
    -- Обновляем флаг, если мы уже в EndView
    if mod.killsboard_show_in_end_view then
        mod.killsboard_show_in_end_view = (show_killsboard_end_view == 1)
    end

    if mod.hud_element then
        mod.hud_element:set_dirty()
    end
end

-- Функция для сохранения данных миссии (для показа в карусели)
local function save_mission_data()
	-- Сохраняем данные для использования в карусели EndView
	if mod.kills_by_category and next(mod.kills_by_category) then
		mod.saved_kills_by_category = {}
		for account_id, categories in pairs(mod.kills_by_category) do
			mod.saved_kills_by_category[account_id] = {}
			for category, count in pairs(categories) do
				mod.saved_kills_by_category[account_id][category] = count
			end
		end
	end
	if mod.damage_by_category and next(mod.damage_by_category) then
		mod.saved_damage_by_category = {}
		for account_id, categories in pairs(mod.damage_by_category) do
			mod.saved_damage_by_category[account_id] = {}
			for category, damage in pairs(categories) do
				mod.saved_damage_by_category[account_id][category] = damage
			end
		end
	end
	if mod.player_kills and next(mod.player_kills) then
		mod.saved_player_kills = {}
		for account_id, kills in pairs(mod.player_kills) do
			mod.saved_player_kills[account_id] = kills
		end
	end
	if mod.player_damage and next(mod.player_damage) then
		mod.saved_player_damage = {}
		for account_id, damage in pairs(mod.player_damage) do
			mod.saved_player_damage[account_id] = damage
		end
	end
end

function mod.on_game_state_changed(status, state_name)
	-- При переходе в хаб - полностью очищаем ВСЕ данные (включая saved и display)
	if status == "enter" then
		local game_mode_name = Managers.state and Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
		if game_mode_name == "hub" then
			-- Полностью очищаем ВСЕ данные при переходе в хаб
			mod.player_kills = {}
			mod.player_damage = {}
			mod.player_last_damage = {}
			mod.killed_units = {}
			mod.player_killstreak = {}
			mod.player_killstreak_timer = {}
			mod.last_enemy_interaction = {}
			mod.kills_by_category = {}
			mod.damage_by_category = {}
			mod.last_kill_time_by_category = {}
			mod.highlighted_categories = {}
			mod.killstreak_kills_by_category = {}
			mod.killstreak_damage_by_category = {}
			mod.display_killstreak_kills_by_category = {}
			mod.display_killstreak_damage_by_category = {}
			mod.boss_damage = {}
			mod.boss_last_damage = {}
			-- Очищаем также saved данные
			mod.saved_kills_by_category = {}
			mod.saved_damage_by_category = {}
			mod.saved_player_kills = {}
			mod.saved_player_damage = {}
			mod.killsboard_show_in_end_view = false
		elseif (state_name == 'GameplayStateRun' or state_name == "StateGameplay") and status == "enter" then
			-- При входе в новую миссию также очищаем данные
			recreate_hud()
			mod.killsboard_show_in_end_view = false
		end
	end
end

mod.add_to_killcounter = function(account_id)
    if not account_id then
		return
	end
	
    if not mod.player_kills[account_id] then
        mod.player_kills[account_id] = 0
	end
	
    mod.player_kills[account_id] = mod.player_kills[account_id] + 1
end

mod.add_to_damage = function(account_id, amount)
    if not account_id or not amount then
        return
    end
    if not mod.player_damage[account_id] then
        mod.player_damage[account_id] = 0
    end
    local clamped_amount = math.max(0, amount)
    mod.player_damage[account_id] = mod.player_damage[account_id] + clamped_amount
    mod.player_last_damage[account_id] = math.ceil(clamped_amount)
end

mod.add_to_killstreak_counter = function(account_id)
	if not account_id then
		return
	end

	local killstreak_before = mod.player_killstreak[account_id] or 0
	mod.player_killstreak[account_id] = killstreak_before + 1
	mod.player_killstreak_timer[account_id] = 0
	
	-- Если killstreak начал собираться заново (был 0, стал 1), очищаем только display массивы для нового подсчета
	-- Рабочие массивы НЕ очищаем - они продолжают накапливать урон
	if killstreak_before == 0 then
		mod.highlighted_categories[account_id] = {}
		-- Очищаем только display массивы при начале нового killstreak, чтобы начать новый подсчет для отображения
		mod.display_killstreak_kills_by_category[account_id] = {}
		mod.display_killstreak_damage_by_category[account_id] = {}
	end
end

mod.update_killstreak_timers = function(dt)
	if not dt then
		return
	end

	for account_id, timer in pairs(mod.player_killstreak_timer) do
		timer = timer + dt

		if timer > mod.killstreak_duration_seconds then
			mod.player_killstreak[account_id] = 0
			mod.player_killstreak_timer[account_id] = nil
			-- Очищаем только рабочие массивы при окончании killstreak, display остаются для отображения
			if mod.killstreak_damage_by_category[account_id] then
				mod.killstreak_damage_by_category[account_id] = nil
			end
			if mod.killstreak_kills_by_category[account_id] then
				mod.killstreak_kills_by_category[account_id] = nil
			end
			-- НЕ очищаем highlighted_categories - строки остаются подсвеченными
			-- НЕ очищаем display массивы - они остаются для отображения
		else
			mod.player_killstreak_timer[account_id] = timer
			-- Во время активного killstreak копируем данные из рабочих массивов в display
			if mod.killstreak_kills_by_category[account_id] then
				mod.display_killstreak_kills_by_category[account_id] = mod.display_killstreak_kills_by_category[account_id] or {}
				for category_key, count in pairs(mod.killstreak_kills_by_category[account_id]) do
					mod.display_killstreak_kills_by_category[account_id][category_key] = count
				end
			end
			if mod.killstreak_damage_by_category[account_id] then
				mod.display_killstreak_damage_by_category[account_id] = mod.display_killstreak_damage_by_category[account_id] or {}
				for category_key, damage in pairs(mod.killstreak_damage_by_category[account_id]) do
					mod.display_killstreak_damage_by_category[account_id][category_key] = damage
				end
			end
		end
	end
end

mod.get_killstreak_label = function(account_id)
	if mod.show_killstreaks ~= 1 then
		return nil
	end

	local count = mod.player_killstreak[account_id]

	if not count or count < 2 then
		return nil
	end

	-- Просто возвращаем число серии
	return tostring(count)
end

local function is_valid_breed(breed_name)
	if not breed_name then
		return false
	end

	local all_breeds = {}
	for _, breed in ipairs(mod.melee_lessers or {}) do
		all_breeds[breed] = true
	end
	for _, breed in ipairs(mod.ranged_lessers or {}) do
		all_breeds[breed] = true
	end
	for _, breed in ipairs(mod.melee_elites or {}) do
		all_breeds[breed] = true
	end
	for _, breed in ipairs(mod.ranged_elites or {}) do
		all_breeds[breed] = true
	end
	for _, breed in ipairs(mod.specials or {}) do
		all_breeds[breed] = true
	end
	for _, breed in ipairs(mod.disablers or {}) do
		all_breeds[breed] = true
	end
	for _, breed in ipairs(mod.bosses or {}) do
		all_breeds[breed] = true
	end

	return all_breeds[breed_name] == true
end

-- Получаем игрока по юниту (проверяем всех игроков)
mod.player_from_unit = function(unit)
	if unit then
		local player_manager = Managers.player
		local players = player_manager:players()
		for _, player in pairs(players) do
			if player and player.player_unit == unit then
				return player
			end
		end
	end
	return nil
end

-- Проверяем, локальная ли сессия (для корректного подсчёта overkill)
local function is_local_session()
    local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
    return game_mode_name == "shooting_range" or game_mode_name == "hub"
end

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result",
function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, ...)

    local player = mod.player_from_unit(attacking_unit)
    
    -- Если attacking_unit не игрок (например, при взрыве Pox Burster), 
    -- проверяем last_enemy_interaction для этого врага
    if not player and attacked_unit then
        if mod.last_enemy_interaction[attacked_unit] then
            local last_player_unit = mod.last_enemy_interaction[attacked_unit]
            player = mod.player_from_unit(last_player_unit)
        end
    end
    
    if player then
        local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
        local breed_or_nil = unit_data_extension and unit_data_extension:breed()
        local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)
        
        if target_is_minion then
            local account_id = player:account_id() or player:name() or "Player"
            
            -- Сохраняем последнее взаимодействие с врагом
            mod.last_enemy_interaction[attacked_unit] = attacking_unit
            
            local unit_health_extension = ScriptUnit.has_extension(attacked_unit, "health_system")
            
            -- Логика подсчёта урона
            local health_damage = 0
            
            if attack_result == "died" then
                -- При смерти: вычисляем здоровье, которое осталось у цели перед ударом
                local attacked_unit_damage_taken = unit_health_extension and unit_health_extension:damage_taken()
                local defender_max_health = unit_health_extension and unit_health_extension:max_health()
                local is_local = is_local_session()
                
                if defender_max_health and not is_local then
                    health_damage = defender_max_health - (attacked_unit_damage_taken or 0)
                elseif defender_max_health and is_local then
                    health_damage = defender_max_health - (attacked_unit_damage_taken or 0) + (damage or 0)
                else
                    health_damage = damage or 1
                end
                
                -- Килл: считаем один раз на юнит
                -- Используем комбинацию unit + breed_name для более надежного отслеживания
                local breed_name = breed_or_nil and breed_or_nil.name
                local unit_key = attacked_unit
                
                -- Дополнительная проверка: если unit уже был удален, используем breed_name как ключ
                if not mod.killed_units[unit_key] then
                    mod.killed_units[unit_key] = true
                    mod.add_to_killcounter(account_id)
                    mod.add_to_killstreak_counter(account_id)

                    if breed_name and is_valid_breed(breed_name) then
                        mod.kills_by_category = mod.kills_by_category or {}
                        mod.kills_by_category[account_id] = mod.kills_by_category[account_id] or {}
                        mod.kills_by_category[account_id][breed_name] = (mod.kills_by_category[account_id][breed_name] or 0) + 1
                        
                        -- Сохраняем время последнего убийства для этой категории
                        mod.last_kill_time_by_category[account_id] = mod.last_kill_time_by_category[account_id] or {}
                        mod.last_kill_time_by_category[account_id][breed_name] = Managers.time:time("gameplay")
                        
                        -- Всегда увеличиваем счетчик killstreak убийств в рабочем массиве
                        mod.killstreak_kills_by_category[account_id] = mod.killstreak_kills_by_category[account_id] or {}
                        mod.killstreak_kills_by_category[account_id][breed_name] = (mod.killstreak_kills_by_category[account_id][breed_name] or 0) + 1
                        
                        -- Если killstreak активен, добавляем категорию в массив для подсветки
                        local current_killstreak = mod.player_killstreak[account_id] or 0
                        if current_killstreak > 0 then
                            mod.highlighted_categories[account_id] = mod.highlighted_categories[account_id] or {}
                            mod.highlighted_categories[account_id][breed_name] = true
                        end
                    end
                end
                
            elseif attack_result == "damaged" then
                -- При обычном уроне просто берём значение damage
                health_damage = damage or 0
            end
            
            if health_damage > 0 then
                mod.add_to_damage(account_id, health_damage)

                local breed_name = breed_or_nil and breed_or_nil.name
                if breed_name and is_valid_breed(breed_name) then
                    mod.damage_by_category = mod.damage_by_category or {}
                    mod.damage_by_category[account_id] = mod.damage_by_category[account_id] or {}
                    mod.damage_by_category[account_id][breed_name] = (mod.damage_by_category[account_id][breed_name] or 0) + math.floor(health_damage)
                    
                    -- Всегда увеличиваем счетчик killstreak урона в рабочем массиве (будет скопирован в display во время активного killstreak)
                    mod.killstreak_damage_by_category = mod.killstreak_damage_by_category or {}
                    mod.killstreak_damage_by_category[account_id] = mod.killstreak_damage_by_category[account_id] or {}
                    mod.killstreak_damage_by_category[account_id][breed_name] = (mod.killstreak_damage_by_category[account_id][breed_name] or 0) + math.floor(health_damage)
                end
                
                -- Отслеживаем урон по боссам
                if breed_name then
                    local breed = breed_or_nil
                    if breed and breed.is_boss then
                        local clamped_amount = math.max(0, health_damage)
                        mod.boss_damage = mod.boss_damage or {}
                        mod.boss_damage[attacked_unit] = mod.boss_damage[attacked_unit] or {}
                        mod.boss_damage[attacked_unit][account_id] = (mod.boss_damage[attacked_unit][account_id] or 0) + clamped_amount
                        
                        -- Отслеживаем последний урон по боссам
                        mod.boss_last_damage = mod.boss_last_damage or {}
                        mod.boss_last_damage[attacked_unit] = mod.boss_last_damage[attacked_unit] or {}
                        mod.boss_last_damage[attacked_unit][account_id] = math.ceil(clamped_amount)
                    end
                end
            end
        end
    end
end)

-- Регистрация killstreak view
mod.register_killstreak_view = function(self)
	self:add_require_path("TeamKills/scripts/mods/TeamKills/killstreak/killstreak_view")
	self:add_require_path("TeamKills/scripts/mods/TeamKills/killstreak/killstreak_widget_definitions")
	self:add_require_path("TeamKills/scripts/mods/TeamKills/killstreak/killstreak_widget_settings")
	self:register_view({
		view_name = "killstreak_view",
		view_settings = {
			init_view_function = function (ingame_ui_context)
				return true
			end,
			class = "KillstreakView",
			disable_game_world = false,
			display_name = "Killstreak",
			game_world_blur = 0,
			load_always = true,
			load_in_hub = true,
			package = "packages/ui/views/options_view/options_view",
			path = "TeamKills/scripts/mods/TeamKills/killstreak/killstreak_view",
			state_bound = false,
			enter_sound_events = {},
			exit_sound_events = {},
			wwise_states = {},
		},
		view_transitions = {},
		view_options = {
			close_all = false,
			close_previous = false,
			close_transition_time = nil,
			transition_time = nil
		}
	})
	self:io_dofile("TeamKills/scripts/mods/TeamKills/killstreak/killstreak_view")
end

mod.show_killstreak_view = function(self, context)
	self:close_killstreak_view()
	local ui_manager = Managers.ui
	if ui_manager then
		ui_manager:open_view("killstreak_view", nil, false, false, nil, context or {}, {use_transition_ui = false})
	end
end

mod.close_killstreak_view = function(self)
	local ui_manager = Managers.ui
	if ui_manager and ui_manager:view_active("killstreak_view") and not ui_manager:is_view_closing("killstreak_view") then
		ui_manager:close_view("killstreak_view", true)
	end
end

mod.killstreak_opened = function(self)
	local ui_manager = Managers.ui
	return ui_manager and ui_manager:view_active("killstreak_view") and not ui_manager:is_view_closing("killstreak_view")
end

function mod.open_killsboard()
	-- Проверяем, находимся ли мы в хабе
	if not mod._is_in_hub() then
		-- return
	end
	
	-- Открываем или закрываем killstreak view
	if mod:killstreak_opened() then
		mod:close_killstreak_view()
	else
		mod:show_killstreak_view()
	end
end

-- Хук для отображения killstreak в конце миссии
mod:hook(CLASS.EndView, "on_enter", function(func, self, ...)
	func(self, ...)
	-- Сохраняем данные миссии для показа в карусели (НЕ очищаем здесь!)
	save_mission_data()
	
	local show_killsboard_end_view = mod:get("show_killsboard_end_view") or 1
	if show_killsboard_end_view == 1 then
		mod:show_killstreak_view({end_view = true})
	end
end)

-- Хук для скрытия killstreak при выходе из экрана окончания миссии
mod:hook(CLASS.EndView, "on_exit", function(func, self, ...)
	func(self, ...)
	mod:close_killstreak_view()
end)

-- Добавляем scenegraph для killsboard в EndPlayerView
mod:hook_require("scripts/ui/views/end_player_view/end_player_view_definitions", function(instance)
	local card_carousel = instance.scenegraph_definition.card_carousel
	if card_carousel then
		card_carousel.horizontal_alignment = "right"
		card_carousel.position = {-130, 350, 0}
	end
end)

mod:hook(CLASS.EndPlayerView, "on_enter", function(func, self, ...)
	func(self, ...)
	local ui_manager = Managers.ui
	if ui_manager then
		local view = ui_manager:view_instance("killstreak_view")
		if view then view:move_killsboard(0, -300) end
	end
end)

mod:hook(CLASS.EndPlayerView, "on_exit", function(func, self, ...)
	func(self, ...)
	local ui_manager = Managers.ui
	if ui_manager then
		local view = ui_manager:view_instance("killstreak_view")
		if view then view:move_killsboard(-300, 0) end
	end
end)

-- Хуки для отображения списка игроков и урона ниже полоски жизни босса
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementBossHealthSettings = require("scripts/ui/hud/elements/boss_health/hud_element_boss_health_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local hud_body_font_settings = UIFontSettings.hud_body or {}

local function get_font_size()
	return mod.font_size or mod:get("font_size") or 16
end

-- Добавляем виджеты для отображения списка игроков в каждую группу виджетов
-- Используем хук после того, как все виджеты созданы (включая RecolorBossHealthBars)
mod:hook_safe(CLASS.HudElementBossHealth, "_setup_widget_groups", function(self)
	local widget_groups = self._widget_groups
	if not widget_groups then
		return
	end
	
	-- Создаем виджеты для всех групп виджетов (включая созданные RecolorBossHealthBars)
	local font_size = get_font_size()
	local health_bar_size_y = HudElementBossHealthSettings.size[2]
	
	for widget_group_index, widget_group in ipairs(widget_groups) do
		if widget_group.health and not widget_group.boss_damage_list then
			local health_widget = widget_group.health
			
			-- Получаем offset health виджета из style для правильного позиционирования
			local health_bar_style = health_widget.style and health_widget.style.bar
			local health_bar_offset = health_bar_style and health_bar_style.offset or {0, -13, 4}
			
			-- Определяем размер полоски жизни (большая для первого, маленькая для остальных)
			local health_bar_size = widget_group_index == 1 and HudElementBossHealthSettings.size or HudElementBossHealthSettings.size_small
			
			-- Создаем виджет для отображения списка игроков и урона
			local damage_list_widget_definition = UIWidget.create_definition({
				{
					pass_type = "text",
					style_id = "text",
					value = "",
					value_id = "text",
					style = {
						font_size = font_size,
						font_type = hud_body_font_settings.font_type or "machine_medium",
						line_spacing = 1.2,
						horizontal_alignment = "left",
						vertical_alignment = "top",
						text_horizontal_alignment = "left",
						text_vertical_alignment = "top",
						text_color = {
							255,
							255,
							255,
							255,
						},
						drop_shadow = true,
						offset = {
							health_bar_offset[1],
							health_bar_offset[2] + health_bar_size_y + 45,
							10,
						},
						size = {
							250,
							200,
						},
					},
				},
			}, "health_bar")
			
			widget_group.boss_damage_list = self:_create_widget("boss_damage_list_" .. widget_group_index, damage_list_widget_definition)
			
			-- Учитываем offset виджета health, если он установлен (для виджетов созданных RecolorBossHealthBars)
			if health_widget.offset then
				widget_group.boss_damage_list.offset[1] = health_widget.offset[1]
				widget_group.boss_damage_list.offset[2] = health_widget.offset[2]
			end
		end
	end
end)

-- Обновляем виджеты со списком игроков и урона
mod:hook_safe(CLASS.HudElementBossHealth, "update", function(self, dt, t, ui_renderer, render_settings, input_service)
	local is_active = self._is_active
	
	if not is_active then
		return
	end
	
	local widget_groups = self._widget_groups
	local active_targets_array = self._active_targets_array
	local num_active_targets = #active_targets_array
	local num_health_bars_to_update = math.min(num_active_targets, self._max_health_bars)
	
	-- Создаем виджеты для всех групп виджетов, которые еще не имеют нашего виджета
	-- Это нужно на случай, если RecolorBossHealthBars добавил виджеты после нашего хука _setup_widget_groups
	local font_size = get_font_size()
	local health_bar_size_y = HudElementBossHealthSettings.size[2]
	
	for widget_group_index, widget_group in ipairs(widget_groups) do
		if widget_group.health and not widget_group.boss_damage_list then
			local health_widget = widget_group.health
			
			-- Получаем offset health виджета из style для правильного позиционирования
			local health_bar_style = health_widget.style and health_widget.style.bar
			local health_bar_offset = health_bar_style and health_bar_style.offset or {0, -13, 4}
			
			-- Определяем размер полоски жизни (большая для первого, маленькая для остальных)
			local health_bar_size = widget_group_index == 1 and HudElementBossHealthSettings.size or HudElementBossHealthSettings.size_small
			
			-- Создаем виджет для отображения списка игроков и урона
			local damage_list_widget_definition = UIWidget.create_definition({
				{
					pass_type = "text",
					style_id = "text",
					value = "",
					value_id = "text",
					style = {
						font_size = font_size,
						font_type = hud_body_font_settings.font_type or "machine_medium",
						line_spacing = 1.2,
						horizontal_alignment = "left",
						vertical_alignment = "top",
						text_horizontal_alignment = "left",
						text_vertical_alignment = "top",
						text_color = {
							255,
							255,
							255,
							255,
						},
						drop_shadow = true,
						offset = {
							health_bar_offset[1],
							health_bar_offset[2] + health_bar_size_y + 45,
							10,
						},
						size = {
							250,
							200,
						},
					},
				},
			}, "health_bar")
			
			widget_group.boss_damage_list = self:_create_widget("boss_damage_list_" .. widget_group_index, damage_list_widget_definition)
			
			-- Учитываем offset виджета health, если он установлен (для виджетов созданных RecolorBossHealthBars)
			if health_widget.offset then
				widget_group.boss_damage_list.offset[1] = health_widget.offset[1]
				widget_group.boss_damage_list.offset[2] = health_widget.offset[2]
			end
		end
	end
	
	for i = 1, num_health_bars_to_update do
		local widget_group_index = num_active_targets > 1 and i + 1 or i
		local widget_group = widget_groups[widget_group_index]
		local target = active_targets_array[i]
		local unit = target.unit
		
		if ALIVE[unit] and widget_group.boss_damage_list then
			local damage_widget = widget_group.boss_damage_list
			
			-- Обновляем offset виджета, если health виджет имеет offset (для виджетов созданных RecolorBossHealthBars)
			local health_widget = widget_group.health
			if health_widget and health_widget.offset then
				damage_widget.offset[1] = health_widget.offset[1]
				damage_widget.offset[2] = health_widget.offset[2]
			end
			
			-- Получаем данные об уроне по этому боссу
			local boss_damage_data = mod.boss_damage and mod.boss_damage[unit]
			
			if boss_damage_data and next(boss_damage_data) then
				-- Получаем список текущих игроков
				local current_players = {}
				if Managers.player then
					local players = Managers.player:players()
					for _, player in pairs(players) do
						if player then
							local account_id = player:account_id() or player:name()
							local character_name = player.character_name and player:character_name()
							if account_id then
								current_players[account_id] = character_name or player:name() or account_id
							end
						end
					end
				end
				
				-- Получаем данные о последнем уроне по этому боссу
				local boss_last_damage_data = mod.boss_last_damage and mod.boss_last_damage[unit]
				
				-- Формируем список игроков с уроном
				local players_with_damage = {}
				for account_id, damage in pairs(boss_damage_data) do
					local display_name = current_players[account_id]
					if display_name and damage > 0 then
						local last_damage = boss_last_damage_data and boss_last_damage_data[account_id] or 0
						table.insert(players_with_damage, {
							name = display_name,
							damage = damage,
							last_damage = last_damage,
							account_id = account_id
						})
					end
				end
				
				-- Сортируем по урону (больше сверху)
				table.sort(players_with_damage, function(a, b)
					return a.damage > b.damage
				end)
				
				-- Формируем текст
				local lines = {}
				local damage_color = mod.get_damage_color_string()
				local last_damage_color = mod.get_last_damage_color_string()
				local reset_color = "{#reset()}"
				
				for _, player in ipairs(players_with_damage) do
					local dmg = math.floor(player.damage or 0)
					local last_dmg = math.floor(player.last_damage or 0)
					local line = player.name .. ": " .. damage_color .. mod.format_number(dmg) .. reset_color
					if last_dmg > 0 then
						line = line .. " [" .. last_damage_color .. mod.format_number(last_dmg) .. reset_color .. "]"
					end
					table.insert(lines, line)
				end
				
				if #lines > 0 then
					damage_widget.content.text = table.concat(lines, "\n")
					damage_widget.visible = true
				else
					damage_widget.content.text = ""
					damage_widget.visible = false
				end
			else
				if damage_widget then
					damage_widget.content.text = ""
					damage_widget.visible = false
				end
			end
		end
	end
end)

-- Очищаем данные об уроне по боссу при завершении боя
mod:hook_safe(CLASS.HudElementBossHealth, "event_boss_encounter_end", function(self, unit, boss_extension)
	if mod.boss_damage and mod.boss_damage[unit] then
		mod.boss_damage[unit] = nil
	end
	if mod.boss_last_damage and mod.boss_last_damage[unit] then
		mod.boss_last_damage[unit] = nil
	end
end)


