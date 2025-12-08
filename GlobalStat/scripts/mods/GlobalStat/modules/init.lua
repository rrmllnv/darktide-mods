local init = {}

init.setup = function(mod, VIEW_NAME, view_templates, views_module, utilities)
	-- Форматирование числа с разделителем тысяч
	mod.format_number = utilities.format_number

	mod._is_in_hub = function()
		if not Managers.state or not Managers.state.game_mode then
			return false
		end

		local game_mode_name = Managers.state.game_mode:game_mode_name()
		return game_mode_name == "hub"
	end

	-- Переключение видимости статистики
	mod.toggle_stats_display = function()
		if not Managers or not Managers.ui then
			return
		end

		-- if not mod._is_in_hub() then
		-- 	return
		-- end

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
		-- views_module.inject_system_view(mod, VIEW_NAME)
	end

	mod.on_setting_changed = function()
		-- Обновление настроек при изменении (placeholder)
	end
end

return init

