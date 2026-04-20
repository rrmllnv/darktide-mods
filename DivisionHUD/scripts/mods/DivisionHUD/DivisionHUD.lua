local mod = get_mod("DivisionHUD")

mod.tracked_deployables = mod.tracked_deployables or {}

mod.on_all_mods_loaded = function()
	local bridge = mod.recolor_stimms_bridge

	if bridge and type(bridge.refresh) == "function" then
		bridge.refresh()
	end
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

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

UIHudSettings.element_draw_layers["HudElementDivisionHUD"] = 301

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

local function divisionhud_insert_or_replace_element(element_pool, data)
	if type(element_pool) ~= "table" or type(data) ~= "table" then
		return
	end

	for i = 1, #element_pool do
		local element = element_pool[i]

		if type(element) == "table" and element.class_name == data.class_name then
			element_pool[i] = data

			return
		end
	end

	element_pool[#element_pool + 1] = data
end

local function add_or_replace_division_hud_elements(element_pool)
	for _, hud_element in ipairs(hud_elements) do
		divisionhud_insert_or_replace_element(element_pool, {
			class_name = hud_element.class_name,
			filename = hud_element.filename,
			use_hud_scale = true,
			visibility_groups = hud_element.visibility_groups or {
				"alive",
			},
		})
	end
end

mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_player", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_training_grounds", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_shooting_range", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_tutorial", add_or_replace_division_hud_elements)

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

mod:hook("MechanismManager", "mechanism_data", function(func, self)
	if self and self._mechanism then
		return func(self)
	end
end)

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/hud_utils")
mod.recolor_stimms_bridge = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/compat/recolor_stimms_bridge")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/vanilla_hud_suppression")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/settings")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/wielded_weapon_icon_tint")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/widgets/alerts")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/debug")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/mission_objective_hud")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/team_alerts")

mod.divisionhud_proximity_apply_settings = function(setting_id)
	local relevant = setting_id == "divisionhud_reset_all_settings"
		or setting_id == "proximity_enabled"
		or setting_id == "proximity_radius"
		or setting_id == "proximity_show_medical_station"
		or setting_id == "proximity_show_medical"
		or setting_id == "proximity_show_medical_deployed"
		or setting_id == "proximity_show_stimm"
		or setting_id == "proximity_show_ammo_small"
		or setting_id == "proximity_show_ammo_large"
		or setting_id == "proximity_show_ammo_crate"
		or setting_id == "proximity_show_grenade"
		or setting_id == "proximity_show_grimoire"
		or setting_id == "proximity_show_tome"

	if not relevant then
		return
	end

	local HudUtils = mod.hud_utils
	local hud_element = HudUtils and HudUtils.resolve_division_hud_instance and HudUtils.resolve_division_hud_instance()

	if not hud_element then
		return
	end

	hud_element._prox_scan_timer = math.huge
	hud_element._prox_data = {}
	hud_element._prox_anim = {}
end

mod.divisionhud_alerts_apply_settings = function(setting_id)
	local relevant = setting_id == "divisionhud_reset_all_settings"
		or setting_id == "alerts_enabled"
		or setting_id == "alerts_max_visible"
		or setting_id == "alerts_duration_sec"
		or setting_id == "alerts_show_duration_bar"

	if not relevant then
		return
	end

	local HudUtils = mod.hud_utils
	local hud_element = HudUtils and HudUtils.resolve_division_hud_instance and HudUtils.resolve_division_hud_instance()

	if not hud_element then
		return
	end

	hud_element._div_alert_next_enter_t = nil
end

function mod.divisionhud_toggle_visible_keybind(_)
	local cur = mod:get("divisionhud_visible")
	local on = cur ~= false and cur ~= 0

	mod:set("divisionhud_visible", not on, true)
end

