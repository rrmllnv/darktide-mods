local mod = get_mod("TeamKills")

local CLASS = CLASS
local Color = Color
local Managers = Managers
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local KillsboardViewSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/killsboard/killsboard_view_settings")
local base_z = 100
local base_x = 0

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

local function get_players()
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
								name = name,
								player = player
							})
						end
					end
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
	
	local row_height = header and _settings.killsboard_row_header_height or _settings.killsboard_row_height
	-- Используем размер шрифта из settings
	local font_size = header and _settings.killsboard_font_size_header or _settings.killsboard_font_size
	
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
		pass_template[1].value = "KILLS BOARD"
		local num_players = 0
		for i = 1, 4 do
			pass_template[k_pass_map[i]].value = ""
			pass_template[d_pass_map[i]].value = ""
			-- Меняем выравнивание на center для заголовка
			pass_template[k_pass_map[i]].style.text_horizontal_alignment = "center"
			-- Увеличиваем размер столбца для имени, чтобы оно поместилось по центру
			pass_template[k_pass_map[i]].style.size[1] = _settings.killsboard_column_player_width
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
				
				if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][category_key] then
					kills = mod.kills_by_category[account_id][category_key] or 0
				end
				
				if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][category_key] then
					dmg = mod.damage_by_category[account_id][category_key] or 0
				end
				
				pass_template[k_pass_map[player_num]].value = tostring(kills)
				pass_template[d_pass_map[player_num]].value = mod.format_number and mod.format_number(dmg) or tostring(dmg)
			end
			player_num = player_num + 1
		end
	end
	
	-- Column backgrounds
	if header or subheader or total then
		-- Скрываем все фоны для header, subheader и total
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
		
		-- Для четных строк: все столбцы - темный
		-- Для нечетных строк: все столбцы - светлый
		local row_color = is_even_row and color_dark or color_light
		
		-- bg_category (столбец категорий) - индекс 14
		pass_template[14].style.size[2] = row_height
		pass_template[14].style.visible = true
		pass_template[14].style.color = row_color
		pass_template[14].style.disabled_color = row_color
		pass_template[14].style.default_color = row_color
		pass_template[14].style.hover_color = row_color
		pass_template[14].style.offset[1] = left_offset
		
		-- bg1 (столбец 1) - индекс 4
		pass_template[4].style.size[2] = row_height
		pass_template[4].style.visible = true
		pass_template[4].style.color = row_color
		pass_template[4].style.disabled_color = row_color
		pass_template[4].style.default_color = row_color
		pass_template[4].style.hover_color = row_color
		pass_template[4].style.offset[1] = left_offset + _settings.killsboard_column_header_width
		
		-- bg2 (столбец 2) - индекс 7
		pass_template[7].style.size[2] = row_height
		pass_template[7].style.visible = true
		pass_template[7].style.color = row_color
		pass_template[7].style.disabled_color = row_color
		pass_template[7].style.default_color = row_color
		pass_template[7].style.hover_color = row_color
		pass_template[7].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width
		
		-- bg3 (столбец 3) - индекс 10
		pass_template[10].style.size[2] = row_height
		pass_template[10].style.visible = true
		pass_template[10].style.color = row_color
		pass_template[10].style.disabled_color = row_color
		pass_template[10].style.default_color = row_color
		pass_template[10].style.hover_color = row_color
		pass_template[10].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2
		
		-- bg4 (столбец 4) - индекс 13
		pass_template[13].style.size[2] = row_height
		pass_template[13].style.visible = true
		pass_template[13].style.color = row_color
		pass_template[13].style.disabled_color = row_color
		pass_template[13].style.default_color = row_color
		pass_template[13].style.hover_color = row_color
		pass_template[13].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3
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
	
	-- Собираем категории с данными
	local categories_to_show = {}
	for _, data in ipairs(categories) do
		local key, label = data[1], data[2]
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
			table.insert(categories_to_show, {key = key, label = label})
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
	
	-- Data rows
	for _, category_data in ipairs(categories_to_show) do
		local row_data = {type = "data", name = category_data.key, key = category_data.key, label = category_data.label}
		widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, row_data, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
		if widget then
			row_widgets[#row_widgets + 1] = widget
			widgets_by_name["killsboard_row_" .. category_data.key] = widget
			current_offset = current_offset + row_height
			visible_rows = visible_rows + 1
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

mod:hook(CLASS.HudElementTacticalOverlay, "_draw_widgets", function(func, self, dt, t, input_service, ui_renderer, render_settings, ...)
	func(self, dt, t, input_service, ui_renderer, render_settings, ...)
	
	local killsboard_widget = self._widgets_by_name["killsboard"]
	if killsboard_widget then
		killsboard_widget.alpha_multiplier = self._alpha_multiplier or 1
	end
	
	if self.killsboard_row_widgets then
		for _, widget in pairs(self.killsboard_row_widgets) do
			widget.alpha_multiplier = self._alpha_multiplier or 1
			UIWidget.draw(widget, ui_renderer)
		end
	end
end)

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
