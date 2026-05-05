local mod = get_mod("RobocopHUD")

local EnemyDebuffs = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/config/enemy_debuffs")
local BuffSettings = require("scripts/settings/buff/buff_settings")

if type(EnemyDebuffs) ~= "table" then
	EnemyDebuffs = {}
end

local DEBUFF_STYLES = EnemyDebuffs.DEBUFF_STYLES or {}
local DEBUFFS = EnemyDebuffs.DEBUFFS or {}
local stat_buff_types = BuffSettings.stat_buff_types or {}
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

local function _is_alive_unit(unit)
	return unit and HEALTH_ALIVE[unit] and Unit.alive(unit)
end

local function _safe_number(value, fallback)
	if type(value) == "number" and value == value then
		return value
	end

	return fallback
end

local function _safe_string(value, fallback)
	if type(value) == "string" and value ~= "" then
		return value
	end

	return fallback
end

local function _current_gameplay_time()
	local time_manager = Managers and Managers.time

	if not time_manager or type(time_manager.time) ~= "function" then
		return 0
	end

	local ok, value = pcall(function()
		return time_manager:time("gameplay")
	end)

	if ok and type(value) == "number" and value == value then
		return value
	end

	return 0
end

local function _calc_stack_buff_percentage(value, stacks, stat_name)
	local stat_buff_type = stat_buff_types[stat_name]
	local percentage = 0

	if stat_buff_type == "multiplicative_multiplier" then
		value = value - 1
		percentage = value * stacks * 100
	elseif stat_buff_type == "additive_multiplier" then
		percentage = value * stacks * 100
	end

	local nearest = math.floor((percentage + 5) / 10) * 10

	if math.abs(percentage - nearest) <= 1 then
		percentage = nearest
	end

	return math.floor(percentage * 10 + 0.5) * 0.1
end

local function _resolve_value_text(entry)
	local stat_buffs = entry.stat_buffs
	local conditional_stat_buffs = entry.conditional_stat_buffs

	if stat_buffs then
		for stat_name, value in next, stat_buffs do
			if stat_name and value then
				return tostring(_calc_stack_buff_percentage(value, entry.stacks or 1, stat_name)) .. "%"
			end
		end
	end

	if conditional_stat_buffs then
		for stat_name, value in next, conditional_stat_buffs do
			if stat_name and value then
				return tostring(_calc_stack_buff_percentage(value, entry.stacks or 1, stat_name)) .. "%"
			end
		end
	end

	if entry.stacks and entry.stacks > 1 then
		return "x" .. tostring(entry.stacks)
	end

	return ""
end

local function _collect_debuffs(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local buffs = buff_extension and buff_extension:buffs() or nil
	local keywords = buff_extension and buff_extension:keywords() or nil
	local active = {}
	local grouped_dot = {}
	local grouped_utility = {}
	local result = {}

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

	local function iter_table_values(tbl, fn)
		if type(tbl) ~= "table" or type(fn) ~= "function" then
			return
		end

		local handled = {}

		for i = 1, #tbl do
			handled[i] = true
			fn(tbl[i], i)
		end

		for key, value in pairs(tbl) do
			if not handled[key] then
				fn(value, key)
			end
		end
	end

	if buffs then
		iter_table_values(buffs, function(buff)
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
		end)
	end

	if keywords then
		iter_table_values(keywords, function(value, key)
			local name = nil

			if type(value) == "string" then
				name = value
			elseif value == true and type(key) == "string" then
				name = key
			end

			if name and DEBUFFS[name] then
				add_active_entry(name, 1, nil, nil, nil, DEBUFFS[name].type)
			end
		end)
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
		local localized_label = nil
		local localization_key = style and style.localization_key

		entry.icon = style and style.icon or "content/ui/materials/icons/generic/danger"

		if localization_key then
			local loc_value = mod:localize(localization_key)

			if type(loc_value) == "string" and loc_value ~= "" and not string.find(loc_value, "^<") then
				localized_label = loc_value
			end
		end

		entry.label = localized_label or (style and style.label) or entry.group or entry.name
		entry.value_text = _resolve_value_text(entry)
		entry.colour = style and style.colour or { 255, 255, 255, 255 }
	end

	return result
end

local function _find_breed_category(unit)
	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data_extension and unit_data_extension:breed() or nil
	local tags = breed and breed.tags or nil

	if type(tags) ~= "table" then
		return "enemy"
	end

	if tags.monster then
		return "monster"
	end

	if tags.captain or tags.renegade_captain then
		return "captain"
	end

	if tags.cultist_captain then
		return "cultist_captain"
	end

	if tags.chaos_hound or tags.netgunner or tags.trapper or tags.disabler then
		return "disabler"
	end

	if tags.sniper then
		return "sniper"
	end

	if tags.witch then
		return "witch"
	end

	if tags.special then
		return "special"
	end

	if tags.elite then
		return "elite"
	end

	if tags.ranged then
		return "far"
	end

	if tags.horde or tags.trash or tags.melee then
		return "horde"
	end

	return "enemy"
end

local function _resolve_type_text(breed, breed_type, health_extension)
	local armor_type = breed and breed.armor_type or nil
	local last_hit_zone_name = health_extension and health_extension.last_hit_zone_name and health_extension:last_hit_zone_name() or nil

	if last_hit_zone_name and breed and breed.hitzone_armor_override and breed.hitzone_armor_override[last_hit_zone_name] then
		armor_type = breed.hitzone_armor_override[last_hit_zone_name]
	end

	local armor_type_loc_string = armor_type and armor_type_string_lookup[armor_type] or nil
	local armor_type_text = armor_type_loc_string and Localize(armor_type_loc_string) or nil

	if type(armor_type_text) == "string" and armor_type_text ~= "" and not string.find(armor_type_text, "^<") then
		return armor_type_text
	end

	local localized_type = mod:localize("enemy_target_type_" .. tostring(breed_type or "enemy"))

	if type(localized_type) ~= "string" or localized_type == "" or string.find(localized_type, "^<") then
		return tostring(breed_type or "enemy")
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

	local display_name = breed.display_name and Localize(breed.display_name) or ""

	if type(display_name) ~= "string" or display_name == "" or string.find(display_name, "^<") then
		display_name = breed.name or ""
	end

	local breed_type = _find_breed_category(unit)
	local type_text = _resolve_type_text(breed, breed_type, health_extension)
	local health_current = _safe_number(health_extension:current_health(), 0)
	local health_max = _safe_number(health_extension:max_health(), 0)
	local health_fraction = _safe_number(health_extension:current_health_percent(), 0)

	return {
		active = true,
		unit = unit,
		name = _safe_string(display_name, "UNKNOWN"),
		type_text = _safe_string(type_text, ""),
		breed_type = breed_type,
		health_current = health_current,
		health_max = health_max,
		health_fraction = math.clamp(health_fraction, 0, 1),
		health_percent_text = tostring(math.floor(math.clamp(health_fraction, 0, 1) * 100 + 0.5)) .. "%",
		debuffs = _collect_debuffs(unit),
		time = _current_gameplay_time(),
	}
end

local EnemyTargetRuntime = {}

EnemyTargetRuntime.scan = function(lock_state, has_los)
	local stage = lock_state and lock_state.stage or "IDLE"
	local unit = lock_state and lock_state.unit or nil

	if stage ~= "LOCK" or has_los == false or not _is_alive_unit(unit) then
		return {
			active = false,
		}
	end

	return _build_result(unit)
end

mod.enemy_target_runtime = EnemyTargetRuntime

return EnemyTargetRuntime
