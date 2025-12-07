local views = {}

local system_view_injected = false
local global_loc_registered = false

views.register_views = function(mod, view_templates)
	for _, view_template in pairs(view_templates) do
		local path = view_template.view_settings.path
		mod:add_require_path(path)
		mod:register_view(view_template)
	end
end

views.inject_system_view = function(mod, NEW_VIEW_NAME)
	if system_view_injected then
		return
	end

	if not global_loc_registered then
		mod:add_global_localize_strings({
			player_progress_stats_button = {
				en = "Player Statistics",
				ru = "Статистика игрока",
			},
		})

		global_loc_registered = true
	end

	mod:hook_require("scripts/ui/views/system_view/system_view_content_list", function(content_list)
		if table.find_by_key(content_list.default, "text", "player_progress_stats_button") then
			return
		end

		local new_entry = {
			text = "player_progress_stats_button",
			type = "button",
			icon = "content/ui/materials/icons/system/escape/achievement",
			trigger_function = function()
				mod.toggle_stats_display()
			end,
		}

		local inserted = false
		local new_default = {}

		for _, item in ipairs(content_list.default) do
			if not inserted and item.text == "mods_options" then
				table.insert(new_default, new_entry)
				inserted = true
			end

			table.insert(new_default, item)
		end

		if not inserted then
			table.insert(new_default, new_entry)
		end

		content_list.default = new_default

		local new_menu = {}
		inserted = false

		for _, item in ipairs(content_list.StateMainMenu or {}) do
			if not inserted and item.text == "mods_options" then
				table.insert(new_menu, new_entry)
				inserted = true
			end

			table.insert(new_menu, item)
		end

		if not inserted then
			table.insert(new_menu, new_entry)
		end

		content_list.StateMainMenu = new_menu

		system_view_injected = true
	end)
end

return views

