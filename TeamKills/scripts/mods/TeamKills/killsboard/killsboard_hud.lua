local mod = get_mod("TeamKills")

local CLASS = CLASS
local Color = Color
local Managers = Managers
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local KillsboardViewSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killsboard_view_settings")
local base_z = 100  -- Как в scoreboard
local base_x = 0

local categories = {
	-- Melee lessers
	{"chaos_newly_infected", "Chaos Newly Infected", "Melee Lessers"},
	{"chaos_poxwalker", "Chaos Poxwalker", "Melee Lessers"},
	{"chaos_mutated_poxwalker", "Chaos Mutated Poxwalker", "Melee Lessers"},
	{"chaos_armored_infected", "Chaos Armored Infected", "Melee Lessers"},
	{"cultist_melee", "Cultist Melee", "Melee Lessers"},
	{"cultist_ritualist", "Cultist Ritualist", "Melee Lessers"},
	{"renegade_melee", "Renegade Melee", "Melee Lessers"},
	-- Ranged lessers
	{"chaos_lesser_mutated_poxwalker", "Chaos Lesser Mutated Poxwalker", "Ranged Lessers"},
	{"cultist_assault", "Cultist Assault", "Ranged Lessers"},
	{"renegade_assault", "Renegade Assault", "Ranged Lessers"},
	{"renegade_rifleman", "Renegade Rifleman", "Ranged Lessers"},
	-- Melee elites
	{"cultist_berzerker", "Cultist Berzerker", "Melee Elites"},
	{"renegade_berzerker", "Renegade Berzerker", "Melee Elites"},
	{"renegade_executor", "Renegade Executor", "Melee Elites"},
	{"chaos_ogryn_bulwark", "Chaos Ogryn Bulwark", "Melee Elites"},
	{"chaos_ogryn_executor", "Chaos Ogryn Executor", "Melee Elites"},
	-- Ranged elites
	{"cultist_gunner", "Cultist Gunner", "Ranged Elites"},
	{"renegade_gunner", "Renegade Gunner", "Ranged Elites"},
	{"renegade_plasma_gunner", "Renegade Plasma Gunner", "Ranged Elites"},
	{"renegade_radio_operator", "Renegade Radio Operator", "Ranged Elites"},
	{"cultist_shocktrooper", "Cultist Shocktrooper", "Ranged Elites"},
	{"renegade_shocktrooper", "Renegade Shocktrooper", "Ranged Elites"},
	{"chaos_ogryn_gunner", "Chaos Ogryn Gunner", "Ranged Elites"},
	-- Specials
	{"chaos_poxwalker_bomber", "Chaos Poxwalker Bomber", "Specials"},
	{"renegade_grenadier", "Renegade Grenadier", "Specials"},
	{"cultist_grenadier", "Cultist Grenadier", "Specials"},
	{"renegade_sniper", "Renegade Sniper", "Specials"},
	{"renegade_flamer", "Renegade Flamer", "Specials"},
	{"renegade_flamer_mutator", "Renegade Flamer Mutator", "Specials"},
	{"cultist_flamer", "Cultist Flamer", "Specials"},
	-- Disablers
	{"chaos_hound", "Chaos Hound", "Disablers"},
	{"chaos_hound_mutator", "Chaos Hound Mutator", "Disablers"},
	{"cultist_mutant", "Cultist Mutant", "Disablers"},
	{"cultist_mutant_mutator", "Cultist Mutant Mutator", "Disablers"},
	{"renegade_netgunner", "Renegade Netgunner", "Disablers"},
	-- Bosses
	{"chaos_beast_of_nurgle", "Chaos Beast of Nurgle", "Bosses"},
	{"chaos_daemonhost", "Chaos Daemonhost", "Bosses"},
	{"chaos_spawn", "Chaos Spawn", "Bosses"},
	{"chaos_plague_ogryn", "Chaos Plague Ogryn", "Bosses"},
	{"chaos_plague_ogryn_sprayer", "Chaos Plague Ogryn Sprayer", "Bosses"},
	{"renegade_captain", "Renegade Captain", "Bosses"},
	{"cultist_captain", "Cultist Captain", "Bosses"},
	{"renegade_twin_captain", "Renegade Twin Captain", "Bosses"},
	{"renegade_twin_captain_two", "Renegade Twin Captain Two", "Bosses"},
}

local function get_players()
	local players = {}
	local local_account_id = nil
	
	-- Получаем локального игрока
	if Managers and Managers.player then
		local local_player = Managers.player:local_player(1)
		if local_player then
			local_account_id = local_player:account_id() or local_player:name()
		end
	end
	
	if Managers and Managers.player then
		local player_manager = Managers.player
		if player_manager and player_manager.players then
			local all_players = player_manager:players()
			if all_players then
				local local_player_data = nil
				
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
							
							local player_data = {
								account_id = account_id,
								name = name,
								player = player
							}
							
							-- Если это локальный игрок, сохраняем отдельно
							if local_account_id and account_id == local_account_id then
								local_player_data = player_data
							else
								table.insert(players, player_data)
							end
						end
					end
				end
				
				-- Вставляем локального игрока первым
				if local_player_data then
					table.insert(players, 1, local_player_data)
				end
			end
		end
	end
	return players
end

-- Add killsboard scenegraph and widget to tactical overlay definitions
mod:hook_require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_definitions", function(instance)
	instance.scenegraph_definition.killsboard = {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = {KillsboardViewSettings.killsboard_size[1], KillsboardViewSettings.killsboard_size[2]},
		position = {0, 0, base_z}
	}
	instance.scenegraph_definition.killsboard_rows = {
		vertical_alignment = "top",
		parent = "killsboard",
		horizontal_alignment = "center",
		size = {KillsboardViewSettings.killsboard_size[1], KillsboardViewSettings.killsboard_size[2] - 100},
		position = {0, 40, base_z - 1}
	}
	instance.widget_definitions.killsboard = UIWidget.create_definition({
		{
			value = "content/ui/materials/backgrounds/terminal_basic",
			pass_type = "texture",
			style = {
				vertical_alignment = "center",
				scale_to_material = true,
				horizontal_alignment = "center",
				offset = {0, 0, base_z},
				size = {KillsboardViewSettings.killsboard_size[1] - 4, KillsboardViewSettings.killsboard_size[2]},
				color = Color.black(255, true),
				disabled_color = Color.black(255, true),
				default_color = Color.black(255, true),
				hover_color = Color.black(255, true),
			}
		},
	}, "killsboard")
end)

mod.create_killsboard_row_widget = function(self, index, current_offset, visible_rows, row_data, widgets_by_name, loaded_players, _obj, _create_widget_callback, ui_renderer)
	local _blueprints = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killsboard_view_blueprints")
	local _settings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killsboard_view_settings")
	local killsboard_widget = widgets_by_name["killsboard"]
	
	local widget = nil
	local template = table.clone(_blueprints["killsboard_row"])
	local size = template.size
	local pass_template = template.pass_template
	local name = "killsboard_row_" .. (row_data.name or index)
	local header = row_data.type == "header"
	local subheader = row_data.type == "subheader"
	local total = row_data.type == "total"
	local group_header = row_data.type == "group_header"
	
	local row_height = (header or group_header) and _settings.killsboard_row_header_height or _settings.killsboard_row_height
	-- Используем размер шрифта из settings
	local font_size = (header or group_header) and _settings.killsboard_font_size_header or _settings.killsboard_font_size
	
	-- Вычисляем отступ для центрирования контента
	-- Ширина контента: column_header_width (300) + column_player_width * 4 (130 * 4 = 520) = 820
	-- Ширина строки: killsboard_size[1] (900)
	-- Отступ слева: (900 - 820) / 2 = 40
	local content_width = _settings.killsboard_column_header_width + (_settings.killsboard_column_player_width * 4)
	local row_width = _settings.killsboard_size[1]
	local left_offset = (row_width - content_width) / 2
	
	-- Map для столбцов: k1, d1, k2, d2, k3, d3, k4, d4
	local k_pass_map = {2, 5, 8, 11}  -- k1, k2, k3, k4
	local d_pass_map = {3, 6, 9, 12}  -- d1, d2, d3, d4
	local background_pass_map = {4, 7, 10, 13}  -- bg1 (темный), bg2 (светлый), bg3 (темный), bg4 (светлый)
	
	local players = loaded_players or get_players()
	
	-- Set styles и применяем left_offset для центрирования
	pass_template[1].style.font_size = font_size
	pass_template[1].style.size[2] = row_height
	pass_template[1].style.offset[1] = left_offset + 30  -- текст категории с отступом 30
	
	for _, i in pairs(k_pass_map) do
		pass_template[i].style.font_size = font_size
		pass_template[i].style.size[2] = row_height
		-- offset будет установлен ниже для каждого столбца
	end
	for _, i in pairs(d_pass_map) do
		pass_template[i].style.font_size = font_size
		pass_template[i].style.size[2] = row_height
		-- offset будет установлен ниже для каждого столбца
	end
	
	-- Применяем left_offset ко всем столбцам
	-- k1 (pass 2)
	pass_template[2].style.offset[1] = left_offset + _settings.killsboard_column_header_width
	-- d1 (pass 3)
	pass_template[3].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_width
	-- k2 (pass 5)
	pass_template[5].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width
	-- d2 (pass 6)
	pass_template[6].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width + _settings.killsboard_column_width
	-- k3 (pass 8)
	pass_template[8].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2
	-- d3 (pass 9)
	pass_template[9].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2 + _settings.killsboard_column_width
	-- k4 (pass 11)
	pass_template[11].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3
	-- d4 (pass 12)
	pass_template[12].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3 + _settings.killsboard_column_width
	
	-- Header row
	if header then
		pass_template[1].value = "KILLSTREAK BOARD"
		local num_players = 0
		for i = 1, 4 do
			pass_template[k_pass_map[i]].value = ""
			pass_template[d_pass_map[i]].value = ""
			-- Меняем выравнивание на center для заголовка
			pass_template[k_pass_map[i]].style.text_horizontal_alignment = "center"
			-- Увеличиваем размер столбца для имени, чтобы оно поместилось по центру
			pass_template[k_pass_map[i]].style.size[1] = _settings.killsboard_column_player_bg_width
		end
		for _, player_data in pairs(players) do
			num_players = num_players + 1
			if num_players <= 4 then
				local name = player_data.name or "Unknown"
				if string.len(name) > 12 then
					name = string.sub(name, 1, 12)
				end
				-- В заголовке показываем имя в столбце K, по центру
				pass_template[k_pass_map[num_players]].value = name
				pass_template[d_pass_map[num_players]].value = ""
			end
		end
	elseif subheader then
		pass_template[1].value = ""
		for i = 1, 4 do
			if players[i] then
				pass_template[k_pass_map[i]].value = "Kills"
				pass_template[d_pass_map[i]].value = "Damage"
			else
				pass_template[k_pass_map[i]].value = ""
				pass_template[d_pass_map[i]].value = ""
			end
		end
	elseif group_header then
		local group_name = row_data.group_name or ""
		pass_template[1].value = group_name
		-- Центрируем текст заголовка группы в столбце категорий
		pass_template[1].style.text_horizontal_alignment = "center"
		pass_template[1].style.offset[1] = left_offset + _settings.killsboard_column_header_width / 2 - (string.len(group_name) * font_size / 2) / 2
		for i = 1, 4 do
			pass_template[k_pass_map[i]].value = ""
			pass_template[d_pass_map[i]].value = ""
		end
	elseif total then
		pass_template[1].value = "TOTAL"
		local player_num = 1
		for _, player_data in pairs(players) do
			if player_num <= 4 then
				local account_id = player_data.account_id
				local total_kills = 0
				local total_dmg = 0
				
				if mod.player_kills and mod.player_kills[account_id] then
					total_kills = mod.player_kills[account_id] or 0
				end
				
				if mod.player_damage and mod.player_damage[account_id] then
					total_dmg = mod.player_damage[account_id] or 0
				end
				
				pass_template[k_pass_map[player_num]].value = tostring(total_kills)
				pass_template[d_pass_map[player_num]].value = mod.format_number and mod.format_number(total_dmg) or tostring(total_dmg)
			end
			player_num = player_num + 1
		end
	else
		-- Data row
		local category_key = row_data.key
		local category_label = row_data.label
		pass_template[1].value = category_label
		
		local player_num = 1
		for _, player_data in pairs(players) do
			if player_num <= 4 then
				local account_id = player_data.account_id
				local kills = 0
				local dmg = 0
				local killstreak_kills = 0
				local killstreak_dmg = 0
				
				if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][category_key] then
					kills = mod.kills_by_category[account_id][category_key] or 0
				end
				
				if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][category_key] then
					dmg = mod.damage_by_category[account_id][category_key] or 0
				end
				
				-- Получаем killstreak значения из display массивов
				if mod.display_killstreak_kills_by_category and mod.display_killstreak_kills_by_category[account_id] and mod.display_killstreak_kills_by_category[account_id][category_key] then
					killstreak_kills = mod.display_killstreak_kills_by_category[account_id][category_key] or 0
				end
				
				if mod.display_killstreak_damage_by_category and mod.display_killstreak_damage_by_category[account_id] and mod.display_killstreak_damage_by_category[account_id][category_key] then
					killstreak_dmg = mod.display_killstreak_damage_by_category[account_id][category_key] or 0
				end
				
				-- Формируем строку с killstreak значениями в скобках
				local kills_text = tostring(kills)
				if killstreak_kills > 0 then
					kills_text = kills_text .. " (+" .. tostring(killstreak_kills) .. ")"
				end
				
				local dmg_text = mod.format_number and mod.format_number(dmg) or tostring(dmg)
				if killstreak_dmg > 0 then
					dmg_text = dmg_text .. " (+" .. (mod.format_number and mod.format_number(killstreak_dmg) or tostring(killstreak_dmg)) .. ")"
				end
				
				pass_template[k_pass_map[player_num]].value = kills_text
				pass_template[d_pass_map[player_num]].value = dmg_text
			end
			player_num = player_num + 1
		end
	end
	
	-- Column backgrounds
	if header or subheader or total or group_header then
		-- Скрываем все фоны для header, subheader, total и group_header
		for _, i in pairs(background_pass_map) do
			pass_template[i].style.visible = false
		end
		pass_template[14].style.visible = false
	else
		-- Определяем четность строки (visible_rows уже учитывает header и subheader)
		local is_even_row = visible_rows % 2 == 0
		
		-- Цвета для четных и нечетных строк
		-- ВСЯ строка (все столбцы) должна иметь один цвет
		local color_dark = Color.black(200, true)  -- черный
		local color_light = Color.black(100, true)  -- темно-серый
		
		-- Проверяем, нужно ли подсвечивать эту категорию (из массива highlighted_categories)
		local has_recent_kill = false
		if row_data.type == "data" and row_data.key then
			local category_key = row_data.key
			
			for _, player_data in pairs(players) do
				if player_data and player_data.account_id then
					local account_id = player_data.account_id
					if mod.highlighted_categories and mod.highlighted_categories[account_id] and mod.highlighted_categories[account_id][category_key] then
						has_recent_kill = true
						break
					end
				end
			end
		end
		
		-- Для четных строк: все столбцы - темный
		-- Для нечетных строк: все столбцы - светлый
		-- Если было недавнее убийство, используем более яркий цвет для подсветки
		local base_row_color = is_even_row and color_dark or color_light
		local row_color = has_recent_kill and Color.terminal_frame(150, true) or base_row_color
		
		-- bg_category (столбец категорий) - индекс 14
		pass_template[14].style.size[2] = row_height
		pass_template[14].style.visible = true
		pass_template[14].style.color = row_color
		pass_template[14].style.disabled_color = row_color
		pass_template[14].style.default_color = row_color
		pass_template[14].style.hover_color = row_color
		pass_template[14].style.offset[1] = left_offset

		-- Вычисляем центрирование фона относительно столбцов K и D
		-- K1 начинается: left_offset + killsboard_column_header_width
		-- D1 заканчивается: left_offset + killsboard_column_header_width + killsboard_column_width * 2
		-- Центр K1+D1: left_offset + killsboard_column_header_width + killsboard_column_width
		-- Начало фона: центр - bg_width / 2
		
		-- bg1 (столбец 1) - индекс 4
		local k1_start = left_offset + _settings.killsboard_column_header_width
		local d1_end = k1_start + _settings.killsboard_column_width * 2
		local center_k1_d1 = (k1_start + d1_end) / 2
		pass_template[4].style.size[2] = row_height
		pass_template[4].style.visible = true
		pass_template[4].style.color = row_color
		pass_template[4].style.disabled_color = row_color
		pass_template[4].style.default_color = row_color
		pass_template[4].style.hover_color = row_color
		pass_template[4].style.offset[1] = center_k1_d1 - (_settings.killsboard_column_player_bg_width / 2)

		-- bg2 (столбец 2) - индекс 7
		local k2_start = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width
		local d2_end = k2_start + _settings.killsboard_column_width * 2
		local center_k2_d2 = (k2_start + d2_end) / 2
		pass_template[7].style.size[2] = row_height
		pass_template[7].style.visible = true
		pass_template[7].style.color = row_color
		pass_template[7].style.disabled_color = row_color
		pass_template[7].style.default_color = row_color
		pass_template[7].style.hover_color = row_color
		pass_template[7].style.offset[1] = center_k2_d2 - (_settings.killsboard_column_player_bg_width / 2)

		-- bg3 (столбец 3) - индекс 10
		local k3_start = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2
		local d3_end = k3_start + _settings.killsboard_column_width * 2
		local center_k3_d3 = (k3_start + d3_end) / 2
		pass_template[10].style.size[2] = row_height
		pass_template[10].style.visible = true
		pass_template[10].style.color = row_color
		pass_template[10].style.disabled_color = row_color
		pass_template[10].style.default_color = row_color
		pass_template[10].style.hover_color = row_color
		pass_template[10].style.offset[1] = center_k3_d3 - (_settings.killsboard_column_player_bg_width / 2)

		-- bg4 (столбец 4) - индекс 13
		local k4_start = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3
		local d4_end = k4_start + _settings.killsboard_column_width * 2
		local center_k4_d4 = (k4_start + d4_end) / 2
		pass_template[13].style.size[2] = row_height
		pass_template[13].style.visible = true
		pass_template[13].style.color = row_color
		pass_template[13].style.disabled_color = row_color
		pass_template[13].style.default_color = row_color
		pass_template[13].style.hover_color = row_color
		pass_template[13].style.offset[1] = center_k4_d4 - (_settings.killsboard_column_player_bg_width / 2)
	end
	
	-- Create widget
	local widget_definition = UIWidget.create_definition(pass_template, "killsboard_rows", nil, size)
	
	if widget_definition then
		widget = _obj[_create_widget_callback](_obj, name, widget_definition)
		widget.alpha_multiplier = 0
		widget.offset = {0, current_offset, base_z + 1}
		return widget, row_height
	end
end

mod.setup_killsboard_row_widgets = function(self, row_widgets, widgets_by_name, loaded_players, _obj, _create_widget_callback, ui_renderer)
	local current_offset = 0
	local visible_rows = 0
	local total_height = 0
	
	local players = loaded_players or get_players()
	
	-- Собираем категории с данными и добавляем заголовки групп
	local categories_to_show = {}
	local current_group = nil
	for _, data in ipairs(categories) do
		local key, label, group_name = data[1], data[2], data[3]
		local has_data = false
		
		for _, player_data in pairs(players) do
			if player_data and player_data.account_id then
				local account_id = player_data.account_id
				local kills = 0
				local dmg = 0
				
				if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][key] then
					kills = mod.kills_by_category[account_id][key] or 0
				end
				
				if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][key] then
					dmg = mod.damage_by_category[account_id][key] or 0
				end
				
				if kills > 0 or dmg > 0 then
					has_data = true
					break
				end
			end
		end
		
		if has_data then
			-- Добавляем заголовок группы, если группа изменилась
			if group_name and group_name ~= current_group then
				table.insert(categories_to_show, {type = "group_header", name = "group_" .. group_name, group_name = group_name})
				current_group = group_name
			end
			table.insert(categories_to_show, {type = "data", key = key, label = label})
		end
	end
	
	local index = 1
	
	-- Header
	local header_row = {type = "header", name = "header"}
	local widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, header_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets = row_widgets or {}
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name = widgets_by_name or {}
		widgets_by_name["killsboard_row_header"] = widget
		current_offset = current_offset + row_height
		visible_rows = visible_rows + 1
	end
	index = index + 1
	
	-- Subheader
	local subheader_row = {type = "subheader", name = "subheader"}
	widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, subheader_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name["killsboard_row_subheader"] = widget
		current_offset = current_offset + row_height
		visible_rows = visible_rows + 1
	end
	index = index + 1
	
	-- Data rows и заголовки групп
	for _, category_data in ipairs(categories_to_show) do
		local row_data = category_data
		if not row_data.type then
			row_data.type = "data"
		end
		if not row_data.name then
			row_data.name = row_data.key or row_data.group_name or "unknown"
		end
		widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, row_data, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
		if widget then
			row_widgets[#row_widgets + 1] = widget
			widgets_by_name["killsboard_row_" .. row_data.name] = widget
			current_offset = current_offset + row_height
			-- Увеличиваем visible_rows только для data строк (для чередования цветов)
			if row_data.type == "data" then
				visible_rows = visible_rows + 1
			end
		end
		index = index + 1
	end
	
	-- Total row
	local total_row = {type = "total", name = "total"}
	widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, total_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name["killsboard_row_total"] = widget
		current_offset = current_offset + row_height
	end
	
	return row_widgets, current_offset
end

mod.adjust_killsboard_size = function(self, total_height, killsboard_widget, scenegraph, row_widgets)
	local height = total_height + 75
	height = math.min(height, 900)
	killsboard_widget.style.style_id_1.size[2] = height - 3 -- удалить если захочу вернуть тень
	
	local killsboard_graph = scenegraph.killsboard
	killsboard_graph.size[2] = height
end

local function _is_in_hub()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	local is_in_hub = game_mode_name == "hub"
	return is_in_hub
end

local function _is_in_prologue_hub()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	local is_in_hub = game_mode_name == "prologue_hub"
	return is_in_hub
end

-- Хук для отрисовки виджетов после основной отрисовки, чтобы они были поверх всех элементов
-- Делаем точно как в scoreboard - без изменения start_layer, просто рисуем после func()
mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings, ...)
	func(self, dt, t, input_service, ui_renderer, render_settings, ...)
	
	local killsboard_widget = self._widgets_by_name["killsboard"]
	if killsboard_widget then
		-- Устанавливаем alpha_multiplier для основного виджета (он рисуется автоматически)
		killsboard_widget.alpha_multiplier = self._alpha_multiplier or 1
	end
	
	-- Рисуем строки killsboard после основной отрисовки
	if self.killsboard_row_widgets then
		for _, widget in pairs(self.killsboard_row_widgets) do
			if widget and widget.visible then
				widget.alpha_multiplier = self._alpha_multiplier or 1
				UIWidget.draw(widget, ui_renderer)
			end
		end
	end
end)

mod:hook(CLASS.HudElementTacticalOverlay, "update", function(func, self, dt, t, ui_renderer, render_settings, input_service, ...)
	func(self, dt, t, ui_renderer, render_settings, input_service, ...)
	
	self.killsboard_row_widgets = self.killsboard_row_widgets or {}
	local killsboard_widget = self._widgets_by_name["killsboard"]
	
	local delete = false
	if self._active and not mod.killsboard_hud_active then
		delete = true
	elseif not self._active and mod.killsboard_hud_active then
		delete = true
	end
	
	-- Delete rows
	if delete then
		if self.killsboard_row_widgets then
			for i = 1, #self.killsboard_row_widgets do
				local widget = self.killsboard_row_widgets[i]
				self._widgets_by_name[widget.name] = nil
				self:_unregister_widget_name(widget.name)
			end
			self.killsboard_row_widgets = {}
		end
	end
	
	if self._active and not mod.killsboard_hud_active then
		local players = get_players()
		local row_widgets, total_height = mod:setup_killsboard_row_widgets(self.killsboard_row_widgets, self._widgets_by_name, players, self, "_create_widget", ui_renderer)
		self.killsboard_row_widgets = row_widgets
		
		mod:adjust_killsboard_size(total_height, killsboard_widget, self._ui_scenegraph, self.killsboard_row_widgets)
	end
	
	local in_hub = _is_in_hub()
	local in_prologue_hub = _is_in_prologue_hub()
	if killsboard_widget then
		killsboard_widget.visible = not in_hub and not in_prologue_hub
	end
	if self.killsboard_row_widgets then
		for i = 1, #self.killsboard_row_widgets do
			local widget = self.killsboard_row_widgets[i]
			widget.visible = not in_hub and not in_prologue_hub
		end
	end
	
	mod.killsboard_hud_active = self._active
end)
