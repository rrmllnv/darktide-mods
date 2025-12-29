local mod = get_mod("TeamKills")

mod.version = "2.0.0"

local Breed = mod:original_require("scripts/utilities/breed")
local Text = mod:original_require("scripts/utilities/ui/text")

mod:io_dofile("TeamKills/scripts/mods/TeamKills/TeamKills_constants")
mod:io_dofile("TeamKills/scripts/mods/TeamKills/TeamKills_notifications")
mod:io_dofile("TeamKills/scripts/mods/TeamKills/HUD/BossDamageTracker")
mod:io_dofile("TeamKills/scripts/mods/TeamKills/TeamKills_api")

mod.trackable_breeds = {}
for _, breed in ipairs(mod.melee_lessers or {}) do
	mod.trackable_breeds[breed] = true
end
for _, breed in ipairs(mod.ranged_lessers or {}) do
	mod.trackable_breeds[breed] = true
end
for _, breed in ipairs(mod.melee_elites or {}) do
	mod.trackable_breeds[breed] = true
end
for _, breed in ipairs(mod.ranged_elites or {}) do
	mod.trackable_breeds[breed] = true
end
for _, breed in ipairs(mod.specials or {}) do
	mod.trackable_breeds[breed] = true
end
for _, breed in ipairs(mod.disablers or {}) do
	mod.trackable_breeds[breed] = true
end
for _, breed in ipairs(mod.bosses or {}) do
	mod.trackable_breeds[breed] = true
end

mod.player_kills = {}
mod.player_damage = {}
mod.player_last_damage = {}
mod.killed_units = {}
mod.player_killstreak = {}
mod.player_killstreak_timer = {}
mod.killstreak_duration_seconds = mod.DEFAULT_KILLSTREAK_DURATION
mod.last_kill_time_by_category = {}
mod.last_enemy_interaction = {}
mod.boss_damage = {}
mod.boss_last_damage = {}
mod.kills_by_category = {}
mod.damage_by_category = {}
mod.saved_kills_by_category = {}
mod.saved_damage_by_category = {}
mod.saved_player_kills = {}
mod.saved_player_damage = {}
mod.display_mode = mod:get("opt_display_mode") or 1
mod.show_background = mod:get("opt_show_background") ~= false
mod.opacity = mod:get("opt_opacity") or 100
mod.highlighted_categories = {}
mod.highlighted_categories_by_category = {}

mod.player_shots_fired = {}
mod.player_shots_missed = {}
mod.player_head_shot_kill = {}

mod._cached_players = nil
mod._cached_players_time = 0
mod._players_cache_duration = 0.1

mod:add_require_path("TeamKills/scripts/mods/TeamKills/HUD/TeamKillsTracker")
mod:add_require_path("TeamKills/scripts/mods/TeamKills/HUD/ShotTracker")

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	local current_hud_elements = {
		{
			filename = "TeamKills/scripts/mods/TeamKills/HUD/TeamKillsTracker",
			class_name = "TeamKillsTracker",
			visibility_groups = {
				"alive",
			},
		},
	}
	
	if mod:get("opt_show_shot_tracker") ~= false then
		table.insert(current_hud_elements, {
			filename = "TeamKills/scripts/mods/TeamKills/HUD/ShotTracker",
			class_name = "ShotTracker",
			visibility_groups = {
				"alive",
			},
		})
	end
	
	for _, hud_element in ipairs(current_hud_elements) do
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

mod.get_kills_color_string = function()
	local color_name = mod.kills_color or "white"
	local rgb = mod.color_presets[color_name] or mod.color_presets["white"]
	return string.format("{#color(%d,%d,%d)}", rgb[1], rgb[2], rgb[3])
end

mod.get_damage_color_string = function()
	local color_name = mod.damage_color or "orange"
	local rgb = mod.color_presets[color_name] or mod.color_presets["orange"]
	return string.format("{#color(%d,%d,%d)}", rgb[1], rgb[2], rgb[3])
end

mod.get_last_damage_color_string = function()
	local color_name = mod.last_damage_color or "orange"
	local rgb = mod.color_presets[color_name] or mod.color_presets["orange"]
	return string.format("{#color(%d,%d,%d)}", rgb[1], rgb[2], rgb[3])
end

local function clear_saved_data()
	mod.saved_kills_by_category = {}
	mod.saved_damage_by_category = {}
	mod.saved_player_kills = {}
	mod.saved_player_damage = {}
	mod._cached_players = nil
	mod._cached_players_time = 0
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
    mod.last_kill_time_by_category = {}
    mod.highlighted_categories = {}
    mod.highlighted_categories_by_category = {}
    mod._cached_players = nil
    mod._cached_players_time = 0
    mod.killstreak_kills_by_category = {}
    mod.killstreak_damage_by_category = {}
    mod.display_killstreak_kills_by_category = {}
    mod.display_killstreak_damage_by_category = {}
    mod.boss_damage = {}
    mod.boss_last_damage = {}
    mod.player_shots_fired = {}
    mod.player_shots_missed = {}
    mod.player_head_shot_kill = {}
    mod.display_mode = mod:get("opt_display_mode") or 1
    mod.show_kills = mod:get("opt_show_kills") ~= false
    mod.show_total_damage = mod:get("opt_show_total_damage") ~= false
    mod.show_last_damage = mod:get("opt_show_last_damage") == true
    mod.show_killstreaks = mod:get("opt_show_killstreaks") ~= false
    local ks_diff = mod:get("opt_killstreak_difficulty") or 2
    if ks_diff == 1 then
        mod.killstreak_duration_seconds = mod.KILLSTREAK_DURATION_EASY
    elseif ks_diff == 2 then
        mod.killstreak_duration_seconds = mod.KILLSTREAK_DURATION_NORMAL
    elseif ks_diff == 3 then
        mod.killstreak_duration_seconds = mod.KILLSTREAK_DURATION_HARD
    end
    mod.kills_color = mod:get("opt_kills_color") or "white"
    mod.damage_color = mod:get("opt_damage_color") or "orange"
    mod.last_damage_color = mod:get("opt_last_damage_color") or "orange"
    mod.font_size = mod:get("opt_font_size") or 16
    mod.show_background = mod:get("opt_show_background") ~= false
    mod.opacity = mod:get("opt_opacity") or 100
    mod.show_killsboard = mod:get("opt_show_killsboard") ~= false
end

mod.on_all_mods_loaded = function()
	local package_manager = Managers.package
	if package_manager then
		if not package_manager:is_loading("packages/ui/views/store_item_detail_view/store_item_detail_view") and not package_manager:has_loaded("packages/ui/views/store_item_detail_view/store_item_detail_view") then
			package_manager:load("packages/ui/views/store_item_detail_view/store_item_detail_view", "TeamKills", nil, true)
		end
		if not package_manager:is_loading("packages/ui/views/end_player_view/end_player_view") and not package_manager:has_loaded("packages/ui/views/end_player_view/end_player_view") then
			package_manager:load("packages/ui/views/end_player_view/end_player_view", "TeamKills", nil, true)
		end
		if not package_manager:is_loading("packages/ui/views/inventory_view/inventory_view") and not package_manager:has_loaded("packages/ui/views/inventory_view/inventory_view") then
			package_manager:load("packages/ui/views/inventory_view/inventory_view", "TeamKills", nil, true)
		end
		if not package_manager:is_loading("packages/ui/views/inventory_weapons_view/inventory_weapons_view") and not package_manager:has_loaded("packages/ui/views/inventory_weapons_view/inventory_weapons_view") then
			package_manager:load("packages/ui/views/inventory_weapons_view/inventory_weapons_view", "TeamKills", nil, true)
		end
		if not package_manager:is_loading("packages/ui/hud/player_weapon/player_weapon") and not package_manager:has_loaded("packages/ui/hud/player_weapon/player_weapon") then
			package_manager:load("packages/ui/hud/player_weapon/player_weapon", "TeamKills", nil, true)
		end
	else
		mod:echo("[TeamKills] Warning: Package manager not found, icons may not display correctly")
	end
	recreate_hud()
	mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/TacticalOverlay")
	mod:register_killstreak_view()
end

mod.on_setting_changed = function()
    mod.display_mode = mod:get("opt_display_mode") or 1
    mod.show_kills = mod:get("opt_show_kills") ~= false
    mod.show_total_damage = mod:get("opt_show_total_damage") ~= false
    mod.show_last_damage = mod:get("opt_show_last_damage") == true
    mod.show_team_summary = mod:get("opt_show_team_summary") ~= false
    mod.show_killstreaks = mod:get("opt_show_killstreaks") ~= false
    local ks_diff = mod:get("opt_killstreak_difficulty") or 2
    if ks_diff == 1 then
        mod.killstreak_duration_seconds = mod.KILLSTREAK_DURATION_EASY
    elseif ks_diff == 2 then
        mod.killstreak_duration_seconds = mod.KILLSTREAK_DURATION_NORMAL
    elseif ks_diff == 3 then
        mod.killstreak_duration_seconds = mod.KILLSTREAK_DURATION_HARD
    end
    mod.kills_color = mod:get("opt_kills_color") or "white"
    mod.damage_color = mod:get("opt_damage_color") or "orange"
    mod.last_damage_color = mod:get("opt_last_damage_color") or "orange"
    mod.font_size = mod:get("opt_font_size") or 16
    mod.show_background = mod:get("opt_show_background") ~= false
    mod.opacity = mod:get("opt_opacity") or 100
    mod.show_killsboard = mod:get("opt_show_killsboard") ~= false
    local show_killsboard_end_view = mod:get("opt_show_killsboard_end_view") ~= false
    if mod.killsboard_show_in_end_view then
        mod.killsboard_show_in_end_view = show_killsboard_end_view
    end

    if mod.hud_element then
        mod.hud_element:set_dirty()
    end
end

local function save_mission_data()
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
	if status == "enter" then
		local game_mode_name = Managers.state and Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
		if game_mode_name == "hub" then
			recreate_hud()
			clear_saved_data()
			mod.killsboard_show_in_end_view = false
		elseif (state_name == 'GameplayStateRun' or state_name == "StateGameplay") and status == "enter" then
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
	
	if killstreak_before == 0 then
		mod.highlighted_categories = mod.highlighted_categories or {}
		if mod.highlighted_categories[account_id] then
			for breed_name, _ in pairs(mod.highlighted_categories[account_id]) do
				if mod.highlighted_categories_by_category and mod.highlighted_categories_by_category[breed_name] then
					mod.highlighted_categories_by_category[breed_name][account_id] = nil
					if not next(mod.highlighted_categories_by_category[breed_name]) then
						mod.highlighted_categories_by_category[breed_name] = nil
					end
				end
			end
		end
		mod.highlighted_categories[account_id] = {}
		mod.display_killstreak_kills_by_category = mod.display_killstreak_kills_by_category or {}
		mod.display_killstreak_kills_by_category[account_id] = {}
		mod.display_killstreak_damage_by_category = mod.display_killstreak_damage_by_category or {}
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
			if mod.killstreak_kills_by_category and mod.killstreak_kills_by_category[account_id] then
				mod.display_killstreak_kills_by_category = mod.display_killstreak_kills_by_category or {}
				mod.display_killstreak_kills_by_category[account_id] = mod.display_killstreak_kills_by_category[account_id] or {}
				for category_key, count in pairs(mod.killstreak_kills_by_category[account_id]) do
					mod.display_killstreak_kills_by_category[account_id][category_key] = count
				end
			end
			if mod.killstreak_damage_by_category and mod.killstreak_damage_by_category[account_id] then
				mod.display_killstreak_damage_by_category = mod.display_killstreak_damage_by_category or {}
				mod.display_killstreak_damage_by_category[account_id] = mod.display_killstreak_damage_by_category[account_id] or {}
				for category_key, damage in pairs(mod.killstreak_damage_by_category[account_id]) do
					mod.display_killstreak_damage_by_category[account_id][category_key] = damage
				end
			end
			
			mod.player_killstreak[account_id] = 0
			mod.player_killstreak_timer[account_id] = nil
			if mod.killstreak_damage_by_category and mod.killstreak_damage_by_category[account_id] then
				mod.killstreak_damage_by_category[account_id] = nil
			end
			if mod.killstreak_kills_by_category and mod.killstreak_kills_by_category[account_id] then
				mod.killstreak_kills_by_category[account_id] = nil
			end
		else
			mod.player_killstreak_timer[account_id] = timer
			if mod.killstreak_kills_by_category and mod.killstreak_kills_by_category[account_id] then
				mod.display_killstreak_kills_by_category = mod.display_killstreak_kills_by_category or {}
				mod.display_killstreak_kills_by_category[account_id] = mod.display_killstreak_kills_by_category[account_id] or {}
				for category_key, count in pairs(mod.killstreak_kills_by_category[account_id]) do
					mod.display_killstreak_kills_by_category[account_id][category_key] = count
				end
			end
			if mod.killstreak_damage_by_category and mod.killstreak_damage_by_category[account_id] then
				mod.display_killstreak_damage_by_category = mod.display_killstreak_damage_by_category or {}
				mod.display_killstreak_damage_by_category[account_id] = mod.display_killstreak_damage_by_category[account_id] or {}
				for category_key, damage in pairs(mod.killstreak_damage_by_category[account_id]) do
					mod.display_killstreak_damage_by_category[account_id][category_key] = damage
				end
			end
		end
	end
end

mod.get_killstreak_label = function(account_id)
	if not mod.show_killstreaks then
		return nil
	end

	local count = mod.player_killstreak[account_id]
	local min_display = mod:get("opt_killstreak_min_display") or 2

	if not count or count < min_display then
		return nil
	end

	return tostring(count)
end

local function is_valid_breed(breed_name)
	return breed_name and mod.trackable_breeds[breed_name] == true
end

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

mod.get_player_color = function(account_id)
	if not account_id or not Managers.player then
		return nil
	end
	
	local UISettings = require("scripts/settings/ui/ui_settings")
	local current_time = 0
	local success = false
	
	if Managers.time then
		success, current_time = pcall(function()
			return Managers.time:time("gameplay")
		end)
		if not success then
			current_time = 0
		end
	end
	
	if not mod._cached_players or (current_time - mod._cached_players_time) > mod._players_cache_duration then
		mod._cached_players = Managers.player:players()
		mod._cached_players_time = current_time
	end
	
	for _, player in pairs(mod._cached_players) do
		if player then
			local player_account_id = player:account_id() or player:name()
			if player_account_id == account_id then
				local slot = player:slot()
				if slot and UISettings.player_slot_colors[slot] then
					local color = UISettings.player_slot_colors[slot]
					return {color[2], color[3], color[4]}
				end
				break
			end
		end
	end
	
	return nil
end

mod.get_current_players = function()
	local current_players = {}
	if not Managers.player then
		return current_players
	end
	
	local current_time = 0
	local success = false
	
	if Managers.time then
		success, current_time = pcall(function()
			return Managers.time:time("gameplay")
		end)
		if not success then
			current_time = 0
		end
	end
	
	if not mod._cached_players or (current_time - mod._cached_players_time) > mod._players_cache_duration then
		mod._cached_players = Managers.player:players()
		mod._cached_players_time = current_time
	end
	
	for _, player in pairs(mod._cached_players) do
		if player then
			local account_id = player:account_id() or player:name()
			local character_name = player.character_name and player:character_name()
			if account_id then
				current_players[account_id] = character_name or player:name() or account_id
			end
		end
	end
	return current_players
end

local function is_overkill_session()
    local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
    return game_mode_name == "shooting_range" or game_mode_name == "hub"
end

mod:hook(CLASS.StatsManager, "record_private", function(func, self, stat_name, player, ...)
	func(self, stat_name, player, ...)
	
	if not player then
		return
	end
	
	local account_id = player:account_id() or player:name()
	if not account_id then
		return
	end
	
	mod.player_shots_fired = mod.player_shots_fired or {}
	mod.player_shots_missed = mod.player_shots_missed or {}
	mod.player_head_shot_kill = mod.player_head_shot_kill or {}
	
	if stat_name == "hook_ranged_attack_concluded" then
		local hit_minion, hit_weakspot, killing_blow, last_round_in_clip = ...
		
		mod.player_shots_fired[account_id] = (mod.player_shots_fired[account_id] or 0) + 1
		
		if not hit_minion then
			mod.player_shots_missed[account_id] = (mod.player_shots_missed[account_id] or 0) + 1
		end
		
		if killing_blow and hit_weakspot then
			mod.player_head_shot_kill[account_id] = (mod.player_head_shot_kill[account_id] or 0) + 1
		end
	end
end)

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result",
function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, ...)

    local player = mod.player_from_unit(attacking_unit)
    
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
            
            mod.last_enemy_interaction[attacked_unit] = attacking_unit
            
            local unit_health_extension = ScriptUnit.has_extension(attacked_unit, "health_system")
            
            local health_damage = 0
            
            if attack_result == "died" then
                local attacked_unit_damage_taken = unit_health_extension and unit_health_extension:damage_taken()
                local defender_max_health = unit_health_extension and unit_health_extension:max_health()
                local is_overkill = is_overkill_session()
                
                if defender_max_health and not is_overkill then
                    health_damage = defender_max_health - (attacked_unit_damage_taken or 0)
                elseif defender_max_health and is_overkill then
                    health_damage = defender_max_health - (attacked_unit_damage_taken or 0) + (damage or 0)
                else
                    health_damage = damage or 1
                end
                
                local breed_name = breed_or_nil and breed_or_nil.name
                local unit_key = attacked_unit
                
                if not mod.killed_units[unit_key] then
                    mod.killed_units[unit_key] = true
                    mod.add_to_killcounter(account_id)
                    mod.add_to_killstreak_counter(account_id)

                    if breed_name and is_valid_breed(breed_name) then
                        mod.kills_by_category = mod.kills_by_category or {}
                        mod.kills_by_category[account_id] = mod.kills_by_category[account_id] or {}
                        mod.kills_by_category[account_id][breed_name] = (mod.kills_by_category[account_id][breed_name] or 0) + 1
                        
                        mod.last_kill_time_by_category = mod.last_kill_time_by_category or {}
                        mod.last_kill_time_by_category[account_id] = mod.last_kill_time_by_category[account_id] or {}
                        mod.last_kill_time_by_category[account_id][breed_name] = Managers.time:time("gameplay")
                        
                        mod.killstreak_kills_by_category = mod.killstreak_kills_by_category or {}
                        mod.killstreak_kills_by_category[account_id] = mod.killstreak_kills_by_category[account_id] or {}
                        mod.killstreak_kills_by_category[account_id][breed_name] = (mod.killstreak_kills_by_category[account_id][breed_name] or 0) + 1
                    end
                end
                
            elseif attack_result == "damaged" then
                health_damage = damage or 0
            end
            
            if health_damage > 0 then
                mod.add_to_damage(account_id, health_damage)

                local breed_name = breed_or_nil and breed_or_nil.name
                if breed_name and is_valid_breed(breed_name) then
                    mod.damage_by_category = mod.damage_by_category or {}
                    mod.damage_by_category[account_id] = mod.damage_by_category[account_id] or {}
                    mod.damage_by_category[account_id][breed_name] = (mod.damage_by_category[account_id][breed_name] or 0) + math.floor(health_damage)
                    
                    mod.killstreak_damage_by_category = mod.killstreak_damage_by_category or {}
                    mod.killstreak_damage_by_category[account_id] = mod.killstreak_damage_by_category[account_id] or {}
                    mod.killstreak_damage_by_category[account_id][breed_name] = (mod.killstreak_damage_by_category[account_id][breed_name] or 0) + math.floor(health_damage)
                    
                    local current_killstreak = mod.player_killstreak[account_id] or 0
                    local timer_exists = mod.player_killstreak_timer and mod.player_killstreak_timer[account_id]
                    if current_killstreak > 0 and timer_exists then
                        mod.highlighted_categories = mod.highlighted_categories or {}
                        mod.highlighted_categories[account_id] = mod.highlighted_categories[account_id] or {}
                        mod.highlighted_categories[account_id][breed_name] = true
                        
                        mod.highlighted_categories_by_category = mod.highlighted_categories_by_category or {}
                        mod.highlighted_categories_by_category[breed_name] = mod.highlighted_categories_by_category[breed_name] or {}
                        mod.highlighted_categories_by_category[breed_name][account_id] = true
                    end
                end
                
                if breed_name then
                    local breed = breed_or_nil
                    if breed and breed.is_boss then
                        local clamped_amount = math.max(0, health_damage)
                        mod.boss_damage = mod.boss_damage or {}
                        mod.boss_damage[attacked_unit] = mod.boss_damage[attacked_unit] or {}
                        mod.boss_damage[attacked_unit][account_id] = (mod.boss_damage[attacked_unit][account_id] or 0) + clamped_amount
                        
                        mod.boss_last_damage = mod.boss_last_damage or {}
                        mod.boss_last_damage[attacked_unit] = mod.boss_last_damage[attacked_unit] or {}
                        mod.boss_last_damage[attacked_unit][account_id] = math.ceil(clamped_amount)
                    end
                end
            end
        end
    end
end)

mod.register_killstreak_view = function(self)
	self:add_require_path("TeamKills/scripts/mods/TeamKills/KillStreakBoard/View")
	self:add_require_path("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetDefinitions")
	self:add_require_path("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
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
			path = "TeamKills/scripts/mods/TeamKills/KillStreakBoard/View",
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
	self:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/View")
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

function mod.toggle_killsboard()
	local opt_show_killsboard = mod:get("opt_show_killsboard") ~= false
	if not opt_show_killsboard then
		return
	end
	
	local current_show_killsboard = mod.show_killsboard
	if current_show_killsboard == nil then
		current_show_killsboard = mod:get("opt_show_killsboard") ~= false
	end
	mod.show_killsboard = not current_show_killsboard
end

mod:hook(CLASS.EndView, "on_enter", function(func, self, ...)
	func(self, ...)
	save_mission_data()
	
	local show_killsboard_end_view = mod:get("opt_show_killsboard_end_view") ~= false
	if show_killsboard_end_view then
		mod:show_killstreak_view({end_view = true})
	end
end)

mod:hook(CLASS.EndView, "on_exit", function(func, self, ...)
	func(self, ...)
	mod:close_killstreak_view()
end)

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

