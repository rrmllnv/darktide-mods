local mod = get_mod("MelksContractTimer")

local function _is_enabled()
	return mod:get("enabled") ~= false
end

local function _contracts_time_left_seconds(tactical_overlay_instance, t)
	if not Managers or not Managers.backend or not Managers.backend.get_server_time then
		return -1
	end

	local contract_data = tactical_overlay_instance and tactical_overlay_instance._contract_data
	local refresh_time_ms = contract_data and contract_data.refreshTime

	if not refresh_time_ms then
		return -1
	end

	local server_time_ms = Managers.backend:get_server_time(t)

	if not server_time_ms then
		return -1
	end

	return (refresh_time_ms - server_time_ms) / 1000
end

mod:hook("HudElementTacticalOverlay", "_update_right_timer", function(func, self, ...)
	func(self, ...)

	if not _is_enabled() then
		return
	end

	if not self or self._right_panel_key ~= "contracts" then
		return
	end

	local contract_data = self._contract_data

	if not contract_data or not contract_data.refreshTime then
		return
	end

	local widgets_by_name = self._widgets_by_name
	local timer_widget = widgets_by_name and widgets_by_name.right_timer

	if not timer_widget then
		return
	end

	self._last_seen_time = nil
	self._right_timer_function = function(t)
		return _contracts_time_left_seconds(self, t)
	end

	timer_widget.visible = true
	timer_widget.content.time_name = mod:localize("contracts_time_left_label")
	timer_widget.content.time_left = ""
end)

