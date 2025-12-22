local mod = get_mod("MourningstarCommandWheel")

local valid_lvls = {
	shooting_range = true,
	hub = true,
	training_grounds = true,
}

local function is_in_valid_lvl()
	if Managers and Managers.state and Managers.state.game_mode then
		return valid_lvls[Managers.state.game_mode:game_mode_name()] or false
	end
	return false
end

local function is_in_psychanium()
	if Managers and Managers.state and Managers.state.game_mode then
		local game_mode_name = Managers.state.game_mode:game_mode_name()
		return game_mode_name == "training_grounds" or game_mode_name == "shooting_range"
	end

	if Managers and Managers.ui then
		return Managers.ui:view_active("training_grounds_view")
	end
	return false
end

local function localize_text(label_key)
	if not label_key then
		return ""
	end
	
	if string.sub(label_key, 1, 4) == "loc_" then
		return Localize(label_key)
	else
		return mod:localize(label_key)
	end
end

local function activate_option(option)
	if not option then
		return false
	end

	local success, err = pcall(function()
		if option.action == "change_character" then
			mod:change_character()
		elseif option.action == "exit_psychanium" then
			if Managers and Managers.state and Managers.state.game_mode then
				Managers.state.game_mode:complete_game_mode()
			end
		elseif option.view then
			mod:activate_hub_view(option.view)
		end
	end)
	
	if not success then
		mod:error("Failed to activate action/view '%s': %s", tostring(option.action or option.view), tostring(err))
		return false
	end
	
	return true
end

local function find_device_for_key(key, supported_devices)
	if not key or not supported_devices then
		return nil
	end

	for _, device_type in ipairs(supported_devices) do
		local device = Managers.input:_find_active_device(device_type)
		if device then
			local index = device:button_index(key)
			if index then
				return {
					device = device,
					index = index,
				}
			end
		end
	end
	
	return nil
end

local function apply_style_offset(style, offset_x, offset_y)
	if style then
		style.offset[1] = offset_x
		style.offset[2] = offset_y
	end
end

local function apply_style_color(style, color)
	if style and color then
		style.color[1] = color[1]
		style.color[2] = color[2]
		style.color[3] = color[3]
		style.color[4] = color[4]
	end
end

return {
	is_in_valid_lvl = is_in_valid_lvl,
	is_in_psychanium = is_in_psychanium,
	localize_text = localize_text,
	activate_option = activate_option,
	find_device_for_key = find_device_for_key,
	apply_style_offset = apply_style_offset,
	apply_style_color = apply_style_color,
	valid_lvls = valid_lvls,
}

