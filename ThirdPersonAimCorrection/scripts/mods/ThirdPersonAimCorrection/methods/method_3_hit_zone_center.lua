local Method = {}

Method.shoot_rotation = function(context, action, position, rotation)
	local can_run, player_unit = context.action_can_run(action)

	if not can_run then
		return nil
	end

	local _, target_unit, actor, fallback_position = context.camera_enemy_hit(action._physics_world, player_unit, action)
	local target_position = target_unit and context.hit_zone_center_position(target_unit, actor, fallback_position) or nil

	return context.corrected_shot_rotation(action, position, rotation, target_position)
end

Method.projectile_rotation = function(context, action, position, rotation)
	return Method.shoot_rotation(context, action, position, rotation)
end

return Method
