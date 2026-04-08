local mod = get_mod("StimmCountdown")

local StimmCountdownCore = mod:io_dofile("StimmCountdown/scripts/mods/StimmCountdown/StimmCountdown_core")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local STIMM_SLOT_NAME = "slot_pocketable_small"
local STIMM_ICON_MATERIAL = "content/ui/materials/icons/pocketables/hud/syringe_broker"
local STIMM_READY_SOUND_EVENT_DEFAULT = "wwise/events/ui/play_hud_heal_2d"

local ACTIVE_COLOR = UIHudSettings.color_tint_main_1
local COOLDOWN_COLOR = UIHudSettings.color_tint_alert_2
local READY_COLOR = UIHudSettings.color_tint_main_2
local NOTIFICATION_LINE_DEFAULT = UIHudSettings.color_tint_main_2
local NOTIFICATION_ICON_DEFAULT = UIHudSettings.color_tint_main_2
local NOTIFICATION_TEXT_DEFAULT = UIHudSettings.color_tint_main_1
local NOTIFICATION_BACKGROUND_DEFAULT = Color.terminal_grid_background(180, true)

local settings_cache = {
	show_decimals = true,
	show_active = true,
	show_cooldown = true,
	show_ready_notification = true,
	enable_ready_override = false,
	enable_active_override = false,
	enable_cooldown_override = false,
	enable_notification_override = false,
	ready_countdown_color = READY_COLOR,
	ready_icon_color = READY_COLOR,
	active_countdown_color = ACTIVE_COLOR,
	active_icon_color = ACTIVE_COLOR,
	cooldown_countdown_color = COOLDOWN_COLOR,
	cooldown_icon_color = COOLDOWN_COLOR,
	notification_line_color = NOTIFICATION_LINE_DEFAULT,
	notification_icon_color = NOTIFICATION_ICON_DEFAULT,
	notification_background_color = NOTIFICATION_BACKGROUND_DEFAULT,
	notification_text_color = NOTIFICATION_TEXT_DEFAULT,
	enable_ready_sound = false,
	ready_sound_event = STIMM_READY_SOUND_EVENT_DEFAULT,
	font_type = "machine_medium",
	font_size = 30,
}

local function resolve_color_from_setting_value(value, fallback)
	if type(value) == "string" and Color[value] then
		return Color[value](255, true)
	end

	return fallback
end

local function refresh_settings()
	settings_cache.show_decimals = mod:get("show_decimals") ~= false
	settings_cache.show_active = mod:get("show_active") ~= false
	settings_cache.show_cooldown = mod:get("show_cooldown") ~= false
	settings_cache.show_ready_notification = mod:get("show_ready_notification") ~= false

	settings_cache.enable_ready_override = mod:get("enable_ready_color_override") == true
	settings_cache.enable_active_override = mod:get("enable_active_color_override") == true
	settings_cache.enable_cooldown_override = mod:get("enable_cooldown_color_override") == true

	settings_cache.ready_countdown_color = resolve_color_from_setting_value(mod:get("ready_countdown_color"), READY_COLOR)
	settings_cache.ready_icon_color = resolve_color_from_setting_value(mod:get("ready_icon_color"), READY_COLOR)
	settings_cache.active_countdown_color = resolve_color_from_setting_value(mod:get("active_countdown_color"), ACTIVE_COLOR)
	settings_cache.active_icon_color = resolve_color_from_setting_value(mod:get("active_icon_color"), ACTIVE_COLOR)
	settings_cache.cooldown_countdown_color = resolve_color_from_setting_value(mod:get("cooldown_countdown_color"), COOLDOWN_COLOR)
	settings_cache.cooldown_icon_color = resolve_color_from_setting_value(mod:get("cooldown_icon_color"), COOLDOWN_COLOR)

	settings_cache.enable_notification_override = mod:get("enable_notification_color_override") == true
	settings_cache.notification_line_color = resolve_color_from_setting_value(mod:get("notification_line_color"), NOTIFICATION_LINE_DEFAULT)
	settings_cache.notification_icon_color = resolve_color_from_setting_value(mod:get("notification_icon_color"), NOTIFICATION_ICON_DEFAULT)
	settings_cache.notification_background_color = resolve_color_from_setting_value(mod:get("notification_background_color"), NOTIFICATION_BACKGROUND_DEFAULT)
	settings_cache.notification_text_color = resolve_color_from_setting_value(mod:get("notification_text_color"), NOTIFICATION_TEXT_DEFAULT)
	settings_cache.enable_ready_sound = mod:get("enable_ready_sound") == true
	settings_cache.ready_sound_event = mod:get("ready_sound_event") or STIMM_READY_SOUND_EVENT_DEFAULT
	settings_cache.font_type = mod:get("font_type") or "machine_medium"
	settings_cache.font_size = mod:get("font_size") or 30
end

refresh_settings()

mod.stimm_countdown_api = {
	pocketable_profiles = {
		{
			id = "broker_syringe",
			archetype_name = "broker",
			ability_type = "pocketable_ability",
			ability_group = "broker_syringe",
			active_buff_template = "syringe_broker_buff",
		},
	},
	buff_entries = {
		{ template = "syringe_broker_buff", archetype_name = "broker" },
		{ template = "syringe_speed_boost_buff" },
		{ template = "syringe_power_boost_buff" },
		{ template = "syringe_ability_boost_buff" },
		{ template = "syringe_heal_corruption_buff" },
	},
	get_display_for_unit = function(player_unit)
		if mod.is_enabled and not mod:is_enabled() then
			return nil
		end

		local api = mod.stimm_countdown_api
		local settings = {
			show_active = mod:get("show_active") ~= false,
			show_cooldown = mod:get("show_cooldown") ~= false,
			show_decimals = mod:get("show_decimals") ~= false,
		}

		return StimmCountdownCore.compute_timer_display_for_consuming_mods(
			player_unit,
			settings,
			api.pocketable_profiles,
			api.buff_entries
		)
	end,
}

mod.on_setting_changed = function(setting_id)
	if setting_id == "reset_color_settings" then
		if mod:get("reset_color_settings") == 1 then
			mod:notify(mod:localize("reset_color_settings"))
			mod:set("reset_color_settings", 0)
			mod:set("enable_ready_color_override", false)
			mod:set("ready_icon_color", "ui_hud_green_light")
			mod:set("enable_active_color_override", false)
			mod:set("active_countdown_color", "ui_terminal_highlight")
			mod:set("active_icon_color", "ui_terminal_highlight")
			mod:set("enable_cooldown_color_override", false)
			mod:set("cooldown_countdown_color", "ui_interaction_critical")
			mod:set("cooldown_icon_color", "ui_interaction_critical")
			mod:set("enable_notification_color_override", false)
			mod:set("notification_text_color", "terminal_text_body")
			mod:set("notification_icon_color", "terminal_text_body")
			mod:set("notification_background_color", "terminal_grid_background")
			mod:set("notification_line_color", "terminal_corner_selected")
		end
	elseif setting_id == "reset_font_settings" then
		if mod:get("reset_font_settings") == 1 then
			mod:notify(mod:localize("reset_font_settings"))
			mod:set("reset_font_settings", 0)
			mod:set("font_type", "machine_medium")
			mod:set("font_size", 30)
		end
	elseif setting_id == "reset_sound_settings" then
		if mod:get("reset_sound_settings") == 1 then
			mod:notify(mod:localize("reset_sound_settings"))
			mod:set("reset_sound_settings", 0)
			mod:set("enable_ready_sound", false)
			mod:set("ready_sound_event", STIMM_READY_SOUND_EVENT_DEFAULT)
		end
	end
	refresh_settings()
end

local function colors_equal_rgba(a, b, include_alpha)
	if not a or not b then
		return false
	end

	local start_index = include_alpha and 1 or 2
	for i = start_index, 4 do
		if a[i] ~= b[i] then
			return false
		end
	end

	return true
end

local function set_existing_rgba(target, source, preserve_target_alpha)
	if not target or not source then
		return false
	end

	if preserve_target_alpha then
		if colors_equal_rgba(target, source, false) then
			return false
		end

		target[2] = source[2]
		target[3] = source[3]
		target[4] = source[4]

		return true
	end

	if colors_equal_rgba(target, source, true) then
		return false
	end

	target[1] = source[1]
	target[2] = source[2]
	target[3] = source[3]
	target[4] = source[4]

	return true
end

local function ensure_original_colors_saved(self, icon_widget, background_widget)
	if self._stimmcountdown_original_colors then
		return
	end

	local originals = {}

	if icon_widget and icon_widget.style then
		local icon_style = icon_widget.style.icon
		local icon_done_style = icon_widget.style.icon_cooldown_done

		if icon_style then
			originals.icon_color = icon_style.color and table.clone(icon_style.color) or nil
			originals.icon_default_color = icon_style.default_color and table.clone(icon_style.default_color) or nil
			originals.icon_highlight_color = icon_style.highlight_color and table.clone(icon_style.highlight_color) or nil
		end

		if icon_done_style then
			originals.icon_done_color = icon_done_style.color and table.clone(icon_done_style.color) or nil
			originals.icon_done_default_color = icon_done_style.default_color and table.clone(icon_done_style.default_color) or nil
			originals.icon_done_highlight_color = icon_done_style.highlight_color and table.clone(icon_done_style.highlight_color) or nil
		end
	end

	if background_widget and background_widget.style then
		local line_style = background_widget.style.line
		local bg_style = background_widget.style.background

		if line_style then
			originals.line_color = line_style.color and table.clone(line_style.color) or nil
			originals.line_default_color = line_style.default_color and table.clone(line_style.default_color) or nil
			originals.line_highlight_color = line_style.highlight_color and table.clone(line_style.highlight_color) or nil
		end

		if bg_style then
			originals.background_color = bg_style.color and table.clone(bg_style.color) or nil
		end
	end

	self._stimmcountdown_original_colors = originals
end

local function apply_icon_and_background_colors(self, icon_widget, background_widget, icon_color, line_color, bg_color)
	if not icon_color and not line_color and not bg_color then
		return
	end

	ensure_original_colors_saved(self, icon_widget, background_widget)
	self._stimmcountdown_has_overridden_colors = true

	local icon_dirty = false
	local background_dirty = false

	if icon_widget and icon_widget.style and icon_color then
		local icon_style = icon_widget.style.icon
		local icon_done_style = icon_widget.style.icon_cooldown_done

		if icon_style then
			if icon_style.color and not colors_equal_rgba(icon_style.color, icon_color, false) then
				icon_style.color = table.clone(icon_style.color)
				icon_dirty = set_existing_rgba(icon_style.color, icon_color, true) or icon_dirty
			end

			if icon_style.default_color and not colors_equal_rgba(icon_style.default_color, icon_color, false) then
				icon_style.default_color = table.clone(icon_style.default_color)
				icon_dirty = set_existing_rgba(icon_style.default_color, icon_color, true) or icon_dirty
			end

			if icon_style.highlight_color and not colors_equal_rgba(icon_style.highlight_color, icon_color, false) then
				icon_style.highlight_color = table.clone(icon_style.highlight_color)
				icon_dirty = set_existing_rgba(icon_style.highlight_color, icon_color, true) or icon_dirty
			end
		end

		if icon_done_style then
			if icon_done_style.color and not colors_equal_rgba(icon_done_style.color, icon_color, false) then
				icon_done_style.color = table.clone(icon_done_style.color)
				icon_dirty = set_existing_rgba(icon_done_style.color, icon_color, true) or icon_dirty
			end

			if icon_done_style.default_color and not colors_equal_rgba(icon_done_style.default_color, icon_color, false) then
				icon_done_style.default_color = table.clone(icon_done_style.default_color)
				icon_dirty = set_existing_rgba(icon_done_style.default_color, icon_color, true) or icon_dirty
			end

			if icon_done_style.highlight_color and not colors_equal_rgba(icon_done_style.highlight_color, icon_color, false) then
				icon_done_style.highlight_color = table.clone(icon_done_style.highlight_color)
				icon_dirty = set_existing_rgba(icon_done_style.highlight_color, icon_color, true) or icon_dirty
			end
		end
	end

	if background_widget and background_widget.style then
		local line_style = background_widget.style.line
		local bg_style = background_widget.style.background

		if line_style and line_color then
			if line_style.color and not colors_equal_rgba(line_style.color, line_color, false) then
				line_style.color = table.clone(line_style.color)
				background_dirty = set_existing_rgba(line_style.color, line_color, true) or background_dirty
			end

			if line_style.default_color and not colors_equal_rgba(line_style.default_color, line_color, false) then
				line_style.default_color = table.clone(line_style.default_color)
				background_dirty = set_existing_rgba(line_style.default_color, line_color, true) or background_dirty
			end

			if line_style.highlight_color and not colors_equal_rgba(line_style.highlight_color, line_color, false) then
				line_style.highlight_color = table.clone(line_style.highlight_color)
				background_dirty = set_existing_rgba(line_style.highlight_color, line_color, true) or background_dirty
			end
		end

		if bg_style and bg_style.color and bg_color then
			if not colors_equal_rgba(bg_style.color, bg_color, true) then
				bg_style.color = table.clone(bg_style.color)
				background_dirty = set_existing_rgba(bg_style.color, bg_color, false) or background_dirty
			end
		end
	end

	if icon_dirty and icon_widget then
		icon_widget.dirty = true
	end

	if background_dirty and background_widget then
		background_widget.dirty = true
	end
end

local function restore_original_colors(self, icon_widget, background_widget)
	if not self._stimmcountdown_has_overridden_colors then
		return
	end

	local originals = self._stimmcountdown_original_colors
	if not originals then
		self._stimmcountdown_has_overridden_colors = false
		return
	end

	local icon_dirty = false
	local background_dirty = false

	if icon_widget and icon_widget.style then
		local icon_style = icon_widget.style.icon
		local icon_done_style = icon_widget.style.icon_cooldown_done

		if icon_style then
			if icon_style.color and originals.icon_color and not colors_equal_rgba(icon_style.color, originals.icon_color, false) then
				icon_style.color = table.clone(icon_style.color)
				icon_dirty = set_existing_rgba(icon_style.color, originals.icon_color, true) or icon_dirty
			end

			if icon_style.default_color and originals.icon_default_color and not colors_equal_rgba(icon_style.default_color, originals.icon_default_color, false) then
				icon_style.default_color = table.clone(icon_style.default_color)
				icon_dirty = set_existing_rgba(icon_style.default_color, originals.icon_default_color, true) or icon_dirty
			end

			if icon_style.highlight_color and originals.icon_highlight_color and not colors_equal_rgba(icon_style.highlight_color, originals.icon_highlight_color, false) then
				icon_style.highlight_color = table.clone(icon_style.highlight_color)
				icon_dirty = set_existing_rgba(icon_style.highlight_color, originals.icon_highlight_color, true) or icon_dirty
			end
		end

		if icon_done_style then
			if icon_done_style.color and originals.icon_done_color and not colors_equal_rgba(icon_done_style.color, originals.icon_done_color, false) then
				icon_done_style.color = table.clone(icon_done_style.color)
				icon_dirty = set_existing_rgba(icon_done_style.color, originals.icon_done_color, true) or icon_dirty
			end

			if icon_done_style.default_color and originals.icon_done_default_color and not colors_equal_rgba(icon_done_style.default_color, originals.icon_done_default_color, false) then
				icon_done_style.default_color = table.clone(icon_done_style.default_color)
				icon_dirty = set_existing_rgba(icon_done_style.default_color, originals.icon_done_default_color, true) or icon_dirty
			end

			if icon_done_style.highlight_color and originals.icon_done_highlight_color and not colors_equal_rgba(icon_done_style.highlight_color, originals.icon_done_highlight_color, false) then
				icon_done_style.highlight_color = table.clone(icon_done_style.highlight_color)
				icon_dirty = set_existing_rgba(icon_done_style.highlight_color, originals.icon_done_highlight_color, true) or icon_dirty
			end
		end
	end

	if background_widget and background_widget.style then
		local line_style = background_widget.style.line
		local bg_style = background_widget.style.background

		if line_style then
			if line_style.color and originals.line_color and not colors_equal_rgba(line_style.color, originals.line_color, false) then
				line_style.color = table.clone(line_style.color)
				background_dirty = set_existing_rgba(line_style.color, originals.line_color, true) or background_dirty
			end

			if line_style.default_color and originals.line_default_color and not colors_equal_rgba(line_style.default_color, originals.line_default_color, false) then
				line_style.default_color = table.clone(line_style.default_color)
				background_dirty = set_existing_rgba(line_style.default_color, originals.line_default_color, true) or background_dirty
			end

			if line_style.highlight_color and originals.line_highlight_color and not colors_equal_rgba(line_style.highlight_color, originals.line_highlight_color, false) then
				line_style.highlight_color = table.clone(line_style.highlight_color)
				background_dirty = set_existing_rgba(line_style.highlight_color, originals.line_highlight_color, true) or background_dirty
			end
		end

		if bg_style and bg_style.color and originals.background_color then
			if not colors_equal_rgba(bg_style.color, originals.background_color, true) then
				bg_style.color = table.clone(bg_style.color)
				bg_style.color[1] = originals.background_color[1]
				bg_style.color[2] = originals.background_color[2]
				bg_style.color[3] = originals.background_color[3]
				bg_style.color[4] = originals.background_color[4]
				background_dirty = true
			end
		end
	end

	if icon_dirty and icon_widget then
		icon_widget.dirty = true
	end

	if background_dirty and background_widget then
		background_widget.dirty = true
	end

	self._stimmcountdown_has_overridden_colors = false
end

local add_definitions = function(definitions)
	if not definitions then
		return
	end

	definitions.scenegraph_definition = definitions.scenegraph_definition or {}
	definitions.widget_definitions = definitions.widget_definitions or {}

	local stimm_timer_text_style = table.clone(UIFontSettings.hud_body)
	stimm_timer_text_style.font_type = settings_cache.font_type
	stimm_timer_text_style.font_size = settings_cache.font_size
	stimm_timer_text_style.drop_shadow = true
	stimm_timer_text_style.text_horizontal_alignment = "right"
	stimm_timer_text_style.text_vertical_alignment = "center"
	stimm_timer_text_style.text_color = table.clone(COOLDOWN_COLOR)
	stimm_timer_text_style.offset = { -60, 0, 10 }

	definitions.widget_definitions.stimm_timer = UIWidget.create_definition({
		{
			visible = false,
			pass_type = "text",
			style_id = "text",
			value = "",
			value_id = "text",
			style = stimm_timer_text_style,
		},
	}, "background")
end

mod:hook_require(
	"scripts/ui/hud/elements/player_weapon/hud_element_player_weapon_definitions",
	function(definitions)
		add_definitions(definitions)
	end
)

local function play_sound_event(event_name, ui_element)
	if not event_name or event_name == "" then
		return false
	end

	if ui_element and ui_element._play_sound then
		ui_element:_play_sound(event_name)
		return true
	end

	local world_manager = Managers.world
	if not world_manager or not world_manager.world then
		return false
	end

	local world = world_manager:world("level_world")
	if not world or not world_manager.wwise_world then
		return false
	end

	local wwise_world = world_manager:wwise_world(world)
	if not wwise_world then
		return false
	end

	WwiseWorld.trigger_resource_event(wwise_world, event_name)
	return true
end

mod:hook_safe("HudElementPlayerWeapon", "update", function(self, dt, t, ui_renderer, render_settings, input_service)
	if not self._slot_name or self._slot_name ~= STIMM_SLOT_NAME then
		return
	end

	local widgets_by_name = self._widgets_by_name
	if not widgets_by_name then
		return
	end

	local widget = widgets_by_name.stimm_timer
	if not widget then
		return
	end

	local icon_widget = widgets_by_name.icon
	local background_widget = widgets_by_name.background

	if mod.is_enabled and not mod:is_enabled() then
		restore_original_colors(self, icon_widget, background_widget)
		widget.content.text = ""
		widget.content.visible = false
		widget.visible = false
		widget.dirty = true
		return
	end

	local data = self._data
	if not data then
		restore_original_colors(self, icon_widget, background_widget)
		widget.content.visible = false
		return
	end

	local player = Managers.player:local_player(1)
	if not player or not player:unit_is_alive() then
		restore_original_colors(self, icon_widget, background_widget)
		widget.content.visible = false
		return
	end

	local player_unit = player.player_unit

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
	if not buff_extension then
		restore_original_colors(self, icon_widget, background_widget)
		widget.content.visible = false
		return
	end

	local tr = StimmCountdownCore.compute_pocketable_stimm_timer_state(player_unit, {
		show_active = settings_cache.show_active,
		show_cooldown = settings_cache.show_cooldown,
		show_decimals = settings_cache.show_decimals,
	}, mod.stimm_countdown_api.pocketable_profiles)

	if not tr.has_matched_pocketable then
		restore_original_colors(self, icon_widget, background_widget)
		widget.content.text = ""
		widget.content.visible = false
		widget.visible = false
		widget.dirty = true
		return
	end

	local display_text = tr.text
	local display_color = COOLDOWN_COLOR
	local should_show = tr.visible

	local show_ready_notification = settings_cache.show_ready_notification

	local enable_ready_override = settings_cache.enable_ready_override
	local enable_active_override = settings_cache.enable_active_override
	local enable_cooldown_override = settings_cache.enable_cooldown_override

	local ready_icon_color = settings_cache.ready_icon_color
	local active_countdown_color = settings_cache.active_countdown_color
	local active_icon_color = settings_cache.active_icon_color
	local cooldown_countdown_color = settings_cache.cooldown_countdown_color
	local cooldown_icon_color = settings_cache.cooldown_icon_color
	local enable_notification_override = settings_cache.enable_notification_override
	local notification_line_color = settings_cache.notification_line_color
	local notification_icon_color = settings_cache.notification_icon_color
	local notification_background_color = settings_cache.notification_background_color
	local notification_text_color = settings_cache.notification_text_color
	local enable_ready_sound = settings_cache.enable_ready_sound
	local ready_sound_event = settings_cache.ready_sound_event
	local icon_color_to_apply = nil
	local line_color_to_apply = nil
	local bg_color_to_apply = nil

	local has_cooldown = tr.has_cooldown
	local is_ready = tr.is_ready

	if tr.phase == "active" then
		display_color = enable_active_override and active_countdown_color or ACTIVE_COLOR

		if enable_active_override then
			icon_color_to_apply = active_icon_color
			line_color_to_apply = active_icon_color
			bg_color_to_apply = active_icon_color
		end
	elseif tr.is_ready then
		if enable_ready_override then
			icon_color_to_apply = ready_icon_color
			line_color_to_apply = ready_icon_color
			bg_color_to_apply = ready_icon_color
		end
	elseif tr.phase == "cooldown" then
		display_color = enable_cooldown_override and cooldown_countdown_color or COOLDOWN_COLOR

		if enable_cooldown_override then
			icon_color_to_apply = cooldown_icon_color
			line_color_to_apply = cooldown_icon_color
			bg_color_to_apply = cooldown_icon_color
		end
	end

	if has_cooldown then
		if not self._stimmcountdown_was_on_cooldown then
			self._stimmcountdown_was_on_cooldown = true
		end
	elseif self._stimmcountdown_was_on_cooldown then
		self._stimmcountdown_was_on_cooldown = false
		if is_ready and enable_ready_sound then
			play_sound_event(ready_sound_event, self)
		end
	end

	if show_ready_notification then
		if self._stimm_ready_prev == nil then
			self._stimm_ready_prev = is_ready
			self._stimm_prev_has_cooldown = has_cooldown
		else
			local became_ready_after_cooldown = is_ready and not self._stimm_ready_prev and (self._stimm_prev_has_cooldown or has_cooldown)

			if became_ready_after_cooldown then
				local line_color = enable_notification_override and notification_line_color or NOTIFICATION_LINE_DEFAULT
				local icon_color = enable_notification_override and notification_icon_color or NOTIFICATION_ICON_DEFAULT
				local background_color = enable_notification_override and notification_background_color or NOTIFICATION_BACKGROUND_DEFAULT
				local text_color = enable_notification_override and notification_text_color or NOTIFICATION_TEXT_DEFAULT
				local line_1_text = mod:localize("stimm_ready_notification")
				line_1_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", text_color[2], text_color[3], text_color[4], line_1_text)

				Managers.event:trigger("event_add_notification_message", "custom", {
					icon = STIMM_ICON_MATERIAL,
					icon_size = "currency",
					color = table.clone(background_color),
					line_color = table.clone(line_color),
					icon_color = table.clone(icon_color),
					line_1 = line_1_text,
					show_shine = true,
				})
			end

			self._stimm_ready_prev = is_ready
			self._stimm_prev_has_cooldown = has_cooldown
		end
	end

	if icon_color_to_apply or line_color_to_apply or bg_color_to_apply then
		apply_icon_and_background_colors(self, icon_widget, background_widget, icon_color_to_apply, line_color_to_apply, bg_color_to_apply)
	else
		restore_original_colors(self, icon_widget, background_widget)
	end

	if not should_show then
		widget.content.text = ""
		widget.content.visible = false
		widget.visible = false
		widget.dirty = true
		return
	end

	local text_style = widget.style.text
	local text_content = widget.content
	local text_color = text_style.text_color

	text_content.text = display_text
	text_content.visible = true
	widget.visible = true

	if not colors_equal_rgba(text_color, display_color, true) then
		text_color[1] = display_color[1]
		text_color[2] = display_color[2]
		text_color[3] = display_color[3]
		text_color[4] = display_color[4]
	end

	local font_type = settings_cache.font_type
	local font_size = settings_cache.font_size

	if text_style.font_type ~= font_type then
		text_style.font_type = font_type
	end

	if text_style.font_size ~= font_size then
		text_style.font_size = font_size
	end

	local height_offset = self._height_offset or 0
	if text_style.offset[2] ~= height_offset then
		text_style.offset[2] = height_offset
	end

	widget.dirty = true
end)

