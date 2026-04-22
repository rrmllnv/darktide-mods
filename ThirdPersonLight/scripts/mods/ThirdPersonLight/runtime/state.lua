local mod = get_mod("ThirdPersonLight")

if type(mod.tpl_state) == "table" then
	return mod.tpl_state
end

local State = {}

local SUPPORTED_GAME_MODES = {
	coop_complete_objective = true,
	shooting_range = true,
	expedition = true,
	survival = true,
}

local DARK_MUTATOR = "mutator_darkness_los"

local _is_dark_mission_cached = false
local _is_dark_mission_dirty = true

State.settings = {
	enable_mod = true,
	only_dark_missions = true,
	enable_player_light = true,
	flashlight_mode = false,
	flicker_mode = false,
	light_radius = 10,
	light_intensity = 20,
	color = { r = 1, g = 1, b = 1 },
}

local function _read_color()
	local r = tonumber(mod:get("light_color_r")) or 255
	local g = tonumber(mod:get("light_color_g")) or 255
	local b = tonumber(mod:get("light_color_b")) or 255

	return { r = r / 255, g = g / 255, b = b / 255 }
end

function State.refresh()
	local s = State.settings

	s.enable_mod = mod:get("enable_mod") ~= false
	s.only_dark_missions = mod:get("only_dark_missions") ~= false
	s.enable_player_light = mod:get("enable_player_light") ~= false
	s.flashlight_mode = mod:get("flashlight_mode") == true
	s.flicker_mode = mod:get("flicker_mode") == true
	s.light_radius = tonumber(mod:get("light_radius")) or 10
	s.light_intensity = tonumber(mod:get("light_intensity")) or 20
	s.color = _read_color()
end

function State.invalidate_dark_mission()
	_is_dark_mission_dirty = true
end

local function _calc_dark_mission()
	local state_mgr = Managers.state
	local circumstance = state_mgr and state_mgr.circumstance

	if not circumstance or not circumstance.template then
		return false
	end

	local template = circumstance:template()

	if not template or not template.mutators then
		return false
	end

	for _, mutator in pairs(template.mutators) do
		if mutator == DARK_MUTATOR then
			return true
		end
	end

	return false
end

function State.is_dark_mission()
	if _is_dark_mission_dirty then
		_is_dark_mission_cached = _calc_dark_mission()
		_is_dark_mission_dirty = false
	end

	return _is_dark_mission_cached
end

local function _game_mode_name()
	local state_mgr = Managers.state
	local gm = state_mgr and state_mgr.game_mode

	if not gm or not gm.game_mode_name then
		return nil
	end

	return gm:game_mode_name()
end

function State.is_in_hub()
	return _game_mode_name() == "hub"
end

function State.is_supported_mode()
	local name = _game_mode_name()

	if not name then
		return false
	end

	return SUPPORTED_GAME_MODES[name] == true
end

function State.can_show_light()
	local s = State.settings

	if not s.enable_mod then
		return false
	end

	if not s.enable_player_light then
		return false
	end

	if State.is_in_hub() then
		return false
	end

	if s.only_dark_missions and not State.is_dark_mission() then
		return false
	end

	return true
end

State.refresh()

mod.tpl_state = State

return State
