local Method = {}
local METHOD_ID = "method_3_hit_zone_center"

Method.shoot_rotation = function(context, action, position, rotation, fire_config)
	local can_run, player_unit, reason = context.action_can_run(action)

	if not can_run then
		context.debug_reject(METHOD_ID, reason)

		return nil
	end

	local _, target_unit, actor, _, target_reason = context.camera_enemy_actor_hit(action._physics_world, player_unit, action)

	if not target_unit then
		context.debug_reject(METHOD_ID, target_reason)

		return nil
	end

	local target_position, hit_zone_reason = context.hit_zone_center_position(target_unit, actor)
	local corrected_rotation, correction_reason = context.corrected_shot_rotation(action, position, rotation, target_position)

	context.debug_reject(METHOD_ID, hit_zone_reason or correction_reason)

	return corrected_rotation
end

return Method
