local mod = get_mod("TeamKills")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local base_z = 100

-- Загружаем общий виджет
mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget")

local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_settings")

local KillsboardView = class("KillsboardView", "BaseView")

KillsboardView.init = function(self, settings, context)
    self._definitions = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_definitions")
    self._settings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_settings")
    self.end_view = context and context.end_view
    
    KillsboardView.super.init(self, self._definitions, settings)
    self._pass_draw = true
    self._pass_input = true
end

KillsboardView.on_enter = function(self)
    self._definitions = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_definitions")
    self._settings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killstreak_widget_settings")
    
    KillsboardView.super.on_enter(self)
    
    -- Виджет создается автоматически из определений через super.on_enter
    self.killsboard_widget = self._widgets_by_name["killsboard"]
    if self.killsboard_widget then
        -- Устанавливаем видимость сразу, без анимации для view
        self.killsboard_widget.alpha_multiplier = 1
        self.killsboard_widget.visible = true
        if not self.end_view then
            self.killsboard_widget.offset = {0, 0, base_z}
        else
            self.killsboard_widget.offset = {0, -100, base_z}
        end
    end
    
    self.row_widgets = {}
    self:setup_row_widgets()
    
    -- В EndView нужно также сместить scenegraph killsboard_rows вместе с рамкой
    if self.end_view and self._ui_scenegraph and self._ui_scenegraph.killsboard_rows then
        -- Смещаем scenegraph на -100, чтобы компенсировать смещение рамки
        self._ui_scenegraph.killsboard_rows.position[2] = self._ui_scenegraph.killsboard_rows.position[2] - 100
    end
end

KillsboardView.setup_row_widgets = function(self)
    -- Используем функцию get_players из killstreak_widget.lua
    local players = mod.get_players_for_killsboard()
    
    -- Если нет игроков, создаем пустой список для отображения пустого view
    if not players or not next(players) then
        players = {}
    end
    
    -- Используем общую функцию из killstreak_widget.lua
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

KillsboardView.move_killsboard = function(self, from_offset_x, to_offset_x, callback)
    -- Аналогично move_scoreboard из scoreboard
    self.killsboard_move_timer = 0.75
    self.killsboard_move_from_offset = from_offset_x
    self.killsboard_move_to_offset = to_offset_x
    self.killsboard_move_callback = callback
end

KillsboardView.update_killsboard = function(self, dt)
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

KillsboardView.update_killsboard_offset = function(self)
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

KillsboardView.update = function(self, dt, t, input_service, view_data)
    self:update_killsboard(dt)
    return KillsboardView.super.update(self, dt, t, input_service)
end

KillsboardView.draw = function(self, dt, t, input_service, layer)
    self:_draw_elements(dt, t, self._ui_renderer, self._render_settings, input_service)
    self:_draw_widgets(dt, input_service)
end

KillsboardView._draw_widgets = function(self, dt, input_service)
    UIRenderer.begin_pass(self._ui_renderer, self._ui_scenegraph, input_service, dt, self._render_settings)
    
    -- Отрисовываем все виджеты из _widgets_by_name (включая killsboard и строки)
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

KillsboardView.on_exit = function(self)
    KillsboardView.super.on_exit(self)
end

return KillsboardView

