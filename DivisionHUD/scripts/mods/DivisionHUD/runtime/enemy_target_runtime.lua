local mod = get_mod("DivisionHUD")

local EnemyDebuffs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/enemy_debuffs")
local BuffSettings = require("scripts/settings/buff/buff_settings")
local AttackSettings = require("scripts/settings/damage/attack_settings")
local HudUtils = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/util/hud_utils")

if type(EnemyDebuffs) ~= "table" then
	EnemyDebuffs = {}
end

local DEBUFF_STYLES = EnemyDebuffs.DEBUFF_STYLES or {}
local DEBUFFS = EnemyDebuffs.DEBUFFS or {}
local stat_buff_types = BuffSettings.stat_buff_types
local attack_results = AttackSettings.attack_results
local armor_type_string_lookup = {
	armored = "loc_weapon_stats_display_armored",
	berserker = "loc_weapon_stats_display_berzerker",
	disgustingly_resilient = "loc_weapon_stats_display_disgustingly_resilient",
	resistant = "loc_glossary_armour_type_resistant",
	super_armor = "loc_weapon_stats_display_super_armor",
	unarmored = "loc_weapon_stats_display_unarmored",
}

local BLACKLIST_BREEDS = {
	sand_vortex = true,
	nurgle_flies = true,
	attack_valkyrie = true,
}

mod.enemy_target_runtime_broadphase_results = nil
mod.enemy_target_runtime_state = nil
mod.enemy_target_runtime_health_samples = nil

local hit_state = {
	unit = nil,
	expires_at = 0,
}

local function _is_alive_unit(unit)
	return unit and HEALTH_ALIVE[unit] and Unit.alive(unit)
end

local function _setting_enabled(key, fallback)
	local settings = mod._settings
	local value = settings and settings[key]

	if value == false or value == 0 then
		return false
	end

	if value == true or value == 1 then
		return true
	end

	return fallback
end

local function _setting_number(key, fallback)
	local settings = mod._settings
	local value = settings and settings[key]

	if type(value) == "number" and value == value then
		return value
	end

	return fallback
end

local function _now()
	local t = HudUtils.safe_gameplay_time()

	if type(t) == "number" then
		return t
	end

	return 0
end

local function _get_breed_tags(unit)
	if not _is_alive_unit(unit) then
		return nil
	end

	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data_extension and unit_data_extension:breed()

	return breed and breed.tags or nil
end

local function _find_breed_category(unit)
	local tags = _get_breed_tags(unit) or {}

	if tags.horde or tags.roamer then
		return "horde"
	elseif tags.captain or tags.cultist_captain then
		return "captain"
	elseif tags.witch then
		return "witch"
	elseif tags.monster then
		return "monster"
	elseif tags.disabler then
		return "disabler"
	elseif tags.special and tags.sniper then
		return "sniper"
	elseif tags.elite and tags.far or tags.special and tags.far or tags.elite and tags.close then
		return "far"
	elseif tags.elite then
		return "elite"
	elseif tags.special then
		return "special"
	else
		return "enemy"
	end
end

local function _is_allowed_breed_type(breed_type)
	if breed_type == "monster" or breed_type == "captain" or breed_type == "witch" then
		return _setting_enabled("enemy_target_show_boss", true)
	elseif breed_type == "elite" then
		return _setting_enabled("enemy_target_show_elite", true)
	elseif breed_type == "special" or breed_type == "disabler" or breed_type == "sniper" or breed_type == "far" then
		return _setting_enabled("enemy_target_show_special", true)
	end

	return false
end

local function _resolve_side_system()
	local extension_manager = Managers.state and Managers.state.extension

	return extension_manager and extension_manager:system("side_system") or nil
end

local function _is_enemy_side(player_unit, unit, side_system)
	if not side_system or not player_unit or not unit then
		return false
	end

	local player_side = side_system.side_by_unit[player_unit]
	local target_side = side_system.side_by_unit[unit]

	if not player_side or not target_side then
		return false
	end

	local enemy_side_names = player_side:relation_side_names("enemy")

	for i = 1, #enemy_side_names do
		if enemy_side_names[i] == target_side:name() then
			return true
		end
	end

	return false
end

local function _is_valid_enemy_target(player_unit, unit, side_system)
	if not _is_alive_unit(unit) or unit == player_unit then
		return false
	end

	if not _is_enemy_side(player_unit, unit, side_system) then
		return false
	end

	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data_extension and unit_data_extension:breed()

	if not breed or BLACKLIST_BREEDS[breed.name] then
		return false
	end

	return ScriptUnit.has_extension(unit, "health_system") ~= nil
end

local function _is_allowed_enemy_target(player_unit, unit, side_system)
	if not _is_valid_enemy_target(player_unit, unit, side_system) then
		return false
	end

	local breed_type = _find_breed_category(unit)

	return _is_allowed_breed_type(breed_type)
end

local function _is_allowed_hit_target(unit)
	if not _is_alive_unit(unit) then
		return false
	end

	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data_extension and unit_data_extension:breed()

	if not breed or BLACKLIST_BREEDS[breed.name] then
		return false
	end

	if not ScriptUnit.has_extension(unit, "health_system") then
		return false
	end

	return _is_allowed_breed_type(_find_breed_category(unit))
end

local function _smart_targeting_aim_unit(player_unit, side_system)
	if not _is_alive_unit(player_unit) then
		return nil
	end

	local smart_targeting_extension = ScriptUnit.has_extension(player_unit, "smart_targeting_system")

	if not smart_targeting_extension then
		return nil
	end

	local targeting_data = smart_targeting_extension:targeting_data()
	local aim_unit = targeting_data and targeting_data.unit

	if _is_allowed_enemy_target(player_unit, aim_unit, side_system) then
		return aim_unit
	end

	return nil
end

local function _local_player_unit()
	local player_manager = Managers.player

	if not player_manager then
		return nil
	end

	local player = player_manager:local_player(1)

	return player and player.player_unit or nil
end

local function _is_local_player_attacker(attacking_unit)
	if not attacking_unit then
		return false
	end

	local local_player = Managers.player and Managers.player:local_player(1)

	if local_player and local_player.player_unit == attacking_unit then
		return true
	end

	local player_unit_spawn_manager = Managers.state and Managers.state.player_unit_spawn

	if not player_unit_spawn_manager then
		return false
	end

	local attacking_player = player_unit_spawn_manager:owner(attacking_unit)

	if not attacking_player or not local_player then
		return false
	end

	return attacking_player == local_player
end

local function _get_hit_target(player_unit, side_system)
	if not hit_state.unit then
		return nil
	end

	if not _is_allowed_enemy_target(player_unit, hit_state.unit, side_system) then
		hit_state.unit = nil
		hit_state.expires_at = 0

		return nil
	end

	if _now() > (hit_state.expires_at or 0) then
		hit_state.unit = nil
		hit_state.expires_at = 0

		return nil
	end

	return hit_state.unit
end

local function _on_attack_result(_, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike)
	if not _setting_enabled("enemy_target_enabled", true) then
		return
	end

	if not _setting_enabled("enemy_target_show_on_hit", true) then
		return
	end

	if type(damage) ~= "number" or damage <= 0 then
		return
	end

	if attack_result == attack_results.friendly_fire then
		return
	end

	if not _is_local_player_attacker(attacking_unit) then
		return
	end

	if not _is_allowed_hit_target(attacked_unit) then
		return
	end

	local hold_time = _setting_number("enemy_target_hold_time", 5)

	hit_state.unit = attacked_unit
	hit_state.expires_at = _now() + hold_time
end

local function _on_rpc_attack_result(_, channel_id, damage_profile_id, attacked_unit_id, attacked_unit_is_level_unit, attacking_unit_id, attack_direction, hit_world_position, hit_weakspot, damage, attack_result_id, attack_type_id, damage_efficiency_id, is_critical_strike)
	local unit_spawner_manager = Managers.state and Managers.state.unit_spawner

	if not unit_spawner_manager then
		return
	end

	local attacked_unit = attacked_unit_id and unit_spawner_manager:unit(attacked_unit_id, attacked_unit_is_level_unit)
	local attacking_unit = attacking_unit_id and unit_spawner_manager:unit(attacking_unit_id)
	local attack_result = attack_result_id and NetworkLookup.attack_results[attack_result_id]
	local attack_type = attack_type_id and NetworkLookup.attack_types[attack_type_id]
	local damage_efficiency = damage_efficiency_id and NetworkLookup.damage_efficiencies[damage_efficiency_id]

	_on_attack_result(nil, nil, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, is_critical_strike)
end

mod.enemy_target_runtime_on_attack_result = _on_attack_result
mod.enemy_target_runtime_on_rpc_attack_result = _on_rpc_attack_result

if not mod.enemy_target_runtime_add_attack_result_hooked then
	mod:hook_safe(CLASS.AttackReportManager, "add_attack_result", function(...)
		return mod.enemy_target_runtime_on_attack_result(...)
	end)

	mod.enemy_target_runtime_add_attack_result_hooked = true
end

if not mod.enemy_target_runtime_rpc_attack_result_hooked then
	mod:hook_safe(CLASS.AttackReportManager, "rpc_add_attack_result", function(...)
		return mod.enemy_target_runtime_on_rpc_attack_result(...)
	end)

	mod.enemy_target_runtime_rpc_attack_result_hooked = true
end

local function _collect_debuffs(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local buffs = buff_extension and buff_extension:buffs() or nil
	local keywords = buff_extension and buff_extension:keywords() or nil
	local active = {}
	local grouped_dot = {}
	local grouped_utility = {}
	local result = {}

	local function calc_stack_buff_percentage(val, stacks, stat_name)
		local stat_buff_type = stat_buff_types[stat_name]
		local perc = 0

		if stat_buff_type == "multiplicative_multiplier" then
			val = val - 1
			perc = (val * stacks) * 100
		elseif stat_buff_type == "additive_multiplier" then
			perc = (val * stacks) * 100
		end

		local nearest = math.floor((perc + 5) / 10) * 10

		if math.abs(perc - nearest) <= 1 then
			perc = nearest
		end

		return math.floor(perc * 10 + 0.5) * 0.1
	end

	local function resolve_value_text(entry)
		local stat_buffs = entry.stat_buffs
		local conditional_stat_buffs = entry.conditional_stat_buffs

		if stat_buffs then
			for stat_name, val in next, stat_buffs do
				if stat_name and val then
					return tostring(calc_stack_buff_percentage(val, entry.stacks or 1, stat_name)) .. "%"
				end
			end
		end

		if conditional_stat_buffs then
			for stat_name, val in next, conditional_stat_buffs do
				if stat_name and val then
					return tostring(calc_stack_buff_percentage(val, entry.stacks or 1, stat_name)) .. "%"
				end
			end
		end

		if entry.stacks and entry.stacks > 1 then
			return "x" .. tostring(entry.stacks)
		end

		return ""
	end

	local function add_active_entry(name, stacks, max_stacks, stat_buffs, conditional_stat_buffs, debuff_type)
		local debuff = DEBUFFS[name]

		if not debuff then
			return nil
		end

		local entry = {
			name = name,
			type = debuff_type or debuff.type,
			group = debuff.group,
			stacks = stacks or 1,
			max_stacks = max_stacks,
			stat_buffs = stat_buffs,
			conditional_stat_buffs = conditional_stat_buffs,
		}

		active[#active + 1] = entry

		return entry
	end

	local function combine_entries(entries)
		for i = 1, #entries do
			local entry = entries[i]
			local debuff = DEBUFFS[entry.name]
			local style = debuff and DEBUFF_STYLES[debuff.group] or nil
			local icon = style and style.icon or entry.name
			local target_map = entry.type == "dot" and grouped_dot or grouped_utility
			local existing = target_map[icon]

			if existing then
				existing.stacks = (existing.stacks or 0) + (entry.stacks or 0)
				existing.max_stacks = (existing.max_stacks or 0) + (entry.max_stacks or 0)
				existing.stat_buffs = existing.stat_buffs or entry.stat_buffs
				existing.conditional_stat_buffs = existing.conditional_stat_buffs or entry.conditional_stat_buffs
			else
				local combined_entry = {
					name = entry.name,
					type = entry.type,
					group = entry.group,
					stacks = entry.stacks,
					max_stacks = entry.max_stacks,
					stat_buffs = entry.stat_buffs,
					conditional_stat_buffs = entry.conditional_stat_buffs,
					combined = true,
				}

				target_map[icon] = combined_entry
				result[#result + 1] = combined_entry
			end
		end
	end

	if buffs then
		for i = 1, #buffs do
			local buff = buffs[i]
			local name = buff and buff:template_name()

			if name and DEBUFFS[name] then
				local stacks = buff.stack_count and buff:stack_count() or buff.stacks and buff:stacks() or 1
				local template = buff.template and buff:template() or nil
				local stat_buffs = template and template.stat_buffs or nil
				local conditional_stat_buffs = template and template.conditional_stat_buffs or nil
				local max_stacks = template and template.max_stacks or nil

				if name == "increase_damage_taken" then
					max_stacks = 1
				end

				add_active_entry(name, stacks, max_stacks, stat_buffs, conditional_stat_buffs, DEBUFFS[name].type)
			end
		end
	end

	if keywords and #keywords > 0 then
		for i = 1, #keywords do
			local name = keywords[i]

			if name and DEBUFFS[name] then
				add_active_entry(name, 1, nil, nil, nil, DEBUFFS[name].type)
			end
		end
	end

	combine_entries(active)

	table.sort(result, function(a, b)
		if a.type ~= b.type then
			return a.type == "dot"
		end

		if a.stacks ~= b.stacks then
			return a.stacks > b.stacks
		end

		return a.name < b.name
	end)

	for i = 1, #result do
		local entry = result[i]
		local debuff = DEBUFFS[entry.name]
		local style = debuff and DEBUFF_STYLES[debuff.group] or nil

		entry.icon = style and style.icon or "content/ui/materials/icons/generic/danger"
		entry.colour = style and style.colour or { 255, 255, 255, 255 }

		local localized_label = nil
		local loc_key = style and style.localization_key

		if loc_key then
			local loc_value = mod:localize(loc_key)

			if type(loc_value) == "string" and loc_value ~= "" and not string.find(loc_value, "^<") then
				localized_label = loc_value
			end
		end

		entry.label = localized_label or (style and style.label) or entry.group or entry.name
		entry.value_text = resolve_value_text(entry)
	end

	return result
end

local function _resolve_type_text(breed, breed_type, health_extension)
	local armor_type = breed and breed.armor_type
	local last_hit_zone_name = health_extension and health_extension.last_hit_zone_name and health_extension:last_hit_zone_name() or nil

	if last_hit_zone_name and breed and breed.hitzone_armor_override and breed.hitzone_armor_override[last_hit_zone_name] then
		armor_type = breed.hitzone_armor_override[last_hit_zone_name]
	end

	local armor_type_loc_string = armor_type and armor_type_string_lookup[armor_type] or nil
	local armor_type_text = armor_type_loc_string and Localize(armor_type_loc_string) or nil

	if type(armor_type_text) == "string" and armor_type_text ~= "" and not string.find(armor_type_text, "^<") then
		return armor_type_text
	end

	local localized_type = mod:localize("enemy_target_type_" .. breed_type)

	if type(localized_type) ~= "string" or localized_type == "" or string.find(localized_type, "^<unlocalized") then
		return breed_type
	end

	return localized_type
end

local function _build_result(unit)
	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	local health_extension = ScriptUnit.has_extension(unit, "health_system")

	if not unit_data_extension or not health_extension then
		return {
			active = false,
		}
	end

	local breed = unit_data_extension:breed()

	if not breed or BLACKLIST_BREEDS[breed.name] then
		return {
			active = false,
		}
	end

	local breed_type = _find_breed_category(unit)
	local type_text = _resolve_type_text(breed, breed_type, health_extension)

	local display_name = breed.display_name and Localize(breed.display_name) or ""

	if type(display_name) ~= "string" or display_name == "" or string.find(display_name, "^<") then
		display_name = breed.name or ""
	end

	return {
		active = true,
		unit = unit,
		name = display_name,
		type_text = type_text,
		breed = breed,
		breed_type = breed_type,
		health_current = health_extension:current_health(),
		health_max = health_extension:max_health(),
		health_fraction = health_extension:current_health_percent(),
		debuffs = _setting_enabled("enemy_target_show_debuffs", true) and _collect_debuffs(unit) or {},
	}
end

local function scan(player_unit)
	if not _setting_enabled("enemy_target_enabled", true) then
		hit_state.unit = nil
		hit_state.expires_at = 0

		return {
			active = false,
		}
	end

	if not _is_alive_unit(player_unit) then
		hit_state.unit = nil
		hit_state.expires_at = 0

		return {
			active = false,
		}
	end

	local side_system = _resolve_side_system()

	if not side_system then
		return {
			active = false,
		}
	end

	local target_unit = nil

	if _setting_enabled("enemy_target_show_on_hit", true) then
		target_unit = _get_hit_target(player_unit, side_system)
	end

	if not target_unit and _setting_enabled("enemy_target_show_on_hover", false) then
		target_unit = _smart_targeting_aim_unit(player_unit, side_system)
	end

	if not target_unit then
		return {
			active = false,
		}
	end

	return _build_result(target_unit)
end

local EnemyTargetRuntime = {
	scan = scan,
}

mod.enemy_target_runtime = EnemyTargetRuntime

return EnemyTargetRuntime
