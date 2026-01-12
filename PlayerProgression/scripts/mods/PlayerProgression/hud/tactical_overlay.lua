local tactical_overlay = {}

local mod = get_mod("PlayerProgression")

local ElementSettings = require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_settings")

local function get_selected_data()
	local selected_items = mod:get("playerprogression_selected_items") or {}
	local selected_items_order = mod:get("playerprogression_selected_items_order") or {}
	return selected_items, selected_items_order
end

local function safe_read_stat(stat_name)
	if not Managers or not Managers.stats or not Managers.stats.read_user_stat then
		return 0
	end

	local success, value = pcall(function()
		local result = Managers.stats:read_user_stat(1, stat_name)
		return result and type(result) == "number" and result or 0
	end)

	return success and value or 0
end

local function format_number(number)
	if not number or type(number) ~= "number" then
		return "0"
	end

	if mod.format_number then
		local success, result = pcall(function()
			return mod.format_number(number)
		end)

		if success and result then
			return result
		end
	end

	return tostring(math.floor(number))
end

local function localize(key)
	if key:match("^loc_") then
		local success, result = pcall(function()
			return Localize(key)
		end)

		if success and result and result ~= "" and result ~= key then
			return result
		end
	end

	local success, result = pcall(function()
		return mod:localize(key)
	end)

	if success and result and result ~= "" then
		return result
	end

	return key
end

local function setup_game_progress(tactical_overlay_instance, ui_renderer)
	if not mod:get("show_in_tactical_overlay") then
		return
	end

	local page_key = "game_progress"
	local selected_items, selected_items_order = get_selected_data()
	
	local configs = {}
	
	local has_selected = false
	
	for _, element_id in ipairs(selected_items_order) do
		local item_data = selected_items[element_id]
		if item_data and item_data.text_key then
			has_selected = true
			local text = localize(item_data.text_key)
			local value = ""
			
			if item_data.stat_name and item_data.stat_name ~= "" then
				local stat_value = safe_read_stat(item_data.stat_name)
				
				if item_data.mission_key or item_data.mission_name then
					value = (stat_value and stat_value > 0) and localize("mission_progress_done") or localize("mission_progress_not_done")
				else
					value = format_number(stat_value)
				end
			end
			
			if item_data.mission_key or item_data.mission_name then
				local mission_display_name = item_data.mission_name
				if not mission_display_name and item_data.mission_key then
					mission_display_name = localize(item_data.mission_key)
				end
				if mission_display_name and mission_display_name ~= "" then
					text = string.format("%s - %s", mission_display_name, text)
				end
			end
			
			local display_text = text
			if value and value ~= "" then
				local colored_value = string.format("{#color(255,255,255)}%s", value)
				display_text = string.format("%s: %s", text, colored_value)
			end
			
			local blueprint = "body"
			
			table.insert(configs, {
				blueprint = blueprint,
				text = display_text,
			})
		end
	end
	
	if not has_selected then
		table.insert(configs, {
			blueprint = "body",
			text = mod:localize("player_progression_no_selected_items"),
		})
	end
	
	tactical_overlay_instance:_create_right_panel_widgets(page_key, configs, ui_renderer)
end

local function get_selected_items_hash()
	local selected_items, _ = get_selected_data()
	local count = 0
	for _ in pairs(selected_items) do
		count = count + 1
	end
	return count
end

local function update_game_progress(tactical_overlay_instance, dt, ui_renderer)
	if not ui_renderer then
		return
	end

	if not mod:get("show_in_tactical_overlay") then
		return
	end
	
	local page_key = "game_progress"
	local has_entry = tactical_overlay_instance._right_panel_entries and tactical_overlay_instance._right_panel_entries[page_key] ~= nil
	
	if not has_entry then
		setup_game_progress(tactical_overlay_instance, ui_renderer)
		return
	end
	
	local current_key = tactical_overlay_instance._right_panel_key
	if current_key ~= page_key then
		return
	end
	
	local pt = mod:persistent_table("PlayerProgression")
	local current_hash = get_selected_items_hash(pt)
	
	if not tactical_overlay_instance._game_progress_items_hash then
		tactical_overlay_instance._game_progress_items_hash = current_hash
		setup_game_progress(tactical_overlay_instance, ui_renderer)
		return
	end
	
	if tactical_overlay_instance._game_progress_items_hash ~= current_hash then
		tactical_overlay_instance._game_progress_items_hash = current_hash
		setup_game_progress(tactical_overlay_instance, ui_renderer)
	end
end

tactical_overlay.setup = function()
	mod:hook("HudElementTacticalOverlay", "init", function(func, self, parent, draw_layer, start_scale, optional_context)
		local result = func(self, parent, draw_layer, start_scale, optional_context)
		
		if not mod:get("show_in_tactical_overlay") then
			return result
		end
		
		if not ElementSettings or not ElementSettings.right_panel_grids then
			return result
		end
		
		local game_progress_data = {
			index = 4,
			loc_key = "tactical_overlay_player_progression",
			icon = {
				blueprint_type = "texture_icon",
				value = "content/ui/materials/hud/interactions/icons/havoc",
			},
		}
		
		local original = ElementSettings.right_panel_grids["game_progress"]
		if original then
			self:_override_right_panel_category("game_progress", game_progress_data, nil)
		else
			if not self._grid_overrides then
				self._grid_overrides = {}
			end
			self._grid_overrides["game_progress"] = game_progress_data
		end
		
		if not ElementSettings.right_panel_order[4] then
			ElementSettings.right_panel_order[4] = "game_progress"
		end
		
		return result
	end)

	mod:hook("HudElementTacticalOverlay", "_setup_right_panel_widgets", function(func, self)
		func(self)
		
		if not mod:get("show_in_tactical_overlay") then
			return
		end
		
		if not ElementSettings.right_panel_order[4] then
			ElementSettings.right_panel_order[4] = "game_progress"
		end
	end)

	mod:hook("HudElementTacticalOverlay", "_get_page", function(func, self, page_key)
		local result = func(self, page_key)
		
		if not mod:get("show_in_tactical_overlay") then
			return result
		end
		
		if page_key == "game_progress" then
			if not result then
				result = {
					index = 4,
					loc_key = "tactical_overlay_player_progression",
					icon = {
						blueprint_type = "texture_icon",
						value = "content/ui/materials/hud/interactions/icons/havoc",
					},
				}
				
				if not self._grid_overrides then
					self._grid_overrides = {}
				end
				self._grid_overrides["game_progress"] = result
			else
				local localized_title = mod:localize("tactical_overlay_player_progression")
				result.loc_key = localized_title
			end
		end
		
		return result
	end)

	mod:hook("HudElementTacticalOverlay", "_update_right_tab_bar", function(func, self, ui_renderer)
		if not mod:get("show_in_tactical_overlay") then
			func(self, ui_renderer)
			return
		end
		
		if not ElementSettings.right_panel_order[4] then
			ElementSettings.right_panel_order[4] = "game_progress"
		end
		
		func(self, ui_renderer)
		
		local current_key = self._right_panel_key
		if current_key == "game_progress" then
			local title_widget = self._widgets_by_name.right_header_title
			if title_widget then
				title_widget.content.text = Utf8.upper(mod:localize("tactical_overlay_player_progression"))
			end
		end
	end)

	mod:hook("HudElementTacticalOverlay", "update", function(func, self, dt, t, ui_renderer, render_settings, input_service)
		local result = func(self, dt, t, ui_renderer, render_settings, input_service)
		
		if ui_renderer and self._right_panel_entries then
			update_game_progress(self, dt, ui_renderer)
		end
		
		return result
	end)
end

return tactical_overlay
