local mod = get_mod("SquadHud")

local HudElementBase = require("scripts/ui/hud/elements/hud_element_base")
local PlayerCompositions = require("scripts/utilities/players/player_compositions")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISettings = require("scripts/settings/ui/ui_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local MAX_PLAYERS = 4
local PANEL_WIDTH = 282
local PANEL_HEIGHT = 38
local PANEL_GAP = 6
local COMBAT_ABILITY_TYPE = "combat_ability"
local POCKETABLE_SLOT_NAME = "slot_pocketable"
local POCKETABLE_SMALL_SLOT_NAME = "slot_pocketable_small"
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
local INVENTORY_ICON_SIZE = 16
local INVENTORY_ICON_GAP = 4
local INVENTORY_BLOCK_WIDTH = INVENTORY_ICON_SIZE * 2 + INVENTORY_ICON_GAP
local INVENTORY_ICON_Y = TOUGHNESS_BAR_BOTTOM_Y - INVENTORY_ICON_SIZE
local INVENTORY_SMALL_ICON_X = PANEL_WIDTH - INNER_PADDING - INVENTORY_ICON_SIZE
local INVENTORY_ICON_X = INVENTORY_SMALL_ICON_X - INVENTORY_ICON_GAP - INVENTORY_ICON_SIZE
local BAR_WIDTH = INVENTORY_ICON_X - INVENTORY_ICON_GAP - BAR_LEFT
local ABILITY_ICON_Y = TOUGHNESS_BAR_BOTTOM_Y - ABILITY_ICON_SIZE
local ABILITY_ICON_FRAME_Y = ABILITY_ICON_Y - ABILITY_ICON_FRAME_PADDING
local ABILITY_ICON_FRAME_X = ABILITY_ICON_X - ABILITY_ICON_FRAME_PADDING
local HEALTH_SEGMENT_GAP = 3
local ROOT_HEIGHT = PANEL_HEIGHT * MAX_PLAYERS + PANEL_GAP * (MAX_PLAYERS - 1)
local STATUS_WIDTH = 64
local STATUS_X = PANEL_WIDTH - INNER_PADDING - INVENTORY_BLOCK_WIDTH - INVENTORY_ICON_GAP - STATUS_WIDTH
local NAME_WIDTH = STATUS_X - TEXT_COLUMN_X - INNER_PADDING

local COLOR_FALLBACK_SLOT = {
	180,
	160,
	160,
	160,
}
local COLOR_TEXT_DEFAULT = UIHudSettings.color_tint_main_1
local COLOR_TEXT_MUTED = UIHudSettings.color_tint_main_3
local COLOR_TOUGHNESS = UIHudSettings.color_tint_6
local COLOR_HEALTH = UIHudSettings.color_tint_main_1
local COLOR_HEALTH_CRITICAL = UIHudSettings.color_tint_alert_2
local COLOR_ABILITY_ICON = UIHudSettings.color_tint_main_2
local COLOR_ABILITY_FRAME = UIHudSettings.color_tint_main_2
local COLOR_ABILITY_GLOW = UIHudSettings.color_tint_main_1
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

local function text_pass(style_id, value_id, font_size, offset, size, color, horizontal_alignment)
	local style = text_style(font_size, horizontal_alignment or "left", "center", color)

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
		ability_texture_pass("ability_icon", ABILITY_ICON_MATERIAL, { ABILITY_ICON_X, ABILITY_ICON_Y, 4 }, { ABILITY_ICON_SIZE, ABILITY_ICON_SIZE }, COLOR_ABILITY_ICON, {
			progress = 1,
			talent_icon = nil,
		}),
		ability_texture_pass("ability_frame", ABILITY_ICON_FRAME_MATERIAL, { ABILITY_ICON_FRAME_X, ABILITY_ICON_FRAME_Y, 5 }, { ABILITY_ICON_FRAME_SIZE, ABILITY_ICON_FRAME_SIZE }, COLOR_ABILITY_FRAME),
		ability_texture_pass("ability_glow", ABILITY_ICON_GLOW_MATERIAL, { ABILITY_ICON_FRAME_X, ABILITY_ICON_FRAME_Y, 6 }, { ABILITY_ICON_FRAME_SIZE, ABILITY_ICON_FRAME_SIZE }, COLOR_ABILITY_GLOW),
		text_pass("class_icon", "class_icon", 22, { CLASS_ICON_X, 0, 4 }, { ICON_COLUMN_WIDTH, 22 }, COLOR_TEXT_DEFAULT, "center"),
		text_pass("player_name", "player_name", 16, { TEXT_COLUMN_X, 0, 4 }, { NAME_WIDTH, 22 }, COLOR_TEXT_DEFAULT, "left"),
		text_pass("player_status", "player_status", 15, { STATUS_X, 0, 4 }, { STATUS_WIDTH, 22 }, COLOR_TEXT_MUTED, "right"),
		inventory_texture_pass("pocketable_icon", "pocketable_icon", { INVENTORY_ICON_X, INVENTORY_ICON_Y, 4 }),
		inventory_texture_pass("pocketable_small_icon", "pocketable_small_icon", { INVENTORY_SMALL_ICON_X, INVENTORY_ICON_Y, 4 }),
		rect_pass("toughness_fill", COLOR_TOUGHNESS, { BAR_LEFT, TOUGHNESS_BAR_Y, 4 }, { BAR_WIDTH, BAR_HEIGHT }),
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

local function gameplay_hud_composition_name()
	local game_mode_manager = Managers.state and Managers.state.game_mode
	local hud_settings = game_mode_manager and game_mode_manager.hud_settings and game_mode_manager:hud_settings()

	return hud_settings and hud_settings.player_composition or nil
end

local function player_slot(player)
	if type(player) == "table" and type(player.slot) == "function" then
		local ok, slot = pcall(function()
			return player:slot()
		end)

		if ok and type(slot) == "number" then
			return slot
		end
	end

	return 99
end

local function player_unique_id(player)
	if type(player) == "table" and type(player.unique_id) == "function" then
		local ok, unique_id = pcall(function()
			return player:unique_id()
		end)

		if ok and unique_id ~= nil then
			return tostring(unique_id)
		end
	end

	return tostring(player)
end

local function sorted_squad_players(composition_name, output)
	table.clear(output)

	if type(composition_name) ~= "string" or composition_name == "" then
		return output
	end

	local players = PlayerCompositions.players(composition_name, {})

	for _, player in pairs(players) do
		output[#output + 1] = player
	end

	table.sort(output, function(a, b)
		local slot_a = player_slot(a)
		local slot_b = player_slot(b)

		if slot_a == slot_b then
			return player_unique_id(a) < player_unique_id(b)
		end

		return slot_a < slot_b
	end)

	return output
end

local function player_name(player)
	if type(player) == "table" and type(player.name) == "function" then
		local ok, name = pcall(function()
			return player:name()
		end)

		if ok and type(name) == "string" and name ~= "" then
			return name
		end
	end

	return mod:localize("squadhud_empty_name")
end

local function player_unit(player)
	return type(player) == "table" and player.player_unit or nil
end

local function player_profile(player)
	if type(player) == "table" and type(player.profile) == "function" then
		local ok, profile = pcall(function()
			return player:profile()
		end)

		if ok then
			return profile
		end
	end

	return nil
end

local function archetype_icon(player)
	local profile = player_profile(player)
	local archetype = profile and profile.archetype
	local archetype_name = archetype and archetype.name
	local icons = UISettings.archetype_font_icon
	local icon = archetype_name and icons and icons[archetype_name]

	if type(icon) == "string" and icon ~= "" then
		return icon
	end

	local title = archetype and archetype.archetype_name and Localize(archetype.archetype_name) or ""

	if type(title) == "string" and title ~= "" then
		return string.sub(title, 1, 1)
	end

	return "?"
end

local function combat_ability_icon(player)
	local unit = player_unit(player)

	if not unit or not Unit.alive(unit) then
		return nil
	end

	local ability_extension = ScriptUnit.has_extension(unit, "ability_system")

	if not ability_extension or not ability_extension:ability_is_equipped(COMBAT_ABILITY_TYPE) then
		return nil
	end

	local equipped_abilities = ability_extension:equipped_abilities()
	local ability_settings = equipped_abilities and equipped_abilities[COMBAT_ABILITY_TYPE]
	local icon = ability_settings and ability_settings.hud_icon

	if type(icon) == "string" and icon ~= "" then
		return icon
	end

	return nil
end

local function extensions_for_player(parent, player)
	local unit = player_unit(player)

	if not unit or not Unit.alive(unit) then
		return nil
	end

	if parent and type(parent.get_all_player_extensions) == "function" then
		local ok, extensions = pcall(function()
			return parent:get_all_player_extensions(player, {})
		end)

		if ok and type(extensions) == "table" then
			extensions.health = extensions.health or ScriptUnit.has_extension(unit, "health_system")
			extensions.toughness = extensions.toughness or ScriptUnit.has_extension(unit, "toughness_system")
			extensions.unit_data = extensions.unit_data or ScriptUnit.has_extension(unit, "unit_data_system")
			extensions.visual_loadout = extensions.visual_loadout or ScriptUnit.has_extension(unit, "visual_loadout_system")

			return extensions
		end
	end

	return {
		health = ScriptUnit.has_extension(unit, "health_system"),
		toughness = ScriptUnit.has_extension(unit, "toughness_system"),
		unit_data = ScriptUnit.has_extension(unit, "unit_data_system"),
		visual_loadout = ScriptUnit.has_extension(unit, "visual_loadout_system"),
	}
end

local function status_from_extensions(extensions)
	local unit_data_extension = extensions and extensions.unit_data
	local health_extension = extensions and extensions.health

	if not health_extension or type(health_extension.is_alive) ~= "function" or not health_extension:is_alive() then
		return "dead"
	end

	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return "alive"
	end

	local character_state_component = unit_data_extension:read_component("character_state")
	local disabled_character_state_component = unit_data_extension:read_component("disabled_character_state")

	if character_state_component and PlayerUnitStatus.is_hogtied(character_state_component) then
		return "dead"
	end

	if character_state_component and PlayerUnitStatus.is_knocked_down(character_state_component) then
		return "down"
	end

	if disabled_character_state_component and disabled_character_state_component.is_disabled then
		return "disabled"
	end

	local disabled = character_state_component and PlayerUnitStatus.is_disabled(character_state_component)

	if disabled then
		return "disabled"
	end

	return "alive"
end

local function player_distance_text(local_player, player, status)
	if status == "dead" then
		return mod:localize("squadhud_status_dead")
	elseif status == "down" then
		return mod:localize("squadhud_status_down")
	elseif status == "disabled" then
		return mod:localize("squadhud_status_disabled")
	end

	if local_player == player then
		return mod:localize("squadhud_status_you")
	end

	local local_unit = player_unit(local_player)
	local target_unit = player_unit(player)

	if local_unit and target_unit and Unit.alive(local_unit) and Unit.alive(target_unit) then
		local local_position = Unit.world_position(local_unit, 1)
		local target_position = Unit.world_position(target_unit, 1)
		local distance = Vector3.distance(local_position, target_position)

		return string.format("%dm", math.floor(distance + 0.5))
	end

	return ""
end

local function health_data(extensions, status)
	local health_extension = extensions and extensions.health

	if not health_extension then
		return 0, 0, 1
	end

	local max_health = health_extension:max_health() or 0
	local health_fraction = health_extension:current_health_percent() or 0
	local permanent_damage = health_extension:permanent_damage_taken() or 0
	local health_max_fraction = max_health > 0 and 1 - permanent_damage / max_health or 0
	local max_wounds = status == "down" and 1 or health_extension:max_wounds() or 1

	return math.clamp(health_fraction, 0, 1), math.clamp(health_max_fraction, 0, 1), math.max(1, math.min(10, max_wounds))
end

local function toughness_fraction(extensions)
	local toughness_extension = extensions and extensions.toughness

	if not toughness_extension then
		return 0
	end

	if type(toughness_extension.current_toughness_percent_visual) == "function" then
		return math.clamp(toughness_extension:current_toughness_percent_visual() or 0, 0, 1)
	end

	return math.clamp(toughness_extension:current_toughness_percent() or 0, 0, 1)
end

local function item_hud_icon_from_slot(inventory_component, visual_loadout_extension, slot_name)
	if not inventory_component or not visual_loadout_extension or type(visual_loadout_extension.weapon_template_from_slot) ~= "function" then
		return nil
	end

	local item_name = inventory_component[slot_name]
	local weapon_template = item_name and visual_loadout_extension:weapon_template_from_slot(slot_name)
	local hud_icon = weapon_template and weapon_template.hud_icon_small

	if type(hud_icon) == "string" and hud_icon ~= "" then
		return hud_icon
	end

	return nil
end

local function inventory_icons(extensions, status)
	if status == "dead" then
		return nil, nil
	end

	local unit_data_extension = extensions and extensions.unit_data
	local visual_loadout_extension = extensions and extensions.visual_loadout

	if not unit_data_extension or not visual_loadout_extension or type(unit_data_extension.read_component) ~= "function" then
		return nil, nil
	end

	local inventory_component = unit_data_extension:read_component("inventory")
	local pocketable_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, POCKETABLE_SLOT_NAME)
	local pocketable_small_icon = item_hud_icon_from_slot(inventory_component, visual_loadout_extension, POCKETABLE_SMALL_SLOT_NAME)

	return pocketable_icon, pocketable_small_icon
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

local function set_panel_visible(widget, visible)
	widget.content.visible = visible
	widget.dirty = true
end

local function apply_empty_panel(widget)
	set_panel_visible(widget, false)
end

local function apply_health_segments(widget, health_fraction, health_max_fraction, max_wounds, is_down)
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
			health_style.size[1] = segment_health * segment_width
			corruption_style.offset[1] = x + segment_width - segment_corruption * segment_width
			corruption_style.size[1] = segment_corruption * segment_width

			apply_color(health_style.color, is_down and COLOR_HEALTH_CRITICAL or COLOR_HEALTH)
		else
			health_style.size[1] = 0
			corruption_style.size[1] = 0
		end
	end
end

local function apply_player_panel(widget, local_player, player, extensions)
	local content = widget.content
	local style = widget.style
	local status = status_from_extensions(extensions)
	local slot = player_slot(player)
	local slot_color = UISettings.player_slot_colors and UISettings.player_slot_colors[slot] or COLOR_FALLBACK_SLOT
	local health_fraction, health_max_fraction, max_wounds = health_data(extensions, status)
	local tough_fraction = toughness_fraction(extensions)
	local is_down = status == "down"
	local is_bad_status = status == "dead" or status == "down" or status == "disabled"
	local ability_icon = combat_ability_icon(player)
	local ability_material_values = style.ability_icon and style.ability_icon.material_values
	local pocketable_icon, pocketable_small_icon = inventory_icons(extensions, status)

	content.class_icon = archetype_icon(player)
	content.player_name = player_name(player)
	content.player_status = player_distance_text(local_player, player, status)
	content.ability_icon_visible = ability_icon ~= nil
	content.pocketable_icon = pocketable_icon
	content.pocketable_small_icon = pocketable_small_icon

	if ability_material_values and ability_material_values.talent_icon ~= ability_icon then
		ability_material_values.talent_icon = ability_icon
		widget.dirty = true
	end

	if style.pocketable_small_icon then
		local small_offset = style.pocketable_small_icon.offset
		local default_offset = style.pocketable_small_icon.default_offset

		if not pocketable_icon and pocketable_small_icon then
			small_offset[1] = INVENTORY_ICON_X
			small_offset[2] = INVENTORY_ICON_Y
			small_offset[3] = 4
		elseif default_offset then
			small_offset[1] = default_offset[1]
			small_offset[2] = default_offset[2]
			small_offset[3] = default_offset[3]
		end
	end

	apply_color(style.player_name.text_color, is_bad_status and COLOR_TEXT_MUTED or COLOR_TEXT_DEFAULT)
	apply_color(style.player_status.text_color, is_bad_status and COLOR_HEALTH_CRITICAL or slot_color)
	apply_color(style.class_icon.text_color, slot_color)

	set_rect_width(style.toughness_fill, BAR_WIDTH * tough_fraction)
	apply_health_segments(widget, health_fraction, health_max_fraction, max_wounds, is_down)
	set_panel_visible(widget, true)
end

HudElementSquadHud.init = function(self, parent, draw_layer, start_scale)
	HudElementSquadHud.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})

	self._players = {}
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

	local composition_name = gameplay_hud_composition_name()
	local players = sorted_squad_players(composition_name, self._players)
	local local_player = self._parent and self._parent.player and self._parent:player() or Managers.player and Managers.player:local_player(1)

	for i = 1, MAX_PLAYERS do
		local widget = widgets_by_name["panel_" .. i]
		local player = players[i]

		if player then
			apply_player_panel(widget, local_player, player, extensions_for_player(self._parent, player))
		else
			apply_empty_panel(widget)
		end
	end
end

return HudElementSquadHud
