local mod = get_mod("GlobalStat")

local view_templates = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/templates/view_templates")
local views = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/modules/views")
local commands = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/modules/commands")
local utilities = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/modules/utilities")
local init = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/modules/init")

local VIEW_NAME = "player_progress_stats_view"

mod.version = "1.0.0"

init.setup(mod, VIEW_NAME, view_templates, views, utilities)
commands.setup(mod)

local ElementSettings = require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_settings")

local function setup_game_progress(tactical_overlay, ui_renderer)
	local page_key = "game_progress"
	local configs = {
		{
			blueprint = "title",
			text = mod:localize("tactical_overlay_game_progress"),
		},
		{
			blueprint = "body",
			text = "Тестовый текст для раздела игрового прогресса",
		},
	}
	
	tactical_overlay:_create_right_panel_widgets(page_key, configs, ui_renderer)
end

local function update_game_progress(tactical_overlay, dt, ui_renderer)
	if not ui_renderer then
		return
	end
	
	local page_key = "game_progress"
	local has_entry = tactical_overlay._right_panel_entries and tactical_overlay._right_panel_entries[page_key] ~= nil
	
	if not has_entry then
		setup_game_progress(tactical_overlay, ui_renderer)
	end
end

mod:hook("HudElementTacticalOverlay", "init", function(func, self, parent, draw_layer, start_scale, optional_context)
	local result = func(self, parent, draw_layer, start_scale, optional_context)
	
	if not ElementSettings or not ElementSettings.right_panel_grids then
		return result
	end
	
	local game_progress_data = {
		index = 4,
		loc_key = "tactical_overlay_game_progress",
		icon = {
			blueprint_type = "text_icon",
			value = "📊",
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
	
	if not ElementSettings.right_panel_order[4] then
		ElementSettings.right_panel_order[4] = "game_progress"
	end
end)

mod:hook("HudElementTacticalOverlay", "_get_page", function(func, self, page_key)
	local result = func(self, page_key)
	
	if page_key == "game_progress" and result then
		local localized_title = mod:localize("tactical_overlay_game_progress")
		result.loc_key = localized_title
	end
	
	return result
end)

mod:hook("HudElementTacticalOverlay", "_update_right_tab_bar", function(func, self, ui_renderer)
	if not ElementSettings.right_panel_order[4] then
		ElementSettings.right_panel_order[4] = "game_progress"
	end
	
	func(self, ui_renderer)
	
	local current_key = self._right_panel_key
	if current_key == "game_progress" then
		local title_widget = self._widgets_by_name.right_header_title
		if title_widget then
			title_widget.content.text = Utf8.upper(mod:localize("tactical_overlay_game_progress"))
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


