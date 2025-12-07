local mod = get_mod("FriendlyFireNotify")

local Breed = mod:original_require("scripts/utilities/breed")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UISettings = mod:original_require("scripts/settings/ui/ui_settings")
local Text = mod:original_require("scripts/utilities/ui/text")
local AttackSettings = require("scripts/settings/damage/attack_settings")
local AttackReportManager = mod:original_require("scripts/managers/attack_report/attack_report_manager")
local Damage = mod:original_require("scripts/utilities/attack/damage")
local ConstantElementNotificationFeed = mod:original_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed")
local attack_types = AttackSettings.attack_types
local attack_results = AttackSettings.attack_results
mod.friendly_fire_damage = {} -- account_id -> damage
mod.self_damage_total = 0 -- Общий урон от собственных взрывов
mod.friendly_fire_kills = {} -- account_id -> kills
mod.team_kills_total = 0
mod.pending_notifications = {} -- key -> payload для коалесса уведомлений
-- Цвета для отображения урона
mod.COLOR_DAMAGE = Color.ui_orange_light(255, true) -- цвет единичного урона
mod.COLOR_TOTAL_DAMAGE = Color.ui_orange_light(255, true) -- цвет суммарного урона (любого)
mod.COLOR_PLAYER_TOTAL = Color.ui_orange_light(255, true) -- цвет общего урона от игрока
mod.COLOR_TEAM_TOTAL = Color.ui_orange_light(255, true) -- цвет общего урона от команды
mod.COLOR_BACKGROUND = Color.terminal_corner_selected(60, true) -- цвет фона уведомления
-- Настройки времени
mod.DEFAULT_NOTIFICATION_COALESCE_TIME = 3
mod.DEFAULT_NOTIFICATION_DURATION_TIME = 8
mod.settings = {}
local NotificationFeed = nil
mod.DEBUG = false

local function apply_notification_duration(duration)
	if not NotificationFeed or not NotificationFeed._notification_templates or not NotificationFeed._notification_templates.custom then
		return
	end

	local new_time = duration or mod.DEFAULT_NOTIFICATION_DURATION_TIME
	NotificationFeed._notification_templates.custom.total_time = new_time

	if NotificationFeed._notifications then
		for _, notification in ipairs(NotificationFeed._notifications) do
			notification.total_time = new_time
		end
	end
end

local function refresh_settings()
	local min_threshold = tonumber(mod:get("min_damage_threshold")) or 0
	local show_total = mod:get("show_total_damage")
	local coalesce_time = tonumber(mod:get("notification_coalesce_time")) or mod.DEFAULT_NOTIFICATION_COALESCE_TIME
	local note_time = tonumber(mod:get("notification_duration_time")) or mod.DEFAULT_NOTIFICATION_DURATION_TIME
	local bg_setting = mod:get("notification_background_color")
	local bg_color = (bg_setting and Color[bg_setting]) and Color[bg_setting](60, true) or mod.COLOR_BACKGROUND

	mod.settings = {
		min_damage_threshold = min_threshold,
		show_total_damage = show_total ~= false,
		notification_coalesce_time = coalesce_time,
		notification_duration_time = note_time,
		notification_background_color = bg_color,
	}

	apply_notification_duration(note_time)
end

local function reset_stats()
	mod.friendly_fire_damage = {}
	mod.self_damage_total = 0
	mod.friendly_fire_kills = {}
	mod.team_kills_total = 0
	mod.pending_notifications = {}
end

mod.on_all_mods_loaded = function()
	reset_stats()
	refresh_settings()
end

mod.on_setting_changed = function(setting_id)
	if setting_id == "min_damage_threshold"
		or setting_id == "show_total_damage"
		or setting_id == "notification_coalesce_time"
		or setting_id == "notification_duration_time"
		or setting_id == "notification_background_color"
	then
		refresh_settings()
	end
end

mod:hook(ConstantElementNotificationFeed, "_generate_notification_data", function(func, self, message_type, data)
	local notification_data = func(self, message_type, data)

	if message_type == "custom" and notification_data and data then
		if data.use_player_portrait then
			notification_data.use_player_portrait = true
			notification_data.player = data.player
		end

		if data.item then
			notification_data.item = data.item
		end
	end

	return notification_data
end)

mod:hook_safe(ConstantElementNotificationFeed, "_event_player_authenticated", function(self)
	NotificationFeed = self
	apply_notification_duration(mod.settings.notification_duration_time)
end)

function mod.on_game_state_changed(status, state_name)
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		reset_stats()
		refresh_settings()
	end
end

local function format_number(number)
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

local function loc(key)
	local value = mod:localize(key, "%s") -- передаем плейсхолдер, чтобы не падало форматирование локализации
	if value and value ~= "" and not string.find(value, "^<") then
		return value
	end
	return key or ""
end

local function safe_format(template, fallback, ...)
	local t = template or fallback or "%s"
	local ok, result = pcall(string.format, tostring(t), ...)
	if ok then
		return result
	end

	local ok_fallback, result_fallback = pcall(string.format, tostring(fallback or "%s"), ...)
	if ok_fallback then
		return result_fallback
	end

	return tostring(fallback or "")
end

local PROFILE_EXCEPTIONS = {
	-- Бочки
	fire_barrel_explosion = true, -- дальний радиус бочки
	fire_barrel_explosion_close = true, -- ближний радиус бочки
	barrel_explosion_close = true, -- ближний радиус (нейм другой схемы)
	barrel_explosion = true, -- дальний радиус (нейм другой схемы)
	
	-- Горячие лужи/поджоги
	liquid_area_fire_burning = true,
	liquid_area_fire_burning_barrel = true, -- горящая лужа от бочки
	flame_grenade_liquid_area_fire_burning = true,
	grenadier_liquid_fire_burning = true,
	cultist_flamer_liquid_fire_burning = true,
	renegade_flamer_liquid_fire_burning = true,
	-- Взрывун (poxburster)
	poxwalker_explosion_close = true, -- ближний радиус
	poxwalker_explosion = true, -- дальний радиус
	-- Ранец огнемета
	flamer_backpack_explosion = true,
	flamer_backpack_explosion_close = true,
	interrupted_flamer_backpack_explosion = true, -- детон при прерывании
	interrupted_flamer_backpack_explosion_close = true, -- детон при прерывании (ближний)
}

local function now()
	if Managers.time and Managers.time:has_timer("gameplay") then
		return Managers.time:time("gameplay")
	end
	return os.clock()
end

local function resolve_source_text(buffer_data)
	local damage_profile = buffer_data and buffer_data.damage_profile

	if damage_profile and damage_profile.name then
		local profile_name = damage_profile.name

		if PROFILE_EXCEPTIONS[profile_name] then
			return loc(profile_name)
		end

		return profile_name
	end

	local attack_type = buffer_data and buffer_data.attack_type

	if attack_type then
		return tostring(attack_type)
	end

	return ""
end

local function make_damage_phrase(amount)
	local damage_value = Text.apply_color_to_text(format_number(amount), mod.COLOR_DAMAGE)
	local localization_manager = Managers.localization
	local language = localization_manager and localization_manager:language() or "en"

	if language == "ru" then
		local n = math.abs(math.floor(amount or 0))
		local last_two = n % 100
		local last = n % 10
		local word_key

		if last_two >= 11 and last_two <= 14 then
			word_key = "friendly_fire_damage_word_other"
		elseif last == 1 then
			word_key = "friendly_fire_damage_word_one"
		else
			word_key = "friendly_fire_damage_word_other"
		end

		local word = loc(word_key)
		return safe_format("%s %s", "%s %s", damage_value, word)
	else
		local damage_suffix = loc("friendly_fire_damage_suffix")
		return safe_format(damage_suffix, "%s damage", damage_value)
	end
end

local function show_friendly_fire_kill_notification(player_name, total_killer_kills, team_total_kills, notification_player, portrait_player)
	local message_name = player_name or loc("friendly_fire_unknown_player")
	if message_name and not string.find(message_name, "{#") then
		message_name = Text.apply_color_to_text(message_name, Color.ui_orange_light(255, true))
	end

	local line1_template = loc("friendly_fire_kill_line1_ally")
	local line1 = safe_format(line1_template, "Player %s killed you", tostring(message_name or ""))

	local killer_total_value = Text.apply_color_to_text(format_number(total_killer_kills or 0), Color.ui_orange_light(255, true)) or format_number(total_killer_kills or 0)
	local line2_template = loc("friendly_fire_kill_total")
	local line2 = safe_format(line2_template, "total %s", tostring(killer_total_value or "0"))

	local team_total_value = Text.apply_color_to_text(format_number(team_total_kills or 0), Color.ui_orange_light(255, true)) or format_number(team_total_kills or 0)
	local line3_template = loc("friendly_fire_kill_team_total")
	local line3 = safe_format(line3_template, "Team total kills %s", tostring(team_total_value or "0"))

	if Managers.event then
		local local_player = notification_player or (Managers.player and Managers.player:local_player(1))
		local portrait_target = portrait_player or local_player
		local profile = portrait_target and portrait_target:profile()
		local frame_item = profile and profile.loadout and profile.loadout.slot_portrait_frame

		local notification_data = {
			show_shine = false,
			icon = "content/ui/materials/base/ui_portrait_frame_base",
			icon_size = "portrait_frame",
			line_1 = line1,
			line_2 = line2,
			line_3 = line3,
			color = mod.COLOR_BACKGROUND,
		}

		local has_portrait = portrait_target and profile

		if has_portrait then
			notification_data.use_player_portrait = true
			notification_data.player = portrait_target
		end

		if frame_item then
			notification_data.item = frame_item
		end

		Managers.event:trigger(
			"event_add_notification_message",
			"custom",
			notification_data,
			nil,
			UISoundEvents.notification_matchmaking_failed
		)
	end
end

local function total_friendly_fire_all()
	local total = 0
	for _, value in pairs(mod.friendly_fire_damage) do
		local numeric = tonumber(value) or 0
		if numeric > 0 then
			total = total + numeric
		end
	end
	return total
end

local function show_friendly_fire_notification(player_name, damage_amount, total_damage, is_self_damage, source_text, notification_player, portrait_player, team_total_damage)
	local min_damage_threshold = mod.settings.min_damage_threshold or 0
	if damage_amount < min_damage_threshold then
		return
	end
	
	local show_total = mod.settings.show_total_damage ~= false
	local show_team_total = mod.settings.show_team_total_damage ~= false
	local message
	local damage_line = make_damage_phrase(damage_amount)
	if is_self_damage then
		local self_template = loc("friendly_fire_line1_self")
		message = safe_format(self_template, "You damaged yourself")
	else
		local unknown_name = loc("friendly_fire_unknown_player")
		local name = player_name or unknown_name
		if name and not string.find(name, "{#") then
			name = Text.apply_color_to_text(name, Color.ui_orange_light(255, true))
		end
		local ally_template = loc("friendly_fire_line1_ally")
		message = safe_format(ally_template, "Player %s damaged you", tostring(name or unknown_name))
	end
	if source_text and source_text ~= "" then
		local source_suffix = loc("friendly_fire_source_suffix")
		damage_line = safe_format("%s " .. source_suffix, "%s (%s)", damage_line, tostring(source_text))
	end
	
	local line2 = damage_line
	local line3 = ""
	local line4 = ""

	local function background_color()
		return mod.settings.notification_background_color or mod.COLOR_BACKGROUND
	end

	if show_total and total_damage and total_damage > 0 then
		local total_value = Text.apply_color_to_text(format_number(total_damage or 0), mod.COLOR_PLAYER_TOTAL) or format_number(total_damage or 0)
		local total_template = loc("friendly_fire_total_line")
		line3 = safe_format(total_template, "Total damage from player: %s", tostring(total_value or "0"))
	end

	if not is_self_damage then
		local allies_total = team_total_damage or 0

		if show_team_total and allies_total > 0 then
			local allies_value = Text.apply_color_to_text(format_number(allies_total or 0), mod.COLOR_TEAM_TOTAL) or format_number(allies_total or 0)
				local team_template = loc("friendly_fire_team_total")
			line4 = safe_format(team_template, "Team total damage: %s", tostring(allies_value or "0"))
		end
	end
	
	if Managers.event then
		local local_player = notification_player or (Managers.player and Managers.player:local_player(1))
		local portrait_target = portrait_player or local_player

		local profile = portrait_target and portrait_target:profile()
		local frame_item = profile and profile.loadout and profile.loadout.slot_portrait_frame

		local notification_data = {
			show_shine = false,
			icon = "content/ui/materials/base/ui_portrait_frame_base",
			icon_size = "large_item",
			line_1 = message,
			line_2 = line2,
			line_3 = line3,
			line_4 = line4,
			color = background_color(),
		}

		local has_portrait = portrait_target and profile

		if has_portrait then
			notification_data.use_player_portrait = true
			notification_data.player = portrait_target
		end

		if frame_item then
			notification_data.item = frame_item
		end

		Managers.event:trigger(
			"event_add_notification_message",
			"custom",
			notification_data,
			nil,
			UISoundEvents.notification_matchmaking_failed
		)
	end
end

local function queue_friendly_fire_notification(account_id, damage_amount, total_damage, player_name, is_self_damage, source_text, notification_player, attacker_player, team_total_damage)
	local key = table.concat({
		is_self_damage and "self" or (account_id or "unknown"),
		source_text or "",
	}, "|")

	local entry = mod.pending_notifications[key]
	if not entry then
		entry = {
			damage = 0,
			player_name = player_name,
			account_id = account_id,
			is_self_damage = is_self_damage,
			source_text = source_text,
			notification_player = notification_player,
			attacker_player = attacker_player,
		}
		mod.pending_notifications[key] = entry
	end

	entry.damage = (entry.damage or 0) + (damage_amount or 0)
	entry.total_damage = total_damage
	entry.team_total_damage = team_total_damage
	entry.player_name = player_name or entry.player_name
	entry.notification_player = notification_player or entry.notification_player
	entry.attacker_player = attacker_player or entry.attacker_player
	entry.last_update = now()
end

mod.update = function()
	if not next(mod.pending_notifications) then
		return
	end

	local t = now()
	local coalesce_time = mod.settings.notification_coalesce_time or mod.DEFAULT_NOTIFICATION_COALESCE_TIME

	for key, entry in pairs(mod.pending_notifications) do
		if entry.last_update and t - entry.last_update >= coalesce_time then
			show_friendly_fire_notification(
				entry.player_name,
				entry.damage,
				entry.total_damage,
				entry.is_self_damage,
				entry.source_text,
				entry.notification_player,
				entry.attacker_player,
				entry.team_total_damage
			)

			mod.pending_notifications[key] = nil
		end
	end
end

mod.add_friendly_fire_damage = function(account_id, amount, player_name, is_self_damage, source_text, notification_player, attacker_player)
	if not amount then
		return
	end
	
	local clamped_amount = math.max(0, amount)
		local safe_player_name = player_name or mod:localize("friendly_fire_unknown_player") or "friendly_fire_unknown_player"
		local safe_account_id = account_id or mod:localize("friendly_fire_unknown_account") or "friendly_fire_unknown_account"
	local safe_source = source_text or ""
	
	if is_self_damage then
		mod.self_damage_total = mod.self_damage_total + clamped_amount
		queue_friendly_fire_notification(nil, clamped_amount, mod.self_damage_total, nil, true, safe_source, notification_player, attacker_player, nil)
	else
		if not mod.friendly_fire_damage[safe_account_id] then
			mod.friendly_fire_damage[safe_account_id] = 0
		end
		local old_total = mod.friendly_fire_damage[safe_account_id]
		mod.friendly_fire_damage[safe_account_id] = old_total + clamped_amount
		local allies_total = total_friendly_fire_all()
		
		queue_friendly_fire_notification(
			safe_account_id,
			clamped_amount,
			mod.friendly_fire_damage[safe_account_id],
			safe_player_name,
			false,
			safe_source,
			notification_player,
			attacker_player,
			allies_total
		)
	end
end

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

mod:hook_safe(AttackReportManager, "_process_attack_result", function(self, buffer_data)
	local attacked_unit = buffer_data.attacked_unit
	local attacking_unit = buffer_data.attacking_unit
	local attack_result = buffer_data.attack_result
	local attack_type = buffer_data.attack_type
	local damage = buffer_data.damage

	local player_unit_spawn_manager = Managers.state and Managers.state.player_unit_spawn
	local attacked_player = player_unit_spawn_manager and attacked_unit and player_unit_spawn_manager:owner(attacked_unit)
	local local_player = Managers.player and Managers.player:local_player(1)
	local source_text = resolve_source_text(buffer_data)

	if not attacked_player or not local_player or attacked_player ~= local_player then
		return
	end

	if not damage or damage <= 0 then
		return
	end

	-- resolve owner
	local resolved_owner_unit = attacking_unit

	if not resolved_owner_unit and attacking_unit then
		local AttackingUnitResolver = mod:original_require("scripts/utilities/attack/attacking_unit_resolver")
		resolved_owner_unit = AttackingUnitResolver.resolve(attacking_unit)
	end

	if resolved_owner_unit and resolved_owner_unit == attacked_unit then
		mod.add_friendly_fire_damage(nil, damage, nil, true, source_text, local_player)
		return
	end

	if not resolved_owner_unit and attacking_unit and attacking_unit == attacked_unit then
		mod.add_friendly_fire_damage(nil, damage, nil, true, source_text, local_player)
		return
	end

	if resolved_owner_unit then
		local side_system = Managers.state.extension:system("side_system")
		local is_ally = side_system:is_ally(resolved_owner_unit, attacked_unit)

		if is_ally or attack_result == attack_results.friendly_fire then
			local attacking_player = mod:player_from_unit(resolved_owner_unit)

			if not attacking_player then
				return
			end

			local account_id = attacking_player:account_id() or attacking_player:name() or loc("friendly_fire_unknown_account")
			local player_name = attacking_player:name() or attacking_player:character_name() or loc("friendly_fire_unknown_player")
			local player_slot = attacking_player.slot and attacking_player:slot()
			local player_slot_colors = UISettings.player_slot_colors
			local player_slot_color = player_slot and player_slot_colors and player_slot_colors[player_slot]

			if player_name and player_slot_color then
				player_name = Text.apply_color_to_text(player_name, player_slot_color)
			end

			if attack_result == attack_results.died then
				if not mod.friendly_fire_kills[account_id] then
					mod.friendly_fire_kills[account_id] = 0
				end

				mod.friendly_fire_kills[account_id] = mod.friendly_fire_kills[account_id] + 1
				mod.team_kills_total = (mod.team_kills_total or 0) + 1

				show_friendly_fire_kill_notification(player_name, mod.friendly_fire_kills[account_id], mod.team_kills_total, local_player, attacking_player)
			else
				mod.add_friendly_fire_damage(account_id, damage, player_name, false, source_text, local_player, attacking_player)
			end
		else
		end
	else
		if attack_result == attack_results.friendly_fire then
			mod.add_friendly_fire_damage(nil, damage, loc("friendly_fire_unknown_player"), false, source_text, local_player, nil)
		end
	end
end)


mod:command("ffd", "Test FriendlyFireNotify notification (damage/kill)", function(mode)
	if not mod.DEBUG then
		return
	end

	local local_player = Managers.player and Managers.player:local_player(1)

	if not local_player or not Managers.event then
		return
	end

	if mode == "kill" then
		show_friendly_fire_kill_notification("Тестовый игрок", 4, 5, local_player, local_player)
	else
		show_friendly_fire_notification("Тестовый игрок", 123, 10, false, "", local_player, local_player, 789)
	end
end)

