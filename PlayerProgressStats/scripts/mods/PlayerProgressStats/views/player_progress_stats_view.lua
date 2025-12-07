local PlayerProgressStatsView = class("PlayerProgressStatsView", "BaseView")

local mod = get_mod("PlayerProgressStats")

-- 🔧 РЕЖИМ ОТЛАДКИ: установите true для отладки локализации
-- При DEBUG = true появляется дополнительная вкладка "🔍 LOCALIZATION"
-- В ней можно проверять как переводятся ключи локализации
-- Редактируйте файл: tabs/tab_localization_debug.lua
local DEBUG = true

local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local ScrollbarPassTemplates = require("scripts/ui/pass_templates/scrollbar_pass_templates")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

-- Импорт модулей вкладок
local TabGeneral = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_general")
local TabEnemies = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_enemies")
local TabMissions = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_missions")
local TabRecords = mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_records")
-- Отладочные вкладки (только если DEBUG = true)
local TabLocalizationDebug = DEBUG and mod:io_dofile("PlayerProgressStats/scripts/mods/PlayerProgressStats/views/tabs/tab_localization_debug") or nil

local Color = Color
local hud_body_font_settings = UIFontSettings.hud_body or {}

local category_panel_size = {500, 820}
local stats_panel_size = {1000, 820}
local tab_height = 64
local tab_spacing = 6
local scrollbar_width = 10
local grid_size = {stats_panel_size[1] - 140, stats_panel_size[2] - 120}
local mask_size = {grid_size[1] + 32, grid_size[2] + 32}

local stat_line_blueprint = {
    size = {grid_size[1] - 20, 34},
    size_function = function()
        return {grid_size[1] - 20, 34}
    end,
    pass_template = {
        {
            content_id = "hotspot",
            pass_type = "hotspot",
            content = {
                use_is_focused = false,
            },
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/backgrounds/default_square",
            style = {
                color = Color.terminal_background_selected(0, true),
                offset = {0, 0, 0},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local hover_progress = hotspot.anim_hover_progress or 0
                local alpha = 100 * hover_progress
                style.color[1] = alpha
            end,
        },
        {
            pass_type = "text",
            value_id = "text",
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "left",
                font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
                font_size = UIFontSettings.list_button.font_size or 24,
                text_color = Color.terminal_text_body(255, true),
                default_color = Color.terminal_text_body(255, true),
                hover_color = Color.terminal_text_header_selected(255, true),
                offset = {10, 0, 1},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local default_color = style.default_color
                local hover_color = style.hover_color
                local hover_progress = hotspot.anim_hover_progress or 0
                local color = style.text_color
                
                color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
                color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
                color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
            end,
        },
        {
            pass_type = "text",
            value_id = "value",
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "right",
                font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
                font_size = UIFontSettings.list_button.font_size or 24,
                text_color = Color.terminal_text_header(255, true),
                default_color = Color.terminal_text_header(255, true),
                hover_color = Color.terminal_text_header_selected(255, true),
                offset = {-10, 0, 1},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local default_color = style.default_color
                local hover_color = style.hover_color
                local hover_progress = hotspot.anim_hover_progress or 0
                local color = style.text_color
                
                color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
                color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
                color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
            end,
        },
    },
    init = function(_, widget, element)
        widget.content.text = element.text or ""
        widget.content.value = element.value or ""
    end,
}

-- Двухстрочный blueprint с описанием под основным текстом
local stat_line_with_description_blueprint = {
    size = {grid_size[1] - 20, 60},
    size_function = function()
        return {grid_size[1] - 20, 60}
    end,
    pass_template = {
        {
            content_id = "hotspot",
            pass_type = "hotspot",
            content = {
                use_is_focused = false,
            },
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/backgrounds/default_square",
            style = {
                color = Color.terminal_background_selected(0, true),
                offset = {0, 0, 0},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local hover_progress = hotspot.anim_hover_progress or 0
                local alpha = 100 * hover_progress
                style.color[1] = alpha
            end,
        },
        {
            pass_type = "text",
            value_id = "text",
            style = {
                text_vertical_alignment = "top",
                text_horizontal_alignment = "left",
                font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
                font_size = UIFontSettings.list_button.font_size or 24,
                text_color = Color.terminal_text_body(255, true),
                default_color = Color.terminal_text_body(255, true),
                hover_color = Color.terminal_text_header_selected(255, true),
                offset = {10, 8, 1},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local default_color = style.default_color
                local hover_color = style.hover_color
                local hover_progress = hotspot.anim_hover_progress or 0
                local color = style.text_color
                
                color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
                color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
                color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
            end,
        },
        {
            pass_type = "text",
            value_id = "value",
            style = {
                text_vertical_alignment = "top",
                text_horizontal_alignment = "right",
                font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
                font_size = UIFontSettings.list_button.font_size or 24,
                text_color = Color.terminal_text_header(255, true),
                default_color = Color.terminal_text_header(255, true),
                hover_color = Color.terminal_text_header_selected(255, true),
                offset = {-10, 8, 1},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local default_color = style.default_color
                local hover_color = style.hover_color
                local hover_progress = hotspot.anim_hover_progress or 0
                local color = style.text_color
                
                color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
                color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
                color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
            end,
        },
        {
            pass_type = "text",
            value_id = "description",
            style = {
                text_vertical_alignment = "bottom",
                text_horizontal_alignment = "left",
                font_type = "proxima_nova_bold",
                font_size = 18,
                text_color = Color.terminal_text_body_dark(180, true),
                offset = {20, -8, 1},
            },
        },
    },
    init = function(_, widget, element)
        widget.content.text = element.text or ""
        widget.content.value = element.value or ""
        widget.content.description = element.description or ""
    end,
}

local stat_header_blueprint = {
    size = {grid_size[1] - 20, 40},
    size_function = function()
        return {grid_size[1] - 20, 40}
    end,
    pass_template = {
        {
            pass_type = "text",
            value_id = "text",
            style = {
                text_vertical_alignment = "center",
                text_horizontal_alignment = "left",
                font_type = UIFontSettings.list_button.font_type or "glass_gothic_medium",
                font_size = (UIFontSettings.list_button.font_size or 24) + 6,
                text_color = Color.terminal_text_header(255, true),
                offset = {10, 0, 1},
            },
        },
    },
    init = function(_, widget, element)
        widget.content.text = element.text or ""
    end,
}

local debug_line_blueprint = {
    size = {grid_size[1] - 20, 70},
    size_function = function()
        return {grid_size[1] - 20, 70}
    end,
    pass_template = {
        {
            content_id = "hotspot",
            pass_type = "hotspot",
            content = {
                use_is_focused = false,
            },
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/backgrounds/default_square",
            style = {
                color = Color.terminal_background_selected(0, true),
                offset = {0, 0, 0},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local hover_progress = hotspot.anim_hover_progress or 0
                local alpha = 100 * hover_progress
                style.color[1] = alpha
            end,
        },
        {
            pass_type = "text",
            value_id = "text",
            style = {
                text_vertical_alignment = "top",
                text_horizontal_alignment = "left",
                font_type = UIFontSettings.list_button.font_type or "glass_gothic_medium",
                font_size = (UIFontSettings.list_button.font_size or 24) - 2,
                text_color = Color.terminal_text_body(255, true),
                default_color = Color.terminal_text_body(255, true),
                hover_color = Color.terminal_text_header_selected(255, true),
                offset = {10, 5, 1},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local default_color = style.default_color
                local hover_color = style.hover_color
                local hover_progress = hotspot.anim_hover_progress or 0
                local color = style.text_color
                
                color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
                color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
                color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
            end,
        },
        {
            pass_type = "text",
            value_id = "value",
            style = {
                text_vertical_alignment = "bottom",
                text_horizontal_alignment = "right",
                font_type = UIFontSettings.list_button.font_type or "proxima_nova_bold",
                font_size = 20,
                text_color = Color.terminal_text_header(255, true),
                default_color = Color.terminal_text_header(255, true),
                hover_color = Color.terminal_text_header_selected(255, true),
                offset = {-10, -5, 1},
            },
            change_function = function(content, style)
                local hotspot = content.hotspot
                local default_color = style.default_color
                local hover_color = style.hover_color
                local hover_progress = hotspot.anim_hover_progress or 0
                local color = style.text_color
                
                color[2] = math.lerp(default_color[2], hover_color[2], hover_progress)
                color[3] = math.lerp(default_color[3], hover_color[3], hover_progress)
                color[4] = math.lerp(default_color[4], hover_color[4], hover_progress)
            end,
        },
    },
    init = function(_, widget, element)
        widget.content.text = element.text or ""
        widget.content.value = element.value or ""
    end,
}

local blueprints = {
    stat_line = stat_line_blueprint,
    stat_line_with_description = stat_line_with_description_blueprint,
    stat_header = stat_header_blueprint,
}

-- Добавляем отладочный blueprint если DEBUG = true
if DEBUG then
    blueprints.debug_line = debug_line_blueprint
end

local tabs_definitions = {
    {key = "tab_general", fallback = "GENERAL"},
    {key = "tab_enemies", fallback = "ENEMIES"},
    {key = "tab_missions", fallback = "MISSIONS"},
    {key = "tab_records", fallback = "RECORDS"},
}

-- Добавляем отладочные вкладки если DEBUG = true
if DEBUG then
    table.insert(tabs_definitions, {key = "tab_localization_debug", fallback = "🔍 LOCALIZATION"})
end

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    dim_background = {
        parent = "screen",
        horizontal_alignment = "center",
        vertical_alignment = "center",
        size = {1920, 1080},
        position = {0, 0, -5},
    },
    background_icon = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "center",
        size = {1250, 1250},
        position = {0, 0, -4},
    },
    title_divider = {
        vertical_alignment = "top",
        parent = "screen",
        horizontal_alignment = "left",
        size = {335, 18},
        position = {180, 145, 1},
    },
    title_text = {
        vertical_alignment = "bottom",
        parent = "title_divider",
        horizontal_alignment = "left",
        size = {500, 50},
        position = {0, -35, 1},
    },
    category_panel = {
        vertical_alignment = "top",
        parent = "screen",
        horizontal_alignment = "left",
        size = category_panel_size,
        position = {140, 190, 0},
    },
    stats_panel = {
        vertical_alignment = "top",
        parent = "screen",
        horizontal_alignment = "right",
        size = stats_panel_size,
        position = {-180, 130, 0},
    },
    stats_panel_background = {
        vertical_alignment = "top",
        parent = "stats_panel",
        horizontal_alignment = "center",
        size = {stats_panel_size[1], stats_panel_size[2]},
        position = {0, 0, -1},
    },
    title = {
        vertical_alignment = "top",
        parent = "category_panel",
        horizontal_alignment = "left",
        size = {category_panel_size[1], 60},
        position = {0, -70, 2},
    },
    grid_pivot = {
        vertical_alignment = "top",
        parent = "stats_panel",
        horizontal_alignment = "left",
        size = {0, 0},
        position = {20, 20, 3},
    },
    grid_scrollbar = {
        vertical_alignment = "top",
        parent = "stats_panel",
        horizontal_alignment = "right",
        size = {scrollbar_width, stats_panel_size[2] - 60},
        position = {30, 30, 2},
    },
}

for index = 1, #tabs_definitions do
    local y = (index - 1) * (tab_height + tab_spacing)

    scenegraph_definition["tab_button_" .. index] = {
        parent = "category_panel",
        horizontal_alignment = "left",
        vertical_alignment = "top",
        size = {category_panel_size[1] - 20, tab_height},
        position = {0, y, 2},
    }
end

local title_style = table.clone(UIFontSettings.header_1 or {})
title_style.text_horizontal_alignment = "left"
title_style.text_vertical_alignment = "bottom"

local widget_definitions = {
    dim_background = UIWidget.create_definition({
        {
            pass_type = "rect",
            style = {
                color = {180, 0, 0, 0},
            },
        },
    }, "dim_background"),
    background_icon = UIWidget.create_definition({
        {
            value = "content/ui/vector_textures/symbols/cog_skull_01",
            pass_type = "slug_icon",
            style = {
                color = {80, 0, 0, 0},
            },
        },
    }, "background_icon"),
    title_divider = UIWidget.create_definition({
        {
            pass_type = "texture",
            value = "content/ui/materials/dividers/skull_rendered_left_01",
        },
    }, "title_divider"),
    title_text = UIWidget.create_definition({
        {
            value_id = "text",
            pass_type = "text",
            style = title_style,
            value = "",
        },
    }, "title_text"),
    stats_panel = UIWidget.create_definition({
        {
            pass_type = "rect",
            style = {
                color = Color.black(0, true),
            },
        },
    }, "stats_panel_background"),
    grid_scrollbar = UIWidget.create_definition(ScrollbarPassTemplates.default_scrollbar, "grid_scrollbar", {
        scroll_speed = 10,
        scroll_amount = 0.1,
    }),
}

for index = 1, #tabs_definitions do
    local widget_name = "tab_button_" .. index
    widget_definitions[widget_name] = UIWidget.create_definition(ButtonPassTemplates.list_button, "tab_button_" .. index, {
        text = tabs_definitions[index].fallback,
    })
end

local legend_inputs = {
    {
        input_action = "back",
        on_pressed_callback = "cb_on_back_pressed",
        display_name = "loc_settings_menu_close_menu",
        alignment = "left_alignment",
    },
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
    legend_inputs = legend_inputs,
}

PlayerProgressStatsView.init = function(self, settings, context)
    PlayerProgressStatsView.super.init(self, definitions, settings, context)
    self._context = context
    self._active_tab_index = 1
end

PlayerProgressStatsView.on_enter = function(self)
    PlayerProgressStatsView.super.on_enter(self)

    self:_setup_input_legend()
    self:_setup_tab_buttons()
    self:_setup_stats_grid()
    self._active_tab_index = 1
    self:_update_tab_selection()
    self:_update_title()
end

PlayerProgressStatsView._setup_tab_buttons = function(self)
    for index, tab in ipairs(tabs_definitions) do
        local button_widget = self._widgets_by_name["tab_button_" .. index]

        if button_widget then
            local success, display_name = pcall(function()
                return mod:localize(tab.key)
            end)

            if not success or not display_name or display_name == "" or display_name == tab.key then
                display_name = tab.fallback
            end

            button_widget.content.text = display_name
            button_widget.content.hotspot.pressed_callback = callback(self, "_on_tab_pressed", index)
            button_widget.content.hotspot.is_selected = (self._active_tab_index == index)
            button_widget.dirty = true
        end
    end
end

PlayerProgressStatsView._setup_stats_grid = function(self)
    local grid_settings = {
        scrollbar_width = scrollbar_width,
        grid_spacing = {0, 5},
        grid_size = grid_size,
        mask_size = mask_size,
        title_height = 0,
        edge_padding = 0,
        use_terminal_background = false,
        hide_dividers = true,
        hide_background = true,
        enable_gamepad_scrolling = true,
    }

    local layer = 10
    self._stats_grid = self:_add_element(ViewElementGrid, "stats_grid", layer, grid_settings, "grid_pivot")

    self:_update_grid_content()
end

PlayerProgressStatsView._update_tab_selection = function(self)
    for i = 1, #tabs_definitions do
        local button_widget = self._widgets_by_name["tab_button_" .. i]

        if button_widget then
            button_widget.content.hotspot.is_selected = (self._active_tab_index == i)
            button_widget.dirty = true
        end
    end
end

PlayerProgressStatsView._on_tab_pressed = function(self, index)
    self._active_tab_index = index
    self:_update_tab_selection()
    self:_update_grid_content()
end

PlayerProgressStatsView._update_title = function(self)
    local title_widget = self._widgets_by_name.title_text

    if not title_widget then
        return
    end

    local success, title_text = pcall(function()
        return mod:localize("stats_title")
    end)

    if success and title_text and title_text ~= "" then
        title_widget.content.text = title_text
    else
        title_widget.content.text = "PLAYER STATISTICS"
    end

    title_widget.dirty = true
end

PlayerProgressStatsView._update_grid_content = function(self)
    if not self._stats_grid then
        return
    end

    local layout = self:_create_stat_layout()
    self._stats_grid:present_grid_layout(layout, blueprints)
end

PlayerProgressStatsView._create_stat_layout = function(self)
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
        -- Сначала пытаемся использовать официальную локализацию игры
        if key:match("^loc_") then
            local success, result = pcall(function()
                return Localize(key)
            end)
            
            if success and result and result ~= "" and result ~= key then
                return result
            end
        end
        
        -- Если не получилось, используем локализацию мода
        local success, result = pcall(function()
            return mod:localize(key)
        end)

        if success and result and result ~= "" then
            return result
        end

        return key
    end

    local tab_index = self._active_tab_index or 1
    
    -- Вызываем соответствующий модуль вкладки
    if tab_index == 1 then
        return TabGeneral.create_layout(safe_read_stat, localize, format_number)
    elseif tab_index == 2 then
        return TabEnemies.create_layout(safe_read_stat, localize, format_number)
    elseif tab_index == 3 then
        return TabMissions.create_layout(safe_read_stat, localize, format_number)
    elseif tab_index == 4 then
        return TabRecords.create_layout(safe_read_stat, localize, format_number)
    elseif DEBUG then
        if tab_index == 5 and TabLocalizationDebug then
            return TabLocalizationDebug.create_layout(safe_read_stat, localize, format_number)
        end
    end
    
    return {}
end

PlayerProgressStatsView._setup_input_legend = function(self)
    self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
    local legend_inputs = definitions.legend_inputs

    for i = 1, #legend_inputs do
        local legend_input = legend_inputs[i]
        local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)

        self._input_legend_element:add_entry(legend_input.display_name, legend_input.input_action, legend_input.visibility_function, on_pressed_callback, legend_input.alignment)
    end
end

PlayerProgressStatsView.cb_on_back_pressed = function(self)
    if Managers and Managers.ui then
        Managers.ui:close_view(self.view_name)
    end
end

PlayerProgressStatsView.update = function(self, dt, t, input_service)
    if Managers and Managers.ui and Managers.ui:view_instance("dmf_options_view") then
        Managers.ui:close_view(self.view_name)

        return
    end

    PlayerProgressStatsView.super.update(self, dt, t, input_service)

    if input_service and input_service:get("back_released") then
        if Managers and Managers.ui then
            Managers.ui:close_view(self.view_name)
        end
    end
end

PlayerProgressStatsView.on_exit = function(self)
    if self._input_legend_element then
        self._input_legend_element = nil
        self:_remove_element("input_legend")
    end
    
    PlayerProgressStatsView.super.on_exit(self)
end

return PlayerProgressStatsView

