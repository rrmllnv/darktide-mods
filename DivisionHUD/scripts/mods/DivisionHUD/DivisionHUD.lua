local mod = get_mod("DivisionHUD")

mod._division_hud_recolor_stimms_mod = nil
mod.tracked_deployables = mod.tracked_deployables or {}

mod.on_all_mods_loaded = function()
	local get_mod_fn = rawget(_G, "get_mod")

	mod._division_hud_recolor_stimms_mod = type(get_mod_fn) == "function" and get_mod_fn("RecolorStimms") or nil
end

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

local hud_elements = {
	{
		filename = "DivisionHUD/scripts/mods/DivisionHUD/hud/HudElementDivisionHUD",
		class_name = "HudElementDivisionHUD",
		visibility_groups = {
			"alive",
		},
	},
}

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/slot_data")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/alerts_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/vanilla_stamina_dodge_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/widgets/vanilla_stamina_dodge")

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	local is_spectator_hud = params and params.renderer_name == "spectator_hud_ui_renderer"

	if not is_spectator_hud then
		for _, hud_element in ipairs(hud_elements) do
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
	end

	return func(self, elements, visibility_groups, params)
end)

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/hud_utils")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/vanilla_hud_suppression")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/settings")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/widgets/alerts")

