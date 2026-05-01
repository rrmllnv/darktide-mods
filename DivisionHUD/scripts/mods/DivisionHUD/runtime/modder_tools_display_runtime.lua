local M = {}

local function modder_tools_mod()
	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" then
		return nil
	end

	local ok, modder_tools = pcall(get_mod_fn, "ModderTools")

	if ok and modder_tools then
		return modder_tools
	end

	return nil
end

local function modder_tools_random_names_enabled(modder_tools)
	if not modder_tools then
		return false
	end

	local ok, enabled = pcall(function()
		return modder_tools:get("enable_random_names") == true
	end)

	return ok and enabled == true
end

local function valid_player(player)
	if not player or player.__deleted then
		return false
	end

	local player_type = type(player)

	return player_type == "table" or player_type == "userdata"
end

function M.resolve_plain_player_name(base_name, player)
	if type(base_name) ~= "string" or base_name == "" then
		return base_name
	end

	if not valid_player(player) then
		return base_name
	end

	local modder_tools = modder_tools_mod()

	if not modder_tools then
		return base_name
	end

	if not modder_tools_random_names_enabled(modder_tools) then
		return base_name
	end

	local ok_out, out = pcall(function()
		if type(modder_tools.resolve_substituted_player_display_name) == "function" then
			return modder_tools.resolve_substituted_player_display_name(player, base_name)
		end

		local cache_key = nil

		if type(modder_tools.player_display_name_cache_key) == "function" then
			cache_key = modder_tools.player_display_name_cache_key(player)
		elseif type(modder_tools.player_name_cache_key) == "function" then
			cache_key = modder_tools.player_name_cache_key(player)
		end

		if cache_key == nil then
			return base_name
		end

		return modder_tools.get_player_name(cache_key, base_name)
	end)

	if ok_out and type(out) == "string" and out ~= "" then
		return out
	end

	return base_name
end

function M.replace_in_player_text(text, player, original_player_name)
	if type(text) ~= "string" or text == "" then
		return text
	end

	if not valid_player(player) then
		return text
	end

	local modder_tools = modder_tools_mod()

	if not modder_tools or type(modder_tools.replace_name_in_text) ~= "function" then
		return text
	end

	if not modder_tools_random_names_enabled(modder_tools) then
		return text
	end

	local cache_key = nil

	if type(modder_tools.player_display_name_cache_key) == "function" then
		local ok_k, k = pcall(function()
			return modder_tools.player_display_name_cache_key(player)
		end)

		if ok_k and k ~= nil then
			cache_key = k
		end
	end

	if cache_key == nil and type(modder_tools.player_name_cache_key) == "function" then
		local ok_k, k = pcall(function()
			return modder_tools.player_name_cache_key(player)
		end)

		if ok_k and k ~= nil then
			cache_key = k
		end
	end

	if cache_key == nil then
		return text
	end

	local original = type(original_player_name) == "string" and original_player_name or ""

	local ok_out, out = pcall(function()
		return modder_tools.replace_name_in_text(text, cache_key, original)
	end)

	if ok_out and type(out) == "string" and out ~= "" then
		return out
	end

	return text
end

return M
