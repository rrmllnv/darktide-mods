local Method = {}
local METHOD_ID = "method_2_validated_shooting_ray"

Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local _, _, _, target_position, target_reason = context.camera_enemy_actor_hit(action._physics_world, player_unit, action)

	if not target_position then
		context.debug_reject(METHOD_ID, target_reason)

		return nil
	end

	local validated_position, validation_reason = context.validated_damageable_muzzle_hit(action._physics_world, player_unit, action, position, target_position)
	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, validated_position)

	context.debug_reject(METHOD_ID, validation_reason or correction_reason)

	return corrected_rotation
end

return Method
