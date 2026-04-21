local mod = get_mod("DivisionHUD")

if type(mod.danger_zone_runtime) == "table" then
	return mod.danger_zone_runtime
end

local ChaosDaemonhostSettings = require("scripts/settings/monster/chaos_daemonhost_settings")
local ExplosionTemplates = require("scripts/settings/damage/explosion_templates")
local HazardPropSettings = require("scripts/settings/hazard_prop/hazard_prop_settings")
local MinionBuffTemplates = require("scripts/settings/buff/minion_buff_templates")

local hazard_state = HazardPropSettings.hazard_state
local unpack_fn = table.unpack or unpack

local function get_corruption_aura_radius()
	local radius = nil
	local getter = {}

	setmetatable(getter, {
		__index = function()
			local func = debug.getinfo(2).func
			local i = 1

			while true do
				local name, value = debug.getupvalue(func, i)

				if name == "CORRUPTION_AURA_RADIUS" then
					radius = value
					break
				elseif not name then
					break
				end

				i = i + 1
			end

			return {
				unit = nil,
			}
		end,
	})

	MinionBuffTemplates.daemonhost_corruption_aura.interval_func({}, getter)

	return radius
end

local function get_highest_alert_ticking_radius()
	local radius = 1

	for _, value in ipairs(ChaosDaemonhostSettings.anger_distances.not_passive) do
		if value.distance > radius and value.tick then
			radius = value.distance
		end
	end

	return radius
end

local daemonhost_corruption_aura_radius = get_corruption_aura_radius()
local highest_alert_ticking_radius = get_highest_alert_ticking_radius()

local OUTLINE_TEMPLATES = {
	templates = {
		fire_barrel_explosion = {
			display_name = "Огненная бочка",
			setting_id = "danger_zone_show_fire_barrel",
			setting_group = "fire_barrel_explosion",
		},
		scab_flamer_explosion = {
			display_name = "Скаб-огнемётчик",
			setting_id = "danger_zone_show_scab_flamer",
			setting_group = "scab_flamer_explosion",
		},
		scab_bomber_grenade = {
			display_name = "Граната бомбардира",
			setting_id = "danger_zone_show_bomber_grenade",
			setting_group = "scab_bomber_grenade",
		},
		tox_flamer_explosion = {
			display_name = "Токс-огнемётчик",
			setting_id = "danger_zone_show_tox_flamer",
			setting_group = "tox_flamer_explosion",
		},
		daemonhost_spawn = {
			display_name = "Демонхост",
			radius = ChaosDaemonhostSettings.anger_distances.passive[1].distance,
			setting_id = "danger_zone_show_daemonhost",
			setting_group = "daemonhost_spawn",
			validator = "valid_minion_source",
		},
		daemonhost_alert1 = {
			display_name = "Демонхост",
			radius = highest_alert_ticking_radius,
			setting_id = "danger_zone_show_daemonhost",
			setting_group = "daemonhost_alert1",
			setting_group_enabled = "daemonhost_spawn",
			setting_group_colour = "daemonhost_alert1",
			validator = "valid_minion_source",
		},
		daemonhost_alert2 = {
			display_name = "Демонхост",
			radius = highest_alert_ticking_radius,
			setting_id = "danger_zone_show_daemonhost",
			setting_group = "daemonhost_alert2",
			setting_group_enabled = "daemonhost_spawn",
			setting_group_colour = "daemonhost_alert2",
			validator = "valid_minion_source",
		},
		daemonhost_alert3 = {
			display_name = "Демонхост",
			radius = highest_alert_ticking_radius,
			setting_id = "danger_zone_show_daemonhost",
			setting_group = "daemonhost_alert3",
			setting_group_enabled = "daemonhost_spawn",
			setting_group_colour = "daemonhost_alert3",
			validator = "valid_minion_source",
		},
		daemonhost_aura = {
			display_name = "Аура демонхоста",
			radius = daemonhost_corruption_aura_radius,
			setting_id = "danger_zone_show_daemonhost_aura",
			setting_group = "daemonhost_aura",
			validator = "valid_minion_source",
		},
		poxburster_spawn = {
			display_name = "Поксбёрстер",
			radius = ExplosionTemplates.poxwalker_bomber.radius,
			setting_id = "danger_zone_show_poxburster",
			setting_group = "poxburster_spawn",
			validator = "valid_minion_source",
		},
		tox_flamer_spawn = {
			display_name = "Токс-огнемётчик",
			radius = ExplosionTemplates.explosion_settings_cultist_flamer.radius,
			setting_id = "danger_zone_show_tox_flamer",
			setting_group = "tox_flamer_spawn",
		},
		tox_flamer_fuse = {
			display_name = "Токс-огнемётчик",
			radius = ExplosionTemplates.explosion_settings_cultist_flamer.radius,
			setting_id = "danger_zone_show_tox_flamer",
			setting_group = "tox_flamer_fuse",
			validator = "valid_minion_source",
		},
		scab_flamer_spawn = {
			display_name = "Скаб-огнемётчик",
			radius = ExplosionTemplates.explosion_settings_renegade_flamer.radius,
			setting_id = "danger_zone_show_scab_flamer",
			setting_group = "scab_flamer_spawn",
			validator = "valid_minion_source",
		},
		scab_flamer_fuse = {
			display_name = "Скаб-огнемётчик",
			radius = ExplosionTemplates.explosion_settings_renegade_flamer.radius,
			setting_id = "danger_zone_show_scab_flamer",
			setting_group = "scab_flamer_fuse",
			validator = "valid_minion_source",
		},
		explosive_barrel_spawn = {
			display_name = "Взрывная бочка",
			radius = ExplosionTemplates.explosive_barrel.radius,
			setting_id = "danger_zone_show_explosive_barrel",
			setting_group = "explosive_barrel_spawn",
			validator = "valid_barrel_source",
		},
		explosive_barrel_fuse = {
			display_name = "Взрывная бочка",
			radius = ExplosionTemplates.explosive_barrel.radius,
			setting_id = "danger_zone_show_explosive_barrel",
			setting_group = "explosive_barrel_fuse",
			validator = "valid_barrel_source",
		},
		fire_barrel_spawn = {
			display_name = "Огненная бочка",
			radius = ExplosionTemplates.fire_barrel.radius,
			setting_id = "danger_zone_show_fire_barrel",
			setting_group = "fire_barrel_spawn",
			validator = "valid_barrel_source",
		},
		fire_barrel_fuse = {
			display_name = "Огненная бочка",
			radius = ExplosionTemplates.fire_barrel.radius,
			setting_id = "danger_zone_show_fire_barrel",
			setting_group = "fire_barrel_fuse",
			validator = "valid_barrel_source",
		},
	},
	liquid = {
		prop_fire = "fire_barrel_explosion",
		renegade_flamer_backpack = "scab_flamer_explosion",
		renegade_grenadier_fire_grenade = "scab_bomber_grenade",
		cultist_flamer_backpack = "tox_flamer_explosion",
	},
	minion = {
		chaos_daemonhost = {
			set_wwise_source_id = true,
			spawn = "daemonhost_spawn",
			stages = {
				[ChaosDaemonhostSettings.stages.agitated] = "daemonhost_alert1",
				[ChaosDaemonhostSettings.stages.disturbed] = "daemonhost_alert2",
				[ChaosDaemonhostSettings.stages.about_to_wake_up] = "daemonhost_alert3",
			},
			buffs = {
				daemonhost_corruption_aura = "daemonhost_aura",
			},
		},
		chaos_poxwalker_bomber = {
			spawn = "poxburster_spawn",
		},
		cultist_flamer = {
			spawn = "tox_flamer_spawn",
			buffs = {
				cultist_flamer_backpack_damaged = "tox_flamer_fuse",
			},
		},
		renegade_flamer = {
			spawn = "scab_flamer_spawn",
			buffs = {
				renegade_flamer_backpack_damaged = "scab_flamer_fuse",
			},
		},
	},
	prop = {
		explosion = {
			spawn = "explosive_barrel_spawn",
			triggered = "explosive_barrel_fuse",
		},
		fire = {
			spawn = "fire_barrel_spawn",
			triggered = "fire_barrel_fuse",
		},
	},
}

local source_unit_map = mod.danger_zone_source_unit_map or {}
local tracked_sources = mod.danger_zone_sources or {}

mod.danger_zone_source_unit_map = source_unit_map
mod.danger_zone_sources = tracked_sources

local VALIDATORS = {
	valid_minion_source = function(unit)
		return unit ~= nil and Unit.is_valid(unit) and HEALTH_ALIVE[unit]
	end,
	valid_barrel_source = function(prop, valid_states)
		if prop == nil or not Unit.is_valid(prop._unit) then
			return false
		end

		local current_state = prop:current_state()

		for i = 1, #valid_states do
			if current_state == valid_states[i] then
				return true
			end
		end

		return false
	end,
}

local function danger_zone_clear_source(unit)
	if not unit then
		return
	end

	tracked_sources[unit] = nil
end

local function danger_zone_track_source(template_id, unit, radius, ...)
	if not unit or not Unit.is_valid(unit) then
		return
	end

	local template = OUTLINE_TEMPLATES.templates[template_id]

	if not template then
		return
	end

	tracked_sources[unit] = {
		display_name = template.display_name,
		template_id = template_id,
		radius = radius or template.radius or 0,
		setting_id = template.setting_id,
		validator = template.validator,
		validator_args = { ... },
	}
end

local function danger_zone_setting_enabled(settings, setting_id)
	if type(setting_id) ~= "string" or setting_id == "" then
		return true
	end

	if type(settings) ~= "table" then
		return true
	end

	local value = settings[setting_id]

	return value ~= false and value ~= 0
end

local function danger_zone_is_valid(unit, source)
	if not unit or not Unit.is_valid(unit) or not source then
		return false
	end

	local validator_name = source.validator

	if not validator_name then
		return true
	end

	local validator = VALIDATORS[validator_name]

	if type(validator) ~= "function" then
		return true
	end

	local args = source.validator_args or {}

	if #args == 0 and validator_name == "valid_minion_source" then
		return validator(unit)
	end

	return validator(unpack_fn(args))
end

local function danger_zone_source_position(unit)
	if POSITION_LOOKUP and POSITION_LOOKUP[unit] then
		return POSITION_LOOKUP[unit]
	end

	local ok, position = pcall(Unit.world_position, unit, 1)

	if ok then
		return position
	end

	return nil
end

local function danger_zone_distance_sq(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z

	return dx * dx + dy * dy + dz * dz
end

local function scan(player_unit, warning_margin, settings)
	local result = {
		active = false,
		distance_m = 0,
		radius = 0,
		source_name = "",
		template_id = nil,
		unit = nil,
	}

	if not player_unit or not Unit.alive(player_unit) then
		return result
	end

	local player_position = Unit.world_position(player_unit, 1)

	if not player_position then
		return result
	end

	local margin = type(warning_margin) == "number" and warning_margin or 15
	local best_edge_distance = nil

	for unit, source in pairs(tracked_sources) do
		if not unit or not Unit.is_valid(unit) then
			tracked_sources[unit] = nil
		elseif danger_zone_is_valid(unit, source) and danger_zone_setting_enabled(settings, source.setting_id) then
			local source_position = danger_zone_source_position(unit)
			local radius = type(source.radius) == "number" and source.radius or 0

			if source_position and radius > 0 then
				local center_distance = math.sqrt(danger_zone_distance_sq(source_position, player_position))
				local edge_distance = math.max(0, center_distance - radius)

				if edge_distance <= margin and (best_edge_distance == nil or edge_distance < best_edge_distance) then
					best_edge_distance = edge_distance
					result.active = true
					result.distance_m = math.max(0, math.floor(edge_distance + 0.5))
					result.radius = radius
					result.source_name = source.display_name or ""
					result.template_id = source.template_id
					result.unit = unit
				end
			end
		end
	end

	return result
end

local function on_liquid_spawn(self, radius)
	local template_id = OUTLINE_TEMPLATES.liquid[self._template_name]
	local template = OUTLINE_TEMPLATES.templates[template_id]

	if template then
		danger_zone_track_source(template_id, self._unit, radius)
	end
end

local function on_minion_spawn(unit)
	local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
	local breed = unit_data_extension and unit_data_extension:breed()
	local breed_template = breed and OUTLINE_TEMPLATES.minion[breed.name]
	local template_id = breed_template and breed_template.spawn
	local template = OUTLINE_TEMPLATES.templates[template_id]

	if template then
		danger_zone_track_source(template_id, unit, template.radius, unit)
	end
end

if mod.danger_zone_hooks_registered ~= true then
	mod.danger_zone_hooks_registered = true

	mod:hook_safe("UIManager", "cb_on_game_state_change", function()
		table.clear(tracked_sources)
		table.clear(source_unit_map)
	end)

	mod:hook_safe("LiquidAreaExtension", "init", function(self, _, _, extension_init_data)
		self._template_name = extension_init_data.template.name
	end)

	mod:hook_safe("LiquidAreaExtension", "_calculate_broadphase_size", function(self)
		on_liquid_spawn(self, self._broadphase_radius)
	end)

	mod:hook_safe("LiquidAreaExtension", "destroy", function(self)
		danger_zone_clear_source(self._unit)
	end)

	mod:hook_safe("HuskLiquidAreaExtension", "init", function(self, _, _, extension_init_data)
		self._template_name = extension_init_data.template.name
	end)

	mod:hook_safe("HuskLiquidAreaExtension", "_calculate_liquid_size", function(self)
		on_liquid_spawn(self, self._liquid_radius)
	end)

	mod:hook_safe("HuskLiquidAreaExtension", "destroy", function(self)
		danger_zone_clear_source(self._unit)
	end)

	mod:hook_safe("HealthExtension", "init", function(_, extension_init_context, unit)
		on_minion_spawn(unit)
	end)

	mod:hook_safe("HealthExtension", "kill", function(self)
		danger_zone_clear_source(self._unit)
	end)

	mod:hook_safe("HuskHealthExtension", "init", function(_, extension_init_context, unit)
		on_minion_spawn(unit)
	end)

	mod:hook_safe("MinionDeathManager", "set_dead", function(_, unit)
		danger_zone_clear_source(unit)
	end)

	mod:hook_safe("MinionSpawnManager", "unregister_unit", function(_, unit)
		danger_zone_clear_source(unit)
	end)

	mod:hook_safe("UnitSpawnerManager", "mark_for_deletion", function(_, unit)
		danger_zone_clear_source(unit)
	end)

	mod:hook_safe("DialogueExtension", "extensions_ready", function(self, _, unit)
		local breed_template = OUTLINE_TEMPLATES.minion[self._context.breed_name]

		if breed_template and breed_template.set_wwise_source_id then
			source_unit_map[self._wwise_source_id] = unit
		end
	end)

	mod:hook_safe("WwiseWorld", "set_source_parameter", function(_, source_id, param, value)
		if param ~= "daemonhost_stage" then
			return
		end

		local stages = OUTLINE_TEMPLATES.minion.chaos_daemonhost.stages
		local template_id = stages[value]
		local template = OUTLINE_TEMPLATES.templates[template_id]

		if template then
			local unit = source_unit_map[source_id]

			if unit then
				danger_zone_track_source(template_id, unit, template.radius, unit)
			end
		end
	end)

	mod:hook_safe("Buff", "init", function(_, context, template)
		local breed_template = context.breed and OUTLINE_TEMPLATES.minion[context.breed.name]
		local template_id = breed_template and breed_template.buffs and breed_template.buffs[template.name]
		local template_data = OUTLINE_TEMPLATES.templates[template_id]

		if template_data then
			danger_zone_track_source(template_id, context.unit, template_data.radius, context.unit)
		end
	end)

	mod:hook_safe("HazardPropExtension", "set_content", function(self, content)
		local prop_template = OUTLINE_TEMPLATES.prop[content]
		local template_id = prop_template and prop_template.spawn
		local template = OUTLINE_TEMPLATES.templates[template_id]

		if template then
			danger_zone_track_source(
				template_id,
				self._unit,
				template.radius,
				self,
				{ hazard_state.idle, hazard_state.triggered }
			)
		end
	end)

	mod:hook_safe("HazardPropExtension", "set_current_state", function(self, state)
		local prop_template = OUTLINE_TEMPLATES.prop[self._content]
		local template_id = prop_template and prop_template.triggered
		local template = OUTLINE_TEMPLATES.templates[template_id]

		if not template then
			return
		end

		if state == hazard_state.triggered then
			danger_zone_track_source(
				template_id,
				self._unit,
				template.radius,
				self,
				{ hazard_state.triggered }
			)
		elseif state == hazard_state.exploding or state == hazard_state.broken then
			danger_zone_clear_source(self._unit)
		end
	end)
end

local DangerZoneRuntime = {
	scan = scan,
}

mod.danger_zone_runtime = DangerZoneRuntime

return DangerZoneRuntime
