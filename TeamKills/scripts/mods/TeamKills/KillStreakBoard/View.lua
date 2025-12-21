local mod = get_mod("TeamKills")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local base_z = 100

-- Загружаем общий виджет
mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/Widget")

local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")

local KillstreakView = class("KillstreakView", "BaseView")

KillstreakView.init = function(self, settings, context)
    self._definitions = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetDefinitions")
    self._settings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
    self.end_view = context and context.end_view
    
    KillstreakView.super.init(self, self._definitions, settings)
    self._pass_draw = true
    self._pass_input = true
end

KillstreakView.on_enter = function(self)
    self._definitions = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetDefinitions")
    self._settings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
    
    KillstreakView.super.on_enter(self)
    
    -- Виджет создается автоматически из определений через super.on_enter
    self.killsboard_widget = self._widgets_by_name["killsboard"]
    
    -- В EndView увеличиваем z-позицию для отображения поверх игровых элементов
    local end_view_z = self.end_view and 200 or base_z
    
    if self.killsboard_widget then
        -- Передаем флаг end_view в content для visibility_function
        if self.killsboard_widget.content then
            self.killsboard_widget.content.end_view = self.end_view
        end
        -- Устанавливаем видимость сразу, без анимации для view
        self.killsboard_widget.alpha_multiplier = 1
        self.killsboard_widget.visible = true
        if not self.end_view then
            self.killsboard_widget.offset = {0, 0, base_z}
        else
            -- В EndView опускаем рамку вниз, чтобы она совпадала с таблицей
            self.killsboard_widget.offset = {0, 0, end_view_z}
            -- Увеличиваем z-позицию для всех стилей виджета в EndView
            if self.killsboard_widget.style then
                for style_name, style in pairs(self.killsboard_widget.style) do
                    if style.offset then
                        style.offset[3] = (style.offset[3] or base_z) + (end_view_z - base_z)
                    end
                end
            end
        end
    end
    
    self.row_widgets = {}
    self:setup_row_widgets()
    
    -- В EndView увеличиваем z-позицию для отображения поверх игровых элементов
    if self.end_view then
        -- Увеличиваем z-позицию для основного scenegraph killsboard
        if self._ui_scenegraph and self._ui_scenegraph.killsboard then
            self._ui_scenegraph.killsboard.position[3] = end_view_z
        end
        if self._ui_scenegraph and self._ui_scenegraph.killsboard_rows then
            -- Увеличиваем z-позицию для scenegraph
            self._ui_scenegraph.killsboard_rows.position[3] = end_view_z + 1
        end
        -- Увеличиваем z-позицию для всех строк
        if self.row_widgets then
            for i = 1, #self.row_widgets do
                local widget = self.row_widgets[i]
                if widget and widget.offset then
                    widget.offset[3] = end_view_z + 1
                end
            end
        end
    end
end

KillstreakView.setup_row_widgets = function(self)
    -- Используем функцию get_players из Widget.lua
    local players = mod.get_players_for_killsboard()
    
    -- Если нет игроков, создаем пустой список для отображения пустого view
    if not players or not next(players) then
        players = {}
    end
    
    -- Используем общую функцию из Widget.lua
    local row_widgets, total_height = mod:setup_killsboard_row_widgets(
        self.row_widgets, 
        self._widgets_by_name, 
        players, 
        self, 
        "_create_widget", 
        self._ui_renderer
    )
    self.row_widgets = row_widgets or {}
    
    -- Устанавливаем видимость всех виджетов строк
    if self.row_widgets then
        for i = 1, #self.row_widgets do
            local widget = self.row_widgets[i]
            if widget then
                widget.alpha_multiplier = 1
                widget.visible = true
            end
        end
    end
    
    -- Устанавливаем минимальную высоту, если нет строк
    if total_height == 0 then
        total_height = 100
    end
    
    if self.killsboard_widget then
        mod:adjust_killsboard_size(total_height, self.killsboard_widget, self._ui_scenegraph, self.row_widgets)
    end
end

KillstreakView.move_killsboard = function(self, from_offset_x, to_offset_x, callback)
    -- Аналогично move_scoreboard из scoreboard
    self.killsboard_move_timer = 0.75
    self.killsboard_move_from_offset = from_offset_x
    self.killsboard_move_to_offset = to_offset_x
    self.killsboard_move_callback = callback
end

KillstreakView.update_killsboard = function(self, dt)
    if self.killsboard_move_timer then
        if self.killsboard_move_timer <= 0 then
            self:update_killsboard_offset()
            self.killsboard_move_timer = nil
            if self.killsboard_move_callback then
                self.killsboard_move_callback()
                self.killsboard_move_callback = nil
            end
        else
            local percentage = self.killsboard_move_timer / 0.75
            local range = math.abs(self.killsboard_move_to_offset) + math.abs(self.killsboard_move_from_offset)
            local t_ease = math.ease_sine(percentage)
            local done = math.lerp(0, range, t_ease)
            if self.killsboard_move_to_offset > self.killsboard_move_from_offset then
                self.killsboard_offset = self.killsboard_move_to_offset - done
            else
                self.killsboard_offset = self.killsboard_move_to_offset + done
            end
            self:update_killsboard_offset()
            self.killsboard_move_timer = self.killsboard_move_timer - dt
        end
    end
end

KillstreakView.update_killsboard_offset = function(self)
    local widgets = self._widgets_by_name
    for _, widget in pairs(widgets) do
        if widget then
            for _, style in pairs(widget.style) do
                local offset = style.original_offset or style.offset or {0, 0, 0}
                if not style.original_offset then
                    style.original_offset = table.clone(offset)
                end
                local x = self.killsboard_offset and style.original_offset[1] + self.killsboard_offset or style.original_offset[1]
                local new_offset = {x, style.original_offset[2], style.original_offset[3]}
                style.offset = new_offset
            end
        end
    end
end

KillstreakView.update = function(self, dt, t, input_service, view_data)
    self:update_killsboard(dt)
    return KillstreakView.super.update(self, dt, t, input_service)
end

KillstreakView.draw = function(self, dt, t, input_service, layer)
    self:_draw_elements(dt, t, self._ui_renderer, self._render_settings, input_service)
    self:_draw_widgets(dt, input_service)
end

KillstreakView._draw_widgets = function(self, dt, input_service)
    UIRenderer.begin_pass(self._ui_renderer, self._ui_scenegraph, input_service, dt, self._render_settings)
    
    -- Отрисовываем все виджеты из _widgets_by_name (включая killstreak и строки)
    for name, widget in pairs(self._widgets_by_name) do
        if widget then
            UIWidget.draw(widget, self._ui_renderer)
        end
    end
    
    -- Также отрисовываем виджеты строк, если они не в _widgets_by_name
    if self.row_widgets then
        for i = 1, #self.row_widgets do
            local widget = self.row_widgets[i]
            if widget then
                UIWidget.draw(widget, self._ui_renderer)
            end
        end
    end
    
    UIRenderer.end_pass(self._ui_renderer)
end

KillstreakView.on_exit = function(self)
    KillstreakView.super.on_exit(self)
end

return KillstreakView
