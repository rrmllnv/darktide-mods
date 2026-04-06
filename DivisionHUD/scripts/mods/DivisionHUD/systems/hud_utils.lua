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

local DIVISION_HUD_ELEMENT_CLASS_NAME = "HudElementDivisionHUD"
local DIVISION_HUD_CUSTOM_HUD_SAVED_PREFIX = DIVISION_HUD_ELEMENT_CLASS_NAME .. "|"

function HudUtils.custom_hud_has_saved_node_settings_for_division_hud()
	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" then
		return false
	end

	local custom_hud_mod = get_mod_fn("custom_hud")

	if not custom_hud_mod or type(custom_hud_mod.get) ~= "function" then
		return false
	end

	local saved = custom_hud_mod:get("saved_node_settings")

	if type(saved) ~= "table" then
		return false
	end

	local prefix_len = #DIVISION_HUD_CUSTOM_HUD_SAVED_PREFIX

	for node_name in pairs(saved) do
		if type(node_name) == "string" and string.sub(node_name, 1, prefix_len) == DIVISION_HUD_CUSTOM_HUD_SAVED_PREFIX then
			return true
		end
	end

	return false
end

local DIVISION_HUD_CUSTOM_HUD_ROOT_NODE_NAME = DIVISION_HUD_ELEMENT_CLASS_NAME .. "|root"

function HudUtils.custom_hud_get_saved_root_position_for_division_hud()
	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" then
		return nil
	end

	local custom_hud_mod = get_mod_fn("custom_hud")

	if not custom_hud_mod or type(custom_hud_mod.get) ~= "function" then
		return nil
	end

	local saved = custom_hud_mod:get("saved_node_settings")

	if type(saved) ~= "table" then
		return nil
	end

	local node = saved[DIVISION_HUD_CUSTOM_HUD_ROOT_NODE_NAME]

	if not node or type(node.x) ~= "number" or type(node.y) ~= "number" then
		return nil
	end

	return {
		x = node.x,
		y = node.y,
		z = type(node.z) == "number" and node.z or 0,
	}
end

return HudUtils
