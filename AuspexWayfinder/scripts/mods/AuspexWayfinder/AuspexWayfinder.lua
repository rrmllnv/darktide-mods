local mod = get_mod("AuspexWayfinder")

local Pathfinder = mod:io_dofile("AuspexWayfinder/scripts/mods/AuspexWayfinder/AuspexWayfinder_pathfinder")

assert(Pathfinder and type(Pathfinder) == "table", "[AuspexWayfinder] AuspexWayfinder_pathfinder must return a table.")

Pathfinder.init(mod)

local LineObject = rawget(_G, "LineObject")
local World = rawget(_G, "World")

local line_state = {
	world = nil,
	object = nil,
}

local function destroy_line_object()
	if line_state.object and line_state.world and World and World.destroy_line_object then
		pcall(World.destroy_line_object, line_state.world, line_state.object)
	end

	line_state.world = nil
	line_state.object = nil
end

local function ensure_line_object(world)
	if not LineObject or not World or not world then
		return nil
	end

	if line_state.world ~= world or not line_state.object then
		destroy_line_object()

		local ok, obj = pcall(World.create_line_object, world)

		if ok and obj then
			line_state.world = world
			line_state.object = obj
		end
	end

	return line_state.object
end

local function clear_draw(world)
	if not world then
		destroy_line_object()
		return
	end

	local obj = line_state.object

	if obj and line_state.world == world and LineObject then
		pcall(LineObject.reset, obj)
		pcall(LineObject.dispatch, world, obj)
	end
end

local function resolve_path_color()
	local name = mod:get("path_color")
	local fallback = Color and Color.ui_hud_warp_charge_high and Color.ui_hud_warp_charge_high(200, true)

	if type(name) ~= "string" or not Color or not Color[name] then
		return fallback
	end

	local ok, c = pcall(Color[name], 200, true)

	if ok and c then
		return c
	end

	return fallback
end

local function draw_thick_line(line_object, color, from, to, thickness)
	if not line_object or not LineObject or not from or not to then
		return
	end

	if thickness == nil or thickness <= 0 then
		pcall(LineObject.add_line, line_object, color, from, to)
		return
	end

	local direction = to - from

	if Vector3.length(direction) < 0.001 then
		pcall(LineObject.add_line, line_object, color, from, to)
		return
	end

	local dir = Vector3.normalize(direction)
	local axis = Vector3.up()

	if math.abs(Vector3.dot(dir, axis)) > 0.9 then
		axis = Vector3(1, 0, 0)
	end

	local right = Vector3.normalize(Vector3.cross(dir, axis))
	local up = Vector3.normalize(Vector3.cross(right, dir))
	local offset = thickness

	pcall(LineObject.add_line, line_object, color, from, to)
	pcall(LineObject.add_line, line_object, color, from + right * offset, to + right * offset)
	pcall(LineObject.add_line, line_object, color, from - right * offset, to - right * offset)
	pcall(LineObject.add_line, line_object, color, from + up * offset, to + up * offset)
	pcall(LineObject.add_line, line_object, color, from - up * offset, to - up * offset)
end

local function resolve_goal_world_position(handler, level_index)
	if not handler or not level_index then
		return nil
	end

	local opp = handler.get_registered_opportunities and handler:get_registered_opportunities()
	local ext = handler.get_registered_extractions and handler:get_registered_extractions()
	local ex = handler.get_registered_exits and handler:get_registered_exits()
	local box = opp and opp[level_index] or ext and ext[level_index] or ex and ex[level_index]

	if not box or not box.unbox then
		return nil
	end

	local ok, v = pcall(box.unbox, box)

	if ok and v then
		return v
	end

	return nil
end

local function on_expedition_auspex_action(minigame)
	local gm = Managers.state and Managers.state.game_mode

	if not gm or gm:game_mode_name() ~= "expedition" then
		Pathfinder.clear_path_only()
		Pathfinder.cancel_computation()
		return
	end

	local handler = minigame._handler

	if not handler then
		return
	end

	local local_player = Managers.player and Managers.player:local_player(1)

	if not local_player then
		return
	end

	local slot = local_player.slot and local_player:slot()
	local sel = minigame._selected
	local level_index = sel and minigame._selectable and minigame._selectable[sel]

	if not level_index or not slot then
		Pathfinder.clear_path_only()
		Pathfinder.cancel_computation()
		return
	end

	local marked_slot = handler.player_slot_by_level_marked and handler:player_slot_by_level_marked(level_index)

	if marked_slot == slot then
		local goal = resolve_goal_world_position(handler, level_index)

		if goal then
			Pathfinder.request_path_to_goal(goal)
		end
	else
		Pathfinder.clear_path_only()
		Pathfinder.cancel_computation()
	end
end

mod:hook_require("scripts/extension_systems/minigame/minigames/minigame_expedition_map", function(MinigameExpeditionMap)
	mod:hook_safe(MinigameExpeditionMap, "on_action_pressed", function(self, t)
		pcall(on_expedition_auspex_action, self)
	end)
end)

local function is_gameplay_not_hub()
	if not Managers or not Managers.state or not Managers.state.game_mode then
		return false
	end

	if Managers.state.game_mode:game_mode_name() == "hub" then
		return false
	end

	return true
end

function mod.update(dt, t)
	local world = Managers.world and Managers.world:world("level_world")

	if not mod:is_enabled() then
		if world then
			clear_draw(world)
		end

		Pathfinder.destroy_astar()
		return
	end

	if not is_gameplay_not_hub() then
		if world then
			clear_draw(world)
		end

		Pathfinder.destroy_astar()
		return
	end

	local gm = Managers.state and Managers.state.game_mode
	local gname = gm and gm.game_mode_name and gm:game_mode_name()

	Pathfinder.update()

	if gname ~= "expedition" then
		Pathfinder.clear_path_only()
		Pathfinder.cancel_computation()

		if world then
			clear_draw(world)
		end

		return
	end

	if mod:get("path_enabled") == false then
		if world then
			clear_draw(world)
		end

		return
	end

	if not world or not Vector3 or not Color then
		return
	end

	local points = Pathfinder.get_path_points()

	if not points or #points < 2 then
		clear_draw(world)
		return
	end

	local line_object = ensure_line_object(world)

	if not line_object then
		return
	end

	pcall(LineObject.reset, line_object)

	local path_color = resolve_path_color()
	local thickness = tonumber(mod:get("path_line_thickness")) or 0

	for i = 1, #points - 1 do
		draw_thick_line(line_object, path_color, points[i], points[i + 1], thickness)
	end

	pcall(LineObject.dispatch, world, line_object)
end

function mod.on_game_state_changed(status, state_name)
	if status == "exit" and (state_name == "GameplayStateRun" or state_name == "StateGameplay") then
		Pathfinder.destroy_astar()
		destroy_line_object()
	end
end

function mod.on_disabled()
	Pathfinder.destroy_astar()
	destroy_line_object()
end

function mod.on_unload()
	mod.on_disabled()
end
