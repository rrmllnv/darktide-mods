local init = {}

init.setup = function(mod, VIEW_NAME, view_templates, views_module, utilities)
	mod.format_number = utilities.format_number

	mod._get_game_mode_name = function()
		if not Managers.state or not Managers.state.game_mode then
			return nil
		end

		return Managers.state.game_mode:game_mode_name()
	end

	mod._is_in_hub = function()
		local game_mode_name = mod._get_game_mode_name()
		return game_mode_name == "hub"
	end

	mod._is_in_mission = function()
		local game_mode_name = mod._get_game_mode_name()
		if not game_mode_name then
			return false
		end

		return game_mode_name ~= "hub" and game_mode_name ~= "prologue_hub" and game_mode_name ~= "training_grounds" and game_mode_name ~= "shooting_range"
	end

	mod._is_in_psykhanium = function()
		local game_mode_name = mod._get_game_mode_name()
		return game_mode_name == "training_grounds" or game_mode_name == "shooting_range"
	end

	mod._is_in_prologue = function()
		local game_mode_name = mod._get_game_mode_name()
		return game_mode_name == "prologue_hub"
	end

	mod._can_show_stats = function()
		if mod._is_in_hub() then
			return mod:get("show_in_hub") == true
		elseif mod._is_in_mission() then
			return mod:get("show_in_mission") == true
		elseif mod._is_in_psykhanium() then
			return mod:get("show_in_psykhanium") == true
		elseif mod._is_in_prologue() then
			return mod:get("show_in_prologue") == true
		end

		return false
	end

	mod.toggle_stats_display = function()
		if not Managers or not Managers.ui then
			return
		end

		if not mod._can_show_stats() then
			return
		end

		local UIManager = Managers.ui

		if UIManager:view_instance(VIEW_NAME) then
			Managers.ui:close_view(VIEW_NAME)
		elseif not UIManager:chat_using_input() then
			if UIManager:view_instance("dmf_options_view") then
				Managers.ui:close_view("dmf_options_view", true)
			end

			Managers.ui:open_view(VIEW_NAME, nil, true, nil, nil, mod)
		end
	end

	mod.on_all_mods_loaded = function()
		views_module.register_views(mod, view_templates)
	end

	mod.on_setting_changed = function()
	end
end

return init

