local mod = get_mod("ThirdPersonLight")

local State = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/state")
local PlayerTarget = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/player_target")
local LightUnit = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/light_unit")
local Flicker = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/flicker")

local UP_OFFSET = Vector3Box(0, 0, 1)

local _light_unit = nil

local function _clear_light()
	local world = PlayerTarget.get_world()

	LightUnit.destroy(world, _light_unit)
	_light_unit = nil
	Flicker.reset()
end

local function _attach_position(player, unit)
	if State.settings.flashlight_mode then
		local pos, rot = PlayerTarget.camera_pose(player)

		if pos then
			return pos, rot
		end
	end

	return Unit.world_position(unit, 1) + UP_OFFSET:unbox(), Quaternion.identity()
end

local function _ensure_spawned(world, player, unit)
	if _light_unit and Unit.alive(_light_unit) then
		return _light_unit
	end

	local pos, rot = _attach_position(player, unit)

	_light_unit = LightUnit.spawn(world, pos, rot)

	return _light_unit
end

local function _update_light(dt)
	if not State.can_show_light() then
		if _light_unit then
			_clear_light()
		end

		return
	end

	local world = PlayerTarget.get_world()

	if not world then
		return
	end

	local player, unit = PlayerTarget.get()

	if not unit then
		if _light_unit then
			_clear_light()
		end

		return
	end

	if not _ensure_spawned(world, player, unit) then
		return
	end

	local pos, rot = _attach_position(player, unit)

	if not pos then
		return
	end

	Unit.set_local_position(_light_unit, 1, pos)

	if rot then
		Unit.set_local_rotation(_light_unit, 1, rot)
	end

	Flicker.update(dt, _light_unit)
end

mod.update = function(dt)
	if not State.is_supported_mode() then
		return
	end

	_update_light(dt)
end

mod.on_game_state_change = function(status, state_name)
	State.invalidate_dark_mission()
	PlayerTarget.invalidate()

	if status == "exit" then
		_clear_light()
	end
end

mod.on_disabled = function()
	_clear_light()
end

mod.on_setting_changed = function(setting_name)
	State.refresh()

	if setting_name == "flashlight_mode" then
		_clear_light()

		return
	end

	if setting_name == "flicker_mode" then
		Flicker.reset()
	end

	if not State.can_show_light() then
		_clear_light()

		return
	end

	LightUnit.apply_settings(_light_unit)
end

function mod.toggle_mod()
	local current = mod:get("enable_mod") ~= false

	mod:set("enable_mod", not current)
	State.refresh()

	if current then
		mod:notify(mod:localize("notify_mod_disabled"))
		_clear_light()
	else
		mod:notify(mod:localize("notify_mod_enabled"))
	end
end

function mod.toggle_flashlight()
	local current = mod:get("flashlight_mode") == true

	mod:set("flashlight_mode", not current)
	State.refresh()

	if current then
		mod:notify(mod:localize("notify_flashlight_disabled"))
	else
		mod:notify(mod:localize("notify_flashlight_enabled"))
	end

	_clear_light()
end

function mod.toggle_player_light()
	local current = mod:get("enable_player_light") ~= false

	mod:set("enable_player_light", not current)
	State.refresh()

	if current then
		mod:notify(mod:localize("notify_player_light_disabled"))
		_clear_light()
	else
		mod:notify(mod:localize("notify_player_light_enabled"))
	end
end
