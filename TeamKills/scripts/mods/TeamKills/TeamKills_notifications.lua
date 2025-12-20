local mod = get_mod("TeamKills")

local ConstantElementNotificationFeed = mod:original_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed")
local UISettings = require("scripts/settings/ui/ui_settings")

-- Функция для получения цвета игрока по account_id
local function get_player_color(account_id)
	if not account_id or not Managers.player then
		return nil
	end
	
	local players = Managers.player:players()
	for _, player in pairs(players) do
		if player then
			local player_account_id = player:account_id() or player:name()
			if player_account_id == account_id then
				local slot = player:slot()
				if slot and UISettings.player_slot_colors[slot] then
					local color = UISettings.player_slot_colors[slot]
					-- Color формат: [alpha, r, g, b]
					return {color[2], color[3], color[4]}
				end
				break
			end
		end
	end
	
	return nil
end

-- Функция для формирования текста урона для уведомления с цветами
local function format_boss_damage_text_for_notification(unit, boss_extension)
	local boss_damage_data = mod.boss_damage and mod.boss_damage[unit]
	if not boss_damage_data or not next(boss_damage_data) then
		return nil
	end
	
	-- Получаем настройки отображения
	local show_total_damage = mod:get("opt_show_boss_total_damage") ~= false
	local show_last_damage = mod:get("opt_show_boss_last_damage") == true
	
	-- Получаем список текущих игроков
	local current_players = {}
	if Managers.player then
		local players = Managers.player:players()
		for _, player in pairs(players) do
			if player then
				local account_id = player:account_id() or player:name()
				local character_name = player.character_name and player:character_name()
				if account_id then
					current_players[account_id] = character_name or player:name() or account_id
				end
			end
		end
	end
	
	-- Получаем данные о последнем уроне по этому боссу
	local boss_last_damage_data = mod.boss_last_damage and mod.boss_last_damage[unit]
	
	-- Получаем цвета RGB
	local damage_color_name = mod.damage_color or "orange"
	local damage_rgb = mod.color_presets[damage_color_name] or mod.color_presets["orange"]
	local last_damage_color_name = mod.last_damage_color or "orange"
	local last_damage_rgb = mod.color_presets[last_damage_color_name] or mod.color_presets["orange"]
	local white_rgb = mod.color_presets["white"] or {255, 255, 255}
	
	-- Формируем список игроков с уроном
	local players_with_damage = {}
	local total_damage = 0
	for account_id, damage in pairs(boss_damage_data) do
		if damage > 0 then
			-- Получаем имя игрока
			local display_name = current_players[account_id]
			-- Если имя не найдено в текущих игроках, пробуем найти по account_id
			if not display_name then
				if Managers.player then
					local players = Managers.player:players()
					for _, player in pairs(players) do
						if player then
							local player_account_id = player:account_id() or player:name()
							if player_account_id == account_id then
								display_name = player.character_name and player:character_name() or player:name() or tostring(account_id)
								break
							end
						end
					end
				end
				-- Если все еще не нашли, используем account_id как имя
				if not display_name then
					display_name = tostring(account_id)
				end
			end
			
			local last_damage = boss_last_damage_data and boss_last_damage_data[account_id] or 0
			total_damage = total_damage + damage
			-- Получаем цвет игрока
			local player_color = get_player_color(account_id)
			table.insert(players_with_damage, {
				name = display_name,
				damage = damage,
				last_damage = last_damage,
				account_id = account_id,
				player_color = player_color
			})
		end
	end
	
	-- Сортируем по урону (больше сверху)
	table.sort(players_with_damage, function(a, b)
		return a.damage > b.damage
	end)
	
	-- Находим игрока с максимальным уроном и последним ударом
	local max_damage_player = players_with_damage[1]
	local max_last_damage_player = nil
	local max_last_damage = 0
	for _, player in ipairs(players_with_damage) do
		if player.last_damage > max_last_damage then
			max_last_damage = player.last_damage
			max_last_damage_player = player
		end
	end
	
	-- Получаем название босса
	local boss_name = ""
	if boss_extension then
		local display_name = boss_extension:display_name()
		if display_name then
			boss_name = Localize(display_name)
		end
	end
	if boss_name == "" then
		local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
		if unit_data_extension then
			local breed = unit_data_extension:breed()
			if breed and breed.display_name then
				boss_name = Localize(breed.display_name)
			end
		end
	end
	if boss_name == "" then
		boss_name = mod:localize("i18n_notification_boss_default")
	end
	
	-- Формируем текст с цветами для уведомления
	local lines = {}
	
	-- Заголовок с названием босса
	local boss_name_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", white_rgb[1], white_rgb[2], white_rgb[3], boss_name)
	table.insert(lines, boss_name_text)
	
	-- Общий урон команды
	if show_total_damage and total_damage > 0 then
		local total_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], mod.format_number(math.floor(total_damage)))
		table.insert(lines, mod:localize("i18n_notification_total") .. total_damage_text)
	end
	
	-- Игрок с максимальным уроном
	if max_damage_player then
		local max_dmg = math.floor(max_damage_player.damage or 0)
		local max_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], mod.format_number(max_dmg))
		local max_percent = total_damage > 0 and math.floor((max_dmg / total_damage) * 100) or 0
		-- Применяем цвет к нику игрока
		local player_name = max_damage_player.name
		if max_damage_player.player_color then
			player_name = string.format("{#color(%d,%d,%d)}%s{#reset()}", max_damage_player.player_color[1], max_damage_player.player_color[2], max_damage_player.player_color[3], player_name)
		end
		table.insert(lines, mod:localize("i18n_notification_top") .. player_name .. " (" .. max_percent .. "%)" .. " " .. max_damage_text)
	end
	
	-- Игрок с последним ударом
	if show_last_damage and max_last_damage_player and max_last_damage > 0 then
		local last_dmg = math.floor(max_last_damage)
		local last_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", last_damage_rgb[1], last_damage_rgb[2], last_damage_rgb[3], mod.format_number(last_dmg))
		-- Применяем цвет к нику игрока
		local player_name = max_last_damage_player.name
		if max_last_damage_player.player_color then
			player_name = string.format("{#color(%d,%d,%d)}%s{#reset()}", max_last_damage_player.player_color[1], max_last_damage_player.player_color[2], max_last_damage_player.player_color[3], player_name)
		end
		table.insert(lines, mod:localize("i18n_notification_last_hit") .. player_name .. " [" .. last_damage_text .. "]")
	end
	
	-- Разделитель
	if #players_with_damage > 0 then
		table.insert(lines, " ")
	end
	
	-- Список всех игроков с уроном и процентом
	for _, player in ipairs(players_with_damage) do
		local dmg = math.floor(player.damage or 0)
		local damage_number = mod.format_number(dmg)
		local percent = total_damage > 0 and math.floor((dmg / total_damage) * 100) or 0
		
		local parts = {}
		-- Ник игрока с цветом
		local player_name = player.name
		if player.player_color then
			player_name = string.format("{#color(%d,%d,%d)}%s{#reset()}", player.player_color[1], player.player_color[2], player.player_color[3], player_name)
		end
		table.insert(parts, player_name)
		
		-- Проценты
		if show_total_damage and total_damage > 0 then
			table.insert(parts, "(" .. percent .. "%)")
		end
		
		-- Двоеточие
		table.insert(parts, ":")
		
		-- Урон
		if show_total_damage then
			local damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], damage_number)
			table.insert(parts, damage_text)
		end
		
		-- Последний урон
		if show_last_damage and player.last_damage > 0 then
			local last_dmg = math.floor(player.last_damage)
			local last_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", last_damage_rgb[1], last_damage_rgb[2], last_damage_rgb[3], mod.format_number(last_dmg))
			table.insert(parts, "[" .. last_damage_text .. "]")
		end
		
		if #parts > 1 then
			table.insert(lines, table.concat(parts, " "))
		end
	end
	
	if #lines > 0 then
		return lines
	else
		return nil
	end
end

-- Перехватываем _generate_notification_data чтобы разбить line_1 с \n на отдельные строки
mod:hook(ConstantElementNotificationFeed, "_generate_notification_data", function(func, self, message_type, data)
	local notification_data = func(self, message_type, data)
	
	-- Для custom уведомлений разбиваем line_1 с \n на отдельные строки
	if message_type == "custom" and notification_data and data and data.line_1 then
		-- Разбиваем line_1 по \n на отдельные строки
		local lines = {}
		for line in string.gmatch(data.line_1, "([^\n]+)") do
			if line and line ~= "" then
				table.insert(lines, {
					display_name = line,
					color = data.line_1_color,
				})
			end
		end
		
		-- Ограничиваем количество строк до 3 (максимум, который поддерживает виджет)
		-- Если строк больше, объединяем остальные в последнюю строку
		if #lines > 0 then
			if #lines > 3 then
				-- Объединяем строки с 4-й и далее в третью строку
				local extra_lines = {}
				for i = 4, #lines do
					table.insert(extra_lines, lines[i].display_name)
				end
				lines[3].display_name = lines[3].display_name .. "\n" .. table.concat(extra_lines, "\n")
				-- Оставляем только первые 3 строки
				for i = 4, #lines do
					lines[i] = nil
				end
			end
			
			-- Заменяем texts на разбитые строки, сохраняя структуру
			notification_data.texts = {}
			for i = 1, math.min(#lines, 3) do
				notification_data.texts[i] = lines[i]
			end
		end
	end
	
	return notification_data
end)

-- Отправляем уведомление при смерти босса с информацией об уроне
mod:hook_safe(CLASS.HudElementBossHealth, "event_boss_encounter_end", function(self, unit, boss_extension)
	-- Проверяем, включены ли уведомления
	if mod:get("opt_show_boss_death_notification") == false then
		return
	end
	
	-- Получаем данные об уроне по этому боссу
	local damage_lines = format_boss_damage_text_for_notification(unit, boss_extension)
	
	if damage_lines and #damage_lines > 0 then
		-- Объединяем все строки в line_1 с переносами \n - система автоматически разобьет на строки
		local all_lines = table.concat(damage_lines, "\n")
		local notification_data = {
			line_1 = all_lines,
			show_shine = false,
		}
		
		-- Отправляем уведомление с информацией об уроне
		if Managers.event then
			Managers.event:trigger("event_add_notification_message", "custom", notification_data)
		end
	end
	
	-- Очищаем данные об уроне по боссу после отправки уведомления
	if mod.boss_damage and mod.boss_damage[unit] then
		mod.boss_damage[unit] = nil
	end
	if mod.boss_last_damage and mod.boss_last_damage[unit] then
		mod.boss_last_damage[unit] = nil
	end
end)
