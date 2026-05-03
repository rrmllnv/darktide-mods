local Health = require("scripts/utilities/health")
local HitZone = require("scripts/utilities/attack/hit_zone")

local Shared = {}

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

function Shared.create_context(mod, settings, weapon_whitelist)
	local context = {}
	local camera_raycast_hits = {}
	local validation_raycast_hits = {}
	local broadphase_results = {}

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

		if weapon_whitelist and weapon_whitelist.all_weapons == true then
			return true
		end

		local templates = weapon_whitelist and weapon_whitelist.templates or nil
		local items = weapon_whitelist and weapon_whitelist.items or nil

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

	local function correction_can_run_for_unit(player_unit)
		if not settings.enable_mod then
			return false, "disabled"
		end

		if not player_unit or not ALIVE[player_unit] then
			return false, "no_player_unit"
		end

		if player_unit ~= local_player_unit() then
			return false, "not_local_player"
		end

		if settings.only_third_person and not perspectives_requests_third_person() then
			return false, "not_third_person"
		end

		return true
	end

	local function action_can_run(action)
		local player_unit = action._player_unit
		local can_run, reason = correction_can_run_for_unit(player_unit)

		if not can_run then
			return false, nil, reason
		end

		if not weapon_is_whitelisted(action) then
			return false, nil, "not_whitelisted"
		end

		if not action._physics_world then
			return false, nil, "no_physics_world"
		end

		return true, player_unit
	end

	local function raycast_unit_is_ignored(action, player_unit, target_unit)
		return target_unit == player_unit
			or action and target_unit == action._first_person_unit
			or action and target_unit == action._weapon_unit
	end

	local function camera_raycast(physics_world)
		local camera_position, camera_rotation = camera_pose()

		if not camera_position or not camera_rotation then
			return nil, nil, nil
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

		if not hits then
			return nil, camera_position, camera_direction
		end

		table.clear(camera_raycast_hits)
		table.append(camera_raycast_hits, hits)
		table.sort(camera_raycast_hits, hit_sort_function)

		return camera_raycast_hits, camera_position, camera_direction
	end

	local function hit_has_damageable_zone(player_unit, actor)
		if not actor then
			return false, "no_hit_actor"
		end

		local target_unit = Actor.unit(actor)

		if not target_unit_is_enemy(player_unit, target_unit) then
			return false, "no_enemy_actor"
		end

		if not Health.is_damagable(target_unit) then
			return false, "not_damageable"
		end

		local hit_zone_name = HitZone.get_name(target_unit, actor)

		if not hit_zone_name then
			return false, "no_hit_zone"
		end

		if hit_zone_name == HitZone.hit_zone_names.afro then
			return false, "invalid_hit_zone"
		end

		return true
	end

	local function camera_enemy_actor_hit(physics_world, player_unit, action)
		local hits, camera_position = camera_raycast(physics_world)

		if not hits then
			return nil, nil, nil, nil, camera_position and "no_camera_hit" or "no_camera_pose"
		end

		for i = 1, #hits do
			local hit = hits[i]
			local actor = hit_actor(hit)

			if not actor then
				return nil, nil, nil, nil, "no_hit_actor"
			end

			local target_unit = Actor.unit(actor)

			if raycast_unit_is_ignored(action, player_unit, target_unit) then
				-- In third person the camera ray can start behind the character and touch player-owned units first.
			elseif target_unit_is_enemy(player_unit, target_unit) then
				return hit, target_unit, actor, hit_position(hit), nil
			else
				return nil, nil, nil, nil, "no_enemy_actor"
			end
		end

		return nil, nil, nil, nil, "no_enemy_actor"
	end

	local function validated_damageable_muzzle_hit(physics_world, player_unit, action, shooting_position, target_position)
		if not shooting_position or not target_position then
			return nil, "no_target_position"
		end

		local target_vector = target_position - shooting_position

		if Vector3.length_squared(target_vector) <= MIN_DIRECTION_LENGTH_SQ then
			return nil, "target_too_close"
		end

		local direction = Vector3.normalize(target_vector)
		local hits = PhysicsWorld.raycast(
			physics_world,
			shooting_position,
			direction,
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
			return nil, "no_muzzle_hit"
		end

		table.clear(validation_raycast_hits)
		table.append(validation_raycast_hits, hits)
		table.sort(validation_raycast_hits, hit_sort_function)

		for i = 1, #validation_raycast_hits do
			local hit = validation_raycast_hits[i]
			local actor = hit_actor(hit)

			if actor then
				local target_unit = Actor.unit(actor)

				if raycast_unit_is_ignored(action, player_unit, target_unit) then
					-- The muzzle ray can start inside player-owned collision in third person.
				else
					local is_damageable_hit, reason = hit_has_damageable_zone(player_unit, actor)

					if is_damageable_hit then
						return hit_position(hit), nil
					end

					return nil, reason
				end
			else
				return nil, "no_hit_actor"
			end
		end

		return nil, "no_muzzle_hit"
	end

	local function debug_reject(method_id, reason)
		if settings.debug_enabled and reason then
			mod:echo("[ThirdPersonAimCorrection] %s rejected: %s", tostring(method_id), tostring(reason))
		end
	end

	local function corrected_rotation_from_position(shooting_position, shooting_rotation, target_position)
		if not shooting_position then
			return nil, "no_shooting_position"
		end

		if not shooting_rotation then
			return nil, "no_shooting_rotation"
		end

		if not target_position then
			return nil, "no_target_position"
		end

		local target_vector = target_position - shooting_position

		if Vector3.length_squared(target_vector) <= MIN_DIRECTION_LENGTH_SQ then
			return nil, "target_too_close"
		end

		local target_direction = Vector3.normalize(target_vector)
		local _, camera_rotation = camera_pose()

		if camera_rotation then
			local camera_direction = Quaternion.forward(camera_rotation)
			local camera_angle = Vector3.angle(camera_direction, target_direction)

			if camera_angle > MAX_SHOOTING_TO_CAMERA_ANGLE then
				return nil, "angle_limit"
			end
		end

		local shooting_direction = Quaternion.forward(shooting_rotation)
		local correction_angle = Vector3.angle(shooting_direction, target_direction)

		if correction_angle > MAX_CORRECTION_ANGLE then
			return nil, "angle_limit"
		end

		return Quaternion.look(target_direction, Vector3.up()), nil
	end

	local function corrected_shot_rotation(action, shooting_position, shooting_rotation, target_position)
		return corrected_rotation_from_position(shooting_position, shooting_rotation, target_position)
	end

	local function hit_zone_center_position(target_unit, actor)
		local hit_zone_name = actor and HitZone.get_name(target_unit, actor) or nil

		if hit_zone_name and hit_zone_name ~= HitZone.hit_zone_names.afro then
			local ok, position = pcall(HitZone.hit_zone_center_of_mass, target_unit, hit_zone_name, true)

			if ok and position then
				return position, nil
			end

			return nil, "no_hit_zone_center"
		end

		return nil, hit_zone_name == HitZone.hit_zone_names.afro and "invalid_hit_zone" or "no_hit_zone"
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

	local function best_target_node_on_camera_line(target_unit, camera_position, camera_direction)
		local best_position = nil
		local best_angle = nil

		for i = 1, #TARGET_NODE_NAMES do
			local target_node = TARGET_NODE_NAMES[i]

			if Unit.has_node(target_unit, target_node) then
				local target_position = Unit.world_position(target_unit, Unit.node(target_unit, target_node))
				local target_vector = target_position - camera_position

				if Vector3.length_squared(target_vector) > MIN_DIRECTION_LENGTH_SQ then
					local target_direction = Vector3.normalize(target_vector)
					local camera_angle = Vector3.angle(camera_direction, target_direction)

					if not best_angle or camera_angle < best_angle then
						best_position = target_position
						best_angle = camera_angle
					end
				else
					return nil, nil
				end
			end
		end

		return best_position, best_angle
	end

	local function broadphase_target_node_position(physics_world, player_unit)
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

	context.mod = mod
	context.settings = settings
	context.CAMERA_RAYCAST_FILTER = CAMERA_RAYCAST_FILTER
	context.action_can_run = action_can_run
	context.camera_pose = camera_pose
	context.camera_enemy_actor_hit = camera_enemy_actor_hit
	context.validated_damageable_muzzle_hit = validated_damageable_muzzle_hit
	context.hit_zone_center_position = hit_zone_center_position
	context.broadphase_target_node_position = broadphase_target_node_position
	context.corrected_shot_rotation = corrected_shot_rotation
	context.debug_reject = debug_reject
	context.hit_distance = hit_distance
	context.hit_actor = hit_actor
	context.hit_position = hit_position
	context.hit_sort_function = hit_sort_function
	context.target_unit_is_enemy = target_unit_is_enemy

	return context
end

return Shared
