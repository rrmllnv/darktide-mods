local mod = get_mod("SquadHud")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local TextUtilities = require("scripts/utilities/ui/text")

local Definitions = mod:io_dofile("SquadHud/scripts/mods/SquadHud/hud/definitions/squad_hud_definitions")
local DefinitionSettings = Definitions.settings
local AbilityRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/ability_runtime")
local InventoryRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/inventory_runtime")
local PlayerDataRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/player_data_runtime")
local StatusRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/status_runtime")

local MAX_PLAYERS = DefinitionSettings.max_players
local HEALTH_BAR_Y = DefinitionSettings.health_bar_y
local BAR_ACTIVE_HEIGHT = DefinitionSettings.bar_active_height
local BAR_INACTIVE_HEIGHT = DefinitionSettings.bar_inactive_height
local BAR_GAP = DefinitionSettings.bar_gap
local ACTIVE_BAR_VISIBLE_DURATION = DefinitionSettings.active_bar_visible_duration
local OVERSHIELD_SPENT_DURATION = DefinitionSettings.overshield_spent_duration
local OVERSHIELD_SPENT_HEIGHT_ADDITION = DefinitionSettings.overshield_spent_height_addition
local TOUGHNESS_HIT_INDICATOR_DURATION = DefinitionSettings.toughness_hit_indicator_duration
local TOUGHNESS_HIT_INDICATOR_PADDING = DefinitionSettings.toughness_hit_indicator_padding
local TOUGHNESS_HIT_INDICATOR_ARMOR_BREAK_EXTRA_SIZE = DefinitionSettings.toughness_hit_indicator_armor_break_extra_size
local INVENTORY_ICON_SIZE = DefinitionSettings.inventory_icon_size
local INVENTORY_ICON_GAP = DefinitionSettings.inventory_icon_gap
local INVENTORY_ICON_X = DefinitionSettings.inventory_icon_x
local INVENTORY_ICON_Y = DefinitionSettings.inventory_icon_y
local GRENADE_VALUE = DefinitionSettings.grenade_value
local AMMO_PERCENT = DefinitionSettings.ammo_percent
local INVENTORY_VALUE = DefinitionSettings.inventory_value
local EXPANDED_VIEW_BLOCK_TRANSITION_DURATION = 0.24
local EXPANDED_VIEW_BLOCK_STAGGER = 0.04
local EXPANDED_VIEW_BLOCK_SLIDE_OFFSET = INVENTORY_VALUE.slide_offset or 18
local EXPANDED_VIEW_BLOCK_ITEM_COUNT = 6
local BAR_LEFT = DefinitionSettings.bar_left
local BAR_WIDTH = DefinitionSettings.bar_width
local HEALTH_SEGMENT_GAP = DefinitionSettings.health_segment_gap
local DEFAULT_REVIVE_DURATION = DefinitionSettings.default_revive_duration
local NAME_X = DefinitionSettings.name_x
local NAME_LEFT_WITHOUT_CLASS_ICON = DefinitionSettings.status_background_x
local NAME_WIDTH = DefinitionSettings.name_width
local NAME_RIGHT_X = DefinitionSettings.name_right_x
local NAME_RIGHT_WITH_RELATION_STATUS = DefinitionSettings.relation_status_x - DefinitionSettings.relation_status_left_padding
local NAME_MARQUEE_START_PAUSE = DefinitionSettings.name_marquee_start_pause
local NAME_MARQUEE_MOVE_DURATION = DefinitionSettings.name_marquee_move_duration
local NAME_MARQUEE_END_PAUSE = DefinitionSettings.name_marquee_end_pause
local NAME_MARQUEE_RETURN_DURATION = DefinitionSettings.name_marquee_return_duration
local NAME_MARQUEE_TOTAL_DURATION = DefinitionSettings.name_marquee_total_duration
local COHERENCY_BORDER_WIDTH = DefinitionSettings.coherency_border_width
local DEFAULT_POSITION_X = 50
local DEFAULT_POSITION_Y = 780
local DEFAULT_OPACITY = 1
local DEFAULT_HUD_LAYOUT_SCALE = 0.8
local AMMO_CRATE_TEMPLATE_ID = "ammo_cache_pocketable"
local MEDICAL_CRATE_TEMPLATE_ID = "medical_crate_pocketable"

local COLOR_TEXT_DEFAULT = DefinitionSettings.color_text_default
local COLOR_PLAYER_NAME_INACTIVE = DefinitionSettings.color_player_name_inactive
local COLOR_TOUGHNESS = DefinitionSettings.color_toughness
local COLOR_TOUGHNESS_OVERSHIELD = DefinitionSettings.color_toughness_overshield
local COLOR_HEALTH = DefinitionSettings.color_health
local COLOR_HEALTH_CRITICAL = DefinitionSettings.color_health_critical
local COLOR_RESCUE_AVAILABLE = DefinitionSettings.color_rescue_available
local COLOR_REVIVE = DefinitionSettings.color_revive
local COLOR_ABILITY_ICON = DefinitionSettings.color_ability_icon
local COLOR_ABILITY_FRAME = DefinitionSettings.color_ability_frame
local COLOR_ABILITY_GLOW = DefinitionSettings.color_ability_glow
local COLOR_ABILITY_READY_GLOW = DefinitionSettings.color_ability_ready_glow
local COLOR_ABILITY_COOLDOWN_ICON = DefinitionSettings.color_ability_cooldown_icon
local COLOR_ABILITY_COOLDOWN_FRAME = DefinitionSettings.color_ability_cooldown_frame
local COLOR_ABILITY_COOLDOWN_GLOW = DefinitionSettings.color_ability_cooldown_glow
local COLOR_STATUS_BACKGROUND_DEFAULT = DefinitionSettings.color_status_background_default
local COLOR_STATUS_BACKGROUND_CRITICAL = DefinitionSettings.color_status_background_critical
local COLOR_TOUGHNESS_HIT_INDICATOR = DefinitionSettings.color_toughness_hit_indicator
local COLOR_TOUGHNESS_ARMOR_BREAK_INDICATOR = DefinitionSettings.color_toughness_armor_break_indicator
local COLOR_COHERENCY_BORDER_IN = DefinitionSettings.color_coherency_border_in
local COLOR_COHERENCY_BORDER_OUT = DefinitionSettings.color_coherency_border_out
local COLOR_AMMO_NOT_IN_USE = DefinitionSettings.color_ammo_not_in_use
local COLOR_AMMO_HIGH = DefinitionSettings.color_ammo_high
local COLOR_AMMO_MEDIUM = DefinitionSettings.color_ammo_medium
local COLOR_AMMO_LOW = DefinitionSettings.color_ammo_low
local COLOR_AMMO_FULL = DefinitionSettings.color_ammo_full
local COLOR_STIMM_BY_TEMPLATE = DefinitionSettings.color_stimm_by_template

local scenegraph_definition = Definitions.scenegraph_definition

local widget_definitions = Definitions.widget_definitions

local HudElementSquadHud = class("HudElementSquadHud", "HudElementBase")
local CUSTOM_HUD_MOD_NAME = "custom_hud"
local CUSTOM_HUD_NODE_PREFIX = "HudElementSquadHud|"
local CUSTOM_HUD_ROOT_NODE_NAME = CUSTOM_HUD_NODE_PREFIX .. "squadhud_root"

local function setting_enabled()
	local value = mod:get("squadhud_enabled")

	return value == true or value == nil
end

local function numeric_setting(setting_id, fallback)
	local value = mod:get(setting_id)

	if type(value) == "number" and value == value then
		return value
	end

	return fallback
end

local function boolean_setting(setting_id, fallback)
	local value = mod:get(setting_id)

	if value == false or value == 0 then
		return false
	elseif value == true or value == 1 then
		return true
	end

	return fallback
end

local function squad_panel_display_mode()
	local value = mod:get("squadhud_panel_display_mode")

	if value == "local" or value == "teammates" then
		return value
	end

	return "all"
end

local function ammo_percent_mode()
	local value = mod:get("squadhud_ammo_percent_mode")

	if value == "never" or value == "always" then
		return value
	end

	return "changed"
end

local function grenade_value_mode()
	local value = mod:get("squadhud_grenade_value_mode")

	if value == "never" or value == "always" then
		return value
	end

	return "changed"
end

local function ammo_value_format()
	local value = mod:get("squadhud_ammo_value_format")

	if value == "count" or value == "current_max" then
		return value
	end

	return "percent"
end

local function custom_hud_mod()
	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" then
		return nil
	end

	local ok, custom_hud = pcall(get_mod_fn, CUSTOM_HUD_MOD_NAME)

	if ok and custom_hud and type(custom_hud) == "table" then
		return custom_hud
	end

	return nil
end

local function custom_hud_saved_node_settings()
	local custom_hud = custom_hud_mod()

	if not custom_hud or type(custom_hud.get) ~= "function" then
		return nil
	end

	local ok, saved_node_settings = pcall(function()
		return custom_hud:get("saved_node_settings")
	end)

	if ok and type(saved_node_settings) == "table" then
		return saved_node_settings
	end

	return nil
end

local function custom_hud_has_squadhud_root_node()
	local saved_node_settings = custom_hud_saved_node_settings()

	if not saved_node_settings then
		return false
	end

	return type(saved_node_settings[CUSTOM_HUD_ROOT_NODE_NAME]) == "table"
end

local function apply_color(target, source)
	target[1] = source[1]
	target[2] = source[2]
	target[3] = source[3]
	target[4] = source[4]
end

local function set_rect_width(style, width)
	if style and style.size then
		style.size[1] = math.max(0, width)
	end
end

local ActiveBar = {}
local OvershieldSpent = {}
local ToughnessHitIndicator = {}
local GrenadeValue = {}
local AmmoPercent = {}
local InventoryValue = {}

ActiveBar.rounded_fraction = function(value)
	return math.floor(math.clamp(value or 0, 0, 1) * 10000 + 0.5)
end

ActiveBar.mode = function(hud, player_key, health_fraction, toughness_fraction, bonus_value, has_overshield, revive_state, t)
	if revive_state and revive_state.in_progress then
		return "toughness"
	end

	if not player_key then
		return "health"
	end

	local state_by_player = hud._active_bar_state_by_player

	if not state_by_player then
		return "health"
	end

	local state = state_by_player[player_key]

	if not state then
		state = {}
		state_by_player[player_key] = state
	end

	local now = type(t) == "number" and t or 0
	local health = ActiveBar.rounded_fraction(health_fraction)
	local toughness = ActiveBar.rounded_fraction(toughness_fraction)
	local bonus = InventoryValue.rounded(bonus_value)

	if has_overshield and bonus > 0 then
		state.initialized = true
		state.health = health
		state.toughness = toughness
		state.bonus = bonus
		state.mode = "toughness"
		state.until_t = nil

		return "toughness"
	end

	if state.initialized then
		local health_changed = health ~= state.health
		local toughness_changed = toughness ~= state.toughness
		local bonus_changed = bonus ~= (state.bonus or 0)
		local toughness_value_changed = toughness_changed or bonus_changed
		local health_is_locked = state.mode == "health" and state.until_t and now <= state.until_t

		if health_changed then
			state.mode = "health"
			state.until_t = now + ACTIVE_BAR_VISIBLE_DURATION
		elseif toughness_value_changed and not health_is_locked then
			state.mode = "toughness"
			state.until_t = now + ACTIVE_BAR_VISIBLE_DURATION
		end
	end

	state.initialized = true
	state.health = health
	state.toughness = toughness
	state.bonus = bonus

	if state.mode and state.until_t and now <= state.until_t then
		return state.mode
	end

	state.mode = nil
	state.until_t = nil

	return "health"
end

InventoryValue.rounded = function(value)
	return math.ceil(math.max(0, value or 0))
end

InventoryValue.text = function(value)
	return tostring(InventoryValue.rounded(value))
end

OvershieldSpent.apply = function(hud, player_key, content, style, has_overshield, toughness_fraction, toughness_bar_y, toughness_bar_height, revive_state, t)
	local spent_style = style.toughness_overshield_spent

	if not spent_style then
		return
	end

	local size_addition = spent_style.size_addition
	local now = type(t) == "number" and t or 0
	local current_width = BAR_WIDTH * math.clamp(toughness_fraction or 0, 0, 1)
	local state_by_player = hud._overshield_spent_state_by_player

	if not player_key or not state_by_player then
		content.toughness_overshield_spent_visible = false
		spent_style.color[1] = 0
		spent_style.size[1] = 0

		if size_addition then
			size_addition[2] = 0
		end

		return
	end

	local state = state_by_player[player_key]

	if not state then
		state = {}
		state_by_player[player_key] = state
	end

	local revive_in_progress = revive_state and revive_state.in_progress

	if state.has_overshield == true and not has_overshield and not revive_in_progress then
		state.start_t = now
		state.spent_width = math.max(state.width or 0, current_width)
	end

	state.has_overshield = has_overshield == true
	state.width = current_width
	spent_style.offset[2] = toughness_bar_y
	spent_style.size[2] = toughness_bar_height

	if state.start_t then
		local progress = math.clamp((now - state.start_t) / OVERSHIELD_SPENT_DURATION, 0, 1)
		local anim_progress = math.easeOutCubic(progress)

		content.toughness_overshield_spent_visible = true
		spent_style.size[1] = state.spent_width or current_width
		spent_style.color[1] = 255 * (1 - anim_progress)
		spent_style.color[2] = COLOR_TOUGHNESS_OVERSHIELD[2]
		spent_style.color[3] = COLOR_TOUGHNESS_OVERSHIELD[3]
		spent_style.color[4] = COLOR_TOUGHNESS_OVERSHIELD[4]

		if size_addition then
			size_addition[2] = anim_progress * OVERSHIELD_SPENT_HEIGHT_ADDITION
		end

		if progress >= 1 then
			state.start_t = nil
			state.spent_width = nil
			content.toughness_overshield_spent_visible = false
			spent_style.color[1] = 0
			spent_style.size[1] = 0

			if size_addition then
				size_addition[2] = 0
			end
		end
	else
		content.toughness_overshield_spent_visible = false
		spent_style.color[1] = 0
		spent_style.size[1] = 0

		if size_addition then
			size_addition[2] = 0
		end
	end
end

local function apply_toughness_hit_rect(rect_style, color, alpha, extra_size)
	if not rect_style then
		return
	end

	local padding = TOUGHNESS_HIT_INDICATOR_PADDING
	local extra = extra_size or 0

	apply_color(rect_style.color, color)
	rect_style.color[1] = alpha
	rect_style.offset[1] = DefinitionSettings.status_background_x - padding - extra * 0.5
	rect_style.offset[2] = DefinitionSettings.status_background_y - padding - extra * 0.5
	rect_style.size[1] = DefinitionSettings.status_background_width + padding * 2 + extra
	rect_style.size[2] = DefinitionSettings.status_background_height + padding * 2 + extra
end

local function clear_toughness_hit_indicator(content, style)
	content.toughness_hit_indicator_visible = false
	content.toughness_armor_break_indicator_visible = false

	apply_toughness_hit_rect(style.toughness_hit_indicator, COLOR_TOUGHNESS_HIT_INDICATOR, 0, 0)
	apply_toughness_hit_rect(style.toughness_armor_break_indicator, COLOR_TOUGHNESS_ARMOR_BREAK_INDICATOR, 0, 0)
end

ToughnessHitIndicator.apply = function(hud, player_key, content, style, status, toughness_fraction, t, debug_request)
	local hit_style = style.toughness_hit_indicator
	local armor_break_style = style.toughness_armor_break_indicator

	if not hit_style or not armor_break_style then
		return
	end

	local now = type(t) == "number" and t or 0
	local current_toughness = math.clamp(toughness_fraction or 0, 0, 1)
	local state_by_player = hud._toughness_hit_indicator_state_by_player

	if not player_key or not state_by_player then
		clear_toughness_hit_indicator(content, style)

		return
	end

	local state = state_by_player[player_key]

	if not state then
		state = {
			toughness = current_toughness,
		}
		state_by_player[player_key] = state
	end

	local should_clear = status == "dead" or status == "hogtied" or status == "down"

	if should_clear then
		state.start_t = nil
		state.armor_break = false
		state.toughness = current_toughness
		clear_toughness_hit_indicator(content, style)

		return
	end

	if type(debug_request) == "table" then
		state.start_t = now
		state.armor_break = debug_request.armor_break == true
		state.toughness = current_toughness
	end

	if state.toughness and current_toughness < state.toughness then
		state.start_t = now
		state.armor_break = current_toughness <= 0
	end

	state.toughness = current_toughness

	if not state.start_t then
		clear_toughness_hit_indicator(content, style)

		return
	end

	local progress = math.clamp((now - state.start_t) / TOUGHNESS_HIT_INDICATOR_DURATION, 0, 1)

	if progress >= 1 then
		state.start_t = nil
		state.armor_break = false
		clear_toughness_hit_indicator(content, style)

		return
	end

	local pulse_progress = math.easeInCubic(math.ease_pulse(progress))
	local hit_alpha = 150 * pulse_progress
	local armor_break_alpha = state.armor_break and 45 * pulse_progress or 0
	local armor_break_extra_size = state.armor_break and TOUGHNESS_HIT_INDICATOR_ARMOR_BREAK_EXTRA_SIZE * math.easeOutCubic(progress) or 0

	content.toughness_hit_indicator_visible = true
	content.toughness_armor_break_indicator_visible = state.armor_break == true

	apply_toughness_hit_rect(hit_style, COLOR_TOUGHNESS_HIT_INDICATOR, hit_alpha, armor_break_extra_size)
	apply_toughness_hit_rect(armor_break_style, COLOR_TOUGHNESS_ARMOR_BREAK_INDICATOR, armor_break_alpha, armor_break_extra_size)
end

InventoryValue.colored_text = function(text, color)
	return "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. text .. "{#reset()}"
end

local function smoothstep(progress)
	progress = math.clamp(progress, 0, 1)

	return progress * progress * (3 - 2 * progress)
end

GrenadeValue.text = function(inventory_icons)
	return tostring(math.max(0, math.floor((inventory_icons.grenade_current or 0) + 0.5)))
end

GrenadeValue.text_width = function(ui_renderer, text, style)
	if not ui_renderer or not style or text == nil or text == "" then
		return 0
	end

	local width = TextUtilities.text_width(ui_renderer, text, style, nil, true) or 0

	return math.min(GRENADE_VALUE.text_width, math.ceil(width) + 2)
end

GrenadeValue.transition_fraction = function(state, now)
	if not state.transition_start_t then
		return state.target_visible and 1 or 0
	end

	local progress = math.clamp((now - state.transition_start_t) / GRENADE_VALUE.slide_duration, 0, 1)
	local eased_progress = smoothstep(progress)
	local fraction = (state.from_fraction or 0) + ((state.to_fraction or 0) - (state.from_fraction or 0)) * eased_progress

	if progress >= 1 then
		state.transition_start_t = nil
		state.from_fraction = nil
		state.to_fraction = nil
		fraction = state.target_visible and 1 or 0
	end

	return fraction
end

GrenadeValue.clear = function(hud, player_key, content, style)
	content.grenade_value_text = ""

	if style.grenade_value_text then
		style.grenade_value_text.offset[1] = DefinitionSettings.grenade_icon_x
		style.grenade_value_text.text_color[1] = 0
	end

	if player_key and hud._grenade_value_state_by_player then
		hud._grenade_value_state_by_player[player_key] = nil
	end

	return {
		fraction = 0,
		width = 0,
	}
end

GrenadeValue.apply = function(hud, player_key, content, style, inventory_icons, color, ui_renderer, t, force_visible)
	local mode = grenade_value_mode()
	local has_grenade_value = inventory_icons and inventory_icons.grenade_icon ~= nil and type(inventory_icons.grenade_current) == "number"

	if mode == "never" or not has_grenade_value or not player_key or not hud._grenade_value_state_by_player then
		return GrenadeValue.clear(hud, player_key, content, style)
	end

	local now = type(t) == "number" and t or 0
	local text = GrenadeValue.text(inventory_icons)
	local grenade_current = inventory_icons.grenade_current
	local grenade_max = inventory_icons.grenade_max
	local grenade_key = tostring(grenade_current or "") .. "/" .. tostring(grenade_max or "")
	local text_style = style.grenade_value_text
	local text_width = GrenadeValue.text_width(ui_renderer, text, text_style)
	local state = hud._grenade_value_state_by_player[player_key]

	if not state then
		state = {
			current_fraction = 0,
			grenade_key = grenade_key,
			target_visible = false,
			text = text,
			width = text_width,
		}
		hud._grenade_value_state_by_player[player_key] = state
	elseif mode == "changed" and state.grenade_key ~= grenade_key then
		state.visible_until_t = now + GRENADE_VALUE.visible_duration
	end

	state.grenade_key = grenade_key
	state.text = text
	state.width = text_width

	local target_visible = mode == "always" or (mode == "changed" and (force_visible == true or state.visible_until_t ~= nil and now <= state.visible_until_t))

	if state.target_visible ~= target_visible then
		state.from_fraction = state.current_fraction or (state.target_visible and 1 or 0)
		state.to_fraction = target_visible and 1 or 0
		state.transition_start_t = now
		state.target_visible = target_visible
	end

	local fraction = GrenadeValue.transition_fraction(state, now)

	state.current_fraction = fraction

	if fraction > 0 or target_visible then
		content.grenade_value_text = text
	else
		content.grenade_value_text = ""
	end

	if text_style then
		apply_color(text_style.text_color, color)
		text_style.text_color[1] = math.floor((color[1] or 255) * fraction + 0.5)
	end

	return {
		fraction = fraction,
		width = text_width,
	}
end

AmmoPercent.text = function(inventory_icons, format)
	if format == "count" then
		return tostring(math.max(0, math.floor((inventory_icons.ammo_count_current or 0) + 0.5)))
	end

	if format == "current_max" then
		local current = math.max(0, math.floor((inventory_icons.ammo_count_current or 0) + 0.5))
		local maximum = math.max(0, math.floor((inventory_icons.ammo_count_max or 0) + 0.5))

		return string.format("%d/%d", current, maximum)
	end

	return string.format("%d%%", math.clamp(math.floor((inventory_icons.ammo_percent or 0) + 0.5), 0, 100))
end

AmmoPercent.text_width = function(ui_renderer, text, style)
	if not ui_renderer or not style or text == nil or text == "" then
		return 0
	end

	local width = TextUtilities.text_width(ui_renderer, text, style, nil, true) or 0

	return math.min(AMMO_PERCENT.text_width, math.ceil(width) + 2)
end

AmmoPercent.transition_fraction = function(state, now)
	if not state.transition_start_t then
		return state.target_visible and 1 or 0
	end

	local progress = math.clamp((now - state.transition_start_t) / AMMO_PERCENT.slide_duration, 0, 1)
	local eased_progress = smoothstep(progress)
	local fraction = (state.from_fraction or 0) + ((state.to_fraction or 0) - (state.from_fraction or 0)) * eased_progress

	if progress >= 1 then
		state.transition_start_t = nil
		state.from_fraction = nil
		state.to_fraction = nil
		fraction = state.target_visible and 1 or 0
	end

	return fraction
end

AmmoPercent.clear = function(hud, player_key, content, style)
	content.ammo_percent_text = ""

	if style.ammo_percent_text then
		style.ammo_percent_text.offset[1] = DefinitionSettings.ammo_icon_x
		style.ammo_percent_text.text_color[1] = 0
	end

	if player_key and hud._ammo_percent_state_by_player then
		hud._ammo_percent_state_by_player[player_key] = nil
	end

	return {
		fraction = 0,
		width = 0,
	}
end

AmmoPercent.apply = function(hud, player_key, content, style, inventory_icons, color, ui_renderer, t, force_visible)
	local mode = ammo_percent_mode()
	local format = ammo_value_format()
	local has_ammo_value = inventory_icons and inventory_icons.ammo_icon ~= nil and inventory_icons.uses_ammo == true and ((format == "count" and type(inventory_icons.ammo_count_current) == "number") or (format == "current_max" and type(inventory_icons.ammo_count_current) == "number" and type(inventory_icons.ammo_count_max) == "number") or (format ~= "count" and format ~= "current_max" and type(inventory_icons.ammo_percent) == "number"))

	if mode == "never" or not has_ammo_value or not player_key or not hud._ammo_percent_state_by_player then
		return AmmoPercent.clear(hud, player_key, content, style)
	end

	local now = type(t) == "number" and t or 0
	local text = AmmoPercent.text(inventory_icons, format)
	local use_count_totals = format == "count" or format == "current_max"
	local ammo_current = use_count_totals and inventory_icons.ammo_count_current or inventory_icons.ammo_current
	local ammo_max = use_count_totals and inventory_icons.ammo_count_max or inventory_icons.ammo_max
	local ammo_key = tostring(ammo_current or "") .. "/" .. tostring(ammo_max or "")
	local text_style = style.ammo_percent_text
	local text_width = AmmoPercent.text_width(ui_renderer, text, text_style)
	local state = hud._ammo_percent_state_by_player[player_key]

	if not state then
		state = {
			ammo_key = ammo_key,
			current_fraction = 0,
			format = format,
			target_visible = false,
			text = text,
			width = text_width,
		}
		hud._ammo_percent_state_by_player[player_key] = state
	elseif mode == "changed" and (state.ammo_key ~= ammo_key or state.format ~= format) then
		state.visible_until_t = now + AMMO_PERCENT.visible_duration
	end

	state.ammo_key = ammo_key
	state.format = format
	state.text = text
	state.width = text_width

	local target_visible = mode == "always" or (mode == "changed" and (force_visible == true or state.visible_until_t ~= nil and now <= state.visible_until_t))

	if state.target_visible ~= target_visible then
		state.from_fraction = state.current_fraction or (state.target_visible and 1 or 0)
		state.to_fraction = target_visible and 1 or 0
		state.transition_start_t = now
		state.target_visible = target_visible
	end

	local fraction = AmmoPercent.transition_fraction(state, now)

	state.current_fraction = fraction

	if fraction > 0 or target_visible then
		content.ammo_percent_text = text
	else
		content.ammo_percent_text = ""
	end

	if text_style then
		apply_color(text_style.text_color, color)
		text_style.text_color[1] = math.floor((color[1] or 255) * fraction + 0.5)
	end

	return {
		fraction = fraction,
		width = text_width,
	}
end

local function name_marquee_fraction(elapsed)
	local cycle_t = elapsed % NAME_MARQUEE_TOTAL_DURATION

	if cycle_t < NAME_MARQUEE_START_PAUSE then
		return 0
	end

	cycle_t = cycle_t - NAME_MARQUEE_START_PAUSE

	if cycle_t < NAME_MARQUEE_MOVE_DURATION then
		return smoothstep(cycle_t / NAME_MARQUEE_MOVE_DURATION)
	end

	cycle_t = cycle_t - NAME_MARQUEE_MOVE_DURATION

	if cycle_t < NAME_MARQUEE_END_PAUSE then
		return 1
	end

	cycle_t = cycle_t - NAME_MARQUEE_END_PAUSE

	return 1 - smoothstep(cycle_t / NAME_MARQUEE_RETURN_DURATION)
end

local function text_fits_width(ui_renderer, text, style, max_width)
	local width = TextUtilities.text_width(ui_renderer, text, style, nil, true) or 0

	return width <= max_width
end

local function rightmost_visible_start_index(ui_renderer, text, style, max_width)
	local text_length = Utf8.string_length(text)
	local start_index = text_length

	while start_index > 1 do
		local segment = Utf8.sub_string(text, start_index - 1)

		if not text_fits_width(ui_renderer, segment, style, max_width) then
			break
		end

		start_index = start_index - 1
	end

	return start_index
end

local function visible_name_segment(ui_renderer, text, style, max_width, start_index)
	local text_length = Utf8.string_length(text)
	local low = start_index
	local high = text_length
	local best_end_index = start_index

	while low <= high do
		local middle = math.floor((low + high) * 0.5)
		local segment = Utf8.sub_string(text, start_index, middle)

		if text_fits_width(ui_renderer, segment, style, max_width) then
			best_end_index = middle
			low = middle + 1
		else
			high = middle - 1
		end
	end

	return Utf8.sub_string(text, start_index, best_end_index)
end

local function player_status_icon_key(status)
	if status == "down" then
		return "knocked_down"
	end

	if status == "disabled" then
		return "grabbed"
	end

	if status ~= "alive" then
		return status
	end

	return nil
end

local function player_status_icon(status)
	local icon_key = player_status_icon_key(status)
	local icons = UIHudSettings.player_status_icons

	return icon_key and icons and icons[icon_key] or nil, icon_key
end

local function player_status_icon_color(icon_key)
	local colors = UIHudSettings.player_status_colors

	return icon_key and colors and colors[icon_key] or COLOR_TEXT_DEFAULT
end

local function pocketable_small_icon_color(inventory_icons)
	local template_id = inventory_icons and inventory_icons.pocketable_small_template_id
	local color = template_id and COLOR_STIMM_BY_TEMPLATE[template_id]

	return color or COLOR_TEXT_DEFAULT
end

local function filtered_pocketable_icon(inventory_icons)
	local template_id = inventory_icons and inventory_icons.pocketable_template_id

	if template_id == MEDICAL_CRATE_TEMPLATE_ID and not boolean_setting("squadhud_show_medical_crate", true) then
		return nil
	elseif template_id == AMMO_CRATE_TEMPLATE_ID and not boolean_setting("squadhud_show_ammo_crate", true) then
		return nil
	end

	return inventory_icons and inventory_icons.pocketable_icon or nil
end

local function inventory_value_visible(mode_key, revive_state)
	if revive_state and revive_state.in_progress then
		return true
	elseif mode_key == "toughness" then
		return boolean_setting("squadhud_show_toughness_value", true)
	end

	return boolean_setting("squadhud_show_health_value", true)
end

local function hide_vitals_for_status(status)
	return status == "dead" or status == "hogtied"
end

local function expanded_view_visible()
	return mod._squadhud_expanded_view == true
end

local function expanded_view_mode()
	local value = mod:get("squadhud_expanded_view_mode")

	if value == "short" then
		return "short"
	end

	return "full"
end

local function expanded_view_revealed()
	return expanded_view_visible()
end

local function update_expanded_view_block_state(hud, player_key, target_visible, t)
	if not player_key or not hud._expanded_view_block_state_by_player then
		return target_visible and 1 or 0
	end

	local now = type(t) == "number" and t or 0
	local state = hud._expanded_view_block_state_by_player[player_key]

	if not state then
		state = {
			current_fraction = target_visible and 1 or 0,
			target_visible = target_visible,
		}
		hud._expanded_view_block_state_by_player[player_key] = state
	end

	if state.target_visible ~= target_visible then
		state.from_fraction = state.current_fraction or (state.target_visible and 1 or 0)
		state.to_fraction = target_visible and 1 or 0
		state.transition_start_t = now
		state.target_visible = target_visible
	end

	local fraction = state.target_visible and 1 or 0

	if state.transition_start_t then
		local progress = math.clamp((now - state.transition_start_t) / EXPANDED_VIEW_BLOCK_TRANSITION_DURATION, 0, 1)
		local eased_progress = smoothstep(progress)

		fraction = (state.from_fraction or 0) + ((state.to_fraction or 0) - (state.from_fraction or 0)) * eased_progress

		if progress >= 1 then
			state.transition_start_t = nil
			state.from_fraction = nil
			state.to_fraction = nil
			fraction = state.target_visible and 1 or 0
		end
	end

	state.current_fraction = fraction

	return fraction, state.target_visible
end

local function update_expanded_inventory_value_state(hud, player_key, target_visible, t)
	if not player_key or not hud._expanded_inventory_value_state_by_player then
		return target_visible and 1 or 0
	end

	local now = type(t) == "number" and t or 0
	local state = hud._expanded_inventory_value_state_by_player[player_key]

	if not state then
		state = {
			current_fraction = target_visible and 1 or 0,
			target_visible = target_visible,
		}
		hud._expanded_inventory_value_state_by_player[player_key] = state
	end

	if state.target_visible ~= target_visible then
		state.from_fraction = state.current_fraction or (state.target_visible and 1 or 0)
		state.to_fraction = target_visible and 1 or 0
		state.transition_start_t = now
		state.target_visible = target_visible
	end

	local fraction = state.target_visible and 1 or 0

	if state.transition_start_t then
		local progress = math.clamp((now - state.transition_start_t) / EXPANDED_VIEW_BLOCK_TRANSITION_DURATION, 0, 1)
		local eased_progress = smoothstep(progress)

		fraction = (state.from_fraction or 0) + ((state.to_fraction or 0) - (state.from_fraction or 0)) * eased_progress

		if progress >= 1 then
			state.transition_start_t = nil
			state.from_fraction = nil
			state.to_fraction = nil
			fraction = state.target_visible and 1 or 0
		end
	end

	state.current_fraction = fraction

	return fraction, state.target_visible
end

local function expanded_view_item_fraction(fraction, item_index)
	local delay = EXPANDED_VIEW_BLOCK_STAGGER * math.max(0, item_index - 1)
	local duration = math.max(0.01, 1 - EXPANDED_VIEW_BLOCK_STAGGER * math.max(0, EXPANDED_VIEW_BLOCK_ITEM_COUNT - 1))

	return math.clamp((fraction - delay) / duration, 0, 1)
end

local function apply_alpha_fraction(color, fraction)
	if color then
		color[1] = math.floor((color[1] or 255) * math.clamp(fraction or 0, 0, 1) + 0.5)
	end
end

local function apply_offset_fraction(offset, fraction)
	if offset then
		offset[1] = offset[1] - EXPANDED_VIEW_BLOCK_SLIDE_OFFSET * (1 - math.clamp(fraction or 0, 0, 1))
	end
end

local function apply_expanded_view_icon_fraction(content, style, content_id, style_id, fraction, target_visible)
	if not target_visible and fraction <= 0 then
		content[content_id] = nil
	end

	if style[style_id] then
		apply_alpha_fraction(style[style_id].color, fraction)
		apply_offset_fraction(style[style_id].offset, fraction)
	end
end

local function apply_expanded_view_text_fraction(content, style, content_id, style_id, fraction, target_visible)
	if not target_visible and fraction <= 0 then
		content[content_id] = ""
	end

	if style[style_id] then
		apply_alpha_fraction(style[style_id].text_color, fraction)
		apply_offset_fraction(style[style_id].offset, fraction)
	end
end

local function apply_expanded_view_block_animation(content, style, fraction, target_visible)
	apply_expanded_view_icon_fraction(content, style, "grenade_icon", "grenade_icon", expanded_view_item_fraction(fraction, 1), target_visible)
	apply_expanded_view_text_fraction(content, style, "grenade_value_text", "grenade_value_text", expanded_view_item_fraction(fraction, 1), target_visible)
	apply_expanded_view_icon_fraction(content, style, "ammo_icon", "ammo_icon", expanded_view_item_fraction(fraction, 2), target_visible)
	apply_expanded_view_text_fraction(content, style, "ammo_percent_text", "ammo_percent_text", expanded_view_item_fraction(fraction, 2), target_visible)
	apply_expanded_view_icon_fraction(content, style, "pocketable_icon", "pocketable_icon", expanded_view_item_fraction(fraction, 3), target_visible)
	apply_expanded_view_icon_fraction(content, style, "pocketable_small_icon", "pocketable_small_icon", expanded_view_item_fraction(fraction, 4), target_visible)
	apply_expanded_view_text_fraction(content, style, "salvage_text", "salvage_text", expanded_view_item_fraction(fraction, 5), target_visible)
	apply_expanded_view_text_fraction(content, style, "inventory_value_text", "inventory_value_text", expanded_view_item_fraction(fraction, 6), target_visible)
	apply_expanded_view_text_fraction(content, style, "inventory_value_out_text", "inventory_value_out_text", expanded_view_item_fraction(fraction, 6), target_visible)
	apply_expanded_view_text_fraction(content, style, "expanded_health_value_text", "expanded_health_value_text", expanded_view_item_fraction(fraction, 6), target_visible)
	apply_expanded_view_text_fraction(content, style, "expanded_toughness_value_text", "expanded_toughness_value_text", expanded_view_item_fraction(fraction, 6), target_visible)
end

local function player_display_name(player, expanded_view)
	local account_name = expanded_view and PlayerDataRuntime.player_account_name(player) or nil

	return account_name or PlayerDataRuntime.player_name(player)
end

local function expanded_view_level_text(player, expanded_view)
	if not expanded_view or not boolean_setting("squadhud_show_teammate_level", true) then
		return ""
	end

	local total_level = PlayerDataRuntime.player_total_level(player)

	if not total_level then
		return ""
	end

	return tostring(total_level)
end

local function apply_ability_state(style, ability_state)
	local icon_style = style.ability_icon
	local material_values = icon_style and icon_style.material_values

	if material_values then
		material_values.talent_icon = ability_state and ability_state.icon or nil
	end

	if ability_state and ability_state.state == "cooldown" then
		apply_color(style.ability_icon.color, COLOR_ABILITY_COOLDOWN_ICON)
		apply_color(style.ability_frame.color, COLOR_ABILITY_COOLDOWN_FRAME)
		apply_color(style.ability_glow.color, COLOR_ABILITY_COOLDOWN_GLOW)
	elseif ability_state and ability_state.state == "active" then
		apply_color(style.ability_icon.color, COLOR_ABILITY_ICON)
		apply_color(style.ability_frame.color, COLOR_ABILITY_FRAME)
		apply_color(style.ability_glow.color, COLOR_ABILITY_GLOW)
	else
		apply_color(style.ability_icon.color, COLOR_ABILITY_ICON)
		apply_color(style.ability_frame.color, COLOR_ABILITY_FRAME)
		apply_color(style.ability_glow.color, COLOR_ABILITY_READY_GLOW)
	end
end

local function ammo_color_from_status(status, uses_ammo)
	if uses_ammo == false then
		return COLOR_AMMO_NOT_IN_USE
	elseif status and status <= 0 then
		return COLOR_AMMO_HIGH
	elseif status and status <= 1 then
		return COLOR_AMMO_MEDIUM
	elseif status and status <= 2 then
		return COLOR_AMMO_LOW
	else
		return COLOR_AMMO_FULL
	end
end

local function player_name_color(base_name_color, operational_status, is_showing_status)
	if not is_showing_status then
		return base_name_color
	end

	if operational_status and operational_status.id == "reviving" then
		return COLOR_REVIVE
	elseif operational_status and (operational_status.id == "rescue_available" or operational_status.id == "rescuing") then
		return COLOR_RESCUE_AVAILABLE
	end

	return COLOR_HEALTH_CRITICAL
end

local function player_name_layout(show_class_icon, show_teammate_distance)
	local left_x = show_class_icon and NAME_X or NAME_LEFT_WITHOUT_CLASS_ICON
	local right_x = show_teammate_distance and NAME_RIGHT_WITH_RELATION_STATUS or NAME_RIGHT_X

	return left_x, math.max(0, right_x - left_x)
end

local function set_panel_visible(widget, visible)
	widget.content.visible = visible
	widget.dirty = true
end

local function apply_empty_panel(widget)
	set_panel_visible(widget, false)
end

local function apply_layout_settings(self, widgets_by_name)
	local custom_hud_enabled = boolean_setting("integration_custom_hud", false)
	local custom_hud_has_root_node = custom_hud_enabled and custom_hud_has_squadhud_root_node()
	local position_x = numeric_setting("position_x", DEFAULT_POSITION_X)
	local position_y = numeric_setting("position_y", DEFAULT_POSITION_Y)
	local position_z = 1
	local opacity = math.clamp(numeric_setting("opacity", DEFAULT_OPACITY), 0.1, 1)
	local hud_scale = math.clamp(numeric_setting("hud_layout_scale", DEFAULT_HUD_LAYOUT_SCALE), 0.5, 2)

	if not custom_hud_has_root_node and (self._squadhud_position_x ~= position_x or self._squadhud_position_y ~= position_y or self._squadhud_position_z ~= position_z) then
		self:set_scenegraph_position("squadhud_root", position_x, position_y, position_z)
		self._squadhud_position_x = position_x
		self._squadhud_position_y = position_y
		self._squadhud_position_z = position_z
	end

	if not self._squadhud_panel_y_by_index then
		self._squadhud_panel_y_by_index = {}
	end

	for i = 1, MAX_PLAYERS do
		local widget = widgets_by_name["panel_" .. i]

		if widget then
			widget.alpha_multiplier = opacity
			widget.scale = hud_scale
		end

		local panel_y = math.floor((i - 1) * (DefinitionSettings.panel_height + DefinitionSettings.panel_gap) * hud_scale + 0.5)
		local panel_scenegraph_id = "squadhud_panel_" .. i

		if self._squadhud_panel_y_by_index[i] ~= panel_y then
			self:set_scenegraph_position(panel_scenegraph_id, 0, panel_y, 1)
			self._squadhud_panel_y_by_index[i] = panel_y
		end
	end
end

ActiveBar.layout = function(mode)
	if mode == "toughness" then
		return HEALTH_BAR_Y, BAR_INACTIVE_HEIGHT, HEALTH_BAR_Y + BAR_INACTIVE_HEIGHT + BAR_GAP, BAR_ACTIVE_HEIGHT
	end

	return HEALTH_BAR_Y, BAR_ACTIVE_HEIGHT, HEALTH_BAR_Y + BAR_ACTIVE_HEIGHT + BAR_GAP, BAR_INACTIVE_HEIGHT
end

local function apply_health_segments(widget, health_fraction, health_max_fraction, max_wounds, is_down, health_y, health_height)
	local style = widget.style
	local segment_count = math.max(1, math.min(10, max_wounds))
	local segment_width = (BAR_WIDTH - (segment_count - 1) * HEALTH_SEGMENT_GAP) / segment_count
	local step_fraction = 1 / segment_count

	for i = 1, 10 do
		local health_style = style["health_fill_" .. i]
		local corruption_style = style["corruption_fill_" .. i]

		if i <= segment_count then
			local start_fraction = (i - 1) * step_fraction
			local end_fraction = i * step_fraction
			local segment_health = math.clamp((health_fraction - start_fraction) / step_fraction, 0, 1)
			local corruption_start = (segment_count - i) * step_fraction
			local segment_corruption = math.clamp((1 - health_max_fraction - corruption_start) / step_fraction, 0, 1)
			local x = BAR_LEFT + (i - 1) * (segment_width + HEALTH_SEGMENT_GAP)

			health_style.offset[1] = x
			health_style.offset[2] = health_y
			health_style.size[1] = segment_health * segment_width
			health_style.size[2] = health_height
			corruption_style.offset[1] = x + segment_width - segment_corruption * segment_width
			corruption_style.offset[2] = health_y
			corruption_style.size[1] = segment_corruption * segment_width
			corruption_style.size[2] = health_height

			apply_color(health_style.color, is_down and COLOR_HEALTH_CRITICAL or COLOR_HEALTH)
		else
			health_style.size[1] = 0
			corruption_style.size[1] = 0
		end
	end
end

local function clear_health_segments(widget)
	local style = widget.style

	for i = 1, 10 do
		local health_style = style["health_fill_" .. i]
		local corruption_style = style["corruption_fill_" .. i]

		if health_style then
			health_style.size[1] = 0
		end

		if corruption_style then
			corruption_style.size[1] = 0
		end
	end
end

local function revive_progress_for_player(self, player_key, revive_state, t)
	if not revive_state or not revive_state.in_progress then
		if self._revive_progress_by_player then
			self._revive_progress_by_player[player_key] = nil
		end

		return 0
	end

	if revive_state.exact_progress then
		if self._revive_progress_by_player then
			self._revive_progress_by_player[player_key] = nil
		end

		return math.clamp(revive_state.progress or 0, 0, 1)
	end

	local now = type(t) == "number" and t or 0
	local duration = revive_state.duration and revive_state.duration > 0 and revive_state.duration or DEFAULT_REVIVE_DURATION
	local state_by_player = self._revive_progress_by_player

	if not state_by_player then
		return 0
	end

	local state = state_by_player[player_key]

	if not state then
		state = {
			start_t = now,
		}
		state_by_player[player_key] = state
	end

	return math.clamp((now - state.start_t) / duration, 0, 1)
end

local function apply_name_marquee(self, widget, player_key, display_name, ui_renderer, t, name_width)
	local content = widget.content
	local name_style = widget.style.player_name
	local max_width = name_width or NAME_WIDTH

	if player_key then
		local last_by_player = self._last_applied_player_name_by_player

		if last_by_player[player_key] ~= display_name then
			last_by_player[player_key] = display_name
			widget.dirty = true
		end
	end

	content.player_name = display_name

	if not player_key or not ui_renderer or display_name == "" then
		if player_key then
			self._name_marquee_by_player[player_key] = nil
		end

		return
	end

	if text_fits_width(ui_renderer, display_name, name_style, max_width) then
		self._name_marquee_by_player[player_key] = nil

		return
	end

	local now = type(t) == "number" and t or 0
	local state = self._name_marquee_by_player[player_key]

	if not state or state.text ~= display_name or state.width ~= max_width then
		state = {
			rightmost_start_index = rightmost_visible_start_index(ui_renderer, display_name, name_style, max_width),
			start_t = now,
			text = display_name,
			width = max_width,
		}
		self._name_marquee_by_player[player_key] = state
	end

	local fraction = name_marquee_fraction(math.max(0, now - state.start_t))
	local start_index = 1 + math.floor((state.rightmost_start_index - 1) * fraction + 0.5)

	content.player_name = visible_name_segment(ui_renderer, display_name, name_style, max_width, start_index)
	widget.dirty = true
end

InventoryValue.toughness_content = function(toughness_values, has_overshield)
	local bonus = toughness_values and toughness_values.bonus or 0
	local normal = toughness_values and toughness_values.normal or 0
	local current = toughness_values and toughness_values.current or 0

	if has_overshield and InventoryValue.rounded(bonus) > 0 then
		local plain_text = InventoryValue.text(normal) .. " + " .. InventoryValue.text(bonus)

		return InventoryValue.colored_text(InventoryValue.text(normal), COLOR_TOUGHNESS) .. " + " .. InventoryValue.colored_text(InventoryValue.text(bonus), COLOR_TOUGHNESS_OVERSHIELD), plain_text
	end

	local text = InventoryValue.text(current)

	return InventoryValue.colored_text(text, has_overshield and COLOR_TOUGHNESS_OVERSHIELD or COLOR_TOUGHNESS), text
end

InventoryValue.health_content = function(extensions, is_down)
	local text = InventoryValue.text(PlayerDataRuntime.health_value(extensions))

	return text, is_down and COLOR_HEALTH_CRITICAL or COLOR_HEALTH, text
end

InventoryValue.active_content = function(active_mode, extensions, revive_state, revive_progress, has_overshield, is_down)
	if revive_state and revive_state.in_progress then
		local text = string.format("%d%%", math.floor((revive_progress or 0) * 100 + 0.5))

		return text, COLOR_REVIVE, text, "revive"
	end

	if active_mode == "toughness" then
		local text, shadow_text = InventoryValue.toughness_content(PlayerDataRuntime.toughness_values(extensions), has_overshield)

		return text, COLOR_TOUGHNESS, shadow_text, "toughness"
	end

	local text = InventoryValue.text(PlayerDataRuntime.health_value(extensions))

	return text, is_down and COLOR_HEALTH_CRITICAL or COLOR_HEALTH, text, "health"
end

InventoryValue.clear_expanded = function(content, style)
	content.expanded_health_value_text = ""
	content.expanded_toughness_value_text = ""

	if style.expanded_health_value_text then
		style.expanded_health_value_text.offset[1] = INVENTORY_VALUE.x
		style.expanded_health_value_text.text_color[1] = 0
	end

	if style.expanded_toughness_value_text then
		style.expanded_toughness_value_text.offset[1] = INVENTORY_VALUE.x
		style.expanded_toughness_value_text.text_color[1] = 0
	end
end

InventoryValue.apply_expanded = function(content, style, ui_renderer, extensions, has_overshield, is_down, active_mode, fraction)
	if active_mode ~= "health" and active_mode ~= "toughness" then
		InventoryValue.clear_expanded(content, style)

		return
	end

	local health_enabled = boolean_setting("squadhud_show_health_value", true)
	local toughness_enabled = boolean_setting("squadhud_show_toughness_value", true)

	if not health_enabled or not toughness_enabled then
		InventoryValue.clear_expanded(content, style)

		return
	end

	local progress = smoothstep(fraction or 0)
	local base_x = INVENTORY_VALUE.x
	local slide_offset = INVENTORY_VALUE.slide_offset
	local health_text, health_color, health_plain_text = InventoryValue.health_content(extensions, is_down)
	local toughness_text, toughness_plain_text = InventoryValue.toughness_content(PlayerDataRuntime.toughness_values(extensions), has_overshield)
	local health_width = InventoryValue.width(ui_renderer, health_plain_text, style.inventory_value_text)
	local toughness_x = base_x + health_width + (INVENTORY_VALUE.gap or INVENTORY_ICON_GAP)

	if active_mode == "health" then
		content.expanded_health_value_text = ""
		content.expanded_toughness_value_text = progress > 0 and toughness_text or ""
		style.inventory_value_text.offset[1] = base_x
		style.expanded_health_value_text.text_color[1] = 0
		style.expanded_toughness_value_text.offset[1] = toughness_x - slide_offset * (1 - progress)
		apply_color(style.expanded_toughness_value_text.text_color, COLOR_TEXT_DEFAULT)
		style.expanded_toughness_value_text.text_color[1] = math.floor((COLOR_TEXT_DEFAULT[1] or 255) * progress + 0.5)
	else
		content.expanded_health_value_text = progress > 0 and health_text or ""
		content.expanded_toughness_value_text = ""
		style.inventory_value_text.offset[1] = base_x + (toughness_x - base_x) * progress
		style.expanded_toughness_value_text.text_color[1] = 0
		style.expanded_health_value_text.offset[1] = base_x - slide_offset * (1 - progress)
		apply_color(style.expanded_health_value_text.text_color, health_color)
		style.expanded_health_value_text.text_color[1] = math.floor((health_color[1] or 255) * progress + 0.5)
	end
end

InventoryValue.width = function(ui_renderer, text, style)
	if not ui_renderer or not style or text == nil or text == "" then
		return 0
	end

	local width = TextUtilities.text_width(ui_renderer, text, style, nil, true) or 0

	return math.min(INVENTORY_VALUE.text_width, math.ceil(width) + 2)
end

InventoryValue.apply_transition = function(hud, player_key, content, style, text, color, plain_text, mode_key, t)
	local base_x = INVENTORY_VALUE.x
	local slide_offset = INVENTORY_VALUE.slide_offset
	local duration = INVENTORY_VALUE.slide_duration

	style.inventory_value_text.size[1] = INVENTORY_VALUE.text_width
	style.inventory_value_out_text.size[1] = INVENTORY_VALUE.text_width

	if not player_key or not hud._inventory_value_state_by_player then
		content.inventory_value_text = text
		content.inventory_value_out_text = ""
		style.inventory_value_text.offset[1] = base_x
		style.inventory_value_out_text.offset[1] = base_x + slide_offset
		apply_color(style.inventory_value_text.text_color, color)
		apply_color(style.inventory_value_out_text.text_color, color)

		return plain_text
	end

	local now = type(t) == "number" and t or 0
	local state = hud._inventory_value_state_by_player[player_key]

	if not state then
		state = {
			color = color,
			mode_key = mode_key,
			plain_text = plain_text,
			text = text,
		}
		hud._inventory_value_state_by_player[player_key] = state
	end

	if state.mode_key ~= mode_key then
		state.out_color = state.color or color
		state.out_text = state.text or ""
		state.start_t = now
		state.mode_key = mode_key
		state.text = text
		state.color = color
		state.plain_text = plain_text
	else
		state.text = text
		state.color = color
		state.plain_text = plain_text
	end

	local progress = state.start_t and math.clamp((now - state.start_t) / duration, 0, 1) or 1
	local eased_progress = smoothstep(progress)
	local incoming_x = base_x + slide_offset * (1 - eased_progress)
	local outgoing_x = base_x + slide_offset * eased_progress

	content.inventory_value_text = state.text
	content.inventory_value_out_text = progress < 1 and state.out_text or ""
	style.inventory_value_text.offset[1] = incoming_x
	style.inventory_value_out_text.offset[1] = outgoing_x
	apply_color(style.inventory_value_text.text_color, state.color or color)
	apply_color(style.inventory_value_out_text.text_color, state.out_color or color)

	if progress >= 1 then
		state.start_t = nil
		state.out_text = nil
		state.out_color = nil
		style.inventory_value_text.offset[1] = base_x
		style.inventory_value_out_text.offset[1] = base_x + slide_offset
	end

	return state.plain_text or plain_text
end

InventoryValue.clear = function(hud, player_key, content, style)
	content.inventory_value_text = ""
	content.inventory_value_out_text = ""
	InventoryValue.clear_expanded(content, style)
	style.inventory_value_text.offset[1] = INVENTORY_VALUE.x
	style.inventory_value_out_text.offset[1] = INVENTORY_VALUE.x + INVENTORY_VALUE.slide_offset

	if player_key and hud._inventory_value_state_by_player then
		hud._inventory_value_state_by_player[player_key] = nil
	end
end

InventoryValue.apply_layout = function(style, visible_inventory_icons, ui_renderer, plain_text, grenade_value_layout, ammo_percent_layout)
	style.inventory_value_text.size[1] = INVENTORY_VALUE.text_width
	style.inventory_value_out_text.size[1] = INVENTORY_VALUE.text_width
	style.expanded_health_value_text.size[1] = INVENTORY_VALUE.text_width
	style.expanded_toughness_value_text.size[1] = INVENTORY_VALUE.text_width
	style.salvage_text.size[1] = DefinitionSettings.salvage_text_width

	local x = DefinitionSettings.grenade_icon_x

	if visible_inventory_icons and visible_inventory_icons.grenade_icon then
		local grenade_icon_x = x
		local grenade_value_fraction = grenade_value_layout and grenade_value_layout.fraction or 0
		local grenade_value_width = grenade_value_layout and grenade_value_layout.width or 0

		style.grenade_icon.offset[1] = x
		x = x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP

		style.grenade_value_text.offset[1] = grenade_icon_x + (x - grenade_icon_x) * grenade_value_fraction
		style.grenade_value_text.size[1] = GRENADE_VALUE.text_width
		x = x + (grenade_value_width + INVENTORY_ICON_GAP) * grenade_value_fraction
	else
		style.grenade_value_text.offset[1] = x
		style.grenade_value_text.size[1] = GRENADE_VALUE.text_width
	end

	if visible_inventory_icons and visible_inventory_icons.ammo_icon then
		local ammo_icon_x = x
		local ammo_percent_fraction = ammo_percent_layout and ammo_percent_layout.fraction or 0
		local ammo_percent_width = ammo_percent_layout and ammo_percent_layout.width or 0

		style.ammo_icon.offset[1] = x
		x = x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP

		style.ammo_percent_text.offset[1] = ammo_icon_x + (x - ammo_icon_x) * ammo_percent_fraction
		style.ammo_percent_text.size[1] = AMMO_PERCENT.text_width
		x = x + (ammo_percent_width + INVENTORY_ICON_GAP) * ammo_percent_fraction
	else
		style.ammo_percent_text.offset[1] = x
		style.ammo_percent_text.size[1] = AMMO_PERCENT.text_width
	end

	if visible_inventory_icons and visible_inventory_icons.pocketable_icon then
		style.pocketable_icon.offset[1] = x
		x = x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
	end

	if visible_inventory_icons and visible_inventory_icons.pocketable_small_icon then
		style.pocketable_small_icon.offset[1] = x
		x = x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
	end

	if visible_inventory_icons and visible_inventory_icons.salvage_text ~= "" then
		style.salvage_text.offset[1] = x
	end
end

local function apply_player_panel(self, widget, local_player, player, extensions, t, ui_renderer)
	local content = widget.content
	local style = widget.style
	local status = PlayerDataRuntime.status_from_extensions(extensions)
	local slot_color = PlayerDataRuntime.slot_color(player)
	local health_fraction, health_max_fraction, max_wounds = PlayerDataRuntime.health_data(extensions, status)
	local tough_fraction = PlayerDataRuntime.toughness_fraction(extensions)
	local has_overshield = PlayerDataRuntime.has_overshield(extensions)
	local is_down = status == "down"
	local hide_vitals = hide_vitals_for_status(status)
	local is_bad_status = status ~= "alive" and status ~= "luggable"
	local player_unit = PlayerDataRuntime.player_unit(player)
	local ability_state = AbilityRuntime.combat_ability_state(player_unit)
	local inventory_icons = InventoryRuntime.icons(player, extensions, status)
	local is_local_player = local_player == player
	local is_teammate = not is_local_player
	local expanded_view = expanded_view_visible()
	local mode = expanded_view_mode()
	local revealed = expanded_view_revealed()
	local show_extra_blocks = mode == "full" or revealed
	local base_name = player_display_name(player, expanded_view)

	base_name = PlayerDataRuntime.apply_modder_tools_display_name(base_name, player)

	if mod.squadhud_debug_player_name then
		base_name = mod.squadhud_debug_player_name(base_name, is_local_player)
	end

	local base_name_color = (PlayerDataRuntime.is_bot(player) or status == "dead" or status == "hogtied") and COLOR_PLAYER_NAME_INACTIVE or COLOR_TEXT_DEFAULT
	local player_key = PlayerDataRuntime.player_unique_id(player)
	local revive_state = PlayerDataRuntime.revive_state(extensions)
	local revive_progress = revive_progress_for_player(self, player_key, revive_state, t)
	local toughness_values = PlayerDataRuntime.toughness_values(extensions)
	local active_bar_mode = ActiveBar.mode(self, player_key, health_fraction, tough_fraction, toughness_values.bonus, has_overshield, revive_state, t)
	local health_bar_y, health_bar_height, toughness_bar_y, toughness_bar_height = ActiveBar.layout(active_bar_mode)
	local inventory_value, inventory_value_color, inventory_value_plain, inventory_value_mode = InventoryValue.active_content(active_bar_mode, extensions, revive_state, revive_progress, has_overshield, is_down)
	local rescue_timer_status = PlayerDataRuntime.rescue_timer_status(player, status)
	local operational_status = StatusRuntime.resolve(player, extensions, status, health_fraction, revive_state, rescue_timer_status)
	local display_name, is_showing_status = StatusRuntime.display_name(self._name_status_flash_by_player, player_key, base_name, operational_status, t)
	local display_name_color = player_name_color(base_name_color, operational_status, is_showing_status)
	local expanded_view_block_fraction, expanded_view_block_target_visible = update_expanded_view_block_state(self, player_key, show_extra_blocks, t)
	local expanded_inventory_value_fraction = update_expanded_inventory_value_state(self, player_key, revealed, t)
	local show_inventory_blocks = show_extra_blocks or expanded_view_block_fraction > 0
	local force_changed_values_visible = revealed
	local show_expanded_inventory_value = expanded_inventory_value_fraction > 0
	local class_status_icon, class_status_icon_key = player_status_icon(status)
	local show_class_icon = boolean_setting("squadhud_show_class_icon", true)
	local show_ability_icon = boolean_setting("squadhud_show_ability_icon", true)
	local show_grenade_icon = boolean_setting("squadhud_show_grenade", true)
	local show_ammo_icon = boolean_setting("squadhud_show_ammo", true)
	local show_stimm_icon = boolean_setting("squadhud_show_stimm", true)
	local show_teammate_distance = boolean_setting("squadhud_show_teammate_distance", true)
	local level_text = expanded_view_level_text(player, expanded_view)
	local show_level_status = level_text ~= "" and not is_showing_status
	local distance_status_allowed = not expanded_view and show_teammate_distance and not is_bad_status and not is_showing_status
	local distance_status = distance_status_allowed and PlayerDataRuntime.player_distance_text(local_player, player, extensions) or ""

	if distance_status_allowed and mod.squadhud_debug_relation_status then
		distance_status = mod.squadhud_debug_relation_status(distance_status, is_local_player)
	end

	local show_distance_status = distance_status ~= ""
	local show_relation_status = show_level_status or show_distance_status
	local relation_status = show_level_status and level_text or show_distance_status and distance_status or ""
	local name_x, name_width = player_name_layout(show_class_icon, show_relation_status)

	local in_coherency = is_teammate and PlayerDataRuntime.in_coherency_with_local_player(local_player, extensions)
	local show_coherency_border = in_coherency or show_distance_status
	local status_background_color = operational_status and operational_status.is_critical and COLOR_STATUS_BACKGROUND_CRITICAL or COLOR_STATUS_BACKGROUND_DEFAULT
	local pocketable_icon = show_inventory_blocks and filtered_pocketable_icon(inventory_icons) or nil
	local pocketable_small_icon = show_inventory_blocks and show_stimm_icon and inventory_icons.pocketable_small_icon or nil
	local grenade_icon = show_inventory_blocks and show_grenade_icon and inventory_icons.grenade_icon or nil
	local grenade_icon_color = ammo_color_from_status(inventory_icons.grenade_status, true)
	local ammo_icon = show_inventory_blocks and show_ammo_icon and inventory_icons.ammo_icon or nil
	local ammo_icon_color = ammo_color_from_status(inventory_icons.ammo_status, inventory_icons.uses_ammo)
	local salvage_text = show_inventory_blocks and inventory_icons.salvage_text or ""
	local visible_inventory_icons = {
		grenade_icon = grenade_icon,
		grenade_current = inventory_icons.grenade_current,
		grenade_max = inventory_icons.grenade_max,
		ammo_icon = ammo_icon,
		ammo_count_current = inventory_icons.ammo_count_current,
		ammo_count_max = inventory_icons.ammo_count_max,
		ammo_current = inventory_icons.ammo_current,
		ammo_max = inventory_icons.ammo_max,
		ammo_percent = inventory_icons.ammo_percent,
		pocketable_icon = pocketable_icon,
		pocketable_small_icon = pocketable_small_icon,
		salvage_text = salvage_text,
		uses_ammo = inventory_icons.uses_ammo,
	}

	content.class_icon = show_class_icon and (expanded_view and PlayerDataRuntime.player_account_platform_icon(player) or class_status_icon and "" or PlayerDataRuntime.archetype_icon(player)) or ""
	content.class_status_icon = show_class_icon and not expanded_view and class_status_icon or nil
	content.relation_status = relation_status
	content.ability_icon_visible = show_ability_icon and ability_state ~= nil and not hide_vitals
	content.ability_progress = ability_state and ability_state.progress or 1
	content.grenade_icon = grenade_icon
	content.ammo_icon = ammo_icon
	content.pocketable_icon = pocketable_icon
	content.pocketable_small_icon = pocketable_small_icon
	content.salvage_text = salvage_text

	apply_ability_state(style, ability_state)

	local grenade_value_layout = GrenadeValue.apply(self, player_key, content, style, visible_inventory_icons, grenade_icon_color, ui_renderer, t, force_changed_values_visible)
	local ammo_percent_layout = AmmoPercent.apply(self, player_key, content, style, visible_inventory_icons, ammo_icon_color, ui_renderer, t, force_changed_values_visible)

	InventoryValue.apply_layout(style, visible_inventory_icons, ui_renderer, inventory_value_plain, grenade_value_layout, ammo_percent_layout)

	if not hide_vitals and show_inventory_blocks and inventory_value_visible(inventory_value_mode, revive_state) then
		InventoryValue.apply_transition(self, player_key, content, style, inventory_value, inventory_value_color, inventory_value_plain, inventory_value_mode, t)
	else
		InventoryValue.clear(self, player_key, content, style)
	end

	style.player_name.offset[1] = name_x
	style.player_name.size[1] = name_width
	apply_color(style.player_name.text_color, display_name_color)
	apply_color(style.relation_status.text_color, COLOR_TEXT_DEFAULT)
	apply_color(style.class_icon.text_color, expanded_view and COLOR_TEXT_DEFAULT or slot_color)
	apply_color(style.class_status_icon.color, player_status_icon_color(class_status_icon_key))
	apply_color(style.status_background.color, status_background_color)
	apply_color(style.coherency_border.color, in_coherency and COLOR_COHERENCY_BORDER_IN or COLOR_COHERENCY_BORDER_OUT)
	apply_color(style.toughness_fill.color, revive_state.in_progress and COLOR_TOUGHNESS or has_overshield and COLOR_TOUGHNESS_OVERSHIELD or COLOR_TOUGHNESS)
	apply_color(style.grenade_icon.color, grenade_icon_color)
	apply_color(style.grenade_value_text.text_color, grenade_icon_color)
	style.grenade_value_text.text_color[1] = math.floor((grenade_icon_color[1] or 255) * (grenade_value_layout.fraction or 0) + 0.5)
	apply_color(style.ammo_icon.color, ammo_icon_color)
	apply_color(style.ammo_percent_text.text_color, ammo_icon_color)
	style.ammo_percent_text.text_color[1] = math.floor((ammo_icon_color[1] or 255) * (ammo_percent_layout.fraction or 0) + 0.5)
	apply_color(style.pocketable_icon.color, COLOR_TEXT_DEFAULT)
	apply_color(style.pocketable_small_icon.color, pocketable_small_icon_color(inventory_icons))
	apply_color(style.salvage_text.text_color, COLOR_TEXT_DEFAULT)
	apply_expanded_view_block_animation(content, style, expanded_view_block_fraction, expanded_view_block_target_visible)

	if not hide_vitals and show_expanded_inventory_value then
		InventoryValue.apply_expanded(content, style, ui_renderer, extensions, has_overshield, is_down, inventory_value_mode, expanded_inventory_value_fraction)
	else
		InventoryValue.clear_expanded(content, style)
	end

	set_rect_width(style.coherency_border, show_coherency_border and COHERENCY_BORDER_WIDTH or 0)

	local debug_toughness_hit_indicator_request = mod.squadhud_debug_consume_toughness_hit_indicator_request and mod.squadhud_debug_consume_toughness_hit_indicator_request(is_local_player) or nil

	if hide_vitals then
		clear_toughness_hit_indicator(content, style)
		style.toughness_fill.offset[2] = toughness_bar_y
		style.toughness_fill.size[2] = 0
		set_rect_width(style.toughness_fill, 0)
		style.revive_fill.offset[2] = toughness_bar_y
		style.revive_fill.size[2] = 0
		set_rect_width(style.revive_fill, 0)
		content.toughness_overshield_spent_visible = false

		local spent_style = style.toughness_overshield_spent

		if spent_style then
			spent_style.color[1] = 0
			spent_style.size[1] = 0

			local size_addition = spent_style.size_addition

			if size_addition then
				size_addition[2] = 0
			end
		end

		clear_health_segments(widget)
	else
		ToughnessHitIndicator.apply(self, player_key, content, style, status, tough_fraction, t, debug_toughness_hit_indicator_request)
		style.toughness_fill.offset[2] = toughness_bar_y
		style.toughness_fill.size[2] = toughness_bar_height
		style.revive_fill.offset[2] = toughness_bar_y
		style.revive_fill.size[2] = toughness_bar_height
		set_rect_width(style.toughness_fill, revive_state.in_progress and 0 or BAR_WIDTH * tough_fraction)
		OvershieldSpent.apply(self, player_key, content, style, has_overshield, tough_fraction, toughness_bar_y, toughness_bar_height, revive_state, t)
		set_rect_width(style.revive_fill, BAR_WIDTH * revive_progress)
		apply_health_segments(widget, health_fraction, health_max_fraction, max_wounds, is_down, health_bar_y, health_bar_height)
	end

	apply_name_marquee(self, widget, player_key, display_name, ui_renderer, t, name_width)
	set_panel_visible(widget, true)
end

HudElementSquadHud.init = function(self, parent, draw_layer, start_scale)
	HudElementSquadHud.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})

	self._players = {}
	self._slot_players = {}
	self._active_bar_state_by_player = {}
	self._ammo_percent_state_by_player = {}
	self._expanded_view_block_state_by_player = {}
	self._expanded_inventory_value_state_by_player = {}
	self._grenade_value_state_by_player = {}
	self._inventory_value_state_by_player = {}
	self._overshield_spent_state_by_player = {}
	self._toughness_hit_indicator_state_by_player = {}
	self._name_marquee_by_player = {}
	self._name_status_flash_by_player = {}
	self._last_applied_player_name_by_player = {}
	self._revive_progress_by_player = {}
end

HudElementSquadHud.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementSquadHud.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local widgets_by_name = self._widgets_by_name

	apply_layout_settings(self, widgets_by_name)

	if not setting_enabled() then
		for i = 1, MAX_PLAYERS do
			set_panel_visible(widgets_by_name["panel_" .. i], false)
		end

		return
	end

	local local_player = self._parent and self._parent.player and self._parent:player() or Managers.player and Managers.player:local_player(1)
	local composition_name = PlayerDataRuntime.gameplay_hud_composition_name()
	local display_mode = squad_panel_display_mode()
	local players = PlayerDataRuntime.filtered_squad_slots(composition_name, self._slot_players, self._players, local_player, MAX_PLAYERS, display_mode)

	if mod.squadhud_debug_update then
		mod.squadhud_debug_update()
	end

	for i = 1, MAX_PLAYERS do
		local widget = widgets_by_name["panel_" .. i]
		local player = players[i]

		if player then
			apply_player_panel(self, widget, local_player, player, PlayerDataRuntime.extensions_for_player(self._parent, player), t, ui_renderer)
		else
			apply_empty_panel(widget)
		end
	end
end

return HudElementSquadHud
