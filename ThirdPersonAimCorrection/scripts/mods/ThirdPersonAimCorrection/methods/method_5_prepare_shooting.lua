local Method = {}
local METHOD_ID = "method_5_prepare_shooting"

Method.prepare_rotation = function(context, action)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local action_component = action._action_component
	local shooting_position = action_component and action_component.shooting_position
	local shooting_rotation = action_component and action_component.shooting_rotation
	local _, _, _, target_position, target_reason = context.camera_enemy_actor_hit(action._physics_world, player_unit, action)
	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, shooting_position, shooting_rotation, target_position)

	context.debug_reject(METHOD_ID, target_reason or correction_reason)

	return corrected_rotation
end

return Method
