local mod = get_mod("SquadHud")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local TextUtilities = require("scripts/utilities/ui/text")

local AbilityRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/ability_runtime")
local InventoryRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/inventory_runtime")
local PlayerDataRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/player_data_runtime")
local StatusRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/status_runtime")

local MAX_PLAYERS = 4
local PANEL_HEIGHT = 38
local PANEL_GAP = 6
local ABILITY_ICON_SIZE = 30
local ABILITY_ICON_FRAME_SIZE = 48
local ABILITY_ICON_FRAME_PADDING = math.floor((ABILITY_ICON_FRAME_SIZE - ABILITY_ICON_SIZE) * 0.5)
local ABILITY_ICON_X = 0
local ABILITY_BLOCK_WIDTH = 42
local ABILITY_ICON_MATERIAL = "content/ui/materials/icons/talents/hud/combat_container"
local ABILITY_ICON_FRAME_MATERIAL = "content/ui/materials/icons/talents/hud/combat_frame_inner"
local ABILITY_ICON_GLOW_MATERIAL = "content/ui/materials/effects/hud/combat_talent_glow"
local ICON_COLUMN_WIDTH = 28
local INNER_PADDING = 8
local CLASS_ICON_X = ABILITY_BLOCK_WIDTH + INNER_PADDING
local TEXT_COLUMN_X = CLASS_ICON_X + ICON_COLUMN_WIDTH + 2
local BAR_LEFT = CLASS_ICON_X
local HEALTH_BAR_Y = 24
local TOUGHNESS_BAR_Y = 31
local BAR_HEIGHT = 6
local TOUGHNESS_BAR_BOTTOM_Y = TOUGHNESS_BAR_Y + BAR_HEIGHT
local BAR_ACTIVE_HEIGHT = 8
local BAR_INACTIVE_HEIGHT = 4
local BAR_GAP = 1
local ACTIVE_BAR_VISIBLE_DURATION = 5
local INVENTORY_ICON_SIZE = 16
local INVENTORY_ICON_GAP = 4
local INVENTORY_VALUE_MAX_WIDTH = 110
local PREVIOUS_INVENTORY_BLOCK_WIDTH = INVENTORY_ICON_SIZE * 2 + INVENTORY_ICON_GAP
local INVENTORY_BLOCK_WIDTH = INVENTORY_VALUE_MAX_WIDTH + INVENTORY_ICON_GAP + INVENTORY_ICON_SIZE * 4 + INVENTORY_ICON_GAP * 3
local NAME_EXTRA_WIDTH = 40
local PANEL_WIDTH = 282 + INVENTORY_BLOCK_WIDTH - PREVIOUS_INVENTORY_BLOCK_WIDTH + NAME_EXTRA_WIDTH
local INVENTORY_BLOCK_X = PANEL_WIDTH - INNER_PADDING - INVENTORY_BLOCK_WIDTH
local INVENTORY_ICON_Y = TOUGHNESS_BAR_BOTTOM_Y - INVENTORY_ICON_SIZE
local GRENADE_ICON_X = INVENTORY_BLOCK_X + INVENTORY_VALUE_MAX_WIDTH + INVENTORY_ICON_GAP
local AMMO_ICON_X = GRENADE_ICON_X + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
local INVENTORY_ICON_X = AMMO_ICON_X + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
local INVENTORY_SMALL_ICON_X = INVENTORY_ICON_X + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
local BAR_WIDTH = INVENTORY_BLOCK_X - INVENTORY_ICON_GAP - BAR_LEFT
local INVENTORY_VALUE = {
	font_size = 14,
	height = INVENTORY_ICON_SIZE,
	gap = INVENTORY_ICON_GAP,
	text_width = INVENTORY_VALUE_MAX_WIDTH,
	x = INVENTORY_BLOCK_X,
	y = INVENTORY_ICON_Y,
}

local ABILITY_ICON_Y = TOUGHNESS_BAR_BOTTOM_Y - ABILITY_ICON_SIZE
local ABILITY_ICON_FRAME_Y = ABILITY_ICON_Y - ABILITY_ICON_FRAME_PADDING
local ABILITY_ICON_FRAME_X = ABILITY_ICON_X - ABILITY_ICON_FRAME_PADDING
local HEALTH_SEGMENT_GAP = 3
local DEFAULT_REVIVE_DURATION = 3
local ROOT_HEIGHT = PANEL_HEIGHT * MAX_PLAYERS + PANEL_GAP * (MAX_PLAYERS - 1)
local NAME_X = TEXT_COLUMN_X
local NAME_Y = 0
local NAME_HEIGHT = 22
local NAME_RIGHT_X = INVENTORY_BLOCK_X - INVENTORY_ICON_GAP
local RELATION_STATUS_LEFT_PADDING = 6
local RELATION_STATUS_Y = 0
local RELATION_STATUS_X = NAME_RIGHT_X + RELATION_STATUS_LEFT_PADDING
local RELATION_STATUS_WIDTH = PANEL_WIDTH - RELATION_STATUS_X
local RELATION_STATUS_HEIGHT = 20
local NAME_WIDTH = NAME_RIGHT_X - NAME_X
local STATUS_BACKGROUND_X = CLASS_ICON_X
local STATUS_BACKGROUND_Y = 1
local STATUS_BACKGROUND_WIDTH = NAME_RIGHT_X - STATUS_BACKGROUND_X
local STATUS_BACKGROUND_HEIGHT = 20
local NAME_MARQUEE_START_PAUSE = 0.6
local NAME_MARQUEE_MOVE_DURATION = 1.6
local NAME_MARQUEE_END_PAUSE = 0.9
local NAME_MARQUEE_RETURN_DURATION = 1.35
local NAME_MARQUEE_TOTAL_DURATION = NAME_MARQUEE_START_PAUSE + NAME_MARQUEE_MOVE_DURATION + NAME_MARQUEE_END_PAUSE + NAME_MARQUEE_RETURN_DURATION
local COHERENCY_BORDER_WIDTH = 3
local COHERENCY_BORDER_X = STATUS_BACKGROUND_X + STATUS_BACKGROUND_WIDTH - COHERENCY_BORDER_WIDTH
local COHERENCY_BORDER_Y = STATUS_BACKGROUND_Y
local COHERENCY_BORDER_HEIGHT = STATUS_BACKGROUND_HEIGHT

local COLOR_TEXT_DEFAULT = UIHudSettings.color_tint_main_1
local COLOR_TOUGHNESS = UIHudSettings.color_tint_6
local COLOR_TOUGHNESS_OVERSHIELD = UIHudSettings.color_tint_10
local COLOR_HEALTH = UIHudSettings.color_tint_main_1
local COLOR_HEALTH_CRITICAL = UIHudSettings.color_tint_alert_2
local COLOR_RESCUE_AVAILABLE = UIHudSettings.player_status_colors and UIHudSettings.player_status_colors.hogtied or UIHudSettings.color_tint_main_1
local COLOR_REVIVE = {
	255,
	75,
	220,
	120,
}
local COLOR_ABILITY_ICON = UIHudSettings.color_tint_main_2
local COLOR_ABILITY_FRAME = UIHudSettings.color_tint_main_2
local COLOR_ABILITY_GLOW = UIHudSettings.color_tint_main_1
local COLOR_ABILITY_READY_GLOW = UIHudSettings.color_tint_main_1
local COLOR_ABILITY_COOLDOWN_ICON = UIHudSettings.color_tint_main_3
local COLOR_ABILITY_COOLDOWN_FRAME = UIHudSettings.color_tint_main_3
local COLOR_ABILITY_COOLDOWN_GLOW = {
	0,
	255,
	255,
	255,
}
local COLOR_STATUS_BACKGROUND_DEFAULT = {
	38,
	255,
	255,
	255,
}
local COLOR_STATUS_BACKGROUND_CRITICAL = {
	90,
	255,
	40,
	40,
}
local COLOR_COHERENCY_BORDER_IN = {
	220,
	75,
	220,
	120,
}
local COLOR_COHERENCY_BORDER_OUT = {
	220,
	255,
	40,
	40,
}
local COLOR_AMMO_NOT_IN_USE = UIHudSettings.color_tint_ammo_not_in_use
local COLOR_AMMO_HIGH = UIHudSettings.color_tint_ammo_high
local COLOR_AMMO_MEDIUM = UIHudSettings.color_tint_ammo_medium
local COLOR_AMMO_LOW = UIHudSettings.color_tint_ammo_low
local COLOR_AMMO_FULL = UIHudSettings.color_tint_ammo_full
local COLOR_CORRUPTION = {
	210,
	130,
	70,
	180,
}

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	squadhud_root = {
		horizontal_alignment = "left",
		parent = "screen",
		vertical_alignment = "top",
		size = {
			PANEL_WIDTH,
			ROOT_HEIGHT,
		},
		position = {
			20,
			130,
			1,
		},
	},
}

for i = 1, MAX_PLAYERS do
	scenegraph_definition["squadhud_panel_" .. i] = {
		horizontal_alignment = "left",
		parent = "squadhud_root",
		vertical_alignment = "top",
		size = {
			PANEL_WIDTH,
			PANEL_HEIGHT,
		},
		position = {
			0,
			(i - 1) * (PANEL_HEIGHT + PANEL_GAP),
			1,
		},
	}
end

local function clone_color(color, alpha)
	local c = table.clone(color)

	if type(alpha) == "number" then
		c[1] = alpha
	end

	return c
end

local function text_style(font_size, horizontal_alignment, vertical_alignment, color)
	local style = table.clone(UIFontSettings.hud_body)

	style.font_size = font_size
	style.font_type = "proxima_nova_bold"
	style.drop_shadow = true
	style.text_horizontal_alignment = horizontal_alignment or "left"
	style.text_vertical_alignment = vertical_alignment or "center"
	style.text_color = clone_color(color or COLOR_TEXT_DEFAULT)

	return style
end

local function rect_pass(style_id, color, offset, size)
	return {
		pass_type = "rect",
		style_id = style_id,
		style = {
			color = clone_color(color),
			offset = offset,
			size = size,
		},
		visibility_function = function(content)
			return content.visible == true
		end,
	}
end

local function text_pass(style_id, value_id, font_size, offset, size, color, horizontal_alignment, font_type, drop_shadow)
	local style = text_style(font_size, horizontal_alignment or "left", "center", color)

	if font_type then
		style.font_type = font_type
	end

	if drop_shadow ~= nil then
		style.drop_shadow = drop_shadow
	end

	style.offset = offset
	style.size = size

	return {
		pass_type = "text",
		style_id = style_id,
		value_id = value_id,
		value = "",
		style = style,
		visibility_function = function(content)
			return content.visible == true
		end,
	}
end

local function ability_texture_pass(style_id, material, offset, size, color, material_values)
	return {
		pass_type = "texture",
		value = material,
		style_id = style_id,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			material_values = material_values,
			size = size,
			offset = offset,
			color = clone_color(color),
		},
		change_function = function(content, style)
			if style.material_values then
				style.material_values.progress = content.ability_progress or 1
			end
		end,
		visibility_function = function(content)
			return content.visible == true and content.ability_icon_visible == true
		end,
	}
end

local function inventory_texture_pass(style_id, value_id, offset)
	return {
		pass_type = "texture",
		style_id = style_id,
		value_id = value_id,
		style = {
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = {
				INVENTORY_ICON_SIZE,
				INVENTORY_ICON_SIZE,
			},
			default_offset = {
				offset[1],
				offset[2],
				offset[3],
			},
			offset = offset,
			color = clone_color(COLOR_TEXT_DEFAULT),
		},
		visibility_function = function(content)
			return content.visible == true and content[value_id] ~= nil
		end,
	}
end

local function create_panel_definition(scenegraph_id)
	local passes = {
		rect_pass("status_background", COLOR_STATUS_BACKGROUND_DEFAULT, { STATUS_BACKGROUND_X, STATUS_BACKGROUND_Y, 2 }, { STATUS_BACKGROUND_WIDTH, STATUS_BACKGROUND_HEIGHT }),
		rect_pass("coherency_border", COLOR_COHERENCY_BORDER_IN, { COHERENCY_BORDER_X, COHERENCY_BORDER_Y, 3 }, { 0, COHERENCY_BORDER_HEIGHT }),
		ability_texture_pass("ability_icon", ABILITY_ICON_MATERIAL, { ABILITY_ICON_X, ABILITY_ICON_Y, 4 }, { ABILITY_ICON_SIZE, ABILITY_ICON_SIZE }, COLOR_ABILITY_ICON, {
			progress = 1,
			talent_icon = nil,
		}),
		ability_texture_pass("ability_frame", ABILITY_ICON_FRAME_MATERIAL, { ABILITY_ICON_FRAME_X, ABILITY_ICON_FRAME_Y, 5 }, { ABILITY_ICON_FRAME_SIZE, ABILITY_ICON_FRAME_SIZE }, COLOR_ABILITY_FRAME),
		ability_texture_pass("ability_glow", ABILITY_ICON_GLOW_MATERIAL, { ABILITY_ICON_FRAME_X, ABILITY_ICON_FRAME_Y, 6 }, { ABILITY_ICON_FRAME_SIZE, ABILITY_ICON_FRAME_SIZE }, COLOR_ABILITY_GLOW),
		text_pass("class_icon", "class_icon", 22, { CLASS_ICON_X, 0, 4 }, { ICON_COLUMN_WIDTH, 22 }, COLOR_TEXT_DEFAULT, "center"),
		text_pass("player_name", "player_name", 16, { NAME_X, NAME_Y, 4 }, { NAME_WIDTH, NAME_HEIGHT }, COLOR_TEXT_DEFAULT, "left", "proxima_nova_bold_no_render_flags"),
		text_pass("relation_status", "relation_status", 15, { RELATION_STATUS_X, RELATION_STATUS_Y, 7 }, { RELATION_STATUS_WIDTH, RELATION_STATUS_HEIGHT }, COLOR_TEXT_DEFAULT, "left"),
		inventory_texture_pass("grenade_icon", "grenade_icon", { GRENADE_ICON_X, INVENTORY_ICON_Y, 4 }),
		inventory_texture_pass("ammo_icon", "ammo_icon", { AMMO_ICON_X, INVENTORY_ICON_Y, 4 }),
		inventory_texture_pass("pocketable_icon", "pocketable_icon", { INVENTORY_ICON_X, INVENTORY_ICON_Y, 4 }),
		inventory_texture_pass("pocketable_small_icon", "pocketable_small_icon", { INVENTORY_SMALL_ICON_X, INVENTORY_ICON_Y, 4 }),
		rect_pass("toughness_fill", COLOR_TOUGHNESS, { BAR_LEFT, TOUGHNESS_BAR_Y, 4 }, { BAR_WIDTH, BAR_HEIGHT }),
		rect_pass("revive_fill", COLOR_REVIVE, { BAR_LEFT, TOUGHNESS_BAR_Y, 5 }, { 0, BAR_HEIGHT }),
		text_pass("inventory_value_text", "inventory_value_text", INVENTORY_VALUE.font_size, { INVENTORY_VALUE.x, INVENTORY_VALUE.y, 8 }, { INVENTORY_VALUE.text_width, INVENTORY_VALUE.height }, COLOR_HEALTH, "left", nil, false),
	}

	for i = 1, 10 do
		passes[#passes + 1] = rect_pass("health_fill_" .. i, COLOR_HEALTH, { BAR_LEFT, HEALTH_BAR_Y, 4 }, { 0, BAR_HEIGHT })
		passes[#passes + 1] = rect_pass("corruption_fill_" .. i, COLOR_CORRUPTION, { BAR_LEFT, HEALTH_BAR_Y, 5 }, { 0, BAR_HEIGHT })
	end

	return UIWidget.create_definition(passes, scenegraph_id)
end

local widget_definitions = {}

for i = 1, MAX_PLAYERS do
	widget_definitions["panel_" .. i] = create_panel_definition("squadhud_panel_" .. i)
end

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
		return "toughness", true
	end

	if not player_key then
		return "health", false
	end

	local state_by_player = hud._active_bar_state_by_player

	if not state_by_player then
		return "health", false
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

		return "toughness", true
	end

	if state.initialized then
		local health_changed = health ~= state.health
		local toughness_changed = toughness ~= state.toughness
		local bonus_changed = bonus ~= (state.bonus or 0)

		if health_changed then
			state.mode = "health"
			state.until_t = now + ACTIVE_BAR_VISIBLE_DURATION
		elseif toughness_changed or bonus_changed then
			state.mode = "toughness"
			state.until_t = now + ACTIVE_BAR_VISIBLE_DURATION
		end
	end

	state.initialized = true
	state.health = health
	state.toughness = toughness
	state.bonus = bonus

	if state.mode and state.until_t and now <= state.until_t then
		return state.mode, true
	end

	state.mode = nil
	state.until_t = nil

	return "health", false
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

InventoryValue.active_content = function(active_mode, show_value, extensions, revive_state, revive_progress, has_overshield, is_down)
	if not show_value then
		return "", COLOR_HEALTH, ""
	end

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
	local value_width = InventoryValue.width(ui_renderer, plain_text, style.inventory_value_text)
	local icon_x = INVENTORY_VALUE.x + value_width + (value_width > 0 and INVENTORY_VALUE.gap or 0)
	local grenade_x = icon_x
	local ammo_x = grenade_x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
	local inventory_x = ammo_x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP
	local inventory_small_x = inventory_x + INVENTORY_ICON_SIZE + INVENTORY_ICON_GAP

	style.inventory_value_text.offset[1] = INVENTORY_VALUE.x
	style.inventory_value_text.size[1] = INVENTORY_VALUE.text_width

	style.grenade_icon.offset[1] = grenade_x
	style.ammo_icon.offset[1] = ammo_x
	style.pocketable_icon.offset[1] = inventory_x
	style.pocketable_small_icon.offset[1] = inventory_small_x

	if inventory_icons and not inventory_icons.pocketable_icon and inventory_icons.pocketable_small_icon then
		style.pocketable_small_icon.offset[1] = inventory_x
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
	local is_bad_status = status == "dead" or status == "down" or status == "disabled"
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
	local active_bar_mode, show_inventory_value = ActiveBar.mode(self, player_key, health_fraction, tough_fraction, toughness_values.bonus, has_overshield, revive_state, t)
	local health_bar_y, health_bar_height, toughness_bar_y, toughness_bar_height = ActiveBar.layout(active_bar_mode)
	local inventory_value, inventory_value_color, inventory_value_plain = InventoryValue.active_content(active_bar_mode, show_inventory_value, extensions, revive_state, revive_progress, has_overshield, is_down)
	local rescue_timer_status = PlayerDataRuntime.rescue_timer_status(player, status)
	local operational_status = StatusRuntime.resolve(player, extensions, status, health_fraction, revive_state, rescue_timer_status)
	local display_name, is_showing_status = StatusRuntime.display_name(self._name_status_flash_by_player, player_key, base_name, operational_status, t)
	local display_name_color = player_name_color(base_name_color, operational_status, is_showing_status)
	local relation_status = is_bad_status and "" or PlayerDataRuntime.player_distance_text(local_player, player, extensions)

	if mod.squadhud_debug_relation_status then
		relation_status = mod.squadhud_debug_relation_status(relation_status, is_local_player)
	end

	local is_teammate = not is_local_player
	local in_coherency = is_teammate and PlayerDataRuntime.in_coherency_with_local_player(local_player, extensions)
	local show_coherency_border = in_coherency or relation_status ~= ""
	local status_background_color = operational_status and operational_status.is_critical and COLOR_STATUS_BACKGROUND_CRITICAL or COLOR_STATUS_BACKGROUND_DEFAULT

	content.class_icon = PlayerDataRuntime.archetype_icon(player)
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
	apply_color(style.status_background.color, status_background_color)
	apply_color(style.coherency_border.color, in_coherency and COLOR_COHERENCY_BORDER_IN or COLOR_COHERENCY_BORDER_OUT)
	apply_color(style.toughness_fill.color, revive_state.in_progress and COLOR_TOUGHNESS or has_overshield and COLOR_TOUGHNESS_OVERSHIELD or COLOR_TOUGHNESS)
	apply_color(style.inventory_value_text.text_color, inventory_value_color)
	apply_color(style.grenade_icon.color, ammo_color_from_status(inventory_icons.grenade_status, true))
	apply_color(style.ammo_icon.color, ammo_color_from_status(inventory_icons.ammo_status, inventory_icons.uses_ammo))

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
