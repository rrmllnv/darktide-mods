-- Auspex Wayfinder: navmesh path via GwNavAStar (same pattern as BotNavigationExtension.move_to / _update_astar).
-- Does not create or destroy NavMeshManager.client_traverse_logic.

local NavQueries = require("scripts/utilities/nav_queries")
local MainPathQueries = require("scripts/utilities/main_path_queries")

local Pathfinder = {}

local _mod_ref = nil
local _astar = nil
local _running = false
local _astar_cancelled = false
local _queued_goal = nil
local _path_points = {}
local _last_fail_echoed = false
local _poi_goal_box = nil
local _nav_search_mode = nil

local NAV_MESH_CHECK_ABOVE = 0.75
local NAV_MESH_CHECK_BELOW = 0.5
local LAST_NODE_NAV_MESH_CHECK_ABOVE = 0.3
local LAST_NODE_NAV_MESH_CHECK_BELOW = 0.3
local GOAL_SNAP_ABOVE = 10
local GOAL_SNAP_BELOW = 10
local GOAL_HORIZONTAL_SEARCH = 30
local GOAL_DISTANCE_FROM_OBSTACLE = 5
local START_GUARANTEED_HORIZONTAL = 12
local START_GUARANTEED_OBSTACLE = 3

function Pathfinder.init(mod_instance)
	_mod_ref = mod_instance
end

local function _get_propagation_extent()
	if not _mod_ref or not _mod_ref.get then
		return 120
	end
	local v = tonumber(_mod_ref:get("path_propagation_box"))
	if not v or v < 1 then
		return 120
	end
	return v
end

function Pathfinder.destroy_astar()
	table.clear(_path_points)
	_queued_goal = nil
	_running = false
	_astar_cancelled = false
	_last_fail_echoed = false

	if _astar and GwNavAStar then
		if GwNavAStar.processing_finished and not GwNavAStar.processing_finished(_astar) then
			pcall(GwNavAStar.cancel, _astar)
		end
		pcall(GwNavAStar.destroy, _astar)
	end

	_astar = nil
	_nav_search_mode = nil
	_poi_goal_box = nil
end

function Pathfinder.clear_path_only()
	table.clear(_path_points)
	_last_fail_echoed = false
end

function Pathfinder.cancel_computation()
	_queued_goal = nil
	_last_fail_echoed = false
	_nav_search_mode = nil

	if not _astar or not GwNavAStar then
		_running = false
		return
	end

	if _running and GwNavAStar.processing_finished and not GwNavAStar.processing_finished(_astar) then
		pcall(GwNavAStar.cancel, _astar)
		_running = false
		_astar_cancelled = true
	elseif _running then
		_running = false
	end
end

local function _ensure_astar()
	if _astar or not GwNavAStar or not GwNavAStar.create then
		return _astar ~= nil
	end

	local ok, inst = pcall(GwNavAStar.create)

	if ok and inst then
		_astar = inst
		return true
	end

	return false
end

local function _nav_world_and_traverse()
	local nav_mesh = Managers.state and Managers.state.nav_mesh

	if not nav_mesh or not nav_mesh.nav_world or not nav_mesh.client_traverse_logic then
		return nil, nil
	end

	local nav_world = nav_mesh:nav_world()
	local traverse_logic = nav_mesh:client_traverse_logic()

	if not nav_world or not traverse_logic then
		return nil, nil
	end

	return nav_world, traverse_logic
end

local function _project_on_mesh(nav_world, traverse_logic, position)
	if not position then
		return nil
	end

	if NavQueries.position_on_mesh then
		return NavQueries.position_on_mesh(nav_world, position, NAV_MESH_CHECK_ABOVE, NAV_MESH_CHECK_BELOW, traverse_logic)
	end

	return nil
end

local function _snap_player_start(nav_world, traverse_logic, raw)
	if not raw then
		return nil
	end

	local on_mesh = _project_on_mesh(nav_world, traverse_logic, raw)

	if on_mesh then
		return on_mesh
	end

	if NavQueries.position_on_mesh_with_outside_position then
		local p = NavQueries.position_on_mesh_with_outside_position(
			nav_world,
			traverse_logic,
			raw,
			NAV_MESH_CHECK_ABOVE,
			NAV_MESH_CHECK_BELOW,
			1,
			1
		)

		if p then
			return p
		end
	end

	if NavQueries.position_on_mesh_guaranteed then
		return NavQueries.position_on_mesh_guaranteed(
			nav_world,
			raw,
			NAV_MESH_CHECK_ABOVE,
			NAV_MESH_CHECK_BELOW,
			traverse_logic,
			START_GUARANTEED_HORIZONTAL,
			START_GUARANTEED_OBSTACLE
		)
	end

	return raw
end

local function _snap_expedition_goal(nav_world, traverse_logic, raw)
	if not raw then
		return nil
	end

	local on_mesh = _project_on_mesh(nav_world, traverse_logic, raw)

	if on_mesh then
		return on_mesh
	end

	if NavQueries.position_on_mesh_guaranteed then
		local g = NavQueries.position_on_mesh_guaranteed(
			nav_world,
			raw,
			GOAL_SNAP_ABOVE,
			GOAL_SNAP_BELOW,
			traverse_logic,
			GOAL_HORIZONTAL_SEARCH,
			GOAL_DISTANCE_FROM_OBSTACLE
		)

		if g then
			return g
		end
	end

	if NavQueries.position_on_mesh_with_outside_position then
		local p = NavQueries.position_on_mesh_with_outside_position(
			nav_world,
			traverse_logic,
			raw,
			GOAL_SNAP_ABOVE,
			GOAL_SNAP_BELOW,
			2,
			2
		)

		if p then
			return p
		end
	end

	return raw
end

local function _goal_on_main_path(poi_world_position)
	if not poi_world_position then
		return nil
	end

	if not MainPathQueries or not MainPathQueries.is_main_path_registered or not MainPathQueries.closest_position then
		return nil
	end

	local ok_reg, registered = pcall(MainPathQueries.is_main_path_registered)

	if not ok_reg or not registered then
		return nil
	end

	local ok_closest, closest_pos = pcall(MainPathQueries.closest_position, poi_world_position, nil, nil)

	if not ok_closest or not closest_pos then
		return nil
	end

	local nav_world, traverse_logic = _nav_world_and_traverse()

	if not nav_world then
		return closest_pos
	end

	return _snap_expedition_goal(nav_world, traverse_logic, closest_pos) or closest_pos
end

local function _fail_echo()
	if not _mod_ref or (_mod_ref.get and _mod_ref:get("path_echo_on_fail") == false) then
		return
	end

	if _last_fail_echoed then
		return
	end

	_last_fail_echoed = true

	if _mod_ref.echo and _mod_ref.localize then
		_mod_ref:echo(_mod_ref:localize("path_failed_echo"))
	end
end

local function _try_start_path(goal_vector3, use_full_map_search, mode_override)
	if not goal_vector3 or not Vector3 then
		return false
	end

	if _astar_cancelled then
		return false
	end

	if not _ensure_astar() then
		return false
	end

	local nav_world, traverse_logic = _nav_world_and_traverse()

	if not nav_world then
		return false
	end

	local local_player = Managers.player and Managers.player:local_player(1)
	local player_unit = local_player and local_player.player_unit

	if not player_unit or not ALIVE[player_unit] or not POSITION_LOOKUP then
		return false
	end

	local start_raw = POSITION_LOOKUP[player_unit]
	local start_pos = _snap_player_start(nav_world, traverse_logic, start_raw) or start_raw
	local goal_pos = _snap_expedition_goal(nav_world, traverse_logic, goal_vector3) or goal_vector3

	local same_spot = false

	if Vector3.equal then
		same_spot = Vector3.equal(start_pos, goal_pos)
	else
		same_spot = Vector3.length_squared(goal_pos - start_pos) < 0.0001
	end

	if same_spot then
		local zh = tonumber(_mod_ref and _mod_ref.get and _mod_ref:get("path_height")) or 0.25

		table.clear(_path_points)
		_path_points[1] = Vector3(start_pos.x, start_pos.y, start_pos.z + zh)
		_nav_search_mode = nil

		return true
	end

	local ok_start

	if use_full_map_search and GwNavAStar.start then
		_nav_search_mode = mode_override or "full"
		ok_start = pcall(GwNavAStar.start, _astar, nav_world, start_pos, goal_pos, traverse_logic)
	else
		_nav_search_mode = "box"
		local extent = _get_propagation_extent()

		ok_start = pcall(GwNavAStar.start_with_propagation_box, _astar, nav_world, start_pos, goal_pos, extent, traverse_logic)
	end

	if ok_start then
		_running = true
		_last_fail_echoed = false
	else
		_nav_search_mode = nil
		_fail_echo()
	end

	return true
end

function Pathfinder.request_path_to_goal(goal_vector3)
	table.clear(_path_points)
	_last_fail_echoed = false
	_nav_search_mode = nil

	if not goal_vector3 then
		Pathfinder.cancel_computation()
		return
	end

	if not _poi_goal_box then
		_poi_goal_box = Vector3Box(0, 0, 0)
	end

	_poi_goal_box:store(goal_vector3)

	if _running and _astar and GwNavAStar and GwNavAStar.processing_finished and not GwNavAStar.processing_finished(_astar) then
		_queued_goal = goal_vector3
		pcall(GwNavAStar.cancel, _astar)
		_running = false
		_astar_cancelled = true
		return
	end

	if _running then
		_queued_goal = goal_vector3
		return
	end

	_try_start_path(goal_vector3, false, nil)
end

local function _apply_height(pos)
	local h = 0.25

	if _mod_ref and _mod_ref.get then
		h = tonumber(_mod_ref:get("path_height")) or 0.25
	end

	return Vector3(pos.x, pos.y, pos.z + h)
end

local function _finalize_success()
	if not _astar or not GwNavAStar or not GwNavAStar.path_found or not GwNavAStar.path_found(_astar) then
		return false
	end

	local num_nodes = GwNavAStar.node_count(_astar)

	if not num_nodes or num_nodes < 1 then
		return false
	end

	local nav_world, traverse_logic = _nav_world_and_traverse()

	if not nav_world then
		return false
	end

	local path_last = GwNavAStar.node_at_index(_astar, num_nodes)
	local last_on_mesh = NavQueries.position_on_mesh
		and NavQueries.position_on_mesh(nav_world, path_last, LAST_NODE_NAV_MESH_CHECK_ABOVE, LAST_NODE_NAV_MESH_CHECK_BELOW, traverse_logic)

	if not last_on_mesh and num_nodes <= 2 then
		return false
	end

	table.clear(_path_points)

	local GwNavAStar_node_at_index = GwNavAStar.node_at_index

	for i = 1, num_nodes - 1 do
		local p = GwNavAStar_node_at_index(_astar, i)

		_path_points[#_path_points + 1] = _apply_height(p)
	end

	if last_on_mesh then
		_path_points[#_path_points + 1] = _apply_height(last_on_mesh)
	else
		_path_points[#_path_points + 1] = _apply_height(path_last)
	end

	return true
end

function Pathfinder.update()
	if not GwNavAStar or not GwNavAStar.processing_finished then
		return
	end

	if not _astar then
		if _queued_goal and not _astar_cancelled then
			local g = _queued_goal

			_queued_goal = nil
			_try_start_path(g, false, nil)
		end

		return
	end

	if _astar_cancelled then
		if GwNavAStar.processing_finished(_astar) then
			_astar_cancelled = false

			if _queued_goal then
				local g = _queued_goal

				_queued_goal = nil
				_try_start_path(g, false, nil)
			end
		end

		return
	end

	if _running then
		if not GwNavAStar.processing_finished(_astar) then
			return
		end

		_running = false

		if GwNavAStar.path_found(_astar) and _finalize_success() then
			_nav_search_mode = nil
		else
			local poi_goal = _poi_goal_box and _poi_goal_box:unbox()

			if _nav_search_mode == "box" and poi_goal and GwNavAStar.start then
				_try_start_path(poi_goal, true, nil)

				if _running then
					return
				end
			elseif _nav_search_mode == "full" and poi_goal then
				local via_main = _goal_on_main_path(poi_goal)

				if via_main and GwNavAStar.start then
					_try_start_path(via_main, true, "mainpath")

					if _running then
						return
					end
				end
			end

			table.clear(_path_points)
			_fail_echo()
			_nav_search_mode = nil
		end

		if _queued_goal then
			local g = _queued_goal

			_queued_goal = nil
			_try_start_path(g, false, nil)
		end

		return
	end

	if _queued_goal then
		local g = _queued_goal

		_queued_goal = nil
		_try_start_path(g, false, nil)
	end
end

function Pathfinder.get_path_points()
	return _path_points
end

function Pathfinder.is_computing()
	return _running == true
end

return Pathfinder
