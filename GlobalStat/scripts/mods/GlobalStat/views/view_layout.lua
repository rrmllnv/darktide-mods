local Layout = {}

local function make_safe_read_stat()
	return function(stat_name)
		if not Managers or not Managers.stats or not Managers.stats.read_user_stat then
			return 0
		end

		local success, value = pcall(function()
			local result = Managers.stats:read_user_stat(1, stat_name)
			return result and type(result) == "number" and result or 0
		end)

		return success and value or 0
	end
end

local function make_format_number(mod)
	return function(number)
		if not number or type(number) ~= "number" then
			return "0"
		end

		if mod.format_number then
			local success, result = pcall(function()
				return mod.format_number(number)
			end)

			if success and result then
				return result
			end
		end

		return tostring(math.floor(number))
	end
end

local function make_localize(mod)
	return function(key)
		if key:match("^loc_") then
			local success, result = pcall(function()
				return Localize(key)
			end)

			if success and result and result ~= "" and result ~= key then
				return result
			end
		end

		local success, result = pcall(function()
			return mod:localize(key)
		end)

		if success and result and result ~= "" then
			return result
		end

		return key
	end
end

Layout.create_stat_layout = function(self, mod, tab_modules, is_debug)
	local safe_read_stat = make_safe_read_stat()
	local format_number = make_format_number(mod)
	local localize = make_localize(mod)

	local tab_index = self._active_tab_index or 1

	local tab_module = tab_modules[tab_index]
	if not tab_module then
		return {}
	end

	local constants = mod:io_dofile("GlobalStat/scripts/mods/GlobalStat/views/view_constants")
	local tab_key = nil
	if constants and constants.tabs_definitions and constants.tabs_definitions[tab_index] then
		tab_key = constants.tabs_definitions[tab_index].key
	end

	local layout = tab_module.create_layout(safe_read_stat, localize, format_number) or {}
	
	-- Добавляем tab_key во все элементы layout
	for _, element in ipairs(layout) do
		if element.widget_type and (element.widget_type == "stat_line" or element.widget_type == "stat_line_with_description") then
			element.tab_key = tab_key
		end
	end

	return layout
end

return Layout

