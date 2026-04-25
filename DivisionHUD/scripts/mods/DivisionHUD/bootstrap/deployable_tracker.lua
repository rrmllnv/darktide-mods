local mod = get_mod("DivisionHUD")

local SessionVector = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/session_vector")

if not SessionVector.can_continue() then
	return mod
end

mod.tracked_deployables = mod.tracked_deployables or {}

if mod._divisionhud_deployable_tracker_hooked then
	return mod
end

mod._divisionhud_deployable_tracker_hooked = true

local function division_hud_clear_tracked_deployables()
	if type(mod.tracked_deployables) == "table" then
		table.clear(mod.tracked_deployables)
	else
		mod.tracked_deployables = {}
	end
end

mod.divisionhud_clear_tracked_deployables = division_hud_clear_tracked_deployables

local function division_hud_add_tracked_deployable(unit, name, duration)
	if not unit or type(name) ~= "string" or type(duration) ~= "number" or duration <= 0 then
		return
	end

	local start_t = mod.hud_utils and mod.hud_utils.safe_gameplay_time and mod.hud_utils.safe_gameplay_time()

	if not start_t then
		return
	end

	mod.tracked_deployables[unit] = {
		name = name,
		start_time = start_t,
		duration = duration,
	}
end

local function division_hud_remove_tracked_deployable(unit)
	if not unit then
		return
	end

	mod.tracked_deployables[unit] = nil
end

mod:hook_safe("UnitSpawnerManager", "spawn_husk_unit", function(self, game_object_id, owner_id)
	local session = self._game_session
	local unit = self._network_units[game_object_id]

	if not unit then
		return
	end

	local local_player = Managers.player and Managers.player:local_player(1)

	if not local_player then
		return
	end

	local unit_template_id = GameSession.game_object_field(session, game_object_id, "unit_template")
	local unit_template_name = self._unit_template_network_lookup[unit_template_id]

	if unit_template_name == "broker_stimm_field_crate_deployable" then
		local owner_unit_id = GameSession.game_object_field(session, game_object_id, "owner_unit_id")

		if owner_unit_id ~= NetworkConstants.invalid_game_object_id then
			local owner_unit = Managers.state.unit_spawner:unit(owner_unit_id)

			if owner_unit and owner_unit == local_player.player_unit then
				local talent_settings = require("scripts/settings/talent/talent_settings")
				local ability_settings = talent_settings.broker.combat_ability.stimm_field
				local lifetime = ability_settings.life_time
				local owner_talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

				if owner_talent_extension and owner_talent_extension:has_special_rule("broker_stimm_field_linger") then
					lifetime = ability_settings.sub_1_life_time
				end

				division_hud_add_tracked_deployable(unit, "broker_stimm_field", lifetime)
			end
		end
	elseif unit_template_name == "item_deployable_projectile" then
		local owner_unit_id = GameSession.game_object_field(session, game_object_id, "owner_unit_id")

		if owner_unit_id ~= NetworkConstants.invalid_game_object_id then
			local owner_unit = Managers.state.unit_spawner:unit(owner_unit_id)

			if owner_unit and owner_unit == local_player.player_unit then
				local item_id = GameSession.game_object_field(session, game_object_id, "item_id")
				local item_name = NetworkLookup.player_item_names[item_id]

				if item_name == "content/items/weapons/player/drone_area_buff" then
					local talent_settings = require("scripts/settings/talent/talent_settings")
					local lifetime = talent_settings.adamant.blitz_ability.drone.duration

					division_hud_add_tracked_deployable(unit, "adamant_drone", lifetime)
				end
			end
		end
	end

	if mod.alerts_on_unit_spawner_spawn_husk then
		mod.alerts_on_unit_spawner_spawn_husk(self, game_object_id)
	end
end)

mod:hook_safe("UnitSpawnerManager", "_remove_network_unit", function(self, unit)
	division_hud_remove_tracked_deployable(unit)
end)

mod:hook_safe("ProximityBrokerStimmField", "init", function(self, context, init_data, owner_unit)
	local local_player = Managers.player and Managers.player:local_player(1)
	local is_owner = local_player and owner_unit == local_player.player_unit

	if is_owner then
		division_hud_add_tracked_deployable(self._unit, "broker_stimm_field", self._life_time)
	end
end)

mod:hook_safe("ProximityAreaBuffDrone", "init", function(self, context, init_data, owner_unit)
	local local_player = Managers.player and Managers.player:local_player(1)
	local is_owner = local_player and owner_unit == local_player.player_unit

	if is_owner then
		division_hud_add_tracked_deployable(self._unit, "adamant_drone", self._life_time)
	end
end)

return mod
