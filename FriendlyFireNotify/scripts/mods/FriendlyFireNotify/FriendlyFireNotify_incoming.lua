local mod = get_mod("FriendlyFireNotify")

local AttackSettings = require("scripts/settings/damage/attack_settings")
local attack_results = AttackSettings.attack_results
local notifications = mod.notifications

local incoming = {}

mod.friendly_fire_damage = mod.friendly_fire_damage or {}
mod.self_damage_total = mod.self_damage_total or 0
mod.friendly_fire_kills = mod.friendly_fire_kills or {}
mod.team_kills_total = mod.team_kills_total or 0
mod.pending_notifications = mod.pending_notifications or {}

local function total_friendly_fire_all()
	local total = 0
	for _, value in pairs(mod.friendly_fire_damage or {}) do
		local numeric = tonumber(value) or 0
		if numeric > 0 then
			total = total + numeric
		end
	end
	return total
end

function incoming.reset()
	mod.friendly_fire_damage = {}
	mod.self_damage_total = 0
	mod.friendly_fire_kills = {}
	mod.team_kills_total = 0
	mod.pending_notifications = {}
end

local function show_friendly_fire_notification(player_name, damage_amount, total_damage, is_self_damage, source_text, notification_player, portrait_player, team_total_damage)
	notifications.show_incoming_damage({
		player_name = player_name,
		damage_amount = damage_amount,
		total_damage = total_damage,
		is_self_damage = is_self_damage,
		source_text = source_text,
		notification_player = notification_player,
		portrait_player = portrait_player,
		team_total_damage = team_total_damage,
	})
end

local function show_friendly_fire_kill_notification(player_name, total_killer_kills, team_total_kills, notification_player, portrait_player)
	notifications.show_incoming_kill(player_name, total_killer_kills, team_total_kills, notification_player, portrait_player)
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
	entry.last_update = notifications.now()
end

function incoming.update()
	if not next(mod.pending_notifications or {}) then
		return
	end

	local t = notifications.now()
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

local function add_friendly_fire_damage(account_id, amount, player_name, is_self_damage, source_text, notification_player, attacker_player)
	if not amount then
		return
	end

	local clamped_amount = math.max(0, amount)
	local safe_player_name = player_name or mod:localize("friendly_fire_unknown_player") or "friendly_fire_unknown_player"
	local safe_account_id = account_id or mod:localize("friendly_fire_unknown_account") or "friendly_fire_unknown_account"
	local safe_source = source_text or ""

	if is_self_damage then
		mod.self_damage_total = (mod.self_damage_total or 0) + clamped_amount
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

function incoming.on_attack_result(buffer_data)
	local attacked_unit = buffer_data.attacked_unit
	local attacking_unit = buffer_data.attacking_unit
	local attack_result = buffer_data.attack_result
	local damage = buffer_data.damage

	local player_unit_spawn_manager = Managers.state and Managers.state.player_unit_spawn
	local attacked_player = player_unit_spawn_manager and attacked_unit and player_unit_spawn_manager:owner(attacked_unit)
	local local_player = Managers.player and Managers.player:local_player(1)
	local source_text = notifications.resolve_source_text(buffer_data)

	if not attacked_player or not local_player or attacked_player ~= local_player then
		return
	end

	if not damage or damage <= 0 then
		return
	end

	local resolved_owner_unit = attacking_unit

	if not resolved_owner_unit and attacking_unit then
		local AttackingUnitResolver = mod:original_require("scripts/utilities/attack/attacking_unit_resolver")
		resolved_owner_unit = AttackingUnitResolver.resolve(attacking_unit)
	end

	if not resolved_owner_unit and attacking_unit and attacking_unit == attacked_unit then
		add_friendly_fire_damage(nil, damage, nil, true, source_text, local_player)
		return
	end

	if resolved_owner_unit and resolved_owner_unit == attacked_unit then
		add_friendly_fire_damage(nil, damage, nil, true, source_text, local_player)
		return
	end

	if resolved_owner_unit then
		local side_system = Managers.state.extension:system("side_system")
		local is_ally = side_system:is_ally(resolved_owner_unit, attacked_unit)

		if is_ally or attack_result == attack_results.friendly_fire then
			local attacking_player = notifications.player_from_unit(resolved_owner_unit)

			if not attacking_player then
				return
			end

			local account_id = attacking_player:account_id() or attacking_player:name() or notifications.loc("friendly_fire_unknown_account")
			local player_name = notifications.colored_player_name(attacking_player, "friendly_fire_unknown_player")

			if attack_result == attack_results.died then
				if not mod.friendly_fire_kills[account_id] then
					mod.friendly_fire_kills[account_id] = 0
				end

				mod.friendly_fire_kills[account_id] = mod.friendly_fire_kills[account_id] + 1
				mod.team_kills_total = (mod.team_kills_total or 0) + 1

				show_friendly_fire_kill_notification(player_name, mod.friendly_fire_kills[account_id], mod.team_kills_total, local_player, attacking_player)
			else
				add_friendly_fire_damage(account_id, damage, player_name, false, source_text, local_player, attacking_player)
			end
		end
	else
		local side_system = Managers.state.extension and Managers.state.extension:system("side_system")
		local profile_name = buffer_data.damage_profile and buffer_data.damage_profile.name
		local profile_is_tracked = profile_name and mod.PROFILE_EXCEPTIONS[profile_name]

		if attacking_unit and side_system then
			local is_ally = side_system:is_ally(attacking_unit, attacked_unit)
			if is_ally then
				local attacking_player = notifications.player_from_unit(attacking_unit)
				if attacking_player then
					local account_id = attacking_player:account_id() or attacking_player:name() or notifications.loc("friendly_fire_unknown_account")
					local player_name = notifications.colored_player_name(attacking_player, "friendly_fire_unknown_player")

					add_friendly_fire_damage(account_id, damage, player_name, false, source_text, local_player, attacking_player)
					return
				end
			end
		end

		if profile_is_tracked then
			add_friendly_fire_damage(nil, damage, notifications.loc("friendly_fire_unknown_player"), false, source_text, local_player, nil)
		end
	end
end

return incoming

