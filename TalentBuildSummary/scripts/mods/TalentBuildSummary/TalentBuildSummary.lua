---@diagnostic disable: undefined-global

local mod = get_mod("TalentBuildSummary")

local BuffSettings = require("scripts/settings/buff/buff_settings")
local BuffTemplates = require("scripts/settings/buff/buff_templates")
local CharacterSheet = require("scripts/utilities/character_sheet")
local TalentLayoutParser = require("scripts/ui/views/talent_builder_view/utilities/talent_layout_parser")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local stat_buff_types = BuffSettings.stat_buff_types
local stat_buff_type_base_values = BuffSettings.stat_buff_type_base_values
local stat_buffs_enum = BuffSettings.stat_buffs

local stat_buff_id_to_name = {}

for stat_name, stat_id in pairs(stat_buffs_enum) do
	if type(stat_id) == "number" then
		stat_buff_id_to_name[stat_id] = stat_name
	end
end

local PANEL_WIDGET_NAME = "talent_build_summary_panel"
local PANEL_SIZE = { 430, 640 }
local PANEL_MARGIN_X = 60
local PANEL_TOP_Y = 210

local requested_stat_groups = {
	crit = {
		"critical_strike_chance",
		"melee_critical_strike_chance",
		"ranged_critical_strike_chance",
		"critical_strike_damage",
	},
	damage = {
		"damage",
		"melee_damage",
		"ranged_damage",
		"weakspot_damage",
		"rending_multiplier",
	},
	defense = {
		"toughness",
		"max_health_modifier",
		"toughness_damage_taken_modifier",
		"ranged_toughness_damage_taken_modifier",
		"melee_toughness_damage_taken_modifier",
		"damage_taken_multiplier",
		"damage_taken_modifier",
	},
}

local function mod_enabled()
	return mod:get("enable_mod") ~= false
end

local function panel_enabled()
	return mod_enabled() and mod:get("show_panel") ~= false
end

local function _stat_base_value(stat_name)
	local base_value = stat_buff_type_base_values[stat_name]

	if base_value ~= nil then
		return base_value
	end

	return 0
end

local function _new_stat_table()
	return setmetatable({}, {
		__index = function(t, stat_name)
			local base_value = _stat_base_value(stat_name)

			rawset(t, stat_name, base_value)

			return base_value
		end,
	})
end

local function _apply_stat_value(current, stat_name, value)
	local stat_buff_type = stat_buff_types[stat_name]

	if stat_buff_type == "multiplicative_multiplier" then
		current[stat_name] = current[stat_name] * value
	elseif stat_buff_type == "max_value" then
		local current_value = current[stat_name]

		current[stat_name] = math.max(current_value, value)
	else
		current[stat_name] = current[stat_name] + value
	end
end

local function _resolve_stat_name(stat_key)
	if type(stat_key) == "number" then
		return stat_buff_id_to_name[stat_key]
	end

	if type(stat_key) == "string" then
		return stat_key
	end

	return nil
end

local function _apply_stat_buff_table(current, base_tbl, override_tbl, stacks)
	if not base_tbl and not override_tbl then
		return 0
	end

	local applied = 0

	if base_tbl then
		for stat_key, value in pairs(base_tbl) do
			local stat_name = _resolve_stat_name(stat_key)
			local resolved_value = override_tbl and override_tbl[stat_key] or value

			if stat_name and type(resolved_value) == "number" then
				for _ = 1, stacks do
					_apply_stat_value(current, stat_name, resolved_value)
				end

				applied = applied + 1
			end
		end
	end

	-- Важно: некоторые баффы определяют статы ТОЛЬКО в override (без base stat_buffs).
	if override_tbl then
		for stat_key, value in pairs(override_tbl) do
			if not base_tbl or base_tbl[stat_key] == nil then
				local stat_name = _resolve_stat_name(stat_key)

				if stat_name and type(value) == "number" then
					for _ = 1, stacks do
						_apply_stat_value(current, stat_name, value)
					end

					applied = applied + 1
				end
			end
		end
	end

	return applied
end

local function _apply_template_stat_buffs(current, template, tier, stacks)
	if not template then
		return 0
	end

	local override = nil
	local talent_overrides = template.talent_overrides

	if talent_overrides and tier and tier > 0 then
		local override_index = math.min(tier, #talent_overrides)

		override = talent_overrides[override_index]
	end

	local stat_buffs = template.stat_buffs
	local override_stat_buffs = override and override.stat_buffs or nil

	local applied = 0

	applied = applied + _apply_stat_buff_table(current, stat_buffs, override_stat_buffs, stacks)

	-- Важно: conditional_stat_buffs часто завязаны на контекст/условия.
	-- Применяем их только если нет функций-условий (то есть таблица фактически безусловная).
	local conditional_stat_buffs = template.conditional_stat_buffs

	if conditional_stat_buffs and not template.conditional_stat_buffs_func and not template.conditional_stat_buffs_funcs then
		local override_conditional_stat_buffs = override and override.conditional_stat_buffs or nil

		applied = applied + _apply_stat_buff_table(current, conditional_stat_buffs, override_conditional_stat_buffs, stacks)
	end

	return applied
end

local function _format_stat_value(stat_name, stat_value)
	local stat_buff_type = stat_buff_types[stat_name]

	if stat_buff_type == "additive_multiplier" or stat_buff_type == "multiplicative_multiplier" then
		local delta_pct = (stat_value - 1) * 100

		return string.format("%.2f%% (x%.3f)", delta_pct, stat_value)
	end

	if stat_buff_type == "value" then
		if string.find(stat_name, "chance", 1, true) then
			return string.format("%.2f%%", stat_value * 100)
		end

		return string.format("%.3f", stat_value)
	end

	if stat_buff_type == "max_value" then
		return string.format("%.3f", stat_value)
	end

	return string.format("%.3f", stat_value)
end

local function _build_panel_text(stat_buffs, debug_info)
	local lines = {}

	local group_crit = mod:localize("group_crit")
	local group_damage = mod:localize("group_damage")
	local group_defense = mod:localize("group_defense")

	if mod:get("debug_panel") and debug_info then
		lines[#lines + 1] = string.format(
			"debug: talents=%i, buff_templates=%i, applied=%i",
			debug_info.selected_talents_count or 0,
			debug_info.buff_template_tiers_count or 0,
			debug_info.applied_stat_entries or 0
		)
		lines[#lines + 1] = ""
	end

	lines[#lines + 1] = string.format("%s:", group_crit)

	for i = 1, #requested_stat_groups.crit do
		local stat_name = requested_stat_groups.crit[i]
		local value = stat_buffs[stat_name]

		lines[#lines + 1] = string.format("- %s: %s", stat_name, _format_stat_value(stat_name, value))
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("%s:", group_damage)

	for i = 1, #requested_stat_groups.damage do
		local stat_name = requested_stat_groups.damage[i]
		local value = stat_buffs[stat_name]

		lines[#lines + 1] = string.format("- %s: %s", stat_name, _format_stat_value(stat_name, value))
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("%s:", group_defense)

	for i = 1, #requested_stat_groups.defense do
		local stat_name = requested_stat_groups.defense[i]
		local value = stat_buffs[stat_name]

		lines[#lines + 1] = string.format("- %s: %s", stat_name, _format_stat_value(stat_name, value))
	end

	return table.concat(lines, "\n")
end

local function _compute_selected_talent_stat_buffs(view)
	local active_layout = view.get_active_layout and view:get_active_layout() or nil

	if not active_layout then
		return nil
	end

	local node_widget_tiers = view._node_widget_tiers

	if type(node_widget_tiers) ~= "table" then
		return nil
	end

	local backend_string = TalentLayoutParser.pack_backend_data(active_layout, node_widget_tiers)

	local preview_player = view._preview_player
	local profile = preview_player and preview_player:profile()

	if not profile then
		return nil
	end

	local selected_talents = {}

	-- Используем активный layout этого view, чтобы не было рассинхрона widget_name/layout.
	TalentLayoutParser.selected_talents_from_selected_nodes(active_layout, node_widget_tiers, selected_talents)
	local loadout_destination = {
		ability = {},
		blitz = {},
		aura = {},
		pocketable = {},
		passives = {},
		coherency = {},
		special_rules = {},
		buff_template_tiers = {},
		iconics = {},
		modifiers = {},
	}

	CharacterSheet.class_loadout(profile, loadout_destination, nil, selected_talents, true)

	local buff_template_tiers = loadout_destination.buff_template_tiers
	local stat_buffs = _new_stat_table()
	local debug_info = {
		selected_talents_count = 0,
		buff_template_tiers_count = 0,
		applied_stat_entries = 0,
	}

	for _ in pairs(selected_talents) do
		debug_info.selected_talents_count = debug_info.selected_talents_count + 1
	end

	for _ in pairs(buff_template_tiers) do
		debug_info.buff_template_tiers_count = debug_info.buff_template_tiers_count + 1
	end

	for buff_template_name, tier in pairs(buff_template_tiers) do
		local template = BuffTemplates[buff_template_name]

		-- В игровом коде tier влияет на talent_overrides у ОДНОГО баффа, а не на "стекание" одного шаблона.
		-- Поэтому применяем шаблон один раз, но с нужным tier.
		local override_tier = tier or 1

		debug_info.applied_stat_entries = debug_info.applied_stat_entries + _apply_template_stat_buffs(stat_buffs, template, override_tier, 1)
	end

	return backend_string, stat_buffs, debug_info
end

local function _create_panel_widget_definition()
	local title_style = table.clone(UIFontSettings.header_3)

	title_style.font_size = 18
	title_style.text_horizontal_alignment = "left"
	title_style.text_vertical_alignment = "top"
	title_style.offset = { 16, 14, 2 }
	title_style.size = { PANEL_SIZE[1] - 32, 30 }
	title_style.text_color = Color.terminal_text_header(255, true)

	local text_style = table.clone(UIFontSettings.body_small)

	text_style.font_size = 16
	text_style.text_horizontal_alignment = "left"
	text_style.text_vertical_alignment = "top"
	text_style.line_spacing = 1.15
	text_style.offset = { 16, 52, 2 }
	text_style.size = { PANEL_SIZE[1] - 32, PANEL_SIZE[2] - 68 }
	text_style.text_color = Color.terminal_text_body(255, true)

	local background_style = {
		color = { 200, 0, 0, 0 },
		offset = { 0, 0, 0 },
	}

	local pass_template = {
		{
			pass_type = "rect",
			style_id = "background",
			style = background_style,
			visibility_function = function(content)
				return content.visible
			end,
		},
		{
			pass_type = "text",
			value_id = "title",
			style_id = "title",
			style = title_style,
			visibility_function = function(content)
				return content.visible
			end,
		},
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			style = text_style,
			visibility_function = function(content)
				return content.visible
			end,
		},
	}

	return UIWidget.create_definition(pass_template, "screen", nil, PANEL_SIZE)
end

local last_backend_string_by_view = setmetatable({}, { __mode = "k" })

mod:hook_safe("TalentBuilderView", "on_enter", function(self)
	if not panel_enabled() then
		return
	end

	if self._widgets_by_name and self._widgets_by_name[PANEL_WIDGET_NAME] then
		return
	end

	local definition = _create_panel_widget_definition()
	local widget = self:_create_widget(PANEL_WIDGET_NAME, definition)

	widget.offset[1] = 1920 - PANEL_SIZE[1] - PANEL_MARGIN_X
	widget.offset[2] = PANEL_TOP_Y
	widget.offset[3] = 210

	widget.content.visible = true
	widget.content.title = mod:localize("panel_title")
	widget.content.text = ""

	local widgets = self._widgets

	widgets[#widgets + 1] = widget
end)

mod:hook_safe("TalentBuilderView", "update", function(self, dt, t)
	local widget = self._widgets_by_name and self._widgets_by_name[PANEL_WIDGET_NAME]

	if not widget then
		return
	end

	local visible = panel_enabled()

	widget.content.visible = visible

	if not visible then
		return
	end

	local ok, backend_string, stat_buffs, debug_info = pcall(function()
		return _compute_selected_talent_stat_buffs(self)
	end)

	if not ok or not backend_string or not stat_buffs then
		widget.content.text = ""

		return
	end

	local last_backend_string = last_backend_string_by_view[self]

	if last_backend_string == backend_string then
		return
	end

	last_backend_string_by_view[self] = backend_string
	widget.content.text = _build_panel_text(stat_buffs, debug_info)
end)

