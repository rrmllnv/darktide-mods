local M = {}

local function _local_player_unit()
	local player_manager = Managers.player
	local connection_manager = Managers.connection

	if not player_manager or not connection_manager or not connection_manager:is_initialized() then
		return nil
	end

	local player = player_manager.local_player_safe and player_manager:local_player_safe(1) or player_manager:local_player(1)

	return player and player.player_unit or nil
end

local function _camera_angle(parent)
	local camera = nil

	if parent and type(parent.player_camera) == "function" then
		camera = parent:player_camera()
	end

	if not camera then
		return Vector3.forward(), Vector3.right()
	end

	local camera_rotation = Camera.local_rotation(camera)
	local camera_forward = Quaternion.forward(camera_rotation)

	camera_forward.z = 0
	camera_forward = Vector3.normalize(camera_forward)

	local camera_right = Vector3.cross(camera_forward, Vector3.up())

	return camera_forward, camera_right
end

M.update = function(parent, widget, lock_state, theme, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	widget.content.visible = false
	return

	local unit = lock_state and lock_state.unit

	if not unit or not Unit.alive(unit) then
		widget.content.visible = false
		return
	end

	local player_unit = _local_player_unit()
	local player_pos = player_unit and POSITION_LOOKUP and POSITION_LOOKUP[player_unit]
	local target_pos = POSITION_LOOKUP and POSITION_LOOKUP[unit]

	if not player_pos or not target_pos then
		widget.content.visible = false
		return
	end

	local fwd, right = _camera_angle(parent)
	local dir = target_pos - player_pos
	dir.z = 0

	if Vector3.length_squared(dir) < 0.0001 then
		widget.content.visible = false
		return
	end

	dir = Vector3.normalize(dir)

	local forward_dot = Vector3.dot(fwd, dir)
	local right_dot = Vector3.dot(right, dir)
	local angle = math.atan2(right_dot, forward_dot)

	local arrow_style = widget.style.arrow
	arrow_style.angle = angle

	local c = arrow_style.color
	local a = math.floor(255 * (opacity or 1) + 0.5)
	local tc = theme and theme.accent

	if tc then
		c[1] = a
		c[2] = tc[2]
		c[3] = tc[3]
		c[4] = tc[4]
	else
		c[1] = a
	end

	widget.content.visible = true
	widget.dirty = true
end

return M

