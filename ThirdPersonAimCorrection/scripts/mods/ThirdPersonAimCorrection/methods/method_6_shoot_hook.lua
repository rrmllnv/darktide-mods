local Method = {}
local METHOD_ID = "method_6_shoot_hook"

Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local _, _, _, target_position, target_reason = context.camera_enemy_actor_hit(action._physics_world, player_unit, action)
	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, target_position)

	context.debug_reject(METHOD_ID, target_reason or correction_reason)

	return corrected_rotation
end

return Method
