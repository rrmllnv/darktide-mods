local mod = get_mod("DivisionHUD")

local SessionVector = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/session_vector")

if not SessionVector.can_continue() then
	return mod.hud_utils or {}
end

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

function HudUtils.resolve_mod(mod_name)
	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" or type(mod_name) ~= "string" or mod_name == "" then
		return nil
	end

	return get_mod_fn(mod_name)
end

function HudUtils.mod_is_enabled(mod_handle)
	if not mod_handle then
		return false
	end

	if type(mod_handle.is_enabled) ~= "function" then
		return true
	end

	local ok, enabled = pcall(function()
		return mod_handle:is_enabled()
	end)

	return ok and enabled == true
end

function HudUtils.is_valid_argb_255(c)
	return type(c) == "table"
		and type(c[1]) == "number"
		and type(c[2]) == "number"
		and type(c[3]) == "number"
		and type(c[4]) == "number"
end

function HudUtils.copy_argb_255(c)
	if not HudUtils.is_valid_argb_255(c) then
		return nil
	end

	return {
		c[1],
		c[2],
		c[3],
		c[4],
	}
end

local DIVISION_HUD_ELEMENT_CLASS_NAME = "HudElementDivisionHUD"
local DIVISION_HUD_CUSTOM_HUD_SAVED_PREFIX = DIVISION_HUD_ELEMENT_CLASS_NAME .. "|"

function HudUtils.resolve_division_hud_instance()
	local hud, const = HudUtils.get_current_hud_instances()

	return HudUtils.resolve_element_instance(hud, const, DIVISION_HUD_ELEMENT_CLASS_NAME)
end

function HudUtils.custom_hud_has_saved_node_settings_for_division_hud()
	local custom_hud_mod = HudUtils.resolve_mod("custom_hud")

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
	local custom_hud_mod = HudUtils.resolve_mod("custom_hud")

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

function HudUtils.safe_gameplay_time()
	local tm = Managers and Managers.time

	if not tm or type(tm.time) ~= "function" then
		return nil
	end

	local ok, t = pcall(function()
		return tm:time("gameplay")
	end)

	if ok and type(t) == "number" and t == t then
		return t
	end

	return nil
end

function HudUtils.safe_time_for_alerts()
	return HudUtils.safe_gameplay_time()
end

return HudUtils
