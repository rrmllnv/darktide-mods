local mod = get_mod("DivisionHUD")

require("scripts/ui/hud/elements/hud_element_base")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local Ammo = require("scripts/utilities/ammo")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")

local DIVISION_STIMM_TIMER_ACTIVE_COLOR = UIHudSettings.color_tint_main_2
local DIVISION_STIMM_TIMER_COOLDOWN_COLOR = UIHudSettings.color_tint_alert_2
local DIVISION_SLOT_COUNTER_TEXT_COLOR_DEFAULT = UIHudSettings.color_tint_main_1

local DIVISION_STIMM_SLOT_TYPE_COLORS = {
	syringe_corruption_pocketable = { 255, 38, 205, 26 },
	syringe_ability_boost_pocketable = { 255, 230, 192, 13 },
	syringe_power_boost_pocketable = { 255, 205, 51, 26 },
	syringe_speed_boost_pocketable = { 255, 0, 127, 218 },
	syringe_broker_pocketable = { 255, 208, 69, 255 },
}

local Definitions = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/definitions")
local SlotData = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/core/slot_data")
local VanillaStaminaDodge = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/widgets/vanilla_stamina_dodge")
local VanillaToughnessHealth = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/widgets/vanilla_toughness_health")
local DivisionHUDSettingsDefaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/settings_defaults")

if type(DivisionHUDSettingsDefaults) ~= "table" then
	DivisionHUDSettingsDefaults = {}
end

local DynamicHudContext = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/context/dynamic_hud")
local GameFlowContext = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/context/game_flow")

local HudElementDivisionHUD = class("HudElementDivisionHUD", "HudElementBase")

local ROOT_LAYOUT_OFFSET_X = Definitions.ROOT_LAYOUT_OFFSET_X
local ROOT_LAYOUT_OFFSET_Y = Definitions.ROOT_LAYOUT_OFFSET_Y
local ROOT_LAYOUT_OFFSET_Z = Definitions.ROOT_LAYOUT_OFFSET_Z

local BAR_WIDTH = Definitions.BAR_WIDTH
local ABILITY_BAR_MAX_SEGMENTS = Definitions.ABILITY_BAR_MAX_SEGMENTS
local ABILITY_BAR_SEGMENT_GAP = Definitions.ABILITY_BAR_SEGMENT_GAP
local RIGHT_SLOT_COUNT = Definitions.RIGHT_SLOT_COUNT
local right_slot_widget_names = Definitions.right_slot_widget_names

local COMBAT_ABILITY_TYPE = "combat_ability"
local GRENADE_ABILITY_TYPE = "grenade_ability"

local HUD_LAYOUT_SCALE = Definitions.HUD_LAYOUT_SCALE or 1

local ABILITY_BAR_READY_COLOR = { 255, 231, 145, 26 }
local ABILITY_BAR_COOLDOWN_COLOR = { 255, 215, 80, 80 }

local function division_hud_compute_combat_ability_cooldown_state(ability_extension, buff_extension, ability_id)
	local state = {
		equipped = false,
		cooldown_progress = 0,
		uses_charges = false,
		has_charges_left = true,
		in_process_of_going_on_cooldown = false,
		force_on_cooldown = false,
		remaining_ability_charges = 0,
		max_ability_charges = 0,
		max_ability_cooldown = 0,
	}

	if not ability_extension or not ability_extension:ability_is_equipped(ability_id) then
		return state
	end

	state.equipped = true

	local remaining_ability_cooldown = ability_extension:remaining_ability_cooldown(ability_id)
	local max_ability_cooldown = ability_extension:max_ability_cooldown(ability_id)
	local is_paused = ability_extension:is_cooldown_paused(ability_id)
	local remaining_ability_charges = ability_extension:remaining_ability_charges(ability_id)
	local max_ability_charges = ability_extension:max_ability_charges(ability_id)

	state.remaining_ability_charges = remaining_ability_charges
	state.max_ability_charges = max_ability_charges
	state.max_ability_cooldown = max_ability_cooldown

	state.uses_charges = max_ability_charges and max_ability_charges > 1
	state.has_charges_left = remaining_ability_charges > 0

	local cooldown_progress
	local in_process_of_going_on_cooldown = false
	local force_on_cooldown = false
	local should_show_empty_cooldown = is_paused

	if should_show_empty_cooldown then
		cooldown_progress = 0
	elseif max_ability_cooldown and max_ability_cooldown > 0 then
		cooldown_progress = 1 - math.lerp(0, 1, remaining_ability_cooldown / max_ability_cooldown)

		if cooldown_progress == 0 then
			cooldown_progress = 1
		end
	else
		cooldown_progress = state.uses_charges and 1 or 0
	end

	local pause_cooldown_settings = ability_extension:ability_pause_cooldown_settings(ability_id)

	if pause_cooldown_settings and buff_extension then
		local duration_tracking_buff = pause_cooldown_settings.duration_tracking_buff

		if duration_tracking_buff then
			if type(duration_tracking_buff) == "table" then
				for _, duration_tracking_buff_name in ipairs(duration_tracking_buff) do
					if buff_extension:current_stacks(duration_tracking_buff_name) > 0 then
						cooldown_progress = buff_extension:buff_duration_progress(duration_tracking_buff_name)
						in_process_of_going_on_cooldown = cooldown_progress > 0

						break
					end
				end
			elseif buff_extension:current_stacks(duration_tracking_buff) > 0 then
				cooldown_progress = buff_extension:buff_duration_progress(duration_tracking_buff)
				in_process_of_going_on_cooldown = cooldown_progress > 0
			end
		end

		local on_cooldown_tracking_buff = pause_cooldown_settings.on_cooldown_tracking_buff

		if on_cooldown_tracking_buff then
			if type(on_cooldown_tracking_buff) == "table" then
				for i = 1, #on_cooldown_tracking_buff do
					if buff_extension:current_stacks(on_cooldown_tracking_buff[i]) > 0 then
						force_on_cooldown = true

						break
					end
				end
			else
				force_on_cooldown = buff_extension:current_stacks(on_cooldown_tracking_buff) > 0
			end
		end
	end

	state.cooldown_progress = cooldown_progress
	state.in_process_of_going_on_cooldown = in_process_of_going_on_cooldown
	state.force_on_cooldown = force_on_cooldown

	return state
end

local function division_hud_apply_ability_segment_style(seg_style, offset_x, width, rgba, opacity)
	if not seg_style then
		return
	end

	seg_style.offset[1] = offset_x
	seg_style.size[1] = math.max(0, math.floor(width))
	seg_style.color[1] = math.floor((rgba[1] or 255) * opacity)
	seg_style.color[2] = rgba[2] or 255
	seg_style.color[3] = rgba[3] or 255
	seg_style.color[4] = rgba[4] or 255
end

local function division_hud_mod_numeric(key)
	local settings = mod._settings
	local v = settings and settings[key]

	if type(v) == "number" and v == v then
		return v
	end

	local fallback = DivisionHUDSettingsDefaults[key]

	if type(fallback) == "number" and fallback == fallback then
		return fallback
	end

	return 0
end

local function division_hud_wrapped_angle_delta(prev_rad, curr_rad)
	return (curr_rad - prev_rad + math.pi) % (math.pi * 2) - math.pi
end

local function division_hud_format_stimm_timer_text_as_whole_seconds(text)
	if type(text) ~= "string" or text == "" then
		return text
	end

	local n = tonumber(text)

	if n == nil or n ~= n then
		return text
	end

	local whole = math.ceil(n)

	if whole < 0 then
		return string.format("%.0f", whole)
	end

	return string.format("%02d", whole)
end

local function division_hud_is_valid_argb_255(c)
	return type(c) == "table"
		and type(c[1]) == "number"
		and type(c[2]) == "number"
		and type(c[3]) == "number"
		and type(c[4]) == "number"
end

local function division_hud_resolve_stimm_slot_main_argb_255(stimm_template_id, s_cfg)
	if type(stimm_template_id) ~= "string" or stimm_template_id == "" then
		return nil
	end

	local use_recolor = type(s_cfg) == "table" and s_cfg.integration_recolor_stimms == true
	local rm = mod._division_hud_recolor_stimms_mod

	if
		use_recolor
		and rm
		and type(rm.is_enabled) == "function"
		and rm:is_enabled()
		and type(rm.get_stimm_argb_255) == "function"
	then
		local from_recolor = rm.get_stimm_argb_255(stimm_template_id)

		if division_hud_is_valid_argb_255(from_recolor) then
			return from_recolor
		end
	end

	return DIVISION_STIMM_SLOT_TYPE_COLORS[stimm_template_id]
end

local function division_hud_apply_right_slot_icon_color(widget, widget_name, entry, opacity, s_cfg)
	local icon_style = widget and widget.style and widget.style.icon

	if not icon_style or not icon_style.color then
		return
	end

	local c = icon_style.color

	if widget_name ~= "slot_stimm" then
		c[1] = math.floor(255 * opacity)
		c[2] = 255
		c[3] = 255
		c[4] = 255

		return
	end

	local tint_on = type(s_cfg) ~= "table" or s_cfg.stimm_slot_icon_tint_by_type ~= false

	if not tint_on or not entry or entry.slot_id ~= "slot_pocketable_small" or not entry.has_equipment then
		c[1] = math.floor(255 * opacity)
		c[2] = 255
		c[3] = 255
		c[4] = 255

		return
	end

	local item = entry.item
	local stimm_id = item and type(item.weapon_template) == "string" and item.weapon_template or nil
	local main = stimm_id and division_hud_resolve_stimm_slot_main_argb_255(stimm_id, s_cfg) or nil

	if division_hud_is_valid_argb_255(main) then
		c[1] = math.floor((main[1] or 255) * opacity)
		c[2] = main[2] or 255
		c[3] = main[3] or 255
		c[4] = main[4] or 255
	else
		c[1] = math.floor(255 * opacity)
		c[2] = 255
		c[3] = 255
		c[4] = 255
	end
end

HudElementDivisionHUD._division_hud_reset_dynamic_offset_state = function(self)
	self._division_hud_dyn_prev_yaw = nil
	self._division_hud_dyn_prev_pitch = nil
	self._division_hud_dyn_ox = 0
	self._division_hud_dyn_oy = 0
end

HudElementDivisionHUD._division_hud_compute_dynamic_root_offset = function(self, dt, player)
	local strength = division_hud_mod_numeric("dynamic_hud_strength")
	local pitch_ratio = division_hud_mod_numeric("dynamic_hud_pitch_ratio")
	local decay_hz = division_hud_mod_numeric("dynamic_hud_decay")
	local max_off = division_hud_mod_numeric("dynamic_hud_max_offset")

	if not player or player.get_orientation == nil then
		self:_division_hud_reset_dynamic_offset_state()

		return 0, 0
	end

	local orientation = player:get_orientation()

	if not orientation or type(orientation.yaw) ~= "number" or type(orientation.pitch) ~= "number" then
		self:_division_hud_reset_dynamic_offset_state()

		return 0, 0
	end

	local yaw = orientation.yaw
	local pitch = orientation.pitch
	local ox = self._division_hud_dyn_ox or 0
	local oy = self._division_hud_dyn_oy or 0
	local decay = math.exp(-decay_hz * dt)

	ox = ox * decay
	oy = oy * decay

	local prev_yaw = self._division_hud_dyn_prev_yaw

	if prev_yaw then
		local dyaw = division_hud_wrapped_angle_delta(prev_yaw, yaw)

		ox = ox - strength * dyaw
	end

	local prev_pitch = self._division_hud_dyn_prev_pitch

	if prev_pitch then
		local dpitch = division_hud_wrapped_angle_delta(prev_pitch, pitch)

		oy = oy + strength * pitch_ratio * dpitch
	end

	self._division_hud_dyn_prev_yaw = yaw
	self._division_hud_dyn_prev_pitch = pitch
	ox = math.clamp(ox, -max_off, max_off)
	oy = math.clamp(oy, -max_off, max_off)
	self._division_hud_dyn_ox = ox
	self._division_hud_dyn_oy = oy

	return ox * HUD_LAYOUT_SCALE, oy * HUD_LAYOUT_SCALE
end

HudElementDivisionHUD._build_extensions = function(self, player_unit)
	local unit_data = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local visual_loadout = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
	local ability = ScriptUnit.has_extension(player_unit, "ability_system")

	if not unit_data or not visual_loadout or not ability then
		return nil
	end

	return {
		unit_data = unit_data,
		visual_loadout = visual_loadout,
		ability = ability,
	}
end

local function division_hud_icon_is_texture_bitmap_path(icon_path)
	return type(icon_path) == "string" and string.find(icon_path, "/textures/", 1, true) ~= nil
end

local function division_hud_icon_must_skip_create_material(icon_path)
	if type(icon_path) ~= "string" then
		return false
	end

	if string.find(icon_path, "/materials/icons/weapons/flat/", 1, true) then
		return true
	end

	return false
end

HudElementDivisionHUD._apply_slot_icon_material = function(self, widget, entry)
	if not widget or not widget.content then
		return
	end

	local slot_id = entry and entry.slot_id
	local icon = entry and entry.icon

	if slot_id == "slot_auspex_display" then
		if type(icon) ~= "string" or icon == "" or icon == "content/ui/materials/base/ui_default_base" then
			return
		end
	elseif type(icon) ~= "string" or icon == "" or icon == "content/ui/materials/base/ui_default_base" then
		icon = Definitions.RIGHT_SLOT_ICON_FALLBACK
	end

	local icon_style = widget.style and widget.style.icon

	if slot_id == "slot_auspex_display" and icon_style then
		if division_hud_icon_is_texture_bitmap_path(icon) then
			widget.content.icon = Definitions.HUD_WEAPON_ICON_CONTAINER

			if not icon_style.material_values then
				icon_style.material_values = {}
			end

			icon_style.material_values.texture_map = icon
			icon_style.material_values.use_placeholder_texture = 0
		elseif division_hud_icon_must_skip_create_material(icon) then
			widget.content.icon = icon
			icon_style.material_values = nil
		else
			widget.content.icon = icon
			icon_style.material_values = {}
		end

		local auspex_sz = Definitions.AUSPEX_ICON_SIZE

		icon_style.size[1] = auspex_sz
		icon_style.size[2] = auspex_sz
		icon_style.default_size[1] = auspex_sz
		icon_style.default_size[2] = auspex_sz
		icon_style.aspect_ratio = 1
	elseif slot_id == "slot_wielded_display" and icon_style then
		if division_hud_icon_is_texture_bitmap_path(icon) then
			widget.content.icon = Definitions.HUD_WEAPON_ICON_CONTAINER

			if not icon_style.material_values then
				icon_style.material_values = {}
			end

			icon_style.material_values.texture_map = icon
			icon_style.material_values.use_placeholder_texture = 0
		elseif division_hud_icon_must_skip_create_material(icon) then
			widget.content.icon = icon
			icon_style.material_values = nil
		else
			widget.content.icon = icon
			icon_style.material_values = {}
		end

		local real_wield_slot = entry.wielded_source_slot_id
		local use_wide_weapon_strip = real_wield_slot == "slot_primary" or real_wield_slot == "slot_secondary"

		if use_wide_weapon_strip then
			icon_style.size[1] = Definitions.WEAPON_STRIP_ICON_W
			icon_style.size[2] = Definitions.WEAPON_STRIP_ICON_H
			icon_style.default_size[1] = Definitions.WEAPON_STRIP_ICON_W
			icon_style.default_size[2] = Definitions.WEAPON_STRIP_ICON_H
			icon_style.aspect_ratio = Definitions.WEAPON_STRIP_ICON_ASPECT_RATIO
		else
			local sq = Definitions.WIELDED_STRIP_SQUARE_ICON

			icon_style.size[1] = sq
			icon_style.size[2] = sq
			icon_style.default_size[1] = sq
			icon_style.default_size[2] = sq
			icon_style.aspect_ratio = 1
		end
	else
		widget.content.icon = icon

		if icon_style and icon_style.material_values ~= nil then
			icon_style.material_values = nil
		end
	end

	widget.dirty = true
end

HudElementDivisionHUD._slot_numeric_text = function(self, slot_id, entry, player_unit)
	if slot_id == "slot_grenade_ability" then
		local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

		if not ability_extension then
			return "00"
		end

		local remaining_charges = ability_extension:remaining_ability_charges(GRENADE_ABILITY_TYPE)

		return string.format("%02d", remaining_charges or 0)
	end

	if slot_id == "slot_pocketable" or slot_id == "slot_pocketable_small" then
		if entry.has_equipment and entry.weapon_template then
			return "01"
		end

		return "00"
	end

	return "0"
end

HudElementDivisionHUD._slot_has_ranged_ammunition = function(self, unit_data_extension, visual_loadout_extension, slot_id)
	if not unit_data_extension or not visual_loadout_extension then
		return false
	end

	local slot_configuration = PlayerCharacterConstants.slot_configuration
	local slot_settings = slot_configuration and slot_configuration[slot_id]

	if not slot_settings or slot_settings.slot_type ~= "weapon" then
		return false
	end

	local inventory_component = unit_data_extension:read_component("inventory")

	if not inventory_component or inventory_component[slot_id] == "not_equipped" then
		return false
	end

	local weapon_template = visual_loadout_extension:weapon_template_from_slot(slot_id)

	if not weapon_template then
		return false
	end

	local hud_configuration = weapon_template.hud_configuration

	if not hud_configuration or not hud_configuration.uses_ammunition then
		return false
	end

	local slot_component = unit_data_extension:read_component(slot_id)

	if not slot_component then
		return false
	end

	local max_reserve = slot_component.max_ammunition_reserve

	return max_reserve ~= nil and max_reserve > 0
end

HudElementDivisionHUD._read_weapon_slot_clip_reserve = function(self, unit_data_extension, visual_loadout_extension, slot_id)
	if not unit_data_extension or not visual_loadout_extension then
		return 0, 0
	end

	if not self:_slot_has_ranged_ammunition(unit_data_extension, visual_loadout_extension, slot_id) then
		return 0, 0
	end

	local slot_component = unit_data_extension:read_component(slot_id)
	local ok, clip = pcall(function()
		return Ammo.current_ammo_in_clips(slot_component)
	end)

	if not ok then
		return 0, 0
	end

	local reserve = slot_component.current_ammunition_reserve or 0

	return clip or 0, reserve
end

HudElementDivisionHUD._pick_ranged_ammo_slot_id = function(self, unit_data_extension, visual_loadout_extension)
	if self:_slot_has_ranged_ammunition(unit_data_extension, visual_loadout_extension, "slot_primary") then
		return "slot_primary"
	end

	if self:_slot_has_ranged_ammunition(unit_data_extension, visual_loadout_extension, "slot_secondary") then
		return "slot_secondary"
	end

	return nil
end

HudElementDivisionHUD._update_ammo_big = function(self, player_unit, widget, opacity)
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")

	if not unit_data_extension or not visual_loadout_extension then
		widget.content.visible = false
		return
	end

	widget.content.visible = true

	local ammo_slot_id = self:_pick_ranged_ammo_slot_id(unit_data_extension, visual_loadout_extension)

	if not ammo_slot_id then
		widget.content.text = ""
		widget.content.text_reserve = ""
		widget.style.text.text_color[1] = 255 * opacity
		widget.style.text_reserve.text_color[1] = 255 * opacity
		widget.dirty = true
		return
	end

	local clip, reserve = self:_read_weapon_slot_clip_reserve(unit_data_extension, visual_loadout_extension, ammo_slot_id)

	widget.content.text = string.format("%d", clip)
	widget.content.text_reserve = string.format("%d", reserve)
	widget.style.text.text_color[1] = 255 * opacity
	widget.style.text_reserve.text_color[1] = 255 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_auspex_slot = function(self, player_unit, widgets, opacity)
	local widget = widgets.slot_auspex

	if not widget or not widget.style then
		return
	end

	local extensions = self:_build_extensions(player_unit)

	if not extensions then
		widget.content.visible = false

		if widget.style.icon.material_values ~= nil then
			widget.style.icon.material_values = nil
		end

		widget.dirty = true
		return
	end

	local entry = SlotData.resolve_auspex_display_entry(extensions)

	if entry.has_equipment and type(entry.icon) == "string" and entry.icon ~= "" and entry.icon ~= "content/ui/materials/base/ui_default_base" then
		widget.content.visible = true
		self:_apply_slot_icon_material(widget, entry)
		widget.style.icon.color[1] = 255 * opacity
		widget.style.icon.color[4] = 255
	else
		widget.content.visible = false

		if widget.style.icon.material_values ~= nil then
			widget.style.icon.material_values = nil
		end
	end

	widget.dirty = true
end

HudElementDivisionHUD._update_right_slot_grid = function(self, player_unit, widgets, opacity)
	local extensions = self:_build_extensions(player_unit)

	if not extensions then
		for i = 1, RIGHT_SLOT_COUNT do
			local name = right_slot_widget_names[i]
			local widget = widgets[name]

			if widget then
				widget.content.visible = false
			end
		end

		if widgets.slot_auspex then
			widgets.slot_auspex.content.visible = false
		end

		return
	end

	local row = SlotData.build_division_right_slots(extensions)

	for i = 1, RIGHT_SLOT_COUNT do
		local name = right_slot_widget_names[i]
		local widget = widgets[name]
		local entry = row[i]

		if not widget or not entry then
			if widget then
				widget.content.visible = false
			end
		else
			local slot_id = entry.slot_id

			widget.content.visible = true
			self:_apply_slot_icon_material(widget, entry)
			division_hud_apply_right_slot_icon_color(widget, name, entry, opacity, mod._settings)

			if widget.style.text then
				widget.content.text = self:_slot_numeric_text(slot_id, entry, player_unit)

				if name == "slot_stimm" then
					local tc = widget.style.text.text_color
					local default_tc = DIVISION_SLOT_COUNTER_TEXT_COLOR_DEFAULT

					tc[1] = math.floor((default_tc[1] or 255) * opacity)
					tc[2] = default_tc[2]
					tc[3] = default_tc[3]
					tc[4] = default_tc[4]

					local s_cfg = mod._settings

					if type(s_cfg) == "table" and s_cfg.integration_stimm_countdown ~= false then
						local get_mod_fn = rawget(_G, "get_mod")
						local sm = type(get_mod_fn) == "function" and get_mod_fn("StimmCountdown") or nil
						local stimm_api = sm and type(sm.stimm_countdown_timer_api) == "table" and sm.stimm_countdown_timer_api or nil
						local get_timer_fn = stimm_api and stimm_api.get_display_for_unit

						if
							stimm_api
							and type(get_timer_fn) == "function"
							and type(sm.is_enabled) == "function"
							and sm:is_enabled()
						then
							local r = get_timer_fn(player_unit)

							if type(r) == "table" and r.visible and r.text ~= "" then
								widget.content.text = division_hud_format_stimm_timer_text_as_whole_seconds(r.text)

								local base = r.phase == "active" and DIVISION_STIMM_TIMER_ACTIVE_COLOR or DIVISION_STIMM_TIMER_COOLDOWN_COLOR

								tc[1] = math.floor((base[1] or 255) * opacity)
								tc[2] = base[2]
								tc[3] = base[3]
								tc[4] = base[4]
							end
						end
					end
				else
					widget.style.text.text_color[1] = 255 * opacity
				end
			end

			widget.dirty = true
		end
	end
end

HudElementDivisionHUD.init = function(self, parent, draw_layer, start_scale)
	local definitions = {
		scenegraph_definition = Definitions.scenegraph_definition,
		widget_definitions = Definitions.widget_definitions,
		animations = Definitions.vanilla_stamina_dodge_animations,
	}

	HudElementDivisionHUD.super.init(self, parent, draw_layer, start_scale, definitions)

	VanillaStaminaDodge.init(self, Definitions)
	VanillaToughnessHealth.init(self, Definitions)

	self:_division_hud_reset_dynamic_offset_state()

	local widgets = self._widgets_by_name
	local skip_init_hide = Definitions.VANILLA_STAMINA_DODGE_DRAW_LAYER_WIDGETS

	for name, widget in pairs(widgets) do
		if widget.content and not skip_init_hide[name] and name ~= "stamina_nodge" then
			widget.content.visible = false
		end
	end
end

HudElementDivisionHUD.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	local is_in_hub = GameFlowContext.is_hub_like()
	local local_player, player_unit = GameFlowContext.local_player_alive_unit()

	if not is_in_hub and local_player and player_unit then
		local s = mod._settings
		local pos_x = (s and type(s.position_x) == "number" and s.position_x) or 0
		local pos_y = (s and type(s.position_y) == "number" and s.position_y) or 0
		local dyn_x, dyn_y = 0, 0

		if DynamicHudContext.dynamic_hud_enabled(mod, DivisionHUDSettingsDefaults) then
			dyn_x, dyn_y = self:_division_hud_compute_dynamic_root_offset(dt, local_player)
		else
			self:_division_hud_reset_dynamic_offset_state()
		end

		local integrate_chud = type(s) == "table" and s.integration_custom_hud == true
		local HudUtils = mod.hud_utils
		local chud_has_division_nodes = integrate_chud
			and HudUtils
			and HudUtils.custom_hud_has_saved_node_settings_for_division_hud
			and HudUtils.custom_hud_has_saved_node_settings_for_division_hud()
		local chud_root_base = chud_has_division_nodes
			and HudUtils.custom_hud_get_saved_root_position_for_division_hud
			and HudUtils.custom_hud_get_saved_root_position_for_division_hud()

		if integrate_chud and chud_has_division_nodes and chud_root_base then
			self:set_scenegraph_position(
				"root",
				chud_root_base.x + dyn_x,
				chud_root_base.y + dyn_y,
				chud_root_base.z,
				"left",
				"top"
			)
		elseif integrate_chud and chud_has_division_nodes and not chud_root_base then
		else
			self:set_scenegraph_position(
				"root",
				ROOT_LAYOUT_OFFSET_X + pos_x + dyn_x,
				ROOT_LAYOUT_OFFSET_Y + pos_y + dyn_y,
				ROOT_LAYOUT_OFFSET_Z,
				"center",
				"center"
			)
		end
	end

	HudElementDivisionHUD.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	if is_in_hub then
		self:_division_hud_reset_dynamic_offset_state()
		self:_set_all_visible(false)
		return
	end

	if not local_player or not player_unit then
		self:_division_hud_reset_dynamic_offset_state()
		self:_set_all_visible(false)
		return
	end

	local s_op = mod._settings
	local opacity_raw = s_op and s_op.opacity
	local opacity = (type(opacity_raw) == "number" and opacity_raw) or 1.0
	local widgets = self._widgets_by_name

	VanillaStaminaDodge.update(self, dt, t, ui_renderer, render_settings, input_service)
	VanillaToughnessHealth.update(self, dt, t, player_unit, opacity)

	local boxes_bg = widgets.boxes_bg

	if boxes_bg then
		boxes_bg.content.visible = true
		boxes_bg.alpha_multiplier = opacity
		boxes_bg.dirty = true
	end

	self:_update_ability_bar(player_unit, widgets.ability_bar, opacity)
	self:_update_ammo_big(player_unit, widgets.ammo_big, opacity)
	self:_update_auspex_slot(player_unit, widgets, opacity)
	self:_update_right_slot_grid(player_unit, widgets, opacity)
end

HudElementDivisionHUD._update_ability_bar = function(self, player_unit, widget, opacity)
	local s_ab = mod._settings
	local show_ability = s_ab and s_ab.show_ability_timer

	if not show_ability then
		widget.content.visible = false
		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not ability_extension then
		widget.content.visible = false
		return
	end

	local st = division_hud_compute_combat_ability_cooldown_state(ability_extension, buff_extension, COMBAT_ABILITY_TYPE)

	if not st.equipped then
		widget.content.visible = false
		return
	end

	if (st.max_ability_charges or 0) <= 0 and (st.max_ability_cooldown or 0) <= 0 then
		widget.content.visible = false
		return
	end

	local cooldown_progress = st.cooldown_progress or 0
	local vanilla_on_cooldown = cooldown_progress ~= 1 and not st.in_process_of_going_on_cooldown or st.force_on_cooldown
	local active_partial_fill = vanilla_on_cooldown or st.in_process_of_going_on_cooldown
	local remaining = st.remaining_ability_charges or 0
	local max_charges = st.max_ability_charges or 0

	widget.content.visible = true

	if widget.style.background then
		widget.style.background.color[1] = math.floor(160 * opacity)
	end

	local function clear_segments_from(idx)
		for j = idx, ABILITY_BAR_MAX_SEGMENTS do
			local seg_style = widget.style["segment_" .. j]

			division_hud_apply_ability_segment_style(seg_style, 0, 0, ABILITY_BAR_READY_COLOR, opacity)
		end
	end

	if max_charges > ABILITY_BAR_MAX_SEGMENTS then
		local seg1 = widget.style.segment_1

		if active_partial_fill then
			division_hud_apply_ability_segment_style(seg1, 0, BAR_WIDTH * cooldown_progress, ABILITY_BAR_COOLDOWN_COLOR, opacity)
		else
			division_hud_apply_ability_segment_style(seg1, 0, BAR_WIDTH, ABILITY_BAR_READY_COLOR, opacity)
		end

		clear_segments_from(2)
	else
		local use_segments = max_charges > 1
		local n = use_segments and math.min(max_charges, ABILITY_BAR_MAX_SEGMENTS) or 1
		local total_gap = (n - 1) * ABILITY_BAR_SEGMENT_GAP
		local seg_w = n > 0 and math.max(1, math.floor((BAR_WIDTH - total_gap) / n)) or BAR_WIDTH
		local ox = 0

		if use_segments then
			for i = 1, ABILITY_BAR_MAX_SEGMENTS do
				local seg_style = widget.style["segment_" .. i]

				if i > n then
					division_hud_apply_ability_segment_style(seg_style, 0, 0, ABILITY_BAR_READY_COLOR, opacity)
				elseif i <= remaining then
					division_hud_apply_ability_segment_style(seg_style, ox, seg_w, ABILITY_BAR_READY_COLOR, opacity)
					ox = ox + seg_w + ABILITY_BAR_SEGMENT_GAP
				elseif i == remaining + 1 then
					local w_fill = active_partial_fill and seg_w * cooldown_progress or seg_w

					division_hud_apply_ability_segment_style(
						seg_style,
						ox,
						w_fill,
						active_partial_fill and ABILITY_BAR_COOLDOWN_COLOR or ABILITY_BAR_READY_COLOR,
						opacity
					)
					ox = ox + seg_w + ABILITY_BAR_SEGMENT_GAP
				else
					division_hud_apply_ability_segment_style(seg_style, ox, 0, ABILITY_BAR_READY_COLOR, opacity)
					ox = ox + seg_w + ABILITY_BAR_SEGMENT_GAP
				end
			end
		else
			local seg1 = widget.style.segment_1

			if active_partial_fill then
				division_hud_apply_ability_segment_style(seg1, 0, BAR_WIDTH * cooldown_progress, ABILITY_BAR_COOLDOWN_COLOR, opacity)
			else
				division_hud_apply_ability_segment_style(seg1, 0, BAR_WIDTH, ABILITY_BAR_READY_COLOR, opacity)
			end

			clear_segments_from(2)
		end
	end

	widget.dirty = true
end

HudElementDivisionHUD._set_all_visible = function(self, visible)
	local widgets = self._widgets_by_name
	local skip_init_hide = Definitions.VANILLA_STAMINA_DODGE_DRAW_LAYER_WIDGETS

	for name, widget in pairs(widgets) do
		if widget.content and not skip_init_hide[name] and name ~= "stamina_nodge" then
			widget.content.visible = visible
		end
	end
end

HudElementDivisionHUD._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	local skip = Definitions.VANILLA_STAMINA_DODGE_DRAW_LAYER_WIDGETS
	local widgets = self._widgets
	local n_widgets = #widgets

	for i = 1, n_widgets do
		local widget = widgets[i]

		if not skip[widget.name] then
			UIWidget.draw(widget, ui_renderer)
		end
	end

	local s_st = mod._settings
	local show_stamina = s_st and s_st.show_stamina_bar

	if show_stamina ~= false and show_stamina ~= 0 then
		VanillaStaminaDodge.draw(self, dt, t, input_service, ui_renderer, render_settings)
	end

	VanillaToughnessHealth.draw(self, dt, t, input_service, ui_renderer, render_settings)
end

HudElementDivisionHUD.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementDivisionHUD.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

HudElementDivisionHUD.destroy = function(self, ui_renderer)
	self:_division_hud_reset_dynamic_offset_state()

	VanillaStaminaDodge.destroy(self, ui_renderer)
	VanillaToughnessHealth.destroy(self, ui_renderer)

	HudElementDivisionHUD.super.destroy(self, ui_renderer)
end

return HudElementDivisionHUD
