local Method = {}

Method.prepare_rotation = function(context, action)
	local can_run, player_unit = context.action_can_run(action)

	if not can_run then
		return nil
	end

	local action_component = action._action_component
	local shooting_position = action_component and action_component.shooting_position
	local shooting_rotation = action_component and action_component.shooting_rotation
	local _, _, _, target_position = context.camera_enemy_hit(action._physics_world, player_unit, action)

	return context.corrected_shot_rotation(action, shooting_position, shooting_rotation, target_position)
end

return Method
