local mod = get_mod("IconPathViewer")
local ScriptWorld = require("scripts/foundation/utilities/script_world")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local definitions = mod:io_dofile("IconPathViewer/scripts/mods/IconPathViewer/icon_path_viewer_view/icon_path_viewer_view_definitions")

-- Конвертация Unicode кодов в символы (ТОЧНАЯ КОПИЯ из BetterLoadouts)
local bytemarkers = { { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } }
local function utf8(decimal)
	if decimal < 128 then return string.char(decimal) end
	local charbytes = {}
	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local rem = decimal % 64
				decimal = (decimal - rem) / 64
				charbytes[b] = string.char(128 + rem)
			end
			charbytes[1] = string.char(vals[2] + decimal)
			break
		end
	end
	return table.concat(charbytes)
end

-- Дополнительные Unicode коды для иконок (ТОЧНАЯ КОПИЯ из BetterLoadouts)
local UNICODE_EXTRA_CODES = {
	0xE000, 0xE001, 0xE002, 0xE003, 0xE004, 0xE005, 0xE006, 0xE007,
	0xE01F, 0xE021, 0xE026, 0xE029, 0xE02E, 0xE041, 0xE042, 0xE045,
	0xE046, 0xE049, 0xE04D, 0xE04F, 0xE051, 0xE107, 0xE108, 0xE109,
	0xE10A, 0xE010, 0xE011, 0xE012, 0xE013, 0xE014, 0xE015, 0xE016,
	0xE017, 0xE018, 0xE019,
}

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
	
	-- ТОЧНАЯ КОПИЯ логики из BetterLoadouts
	local ViewElementProfilePresetsSettings = require("scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_settings")
	
	-- Private preset-icons pool (как в BetterLoadouts)
	local PRIVATE_ICON_LOOKUP, PRIVATE_ICON_KEYS = {}, {}
	
	-- Функция регистрации (как в BetterLoadouts)
	local function _register_private(list)
		for i = 1, #list do
			local key = list[i]
			if key and not PRIVATE_ICON_LOOKUP[key] then
				PRIVATE_ICON_LOOKUP[key] = key
				PRIVATE_ICON_KEYS[#PRIVATE_ICON_KEYS + 1] = key
			end
		end
	end
	
	-- Функция заполнения (ТОЧНАЯ КОПИЯ из BetterLoadouts)
	local function _seed_private_from_vanilla_then_custom()
		local S   = ViewElementProfilePresetsSettings
		local ref = S and S.optional_preset_icon_reference_keys or {}
		local lu  = S and S.optional_preset_icons_lookup or {}

		-- Сначала добавляем все из reference_keys (как в BetterLoadouts)
		for i = 1, #ref do
			local vk   = ref[i]
			local vmat = lu[vk]
			if vk and vmat and not PRIVATE_ICON_LOOKUP[vk] then
				PRIVATE_ICON_LOOKUP[vk] = vmat
				PRIVATE_ICON_KEYS[#PRIVATE_ICON_KEYS + 1] = vk
			end
		end
		
		-- Также добавляем ВСЕ ключи из lookup (на случай если там больше, чем в reference_keys)
		if lu then
			for vk, vmat in pairs(lu) do
				if vk and vmat and not PRIVATE_ICON_LOOKUP[vk] then
					PRIVATE_ICON_LOOKUP[vk] = vmat
					PRIVATE_ICON_KEYS[#PRIVATE_ICON_KEYS + 1] = vk
				end
			end
		end

		-- Встроенный список путей (скопирован из BetterLoadouts/constants.lua)
		local DEFAULT_CUSTOM_ICON_PATHS = {
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
		_register_private(DEFAULT_CUSTOM_ICON_PATHS)
	end
	
	_seed_private_from_vanilla_then_custom()

	mod:info("PRIVATE_ICON_KEYS count: %d", #PRIVATE_ICON_KEYS)

	-- Создаем layout ТОЧНО как в BetterLoadouts (строки 150-157)
	local layout = {}
	for i = 1, #PRIVATE_ICON_KEYS do
		local key = PRIVATE_ICON_KEYS[i]
		local mat = PRIVATE_ICON_LOOKUP[key]
		if mat then
			layout[#layout + 1] = {
				widget_type = "icon_box",
				icon_index = i,
				icon_key = key,
				icon = mat, -- Материал (путь к иконке) для отображения
				icon_path = mat, -- Материал (путь к иконке) для копирования
				icon_path_short = string.match(key, "([^/]+)$") or key,
			}
		end
	end

	-- Добавляем Unicode глифы (ТОЧНАЯ КОПИЯ логики из BetterLoadouts profile_presets_present_grid.lua)
	local function make_unicode(cp)
		local key = string.format("unicode:%X", cp)
		return {
			widget_type = "unicode_icon",
			text = utf8(cp),
			icon_key = key,
			unicode_text = utf8(cp),
			unicode_code = string.format("U+%04X", cp),
		}
	end

	-- Добавляем дополнительные Unicode коды
	for i = 1, #UNICODE_EXTRA_CODES do
		layout[#layout + 1] = make_unicode(UNICODE_EXTRA_CODES[i])
	end

	-- Также добавляем глобальные Unicode коды (если есть)
	local G = _G.UNICODE_PRESET_CODES
	if G then
		for i = 1, #G do
			layout[#layout + 1] = make_unicode(G[i])
		end
	end

	mod:info("Layout entries count: %d (including %d unicode icons)", #layout, #UNICODE_EXTRA_CODES + (G and #G or 0))

	local spacing_entry = {
		widget_type = "spacing_vertical"
	}

	table.insert(layout, 1, spacing_entry)
	table.insert(layout, #layout + 1, spacing_entry)

	local left_click_callback = callback(self, "cb_on_icon_left_pressed")

	self._icon_table_element:present_grid_layout(layout, definitions.blueprints, left_click_callback)
	
	mod:info("Loaded %d icons from BetterLoadouts logic", #PRIVATE_ICON_KEYS)
end

IconPathViewerView.cb_on_icon_left_pressed = function(self, widget, element)
	if widget and widget.content then
		local content = widget.content
		-- Для Unicode глифов копируем Unicode код
		if content.unicode_code and element.widget_type == "unicode_icon" then
			Clipboard.put(content.unicode_code)
			mod:notify(mod:localize("msg_copied_path", content.unicode_code))
		-- Для обычных иконок копируем путь
		elseif content.icon_path then
			Clipboard.put(content.icon_path)
			mod:notify(mod:localize("msg_copied_path", content.icon_path))
		end
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

