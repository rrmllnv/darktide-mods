local mod = get_mod("TeamKills")

local CLASS = CLASS
local Color = Color
local Managers = Managers
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/Widget")

local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
local WidgetBackground = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetBackground")
local base_z = KillstreakWidgetSettings.killsboard_base_z
local base_x = 0

local function get_players()
	return mod.get_players_for_killsboard()
end

mod:hook_require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_definitions", function(instance)
	instance.scenegraph_definition.killsboard = WidgetBackground.create_killsboard_scenegraph(KillstreakWidgetSettings, base_z)
	
	local rows_scenegraph = WidgetBackground.create_killsboard_rows_scenegraph(KillstreakWidgetSettings, base_z)
	instance.scenegraph_definition.killsboard_rows = rows_scenegraph
	local background_passes = WidgetBackground.create_killsboard_background_passes(KillstreakWidgetSettings, base_x, base_z)
	instance.widget_definitions.killsboard = UIWidget.create_definition(background_passes, "killsboard")
end)

local function _is_in_hub()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	local is_in_hub = game_mode_name == "hub"
	return is_in_hub
end

local function _is_in_prologue_hub()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	local is_in_hub = game_mode_name == "prologue_hub"
	return is_in_hub
end

mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings)
	if func then
	func(self, dt, t, input_service, ui_renderer, render_settings)
	end
	
	local killsboard_widget = self._widgets_by_name and self._widgets_by_name["killsboard"]
	if killsboard_widget then
		killsboard_widget.alpha_multiplier = self._alpha_multiplier or 1
	end
	
	if self.killsboard_row_widgets then
		for _, widget in pairs(self.killsboard_row_widgets) do
			if widget and widget.visible then
				widget.alpha_multiplier = self._alpha_multiplier or 1
				UIWidget.draw(widget, ui_renderer)
			end
		end
	end
end)

mod:hook(CLASS.HudElementTacticalOverlay, "update", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	func(self, dt, t, ui_renderer, render_settings, input_service)
	
	self.killsboard_row_widgets = self.killsboard_row_widgets or {}
	local killsboard_widget = self._widgets_by_name["killsboard"]
	
	local show_killsboard = mod.show_killsboard
	if show_killsboard == nil then
		show_killsboard = mod:get("opt_show_killsboard") ~= false
	end
	local show_killsboard_end_view = mod:get("opt_show_killsboard_end_view") ~= false
	local delete = false
	
	if self._active and not mod.killsboard_hud_active and not mod.killsboard_show_in_end_view then
		delete = true
	elseif not self._active and mod.killsboard_hud_active and not mod.killsboard_show_in_end_view then
		delete = true
	elseif not show_killsboard and mod.killsboard_hud_active and not mod.killsboard_show_in_end_view then
		delete = true
	elseif mod.killsboard_show_in_end_view and not show_killsboard_end_view then
		delete = true
	end
	
	if delete then
		if self.killsboard_row_widgets then
			for i = 1, #self.killsboard_row_widgets do
				local widget = self.killsboard_row_widgets[i]
				self._widgets_by_name[widget.name] = nil
				self:_unregister_widget_name(widget.name)
			end
			self.killsboard_row_widgets = {}
		end
		if not show_killsboard and not mod.killsboard_show_in_end_view then
			mod.killsboard_hud_active = false
		end
	end
	
	local should_create = false
	if self._active and not mod.killsboard_hud_active then
		should_create = true
	elseif mod.killsboard_show_in_end_view and show_killsboard_end_view and show_killsboard then
		if not mod.killsboard_hud_active or #(self.killsboard_row_widgets or {}) == 0 then
			should_create = true
		end
	elseif show_killsboard and mod.killsboard_hud_active and (#(self.killsboard_row_widgets or {}) == 0) then
		should_create = true
	end
	
	if should_create then
		if show_killsboard then
			local players = get_players()
			local row_widgets, total_height = mod:setup_killsboard_row_widgets(self.killsboard_row_widgets, self._widgets_by_name, players, self, "_create_widget", ui_renderer)
			self.killsboard_row_widgets = row_widgets
			
			if killsboard_widget then
				mod:adjust_killsboard_size(total_height, killsboard_widget, self._ui_scenegraph, self.killsboard_row_widgets)
			end
		end
	end
	
	local in_hub = _is_in_hub()
	local in_prologue_hub = _is_in_prologue_hub()
	local should_show = (show_killsboard and not in_hub and not in_prologue_hub) or (mod.killsboard_show_in_end_view and show_killsboard and show_killsboard_end_view)
	if killsboard_widget then
		killsboard_widget.visible = should_show
	end
	if self.killsboard_row_widgets then
		for i = 1, #self.killsboard_row_widgets do
			local widget = self.killsboard_row_widgets[i]
			if widget then
				widget.visible = should_show
			end
		end
	end
	
	if show_killsboard then
	mod.killsboard_hud_active = self._active or mod.killsboard_show_in_end_view
	else
		if not mod.killsboard_show_in_end_view then
			mod.killsboard_hud_active = false
		end
	end
end)
