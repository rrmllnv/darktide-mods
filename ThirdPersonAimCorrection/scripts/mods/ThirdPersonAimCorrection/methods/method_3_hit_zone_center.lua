local Method = {}
local METHOD_ID = "method_3_hit_zone_center"

Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local _, target_unit, actor, _, target_reason = context.camera_enemy_actor_hit(action._physics_world, player_unit, action)
	local target_position, hit_zone_reason = nil, nil

	if target_unit then
		target_position, hit_zone_reason = context.hit_zone_center_position(target_unit, actor)
	else
		target_position = context.broadphase_target_node_position(action._physics_world, player_unit, action, position)
		context.debug_fallback(METHOD_ID, target_reason)
	end

	if not target_position then
		target_position = context.broadphase_target_node_position(action._physics_world, player_unit, action, position)
		context.debug_fallback(METHOD_ID, hit_zone_reason)
	end

	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, target_position)

	context.debug_reject(METHOD_ID, correction_reason)

	return corrected_rotation
end

return Method
