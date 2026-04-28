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
local INVENTORY_ICON_SIZE = DefinitionSettings.inventory_icon_size
local INVENTORY_ICON_GAP = DefinitionSettings.inventory_icon_gap
local INVENTORY_ICON_X = DefinitionSettings.inventory_icon_x
local INVENTORY_ICON_Y = DefinitionSettings.inventory_icon_y
local INVENTORY_VALUE = DefinitionSettings.inventory_value
local BAR_LEFT = DefinitionSettings.bar_left
local BAR_WIDTH = DefinitionSettings.bar_width
local HEALTH_SEGMENT_GAP = DefinitionSettings.health_segment_gap
local DEFAULT_REVIVE_DURATION = DefinitionSettings.default_revive_duration
local NAME_WIDTH = DefinitionSettings.name_width
local NAME_MARQUEE_START_PAUSE = DefinitionSettings.name_marquee_start_pause
local NAME_MARQUEE_MOVE_DURATION = DefinitionSettings.name_marquee_move_duration
local NAME_MARQUEE_END_PAUSE = DefinitionSettings.name_marquee_end_pause
local NAME_MARQUEE_RETURN_DURATION = DefinitionSettings.name_marquee_return_duration
local NAME_MARQUEE_TOTAL_DURATION = DefinitionSettings.name_marquee_total_duration
local COHERENCY_BORDER_WIDTH = DefinitionSettings.coherency_border_width

local COLOR_TEXT_DEFAULT = DefinitionSettings.color_text_default
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

local function setting_enabled()
	local value = mod:get("squadhud_enabled")

	return value == true or value == nil
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

InventoryValue.colored_text = function(text, color)
	return "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. text .. "{#reset()}"
end

local function smoothstep(progress)
	progress = math.clamp(progress, 0, 1)

	return progress * progress * (3 - 2 * progress)
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

local function set_panel_visible(widget, visible)
	widget.content.visible = visible
	widget.dirty = true
end

local function apply_empty_panel(widget)
	set_panel_visible(widget, false)
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

local function apply_name_marquee(self, widget, player_key, display_name, ui_renderer, t)
	local content = widget.content
	local name_style = widget.style.player_name

	content.player_name = display_name

	if not player_key or not ui_renderer or display_name == "" then
		if player_key then
			self._name_marquee_by_player[player_key] = nil
		end

		return
	end

	if text_fits_width(ui_renderer, display_name, name_style, NAME_WIDTH) then
		self._name_marquee_by_player[player_key] = nil

		return
	end

	local now = type(t) == "number" and t or 0
	local state = self._name_marquee_by_player[player_key]

	if not state or state.text ~= display_name then
		state = {
			rightmost_start_index = rightmost_visible_start_index(ui_renderer, display_name, name_style, NAME_WIDTH),
			start_t = now,
			text = display_name,
		}
		self._name_marquee_by_player[player_key] = state
	end

	local fraction = name_marquee_fraction(math.max(0, now - state.start_t))
	local start_index = 1 + math.floor((state.rightmost_start_index - 1) * fraction + 0.5)

	content.player_name = visible_name_segment(ui_renderer, display_name, name_style, NAME_WIDTH, start_index)
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

InventoryValue.active_content = function(active_mode, extensions, revive_state, revive_progress, has_overshield, is_down)
	if revive_state and revive_state.in_progress then
		local text = string.format("%d%%", math.floor((revive_progress or 0) * 100 + 0.5))

		return text, COLOR_REVIVE, text
	end

	if active_mode == "toughness" then
		local text, shadow_text = InventoryValue.toughness_content(PlayerDataRuntime.toughness_values(extensions), has_overshield)

		return text, COLOR_TOUGHNESS, shadow_text
	end

	local text = InventoryValue.text(PlayerDataRuntime.health_value(extensions))

	return text, is_down and COLOR_HEALTH_CRITICAL or COLOR_HEALTH, text
end

InventoryValue.width = function(ui_renderer, text, style)
	if not ui_renderer or not style or text == nil or text == "" then
		return 0
	end

	local width = TextUtilities.text_width(ui_renderer, text, style, nil, true) or 0

	return math.min(INVENTORY_VALUE.text_width, math.ceil(width) + 2)
end

InventoryValue.apply_layout = function(style, inventory_icons, ui_renderer, plain_text)
	style.inventory_value_text.offset[1] = INVENTORY_VALUE.x
	style.inventory_value_text.size[1] = INVENTORY_VALUE.text_width

	if inventory_icons and not inventory_icons.pocketable_icon and inventory_icons.pocketable_small_icon then
		style.pocketable_small_icon.offset[1] = INVENTORY_ICON_X
	elseif style.pocketable_small_icon.default_offset then
		style.pocketable_small_icon.offset[1] = style.pocketable_small_icon.default_offset[1]
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
	local is_bad_status = status ~= "alive" and status ~= "luggable"
	local player_unit = PlayerDataRuntime.player_unit(player)
	local ability_state = AbilityRuntime.combat_ability_state(player_unit)
	local inventory_icons = InventoryRuntime.icons(player, extensions, status)
	local is_local_player = local_player == player
	local base_name = PlayerDataRuntime.player_name(player)

	if mod.squadhud_debug_player_name then
		base_name = mod.squadhud_debug_player_name(base_name, is_local_player)
	end

	local base_name_color = COLOR_TEXT_DEFAULT
	local player_key = PlayerDataRuntime.player_unique_id(player)
	local revive_state = PlayerDataRuntime.revive_state(extensions)
	local revive_progress = revive_progress_for_player(self, player_key, revive_state, t)
	local toughness_values = PlayerDataRuntime.toughness_values(extensions)
	local active_bar_mode = ActiveBar.mode(self, player_key, health_fraction, tough_fraction, toughness_values.bonus, has_overshield, revive_state, t)
	local health_bar_y, health_bar_height, toughness_bar_y, toughness_bar_height = ActiveBar.layout(active_bar_mode)
	local inventory_value, inventory_value_color, inventory_value_plain = InventoryValue.active_content(active_bar_mode, extensions, revive_state, revive_progress, has_overshield, is_down)
	local rescue_timer_status = PlayerDataRuntime.rescue_timer_status(player, status)
	local operational_status = StatusRuntime.resolve(player, extensions, status, health_fraction, revive_state, rescue_timer_status)
	local display_name, is_showing_status = StatusRuntime.display_name(self._name_status_flash_by_player, player_key, base_name, operational_status, t)
	local display_name_color = player_name_color(base_name_color, operational_status, is_showing_status)
	local relation_status = is_bad_status and "" or PlayerDataRuntime.player_distance_text(local_player, player, extensions)
	local class_status_icon, class_status_icon_key = player_status_icon(status)

	if mod.squadhud_debug_relation_status then
		relation_status = mod.squadhud_debug_relation_status(relation_status, is_local_player)
	end

	local is_teammate = not is_local_player
	local in_coherency = is_teammate and PlayerDataRuntime.in_coherency_with_local_player(local_player, extensions)
	local show_coherency_border = in_coherency or relation_status ~= ""
	local status_background_color = operational_status and operational_status.is_critical and COLOR_STATUS_BACKGROUND_CRITICAL or COLOR_STATUS_BACKGROUND_DEFAULT

	content.class_icon = class_status_icon and "" or PlayerDataRuntime.archetype_icon(player)
	content.class_status_icon = class_status_icon
	content.relation_status = relation_status
	content.ability_icon_visible = ability_state ~= nil
	content.ability_progress = ability_state and ability_state.progress or 1
	content.grenade_icon = inventory_icons.grenade_icon
	content.ammo_icon = inventory_icons.ammo_icon
	content.pocketable_icon = inventory_icons.pocketable_icon
	content.pocketable_small_icon = inventory_icons.pocketable_small_icon
	content.inventory_value_text = inventory_value

	apply_ability_state(style, ability_state)
	InventoryValue.apply_layout(style, inventory_icons, ui_renderer, inventory_value_plain)

	apply_color(style.player_name.text_color, display_name_color)
	apply_color(style.relation_status.text_color, COLOR_TEXT_DEFAULT)
	apply_color(style.class_icon.text_color, slot_color)
	apply_color(style.class_status_icon.color, player_status_icon_color(class_status_icon_key))
	apply_color(style.status_background.color, status_background_color)
	apply_color(style.coherency_border.color, in_coherency and COLOR_COHERENCY_BORDER_IN or COLOR_COHERENCY_BORDER_OUT)
	apply_color(style.toughness_fill.color, revive_state.in_progress and COLOR_TOUGHNESS or has_overshield and COLOR_TOUGHNESS_OVERSHIELD or COLOR_TOUGHNESS)
	apply_color(style.inventory_value_text.text_color, inventory_value_color)
	apply_color(style.grenade_icon.color, ammo_color_from_status(inventory_icons.grenade_status, true))
	apply_color(style.ammo_icon.color, ammo_color_from_status(inventory_icons.ammo_status, inventory_icons.uses_ammo))
	apply_color(style.pocketable_icon.color, COLOR_TEXT_DEFAULT)
	apply_color(style.pocketable_small_icon.color, pocketable_small_icon_color(inventory_icons))

	set_rect_width(style.coherency_border, show_coherency_border and COHERENCY_BORDER_WIDTH or 0)
	style.toughness_fill.offset[2] = toughness_bar_y
	style.toughness_fill.size[2] = toughness_bar_height
	style.revive_fill.offset[2] = toughness_bar_y
	style.revive_fill.size[2] = toughness_bar_height
	set_rect_width(style.toughness_fill, revive_state.in_progress and 0 or BAR_WIDTH * tough_fraction)
	set_rect_width(style.revive_fill, BAR_WIDTH * revive_progress)
	apply_health_segments(widget, health_fraction, health_max_fraction, max_wounds, is_down, health_bar_y, health_bar_height)
	apply_name_marquee(self, widget, player_key, display_name, ui_renderer, t)
	set_panel_visible(widget, true)
end

HudElementSquadHud.init = function(self, parent, draw_layer, start_scale)
	HudElementSquadHud.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})

	self._players = {}
	self._active_bar_state_by_player = {}
	self._name_marquee_by_player = {}
	self._name_status_flash_by_player = {}
	self._revive_progress_by_player = {}
end

HudElementSquadHud.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementSquadHud.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local widgets_by_name = self._widgets_by_name

	if not setting_enabled() then
		for i = 1, MAX_PLAYERS do
			set_panel_visible(widgets_by_name["panel_" .. i], false)
		end

		return
	end

	local local_player = self._parent and self._parent.player and self._parent:player() or Managers.player and Managers.player:local_player(1)
	local composition_name = PlayerDataRuntime.gameplay_hud_composition_name()
	local players = PlayerDataRuntime.sorted_squad_players(composition_name, self._players, local_player)

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
