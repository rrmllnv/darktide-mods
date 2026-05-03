local Breed = require("scripts/utilities/breed")
local Health = require("scripts/utilities/health")
local HitZone = require("scripts/utilities/attack/hit_zone")

local Method = {}
local METHOD_ID = "method_7_hits_injection"

local MAX_RAYCAST_HITS = 64

-- Returns true if the unit is an enemy: either via side_system (authoritative)
-- or via breed fallback when side_system is unavailable (e.g. early in mission
-- before HEALTH_ALIVE is populated or side_system is fully initialised).
local function unit_is_injectable_enemy(context, player_unit, target_unit)
	if context.target_unit_is_enemy(player_unit, target_unit) then
		return true
	end

	-- side_system returned false - check whether it was simply not ready yet.
	-- Non-player units that are damageable and have a breed are enemy minions.
	if not Health.is_damagable(target_unit) then
		return false
	end

	local target_breed = Breed.unit_breed_or_nil(target_unit)

	return target_breed ~= nil and not Breed.is_player(target_breed)
end

-- Scans a sorted hits table for the first actor on an injectable enemy unit
-- that has a valid damageable non-afro hit zone.
--
-- Skips:
--   - player-owned units (player, first_person, weapon)
--   - afro hit zones (continue scanning deeper into the same unit)
--   - non-damageable units in ragdoll state (continue scanning)
--
-- Stops at the first non-player non-enemy static obstacle (no health extension).
-- Units with health that are not identified as enemy are skipped, not stopped on,
-- to handle the case where side_system is not yet initialised.
local function scan_hits_for_damageable_actor(hits, player_unit, first_person_unit, weapon_unit, context, shooting_position)
	for i = 1, #hits do
		local hit = hits[i]
		local actor = context.hit_actor(hit)

		if not actor then
			break
		end

		local target_unit = Actor.unit(actor)

		if target_unit == player_unit
			or target_unit == first_person_unit
			or target_unit == weapon_unit
		then
			-- Skip player-owned units that appear first in 3rd person camera rays
		elseif unit_is_injectable_enemy(context, player_unit, target_unit) then
			if Health.is_damagable(target_unit) then
				local hit_zone_name = HitZone.get_name(target_unit, actor)

				if hit_zone_name and hit_zone_name ~= HitZone.hit_zone_names.afro then
					local hit_pos = context.hit_position(hit)
					local muzzle_distance = shooting_position and hit_pos
						and Vector3.length(hit_pos - shooting_position)
						or context.hit_distance(hit)

					return {
						position = hit_pos,
						distance = muzzle_distance,
						normal   = hit.normal or hit[3],
						actor    = actor,
					}
				end
				-- Afro or no hit zone: continue scanning deeper into this unit
			end
			-- Not damageable (ragdoll): continue scanning
		elseif Health.is_damagable(target_unit) then
			-- Unit has health but is not a known enemy (player character or
			-- unidentifiable unit). Skip it and continue rather than stopping,
			-- to avoid treating allies as wall blockers.
		else
			-- No health extension: static obstacle (wall, surface, prop). Stop.
			return nil
		end
	end

	return nil
end

-- Fires a raycast and scans hits for the first valid injectable enemy actor.
local function raycast_for_damageable_actor(context, physics_world, from_position, direction, player_unit, first_person_unit, weapon_unit, shooting_position)
	local max_distance = context.settings.max_distance

	local hits = PhysicsWorld.raycast(
		physics_world,
		from_position,
		direction,
		max_distance,
		"all",
		"types",
		"both",
		"max_hits",
		MAX_RAYCAST_HITS,
		"collision_filter",
		context.CAMERA_RAYCAST_FILTER
	)

	if not hits or #hits == 0 then
		return nil
	end

	table.sort(hits, context.hit_sort_function)

	return scan_hits_for_damageable_actor(hits, player_unit, first_person_unit, weapon_unit, context, shooting_position)
end

-- Method 7: Aggressive rotation correction.
--
-- Three-phase search for a damageable enemy surface position to aim at.
-- No synthetic hit injection — the real muzzle ray is used for damage so
-- the server can validate it normally.
--
-- Phase 1 (camera ray): exact hit point on enemy surface via camera ray.
-- Phase 2 (broadphase): nearest enemy node position fallback.
-- Phase 3 (muzzle ray in camera direction): close-range fallback when the
--   player body blocks both the camera ray and broadphase LOS check.
--
-- Enemy identification uses side_system with a breed-based fallback for
-- cases where side_system or HEALTH_ALIVE are not yet fully initialised.
Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local physics_world = action._physics_world

	if not physics_world then
		context.debug_reject(METHOD_ID, "no_physics_world")

		return nil
	end

	local camera_position, camera_rotation = context.camera_pose()

	if not camera_position or not camera_rotation then
		context.debug_reject(METHOD_ID, "no_camera_pose")

		return nil
	end

	local first_person_unit = action._first_person_unit
	local weapon_unit = action._weapon_unit
	local camera_direction = Quaternion.forward(camera_rotation)

	-- Phase 1: Camera ray from camera position in camera forward direction.
	local camera_hit = raycast_for_damageable_actor(
		context, physics_world,
		camera_position, camera_direction,
		player_unit, first_person_unit, weapon_unit,
		position
	)

	local target_position = camera_hit and camera_hit.position or nil

	if not target_position then
		context.debug_fallback(METHOD_ID, "no_camera_hit")

		-- Phase 2: Broadphase as rotation fallback.
		target_position = context.broadphase_target_node_position(physics_world, player_unit, action, position)

		if not target_position then
			context.debug_fallback(METHOD_ID, "no_broadphase_target")

			-- Phase 3: Muzzle ray in camera direction.
			-- filter_player_character_shooting_raycast is not blocked by the
			-- player's 3rd person body, covering point-blank range.
			if position then
				local muzzle_hit = raycast_for_damageable_actor(
					context, physics_world,
					position, camera_direction,
					player_unit, first_person_unit, weapon_unit,
					position
				)

				if muzzle_hit then
					target_position = muzzle_hit.position
				else
					context.debug_fallback(METHOD_ID, "no_muzzle_camera_dir_hit")
				end
			end
		end
	end

	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, target_position)

	context.debug_reject(METHOD_ID, correction_reason)

	return corrected_rotation
end

Method.projectile_rotation = function(context, action, position, rotation, fire_config)
	return Method.shoot_rotation(context, action, position, rotation, fire_config)
end

return Method
