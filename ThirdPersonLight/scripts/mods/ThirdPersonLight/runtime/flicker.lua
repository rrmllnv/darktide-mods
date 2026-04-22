local mod = get_mod("ThirdPersonLight")

if type(mod.tpl_flicker) == "table" then
	return mod.tpl_flicker
end

local State = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/state")
local LightUnit = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/light_unit")

local Flicker = {}

local TICK_BASE = 0.1
local TICK_JITTER = 0.05
local TARGET_RANGE = 0.8
local TARGET_MIN = 0.6
local LERP_SPEED = 5

local _time_remaining = TICK_BASE
local _target = 1
local _current = 1

local function _lerp(a, b, t)
	return a + (b - a) * t
end

function Flicker.reset()
	_time_remaining = TICK_BASE
	_target = 1
	_current = 1
end

function Flicker.update(dt, light_unit)
	if not State.settings.flicker_mode then
		if _current ~= 1 then
			_current = 1

			if light_unit then
				LightUnit.set_intensity(light_unit, State.settings.light_intensity)
			end
		end

		return
	end

	if not light_unit or not Unit.alive(light_unit) then
		return
	end

	_time_remaining = _time_remaining - dt

	if _time_remaining <= 0 then
		_time_remaining = TICK_BASE + math.random() * TICK_JITTER
		_target = math.random() * TARGET_RANGE + TARGET_MIN
	end

	_current = _lerp(_current, _target, LERP_SPEED * dt)

	LightUnit.set_intensity(light_unit, State.settings.light_intensity * _current)
end

mod.tpl_flicker = Flicker

return Flicker
