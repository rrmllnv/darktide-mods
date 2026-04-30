local mod = get_mod("SquadHud")

if mod._squadhud_debug_hooked then
	return mod
end

mod._squadhud_debug_hooked = true

local DEBUG_LONG_PLAYER_NAME = "SquadHudDebugVeryLongNicknameForMarqueeMaskTesting"
local DEBUG_RELATION_STATUS = "999m"

local debug_state = {
	long_name_enabled = false,
	relation_status_enabled = false,
	toughness_hit_indicator_next_armor_break = false,
	toughness_hit_indicator_request = nil,
}

local function debug_enabled()
	return mod:get("debug") == true
end

local function clear_debug_state()
	debug_state.long_name_enabled = false
	debug_state.relation_status_enabled = false
	debug_state.toughness_hit_indicator_next_armor_break = false
	debug_state.toughness_hit_indicator_request = nil
end

local function key_pressed(key_name)
	if type(key_name) ~= "string" or key_name == "" then
		return false
	end

	local key_index = Keyboard.button_index(key_name)

	if not key_index then
		return false
	end

	return Keyboard.pressed(key_index)
end

mod.squadhud_debug_apply_settings = function(setting_id)
	if setting_id ~= "debug" and setting_id ~= "squadhud_reset_all_settings" then
		return
	end

	if not debug_enabled() then
		clear_debug_state()
	end
end

mod.squadhud_debug_update = function()
	if not debug_enabled() then
		clear_debug_state()

		return
	end

	if key_pressed("numpad 1") then
		debug_state.long_name_enabled = not debug_state.long_name_enabled
	end

	if key_pressed("numpad 2") then
		debug_state.relation_status_enabled = not debug_state.relation_status_enabled
	end

	if key_pressed("numpad 5") then
		debug_state.toughness_hit_indicator_request = {
			armor_break = debug_state.toughness_hit_indicator_next_armor_break == true,
		}
		debug_state.toughness_hit_indicator_next_armor_break = debug_state.toughness_hit_indicator_next_armor_break ~= true
	end
end

mod.squadhud_debug_player_name = function(base_name, is_local_player)
	if not debug_enabled() or not debug_state.long_name_enabled or not is_local_player then
		return base_name
	end

	return DEBUG_LONG_PLAYER_NAME
end

mod.squadhud_debug_relation_status = function(relation_status, is_local_player)
	if not debug_enabled() or not debug_state.relation_status_enabled or not is_local_player then
		return relation_status
	end

	return DEBUG_RELATION_STATUS
end

mod.squadhud_debug_consume_toughness_hit_indicator_request = function(is_local_player)
	if not debug_enabled() or not is_local_player then
		return nil
	end

	local request = debug_state.toughness_hit_indicator_request

	debug_state.toughness_hit_indicator_request = nil

	return request
end

return mod
