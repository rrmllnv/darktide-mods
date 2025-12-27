-- chunkname: @scripts/ui/views/aggregatum_view/aggregatum_view.lua

require("scripts/ui/views/base_view")

local mod = get_mod("EffectAggregate")
local Definitions = require("EffectAggregate/scripts/mods/EffectAggregate/Views/aggregatum_view_definitions")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")

local AggregatumView = class("AggregatumView", "BaseView")

AggregatumView.init = function (self, settings, context)
	self._context = context

	local player = context and context.player or Managers.player:local_player(1)

	if not player or player.__deleted then
		return
	end

	AggregatumView.super.init(self, Definitions, settings, context)

	self._pass_input = false
	self._pass_draw = false
end

AggregatumView.on_enter = function (self)
	AggregatumView.super.on_enter(self)

	self:_setup_input_legend()
end

AggregatumView.on_exit = function (self)
	AggregatumView.super.on_exit(self)
end

AggregatumView.update = function (self, dt, t, input_service)
	return AggregatumView.super.update(self, dt, t, input_service)
end

AggregatumView.draw = function (self, dt, t, input_service, layer)
	return AggregatumView.super.draw(self, dt, t, input_service, layer)
end

AggregatumView._setup_input_legend = function (self)
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)

	local definitions = self._definitions
	local legend_inputs = definitions and definitions.legend_inputs

	if not legend_inputs then
		return
	end

	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)

		self._input_legend_element:add_entry(legend_input.display_name, legend_input.input_action, legend_input.visibility_function, on_pressed_callback, legend_input.alignment)
	end
end

AggregatumView._handle_back_pressed = function (self)
	local view_name = "aggregatum_view"

	Managers.ui:close_view(view_name)
end

AggregatumView.cb_on_close_pressed = function (self)
	self:_handle_back_pressed()
end

return AggregatumView
