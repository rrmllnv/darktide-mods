local Health = require("scripts/utilities/health")
local HitZone = require("scripts/utilities/attack/hit_zone")

local Method = {}
local METHOD_ID = "method_7_hits_injection"

local MAX_RAYCAST_HITS = 64
local MIN_DIRECTION_LENGTH_SQ = 0.0001

-- Scans all camera ray hits in order to find the first actor on an enemy unit
-- that belongs to a valid, damageable, non-afro hit zone.
-- Stops at the first non-player non-enemy obstacle (wall or surface).
-- Skips afro actors and continues deeper into the same unit looking for a real zone.
local function find_best_damageable_camera_hit(context, physics_world, player_unit, action, shooting_position)
	local camera_position, camera_rotation = context.camera_pose()

	if not camera_position or not camera_rotation then
		return nil, "no_camera_pose"
	end

	local camera_direction = Quaternion.forward(camera_rotation)
	local max_distance = context.settings.max_distance

	local hits = PhysicsWorld.raycast(
		physics_world,
		camera_position,
		camera_direction,
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
		return nil, "no_camera_hit"
	end

	table.sort(hits, context.hit_sort_function)

	local first_person_unit = action._first_person_unit
	local weapon_unit = action._weapon_unit

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
			-- Skip player-owned units that may appear first in 3rd person
		elseif context.target_unit_is_enemy(player_unit, target_unit) then
			if Health.is_damagable(target_unit) then
				local hit_zone_name = HitZone.get_name(target_unit, actor)

				if hit_zone_name and hit_zone_name ~= HitZone.hit_zone_names.afro then
					local hit_pos = context.hit_position(hit)

					-- Compute distance from muzzle for accurate damage falloff
					local muzzle_distance = shooting_position and hit_pos
						and Vector3.length(hit_pos - shooting_position)
						or context.hit_distance(hit)

					return {
						position = hit_pos,
						distance = muzzle_distance,
						normal   = hit.normal or hit[3],
						actor    = actor,
					}, nil
				end
				-- Afro actor or no hit zone: continue scanning deeper into this unit
			end
			-- Not damageable (ragdoll state): continue scanning
		else
			-- First non-player non-enemy obstacle: stop (wall in the way)
			return nil, "no_enemy_actor"
		end
	end

	return nil, "no_enemy_actor"
end

-- Method 7: Hits injection.
--
-- Finds the first valid damageable non-afro enemy actor under the camera ray
-- and stores it as a pending injection into HitScan.process_hits.
-- The main file's monkey-patched process_hits prepends this actor as the
-- first hit in the hits table, guaranteeing RangedAction.execute_attack is
-- called with the correct actor regardless of where the muzzle ray lands.
-- Also corrects the visible bullet rotation towards the target for visual accuracy.
Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)
		context.set_pending_injection(nil)

		return nil
	end

	local physics_world = action._physics_world

	if not physics_world then
		context.debug_reject(METHOD_ID, "no_physics_world")
		context.set_pending_injection(nil)

		return nil
	end

	-- Find the best damageable camera hit for injection and rotation.
	-- shooting_position is used to compute accurate muzzle-to-target distance.
	local best_hit, hit_reason = find_best_damageable_camera_hit(context, physics_world, player_unit, action, position)

	context.set_pending_injection(best_hit)

	local target_position = best_hit and best_hit.position or nil

	if not target_position then
		context.debug_fallback(METHOD_ID, hit_reason)

		-- No direct camera hit: fall back to broadphase for visual rotation only.
		-- Injection is nil so process_hits will not receive a synthetic hit.
		target_position = context.broadphase_target_node_position(physics_world, player_unit, action, position)
	end

	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, target_position)

	context.debug_reject(METHOD_ID, correction_reason)

	return corrected_rotation
end

Method.projectile_rotation = function(context, action, position, rotation, fire_config)
	return Method.shoot_rotation(context, action, position, rotation, fire_config)
end

return Method
