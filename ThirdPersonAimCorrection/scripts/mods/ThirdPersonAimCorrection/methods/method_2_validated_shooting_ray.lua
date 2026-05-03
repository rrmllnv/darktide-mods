local Method = {}

Method.shoot_rotation = function(context, action, position, rotation)
	local can_run, player_unit = context.action_can_run(action)

	if not can_run then
		return nil
	end

	local _, _, _, target_position = context.camera_enemy_hit(action._physics_world, player_unit, action)

	target_position = context.validated_shooting_hit_position(action._physics_world, player_unit, action, position, target_position)

	return context.corrected_shot_rotation(action, position, rotation, target_position)
end

Method.projectile_rotation = function(context, action, position, rotation)
	return Method.shoot_rotation(context, action, position, rotation)
end

return Method
