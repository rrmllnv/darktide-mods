local mod = get_mod("DivisionHUD")

require("scripts/ui/hud/elements/hud_element_base")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local Ammo = require("scripts/utilities/ammo")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")
local Text = require("scripts/utilities/ui/text")
local WalletSettings = require("scripts/settings/wallet_settings")

require("scripts/foundation/utilities/color")

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
local CombatAbilityBar = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/widgets/combat_ability_bar")
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

local RIGHT_SLOT_COUNT = Definitions.RIGHT_SLOT_COUNT
local right_slot_widget_names = Definitions.right_slot_widget_names
local ALERTS_MAX_SLOTS = Definitions.ALERTS_MAX_SLOTS or 5
local alert_slot_widget_names = Definitions.alert_slot_widget_names or {}
local ALERT_BAR_WIDTH = Definitions.BAR_WIDTH or 1
local ALERT_PALETTE_DEFAULT = Definitions.ALERT_PALETTE_DEFAULT
local ALERT_PALETTE_BOSS = Definitions.ALERT_PALETTE_BOSS
local ALERT_PALETTE_MISSION_OBJECTIVE = Definitions.ALERT_PALETTE_MISSION_OBJECTIVE
local ALERT_PALETTE_TEAM = Definitions.ALERT_PALETTE_TEAM
local ALERTS_STRIP_HEIGHT = Definitions.ALERTS_STRIP_HEIGHT
local ALERTS_SLOT_GAP = Definitions.ALERTS_SLOT_GAP
local ALERTS_TOUGHNESS_GAP = Definitions.ALERTS_TOUGHNESS_GAP
local ALERTS_BODY_HEIGHT_MIN = Definitions.ALERTS_BODY_HEIGHT_MIN
local ALERTS_BODY_HEIGHT_MAX = Definitions.ALERTS_BODY_HEIGHT_MAX
local ALERTS_MESSAGE_TEXT_VERTICAL_INSET = Definitions.ALERTS_MESSAGE_TEXT_VERTICAL_INSET
local ALERTS_MESSAGE_TEXT_OFFSET_Y = Definitions.ALERTS_MESSAGE_TEXT_OFFSET_Y or 0
local ALERTS_MESSAGE_TEXT_WRAP_WIDTH = Definitions.ALERTS_MESSAGE_TEXT_WRAP_WIDTH

local COMBAT_ABILITY_TYPE = "combat_ability"
local GRENADE_ABILITY_TYPE = "grenade_ability"

local HUD_LAYOUT_SCALE = Definitions.HUD_LAYOUT_SCALE or 1
local FRACTION_COLOR_GT_MAIN = Definitions.AMMO_TEXT_COLOR_FRACTION_GT_MAIN or 0.75
local FRACTION_COLOR_GT_LOW_BAND = Definitions.AMMO_TEXT_COLOR_FRACTION_GT_LOW_BAND or 0.5
local FRACTION_COLOR_GT_MEDIUM_BAND = Definitions.AMMO_TEXT_COLOR_FRACTION_GT_MEDIUM_BAND or 0.25
local AMMO_BIG_DISPLAY_VALUE_MAX = Definitions.AMMO_BIG_DISPLAY_VALUE_MAX or 9999

local RESOURCE_ZERO_DIM_ALPHA_MUL = 0.45

local function resource_stack_effective_opacity(hud_row_opacity, is_at_zero)
	if type(hud_row_opacity) ~= "number" or hud_row_opacity ~= hud_row_opacity then
		return 0
	end

	if is_at_zero then
		return hud_row_opacity * RESOURCE_ZERO_DIM_ALPHA_MUL
	end

	return hud_row_opacity
end

local function format_ammo_big_display_count(raw)
	if type(raw) ~= "number" or raw ~= raw then
		return "0"
	end

	local v = math.floor(raw + 0.5)

	if v < 0 then
		v = 0
	elseif v > AMMO_BIG_DISPLAY_VALUE_MAX then
		v = AMMO_BIG_DISPLAY_VALUE_MAX
	end

	return string.format("%d", v)
end

local function read_mod_numeric_setting(key)
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

local function wrapped_angle_delta(prev_rad, curr_rad)
	return (curr_rad - prev_rad + math.pi) % (math.pi * 2) - math.pi
end

local function format_stimm_timer_text_as_whole_seconds(text)
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

local function division_right_slot_counter_markup_lead_unit_digit_as_background(raw_display)
	if type(raw_display) ~= "string" then
		return raw_display
	end

	if not string.match(raw_display, "^0[1-9]$") then
		return raw_display
	end

	local grad = Color.terminal_background_gradient(255, true)
	local r = type(grad[2]) == "number" and grad[2] or 101
	local gch = type(grad[3]) == "number" and grad[3] or 133
	local bch = type(grad[4]) == "number" and grad[4] or 96

	return string.format("{#color(%d,%d,%d)}0{#reset()}%s", r, gch, bch, string.sub(raw_display, 2, 2))
end

local function is_valid_argb_255(c)
	return type(c) == "table"
		and type(c[1]) == "number"
		and type(c[2]) == "number"
		and type(c[3]) == "number"
		and type(c[4]) == "number"
end

local function resolve_ammo_total_fraction(slot_component)
	if not slot_component then
		return 0
	end

	local max_reserve = Ammo.max_ammo_in_reserve(slot_component) or 0
	local current_reserve = Ammo.current_ammo_in_reserve(slot_component) or 0
	local total_current_ammo = current_reserve
	local total_max_ammo = max_reserve

	for i = 1, NetworkConstants.clips_in_use.max_size do
		local max_clip = Ammo.max_ammo_in_clips(slot_component, i) or 0
		local current_clip = Ammo.current_ammo_in_clips(slot_component, i) or 0

		total_current_ammo = total_current_ammo + current_clip
		total_max_ammo = total_max_ammo + max_clip
	end

	local weapon_ammo_fraction = 0

	if total_max_ammo > 0 then
		weapon_ammo_fraction = total_current_ammo / total_max_ammo
	end

	return weapon_ammo_fraction
end

local function ammo_text_fraction_coloring_enabled()
	local s = mod._settings

	if type(s) ~= "table" then
		return true
	end

	local v = s.ammo_text_color_by_fraction

	if v == false or v == 0 then
		return false
	end

	return true
end

local function grenade_slot_fraction_coloring_enabled()
	local s = mod._settings

	if type(s) ~= "table" then
		return true
	end

	local v = s.grenade_color_by_fraction

	if v == false or v == 0 then
		return false
	end

	return true
end

local function resolve_ammo_palette_color_from_fraction(fraction)
	if fraction > FRACTION_COLOR_GT_MAIN then
		return UIHudSettings.color_tint_main_1
	elseif fraction > FRACTION_COLOR_GT_LOW_BAND then
		return UIHudSettings.color_tint_ammo_low
	elseif fraction > FRACTION_COLOR_GT_MEDIUM_BAND then
		return UIHudSettings.color_tint_ammo_medium
	else
		return UIHudSettings.color_tint_ammo_high
	end
end

local function apply_tinted_icon_color_from_palette(c, palette_argb, hud_row_opacity, is_at_zero)
	if not c or not is_valid_argb_255(palette_argb) then
		return
	end

	local eff = resource_stack_effective_opacity(hud_row_opacity, is_at_zero)

	c[1] = math.floor((palette_argb[1] or 255) * eff)
	c[2] = palette_argb[2] or 255
	c[3] = palette_argb[3] or 255
	c[4] = palette_argb[4] or 255
end

local function resolve_grenade_charge_fraction_from_player_unit(player_unit)
	if not player_unit then
		return 1
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

	if not ability_extension then
		return 1
	end

	local max_charges = ability_extension:max_ability_charges(GRENADE_ABILITY_TYPE)
	local remaining_charges = ability_extension:remaining_ability_charges(GRENADE_ABILITY_TYPE)

	if type(max_charges) ~= "number" or max_charges <= 0 or type(remaining_charges) ~= "number" then
		return 1
	end

	return math.clamp(remaining_charges / max_charges, 0, 1)
end

local function apply_ammo_big_text_colors(widget, opacity, palette_argb)
	local st = widget and widget.style

	if not st or not is_valid_argb_255(palette_argb) then
		return
	end

	local a = palette_argb[1] or 255
	local r = palette_argb[2] or 255
	local g = palette_argb[3] or 255
	local bch = palette_argb[4] or 255
	local alpha_scaled = math.floor(a * opacity)

	local function apply_pass(pass_name)
		local tc = st[pass_name] and st[pass_name].text_color

		if not tc then
			return
		end

		tc[1] = alpha_scaled
		tc[2] = r
		tc[3] = g
		tc[4] = bch
	end

	apply_pass("text")
	apply_pass("text_reserve")
end

local function resolve_stimm_slot_main_argb_255(stimm_template_id, s_cfg)
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

		if is_valid_argb_255(from_recolor) then
			return from_recolor
		end
	end

	return DIVISION_STIMM_SLOT_TYPE_COLORS[stimm_template_id]
end

local function get_stimm_countdown_display_for_player_unit(player_unit)
	if not player_unit then
		return nil
	end

	local s_cfg = mod._settings

	if type(s_cfg) ~= "table" or s_cfg.integration_stimm_countdown == false or s_cfg.integration_stimm_countdown == 0 then
		return nil
	end

	local get_mod_fn = rawget(_G, "get_mod")
	local sm = type(get_mod_fn) == "function" and get_mod_fn("StimmCountdown") or nil
	local stimm_api = sm and type(sm.stimm_countdown_api) == "table" and sm.stimm_countdown_api or nil
	local get_timer_fn = stimm_api and stimm_api.get_display_for_unit

	if
		not stimm_api
		or type(get_timer_fn) ~= "function"
		or type(sm.is_enabled) ~= "function"
		or not sm:is_enabled()
	then
		return nil
	end

	local r = get_timer_fn(player_unit)

	if type(r) == "table" and r.visible and type(r.text) == "string" and r.text ~= "" then
		return r
	end

	return nil
end

local function apply_right_slot_icon_color(widget, widget_name, entry, opacity, s_cfg, player_unit)
	local icon_style = widget and widget.style and widget.style.icon

	if not icon_style or not icon_style.color then
		return
	end

	local c = icon_style.color

	if widget_name == "slot_stimm" then
		local is_pocket_small = entry and entry.slot_id == "slot_pocketable_small"
		local has_stimm = is_pocket_small and entry.has_equipment
		local stimm_cd = get_stimm_countdown_display_for_player_unit(player_unit)

		if not has_stimm and not stimm_cd then
			apply_tinted_icon_color_from_palette(c, UIHudSettings.color_tint_main_1, opacity, true)

			return
		end

		if not has_stimm and stimm_cd then
			c[1] = math.floor(255 * opacity)
			c[2] = 255
			c[3] = 255
			c[4] = 255

			return
		end

		local tint_on = type(s_cfg) ~= "table" or s_cfg.stimm_slot_icon_tint_by_type ~= false

		if not tint_on then
			c[1] = math.floor(255 * opacity)
			c[2] = 255
			c[3] = 255
			c[4] = 255

			return
		end

		local item = entry.item
		local stimm_id = item and type(item.weapon_template) == "string" and item.weapon_template or nil
		local main = stimm_id and resolve_stimm_slot_main_argb_255(stimm_id, s_cfg) or nil

		if is_valid_argb_255(main) then
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

		return
	end

	if widget_name == "slot_pickup" and entry and entry.slot_id == "slot_pocketable" then
		if not entry.has_equipment then
			apply_tinted_icon_color_from_palette(c, UIHudSettings.color_tint_main_1, opacity, true)
		else
			c[1] = math.floor(255 * opacity)
			c[2] = 255
			c[3] = 255
			c[4] = 255
		end

		return
	end

	if widget_name == "slot_blitz" and entry and entry.slot_id == "slot_grenade_ability" and player_unit then
		local fraction = resolve_grenade_charge_fraction_from_player_unit(player_unit)
		local is_zero = fraction <= 0

		if grenade_slot_fraction_coloring_enabled() then
			if is_zero then
				apply_tinted_icon_color_from_palette(c, UIHudSettings.color_tint_main_1, opacity, true)
			else
				local palette_argb = resolve_ammo_palette_color_from_fraction(fraction)

				apply_tinted_icon_color_from_palette(c, palette_argb, opacity, false)
			end
		else
			if is_zero then
				apply_tinted_icon_color_from_palette(c, UIHudSettings.color_tint_main_1, opacity, true)
			else
				c[1] = math.floor(255 * opacity)
				c[2] = 255
				c[3] = 255
				c[4] = 255
			end
		end

		return
	end

	if widget_name == "slot_weapon_wielded" then
		local try_fn = mod.divisionhud_try_apply_wielded_weapon_icon_state_colors

		if type(try_fn) == "function" and try_fn(widget, widget_name, entry, opacity, s_cfg, player_unit) then
			return
		end
	end

	c[1] = math.floor(255 * opacity)
	c[2] = 255
	c[3] = 255
	c[4] = 255
end

HudElementDivisionHUD._reset_dynamic_offset_state = function(self)
	self._dyn_prev_yaw = nil
	self._dyn_prev_pitch = nil
	self._dyn_ox = 0
	self._dyn_oy = 0
end

HudElementDivisionHUD._compute_dynamic_root_offset = function(self, dt, player)
	local strength = read_mod_numeric_setting("dynamic_hud_strength")
	local pitch_ratio = read_mod_numeric_setting("dynamic_hud_pitch_ratio")
	local decay_hz = read_mod_numeric_setting("dynamic_hud_decay")
	local max_off = read_mod_numeric_setting("dynamic_hud_max_offset")

	if not player or player.get_orientation == nil then
		self:_reset_dynamic_offset_state()

		return 0, 0
	end

	local orientation = player:get_orientation()

	if not orientation or type(orientation.yaw) ~= "number" or type(orientation.pitch) ~= "number" then
		self:_reset_dynamic_offset_state()

		return 0, 0
	end

	local yaw = orientation.yaw
	local pitch = orientation.pitch
	local ox = self._dyn_ox or 0
	local oy = self._dyn_oy or 0
	local decay = math.exp(-decay_hz * dt)

	ox = ox * decay
	oy = oy * decay

	local prev_yaw = self._dyn_prev_yaw

	if prev_yaw then
		local dyaw = wrapped_angle_delta(prev_yaw, yaw)

		ox = ox - strength * dyaw
	end

	local prev_pitch = self._dyn_prev_pitch

	if prev_pitch then
		local dpitch = wrapped_angle_delta(prev_pitch, pitch)

		oy = oy + strength * pitch_ratio * dpitch
	end

	self._dyn_prev_yaw = yaw
	self._dyn_prev_pitch = pitch
	ox = math.clamp(ox, -max_off, max_off)
	oy = math.clamp(oy, -max_off, max_off)
	self._dyn_ox = ox
	self._dyn_oy = oy

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

local function icon_is_texture_bitmap_path(icon_path)
	return type(icon_path) == "string" and string.find(icon_path, "/textures/", 1, true) ~= nil
end

local function icon_must_skip_create_material(icon_path)
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
		if icon_is_texture_bitmap_path(icon) then
			widget.content.icon = Definitions.HUD_WEAPON_ICON_CONTAINER

			if not icon_style.material_values then
				icon_style.material_values = {}
			end

			icon_style.material_values.texture_map = icon
			icon_style.material_values.use_placeholder_texture = 0
		elseif icon_must_skip_create_material(icon) then
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
		if icon_is_texture_bitmap_path(icon) then
			widget.content.icon = Definitions.HUD_WEAPON_ICON_CONTAINER

			if not icon_style.material_values then
				icon_style.material_values = {}
			end

			icon_style.material_values.texture_map = icon
			icon_style.material_values.use_placeholder_texture = 0
		elseif icon_must_skip_create_material(icon) then
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
		if not entry.has_equipment or type(entry.weapon_template) ~= "table" then
			return "00"
		end

		local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")

		if not unit_data_extension then
			return "01"
		end

		local slot_component = unit_data_extension:read_component(slot_id)

		if not slot_component then
			return "01"
		end

		local hud_configuration = entry.weapon_template.hud_configuration

		if type(hud_configuration) == "table" and hud_configuration.uses_weapon_special_charges == true then
			local num_special_charges = slot_component.num_special_charges

			if type(num_special_charges) == "number" then
				return string.format("%02d", math.max(0, math.floor(num_special_charges + 0.5)))
			end

			return "00"
		end

		if type(hud_configuration) == "table" and hud_configuration.uses_ammunition == true then
			local total_current = Ammo.current_ammo_in_reserve(slot_component) or 0

			for ci = 1, NetworkConstants.clips_in_use.max_size do
				total_current = total_current + (Ammo.current_ammo_in_clips(slot_component, ci) or 0)
			end

			return string.format("%02d", math.max(0, math.floor(total_current + 0.5)))
		end

		return "01"
	end

	return "0"
end

HudElementDivisionHUD._wielded_weapon_counter_text = function(self, extensions, entry)
	if type(entry) ~= "table" or entry.slot_id ~= "slot_wielded_display" or not entry.has_equipment then
		return ""
	end

	local wielded_slot_id = entry.wielded_source_slot_id
	local weapon_template = entry.weapon_template
	local hud_configuration = weapon_template and weapon_template.hud_configuration
	local uses_weapon_special_charges = hud_configuration and hud_configuration.uses_weapon_special_charges
	local hud_ammo_icon = hud_configuration and hud_configuration.hud_ammo_icon

	if wielded_slot_id == nil or type(hud_configuration) ~= "table" or hud_configuration.uses_ammunition ~= true then
		return ""
	end

	if wielded_slot_id ~= "slot_primary" then
		return ""
	end

	if hud_ammo_icon ~= "content/ui/materials/icons/throwables/hud/zealot_throwing_knives_ammo_counter" then
		return ""
	end

	local unit_data_extension = extensions and extensions.unit_data

	if not unit_data_extension then
		return ""
	end

	local slot_component = unit_data_extension:read_component(wielded_slot_id)

	if not slot_component then
		return ""
	end

	if uses_weapon_special_charges == true then
		local num_special_charges = slot_component.num_special_charges

		if type(num_special_charges) ~= "number" then
			return ""
		end

		return string.format("x%d", math.max(0, num_special_charges))
	end

	local ok, current_clip = pcall(function()
		return Ammo.current_ammo_in_clips(slot_component)
	end)

	if not ok then
		return ""
	end

	return string.format("x%d", math.max(0, current_clip or 0))
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
		apply_ammo_big_text_colors(widget, opacity, UIHudSettings.color_tint_main_1)
		widget.dirty = true
		return
	end

	local clip, reserve = self:_read_weapon_slot_clip_reserve(unit_data_extension, visual_loadout_extension, ammo_slot_id)

	widget.content.text = format_ammo_big_display_count(clip)
	widget.content.text_reserve = format_ammo_big_display_count(reserve)

	local slot_component = unit_data_extension:read_component(ammo_slot_id)
	local fraction = resolve_ammo_total_fraction(slot_component)
	local is_zero = fraction <= 0
	local eff_opacity = resource_stack_effective_opacity(opacity, is_zero)
	local palette

	if is_zero then
		palette = UIHudSettings.color_tint_main_1
	elseif ammo_text_fraction_coloring_enabled() then
		palette = resolve_ammo_palette_color_from_fraction(fraction)
	else
		palette = UIHudSettings.color_tint_main_1
	end

	apply_ammo_big_text_colors(widget, eff_opacity, palette)
	widget.dirty = true
end

HudElementDivisionHUD._update_expedition_salvage = function(self, local_player, widget, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	local game_mode_manager = Managers.state and Managers.state.game_mode
	local game_mode = game_mode_manager and game_mode_manager:game_mode()
	local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()

	if game_mode_name ~= "expedition" or not game_mode or not game_mode.expedition_currency then
		widget.content.visible = false
		widget.dirty = true

		return
	end

	if not local_player or not local_player.is_human_controlled or not local_player:is_human_controlled() then
		widget.content.visible = false
		widget.dirty = true

		return
	end

	local peer_id = local_player.peer_id and local_player:peer_id()
	local amount = 0

	if peer_id then
		local ok, v = pcall(function()
			return game_mode:expedition_currency(peer_id)
		end)

		if ok and type(v) == "number" then
			amount = v
		elseif ok and v ~= nil then
			amount = tonumber(v) or 0
		end
	end

	local salvage_settings = WalletSettings.expedition_salvage
	local string_symbol = salvage_settings and salvage_settings.string_symbol or ""

	widget.content.visible = true
	widget.content.text = string.format("%s %s", Text.format_currency(math.floor(amount + 0.5)), string_symbol)

	local text_color = widget.style.text and widget.style.text.text_color

	if text_color then
		local is_zero = amount <= 0
		local base = is_zero and UIHudSettings.color_tint_ammo_high or UIHudSettings.color_tint_main_1
		local eff = resource_stack_effective_opacity(opacity, is_zero)

		text_color[1] = math.floor((base[1] or 255) * eff)
		text_color[2] = base[2] or 255
		text_color[3] = base[3] or 255
		text_color[4] = base[4] or 255
	end

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
			apply_right_slot_icon_color(widget, name, entry, opacity, mod._settings, player_unit)

			if widget.style.text then
				local raw_display
				local stimm_cd_for_colors

				if name == "slot_weapon_wielded" then
					raw_display = self:_wielded_weapon_counter_text(extensions, entry)
					widget.content.text = raw_display or ""
				else
					if name == "slot_stimm" then
						stimm_cd_for_colors = get_stimm_countdown_display_for_player_unit(player_unit)

						if stimm_cd_for_colors then
							raw_display = format_stimm_timer_text_as_whole_seconds(stimm_cd_for_colors.text)
						else
							raw_display = self:_slot_numeric_text(slot_id, entry, player_unit)
						end
					else
						raw_display = self:_slot_numeric_text(slot_id, entry, player_unit)
					end

					if name == "slot_blitz" or name == "slot_stimm" or name == "slot_pickup" then
						widget.content.text = division_right_slot_counter_markup_lead_unit_digit_as_background(raw_display)
					else
						widget.content.text = raw_display or ""
					end
				end

				local tc = widget.style.text.text_color
				local default_tc = DIVISION_SLOT_COUNTER_TEXT_COLOR_DEFAULT

				tc[1] = math.floor((default_tc[1] or 255) * opacity)
				tc[2] = default_tc[2]
				tc[3] = default_tc[3]
				tc[4] = default_tc[4]

				if name == "slot_stimm" then
					if stimm_cd_for_colors then
						local base = stimm_cd_for_colors.phase == "active" and DIVISION_STIMM_TIMER_ACTIVE_COLOR or DIVISION_STIMM_TIMER_COOLDOWN_COLOR

						tc[1] = math.floor((base[1] or 255) * opacity)
						tc[2] = base[2]
						tc[3] = base[3]
						tc[4] = base[4]
					elseif slot_id == "slot_pocketable_small" and not entry.has_equipment then
						local pal = UIHudSettings.color_tint_main_1
						local eff = resource_stack_effective_opacity(opacity, true)

						tc[1] = math.floor((pal[1] or 255) * eff)
						tc[2] = pal[2] or 255
						tc[3] = pal[3] or 255
						tc[4] = pal[4] or 255
					end
				elseif name == "slot_blitz" and slot_id == "slot_grenade_ability" then
					local fraction = resolve_grenade_charge_fraction_from_player_unit(player_unit)
					local is_zero = fraction <= 0

					if grenade_slot_fraction_coloring_enabled() then
						if is_zero then
							local pal = UIHudSettings.color_tint_main_1
							local eff = resource_stack_effective_opacity(opacity, true)

							tc[1] = math.floor((pal[1] or 255) * eff)
							tc[2] = pal[2] or 255
							tc[3] = pal[3] or 255
							tc[4] = pal[4] or 255
						else
							local palette_argb = resolve_ammo_palette_color_from_fraction(fraction)
							local eff = resource_stack_effective_opacity(opacity, false)

							if is_valid_argb_255(palette_argb) then
								tc[1] = math.floor((palette_argb[1] or 255) * eff)
								tc[2] = palette_argb[2] or 255
								tc[3] = palette_argb[3] or 255
								tc[4] = palette_argb[4] or 255
							end
						end
					elseif is_zero then
						local pal = UIHudSettings.color_tint_main_1
						local eff = resource_stack_effective_opacity(opacity, true)

						tc[1] = math.floor((pal[1] or 255) * eff)
						tc[2] = pal[2] or 255
						tc[3] = pal[3] or 255
						tc[4] = pal[4] or 255
					end
				elseif name == "slot_pickup" and slot_id == "slot_pocketable" and not entry.has_equipment then
					local pal = UIHudSettings.color_tint_main_1
					local eff = resource_stack_effective_opacity(opacity, true)

					tc[1] = math.floor((pal[1] or 255) * eff)
					tc[2] = pal[2] or 255
					tc[3] = pal[3] or 255
					tc[4] = pal[4] or 255
				else
					widget.style.text.text_color[1] = 255 * opacity
				end
			end

			widget.dirty = true
		end
	end
end

local function apply_alert_color_channel4(dst, src, opacity)
	if not dst or type(src) ~= "table" or type(opacity) ~= "number" then
		return
	end

	local a = type(src[1]) == "number" and src[1] or 230
	local r = type(src[2]) == "number" and src[2] or 255
	local gch = type(src[3]) == "number" and src[3] or 255
	local bch = type(src[4]) == "number" and src[4] or 255

	dst[1] = math.floor(a * opacity)
	dst[2] = r
	dst[3] = gch
	dst[4] = bch
end

local function apply_alert_pass_colors(st, palette, opacity)
	if not st or type(palette) ~= "table" or type(opacity) ~= "number" then
		return
	end

	if type(palette.upper) == "table" then
		apply_alert_color_channel4(st.alert_slot_upper_background and st.alert_slot_upper_background.color, palette.upper, opacity)
	end

	if type(palette.emitter) == "table" then
		apply_alert_color_channel4(st.alert_slot_upper_emitter and st.alert_slot_upper_emitter.color, palette.emitter, opacity)
	elseif type(palette.upper) == "table" then
		apply_alert_color_channel4(st.alert_slot_upper_emitter and st.alert_slot_upper_emitter.color, palette.upper, opacity)
	end

	if type(palette.strip) == "table" then
		apply_alert_color_channel4(st.alert_strip_background and st.alert_strip_background.color, palette.strip, opacity)
	end

	if type(palette.strip_text) == "table" then
		apply_alert_color_channel4(st.alert_strip_label_text and st.alert_strip_label_text.text_color, palette.strip_text, opacity)
	end

	if type(palette.duration_bar) == "table" then
		apply_alert_color_channel4(st.alert_duration_bar and st.alert_duration_bar.color, palette.duration_bar, opacity)
	end
end

local function apply_alerts_column_layout(self, widgets, slot_heights, column_width)
	local y_cursor = 0

	for si = 1, ALERTS_MAX_SLOTS do
		local h = (type(slot_heights) == "table" and type(slot_heights[si]) == "number" and slot_heights[si]) or 0
		local slot_id = "alert_slot_" .. si
		local wname = alert_slot_widget_names[si]
		local w = wname and widgets[wname]

		if h > 0 then
			self:set_scenegraph_position(slot_id, nil, y_cursor)
			self:_set_scenegraph_size(slot_id, column_width, h)

			if w and w.content and w.content.size then
				w.content.size[1] = column_width
				w.content.size[2] = h
			end

			y_cursor = y_cursor + h + ALERTS_SLOT_GAP
		else
			self:set_scenegraph_position(slot_id, nil, 0)
			self:_set_scenegraph_size(slot_id, column_width, 0)

			if w and w.content and w.content.size then
				w.content.size[1] = column_width
				w.content.size[2] = 0
			end
		end
	end

	local total_h = (y_cursor > 0) and (y_cursor - ALERTS_SLOT_GAP) or 0

	self:_set_scenegraph_size("alerts_column", column_width, total_h)
	self:set_scenegraph_position("alerts_column", nil, -(total_h + ALERTS_TOUGHNESS_GAP))
end

HudElementDivisionHUD._update_alert_slots = function(self, widgets, opacity, ui_renderer)
	local s_cfg = mod._settings
	local alerts_master_off = type(s_cfg) == "table" and (s_cfg.alerts_enabled == false or s_cfg.alerts_enabled == 0)
	local mission_mirror = mod.mission_objective_mirror_wants_alerts_ui and mod.mission_objective_mirror_wants_alerts_ui()
	local team_mirror = mod.team_alerts_wants_alerts_ui and mod.team_alerts_wants_alerts_ui()
	local alerts_mirror_ui = mission_mirror or team_mirror

	if alerts_master_off and not alerts_mirror_ui then
		if mod.alerts_clear then
			mod.alerts_clear()
		end

		for si = 1, ALERTS_MAX_SLOTS do
			local wname = alert_slot_widget_names[si]
			local w = wname and widgets[wname]

			if w and w.content then
				w.content.visible = false

				local st = w.style
				local dur_bar_sz = st and st.alert_duration_bar and st.alert_duration_bar.size

				if dur_bar_sz and type(dur_bar_sz[1]) == "number" then
					dur_bar_sz[1] = 0
				end

				w.dirty = true
			end
		end

		local slot_heights_off = {}

		for si_off = 1, ALERTS_MAX_SLOTS do
			slot_heights_off[si_off] = 0
		end

		apply_alerts_column_layout(self, widgets, slot_heights_off, ALERT_BAR_WIDTH)

		return
	end

	if alerts_master_off and alerts_mirror_ui and mod.alerts_prune_for_master_off_mirror then
		mod.alerts_prune_for_master_off_mirror(mission_mirror, team_mirror)
	end

	local Hu = mod.hud_utils
	local gt = nil

	if Hu and type(Hu.safe_time_for_alerts) == "function" then
		gt = Hu.safe_time_for_alerts()
	elseif Hu and type(Hu.safe_gameplay_time) == "function" then
		gt = Hu.safe_gameplay_time()
	end

	if type(gt) ~= "number" or gt ~= gt then
		return
	end

	if mod.alerts_sync then
		mod.alerts_sync(gt)
	end

	local slot_heights = {}

	for si_h = 1, ALERTS_MAX_SLOTS do
		slot_heights[si_h] = 0
	end

	local lines = mod.alerts_get_lines and mod.alerts_get_lines() or {}
	local n = #lines
	local banner_raw = Localize("loc_objective_op_train_alert_header")
	local banner_upper = ""

	if type(banner_raw) == "string" and banner_raw ~= "" and not string.find(banner_raw, "^<unlocalized") then
		banner_upper = Utf8.upper(banner_raw)
	else
		banner_upper = Utf8.upper(mod:localize("alerts_ui_banner_alert"))
	end

	local show_alert_duration_bar = type(s_cfg) == "table" and (s_cfg.alerts_show_duration_bar == true or s_cfg.alerts_show_duration_bar == 1)

	for si = 1, ALERTS_MAX_SLOTS do
		local wname = alert_slot_widget_names[si]
		local w = wname and widgets[wname]

		if w and w.content then
			local idx = nil

			if n > 0 and si >= ALERTS_MAX_SLOTS - n + 1 then
				idx = ALERTS_MAX_SLOTS + 1 - si
			end

			if idx and lines[idx] and type(lines[idx].text) == "string" and lines[idx].text ~= "" then
				local line = lines[idx]
				local strip_raw = line.strip_label

				if type(strip_raw) == "string" and strip_raw ~= "" then
					w.content.alert_strip_label_text = Utf8.upper(strip_raw)
				else
					w.content.alert_strip_label_text = banner_upper
				end

				w.content.visible = true
				w.content.alert_message_text = line.text
				w.alpha_multiplier = opacity

				local st = w.style

				if st then
					local msg_tc = st.alert_message_text and st.alert_message_text.text_color
					local cat = line.alert_line_category
					local pal = ALERT_PALETTE_DEFAULT

					if cat == "boss" then
						pal = ALERT_PALETTE_BOSS
					elseif cat == "mission" and type(ALERT_PALETTE_MISSION_OBJECTIVE) == "table" then
						pal = ALERT_PALETTE_MISSION_OBJECTIVE
					elseif cat == "team" and type(ALERT_PALETTE_TEAM) == "table" then
						pal = ALERT_PALETTE_TEAM
					end

					if type(pal) == "table" then
						apply_alert_pass_colors(st, pal, opacity)
					end

					if msg_tc and type(msg_tc[1]) == "number" then
						msg_tc[1] = math.floor(255 * opacity)
					end

					local dur_bar = st.alert_duration_bar
					local dur_bar_sz = dur_bar and dur_bar.size

					if show_alert_duration_bar then
						local line_dur = type(line.duration_sec) == "number" and line.duration_sec > 0 and line.duration_sec or nil
						local rem_t = type(line.expire_t) == "number" and (line.expire_t - gt) or 0
						local frac = 1

						if line_dur then
							frac = math.clamp(rem_t / line_dur, 0, 1)
						end

						if dur_bar_sz and type(dur_bar_sz[1]) == "number" and type(dur_bar_sz[2]) == "number" then
							dur_bar_sz[1] = math.max(0, math.floor(ALERT_BAR_WIDTH * frac + 0.5))
						end

						local dbc = dur_bar and dur_bar.color

						if dbc and type(pal) == "table" and type(pal.duration_bar) == "table" and type(pal.duration_bar[1]) == "number" then
							dbc[1] = math.floor(pal.duration_bar[1] * opacity)
						elseif dbc and type(dbc[1]) == "number" then
							dbc[1] = math.floor(230 * opacity)
						end
					elseif dur_bar_sz and type(dur_bar_sz[1]) == "number" then
						dur_bar_sz[1] = 0
					end

					local msg_st = st.alert_message_text
					local body_h = ALERTS_BODY_HEIGHT_MIN

					if ui_renderer and msg_st and type(ALERTS_MESSAGE_TEXT_WRAP_WIDTH) == "number" and type(ALERTS_MESSAGE_TEXT_VERTICAL_INSET) == "number" then
						local measured = Text.text_height(ui_renderer, line.text, msg_st, {
							ALERTS_MESSAGE_TEXT_WRAP_WIDTH,
							4096,
						}, true)

						body_h = math.ceil(measured + ALERTS_MESSAGE_TEXT_VERTICAL_INSET + ALERTS_MESSAGE_TEXT_OFFSET_Y)
						body_h = math.clamp(body_h, ALERTS_BODY_HEIGHT_MIN, ALERTS_BODY_HEIGHT_MAX)
					end

					local text_box_h = body_h - ALERTS_MESSAGE_TEXT_VERTICAL_INSET - ALERTS_MESSAGE_TEXT_OFFSET_Y

					if msg_st and msg_st.size then
						msg_st.size[2] = text_box_h
					end

					local ub = st.alert_slot_upper_background
					local ue = st.alert_slot_upper_emitter

					if ub and ub.size then
						ub.size[2] = body_h
					end

					if ue and ue.size then
						ue.size[2] = body_h
					end

					slot_heights[si] = body_h + ALERTS_STRIP_HEIGHT
				else
					slot_heights[si] = ALERTS_BODY_HEIGHT_MIN + ALERTS_STRIP_HEIGHT
				end

				w.dirty = true
			else
				w.content.visible = false

				local st = w.style
				local dur_bar = st and st.alert_duration_bar
				local dur_bar_sz = dur_bar and dur_bar.size

				if dur_bar_sz and type(dur_bar_sz[1]) == "number" then
					dur_bar_sz[1] = 0
				end

				if st then
					local msg_st_h = st.alert_message_text
					local ub_h = st.alert_slot_upper_background
					local ue_h = st.alert_slot_upper_emitter

					if msg_st_h and msg_st_h.size then
						msg_st_h.size[2] = 0
					end

					if ub_h and ub_h.size then
						ub_h.size[2] = 0
					end

					if ue_h and ue_h.size then
						ue_h.size[2] = 0
					end
				end

				slot_heights[si] = 0
				w.dirty = true
			end
		end
	end

	apply_alerts_column_layout(self, widgets, slot_heights, ALERT_BAR_WIDTH)
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

	self:_reset_dynamic_offset_state()

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
			dyn_x, dyn_y = self:_compute_dynamic_root_offset(dt, local_player)
		else
			self:_reset_dynamic_offset_state()
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
		self:_reset_dynamic_offset_state()

		if mod.alerts_clear then
			mod.alerts_clear()
		end

		self:_set_all_visible(false)
		return
	end

	if not local_player or not player_unit then
		self:_reset_dynamic_offset_state()

		if mod.alerts_clear then
			mod.alerts_clear()
		end

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
	self:_update_expedition_salvage(local_player, widgets.expedition_salvage, opacity)
	self:_update_ammo_big(player_unit, widgets.ammo_big, opacity)
	self:_update_auspex_slot(player_unit, widgets, opacity)
	self:_update_right_slot_grid(player_unit, widgets, opacity)
	self:_update_alert_slots(widgets, opacity, ui_renderer)
end

HudElementDivisionHUD._update_ability_bar = function(self, player_unit, widget, opacity)
	CombatAbilityBar.update(player_unit, widget, opacity, Definitions, COMBAT_ABILITY_TYPE)
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
	self:_reset_dynamic_offset_state()

	VanillaStaminaDodge.destroy(self, ui_renderer)
	VanillaToughnessHealth.destroy(self, ui_renderer)

	HudElementDivisionHUD.super.destroy(self, ui_renderer)
end

return HudElementDivisionHUD
