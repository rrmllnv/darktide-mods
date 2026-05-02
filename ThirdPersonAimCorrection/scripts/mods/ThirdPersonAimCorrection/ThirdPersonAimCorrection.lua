local mod = get_mod("ThirdPersonAimCorrection")

require("scripts/extension_systems/weapon/actions/action_shoot")
require("scripts/extension_systems/weapon/actions/action_shoot_hit_scan")
require("scripts/extension_systems/weapon/actions/action_shoot_pellets")
require("scripts/extension_systems/weapon/actions/action_shoot_projectile")

local WeaponWhitelist = mod:io_dofile("ThirdPersonAimCorrection/scripts/mods/ThirdPersonAimCorrection/settings/weapon_whitelist")

local RAY_HIT_TARGET = "ray_hit"
local DEFAULT_TARGET_NODE = "enemy_aim_target_03"
local CAMERA_RAYCAST_FILTER = "filter_player_character_shooting_raycast"
local CAMERA_LINE_OF_SIGHT_FILTER = "filter_interactable_line_of_sight_check"
local MIN_DIRECTION_LENGTH_SQ = 0.0001
local MAX_CORRECTION_ANGLE = math.rad(180)
local MAX_RAYCAST_HITS = 64
local MAX_SHOOTING_TO_CAMERA_ANGLE = math.rad(85)
local MAX_TARGET_NODE_CAMERA_ANGLE = math.rad(3)
local BLOCKER_DISTANCE_EPSILON = 0.05
local TARGET_NODE_NAMES = {
	"enemy_aim_target_03",
	"enemy_aim_target_02",
	"enemy_aim_target_01",
}

local settings = {
	enable_mod = true,
	only_third_person = true,
	max_distance = 100,
	target_node = DEFAULT_TARGET_NODE,
}

local broadphase_results = {}
local camera_raycast_hits = {}
local correction_error_logged = false

local function refresh_settings()
	settings.enable_mod = mod:get("enable_mod") ~= false
	settings.only_third_person = mod:get("only_third_person") ~= false
	settings.max_distance = tonumber(mod:get("max_distance")) or 100
	settings.target_node = mod:get("target_node") or DEFAULT_TARGET_NODE

	if settings.target_node == RAY_HIT_TARGET then
		settings.target_node = DEFAULT_TARGET_NODE
	end
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

local function target_unit_is_enemy(player_unit, target_unit)
	if not target_unit or not HEALTH_ALIVE[target_unit] then
		return false
	end

	local state_manager = Managers.state
	local extension_manager = state_manager and state_manager.extension
	local side_system = extension_manager and extension_manager:system("side_system")

	if not side_system or type(side_system.is_enemy) ~= "function" then
		return false
	end

	return side_system:is_enemy(player_unit, target_unit)
end

local function enemy_side_names(player_unit)
	local state_manager = Managers.state
	local extension_manager = state_manager and state_manager.extension
	local side_system = extension_manager and extension_manager:system("side_system")
	local side = side_system and side_system.side_by_unit[player_unit] or nil

	return side and side:relation_side_names("enemy") or nil
end

local function position_from_target_node(target_unit, fallback_position, allow_ray_hit_position)
	local target_node = settings.target_node

	if allow_ray_hit_position and target_node == RAY_HIT_TARGET then
		return fallback_position
	end

	if target_node ~= RAY_HIT_TARGET and target_node and Unit.has_node(target_unit, target_node) then
		return Unit.world_position(target_unit, Unit.node(target_unit, target_node))
	end

	if Unit.has_node(target_unit, DEFAULT_TARGET_NODE) then
		return Unit.world_position(target_unit, Unit.node(target_unit, DEFAULT_TARGET_NODE))
	end

	if Unit.has_node(target_unit, "enemy_aim_target_02") then
		return Unit.world_position(target_unit, Unit.node(target_unit, "enemy_aim_target_02"))
	end

	if Unit.has_node(target_unit, "enemy_aim_target_01") then
		return Unit.world_position(target_unit, Unit.node(target_unit, "enemy_aim_target_01"))
	end

	return fallback_position
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

local function camera_blocker_distance(physics_world, camera_position, camera_direction, max_distance)
	local hit, _, distance = PhysicsWorld.raycast(
		physics_world,
		camera_position,
		camera_direction,
		max_distance,
		"closest",
		"collision_filter",
		CAMERA_LINE_OF_SIGHT_FILTER
	)

	return hit and distance or nil
end

local function raycast_camera_target(physics_world, player_unit)
	local camera_position, camera_rotation = camera_pose()

	if not camera_position or not camera_rotation then
		return nil
	end

	local camera_direction = Quaternion.forward(camera_rotation)
	local blocker_distance = camera_blocker_distance(physics_world, camera_position, camera_direction, settings.max_distance)
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

	if not hits then
		return nil
	end

	table.clear(camera_raycast_hits)
	table.append(camera_raycast_hits, hits)
	table.sort(camera_raycast_hits, hit_sort_function)

	local best_position = nil
	local best_score = nil
	for i = 1, #camera_raycast_hits do
		local hit = camera_raycast_hits[i]
		local actor = hit_actor(hit)

		if actor then
			local target_unit = Actor.unit(actor)

			if target_unit == player_unit then
				-- In third person the camera ray can start behind the character and touch the player first.
			elseif target_unit_is_enemy(player_unit, target_unit) then
				local target_distance = hit_distance(hit)

				if blocker_distance and blocker_distance < target_distance - BLOCKER_DISTANCE_EPSILON then
					break
				end

				local target_position = position_from_target_node(target_unit, hit_position(hit), false)
				local target_vector = target_position and target_position - camera_position or nil

				if target_vector and Vector3.length_squared(target_vector) > MIN_DIRECTION_LENGTH_SQ then
					local target_direction = Vector3.normalize(target_vector)
					local camera_angle = Vector3.angle(camera_direction, target_direction)

					if camera_angle <= MAX_TARGET_NODE_CAMERA_ANGLE then
						local score = camera_angle * 1000 + target_distance * 0.001

						if not best_score or score < best_score then
							best_position = target_position
							best_score = score
						end
					end
				end
			else
				if best_position then
					return best_position
				end

				return nil
			end
		else
			if best_position then
				return best_position
			end

			return nil
		end
	end

	return best_position
end

local function best_target_node_on_camera_line(target_unit, camera_position, camera_direction)
	local best_position = nil
	local best_angle = nil
	local wanted_target_node = settings.target_node

	if wanted_target_node ~= RAY_HIT_TARGET and wanted_target_node and Unit.has_node(target_unit, wanted_target_node) then
		local target_position = Unit.world_position(target_unit, Unit.node(target_unit, wanted_target_node))
		local target_vector = target_position - camera_position

		if Vector3.length_squared(target_vector) > MIN_DIRECTION_LENGTH_SQ then
			local target_direction = Vector3.normalize(target_vector)
			local camera_angle = Vector3.angle(camera_direction, target_direction)

			best_position = target_position
			best_angle = camera_angle
		end
	end

	for i = 1, #TARGET_NODE_NAMES do
		local target_node = TARGET_NODE_NAMES[i]

		if target_node ~= wanted_target_node and Unit.has_node(target_unit, target_node) then
			local target_position = Unit.world_position(target_unit, Unit.node(target_unit, target_node))
			local target_vector = target_position - camera_position

			if Vector3.length_squared(target_vector) > MIN_DIRECTION_LENGTH_SQ then
				local target_direction = Vector3.normalize(target_vector)
				local camera_angle = Vector3.angle(camera_direction, target_direction)

				if not best_angle or camera_angle < best_angle then
					best_position = target_position
					best_angle = camera_angle
				end
			end
		end
	end

	return best_position, best_angle
end

local function broadphase_camera_target(physics_world, player_unit)
	local camera_position, camera_rotation = camera_pose()
	local side_names = enemy_side_names(player_unit)

	if not camera_position or not camera_rotation or not side_names then
		return nil
	end

	local extension_manager = Managers.state and Managers.state.extension or nil
	local broadphase_system = extension_manager and extension_manager:system("broadphase_system")
	local broadphase = broadphase_system and broadphase_system.broadphase or nil

	if not broadphase then
		return nil
	end

	table.clear(broadphase_results)

	local num_results = broadphase.query(broadphase, camera_position, settings.max_distance, broadphase_results, side_names)
	local camera_direction = Quaternion.forward(camera_rotation)
	local blocker_distance = camera_blocker_distance(physics_world, camera_position, camera_direction, settings.max_distance)
	local best_position = nil
	local best_score = nil

	for i = 1, num_results do
		local target_unit = broadphase_results[i]

		repeat
			if not target_unit_is_enemy(player_unit, target_unit) then
				break
			end

			local target_position, camera_angle = best_target_node_on_camera_line(target_unit, camera_position, camera_direction)

			if not target_position or not camera_angle then
				break
			end

			local to_target = target_position - camera_position

			if Vector3.length_squared(to_target) <= MIN_DIRECTION_LENGTH_SQ then
				break
			end

			if camera_angle > MAX_TARGET_NODE_CAMERA_ANGLE then
				break
			end

			local distance = Vector3.length(to_target)
			if blocker_distance and blocker_distance < distance - BLOCKER_DISTANCE_EPSILON then
				break
			end

			local score = camera_angle * 1000 + distance

			if not best_score or score < best_score then
				best_position = target_position
				best_score = score
			end
		until true
	end

	return best_position
end

local function corrected_rotation_from_position(shooting_position, base_rotation, target_position)
	if not shooting_position or not base_rotation or not target_position then
		return nil
	end

	local base_direction = Quaternion.forward(base_rotation)
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

	local correction_angle = Vector3.angle(base_direction, target_direction)

	if correction_angle > MAX_CORRECTION_ANGLE then
		return nil
	end

	local target_rotation = Quaternion.look(target_direction, Vector3.up())

	return target_rotation
end

local function corrected_rotation(action, target_position)
	local action_component = action._action_component
	local shooting_position = action_component and action_component.shooting_position
	local shooting_rotation = action_component and action_component.shooting_rotation
	local first_person_component = action._first_person_component
	local base_rotation = first_person_component and first_person_component.rotation or shooting_rotation

	return corrected_rotation_from_position(shooting_position, base_rotation, target_position)
end

local function camera_target_position(physics_world, player_unit)
	return broadphase_camera_target(physics_world, player_unit) or raycast_camera_target(physics_world, player_unit)
end

local function apply_third_person_correction(action, t)
	if action._third_person_aim_correction_t == t then
		return
	end

	action._third_person_aim_correction_t = t

	local player_unit = action._player_unit

	if not correction_can_run_for_unit(player_unit) then
		return
	end

	if not weapon_is_whitelisted(action) then
		return
	end

	local physics_world = action._physics_world

	if not physics_world then
		return
	end

	local target_position = camera_target_position(physics_world, player_unit)
	local rotation = corrected_rotation(action, target_position)

	if rotation then
		action._action_component.shooting_rotation = rotation
	end
end

local function corrected_hitscan_shot_rotation(action, shooting_position, shooting_rotation)
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

	return corrected_rotation_from_position(shooting_position, shooting_rotation, target_position)
end

refresh_settings()

mod.on_setting_changed = function()
	refresh_settings()
end

local function hook_prepare_shooting(action_class)
	if not action_class then
		return
	end

	mod:hook(action_class, "_prepare_shooting", function(func, self, dt, t)
		func(self, dt, t)

		local ok, err = pcall(apply_third_person_correction, self, t)

		if not ok and not correction_error_logged then
			correction_error_logged = true
			mod:error("Third person aim correction failed: %s", tostring(err))
		end
	end)
end

hook_prepare_shooting(CLASS.ActionShootHitScan)
hook_prepare_shooting(CLASS.ActionShootPellets)
hook_prepare_shooting(CLASS.ActionShootProjectile)
hook_prepare_shooting(CLASS.ActionShoot)

mod:hook(CLASS.ActionShootHitScan, "_shoot", function(func, self, position, rotation, power_level, charge_level, t, fire_config)
	local ok, corrected_rotation_or_error = pcall(corrected_hitscan_shot_rotation, self, position, rotation)

	if ok and corrected_rotation_or_error then
		rotation = corrected_rotation_or_error
	elseif not ok and not correction_error_logged then
		correction_error_logged = true
		mod:error("Third person hitscan correction failed: %s", tostring(corrected_rotation_or_error))
	end

	return func(self, position, rotation, power_level, charge_level, t, fire_config)
end)
