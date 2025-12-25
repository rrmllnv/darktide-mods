local mod = get_mod("TeamKills")

-- #####################################################################################################################
-- ##### API Functions for other mods #################################################################################
-- #####################################################################################################################

-- Вспомогательная функция для глубокого копирования таблиц
local function deep_copy_table(t)
	if type(t) ~= "table" then
		return t
	end
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = deep_copy_table(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- API: Получить убийства всех игроков
mod.get_player_kills = function()
	return deep_copy_table(mod.player_kills or {})
end

-- API: Получить урон всех игроков
mod.get_player_damage = function()
	return deep_copy_table(mod.player_damage or {})
end

-- API: Получить последний урон всех игроков
mod.get_player_last_damage = function()
	return deep_copy_table(mod.player_last_damage or {})
end

-- API: Получить убийства по категориям для всех игроков
mod.get_kills_by_category = function()
	return deep_copy_table(mod.kills_by_category or {})
end

-- API: Получить урон по категориям для всех игроков
mod.get_damage_by_category = function()
	return deep_copy_table(mod.damage_by_category or {})
end

-- API: Получить серии убийств всех игроков
mod.get_player_killstreak = function()
	return deep_copy_table(mod.player_killstreak or {})
end

-- API: Получить урон по боссам
mod.get_boss_damage = function()
	return deep_copy_table(mod.boss_damage or {})
end

-- API: Получить последний урон по боссам
mod.get_boss_last_damage = function()
	return deep_copy_table(mod.boss_last_damage or {})
end

-- API: Получить данные конкретного игрока
mod.get_player_data = function(account_id)
	if not account_id then
		return nil
	end
	
	return {
		kills = mod.player_kills and mod.player_kills[account_id] or 0,
		damage = mod.player_damage and mod.player_damage[account_id] or 0,
		last_damage = mod.player_last_damage and mod.player_last_damage[account_id] or 0,
		killstreak = mod.player_killstreak and mod.player_killstreak[account_id] or 0,
		kills_by_category = mod.kills_by_category and deep_copy_table(mod.kills_by_category[account_id] or {}) or {},
		damage_by_category = mod.damage_by_category and deep_copy_table(mod.damage_by_category[account_id] or {}) or {},
	}
end

-- API: Получить все данные мода
mod.get_all_data = function()
	return {
		player_kills = mod.get_player_kills(),
		player_damage = mod.get_player_damage(),
		player_last_damage = mod.get_player_last_damage(),
		kills_by_category = mod.get_kills_by_category(),
		damage_by_category = mod.get_damage_by_category(),
		player_killstreak = mod.get_player_killstreak(),
		boss_damage = mod.get_boss_damage(),
		boss_last_damage = mod.get_boss_last_damage(),
	}
end

-- API: Получить версию мода
mod.get_version = function()
	return mod.version or "unknown"
end

