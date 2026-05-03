local Method = {}
local METHOD_ID = "method_1_camera_hit_position"

Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local _, _, _, target_position, target_reason = context.camera_enemy_actor_hit(action._physics_world, player_unit, action)

	if not target_position then
		target_position = context.broadphase_target_node_position(action._physics_world, player_unit)
		context.debug_fallback(METHOD_ID, target_reason)
	end

	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, target_position)

	context.debug_reject(METHOD_ID, correction_reason)

	return corrected_rotation
end

return Method
