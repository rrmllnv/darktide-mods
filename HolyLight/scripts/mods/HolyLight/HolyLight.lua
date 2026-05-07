local mod = get_mod("HolyLight")

local HOLY_LIGHT_VFX = "content/fx/particles/player_buffs/buff_preacher_holy_light"
local ROOT_NODE_INDEX = 1
local DEFAULT_HEIGHT = 0.1

local tracked_effects_by_unit = {}
local tracked_pickups_by_unit = {}
local tracked_deployables_by_unit = {}

local function is_alive_unit(unit)
	return type(unit) == "userdata" and Unit and Unit.alive and Unit.alive(unit)
end

local STIMM_PICKUP_TYPES = {
	expedition_time_syringe_timed = true,
	syringe_ability_boost_pocketable = true,
	syringe_broker_pocketable = true,
	syringe_corruption_pocketable = true,
	syringe_power_boost_pocketable = true,
	syringe_speed_boost_pocketable = true,
}

local AMMO_PICKUP_TYPES = {
	small_clip = true,
	large_clip = true,
}

local GRENADE_PICKUP_TYPES = {
	small_grenade = true,
}

local AMMO_CRATE_PICKUP_TYPES = {
	ammo_cache_pocketable = true,
	ammo_cache_deployable = true,
	large_ammunition_crate = true,
}

local MEDICAL_CRATE_PICKUP_TYPES = {
	medical_crate_pocketable = true,
	medical_crate_deployable = true,
}

local PLASTEEL_PICKUP_TYPES = {
	small_metal = true,
	large_metal = true,
}

local DIAMANTINE_PICKUP_TYPES = {
	small_platinum = true,
	large_platinum = true,
}

local GRIMOIRE_PICKUP_TYPES = {
	grimoire = true,
	grimoire_pocketable = true,
}

local SCRIPTURE_PICKUP_TYPES = {
	tome = true,
	tome_pocketable = true,
	scripture_pocketable = true,
}

local function mod_enabled()
	return mod:get("enable_mod") ~= false
end

local function pickup_type_enabled(pickup_type)
	if not pickup_type then
		return false
	end

	if STIMM_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_stimms") ~= false
	end

	if AMMO_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_ammo_pickups") ~= false
	end

	if GRENADE_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_grenade_pickups") ~= false
	end

	if AMMO_CRATE_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_ammo_crates") ~= false
	end

	if MEDICAL_CRATE_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_medical_crates") ~= false
	end

	if PLASTEEL_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_plasteel_pickups") ~= false
	end

	if DIAMANTINE_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_diamantine_pickups") ~= false
	end

	if GRIMOIRE_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_grimoires") ~= false
	end

	if SCRIPTURE_PICKUP_TYPES[pickup_type] then
		return mod:get("enable_scriptures") ~= false
	end

	return false
end

local function effect_height()
	local height = mod:get("effect_height")

	if type(height) ~= "number" then
		return DEFAULT_HEIGHT
	end

	return height
end

local function pickup_type_from_unit(unit)
	if not is_alive_unit(unit) or not Unit.has_data(unit, "pickup_type") then
		return nil
	end

	return Unit.get_data(unit, "pickup_type")
end

local function pickup_type_from_marker_data(marker)
	if not marker then
		return nil
	end

	local success, pickup_type = pcall(function()
		local data = marker.data

		return data and data.type or nil
	end)

	if not success then
		return nil
	end

	return pickup_type
end

local function stop_effect_for_unit(unit)
	local effect_data = tracked_effects_by_unit[unit]

	if not effect_data then
		return
	end

	local world = effect_data.world
	local effect_id = effect_data.effect_id

	if world and effect_id then
		World.stop_spawning_particles(world, effect_id)
	end

	tracked_effects_by_unit[unit] = nil
end

local function stop_all_effects()
	for unit, _ in pairs(tracked_effects_by_unit) do
		stop_effect_for_unit(unit)
	end

	table.clear(tracked_pickups_by_unit)
	table.clear(tracked_deployables_by_unit)
end

local function spawn_effect_for_unit(unit, pickup_type)
	if not is_alive_unit(unit) or tracked_effects_by_unit[unit] then
		return
	end

	if not pickup_type_enabled(pickup_type) then
		return
	end

	local world = Unit.world(unit)

	if not world then
		return
	end

	local node_index = ROOT_NODE_INDEX

	local node_position = Unit.world_position(unit, node_index)
	local translation_offset = Vector3(0, 0, effect_height())
	local effect_id =
		World.create_particles(world, HOLY_LIGHT_VFX, node_position + translation_offset, Quaternion.identity())

	if not effect_id then
		return
	end

	local attachment_pose = Matrix4x4.from_translation(translation_offset)

	World.link_particles(world, effect_id, unit, node_index, attachment_pose, "destroy")

	tracked_effects_by_unit[unit] = {
		effect_id = effect_id,
		pickup_type = pickup_type,
		world = world,
	}
end

local function register_deployable_unit(unit, pickup_type)
	if not unit or not pickup_type then
		return
	end

	tracked_deployables_by_unit[unit] = pickup_type
end

local function register_pickup_unit(unit)
	if not is_alive_unit(unit) then
		return
	end

	local pickup_type = pickup_type_from_unit(unit)

	if not pickup_type then
		return
	end

	tracked_pickups_by_unit[unit] = pickup_type
end

local function add_registered_pickup_units(desired_units)
	for unit, pickup_type in pairs(tracked_pickups_by_unit) do
		if is_alive_unit(unit) and pickup_type_enabled(pickup_type) then
			desired_units[unit] = pickup_type
		else
			tracked_pickups_by_unit[unit] = nil
		end
	end
end

local function add_marker_units(desired_units)
	local ui_manager = Managers.ui
	local hud = ui_manager and ui_manager:get_hud()
	local world_markers = hud and hud:element("HudElementWorldMarkers")
	local markers_by_type = world_markers and world_markers._markers_by_type

	if not markers_by_type then
		return
	end

	for _, markers in pairs(markers_by_type) do
		for i = 1, #markers do
			local marker = markers[i]
			local unit = marker and marker.unit
			local pickup_type = unit and pickup_type_from_unit(unit)

			if not pickup_type then
				pickup_type = pickup_type_from_marker_data(marker)
			end

			if type(unit) == "userdata" and pickup_type and pickup_type_enabled(pickup_type) then
				desired_units[unit] = pickup_type
			end
		end
	end
end

local function add_deployable_units(desired_units)
	for unit, pickup_type in pairs(tracked_deployables_by_unit) do
		if is_alive_unit(unit) and pickup_type_enabled(pickup_type) then
			desired_units[unit] = pickup_type
		else
			tracked_deployables_by_unit[unit] = nil
		end
	end
end

local function sync_effects()
	if not mod_enabled() then
		stop_all_effects()
		return
	end

	local desired_units = {}

	add_marker_units(desired_units)
	add_registered_pickup_units(desired_units)
	add_deployable_units(desired_units)

	for unit, pickup_type in pairs(desired_units) do
		spawn_effect_for_unit(unit, pickup_type)
	end

	for unit, effect_data in pairs(tracked_effects_by_unit) do
		local desired_pickup_type = desired_units[unit]

		if not is_alive_unit(unit) or not desired_pickup_type or effect_data.pickup_type ~= desired_pickup_type then
			stop_effect_for_unit(unit)
		end
	end
end

mod.on_all_mods_loaded = function()
	local is_mod_loading = true

	mod:hook_require("scripts/extension_systems/unit_templates", function(instance)
		if not is_mod_loading then
			return
		end

		if instance.pickup then
			mod:hook_safe(instance.pickup, "local_unit_spawned", function(unit)
				register_pickup_unit(unit)
			end)

			mod:hook_safe(instance.pickup, "husk_unit_spawned", function(unit)
				register_pickup_unit(unit)
			end)
		end

		if instance.medical_crate_deployable then
			mod:hook_safe(instance.medical_crate_deployable, "husk_init", function(unit)
				register_deployable_unit(unit, "medical_crate_deployable")
			end)

			mod:hook_safe(
				instance.medical_crate_deployable,
				"local_unit_spawned",
				function(unit)
					register_deployable_unit(unit, "medical_crate_deployable")
				end
			)
		end

		is_mod_loading = false
	end)
end

mod.update = function()
	sync_effects()
end

mod.on_setting_changed = function()
	if not mod_enabled() then
		stop_all_effects()
		return
	end

	for unit, effect_data in pairs(tracked_effects_by_unit) do
		if effect_data.pickup_type ~= nil then
			stop_effect_for_unit(unit)
		end
	end
end

mod.on_game_state_changed = function(status)
	if status == "exit" then
		stop_all_effects()
	end
end

mod.on_unload = function()
	stop_all_effects()
end

mod.on_disabled = function()
	stop_all_effects()
end
