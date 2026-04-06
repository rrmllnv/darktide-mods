local mod = get_mod("DivisionHUD")

mod.hud_utils = mod.hud_utils or {}
local HudUtils = mod.hud_utils

function HudUtils.get_current_hud_instances()
	local ui_manager = Managers and Managers.ui

	if not ui_manager then
		return nil, nil
	end

	return ui_manager._hud, ui_manager:ui_constant_elements()
end

function HudUtils.resolve_element_instance(hud, const, class_name)
	local inst

	if hud and hud.element then
		inst = hud:element(class_name)
	end

	if not inst and const and const.element then
		inst = const:element(class_name)
	end

	return inst
end

return HudUtils
