local mod = get_mod("DivisionHUD")

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local M = {}

local function _copy_argb(dst, src)
	if not dst or type(src) ~= "table" then
		return
	end

	dst[1] = type(src[1]) == "number" and src[1] or 255
	dst[2] = type(src[2]) == "number" and src[2] or 255
	dst[3] = type(src[3]) == "number" and src[3] or 255
	dst[4] = type(src[4]) == "number" and src[4] or 255
end

local function _reset_widget(widget)
	if not widget then
		return
	end

	if widget.content then
		widget.content.visible = false
		widget.content.dist_text = ""
		widget.content.count_text = ""
	end

	widget.alpha_multiplier = 0
	widget.dirty = true
end

local function _reset_icon_transform(widget)
	local style = widget and widget.style
	local icon_style = style and style.icon
	local default_size = icon_style and icon_style.default_size
	local default_offset = icon_style and icon_style.default_offset

	if not icon_style or type(default_size) ~= "table" or type(default_offset) ~= "table" then
		return
	end

	icon_style.size[1] = default_size[1]
	icon_style.size[2] = default_size[2]
	icon_style.offset[1] = default_offset[1]
	icon_style.offset[2] = default_offset[2]
	icon_style.offset[3] = default_offset[3]
end

local function _apply_icon_transform(widget, scale, y_offset)
	local style = widget and widget.style
	local icon_style = style and style.icon
	local default_size = icon_style and icon_style.default_size
	local default_offset = icon_style and icon_style.default_offset

	if not icon_style or type(default_size) ~= "table" or type(default_offset) ~= "table" then
		return
	end

	local sx = math.max(1, math.floor(default_size[1] * scale + 0.5))
	local sy = math.max(1, math.floor(default_size[2] * scale + 0.5))
	local dx = math.floor((default_size[1] - sx) * 0.5 + 0.5)
	local dy = math.floor((default_size[2] - sy) * 0.5 + 0.5)

	icon_style.size[1] = sx
	icon_style.size[2] = sy
	icon_style.offset[1] = default_offset[1] + dx
	icon_style.offset[2] = default_offset[2] + dy + y_offset
	icon_style.offset[3] = default_offset[3]
end

local function _apply_count_alpha(widget)
	if not widget or not widget.style then
		return
	end

	local count_ids = {
		"count_text_outline_w",
		"count_text_outline_e",
		"count_text_outline_n",
		"count_text_outline_s",
		"count_text",
	}

	for i = 1, #count_ids do
		local pass_style = widget.style[count_ids[i]]
		local text_color = pass_style and pass_style.text_color

		if text_color then
			text_color[1] = 255
		end
	end
end

local function _apply_text_alpha(widget, base_text_color)
	local style = widget and widget.style
	local dist_text_style = style and style.dist_text
	local dist_text_color = dist_text_style and dist_text_style.text_color

	if dist_text_color then
		_copy_argb(dist_text_color, base_text_color)
	end

	_apply_count_alpha(widget)
end

local function _ensure_anim_state(self, categories)
	self._prox_anim = self._prox_anim or {}

	for i = 1, #categories do
		local cat = categories[i]

		if not self._prox_anim[cat] then
			self._prox_anim[cat] = {
				state = "hidden",
				timer = 0,
				alpha = 0,
				y_offset = 0,
				grid_idx = nil,
				icon_scale = self._div_prox_icon_enter_scale or 0.82,
				icon_y_offset = 0,
			}
		end
	end
end

function M.init(self, definitions)
	self._div_prox_widget_names = definitions.PROX_SLOT_WIDGET_NAMES or {}
	self._div_prox_grid_positions = definitions.PROX_GRID_POSITIONS or {}
	self._div_prox_slide_px = definitions.PROX_SLIDE_PX or 8
	self._div_prox_anim_enter_dur = definitions.PROX_ANIM_ENTER_DUR or 0.2
	self._div_prox_anim_exit_dur = definitions.PROX_ANIM_EXIT_DUR or 0.16
	self._div_prox_icon_enter_scale = definitions.PROX_ICON_ENTER_SCALE or 0.82
	self._div_prox_icon_exit_scale = definitions.PROX_ICON_EXIT_SCALE or 0.82
	self._prox_anim = {}
	-- Store definition build scale to compute runtime ratio
	self._prox_def_hud_layout_scale = definitions.HUD_LAYOUT_SCALE or 1

	local widgets = self._widgets_by_name or {}

	for _, widget_name in pairs(self._div_prox_widget_names) do
		_reset_widget(widgets[widget_name])
		_reset_widget(widgets[widget_name .. "_bg"])
	end
end

function M.update(self, widgets, opacity, dt, proximity_scan, right_slot_icon_fallback, resolve_stimm_slot_main_argb_255, is_valid_argb_255, default_text_color)
	dt = (type(dt) == "number" and dt == dt and dt > 0) and dt or 0

	local settings = mod._settings
	local prox_data = self._prox_data or {}
	local categories = proximity_scan and proximity_scan.CATEGORIES or {}
	local enabled = type(settings) ~= "table" or (settings.proximity_enabled ~= false and settings.proximity_enabled ~= 0)
	local show_stimm = type(settings) ~= "table" or (settings.proximity_show_stimm ~= false and settings.proximity_show_stimm ~= 0)
	local cat_settings = {
		medical_station = type(settings) ~= "table" or (settings.proximity_show_medical_station ~= false and settings.proximity_show_medical_station ~= 0),
		medical = type(settings) ~= "table" or (settings.proximity_show_medical ~= false and settings.proximity_show_medical ~= 0),
		medical_deployed = type(settings) ~= "table" or (settings.proximity_show_medical_deployed ~= false and settings.proximity_show_medical_deployed ~= 0),
		stimm_corruption = show_stimm,
		stimm_power = show_stimm,
		stimm_speed = show_stimm,
		stimm_ability = show_stimm,
		ammo_small = type(settings) ~= "table" or (settings.proximity_show_ammo_small ~= false and settings.proximity_show_ammo_small ~= 0),
		ammo_large = type(settings) ~= "table" or (settings.proximity_show_ammo_large ~= false and settings.proximity_show_ammo_large ~= 0),
		ammo_crate = type(settings) ~= "table" or (settings.proximity_show_ammo_crate ~= false and settings.proximity_show_ammo_crate ~= 0),
		grenade = type(settings) ~= "table" or (settings.proximity_show_grenade ~= false and settings.proximity_show_grenade ~= 0),
		grimoire = type(settings) ~= "table" or (settings.proximity_show_grimoire ~= false and settings.proximity_show_grimoire ~= 0),
		tome = type(settings) ~= "table" or (settings.proximity_show_tome ~= false and settings.proximity_show_tome ~= 0),
	}

	_ensure_anim_state(self, categories)

	local slide_px = self._div_prox_slide_px or 8
	local grid_positions = self._div_prox_grid_positions or {}
	local widget_names = self._div_prox_widget_names or {}
	local enter_dur = self._div_prox_anim_enter_dur or 0.2
	local exit_dur = self._div_prox_anim_exit_dur or 0.16
	local icon_enter_scale = self._div_prox_icon_enter_scale or 0.82
	local icon_exit_scale = self._div_prox_icon_exit_scale or 0.82

	for i = 1, #categories do
		local cat = categories[i]
		local anim = self._prox_anim[cat]
		local want = enabled and cat_settings[cat] and prox_data[cat] ~= nil

		if want and anim.state == "exit" then
			local gp = anim.grid_idx and grid_positions[anim.grid_idx]
			local sd = (gp and gp.is_bottom) and 1 or -1

			anim.state = "enter"
			anim.timer = enter_dur * (1 - anim.alpha)
			anim.y_offset = sd * slide_px * (1 - anim.alpha)
		elseif not want and (anim.state == "enter" or anim.state == "hold") then
			anim.state = "exit"
			anim.timer = exit_dur * (1 - anim.alpha)
			anim.grid_idx = nil
		end
	end

	local active = {}

	for i = 1, #categories do
		local cat = categories[i]
		local anim = self._prox_anim[cat]

		if anim.state == "enter" or anim.state == "hold" then
			active[#active + 1] = anim
		end
	end

	table.sort(active, function(a, b)
		local ai = a.grid_idx or math.huge
		local bi = b.grid_idx or math.huge

		return ai < bi
	end)

	for new_idx, anim in ipairs(active) do
		if anim.grid_idx ~= new_idx then
			anim.grid_idx = new_idx
			anim.y_offset = 0
			anim.icon_y_offset = 0
		end
	end

	local next_idx = #active + 1

	for i = 1, #categories do
		local cat = categories[i]
		local anim = self._prox_anim[cat]
		local want = enabled and cat_settings[cat] and prox_data[cat] ~= nil

		if want and anim.state == "hidden" and next_idx <= #grid_positions then
			local gp = grid_positions[next_idx]
			local sd = (gp and gp.is_bottom) and 1 or -1

			anim.state = "enter"
			anim.timer = 0
			anim.alpha = 0
			anim.grid_idx = next_idx
			anim.y_offset = sd * slide_px
			anim.icon_scale = icon_enter_scale
			anim.icon_y_offset = sd * math.max(1, math.floor(slide_px * 0.35 + 0.5))
			next_idx = next_idx + 1
		end
	end

	for i = 1, #categories do
		local cat = categories[i]
		local widget_name = widget_names[cat]
		local widget = widget_name and widgets[widget_name]
		local bg_widget = widget_name and widgets[widget_name .. "_bg"]

		if not widget or not widget.content then
			goto continue_prox
		end

		local anim = self._prox_anim[cat]
		local gp = anim.grid_idx and grid_positions[anim.grid_idx]
		local sd = (gp and gp.is_bottom) and 1 or -1

		anim.timer = anim.timer + dt

		if anim.state == "enter" then
			local p = math.min(1, anim.timer / enter_dur)
			local ep = math.easeOutCubic(p)

			anim.alpha = ep
			anim.y_offset = sd * slide_px * (1 - ep)
			anim.icon_scale = icon_enter_scale + (1 - icon_enter_scale) * ep
			anim.icon_y_offset = math.floor(sd * math.max(1, math.floor(slide_px * 0.35 + 0.5)) * (1 - ep) + 0.5)

			if p >= 1 then
				anim.state = "hold"
				anim.alpha = 1
				anim.y_offset = 0
				anim.icon_scale = 1
				anim.icon_y_offset = 0
			end
		elseif anim.state == "hold" then
			anim.alpha = 1
			anim.y_offset = 0
			anim.icon_scale = 1
			anim.icon_y_offset = 0
		elseif anim.state == "exit" then
			local p = math.min(1, anim.timer / exit_dur)
			local ep = math.easeOutCubic(p)

			anim.alpha = 1 - ep
			anim.y_offset = sd * slide_px * ep
			anim.icon_scale = 1 - (1 - icon_exit_scale) * ep
			anim.icon_y_offset = math.floor(sd * math.max(1, math.floor(slide_px * 0.35 + 0.5)) * ep + 0.5)

			if p >= 1 then
				anim.state = "hidden"
				anim.alpha = 0
				anim.y_offset = 0
				anim.grid_idx = nil
				anim.icon_scale = icon_exit_scale
				anim.icon_y_offset = 0
			end
		end

		gp = anim.grid_idx and grid_positions[anim.grid_idx]

		if anim.state == "hidden" then
			_reset_icon_transform(widget)
			_reset_widget(widget)
			_reset_widget(bg_widget)
			goto continue_prox
		end

		if not gp then
			_reset_icon_transform(widget)
			_reset_widget(widget)
			_reset_widget(bg_widget)
			goto continue_prox
		end

		local data = prox_data[cat]
		local eff_alpha = opacity * math.max(0, math.min(1, anim.alpha))

		local desired = (mod and type(mod._settings) == "table" and type(mod._settings.hud_layout_scale) == "number" and mod._settings.hud_layout_scale) or (self._prox_def_hud_layout_scale or 1)
		local def_scale = self._prox_def_hud_layout_scale or 1
		local ratio = (def_scale ~= 0) and (desired / def_scale) or 1

		-- Scale grid positions and animated offset by ratio
		local px = gp.x and math.floor((gp.x * ratio) + 0.5) or 0
		local py = gp.y and math.floor((gp.y * ratio) + 0.5) or 0
		local ay = math.floor((anim.y_offset or 0) * ratio + 0.5)

		self:set_scenegraph_position(widget_name, px, py + ay)

		if bg_widget and bg_widget.content then
			bg_widget.content.visible = true
			bg_widget.alpha_multiplier = eff_alpha
			bg_widget.dirty = true
		end

		widget.content.visible = true
		widget.alpha_multiplier = eff_alpha
		widget.content.icon = (data and data.icon) or right_slot_icon_fallback
		widget.content.dist_text = data and string.format("%dm", data.dist_m) or ""

		local count_str = data and data.count and data.count > 0 and tostring(data.count) or nil
		local size_str = nil

		if data and data.size_label_loc_key then
			local loc = mod:localize(data.size_label_loc_key)

			if type(loc) == "string" and loc ~= "" and not string.find(loc, "^<unlocalized") then
				size_str = loc
			else
				size_str = "big"
			end
		elseif data then
			size_str = data.size_label
		end

		if count_str and size_str then
			widget.content.count_text = count_str .. " " .. size_str
		elseif count_str then
			widget.content.count_text = count_str
		elseif size_str then
			widget.content.count_text = size_str
		else
			widget.content.count_text = ""
		end

		local icon_color = widget.style.icon and widget.style.icon.color

		if icon_color then
			local icon_base = { 255, 255, 255, 255 }
			local is_stimm_cat = cat == "stimm_corruption" or cat == "stimm_power" or cat == "stimm_speed" or cat == "stimm_ability"

			if is_stimm_cat and data and data.stimm_id then
				local stimm_argb = resolve_stimm_slot_main_argb_255(data.stimm_id, settings)

				if is_valid_argb_255(stimm_argb) then
					icon_base = stimm_argb
				end
			elseif cat == "medical_deployed" then
				icon_base = UIHudSettings.color_tint_6
			elseif cat == "ammo_crate" and data and data.prox_icon_tint == "ammo_deployed" then
				icon_base = UIHudSettings.color_tint_ammo_high
			end

			_copy_argb(icon_color, icon_base)
		end

		_apply_text_alpha(widget, default_text_color)
		_apply_icon_transform(widget, anim.icon_scale, anim.icon_y_offset)

		widget.dirty = true

		::continue_prox::
	end
end

function M.destroy(self, ui_renderer)
	local widgets = self._widgets_by_name or {}
	local widget_names = self._div_prox_widget_names or {}

	for _, widget_name in pairs(widget_names) do
		local widget = widgets[widget_name]
		local bg_widget = widgets[widget_name .. "_bg"]

		_reset_icon_transform(widget)
		_reset_widget(widget)
		_reset_widget(bg_widget)
	end

	self._prox_anim = {}
end

return M
