local mod = get_mod("ThirdPersonLight")

if type(mod.tpl_light_unit) == "table" then
	return mod.tpl_light_unit
end

local State = mod:io_dofile("ThirdPersonLight/scripts/mods/ThirdPersonLight/runtime/state")

local LightUnit = {}

local LIGHT_RESOURCE = "core/units/light"
local FALLOFF_START = 1
local VOLUMETRIC_INTENSITY = 0.3
local SPOT_ANGLE_START = 5 / 180 * math.pi
local SPOT_ANGLE_END = 70 / 180 * math.pi

local function _apply_properties(light_obj, settings)
	local c = settings.color

	Light.set_enabled(light_obj, true)
	Light.set_color_filter(light_obj, Vector3(c.r, c.g, c.b))
	Light.set_falloff_start(light_obj, FALLOFF_START)
	Light.set_falloff_end(light_obj, settings.light_radius)
	Light.set_volumetric_intensity(light_obj, VOLUMETRIC_INTENSITY)
	Light.set_intensity(light_obj, settings.light_intensity)

	if settings.flashlight_mode then
		Light.set_type(light_obj, "spot")
		Light.set_spot_angle_start(light_obj, SPOT_ANGLE_START)
		Light.set_spot_angle_end(light_obj, SPOT_ANGLE_END)
	else
		Light.set_type(light_obj, "omni")
	end
end

function LightUnit.spawn(world, position, rotation)
	if not world or not position then
		return nil
	end

	local unit = World.spawn_unit_ex(world, LIGHT_RESOURCE, nil, position, rotation or Quaternion.identity())

	if not unit or not Unit.alive(unit) then
		return nil
	end

	local light_obj = Unit.light(unit, 1)

	if light_obj then
		_apply_properties(light_obj, State.settings)
	end

	return unit
end

function LightUnit.apply_settings(unit)
	if not unit or not Unit.alive(unit) then
		return
	end

	local light_obj = Unit.light(unit, 1)

	if not light_obj then
		return
	end

	_apply_properties(light_obj, State.settings)
end

function LightUnit.set_intensity(unit, value)
	if not unit or not Unit.alive(unit) then
		return
	end

	local light_obj = Unit.light(unit, 1)

	if light_obj then
		Light.set_intensity(light_obj, value)
	end
end

function LightUnit.destroy(world, unit)
	if world and unit and Unit.alive(unit) then
		World.destroy_unit(world, unit)
	end
end

mod.tpl_light_unit = LightUnit

return LightUnit
