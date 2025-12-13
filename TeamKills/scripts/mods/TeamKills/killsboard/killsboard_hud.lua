local mod = get_mod("TeamKills")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local categories = {
	-- Melee lessers
	{"chaos_newly_infected", "Chaos Newly Infected"},
	{"chaos_poxwalker", "Chaos Poxwalker"},
	{"chaos_mutated_poxwalker", "Chaos Mutated Poxwalker"},
	{"chaos_armored_infected", "Chaos Armored Infected"},
	{"cultist_melee", "Cultist Melee"},
	{"cultist_ritualist", "Cultist Ritualist"},
	{"renegade_melee", "Renegade Melee"},
	-- Ranged lessers
	{"chaos_lesser_mutated_poxwalker", "Chaos Lesser Mutated Poxwalker"},
	{"cultist_assault", "Cultist Assault"},
	{"renegade_assault", "Renegade Assault"},
	{"renegade_rifleman", "Renegade Rifleman"},
	-- Melee elites
	{"cultist_berzerker", "Cultist Berzerker"},
	{"renegade_berzerker", "Renegade Berzerker"},
	{"renegade_executor", "Renegade Executor"},
	{"chaos_ogryn_bulwark", "Chaos Ogryn Bulwark"},
	{"chaos_ogryn_executor", "Chaos Ogryn Executor"},
	-- Ranged elites
	{"cultist_gunner", "Cultist Gunner"},
	{"renegade_gunner", "Renegade Gunner"},
	{"renegade_plasma_gunner", "Renegade Plasma Gunner"},
	{"renegade_radio_operator", "Renegade Radio Operator"},
	{"cultist_shocktrooper", "Cultist Shocktrooper"},
	{"renegade_shocktrooper", "Renegade Shocktrooper"},
	{"chaos_ogryn_gunner", "Chaos Ogryn Gunner"},
	-- Specials
	{"chaos_poxwalker_bomber", "Chaos Poxwalker Bomber"},
	{"renegade_grenadier", "Renegade Grenadier"},
	{"cultist_grenadier", "Cultist Grenadier"},
	{"renegade_sniper", "Renegade Sniper"},
	{"renegade_flamer", "Renegade Flamer"},
	{"renegade_flamer_mutator", "Renegade Flamer Mutator"},
	{"cultist_flamer", "Cultist Flamer"},
	-- Disablers
	{"chaos_hound", "Chaos Hound"},
	{"chaos_hound_mutator", "Chaos Hound Mutator"},
	{"cultist_mutant", "Cultist Mutant"},
	{"cultist_mutant_mutator", "Cultist Mutant Mutator"},
	{"renegade_netgunner", "Renegade Netgunner"},
	-- Bosses
	{"chaos_beast_of_nurgle", "Chaos Beast of Nurgle"},
	{"chaos_daemonhost", "Chaos Daemonhost"},
	{"chaos_spawn", "Chaos Spawn"},
	{"chaos_plague_ogryn", "Chaos Plague Ogryn"},
	{"chaos_plague_ogryn_sprayer", "Chaos Plague Ogryn Sprayer"},
	{"renegade_captain", "Renegade Captain"},
	{"cultist_captain", "Cultist Captain"},
	{"renegade_twin_captain", "Renegade Twin Captain"},
	{"renegade_twin_captain_two", "Renegade Twin Captain Two"},
}

local function build_lines()
	if not mod.get_kills_color_string or not mod.get_damage_color_string or not mod.format_number then
		return ""
	end

	local kills_color = mod.get_kills_color_string()
	local damage_color = mod.get_damage_color_string()
	local reset = "{#reset()}"

	-- Получаем список игроков с проверками
	local players = {}
	if Managers and Managers.player then
		local player_manager = Managers.player
		if player_manager and player_manager.players then
			local all_players = player_manager:players()
			if all_players then
				for _, player in pairs(all_players) do
					if player and type(player) == "table" then
						local account_id = nil
						if player.account_id then
							account_id = player:account_id()
						end
						
						if account_id then
							local name = "Unknown"
							if player.character_name then
								name = player:character_name() or name
							elseif player.name then
								name = player:name() or name
							end
							
							table.insert(players, {
								account_id = account_id,
								name = name
							})
						end
					end
				end
			end
		end
	end

	-- Ограничиваем до 4 игроков
	if #players > 4 then
		local temp = {}
		for i = 1, 4 do
			if players[i] then
				table.insert(temp, players[i])
			end
		end
		players = temp
	end

	local lines = {}
	
	-- Заголовок: название категории + столбцы для каждого игрока
	local header = string.format("%-20s", "Category")
	for i = 1, 4 do
		if players[i] and players[i].name then
			local name = players[i].name
			if string.len(name) > 10 then
				name = string.sub(name, 1, 10)
			end
			header = header .. string.format("  %-15s", name)
		else
			header = header .. string.format("  %-15s", "")
		end
	end
	table.insert(lines, header)
	table.insert(lines, string.rep("-", 80))

	-- Строки для каждой категории
	for _, data in ipairs(categories) do
		local key, label = data[1], data[2]
		local row = string.format("%-20s", label)
		
		for i = 1, 4 do
			if players[i] and players[i].account_id then
				local account_id = players[i].account_id
				local kills = 0
				local dmg = 0
				
				if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][key] then
					kills = mod.kills_by_category[account_id][key] or 0
				end
				
				if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][key] then
					dmg = mod.damage_by_category[account_id][key] or 0
				end
				
				row = row .. string.format("  %5d/%-10s", kills, mod.format_number(dmg))
			else
				row = row .. string.format("  %-15s", "")
			end
		end
		
		table.insert(lines, row)
	end

	-- Строка TOTAL
	local total_row = string.format("%-20s", "TOTAL")
	for i = 1, 4 do
		if players[i] and players[i].account_id then
			local account_id = players[i].account_id
			local total_kills = 0
			local total_dmg = 0
			
			if mod.player_kills and mod.player_kills[account_id] then
				total_kills = mod.player_kills[account_id] or 0
			end
			
			if mod.player_damage and mod.player_damage[account_id] then
				total_dmg = mod.player_damage[account_id] or 0
			end
			
			total_row = total_row .. string.format("  %5d/%-10s", total_kills, mod.format_number(total_dmg))
		else
			total_row = total_row .. string.format("  %-15s", "")
		end
	end
	table.insert(lines, string.rep("-", 80))
	table.insert(lines, total_row)

	return table.concat(lines, "\n")
end

-- Добавляем слой в тактический оверлей (TAB)
mod:hook_require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_definitions", function(instance)
	local width = 1000
	local height = 600
	instance.scenegraph_definition.killsboard = {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = {width, height},
		position = {0, 0, 150},
	}

	instance.widget_definitions.killsboard = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				vertical_alignment = "center",
				horizontal_alignment = "center",
				color = {160, 10, 10, 10},
				size = {width, height},
				offset = {0, 0, 0},
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			style_id = "text",
			value = "",
			style = {
				vertical_alignment = "top",
				horizontal_alignment = "left",
				font_type = "machine_medium",
				font_size = 16,
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				text_color = UIHudSettings.color_tint_1,
				offset = {10, -20, 1},
				size = {width - 20, height - 40},
			},
		},
	}, "killsboard")
end)

-- Рисуем виджет при активном тактическом оверлее
mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings, ...)
	func(self, dt, t, input_service, ui_renderer, render_settings, ...)

	local widget = self._widgets_by_name and self._widgets_by_name["killsboard"]
	if widget then
		widget.alpha_multiplier = self._alpha_multiplier or 1
		widget.content.text = build_lines()
		UIWidget.draw(widget, ui_renderer)
	end
end)

