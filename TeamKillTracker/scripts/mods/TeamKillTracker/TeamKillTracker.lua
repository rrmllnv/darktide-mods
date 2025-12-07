local mod = get_mod("TeamKillTracker")

local Breed = mod:original_require("scripts/utilities/breed")

local hud_elements = {
	{
		filename = "TeamKillTracker/scripts/mods/TeamKillTracker/HudElementPlayerStats",
		class_name = "HudElementPlayerStats",
		visibility_groups = {
			"alive",
		},
	},
}

mod.player_kills = {}
mod.player_damage = {}
mod.player_last_damage = {}
mod.killed_units = {}
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
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	return game_mode_name == "hub"
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
    mod.display_mode = mod:get("display_mode") or 1
    mod.hud_counter_mode = mod:get("hud_counter_mode") or 1
    mod.kills_color = mod:get("kills_color") or "white"
    mod.damage_color = mod:get("damage_color") or "orange"
    mod.last_damage_color = mod:get("last_damage_color") or "orange"
    mod.font_size = mod:get("font_size") or 16
    mod.show_background = mod:get("show_background") or 1
    mod.opacity = mod:get("opacity") or 100
end

mod.on_all_mods_loaded = function()
	recreate_hud()
end

mod.on_setting_changed = function()
    mod.display_mode = mod:get("display_mode") or 1
    mod.hud_counter_mode = mod:get("hud_counter_mode") or 1
    mod.show_team_summary = mod:get("show_team_summary") or 1
    mod.kills_color = mod:get("kills_color") or "white"
    mod.damage_color = mod:get("damage_color") or "orange"
    mod.last_damage_color = mod:get("last_damage_color") or "orange"
    mod.font_size = mod:get("font_size") or 16
    mod.show_background = mod:get("show_background") or 1
    mod.opacity = mod:get("opacity") or 100

    if mod.hud_element then
        mod.hud_element:set_dirty()
    end
end

function mod.on_game_state_changed(status, state_name)
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		recreate_hud()
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

-- Получаем игрока по юниту (проверяем всех игроков)
mod.player_from_unit = function(self, unit)
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

    local player = mod:player_from_unit(attacking_unit)
    if player then
        local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
        local breed_or_nil = unit_data_extension and unit_data_extension:breed()
        local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)
        
        if target_is_minion then
            local account_id = player:account_id() or player:name() or "Player"
            local unit_health_extension = ScriptUnit.has_extension(attacked_unit, "health_system")
            
            -- Логика подсчёта урона из Power_DI
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
                if not mod.killed_units[attacked_unit] then
                    mod.killed_units[attacked_unit] = true
                    mod.add_to_killcounter(account_id)
                end
                
            elseif attack_result == "damaged" then
                -- При обычном уроне просто берём значение damage
                health_damage = damage or 0
            end
            
            if health_damage > 0 then
                mod.add_to_damage(account_id, health_damage)
            end
        end
    end
end)

