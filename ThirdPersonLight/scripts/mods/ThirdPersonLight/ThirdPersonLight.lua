local mod = get_mod("ThirdPersonLight")

local light_unit = nil
local dog_light_unit = nil
local cached_player_unit = nil
local cached_player_obj = nil

local flicker_time_remaining = 0.1
local flicker_target = 1
local current_intensity = 1

local light_intensity = mod:get("light_intensity")
local light_radius = mod:get("light_radius")
local light_falloff_start = 1
local color = {
    r = mod:get("light_color_r") / 255,
    g = mod:get("light_color_g") / 255,
    b = mod:get("light_color_b") / 255
}

local dog_light_enabled = mod:get("enable_dog_light")
local dog_light_intensity = mod:get("dog_light_intensity")
local dog_light_radius = mod:get("dog_light_radius")
local dog_color = {
    r = mod:get("dog_light_color_r") / 255,
    g = mod:get("dog_light_color_g") / 255,
    b = mod:get("dog_light_color_b") / 255
}

local flashlight_mode = mod:get("flashlight_mode")
local flicker_mode = mod:get("flicker_mode")
local player_light_enabled = mod:get("enable_player_light")

local function get_world()
    if not Managers.world or not Managers.world:has_world("level_world") then
        return nil
    end
    return Managers.world:world("level_world")
end

local function get_local_player_cached()
    if cached_player_unit then
        local ok, alive = pcall(function() return ALIVE[cached_player_unit] end)
        if ok and alive then
            return cached_player_obj, cached_player_unit
        end
        cached_player_unit = nil
        cached_player_obj = nil
    end
    local player_manager = Managers.player
    if not player_manager then return nil, nil end
    local player = player_manager:local_player(1)
    if not player or not player.player_unit then return nil, nil end
    local unit = player.player_unit
    local ok, alive = pcall(function() return ALIVE[unit] end)
    if ok and alive then
        cached_player_unit = unit
        cached_player_obj = player
        return cached_player_obj, cached_player_unit
    end
    return nil, nil
end

local function get_camera_position_and_rotation(player)
    if not Managers.state or not Managers.state.camera then return nil, nil end
    local camera_manager = Managers.state.camera
    local viewport_name = player and player.viewport_name
    if not viewport_name then return nil, nil end
    local camera = camera_manager:camera(viewport_name)
    if not camera then return nil, nil end
    return Camera.world_position(camera), Camera.world_rotation(camera)
end

local function is_in_hub()
    if not Managers.state or not Managers.state.game_mode then return false end
    local gm = Managers.state.game_mode
    return gm and gm.game_mode_name and gm:game_mode_name() == "hub"
end

local function is_dark_mission()
    local template = Managers.state.circumstance and Managers.state.circumstance:template()
    if template and template.mutators then
        for _, mutator in pairs(template.mutators) do
            if mutator == "mutator_darkness_los" then return true end
        end
    end
    return false
end

local function can_spawn_light_unit(is_player)
    if not mod:get("enable_lantern_mod") then return false end
    if is_player and not player_light_enabled then return false end
    if is_in_hub() then return false end
    if mod:get("only_dark_missions") and not is_dark_mission() then return false end
    return true
end

local function destroy_light(unit_ref)
    local world = get_world()
    if world and unit_ref and Unit.alive(unit_ref) then
        World.destroy_unit(world, unit_ref)
    end
end

local function spawn_light()
    if not can_spawn_light_unit(true) then
        destroy_light(light_unit)
        light_unit = nil
        return
    end
    local player, unit = get_local_player_cached()
    local world = get_world()
    if not unit or not world then return end
    if light_unit and Unit.alive(light_unit) then return end
    local pos = Unit.world_position(unit, 1)
    if not flashlight_mode then pos = pos + Vector3(0,0,1) end
    local rot = Quaternion.identity()
    light_unit = World.spawn_unit_ex(world, "core/units/light", nil, pos, rot)
    if light_unit and Unit.alive(light_unit) then
        local light_obj = Unit.light(light_unit, 1)
        if light_obj then
            Light.set_enabled(light_obj, true)
            Light.set_color_filter(light_obj, Vector3(color.r, color.g, color.b))
            Light.set_falloff_start(light_obj, light_falloff_start)
            Light.set_falloff_end(light_obj, light_radius)
            Light.set_volumetric_intensity(light_obj, 0.3)
            Light.set_intensity(light_obj, light_intensity)
            if flashlight_mode then
                Light.set_type(light_obj, "spot")
                Light.set_spot_angle_start(light_obj, 5 / 180 * math.pi)
                Light.set_spot_angle_end(light_obj, 70 / 180 * math.pi)
            else
                Light.set_type(light_obj, "omni")
            end
        end
    end
end

local function get_dog_unit()
    local player, unit = get_local_player_cached()
    if not player or not unit then return nil end

    local ok, spawner = pcall(ScriptUnit.extension, unit, "companion_spawner_system")
    if not ok or not spawner then return nil end

    local ok2, companion_units = pcall(spawner.companion_units, spawner)
    
    if not ok2 or not companion_units or #companion_units == 0 then 
        return nil 
    end

    local dog_unit = companion_units[1]

    if not dog_unit or not ALIVE[dog_unit] then 
        return nil 
    end

    return dog_unit
end

local function spawn_dog_light()
    if not dog_light_enabled or not can_spawn_light_unit(false) then return end
    local world = get_world()
    if not world then return end
    local dog = get_dog_unit()
    if not dog then return end
    if dog_light_unit and Unit.alive(dog_light_unit) then return end
    local pos = Unit.world_position(dog, 1) + Vector3(0,0,1)
    local rot = Quaternion.identity()
    dog_light_unit = World.spawn_unit_ex(world, "core/units/light", nil, pos, rot)
    if dog_light_unit and Unit.alive(dog_light_unit) then
        local light_obj = Unit.light(dog_light_unit, 1)
        if light_obj then
            Light.set_enabled(light_obj, true)
            Light.set_color_filter(light_obj, Vector3(dog_color.r, dog_color.g, dog_color.b))
            Light.set_falloff_start(light_obj, 0.5)
            Light.set_falloff_end(light_obj, dog_light_radius)
            Light.set_volumetric_intensity(light_obj, 0.25)
            Light.set_intensity(light_obj, dog_light_intensity)
            Light.set_type(light_obj, "omni")
        end
    end
end

local function update_dog_light(dt)
    if not dog_light_enabled or not can_spawn_light_unit(false) then
        if dog_light_unit then destroy_light(dog_light_unit) dog_light_unit=nil end
        return
    end
    local dog = get_dog_unit()
    if not dog or not ALIVE[dog] then
        if dog_light_unit then destroy_light(dog_light_unit) dog_light_unit=nil end
        return
    end
    if not dog_light_unit or not Unit.alive(dog_light_unit) then
        spawn_dog_light()
        return
    end
    local pos = Unit.world_position(dog, 1) + Vector3(0,0,1)
    Unit.set_local_position(dog_light_unit, 1, pos)
end

local function lerp(a,b,t) return a+(b-a)*t end

local function apply_flicker_effect(dt)
    if not flicker_mode or not light_unit or not Unit.alive(light_unit) then return end
    flicker_time_remaining = flicker_time_remaining - dt
    if flicker_time_remaining <=0 then
        flicker_time_remaining = 0.1 + math.random()*0.05
        flicker_target = math.random()*0.8 + 0.6
    end
    current_intensity = lerp(current_intensity, flicker_target, 5*dt)
    local light_obj = Unit.light(light_unit, 1)
    if light_obj then Light.set_intensity(light_obj, light_intensity*current_intensity) end
end

local function update_light_position(dt)
    if not can_spawn_light_unit(true) then
        destroy_light(light_unit)
        light_unit=nil
        return
    end
    local world = get_world()
    if not world then return end
    local player, unit = get_local_player_cached()
    if not unit then return end
    if not light_unit or not Unit.alive(light_unit) then
        spawn_light()
        return
    end
    local pos, rot
    if flashlight_mode then
        pos, rot = get_camera_position_and_rotation(player)
    else
        pos = Unit.world_position(unit, 1) + Vector3(0,0,1)
        rot = Quaternion.identity()
    end
    if not pos then return end
    Unit.set_local_position(light_unit, 1, pos)
    if rot then Unit.set_local_rotation(light_unit, 1, rot) end
    apply_flicker_effect(dt)
end

mod.update = function(dt)
	local gm = Managers.state.game_mode
	if not gm then return end
	local name = gm:game_mode_name()
	if name ~= "coop_complete_objective" and name ~= "shooting_range" and name ~= "expedition" and name ~= "survival" then
		return
	end

    update_light_position(dt)
    update_dog_light(dt)
end

function mod.toggle_lantern()
    local current = mod:get("enable_lantern_mod")
    mod:set("enable_lantern_mod", not current)
    if current then
        mod:notify("Lantern disabled")
        destroy_light(light_unit)
        destroy_light(dog_light_unit)
        light_unit=nil
        dog_light_unit=nil
    else
        mod:notify("Lantern enabled")
        spawn_light()
        spawn_dog_light()
    end
end

function mod.toggle_flashlight()
    flashlight_mode = not flashlight_mode
    mod:set("flashlight_mode", flashlight_mode)
    if flashlight_mode then
        mod:notify("Flashlight mode enabled")
    else
        mod:notify("Flashlight mode disabled")
    end
    destroy_light(light_unit)
    spawn_light()
end

function mod.toggle_player_light()
	player_light_enabled = not player_light_enabled 
    mod:set("enable_player_light", player_light_enabled)
	if player_light_enabled then
        mod:notify("Player light enabled")
    else
        mod:notify("Player light disabled")
    end
end

function mod.toggle_dog_light()
	dog_light_enabled = not dog_light_enabled 
    mod:set("enable_dog_light", dog_light_enabled)
	if dog_light_enabled then
        mod:notify("Dog light enabled")
    else
        mod:notify("Dog light disabled")
    end
end

mod.on_setting_changed = function(setting_name)
    if setting_name=="light_radius" then light_radius=mod:get("light_radius")
    elseif setting_name=="light_intensity" then light_intensity=mod:get("light_intensity")
    elseif setting_name=="light_color_r" or setting_name=="light_color_g" or setting_name=="light_color_b" then
        color={r=mod:get("light_color_r")/255,g=mod:get("light_color_g")/255,b=mod:get("light_color_b")/255}
    elseif setting_name=="dog_light_radius" then dog_light_radius=mod:get("dog_light_radius")
    elseif setting_name=="dog_light_intensity" then dog_light_intensity=mod:get("dog_light_intensity")
    elseif setting_name=="dog_light_color_r" or setting_name=="dog_light_color_g" or setting_name=="dog_light_color_b" then
        dog_color={r=mod:get("dog_light_color_r")/255,g=mod:get("dog_light_color_g")/255,b=mod:get("dog_light_color_b")/255}
    elseif setting_name=="enable_dog_light" then dog_light_enabled=mod:get("enable_dog_light")
    elseif setting_name=="enable_player_light" then player_light_enabled=mod:get("enable_player_light")
    elseif setting_name=="flashlight_mode" then flashlight_mode=mod:get("flashlight_mode")
    elseif setting_name=="flicker_mode" then flicker_mode=mod:get("flicker_mode")
    else return end
    destroy_light(light_unit)
    destroy_light(dog_light_unit)
    light_unit=nil
    dog_light_unit=nil
    spawn_light()
    spawn_dog_light()
end

mod.on_disabled = function()
    destroy_light(light_unit)
    destroy_light(dog_light_unit)
    light_unit=nil
    dog_light_unit=nil
end
