local mod = get_mod("DivisionHUD")

if type(mod.enemy_target_runtime) == "table" then
	return mod.enemy_target_runtime
end

local EnemyDebuffs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/enemy_debuffs")
local BuffSettings = require("scripts/settings/buff/buff_settings")

if type(EnemyDebuffs) ~= "table" then
	EnemyDebuffs = {}
end

local DEBUFF_STYLES = EnemyDebuffs.DEBUFF_STYLES or {}
local DEBUFFS = EnemyDebuffs.DEBUFFS or {}
local stat_buff_types = BuffSettings.stat_buff_types
local armor_type_string_lookup = {
	armored = "loc_weapon_stats_display_armored",
	berserker = "loc_weapon_stats_display_berzerker",
	disgustingly_resilient = "loc_weapon_stats_display_disgustingly_resilient",
	resistant = "loc_glossary_armour_type_resistant",
	super_armor = "loc_weapon_stats_display_super_armor",
	unarmored = "loc_weapon_stats_display_unarmored",
}

local TRIGGER_HOLD_SECONDS = 5
local TRIGGER_PRIORITY = {
	"hover",
	"hit",
}

local BLACKLIST_BREEDS = {
	sand_vortex = true,
	nurgle_flies = true,
	attack_valkyrie = true,
}

local state = mod.enemy_target_runtime_state or {
	reasons = {},
}

mod.enemy_target_runtime_state = state

local function _is_alive_unit(unit)
	return unit and HEALTH_ALIVE[unit] and Unit.alive(unit)
end

local function _gameplay_time()
	local hud_utils = mod.hud_utils or {}

	if type(hud_utils.safe_gameplay_time) == "function" then
		local t = hud_utils.safe_gameplay_time()

		if type(t) == "number" and t == t then
			return t
		end
	end

	local time_manager = Managers and Managers.time

	if not time_manager or type(time_manager.time) ~= "function" then
		return nil
	end

	local ok_time, t = pcall(function()
		return time_manager:time("gameplay")
	end)

	if ok_time and type(t) == "number" and t == t then
		return t
	end

	return nil
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

local function _collect_debuffs(unit)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	local buffs = buff_extension and buff_extension:buffs() or nil
	local keywords = buff_extension and buff_extension:keywords() or nil
	local grouped = {}
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

	local function add_entry(name, stacks)
		local debuff = DEBUFFS[name]

		if not debuff then
			return
		end

		local style = DEBUFF_STYLES[debuff.group]

		if not style then
			return
		end

		local key = debuff.type .. ":" .. debuff.group
		local existing = grouped[key]

		if existing then
			existing.stacks = (existing.stacks or 0) + (stacks or 1)
			return
		end

		local entry = {
			name = name,
			type = debuff.type,
			group = debuff.group,
			icon = style.icon,
			colour = style.colour,
			label = style.label or debuff.group or name,
			stacks = stacks or 1,
		}

		grouped[key] = entry
		result[#result + 1] = entry
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

				add_entry(name, stacks)

				local debuff = DEBUFFS[name]
				local style = DEBUFF_STYLES[debuff.group]
				local key = debuff.type .. ":" .. debuff.group
				local existing = grouped[key]

				if existing then
					existing.stat_buffs = existing.stat_buffs or stat_buffs
					existing.conditional_stat_buffs = existing.conditional_stat_buffs or conditional_stat_buffs
				end
			end
		end
	end

	if keywords and #keywords > 0 then
		for i = 1, #keywords do
			local name = keywords[i]

			if name and DEBUFFS[name] then
				add_entry(name, 1)
			end
		end
	end

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
		debuffs = _collect_debuffs(unit),
	}
end

local function _set_trigger(reason, unit, now)
	if not reason or not unit or type(now) ~= "number" then
		return
	end

	local hold_seconds = math.max(1, _setting_number("enemy_target_hold_time", TRIGGER_HOLD_SECONDS))

	state.reasons[reason] = {
		unit = unit,
		expires_at = now + hold_seconds,
	}
end

local function _clear_trigger(reason)
	state.reasons[reason] = nil
end

local function _hover_target_unit(player_unit, side_system)
	local interactor_extension = ScriptUnit.has_extension(player_unit, "interactor_system")
	local interactor_target_unit = interactor_extension and interactor_extension:target_unit()
	local interactor_smart_tag_extension = interactor_target_unit and ScriptUnit.has_extension(interactor_target_unit, "smart_tag_system")

	if interactor_smart_tag_extension and _is_allowed_enemy_target(player_unit, interactor_target_unit, side_system) then
		return interactor_target_unit
	end

	local smart_targeting_extension = ScriptUnit.has_extension(player_unit, "smart_targeting_system")

	if smart_targeting_extension and smart_targeting_extension.force_update_smart_tag_targets then
		smart_targeting_extension:force_update_smart_tag_targets()
	end

	local targeting_data = smart_targeting_extension and smart_targeting_extension:smart_tag_targeting_data()
	local target_unit = targeting_data and targeting_data.unit

	if _is_allowed_enemy_target(player_unit, target_unit, side_system) then
		return target_unit
	end

	return nil
end

local function _cleanup_reasons(player_unit, side_system, now)
	local reasons = state.reasons

	for reason, entry in pairs(reasons) do
		local expires_at = entry and entry.expires_at
		local unit = entry and entry.unit
		local expired = type(expires_at) ~= "number" or type(now) ~= "number" or expires_at <= now

		if expired or not _is_allowed_enemy_target(player_unit, unit, side_system) then
			reasons[reason] = nil
		end
	end
end

local function _pick_trigger_unit(player_unit, side_system)
	local reasons = state.reasons

	for i = 1, #TRIGGER_PRIORITY do
		local reason = TRIGGER_PRIORITY[i]
		local entry = reasons[reason]
		local unit = entry and entry.unit

		if _is_allowed_enemy_target(player_unit, unit, side_system) then
			return unit
		end
	end

	return nil
end

local function scan(player_unit)
	if not _setting_enabled("enemy_target_enabled", true) then
		state.reasons = {}

		return {
			active = false,
		}
	end

	if not _is_alive_unit(player_unit) then
		return {
			active = false,
		}
	end

	local extension_manager = Managers.state and Managers.state.extension
	local side_system = extension_manager and extension_manager:system("side_system")

	if not side_system then
		return {
			active = false,
		}
	end

	local now = _gameplay_time()
	local hover_enabled = _setting_enabled("enemy_target_show_on_hover", true)
	local hover_unit = hover_enabled and _hover_target_unit(player_unit, side_system) or nil

	if hover_unit and type(now) == "number" then
		_set_trigger("hover", hover_unit, now)
	elseif not hover_enabled then
		_clear_trigger("hover")
	end

	if type(now) == "number" then
		_cleanup_reasons(player_unit, side_system, now)
	end

	local selected_unit = _pick_trigger_unit(player_unit, side_system)

	if not selected_unit then
		return {
			active = false,
		}
	end

	return _build_result(selected_unit)
end

local EnemyTargetRuntime = {
	scan = scan,
}

if mod.enemy_target_runtime_hooks_registered ~= true then
	mod.enemy_target_runtime_hooks_registered = true

	local function on_set_last_damaging_unit(self, last_damaging_unit)
		if not _setting_enabled("enemy_target_enabled", true) or not _setting_enabled("enemy_target_show_on_hit", true) then
			return
		end

		local local_player = Managers.player and Managers.player:local_player(1)
		local player_unit = local_player and local_player.player_unit
		local attacked_unit = self and self._unit
		local now = _gameplay_time()
		local extension_manager = Managers.state and Managers.state.extension
		local side_system = extension_manager and extension_manager:system("side_system")

		if not player_unit or not attacked_unit or not side_system or last_damaging_unit ~= player_unit or type(now) ~= "number" then
			return
		end

		if not _is_allowed_enemy_target(player_unit, attacked_unit, side_system) then
			return
		end

		_set_trigger("hit", attacked_unit, now)
	end

	mod:hook_safe("HealthExtension", "set_last_damaging_unit", on_set_last_damaging_unit)
	mod:hook_safe("HuskHealthExtension", "set_last_damaging_unit", on_set_last_damaging_unit)
end

mod.enemy_target_runtime = EnemyTargetRuntime

return EnemyTargetRuntime
