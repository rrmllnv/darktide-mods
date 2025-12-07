local commands = {}

commands.setup = function(mod)
	-- 🔍 Консольная команда для проверки локализации
	mod:command("check_loc", "Check localization key. Usage: /check_loc your_key", function(key)
		if not key or key == "" then
			mod:echo("Usage: /check_loc your_localization_key")
			mod:echo("Example: /check_loc loc_breed_display_name_chaos_daemonhost")
			return
		end

		local function check_localization(loc_key)
			if loc_key:match("^loc_") then
				local success, result = pcall(function()
					return Localize(loc_key)
				end)

				if success and result and result ~= "" and result ~= loc_key then
					return true, result, "game"
				end
			end

			local success, result = pcall(function()
				return mod:localize(loc_key)
			end)

			if success and result and result ~= "" and result ~= loc_key then
				return true, result, "mod"
			end

			return false, nil, nil
		end

		local found, translation, source = check_localization(key)

		if found then
			if source == "game" then
				mod:echo("Found in GAME localization:")
			else
				mod:echo("Found in MOD localization:")
			end
			mod:echo("Key: " .. key)
			mod:echo("Translation: " .. translation)
		else
			mod:echo("NOT FOUND: " .. key)
			mod:echo("Make sure the key is correct and starts with 'loc_'")
		end
	end)

	-- 📚 Команда для списка примеров
	mod:command("check_loc_help", "Show example localization keys", function()
		mod:echo("Example localization keys to try:")
		mod:echo("")
		mod:echo("Breeds - Bosses:")
		mod:echo("/check_loc loc_breed_display_name_chaos_daemonhost")
		mod:echo("/check_loc loc_breed_display_name_chaos_beast_of_nurgle")
		mod:echo("")
		mod:echo("Breeds - Elites:")
		mod:echo("/check_loc loc_breed_display_name_chaos_ogryn_gunner")
		mod:echo("/check_loc loc_breed_display_name_renegade_gunner")
		mod:echo("")
		mod:echo("Achievements:")
		mod:echo("/check_loc loc_achievement_enemies_killed_by_barrels_name")
		mod:echo("")
		mod:echo("Weapons:")
		mod:echo("/check_loc loc_weapon_family_lasgun")
		mod:echo("")
		mod:echo("UI:")
		mod:echo("/check_loc loc_settings_menu_close_menu")
		mod:echo("")
		mod:echo("For statistics use: /check_stat")
	end)

	-- 📊 Консольная команда для проверки статистики
	mod:command("check_stat", "Check player statistic. Usage: /check_stat stat_name", function(stat_name)
		if not stat_name or stat_name == "" then
			mod:echo("Usage: /check_stat your_stat_name")
			mod:echo("Example: /check_stat total_kills")
			mod:echo("Example: /check_stat missions")
			mod:echo("")
			mod:echo("Common stats:")
			mod:echo("• total_kills, total_renegade_kills, total_cultist_kills")
			mod:echo("• missions, auric_missions, havoc_missions")
			mod:echo("• total_chaos_daemonhost_killed")
			return
		end

		if not Managers or not Managers.stats then
			mod:echo("Stats manager not available (not in hub?)")
			return
		end

		local success, value = pcall(function()
			return Managers.stats:read_user_stat(1, stat_name)
		end)

		if success and value then
			mod:echo("Statistic found:")
			mod:echo("Stat: " .. stat_name)
			mod:echo("Value: " .. mod.format_number(value))
		else
			mod:echo("Statistic NOT FOUND: " .. stat_name)
			mod:echo("Check if stat name is correct")
			mod:echo("Some stats only work during missions")
		end
	end)
end

return commands

