local mod = get_mod("DivisionHUD")

require("scripts/ui/hud/elements/hud_element_base")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local Ammo = require("scripts/utilities/ammo")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")

local Definitions = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_definitions")
local SlotData = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_slot_data")

local HudElementDivisionHUD = class("HudElementDivisionHUD", "HudElementBase")

local HUD_GLASS_PLATE_ALPHA_BASE = Definitions.HUD_GLASS_PLATE_ALPHA_BASE
local HUD_GLASS_PLATE_COLOR = Definitions.HUD_GLASS_PLATE_COLOR
local ROOT_LAYOUT_OFFSET_X = Definitions.ROOT_LAYOUT_OFFSET_X
local ROOT_LAYOUT_OFFSET_Y = Definitions.ROOT_LAYOUT_OFFSET_Y
local ROOT_LAYOUT_OFFSET_Z = Definitions.ROOT_LAYOUT_OFFSET_Z

local BAR_WIDTH = Definitions.BAR_WIDTH
local RIGHT_SLOT_COUNT = Definitions.RIGHT_SLOT_COUNT
local right_slot_widget_names = Definitions.right_slot_widget_names

local COMBAT_ABILITY_TYPE = "combat_ability"
local GRENADE_ABILITY_TYPE = "grenade_ability"

local HUD_LAYOUT_SCALE = Definitions.HUD_LAYOUT_SCALE or 1

local function division_hud_mod_numeric(key, default_val)
	local v = mod:get(key)

	if type(v) == "number" and v == v then
		return v
	end

	return default_val
end

local function division_hud_wrapped_angle_delta(prev_rad, curr_rad)
	return (curr_rad - prev_rad + math.pi) % (math.pi * 2) - math.pi
end

HudElementDivisionHUD._division_hud_reset_dynamic_offset_state = function(self)
	self._division_hud_dyn_prev_yaw = nil
	self._division_hud_dyn_prev_pitch = nil
	self._division_hud_dyn_ox = 0
	self._division_hud_dyn_oy = 0
end

HudElementDivisionHUD._division_hud_compute_dynamic_root_offset = function(self, dt, player)
	local strength = division_hud_mod_numeric("dynamic_hud_strength", 110)
	local pitch_ratio = division_hud_mod_numeric("dynamic_hud_pitch_ratio", 0.65)
	local decay_hz = division_hud_mod_numeric("dynamic_hud_decay", 11)
	local max_off = division_hud_mod_numeric("dynamic_hud_max_offset", 72)

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

HudElementDivisionHUD._slot_cell_visible = function(self, slot_id)
	if slot_id == "slot_grenade_ability" then
		return mod:get("show_grenades") ~= false and mod:get("show_grenades") ~= 0
	elseif slot_id == "slot_pocketable" then
		return mod:get("show_pickups") ~= false and mod:get("show_pickups") ~= 0
	elseif slot_id == "slot_pocketable_small" then
		return mod:get("show_stimm") ~= false and mod:get("show_stimm") ~= 0
	elseif slot_id == "slot_wielded_display" then
		return mod:get("show_wielded_weapon") ~= false and mod:get("show_wielded_weapon") ~= 0
	end

	return true
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
	if not mod:get("show_ammo") then
		widget.content.visible = false
		return
	end

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
		widget.style.background.color[1] = HUD_GLASS_PLATE_ALPHA_BASE * opacity
		widget.style.text.text_color[1] = 255 * opacity
		widget.style.text_reserve.text_color[1] = 255 * opacity
		widget.dirty = true
		return
	end

	local clip, reserve = self:_read_weapon_slot_clip_reserve(unit_data_extension, visual_loadout_extension, ammo_slot_id)

	widget.content.text = string.format("%d", clip)
	widget.content.text_reserve = string.format("%d", reserve)
	widget.style.background.color[1] = HUD_GLASS_PLATE_ALPHA_BASE * opacity
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

	if widget.style.background then
		widget.style.background.color[1] = HUD_GLASS_PLATE_ALPHA_BASE * opacity
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
			local visible = self:_slot_cell_visible(slot_id)

			widget.content.visible = visible

			if visible then
				self:_apply_slot_icon_material(widget, entry)
				widget.style.background.color[1] = HUD_GLASS_PLATE_ALPHA_BASE * opacity
				widget.style.icon.color[1] = 255 * opacity

				if widget.style.text then
					widget.content.text = self:_slot_numeric_text(slot_id, entry, player_unit)
					widget.style.text.text_color[1] = 255 * opacity
				end

				widget.dirty = true
			end
		end
	end
end

HudElementDivisionHUD.init = function(self, parent, draw_layer, start_scale)
	local definitions = {
		scenegraph_definition = Definitions.scenegraph_definition,
		widget_definitions = Definitions.widget_definitions,
	}

	HudElementDivisionHUD.super.init(self, parent, draw_layer, start_scale, definitions)

	self:_division_hud_reset_dynamic_offset_state()

	local widgets = self._widgets_by_name

	for _, widget in pairs(widgets) do
		widget.content.visible = false
	end
end

HudElementDivisionHUD.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	local game_mode_manager = Managers.state.game_mode
	local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()
	local is_in_hub = not game_mode_name or game_mode_name == "hub" or game_mode_name == "prologue_hub"

	if not is_in_hub then
		local layout_player = Managers.player:local_player(1)
		local layout_unit = layout_player and layout_player.player_unit

		if layout_player and layout_unit and ALIVE[layout_unit] then
			local pos_x = mod:get("position_x") or 0
			local pos_y = mod:get("position_y") or 0
			local dyn_x, dyn_y = 0, 0

			if mod:get("dynamic_hud") ~= false and mod:get("dynamic_hud") ~= 0 then
				dyn_x, dyn_y = self:_division_hud_compute_dynamic_root_offset(dt, layout_player)
			else
				self:_division_hud_reset_dynamic_offset_state()
			end

			self:set_scenegraph_position(
				"root",
				ROOT_LAYOUT_OFFSET_X + pos_x + dyn_x,
				ROOT_LAYOUT_OFFSET_Y + pos_y + dyn_y,
				ROOT_LAYOUT_OFFSET_Z
			)
		end
	end

	HudElementDivisionHUD.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	if is_in_hub then
		self:_division_hud_reset_dynamic_offset_state()
		self:_set_all_visible(false)
		return
	end

	local player = Managers.player:local_player(1)

	if not player then
		self:_division_hud_reset_dynamic_offset_state()
		self:_set_all_visible(false)
		return
	end

	local player_unit = player.player_unit

	if not player_unit or not ALIVE[player_unit] then
		self:_division_hud_reset_dynamic_offset_state()
		self:_set_all_visible(false)
		return
	end

	local opacity = mod:get("opacity") or 1.0
	local widgets = self._widgets_by_name

	self:_update_stamina_bar(player_unit, widgets.stamina_bar, opacity)
	self:_update_toughness_bar(player_unit, widgets.toughness_bar, opacity)
	self:_update_health_bar(player_unit, widgets.health_bar, opacity)
	self:_update_ability_bar(player_unit, widgets.ability_bar, opacity)
	self:_update_ammo_big(player_unit, widgets.ammo_big, opacity)
	self:_update_auspex_slot(player_unit, widgets, opacity)
	self:_update_right_slot_grid(player_unit, widgets, opacity)
end

HudElementDivisionHUD._update_stamina_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_stamina_bar") then
		widget.content.visible = false
		return
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		widget.content.visible = false
		return
	end

	local stamina_component = unit_data_extension:read_component("stamina")

	if not stamina_component then
		widget.content.visible = false
		return
	end

	local stamina_fraction = stamina_component.current_fraction or 0

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * stamina_fraction
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_toughness_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_toughness_bar") then
		widget.content.visible = false
		return
	end

	local toughness_extension = ScriptUnit.has_extension(player_unit, "toughness_system")

	if not toughness_extension then
		widget.content.visible = false
		return
	end

	local toughness_fraction = toughness_extension:current_toughness_percent()

	if toughness_fraction == nil then
		widget.content.visible = false
		return
	end

	toughness_fraction = math.clamp(toughness_fraction, 0, 1)

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * toughness_fraction
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_health_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_health_bar") then
		widget.content.visible = false
		return
	end

	local health_extension = ScriptUnit.has_extension(player_unit, "health_system")

	if not health_extension then
		widget.content.visible = false
		return
	end

	local health_percent = health_extension:current_health_percent() or 0

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * health_percent
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_ability_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_ability_timer") then
		widget.content.visible = false
		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not ability_extension or not buff_extension then
		widget.content.visible = false
		return
	end

	local remaining_cooldown = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE)
	local max_cooldown = ability_extension:max_ability_cooldown(COMBAT_ABILITY_TYPE)

	if not remaining_cooldown or remaining_cooldown <= 0 or not max_cooldown or max_cooldown <= 0 then
		widget.content.visible = false
		return
	end

	local progress = 1 - (remaining_cooldown / max_cooldown)

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * progress
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._set_all_visible = function(self, visible)
	local widgets = self._widgets_by_name

	for _, widget in pairs(widgets) do
		widget.content.visible = visible
	end
end

HudElementDivisionHUD.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementDivisionHUD.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

HudElementDivisionHUD.destroy = function(self, ui_renderer)
	self:_division_hud_reset_dynamic_offset_state()

	HudElementDivisionHUD.super.destroy(self, ui_renderer)
end

return HudElementDivisionHUD
