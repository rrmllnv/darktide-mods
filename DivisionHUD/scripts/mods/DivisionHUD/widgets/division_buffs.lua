local BuffSettings = require("scripts/settings/buff/buff_settings")
local HudElementPlayerBuffsSettings = require("scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_settings")
local Colors = require("scripts/utilities/ui/colors")
local Text = require("scripts/utilities/ui/text")
local UIWidget = require("scripts/managers/ui/ui_widget")

local buff_categories = BuffSettings.buff_categories
local MAX_BUFFS = HudElementPlayerBuffsSettings.max_buffs
local NEGATIVE_BUFFS_MAX = math.floor(MAX_BUFFS * 0.25)
local POSITIVE_BUFFS_MAX = MAX_BUFFS - NEGATIVE_BUFFS_MAX
local BUFF_ANIM_ENTER_DUR = 0.15
local BUFF_ANIM_EXIT_DUR = 0.12

local M = {}

local function _widget_set_colors(widget, is_negative, is_active)
	local source_colors

	if not is_active then
		source_colors = HudElementPlayerBuffsSettings.inactive_colors
	elseif is_negative then
		source_colors = HudElementPlayerBuffsSettings.negative_colors
	else
		source_colors = HudElementPlayerBuffsSettings.positive_colors
	end

	local style = widget.style

	for pass_id, pass_style in pairs(style) do
		local src = source_colors[pass_id]

		if src and not pass_style.text_color then
			Colors.color_copy(src, pass_style.color)
		end
	end

	widget.dirty = true
end

local function _widget_reset(widget, ui_renderer)
	_widget_set_colors(widget, false, false)

	widget.dirty = true
	widget.offset[1] = 0
	widget.offset[2] = 0
	widget.visible = false

	local content = widget.content

	content.taken = false
	content.visible = false
	content.text = nil
	content.opacity = 1
	content.duration_progress = 1

	local style = widget.style

	style.icon.material_values.talent_icon = nil
	style.icon.material_values.gradient_map = nil
	style.text_background.size[1] = 0

	local text_style = style.text

	text_style.size[1] = 0

	if ui_renderer then
		UIWidget.set_visible(widget, ui_renderer, false)
	end
end

local function _show_aura_category()
	local save_manager = Managers.save
	local show_aura_buff_icons = true

	if save_manager then
		local account_data = save_manager:account_data()
		local interface_settings = account_data and account_data.interface_settings

		if type(interface_settings) == "table" and interface_settings.show_aura_buff_icons ~= nil then
			show_aura_buff_icons = interface_settings.show_aura_buff_icons
		end
	end

	return show_aura_buff_icons
end

local function _compare_entries(a, b)
	if a.activated_time == b.activated_time then
		if a.hud_priority ~= b.hud_priority then
			if a.hud_priority and not b.hud_priority then
				return true
			end

			if not a.hud_priority and b.hud_priority then
				return false
			end

			return a.hud_priority < b.hud_priority
		end

		return a.start_index < b.start_index
	end

	return a.activated_time < b.activated_time
end

local function _acquire_widget(self)
	local pool = self._div_buff_widget_pool

	for i = 1, #pool do
		local widget = pool[i]

		if widget and not widget.content.taken then
			widget.content.taken = true
			widget.content.visible = true
			widget.visible = true

			return widget
		end
	end

	return nil
end

local function _find_entry(entries, buff_instance)
	for i = 1, #entries do
		local entry = entries[i]

		if entry.buff_instance == buff_instance then
			return entry
		end
	end

	return nil
end

local function _ensure_entry(self, entries, buff_instance)
	local entry = _find_entry(entries, buff_instance)

	if entry then
		entry._seen_this_frame = true

		return entry
	end

	local buff_template = buff_instance and buff_instance:template()
	local buff_category = buff_template and buff_template.buff_category or buff_categories.generic
	local start_index = self._div_buff_next_start_index or 1

	self._div_buff_next_start_index = start_index + 1

	entry = {
		buff_instance = buff_instance,
		buff_category = buff_category,
		start_index = start_index,
		activated_time = math.huge,
		hud_priority = nil,
		show = false,
		is_negative = buff_instance:is_negative(),
		is_active = nil,
		force_negative = nil,
		state = "hidden",
		timer = 0,
		alpha = 0,
		x_offset = 0,
		grid_idx = nil,
		widget = nil,
		_seen_this_frame = true,
		_remove = false,
		icon = nil,
		icon_gradient_map = nil,
		stack_count = nil,
		duration_progress = nil,
	}

	entries[#entries + 1] = entry

	return entry
end

local function _update_entry_widget(entry, ui_renderer)
	local widget = entry.widget
	local buff = entry.buff_instance

	if not widget or not buff then
		return
	end

	local hud_data = buff:get_hud_data()

	if not hud_data then
		return
	end

	local icon = hud_data.hud_icon
	local icon_gradient_map = hud_data.hud_icon_gradient_map
	local stack_count = hud_data.stack_count
	local show_stack_count = hud_data.show_stack_count
	local duration_progress = hud_data.duration_progress
	local is_active = hud_data.is_active
	local is_negative = hud_data.is_negative
	local force_negative = hud_data.force_negative_frame
	local buff_template = buff:template()
	local style = widget.style
	local content = widget.content

	if icon ~= entry.icon or entry.icon == nil or icon_gradient_map ~= entry.icon_gradient_map then
		style.icon.material_values.talent_icon = icon
		style.icon.material_values.gradient_map = icon_gradient_map
		entry.icon = icon
		entry.icon_gradient_map = icon_gradient_map
		widget.dirty = true
	end

	if duration_progress ~= entry.duration_progress then
		content.duration_progress = (duration_progress == 0) and 1 or (duration_progress or 1)
		entry.duration_progress = duration_progress
		widget.dirty = true
	end

	if stack_count ~= entry.stack_count or entry.stack_count == nil then
		local text_style = style.text

		if not show_stack_count then
			content.text, text_style.font_size = nil, 20
		elseif buff_template and buff_template.stack_hud_data_formatter then
			local text, optional_font_size = buff_template.stack_hud_data_formatter({
				buff_instance = buff,
			}, stack_count, buff_template, text_style)

			content.text, text_style.font_size = text, optional_font_size or 20
		else
			content.text = tostring(stack_count) or nil
			text_style.font_size = 20
		end

		if content.text and content.text ~= "" then
			local buff_size = {
				38,
				38,
			}
			local text_width = select(1, Text.text_size(ui_renderer, content.text, text_style, buff_size))

			if text_width then
				local text_margin = 5
				local total_width = text_margin + math.ceil(text_width)

				style.text_background.size[1] = total_width
				text_style.size[1] = total_width
			end
		else
			style.text_background.size[1] = 0
			text_style.size[1] = 0
		end

		entry.stack_count = stack_count
		widget.dirty = true
	end

	local negative_frame = is_negative or force_negative

	if is_active ~= entry.is_active or negative_frame ~= entry.force_negative or entry.is_active == nil then
		_widget_set_colors(widget, negative_frame, is_active)
		entry.is_active = is_active
		entry.is_negative = is_negative
		entry.force_negative = negative_frame
	end
end

local function _hide_entry(entry, ui_renderer, remove_after_hide)
	entry.state = "hidden"
	entry.timer = 0
	entry.alpha = 0
	entry.x_offset = 0
	entry.grid_idx = nil
	entry.activated_time = math.huge
	entry.is_active = nil
	entry.force_negative = nil

	if entry.widget then
		_widget_reset(entry.widget, ui_renderer)
		entry.widget = nil
	end

	entry.icon = nil
	entry.icon_gradient_map = nil
	entry.stack_count = nil
	entry.duration_progress = nil
	entry._remove = remove_after_hide == true
end

M.init = function(self, definitions)
	local buff_rows = definitions.buff_rows
	local widgets = self._widgets_by_name

	self._div_buff_entries = {}
	self._div_buff_grid_positions = buff_rows.grid_positions
	self._div_buff_max_slots = buff_rows.BUFF_MAX_SLOTS
	self._div_buff_widget_names = buff_rows.buff_widget_names
	self._div_buff_slot_spacing = buff_rows.BUFF_SLOT_SPACING
	self._div_buff_row_spacing = buff_rows.BUFF_ROW_SPACING
	self._div_buff_slide_px = buff_rows.BUFF_SLIDE_PX
	self._div_buff_next_start_index = 1
	self._div_buff_widget_pool = {}

	for i, name in ipairs(buff_rows.buff_widget_names) do
		local widget = widgets[name]

		if widget then
			self._div_buff_widget_pool[i] = widget
			_widget_reset(widget, nil)
		end
	end
end

M.update = function(self, dt, t, ui_renderer, opacity)
	dt = (type(dt) == "number" and dt == dt and dt > 0) and dt or 0

	local buff_extension = nil

	if self._parent then
		local exts = self._parent:player_extensions()

		buff_extension = exts and exts.buff
	end

	local entries = self._div_buff_entries
	local raw_buffs = buff_extension and buff_extension:buffs() or nil
	local show_aura_category = _show_aura_category()
	local max_visible = math.min(self._div_buff_max_slots or MAX_BUFFS, MAX_BUFFS)
	local slide_px = self._div_buff_slide_px

	for i = 1, #entries do
		local entry = entries[i]

		entry._seen_this_frame = false
		entry._remove = false
	end

	if raw_buffs then
		for i = 1, #raw_buffs do
			local buff = raw_buffs[i]

			if buff and buff:has_hud() then
				_ensure_entry(self, entries, buff)
			end
		end
	end

	local sortable = {}

	for i = 1, #entries do
		local entry = entries[i]
		local buff = entry.buff_instance

		if not entry._seen_this_frame then
			_hide_entry(entry, ui_renderer, true)
		elseif buff then
			local hud_data = buff:get_hud_data()
			local buff_template = buff:template()
			local buff_category = buff_template and buff_template.buff_category or buff_categories.generic
			local show_category = buff_category ~= buff_categories.aura or show_aura_category
			local is_negative = (hud_data and hud_data.is_negative) or buff:is_negative()
			local should_show = hud_data and hud_data.show == true and show_category or false

			entry.buff_category = buff_category
			entry.is_negative = is_negative
			entry.hud_priority = hud_data and hud_data.hud_priority or nil
			entry.show = should_show

			if should_show then
				sortable[#sortable + 1] = entry
			elseif entry.state == "hidden" then
				entry.activated_time = math.huge
			else
				_hide_entry(entry, ui_renderer, false)
			end
		end
	end

	table.sort(sortable, _compare_entries)

	local selected = {}
	local selected_count = 0
	local negative_count = 0
	local positive_count = 0

	for i = 1, #sortable do
		local entry = sortable[i]

		if selected_count >= max_visible then
			break
		end

		if entry.is_negative then
			if negative_count < NEGATIVE_BUFFS_MAX then
				negative_count = negative_count + 1
				selected_count = selected_count + 1
				selected[selected_count] = entry
			end
		elseif positive_count < POSITIVE_BUFFS_MAX then
			positive_count = positive_count + 1
			selected_count = selected_count + 1
			selected[selected_count] = entry
		end
	end

	local selected_lookup = {}

	for i = 1, #selected do
		local entry = selected[i]

		selected_lookup[entry] = i

		if entry.activated_time == math.huge then
			entry.activated_time = t
		end

		entry.grid_idx = i

		if entry.state == "hidden" then
			entry.state = "enter"
			entry.timer = 0
			entry.alpha = 0
			entry.x_offset = slide_px
		end
	end

	for i = 1, #entries do
		local entry = entries[i]

		if not selected_lookup[entry] and entry._seen_this_frame then
			if entry.state == "hidden" then
				entry.activated_time = math.huge
			else
				_hide_entry(entry, ui_renderer, false)
			end
		end
	end

	local grid_positions = self._div_buff_grid_positions

	for i = 1, #entries do
		local entry = entries[i]
		local state = entry.state

		if state == "enter" or state == "hold" then
			entry.timer = entry.timer + dt
		end

		if state == "enter" then
			local p = math.min(1, entry.timer / BUFF_ANIM_ENTER_DUR)
			local ep = math.easeOutCubic(p)

			entry.alpha = ep
			entry.x_offset = slide_px * (1 - ep)

			if p >= 1 then
				entry.state = "hold"
				entry.alpha = 1
				entry.x_offset = 0
			end
		elseif state == "hold" then
			entry.alpha = 1
			entry.x_offset = 0
		end

		state = entry.state

		if state == "enter" or state == "hold" then
			local gp = entry.grid_idx and grid_positions[entry.grid_idx]
			local widget = entry.widget

			if not widget and gp then
				widget = _acquire_widget(self)
				entry.widget = widget
			end

			if widget and gp then
				_update_entry_widget(entry, ui_renderer)

				widget.offset[1] = gp.x + math.floor(entry.x_offset + 0.5)
				widget.offset[2] = gp.y
				widget.alpha_multiplier = opacity
				widget.content.opacity = entry.alpha
				widget.content.visible = true
				widget.visible = true
				widget.dirty = true

				UIWidget.set_visible(widget, ui_renderer, true)
			elseif widget then
				widget.content.visible = false
				widget.dirty = true
			end
		elseif state == "hidden" and entry.widget then
			entry.widget.content.visible = false
			entry.widget.dirty = true
		end
	end

	for i = #entries, 1, -1 do
		if entries[i]._remove then
			table.remove(entries, i)
		end
	end
end

M.draw = function(self, dt, t, input_service, ui_renderer, render_settings)
	local pool = self._div_buff_widget_pool

	if not pool then
		return
	end

	for i = 1, #pool do
		local widget = pool[i]

		if widget and widget.visible and widget.dirty then
			UIWidget.draw(widget, ui_renderer)
		end
	end
end

M.destroy = function(self, ui_renderer)
	local pool = self._div_buff_widget_pool

	if not pool then
		return
	end

	for i = 1, #pool do
		local widget = pool[i]

		if widget then
			_widget_reset(widget, ui_renderer)
		end
	end

	self._div_buff_entries = {}
	self._div_buff_widget_pool = {}
end

return M
