local mod = get_mod("ThirdPersonAimCorrection")

require("scripts/extension_systems/weapon/actions/action_shoot")
require("scripts/extension_systems/weapon/actions/action_shoot_hit_scan")
require("scripts/extension_systems/weapon/actions/action_shoot_pellets")
require("scripts/extension_systems/weapon/actions/action_shoot_projectile")

local HitScan = require("scripts/utilities/attack/hit_scan")

local BASE_PATH = "ThirdPersonAimCorrection/scripts/mods/ThirdPersonAimCorrection"
local DEFAULT_METHOD_ID = "method_4_enemy_aim_target_node"

local WeaponWhitelist = mod:io_dofile(BASE_PATH .. "/settings/weapon_whitelist")
local Shared = mod:io_dofile(BASE_PATH .. "/methods/shared")

local METHOD_REGISTRY = {
	{
		id = "method_1_camera_hit_position",
		path = BASE_PATH .. "/methods/method_1_camera_hit_position",
	},
	{
		id = "method_2_validated_shooting_ray",
		path = BASE_PATH .. "/methods/method_2_validated_shooting_ray",
	},
	{
		id = "method_3_hit_zone_center",
		path = BASE_PATH .. "/methods/method_3_hit_zone_center",
	},
	{
		id = "method_4_enemy_aim_target_node",
		path = BASE_PATH .. "/methods/method_4_enemy_aim_target_node",
	},
	{
		id = "method_5_prepare_shooting",
		path = BASE_PATH .. "/methods/method_5_prepare_shooting",
	},
	{
		id = "method_6_shoot_hook",
		path = BASE_PATH .. "/methods/method_6_shoot_hook",
	},
	{
		id = "method_7_hits_injection",
		path = BASE_PATH .. "/methods/method_7_hits_injection",
	},
}

local method_lookup = {}

for i = 1, #METHOD_REGISTRY do
	local entry = METHOD_REGISTRY[i]

	method_lookup[entry.id] = entry
end

local settings = {
	enable_mod = true,
	only_third_person = true,
	debug_enabled = false,
	max_distance = 100,
	correction_method = DEFAULT_METHOD_ID,
}

local function refresh_settings()
	settings.enable_mod = mod:get("enable_mod") ~= false
	settings.only_third_person = mod:get("only_third_person") ~= false
	settings.debug_enabled = mod:get("debug_enabled") == true
	settings.max_distance = tonumber(mod:get("max_distance")) or 100

	local correction_method = mod:get("correction_method") or DEFAULT_METHOD_ID

	settings.correction_method = method_lookup[correction_method] and correction_method or DEFAULT_METHOD_ID
end

local function load_method(entry)
	local method = mod:io_dofile(entry.path)

	if type(method) ~= "table" then
		mod:error("Correction method `%s` does not return a method table.", tostring(entry.id))

		return nil
	end

	return method
end

refresh_settings()

local context = Shared.create_context(mod, settings, WeaponWhitelist)

local _original_process_hits = HitScan.process_hits

HitScan.process_hits = function(is_server, world, physics_world, attacker_unit, fire_configuration, hits, position, direction, power_level, charge_level, impact_fx_data, max_distance, debug_drawer, optional_is_local_unit, optional_player, optional_instakill, optional_is_critical_strike, optional_weapon_item, optional_origin_slot, optional_get_results_per_unit)
	local injection_data = context.consume_pending_injection(attacker_unit)

	if injection_data then
		local synthetic_hit = {
			injection_data.position,
			injection_data.distance,
			injection_data.normal,
			injection_data.actor,
			position = injection_data.position,
			distance = injection_data.distance,
			normal   = injection_data.normal,
			actor    = injection_data.actor,
		}

		local merged = { synthetic_hit }

		if hits then
			for i = 1, #hits do
				merged[i + 1] = hits[i]
			end
		end

		hits = merged
	end

	return _original_process_hits(is_server, world, physics_world, attacker_unit, fire_configuration, hits, position, direction, power_level, charge_level, impact_fx_data, max_distance, debug_drawer, optional_is_local_unit, optional_player, optional_instakill, optional_is_critical_strike, optional_weapon_item, optional_origin_slot, optional_get_results_per_unit)
end

local methods = {}

for i = 1, #METHOD_REGISTRY do
	local entry = METHOD_REGISTRY[i]
	local method = load_method(entry)

	if method then
		methods[entry.id] = method
	end
end

local function active_method()
	refresh_settings()

	return methods[settings.correction_method] or methods[DEFAULT_METHOD_ID]
end

local function apply_shoot_rotation(self, position, rotation, fire_config, error_prefix)
	local method = active_method()
	local shoot_rotation = method and method.shoot_rotation

	if type(shoot_rotation) ~= "function" then
		return rotation
	end

	local ok, corrected_rotation_or_error = pcall(shoot_rotation, context, self, position, rotation, fire_config)

	if ok and corrected_rotation_or_error then
		return corrected_rotation_or_error
	elseif not ok then
		mod:error("%s: %s", error_prefix, tostring(corrected_rotation_or_error))
	end

	return rotation
end

local function hook_shoot_with_rotation_argument(action_class, error_prefix)
	if not action_class then
		return
	end

	mod:hook(action_class, "_shoot", function(func, self, position, rotation, power_level, charge_level, t, fire_config)
		rotation = apply_shoot_rotation(self, position, rotation, fire_config, error_prefix)

		return func(self, position, rotation, power_level, charge_level, t, fire_config)
	end)
end

hook_shoot_with_rotation_argument(CLASS.ActionShootHitScan, "Hitscan correction failed")
hook_shoot_with_rotation_argument(CLASS.ActionShootPellets, "Pellets correction failed")

if CLASS.ActionShoot then
	mod:hook(CLASS.ActionShoot, "_prepare_shooting", function(func, self, dt, t)
		func(self, dt, t)

		local method = active_method()
		local prepare_rotation = method and method.prepare_rotation

		if type(prepare_rotation) ~= "function" then
			return
		end

		local action_component = self._action_component

		if not action_component then
			return
		end

		local ok, corrected_rotation_or_error = pcall(prepare_rotation, context, self)

		if ok and corrected_rotation_or_error then
			action_component.shooting_rotation = corrected_rotation_or_error
		elseif not ok then
			mod:error("Prepare shooting correction failed: %s", tostring(corrected_rotation_or_error))
		end
	end)
end

if CLASS.ActionShootProjectile then
	mod:hook(CLASS.ActionShootProjectile, "_shoot", function(func, self, position, rotation, power_level, charge_level, t, fire_config)
		local method = active_method()
		local projectile_rotation = method and method.projectile_rotation
		local action_component = self._action_component

		if type(projectile_rotation) ~= "function" or not action_component then
			return func(self, position, rotation, power_level, charge_level, t, fire_config)
		end

		local shooting_position = action_component.shooting_position
		local shooting_rotation = action_component.shooting_rotation
		local original_rotation = shooting_rotation
		local ok, corrected_rotation_or_error = pcall(projectile_rotation, context, self, shooting_position, shooting_rotation, fire_config)

		if ok and corrected_rotation_or_error then
			action_component.shooting_rotation = corrected_rotation_or_error
			rotation = corrected_rotation_or_error
		elseif not ok then
			mod:error("Projectile correction failed: %s", tostring(corrected_rotation_or_error))
		end

		local result = func(self, position, rotation, power_level, charge_level, t, fire_config)

		action_component.shooting_rotation = original_rotation

		return result
	end)
end

mod.on_setting_changed = function()
	refresh_settings()
end
