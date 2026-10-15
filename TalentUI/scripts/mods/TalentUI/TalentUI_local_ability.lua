local mod = get_mod("TalentUI")

local PLAYER_ABILITY_DEF_PATH = "scripts/ui/hud/elements/player_ability/hud_element_player_ability_vertical_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local FixedFrame = require("scripts/utilities/fixed_frame")
local ProjectileTemplates = require("scripts/settings/projectile/projectile_templates")
local StimmFieldCrateUnitTemplate = require("scripts/extension_systems/unit_templates/broker_stimm_field_crate_deployable_unit_template")
local TalentSettings = require("scripts/settings/talent/talent_settings")

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

local ACTIVE_COLOR = UIHudSettings.color_tint_main_1
local COOLDOWN_COLOR = UIHudSettings.color_tint_alert_2
local NOTIFICATION_LINE_DEFAULT = UIHudSettings.color_tint_main_2
local NOTIFICATION_ICON_DEFAULT = UIHudSettings.color_tint_main_2
local NOTIFICATION_TEXT_DEFAULT = UIHudSettings.color_tint_main_1
local NOTIFICATION_BACKGROUND_DEFAULT = Color.terminal_grid_background(180, true)

local math_ceil, math_floor = math.ceil, math.floor
local string_format = string.format

local function clone_color(color)
	return {
		color[1],
		color[2],
		color[3],
		color[4],
	}
end

-- Cached local ability settings; refreshed on load and from mod.on_setting_changed
local show_local_ability_cooldown
local show_local_ability_active
local show_local_ability_decimals
local show_local_ability_ready_notification
local cooldown_format
local local_cooldown_font_size

local function refresh_local_ability_settings()
	show_local_ability_cooldown = mod:get("show_local_ability_cooldown")
	show_local_ability_active = mod:get("show_local_ability_active") ~= false
	show_local_ability_decimals = mod:get("show_local_ability_decimals") ~= false
	show_local_ability_ready_notification = mod:get("show_local_ability_ready_notification") ~= false
	cooldown_format = mod:get("cooldown_format")
	local_cooldown_font_size = mod:get("local_cooldown_font_size") or TalentUISettings.local_cooldown_font_size
end

refresh_local_ability_settings()

mod.refresh_local_ability_settings = refresh_local_ability_settings

mod:hook(_G, "dofile", function(func, path)
	local instance = func(path)
	
	if path == PLAYER_ABILITY_DEF_PATH then
		local style = table.clone(UIFontSettings.hud_body)
		style.text_horizontal_alignment = "center"
		style.text_vertical_alignment = "center"
		style.font_size = local_cooldown_font_size
		style.font_type = "machine_medium"
		style.drop_shadow = true
		
		instance.scenegraph_definition.cooldown = {
			parent = "slot",
			vertical_alignment = "center",
			horizontal_alignment = "center",
			size = HudElementPlayerAbilitySettings.icon_size,
			position = {
				0,
				0,
				10,
			},
		}
		
		instance.widget_definitions.talentui_cooldown_timer = UIWidget.create_definition({
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = "",
				style = style,
			},
		}, "cooldown")
	end
	
	return instance
end)

local ACTIVE_BUFF_SCAN_INTERVAL = 0.1
local CHORUS_ACTION_NAME = "action_zealot_channel"

-- The active timer below mirrors NumericUI's (PlayerAbility.lua), with each time function also returning the effect's
-- full duration for the percent format.

-- Combat abilities whose action code adds their timed buff, so the ability settings don't name it. Only the buff
-- names live here; the remaining time is always read from the live buff. The Skitarius' Chordclaw is left out on
-- purpose: its 10 s buff only caps how long the claw can stay out, it is no lingering effect.
local ACTIVE_BUFFS_BY_ABILITY = {
	veteran_combat_ability_stance = {
		"veteran_combat_ability_stance_master",
		"veteran_combat_ability_stance_master_increased_duration",
	},
	veteran_combat_ability_stance_improved = {
		"veteran_combat_ability_stance_master",
		"veteran_combat_ability_stance_master_increased_duration",
	},
	veteran_combat_ability_stealth = { "veteran_invisibility" },
}

local function get_player_extension(self, system_name)
	return self._parent:get_player_extension(self._data.player, system_name)
end

-- Vanilla's own ability HUD keeps the ability from reading as on cooldown while this buff runs (Hive Scum stances)
local function has_duration_tracking_buff(buff_extension, pause_cooldown_settings)
	local duration_tracking_buff = pause_cooldown_settings and pause_cooldown_settings.duration_tracking_buff

	if not duration_tracking_buff or not buff_extension then
		return false
	end

	if type(duration_tracking_buff) == "table" then
		for i = 1, #duration_tracking_buff do
			if buff_extension:current_stacks(duration_tracking_buff[i]) > 0 then
				return true
			end
		end

		return false
	end

	return buff_extension:current_stacks(duration_tracking_buff) > 0
end

-- per ability name: the set of buff template names that carry its active effect, or false when it has none
local active_buff_names_by_ability = {}

local function get_active_buff_names(ability)
	local ability_name = ability.name
	local buff_names = active_buff_names_by_ability[ability_name]

	if buff_names ~= nil then
		return buff_names
	end

	buff_names = {}

	-- the buff a stance-like ability applies, and the buff whose duration vanilla's own ability HUD tracks
	local tweak_data = ability.ability_template_tweak_data
	local buff_to_add = tweak_data and tweak_data.buff_to_add

	if buff_to_add then
		buff_names[buff_to_add] = true
	end

	local pause_cooldown_settings = ability.pause_cooldown_settings
	local duration_tracking_buff = pause_cooldown_settings and pause_cooldown_settings.duration_tracking_buff

	if type(duration_tracking_buff) == "table" then
		for i = 1, #duration_tracking_buff do
			buff_names[duration_tracking_buff[i]] = true
		end
	elseif duration_tracking_buff then
		buff_names[duration_tracking_buff] = true
	end

	local extra_buff_names = ACTIVE_BUFFS_BY_ABILITY[ability_name]

	if extra_buff_names then
		for i = 1, #extra_buff_names do
			buff_names[extra_buff_names[i]] = true
		end
	end

	if next(buff_names) == nil then
		buff_names = false
	end

	active_buff_names_by_ability[ability_name] = buff_names

	return buff_names
end

local function find_active_buff(self)
	local buff_extension = get_player_extension(self, "buff_system")

	if not buff_extension then
		return nil
	end

	local buff_names = self._talentui_active_buff_names
	local buffs = buff_extension:buffs()

	for i = 1, #buffs do
		local buff = buffs[i]

		if buff_names[buff:template_name()] then
			return buff
		end
	end

	return nil
end

-- Read from the ability's live buff, so duration talents, extensions and early ends count exactly as the game counts
-- them. The buff is cached on the element and looked for again at most every ACTIVE_BUFF_SCAN_INTERVAL
local function get_buff_time_remaining(self, t)
	local buff = self._talentui_active_buff

	-- a deleted buff ended early or was replaced by a recast, so look for its successor straight away
	if buff and rawget(buff, "__deleted") then
		buff = nil
		self._talentui_active_buff = nil
		self._talentui_active_buff_scan_t = nil
	end

	if not buff then
		local scan_t = self._talentui_active_buff_scan_t

		if scan_t and t < scan_t then
			return nil
		end

		buff = find_active_buff(self)
		self._talentui_active_buff = buff
		self._talentui_active_buff_scan_t = t + ACTIVE_BUFF_SCAN_INTERVAL

		if not buff then
			return nil
		end
	end

	-- Scrier's Gaze and Precision Stance have no duration; they end on peril or when their resource runs out
	local duration = buff:duration()

	if duration then
		return buff:start_time() + duration - t, duration
	end

	return nil
end

-- Chorus is a channel action, whose end time already includes any action speed change. Cancelling it ends it.
local function get_chorus_time_remaining(self, t)
	local unit_data_extension = get_player_extension(self, "unit_data_system")
	local weapon_action_component = unit_data_extension and unit_data_extension:read_component("weapon_action")

	if weapon_action_component and weapon_action_component.current_action_name == CHORUS_ACTION_NAME then
		local end_t = weapon_action_component.end_t

		return end_t - t, end_t - weapon_action_component.start_t
	end

	return nil
end

-- Every Telekine Shield keeps its remaining duration on its own extension, synced to clients by the server. With
-- two up, the one deployed first runs out first.
local function get_telekine_shield_time_remaining(self)
	local extension_manager = Managers.state.extension
	local force_field_system = extension_manager and extension_manager:system("force_field_system")
	local player_unit = self._data.player.player_unit

	if not force_field_system or not player_unit then
		return nil
	end

	local remaining, total

	for _, extension in pairs(force_field_system:unit_to_extension_map()) do
		if extension.owner_unit == player_unit then
			local shield_remaining = extension:remaining_duration()

			if shield_remaining and shield_remaining > 0 and (not remaining or shield_remaining < remaining) then
				remaining = shield_remaining
				total = extension._max_duration
			end
		end
	end

	return remaining, total
end

-- The local player's Nuncio-Aquila drones and Stimm Field crates by unit, with the fixed time each one's lifetime
-- ends and its full lifetime. Both lifetimes run on the server only, so the clock is started where the server starts
-- it: when the drone deploys and when the crate spawns. A client sees both slightly later than the server, so its
-- timer is an estimate.
local drone_lifetimes = {}
local stimm_field_lifetimes = {}

local function get_local_player_owner_unit(unit)
	local owner = Managers.state.player_unit_spawn:owner(unit)

	if owner and owner == Managers.player:local_player(1) then
		return owner.player_unit
	end

	return nil
end

-- Seconds until the first of the tracked units runs out. A unit stays tracked while the local player owns it: the
-- game releases the ownership when the unit is destroyed, and every mission starts with a new spawn manager, so an
-- end time left over from an earlier mission's clock is dropped as well.
local function get_tracked_time_remaining(lifetimes, t)
	local player_unit_spawn_manager = Managers.state.player_unit_spawn
	local local_player = Managers.player:local_player(1)
	local remaining, total

	for unit, lifetime in pairs(lifetimes) do
		local unit_remaining = lifetime.end_t - t

		if unit_remaining <= 0 or not player_unit_spawn_manager or player_unit_spawn_manager:owner(unit) ~= local_player then
			lifetimes[unit] = nil
		elseif not remaining or unit_remaining < remaining then
			remaining = unit_remaining
			total = lifetime.duration
		end
	end

	return remaining, total
end

local function get_drone_time_remaining(_self, t)
	return get_tracked_time_remaining(drone_lifetimes, t)
end

local function get_stimm_field_time_remaining(_self, t)
	return get_tracked_time_remaining(stimm_field_lifetimes, t)
end

local function is_active_timer_enabled()
	return show_local_ability_cooldown and show_local_ability_active
end

local area_buff_drone = ProjectileTemplates.area_buff_drone
local area_buff_drone_deployable = area_buff_drone and area_buff_drone.deployable

if area_buff_drone_deployable and area_buff_drone_deployable.deploy_func then
	-- the server registers the drone's lifetime job here, and clients run the same function when they see it deploy
	mod:hook_safe(area_buff_drone_deployable, "deploy_func", function(_world, _physics_world, unit)
		if is_active_timer_enabled() and get_local_player_owner_unit(unit) then
			local duration = TalentSettings.adamant.blitz_ability.drone.duration

			drone_lifetimes[unit] = {
				end_t = FixedFrame.get_latest_fixed_time() + duration,
				duration = duration,
			}
		end
	end)
end

local function track_stimm_field(unit)
	if not is_active_timer_enabled() then
		return
	end

	local owner_unit = get_local_player_owner_unit(unit)

	if not owner_unit then
		return
	end

	-- the life time ProximityBrokerStimmField.init picks
	local settings = TalentSettings.broker.combat_ability.stimm_field
	local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")
	local life_time = talent_extension and talent_extension:has_special_rule("broker_stimm_field_linger") and settings.sub_1_life_time or settings.life_time

	stimm_field_lifetimes[unit] = {
		end_t = FixedFrame.get_latest_fixed_time() + life_time,
		duration = life_time,
	}
end

-- As the server, which registers the field's lifetime job when the crate has spawned
mod:hook_safe(StimmFieldCrateUnitTemplate, "local_unit_spawned", track_stimm_field)

-- As a client
mod:hook_safe(StimmFieldCrateUnitTemplate, "husk_init", track_stimm_field)

-- Combat abilities whose effect is no buff on the player
local ACTIVE_TIME_FUNCS = {
	zealot_relic = get_chorus_time_remaining,
	psyker_force_field = get_telekine_shield_time_remaining,
	psyker_force_field_improved = get_telekine_shield_time_remaining,
	psyker_force_field_dome = get_telekine_shield_time_remaining,
	adamant_area_buff_drone = get_drone_time_remaining,
	broker_ability_stimm_field = get_stimm_field_time_remaining,
}

-- How the equipped ability's active time is read. It is cached on the element, which the ability handler recreates
-- when the ability changes. Nil until the ability is equipped, false for abilities without a timed effect.
local function get_active_time_func(self, ability_extension, ability_type)
	local time_func = self._talentui_active_time_func

	if time_func ~= nil then
		return time_func
	end

	local ability = ability_extension and ability_extension:ability_is_equipped(ability_type)

	if not ability then
		return nil
	end

	time_func = ACTIVE_TIME_FUNCS[ability.name]

	if not time_func then
		local buff_names = get_active_buff_names(ability)

		self._talentui_active_buff_names = buff_names
		time_func = buff_names and get_buff_time_remaining or false
	end

	self._talentui_active_time_func = time_func

	return time_func
end

-- Seconds left on the combat ability's active effect and its full duration (nil when unknown), or nil when nothing
-- is running
local function get_active_time_remaining(self, ability_extension, ability_type)
	local time_func = get_active_time_func(self, ability_extension, ability_type)

	if not time_func then
		return nil
	end

	local remaining, total = time_func(self, FixedFrame.get_latest_fixed_time())

	if remaining and remaining > 0 then
		return remaining, total
	end

	return nil
end

-- Seconds until the next charge at the ability's base recharge speed, mirroring NumericUI's
-- mod.ability_charge_time_remaining and the time vanilla's max_regen_time_for_ability_charge gives a charge, which the
-- teammate timer shows as well. Recharge speed buffs, permanent or timed, are left out: the game still applies them to
-- the live missing resource, so they make the countdown run faster than the clock instead of shortening it or making it
-- jump when they end, and it still reaches zero when the charge is ready. Returns nil while no charge is regenerating,
-- regen is paused, or the active ability drains its own resource. Only pass the local player's extension: husks error
-- on get_ability_resource_cost_per_second.
local function get_charge_time_remaining(ability_extension, ability_type)
	if not ability_extension then
		return nil
	end

	local missing_resource = ability_extension:missing_ability_resource_until_next_charge(ability_type)

	if not missing_resource or missing_resource <= 0 or ability_extension:is_ability_resource_regen_paused(ability_type) then
		return nil
	end

	local ability = ability_extension:ability_is_equipped(ability_type)

	if not ability then
		return nil
	end

	local regen_per_second = (ability.resource_regen_per_second or 0) + ability_extension:max_ability_resource(ability_type) * (ability.resource_regen_percent_per_second or 0)
	local resource_cost_per_second = ability_extension:get_ability_resource_cost_per_second(ability_type)

	-- an active ability draining its own resource, like the Skitarius' Precision Stance, is spending its charge rather
	-- than recharging it, so there is nothing to count down, just as while regen is paused
	if resource_cost_per_second > 0 and ability_extension:is_ability_active(ability_type) then
		return nil
	end

	regen_per_second = regen_per_second - resource_cost_per_second

	if regen_per_second <= 0 then
		return nil
	end

	return missing_resource / regen_per_second
end

local function format_display_text(display_kind, display_value)
	if display_kind == "percent" then
		return string_format("%d%%", display_value)
	elseif display_kind == "tenths" then
		return string_format("%.1f", display_value / 10)
	end

	return string_format("%d", display_value)
end

-- Seconds as the kind and whole value the text shows, so the text is only formatted again when that value changes
local function get_time_display(seconds)
	if show_local_ability_decimals then
		return "tenths", math_floor(seconds * 10 + 0.5)
	end

	return "seconds", math_ceil(seconds)
end

-- A nil display_kind hides the text. The retained widget is only marked dirty when something it shows changes
local function set_text_widget(text_widget, display_kind, display_value, display_color)
	local content = text_widget.content

	if content._talentui_kind ~= display_kind or content._talentui_value ~= display_value then
		content._talentui_kind = display_kind
		content._talentui_value = display_value
		content.text = display_kind and format_display_text(display_kind, display_value) or ""
		text_widget.dirty = true
	end

	local text_style = text_widget.style.text

	if display_color and text_style.text_color ~= display_color then
		text_style.text_color = display_color
		text_widget.dirty = true
	end

	-- the definition reads the font size only when the HUD is created, so a changed setting is applied here
	if text_style.font_size ~= local_cooldown_font_size then
		text_style.font_size = local_cooldown_font_size
		text_widget.dirty = true
	end

	local visible = display_kind ~= nil

	if text_widget.visible ~= visible then
		text_widget.visible = visible
		text_widget.dirty = true
	end
end

mod:hook_safe("HudElementPlayerAbility", "update", function(self)
	local text_widget = self._widgets_by_name.talentui_cooldown_timer

	if not text_widget then
		return
	end

	if not show_local_ability_cooldown then
		-- hides what was shown when the setting was turned off
		if text_widget.visible then
			set_text_widget(text_widget, nil, nil, nil)
		end

		return
	end

	local player = self._data.player
	local player_unit = player.player_unit
	local parent = self._parent
	-- 1.13.0 renamed HudElementPlayerAbility._ability_id to _ability_type
	local ability_type = self._ability_type or self._ability_id

	if not rawget(_G, "ALIVE") or not ALIVE[player_unit] then
		set_text_widget(text_widget, nil, nil, nil)
		return
	end

	local ability_extension = parent:get_player_extension(player, "ability_system")
	local buff_extension = parent:get_player_extension(player, "buff_system")

	local progress = self._ability_progress
	local on_cooldown = self._on_cooldown

	local display_kind, display_value
	local display_color = COOLDOWN_COLOR
	local is_active = false
	local has_active_buff = false

	if ability_extension and ability_extension:ability_is_equipped(ability_type) then
		has_active_buff = has_duration_tracking_buff(buff_extension, ability_extension:ability_pause_cooldown_settings(ability_type))

		if show_local_ability_active then
			local active_time_remaining, active_duration = get_active_time_remaining(self, ability_extension, ability_type)

			if active_time_remaining then
				is_active = true
				display_color = ACTIVE_COLOR

				if cooldown_format == "percent" and active_duration and active_duration > 0 then
					display_kind, display_value = "percent", math_floor(active_time_remaining / active_duration * 100)
				else
					display_kind, display_value = get_time_display(active_time_remaining)
				end
			end
		end
	end

	-- 1.13.0 vanilla _on_cooldown is false while any charge is usable; keep treating a recharging extra charge as cooldown (pre-1.13 behavior)
	if not on_cooldown and progress and progress ~= 1 then
		local in_process_of_going_on_cooldown = has_active_buff and progress > 0
		on_cooldown = not in_process_of_going_on_cooldown
	end

	if not is_active and on_cooldown and progress < 1 then
		if cooldown_format == "time" then
			-- nil while regen is paused or Precision Stance drains its charge, which shows nothing
			local time_remaining = get_charge_time_remaining(ability_extension, ability_type)

			if time_remaining then
				display_kind, display_value = get_time_display(time_remaining)
			end
		elseif cooldown_format == "percent" then
			display_kind, display_value = "percent", math_floor(progress * 100)
		end
	end

	set_text_widget(text_widget, display_kind, display_value, display_color)

	-- vanilla's tracked stance rather than the active timer, so an ability that recharges while its effect still runs
	-- (kills extending Volley Fire) still notifies when it is ready
	local is_ready = not on_cooldown and progress >= 1 and not has_active_buff

	if show_local_ability_ready_notification then
		if self._ability_ready_prev == nil then
			self._ability_ready_prev = is_ready
			self._ability_prev_on_cooldown = on_cooldown
		else
			local became_ready_after_cooldown = is_ready and not self._ability_ready_prev and (self._ability_prev_on_cooldown or on_cooldown)

			if became_ready_after_cooldown then
				local line_color = clone_color(NOTIFICATION_LINE_DEFAULT)
				local icon_color = clone_color(NOTIFICATION_ICON_DEFAULT)
				local background_color = clone_color(NOTIFICATION_BACKGROUND_DEFAULT)
				local text_color = clone_color(NOTIFICATION_TEXT_DEFAULT)
				local line_1_text = mod:localize("local_ability_ready_notification")
				line_1_text = string_format("{#color(%d,%d,%d)}%s{#reset()}", text_color[2], text_color[3], text_color[4], line_1_text)

				local notification_data = {
					icon_size = "currency",
					color = background_color,
					line_color = line_color,
					icon_color = icon_color,
					line_1 = line_1_text,
					show_shine = true,
				}

				Managers.event:trigger("event_add_notification_message", "custom", notification_data)
			end

			self._ability_ready_prev = is_ready
			self._ability_prev_on_cooldown = on_cooldown
		end
	end
end)

