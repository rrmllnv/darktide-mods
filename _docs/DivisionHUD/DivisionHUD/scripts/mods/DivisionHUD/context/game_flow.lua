local function game_mode_name()
	local gm = Managers.state and Managers.state.game_mode

	if not gm or gm.game_mode_name == nil then
		return nil
	end

	return gm:game_mode_name()
end

local function is_hub_like()
	local name = game_mode_name()

	if not name then
		return true
	end

	return name == "hub" or name == "prologue_hub"
end

local function local_player_alive_unit()
	local pm = Managers.player

	if not pm or pm.local_player == nil then
		return nil, nil
	end

	local player = pm:local_player(1)

	if not player then
		return nil, nil
	end

	local unit = player.player_unit

	if not unit or not ALIVE[unit] then
		return nil, nil
	end

	return player, unit
end

return {
	game_mode_name = game_mode_name,
	is_hub_like = is_hub_like,
	local_player_alive_unit = local_player_alive_unit,
}
