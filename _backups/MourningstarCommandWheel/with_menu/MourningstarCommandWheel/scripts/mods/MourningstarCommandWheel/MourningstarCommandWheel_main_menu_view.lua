local mod = get_mod("MourningstarCommandWheel")

local Promise = require("scripts/foundation/utilities/promise")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local definitions = mod:io_dofile("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_main_menu_view_definitions")

local _is_view_loading = false

local MourningstarCommandWheelMainMenuView = class("MourningstarCommandWheelMainMenuView", "BaseView")

MourningstarCommandWheelMainMenuView.init = function(self, settings)
	MourningstarCommandWheelMainMenuView.super.init(self, definitions, settings)
end

MourningstarCommandWheelMainMenuView.on_enter = function(self)
	MourningstarCommandWheelMainMenuView.super.on_enter(self)
	
	self:_setup_input_legend()
	self:_setup_buttons()
end

MourningstarCommandWheelMainMenuView._setup_input_legend = function(self)
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 100)
	local legend_inputs = definitions.legend_inputs

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

MourningstarCommandWheelMainMenuView._setup_buttons = function(self)
	local button_definitions = definitions.button_definitions
	
	for _, button_def in ipairs(button_definitions) do
		local widget = self._widgets_by_name[button_def.name]
		if widget then
			local content = widget.content
			if content and content.hotspot then
				content.hotspot.pressed_callback = function()
					self:_open_view(button_def.view_name)
				end
			end
		end
	end
end

MourningstarCommandWheelMainMenuView._open_view = function(self, view_name)
	-- Некоторые view не могут быть открыты из главного меню
	-- havoc_background_view требует наличия player_unit_spawn, который доступен только в хабе
	local views_not_available_in_main_menu = {
		["havoc_background_view"] = true,
	}
	
	if views_not_available_in_main_menu[view_name] then
		-- mod:warning("View '%s' cannot be opened from main menu", view_name)
		return
	end
	
	local character_id = Managers.player:local_player(1):profile().character_id
	local narrative_promise = Managers.narrative:load_character_narrative(character_id)

	if not _is_view_loading then
		_is_view_loading = true

		Promise.all(narrative_promise):next(function(_)
			_is_view_loading = false

			-- Закрываем текущее view
			Managers.ui:close_view("mourningstar_command_wheel_main_menu_view")
			
			-- Открываем нужное view
			Managers.ui:open_view(view_name, nil, nil, nil, nil, {
				hub_interaction = true,
			})
		end):catch(function()
			_is_view_loading = false
			return
		end)
	end
end

MourningstarCommandWheelMainMenuView._on_back_pressed = function(self)
	Managers.ui:close_view(self.view_name)
end

return MourningstarCommandWheelMainMenuView

