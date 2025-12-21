local mod = get_mod("IconPathViewer")
local ScriptWorld = require("scripts/foundation/utilities/script_world")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local definitions = mod:io_dofile("IconPathViewer/scripts/mods/IconPathViewer/icon_path_viewer_view/icon_path_viewer_view_definitions")

IconPathViewerView = class("IconPathViewerView", "BaseView")

IconPathViewerView.init = function(self, settings)
	IconPathViewerView.super.init(self, definitions, settings)
end

IconPathViewerView.on_enter = function(self)
	IconPathViewerView.super.on_enter(self)
	self:_setup_input_legend()
	self:_setup_grid()
end

IconPathViewerView._setup_input_legend = function(self)
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 100)
	local legend_inputs = self._definitions.legend_inputs

	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)

		self._input_legend_element:add_entry(
			legend_input.display_name,
			legend_input.input_action,
			legend_input.visibility_function,
			on_pressed_callback,
			legend_input.alignment
		)
	end
end

IconPathViewerView._setup_grid = function(self)
	self._icon_table_element = self:_add_element(ViewElementGrid, "icon_table", 103, definitions.grid_settings, "icon_table_pivot")
	self._icon_table_element:set_visibility(true)
	self._icon_table_element:present_grid_layout({}, {})
	
	local layout = {}
	
	-- Получаем пути иконок из BetterLoadouts или используем встроенный список
	local icon_paths = {}
	local icon_paths_lookup = {}
	
	-- Пробуем получить пути из настроек игры (как в BetterLoadouts)
	local success, ViewElementProfilePresetsSettings = pcall(require, "scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_settings")
	if success and ViewElementProfilePresetsSettings then
		local ref = ViewElementProfilePresetsSettings and ViewElementProfilePresetsSettings.optional_preset_icon_reference_keys or {}
		local lu = ViewElementProfilePresetsSettings and ViewElementProfilePresetsSettings.optional_preset_icons_lookup or {}
		
		for i = 1, #ref do
			local vk = ref[i]
			local vmat = lu[vk]
			if vk and vmat and not icon_paths_lookup[vk] then
				icon_paths[#icon_paths + 1] = vmat
				icon_paths_lookup[vk] = true
			end
		end
	end
	
	-- Пробуем получить пути из BetterLoadouts
	local better_loadouts_mod = get_mod("BetterLoadouts")
	if better_loadouts_mod and better_loadouts_mod.BL and better_loadouts_mod.BL.DEFAULT_CUSTOM_ICON_PATHS then
		for i = 1, #better_loadouts_mod.BL.DEFAULT_CUSTOM_ICON_PATHS do
			local path = better_loadouts_mod.BL.DEFAULT_CUSTOM_ICON_PATHS[i]
			if path and type(path) == "string" and path ~= "" and not icon_paths_lookup[path] then
				-- Пропускаем закомментированные пути
				if not string.match(path, "^%s*%-%-") then
					icon_paths[#icon_paths + 1] = path
					icon_paths_lookup[path] = true
				end
			end
		end
		mod:info("Loaded %d icon paths from BetterLoadouts", #icon_paths)
	end
	
	-- Если ничего не найдено, используем встроенный список
	if #icon_paths == 0 then
		icon_paths = {
			"content/ui/materials/icons/item_types/ranged_weapons",
			"content/ui/materials/icons/circumstances/assault_01",
			"content/ui/materials/icons/item_types/weapons",
			"content/ui/materials/icons/item_types/melee_weapons",
			"content/ui/materials/hud/interactions/icons/grenade",
			"content/ui/materials/icons/circumstances/hunting_grounds_01",
			"content/ui/materials/icons/circumstances/ventilation_purge_01",
			"content/ui/materials/icons/circumstances/nurgle_manifestation_01",
			"content/ui/materials/icons/pocketables/hud/scripture",
			"content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
		}
		mod:info("Using built-in icon paths list (%d paths)", #icon_paths)
	end
	
	-- Создаем layout для каждой иконки
	for i = 1, #icon_paths do
		local icon_path = icon_paths[i]
		if icon_path and type(icon_path) == "string" and icon_path ~= "" then
			-- Пропускаем закомментированные пути
			if not string.match(icon_path, "^%s*%-%-") then
				layout[#layout + 1] = {
					widget_type = "icon_box",
					icon_index = i,
					icon_path = icon_path,
					icon_path_short = string.match(icon_path, "([^/]+)$") or icon_path,
				}
			end
		end
	end

	local spacing_entry = {
		widget_type = "spacing_vertical"
	}

	table.insert(layout, 1, spacing_entry)
	table.insert(layout, #layout + 1, spacing_entry)

	local left_click_callback = callback(self, "cb_on_icon_left_pressed")

	self._icon_table_element:present_grid_layout(layout, definitions.blueprints, left_click_callback)
end

IconPathViewerView.cb_on_icon_left_pressed = function(self, widget, element)
	if widget and widget.content and widget.content.icon_path then
		Clipboard.put(widget.content.icon_path)
		mod:notify(mod:localize("msg_copied_path", widget.content.icon_path))
	end
end

IconPathViewerView._on_back_pressed = function(self)
	Managers.ui:close_view(self.view_name)
end

IconPathViewerView._destroy_renderer = function(self)
	if self._offscreen_renderer then
		self._offscreen_renderer = nil
	end

	local world_data = self._offscreen_world

	if world_data then
		Managers.ui:destroy_renderer(world_data.renderer_name)
		ScriptWorld.destroy_viewport(world_data.world, world_data.viewport_name)
		Managers.ui:destroy_world(world_data.world)

		world_data = nil
	end
end

IconPathViewerView.update = function(self, dt, t, input_service)
	return IconPathViewerView.super.update(self, dt, t, input_service)
end

IconPathViewerView.draw = function(self, dt, t, input_service, layer)
	return IconPathViewerView.super.draw(self, dt, t, input_service, layer)
end

IconPathViewerView._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	IconPathViewerView.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

IconPathViewerView.on_exit = function(self)
	IconPathViewerView.super.on_exit(self)

	self:_destroy_renderer()
end

return IconPathViewerView

