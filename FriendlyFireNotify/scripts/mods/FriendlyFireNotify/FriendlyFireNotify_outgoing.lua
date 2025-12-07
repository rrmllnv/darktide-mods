local mod = get_mod("FriendlyFireNotify")

local AttackSettings = require("scripts/settings/damage/attack_settings")
local attack_results = AttackSettings.attack_results
local notifications = mod.notifications

local outgoing = {}

mod.outgoing_friendly_fire_damage = mod.outgoing_friendly_fire_damage or {}
mod.outgoing_team_damage_total = mod.outgoing_team_damage_total or 0
mod.outgoing_friendly_fire_kills = mod.outgoing_friendly_fire_kills or {}
mod.outgoing_team_kills_total = mod.outgoing_team_kills_total or 0
mod.outgoing_pending_notifications = mod.outgoing_pending_notifications or {}

local function total_outgoing_friendly_fire_all()
	local total = 0
	for _, value in pairs(mod.outgoing_friendly_fire_damage or {}) do
		local numeric = tonumber(value) or 0
		if numeric > 0 then
			total = total + numeric
		end
	end
	return total
end

function outgoing.reset()
	mod.outgoing_friendly_fire_damage = {}
	mod.outgoing_team_damage_total = 0
	mod.outgoing_friendly_fire_kills = {}
	mod.outgoing_team_kills_total = 0
	mod.outgoing_pending_notifications = {}
end

local function queue_outgoing_notification(account_id, damage_amount, total_damage, player_name, source_text, notification_player, victim_player, team_total_damage)
	local key = table.concat({
		account_id or "unknown",
		source_text or "",
	}, "|")

	local entry = mod.outgoing_pending_notifications[key]
	if not entry then
		entry = {
			damage = 0,
			player_name = player_name,
			account_id = account_id,
			source_text = source_text,
			notification_player = notification_player,
			victim_player = victim_player,
		}
		mod.outgoing_pending_notifications[key] = entry
	end

	entry.damage = (entry.damage or 0) + (damage_amount or 0)
	entry.total_damage = total_damage
	entry.team_total_damage = team_total_damage
	entry.player_name = player_name or entry.player_name
	entry.notification_player = notification_player or entry.notification_player
	entry.victim_player = victim_player or entry.victim_player
	entry.last_update = notifications.now()
end

function outgoing.update()
	if not next(mod.outgoing_pending_notifications or {}) then
		return
	end

	local t = notifications.now()
	local coalesce_time = mod.settings.notification_coalesce_time or mod.DEFAULT_NOTIFICATION_COALESCE_TIME

	for key, entry in pairs(mod.outgoing_pending_notifications) do
		if entry.last_update and t - entry.last_update >= coalesce_time then
			notifications.show_outgoing_damage({
				player_name = entry.player_name,
				damage_amount = entry.damage,
				total_damage = entry.total_damage,
				source_text = entry.source_text,
				notification_player = entry.notification_player,
				portrait_player = entry.victim_player,
				team_total_damage = entry.team_total_damage,
			})

			mod.outgoing_pending_notifications[key] = nil
		end
	end
end

local function add_outgoing_friendly_fire_damage(account_id, amount, player_name, source_text, notification_player, victim_player)
	if not amount then
		return
	end

	local clamped_amount = math.max(0, amount)
	local safe_player_name = player_name or mod:localize("friendly_fire_unknown_player") or "friendly_fire_unknown_player"
	local safe_account_id = account_id or mod:localize("friendly_fire_unknown_account") or "friendly_fire_unknown_account"
	local safe_source = source_text or ""

	if not mod.outgoing_friendly_fire_damage[safe_account_id] then
		mod.outgoing_friendly_fire_damage[safe_account_id] = 0
	end

	mod.outgoing_friendly_fire_damage[safe_account_id] = mod.outgoing_friendly_fire_damage[safe_account_id] + clamped_amount
	local allies_total = total_outgoing_friendly_fire_all()

	queue_outgoing_notification(
		safe_account_id,
		clamped_amount,
		mod.outgoing_friendly_fire_damage[safe_account_id],
		safe_player_name,
		safe_source,
		notification_player,
		victim_player,
		allies_total
	)
end

local function add_outgoing_friendly_fire_kill(account_id, player_name, notification_player, victim_player)
	local safe_account_id = account_id or mod:localize("friendly_fire_unknown_account") or "friendly_fire_unknown_account"
	local safe_player_name = player_name or mod:localize("friendly_fire_unknown_player") or "friendly_fire_unknown_player"

	if not mod.outgoing_friendly_fire_kills[safe_account_id] then
		mod.outgoing_friendly_fire_kills[safe_account_id] = 0
	end

	mod.outgoing_friendly_fire_kills[safe_account_id] = mod.outgoing_friendly_fire_kills[safe_account_id] + 1
	mod.outgoing_team_kills_total = (mod.outgoing_team_kills_total or 0) + 1

	notifications.show_outgoing_kill(
		safe_player_name,
		mod.outgoing_friendly_fire_kills[safe_account_id],
		mod.outgoing_team_kills_total,
		notification_player,
		victim_player
	)
end

function outgoing.on_attack_result(buffer_data)
	local attacked_unit = buffer_data.attacked_unit
	local attacking_unit = buffer_data.attacking_unit
	local attack_result = buffer_data.attack_result
	local damage = buffer_data.damage

	if not damage or damage <= 0 then
		return
	end

	local player_unit_spawn_manager = Managers.state and Managers.state.player_unit_spawn
	local local_player = Managers.player and Managers.player:local_player(1)
	local source_text = notifications.resolve_source_text(buffer_data)

	if not local_player or not player_unit_spawn_manager then
		return
	end

	local attacked_player = attacked_unit and player_unit_spawn_manager:owner(attacked_unit)

	if not attacked_player or attacked_player == local_player then
		return
	end

	local resolved_owner_unit = attacking_unit

	if attacking_unit then
		local AttackingUnitResolver = mod:original_require("scripts/utilities/attack/attacking_unit_resolver")
		resolved_owner_unit = AttackingUnitResolver.resolve(attacking_unit)
	end

	local attacking_player = notifications.player_from_unit(resolved_owner_unit or attacking_unit)

	if attacking_player ~= local_player then
		return
	end

	local side_system = Managers.state.extension and Managers.state.extension:system("side_system")
	local ally_unit = resolved_owner_unit or attacking_unit

	if not side_system or not ally_unit then
		return
	end

	local is_ally = side_system:is_ally(attacked_unit, ally_unit)

	if not is_ally and attack_result ~= attack_results.friendly_fire then
		return
	end

	local account_id = attacked_player:account_id() or attacked_player:name() or notifications.loc("friendly_fire_unknown_account")
	local player_name = notifications.colored_player_name(attacked_player, "friendly_fire_unknown_player")

	if attack_result == attack_results.died then
		add_outgoing_friendly_fire_kill(account_id, player_name, local_player, attacked_player)
	else
		add_outgoing_friendly_fire_damage(account_id, damage, player_name, source_text, local_player, attacked_player)
	end
end

return outgoing

