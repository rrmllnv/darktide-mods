local mod = get_mod("TeamKills")

local CLASS = CLASS
local Color = Color
local Managers = Managers
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

-- Загружаем общий виджет
mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/Widget")

local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
local base_z = 100
local base_x = 0

-- Используем функцию get_players из Widget
local function get_players()
	return mod.get_players_for_killsboard()
end

-- Add killsboard scenegraph and widget to tactical overlay definitions
mod:hook_require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_definitions", function(instance)
	instance.scenegraph_definition.killsboard = {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = {KillstreakWidgetSettings.killsboard_size[1], KillstreakWidgetSettings.killsboard_size[2]},
		position = {0, 0, base_z}
	}
	instance.scenegraph_definition.killsboard_rows = {
		vertical_alignment = "top",
		parent = "killsboard",
		horizontal_alignment = "center",
		size = {KillstreakWidgetSettings.killsboard_size[1], KillstreakWidgetSettings.killsboard_size[2] - 100},
		position = {0, 40, base_z - 1}
	}
	instance.widget_definitions.killsboard = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/frames/dropshadow_heavy",
			style = {
				vertical_alignment = "center",
				scale_to_material = true,
				horizontal_alignment = "center",
				offset = {base_x, 0, base_z + 200},
				size = {KillstreakWidgetSettings.killsboard_size[1] - 4, KillstreakWidgetSettings.killsboard_size[2] - 3},
				color = Color.black(255, true),
				disabled_color = Color.black(255, true),
				default_color = Color.black(255, true),
				hover_color = Color.black(255, true),
			}
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/frames/inner_shadow_medium",
			style = {
				vertical_alignment = "center",
				scale_to_material = true,
				horizontal_alignment = "center",
				offset = {base_x, 0, base_z + 100},
				size = {KillstreakWidgetSettings.killsboard_size[1] - 24, KillstreakWidgetSettings.killsboard_size[2] - 28},
				color = Color.black(255, true),
				disabled_color = Color.black(255, true),
				default_color = Color.black(255, true),
				hover_color = Color.black(255, true),
			}
		},
		{
			value = "content/ui/materials/backgrounds/terminal_basic",
			pass_type = "texture",
			style = {
				vertical_alignment = "center",
				scale_to_material = true,
				horizontal_alignment = "center",
				offset = {base_x, 0, base_z},
				size = {KillstreakWidgetSettings.killsboard_size[1] - 4, KillstreakWidgetSettings.killsboard_size[2]},
				color = Color.black(255, true),
				disabled_color = Color.black(255, true),
				default_color = Color.black(255, true),
				hover_color = Color.black(255, true),
			}
		},
		{
			value = "content/ui/materials/backgrounds/hud/tactical_overlay_background",
			pass_type = "texture",
			style = {
				vertical_alignment = "center",
				horizontal_alignment = "center",
				offset = {base_x, 0, base_z - 1},
				size = {KillstreakWidgetSettings.killsboard_size[1] - 4 - (KillstreakWidgetSettings.killsboard_background_width_offset * 2), KillstreakWidgetSettings.killsboard_size[2]},
				color = Color.black(KillstreakWidgetSettings.killsboard_background_alpha, true),
			}
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/frames/premium_store/details_upper",
			style = {
				vertical_alignment = "center",
				scale_to_material = true,
				horizontal_alignment = "center",
			offset = {base_x, -KillstreakWidgetSettings.killsboard_size[2] / 2, base_z + 200},
			size = {KillstreakWidgetSettings.killsboard_size[1], 80},
				color = Color.gray(255, true),
				disabled_color = Color.gray(255, true),
				default_color = Color.gray(255, true),
				hover_color = Color.gray(255, true),
			}
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/frames/premium_store/details_lower_basic",
			style = {
				vertical_alignment = "center",
				scale_to_material = true,
				horizontal_alignment = "center",
			offset = {base_x, KillstreakWidgetSettings.killsboard_size[2] / 2 - 50, base_z + 200},
			size = {KillstreakWidgetSettings.killsboard_size[1] + 50, 120},
				color = Color.gray(255, true),
				disabled_color = Color.gray(255, true),
				default_color = Color.gray(255, true),
				hover_color = Color.gray(255, true),
			}
		},
	}, "killsboard")
end)

-- Функции create_killsboard_row_widget, setup_killsboard_row_widgets и adjust_killsboard_size теперь в Widget.lua

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

-- Хук для отрисовки виджетов после основной отрисовки, чтобы они были поверх всех элементов
-- Делаем точно как в scoreboard - без изменения start_layer, просто рисуем после func()
mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings)
	func(self, dt, t, input_service, ui_renderer, render_settings)
	
	local killsboard_widget = self._widgets_by_name["killsboard"]
	if killsboard_widget then
		-- Устанавливаем alpha_multiplier для основного виджета (он рисуется автоматически)
		killsboard_widget.alpha_multiplier = self._alpha_multiplier or 1
	end
	
	-- Рисуем строки killsboard после основной отрисовки
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
	
	local show_killsboard = mod.show_killsboard or mod:get("opt_show_killsboard") or 1
	local show_killsboard_end_view = mod:get("opt_show_killsboard_end_view") or 1
	local delete = false
	
	-- Удаляем виджеты только если:
	-- 1. Tactical overlay стал активен, но killsboard_hud_active еще false (но не в EndView)
	-- 2. Tactical overlay стал неактивен, но killsboard_hud_active еще true (но не в EndView)
	-- 3. Настройка show_killsboard выключена (но не в EndView)
	if self._active and not mod.killsboard_hud_active and not mod.killsboard_show_in_end_view then
		delete = true
	elseif not self._active and mod.killsboard_hud_active and not mod.killsboard_show_in_end_view then
		delete = true
	elseif show_killsboard ~= 1 and mod.killsboard_hud_active and not mod.killsboard_show_in_end_view then
		-- Удаляем виджеты, если настройка выключена (но не в EndView)
		delete = true
	elseif mod.killsboard_show_in_end_view and show_killsboard_end_view ~= 1 then
		-- Удаляем виджеты, если мы в EndView, но настройка show_killsboard_end_view выключена
		delete = true
	end
	
	-- Delete rows
	if delete then
		if self.killsboard_row_widgets then
			for i = 1, #self.killsboard_row_widgets do
				local widget = self.killsboard_row_widgets[i]
				self._widgets_by_name[widget.name] = nil
				self:_unregister_widget_name(widget.name)
			end
			self.killsboard_row_widgets = {}
		end
	end
	
	-- Создаем/обновляем виджеты если:
	-- 1. Tactical overlay активен и killsboard_hud_active еще false
	-- 2. Мы в EndView и настройка включена (независимо от активности tactical overlay)
	local should_create = false
	if self._active and not mod.killsboard_hud_active then
		should_create = true
	elseif mod.killsboard_show_in_end_view and show_killsboard_end_view == 1 and show_killsboard == 1 then
		-- В EndView создаем виджеты, даже если tactical overlay не активен
		if not mod.killsboard_hud_active or #(self.killsboard_row_widgets or {}) == 0 then
			should_create = true
		end
	end
	
	if should_create then
		if show_killsboard == 1 then
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
	-- Показываем killsboard если:
	-- 1. Обычные условия (show_killsboard включен, не в hub)
	-- 2. ИЛИ мы в EndView и обе настройки включены
	local should_show = (show_killsboard == 1 and not in_hub and not in_prologue_hub) or (mod.killsboard_show_in_end_view and show_killsboard == 1 and show_killsboard_end_view == 1)
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
	
	-- Обновляем флаг активности: true если tactical overlay активен ИЛИ мы в EndView
	mod.killsboard_hud_active = self._active or mod.killsboard_show_in_end_view
end)
