local mod = get_mod("ThirdPersonAimCorrection")

require("scripts/extension_systems/weapon/actions/action_shoot")
require("scripts/extension_systems/weapon/actions/action_shoot_hit_scan")
require("scripts/extension_systems/weapon/actions/action_shoot_pellets")
require("scripts/extension_systems/weapon/actions/action_shoot_projectile")

local WeaponWhitelist = mod:io_dofile("ThirdPersonAimCorrection/scripts/mods/ThirdPersonAimCorrection/settings/weapon_whitelist")

local CAMERA_RAYCAST_FILTER = "filter_player_character_shooting_raycast"
local MIN_DIRECTION_LENGTH_SQ = 0.0001
local MAX_CORRECTION_ANGLE = math.rad(180)
local MAX_RAYCAST_HITS = 64
local MAX_SHOOTING_TO_CAMERA_ANGLE = math.rad(85)

local settings = {
	enable_mod = true,
	only_third_person = true,
	max_distance = 100,
}

local camera_raycast_hits = {}
local correction_error_logged = false

local function refresh_settings()
	settings.enable_mod = mod:get("enable_mod") ~= false
	settings.only_third_person = mod:get("only_third_person") ~= false
	settings.max_distance = tonumber(mod:get("max_distance")) or 100
end

local function local_player()
	local player_manager = Managers.player

	if not player_manager then
		return nil
	end

	return player_manager:local_player(1)
end

local function local_player_unit()
	local player = local_player()

	return player and player.player_unit or nil
end

local function camera_pose()
	local player = local_player()
	local state_manager = Managers.state
	local camera_manager = state_manager and state_manager.camera
	local viewport_name = player and player.viewport_name

	if not camera_manager or not viewport_name then
		return nil, nil
	end

	local camera = camera_manager:camera(viewport_name)

	if not camera then
		return nil, nil
	end

	return Camera.world_position(camera), Camera.world_rotation(camera)
end

local function perspectives_requests_third_person()
	local perspectives_mod = get_mod("Perspectives") or get_mod("PerspectivesRedux")

	if perspectives_mod and type(perspectives_mod.is_requesting_third_person) == "function" then
		local ok, result = pcall(perspectives_mod.is_requesting_third_person)

		return ok and result == true
	end

	local player_unit = local_player_unit()
	local first_person_extension = player_unit and ScriptUnit.has_extension(player_unit, "first_person_system")

	return first_person_extension and first_person_extension._force_third_person_mode == true
end

local function correction_can_run_for_unit(player_unit)
	if not settings.enable_mod then
		return false
	end

	if not player_unit or not ALIVE[player_unit] then
		return false
	end

	if player_unit ~= local_player_unit() then
		return false
	end

	if settings.only_third_person and not perspectives_requests_third_person() then
		return false
	end

	return true
end

local function weapon_ids(action)
	local weapon_action_component = action._weapon_action_component
	local template_name = weapon_action_component and weapon_action_component.template_name or nil
	local weapon = action._weapon
	local item = weapon and weapon.item or nil
	local item_name = item and item.name or nil
	local master_item = item and item.__master_item or nil
	local item_weapon_template = item and item.weapon_template or nil

	return template_name, item_name, master_item, item_weapon_template
end

local function weapon_is_whitelisted(action)
	local template_name, item_name, master_item, item_weapon_template = weapon_ids(action)

	if WeaponWhitelist and WeaponWhitelist.all_weapons == true then
		return true
	end

	local templates = WeaponWhitelist and WeaponWhitelist.templates or nil
	local items = WeaponWhitelist and WeaponWhitelist.items or nil

	if templates and template_name and templates[template_name] then
		return true
	end

	if templates and item_weapon_template and templates[item_weapon_template] then
		return true
	end

	if items and item_name and items[item_name] then
		return true
	end

	if items and master_item and items[master_item] then
		return true
	end

	return false
end

local function hit_distance(hit)
	return hit.distance or hit[2] or 0
end

local function hit_actor(hit)
	return hit.actor or hit[4]
end

local function hit_position(hit)
	return hit.position or hit[1]
end

local function hit_sort_function(left, right)
	return hit_distance(left) < hit_distance(right)
end

local function camera_target_position(physics_world, player_unit)
	local camera_position, camera_rotation = camera_pose()

	if not camera_position or not camera_rotation then
		return nil
	end

	local camera_direction = Quaternion.forward(camera_rotation)
	local hits = PhysicsWorld.raycast(
		physics_world,
		camera_position,
		camera_direction,
		settings.max_distance,
		"all",
		"types",
		"both",
		"max_hits",
		MAX_RAYCAST_HITS,
		"collision_filter",
		CAMERA_RAYCAST_FILTER
	)

	if hits then
		table.clear(camera_raycast_hits)
		table.append(camera_raycast_hits, hits)
		table.sort(camera_raycast_hits, hit_sort_function)

		for i = 1, #camera_raycast_hits do
			local hit = camera_raycast_hits[i]
			local position = hit_position(hit)
			local actor = hit_actor(hit)

			if position then
				if actor then
					local target_unit = Actor.unit(actor)

					if target_unit ~= player_unit then
						return position
					end
				else
					return position
				end
			end
		end
	end

	return camera_position + camera_direction * settings.max_distance
end

local function corrected_rotation_from_position(shooting_position, aim_rotation, shooting_rotation, target_position)
	if not shooting_position or not aim_rotation or not shooting_rotation or not target_position then
		return nil
	end

	local aim_direction = Quaternion.forward(aim_rotation)
	local target_vector = target_position - shooting_position

	if Vector3.length_squared(target_vector) <= MIN_DIRECTION_LENGTH_SQ then
		return nil
	end

	local target_direction = Vector3.normalize(target_vector)
	local _, camera_rotation = camera_pose()

	if camera_rotation then
		local camera_direction = Quaternion.forward(camera_rotation)
		local camera_angle = Vector3.angle(camera_direction, target_direction)

		if camera_angle > MAX_SHOOTING_TO_CAMERA_ANGLE then
			return nil
		end
	end

	local correction_angle = Vector3.angle(aim_direction, target_direction)

	if correction_angle > MAX_CORRECTION_ANGLE then
		return nil
	end

	local target_rotation = Quaternion.look(target_direction, Vector3.up())
	local shot_offset = Quaternion.multiply(Quaternion.inverse(aim_rotation), shooting_rotation)

	return Quaternion.multiply(target_rotation, shot_offset)
end

local function corrected_shot_rotation(action, shooting_position, shooting_rotation)
	local player_unit = action._player_unit

	if not correction_can_run_for_unit(player_unit) then
		return nil
	end

	if not weapon_is_whitelisted(action) then
		return nil
	end

	local physics_world = action._physics_world

	if not physics_world then
		return nil
	end

	local target_position = camera_target_position(physics_world, player_unit)
	local first_person_component = action._first_person_component
	local aim_rotation = first_person_component and first_person_component.rotation or shooting_rotation

	return corrected_rotation_from_position(shooting_position, aim_rotation, shooting_rotation, target_position)
end

refresh_settings()

mod.on_setting_changed = function()
	refresh_settings()
end

local function hook_shoot_with_rotation_argument(action_class, error_prefix)
	if not action_class then
		return
	end

	mod:hook(action_class, "_shoot", function(func, self, position, rotation, power_level, charge_level, t, fire_config)
		local ok, corrected_rotation_or_error = pcall(corrected_shot_rotation, self, position, rotation)

		if ok and corrected_rotation_or_error then
			rotation = corrected_rotation_or_error
		elseif not ok and not correction_error_logged then
			correction_error_logged = true
			mod:error("%s: %s", error_prefix, tostring(corrected_rotation_or_error))
		end

		return func(self, position, rotation, power_level, charge_level, t, fire_config)
	end)
end

hook_shoot_with_rotation_argument(CLASS.ActionShootHitScan, "Third person hitscan correction failed")
hook_shoot_with_rotation_argument(CLASS.ActionShootPellets, "Third person pellets correction failed")

mod:hook(CLASS.ActionShootProjectile, "_shoot", function(func, self, position, rotation, power_level, charge_level, t, fire_config)
	local action_component = self._action_component

	if not action_component then
		return func(self, position, rotation, power_level, charge_level, t, fire_config)
	end

	local shooting_position = action_component and action_component.shooting_position
	local shooting_rotation = action_component and action_component.shooting_rotation
	local ok, corrected_rotation_or_error = pcall(corrected_shot_rotation, self, shooting_position, shooting_rotation)
	local original_rotation = shooting_rotation

	if ok and corrected_rotation_or_error then
		action_component.shooting_rotation = corrected_rotation_or_error
	elseif not ok and not correction_error_logged then
		correction_error_logged = true
		mod:error("Third person projectile correction failed: %s", tostring(corrected_rotation_or_error))
	end

	local result = func(self, position, rotation, power_level, charge_level, t, fire_config)

	if original_rotation then
		action_component.shooting_rotation = original_rotation
	end

	return result
end)
