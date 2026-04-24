local mod = get_mod("DivisionHUD")

if mod._divisionhud_debug_hooked then
	return mod
end

mod._divisionhud_debug_hooked = true

local BuffSettings = require("scripts/settings/buff/buff_settings")
local EnemyDebuffs = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/enemy_debuffs")

local buff_categories = BuffSettings.buff_categories
local DEBUG_DEBUFF_STYLES = type(EnemyDebuffs) == "table" and EnemyDebuffs.DEBUFF_STYLES or {}

local DEBUG_ALERT_STRIP = "DEBUG"
local DEBUG_ALERT_TEXT = "Enemies nearby"
local DEBUG_INVULNERABILITY_DURATION = 8
local DEBUG_TOUGHNESS_BASE_VALUE = 17000
local DEBUG_TOUGHNESS_BONUS_VALUE = 125

local debug_state = {
	invulnerability_start_t = nil,
	invulnerability_expire_t = nil,
	alert_instance_seq = 0,
	enemy_target_override = nil,
	expedition_salvage_override = nil,
}

local DEBUG_FAKE_BUFF_TEMPLATE = {
	name = "zealot_channel_toughness_bonus",
	buff_category = buff_categories.talents_secondary,
	hud_icon = "content/ui/textures/icons/buffs/hud/zealot/zealot_ability_bolstering_prayer",
	hud_icon_gradient_map = "content/ui/textures/color_ramps/talent_ability",
}

local function debug_enabled()
	local settings = mod._settings

	return type(settings) == "table" and settings.debug == true
end

local function gameplay_time()
	local Hu = mod.hud_utils

	if Hu and type(Hu.safe_time_for_alerts) == "function" then
		local t1 = Hu.safe_time_for_alerts()

		if type(t1) == "number" and t1 == t1 then
			return t1
		end
	end

	if Hu and type(Hu.safe_gameplay_time) == "function" then
		local t2 = Hu.safe_gameplay_time()

		if type(t2) == "number" and t2 == t2 then
			return t2
		end
	end

	local tm = Managers and Managers.time

	if tm and type(tm.has_timer) == "function" and tm:has_timer("gameplay") and type(tm.time) == "function" then
		local ok, t3 = pcall(function()
			return tm:time("gameplay")
		end)

		if ok and type(t3) == "number" and t3 == t3 then
			return t3
		end
	end

	return nil
end

local function clear_debug_state()
	debug_state.invulnerability_start_t = nil
	debug_state.invulnerability_expire_t = nil
	debug_state.enemy_target_override = nil
	debug_state.expedition_salvage_override = nil
end

local DEBUG_MAX_DEBUFF_ROWS = 9
local DEBUG_BREED_TYPES = { "elite", "special", "monster", "captain" }

local function _debug_random_value_text()
	local mode = math.random(1, 5)

	if mode == 1 then
		return string.format("x%d", math.random(2, 99))
	elseif mode == 2 then
		return string.format("+%d%%", math.random(5, 200))
	elseif mode == 3 then
		return string.format("+%d.%d%%", math.random(1, 99), math.random(0, 9))
	elseif mode == 4 then
		return string.format("x%d", math.random(2, 9))
	end

	return string.format("-%d%%", math.random(5, 75))
end

local function _shuffled_style_keys()
	local keys = {}

	for group_key in pairs(DEBUG_DEBUFF_STYLES) do
		keys[#keys + 1] = group_key
	end

	for i = #keys, 2, -1 do
		local j = math.random(1, i)

		keys[i], keys[j] = keys[j], keys[i]
	end

	return keys
end

local function _build_debug_enemy_target_data()
	local keys = _shuffled_style_keys()
	local total = math.min(#keys, DEBUG_MAX_DEBUFF_ROWS)
	local count = total > 0 and math.random(1, total) or 0
	local debuffs = {}

	for i = 1, count do
		local group_key = keys[i]
		local style = DEBUG_DEBUFF_STYLES[group_key]
		local label = nil
		local loc_key = style and style.localization_key

		if loc_key then
			local loc_value = mod:localize(loc_key)

			if type(loc_value) == "string" and loc_value ~= "" and not string.find(loc_value, "^<") then
				label = loc_value
			end
		end

		debuffs[#debuffs + 1] = {
			name = group_key,
			type = "dot",
			group = group_key,
			stacks = math.random(1, 5),
			icon = style and style.icon or "content/ui/materials/icons/generic/danger",
			colour = style and style.colour or { 255, 255, 255, 255 },
			label = label or (style and style.label) or group_key,
			value_text = _debug_random_value_text(),
		}
	end

	local breed_type = DEBUG_BREED_TYPES[math.random(1, #DEBUG_BREED_TYPES)]
	local health_max = math.random(5, 250) * 100
	local health_fraction = math.random(5, 100) / 100

	return {
		active = true,
		name = "DEBUG TARGET",
		type_text = breed_type,
		breed_type = breed_type,
		health_current = math.floor(health_max * health_fraction),
		health_max = health_max,
		health_fraction = health_fraction,
		debuffs = debuffs,
	}
end

mod.divisionhud_debug_apply_settings = function(setting_id)
	if setting_id ~= "debug" and setting_id ~= "divisionhud_reset_all_settings" then
		return
	end

	if not debug_enabled() then
		clear_debug_state()
	end
end

local function refresh_debug_state(game_t)
	local expire_t = debug_state.invulnerability_expire_t

	if type(expire_t) == "number" and type(game_t) == "number" and game_t >= expire_t then
		clear_debug_state()
	end
end

local function key_pressed(key_name)
	if type(key_name) ~= "string" or key_name == "" then
		return false
	end

	local key_index = Keyboard.button_index(key_name)

	if not key_index then
		return false
	end

	return Keyboard.pressed(key_index)
end

local function invulnerability_active(game_t)
	refresh_debug_state(game_t)

	return type(debug_state.invulnerability_start_t) == "number" and type(debug_state.invulnerability_expire_t) == "number"
end

local function invulnerability_progress(game_t)
	if not invulnerability_active(game_t) then
		return nil
	end

	local start_t = debug_state.invulnerability_start_t
	local expire_t = debug_state.invulnerability_expire_t
	local duration = expire_t - start_t

	if duration <= 0 then
		return nil
	end

	return math.clamp((expire_t - game_t) / duration, 0, 1)
end

local debug_fake_buff_instance = {}

function debug_fake_buff_instance:template()
	return DEBUG_FAKE_BUFF_TEMPLATE
end

function debug_fake_buff_instance:is_negative()
	return false
end

function debug_fake_buff_instance:has_hud()
	return true
end

function debug_fake_buff_instance:get_hud_data()
	local game_t = gameplay_time()
	local progress = game_t and invulnerability_progress(game_t) or nil

	if type(progress) ~= "number" then
		return nil
	end

	return {
		show = true,
		hud_icon = DEBUG_FAKE_BUFF_TEMPLATE.hud_icon,
		hud_icon_gradient_map = DEBUG_FAKE_BUFF_TEMPLATE.hud_icon_gradient_map,
		stack_count = nil,
		show_stack_count = false,
		duration_progress = progress,
		is_active = true,
		is_negative = false,
		hud_priority = 1,
	}
end

function debug_fake_buff_instance:duration()
	return DEBUG_INVULNERABILITY_DURATION
end

function debug_fake_buff_instance:duration_progress()
	local game_t = gameplay_time()

	return game_t and invulnerability_progress(game_t) or 0
end

mod.divisionhud_debug_update = function()
	if not debug_enabled() then
		clear_debug_state()
		return
	end

	local game_t = gameplay_time()

	if type(game_t) ~= "number" then
		return
	end

	refresh_debug_state(game_t)

	if key_pressed("numpad 1") and mod.alerts_enqueue_strip_body then
		debug_state.alert_instance_seq = debug_state.alert_instance_seq + 1

		mod.alerts_enqueue_strip_body(DEBUG_ALERT_STRIP, DEBUG_ALERT_TEXT, game_t, "debug", {
			instance_id = debug_state.alert_instance_seq,
		})
	end

	if key_pressed("numpad 2") then
		debug_state.invulnerability_start_t = game_t
		debug_state.invulnerability_expire_t = game_t + DEBUG_INVULNERABILITY_DURATION
	end

	if key_pressed("numpad 3") then
		if debug_state.enemy_target_override then
			debug_state.enemy_target_override = nil
		else
			debug_state.enemy_target_override = _build_debug_enemy_target_data()
		end
	end

	if key_pressed("numpad 4") then
		if debug_state.expedition_salvage_override then
			debug_state.expedition_salvage_override = nil
		else
			debug_state.expedition_salvage_override = math.random(1, 999999)
		end
	end
end

mod.divisionhud_debug_get_extra_buffs = function()
	if not debug_enabled() then
		return nil
	end

	local game_t = gameplay_time()

	if type(game_t) ~= "number" or not invulnerability_active(game_t) then
		return nil
	end

	return {
		debug_fake_buff_instance,
	}
end

mod.divisionhud_debug_get_timed_gold_bar_progress = function()
	if not debug_enabled() then
		return nil
	end

	local game_t = gameplay_time()

	if type(game_t) ~= "number" then
		return nil
	end

	return invulnerability_progress(game_t)
end

mod.divisionhud_debug_get_enemy_target_override = function()
	if not debug_enabled() then
		return nil
	end

	return debug_state.enemy_target_override
end

mod.divisionhud_debug_get_expedition_salvage_override = function()
	if not debug_enabled() then
		return nil
	end

	return debug_state.expedition_salvage_override
end

mod.divisionhud_debug_get_toughness_override = function()
	if not debug_enabled() then
		return nil
	end

	local game_t = gameplay_time()

	if type(game_t) ~= "number" or not invulnerability_active(game_t) then
		return nil
	end

	return {
		base_toughness_value = DEBUG_TOUGHNESS_BASE_VALUE,
		bonus_toughness_value = DEBUG_TOUGHNESS_BONUS_VALUE,
	}
end

return mod
