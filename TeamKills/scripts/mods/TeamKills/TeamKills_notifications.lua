local mod = get_mod("TeamKills")

local ConstantElementNotificationFeed = mod:original_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed")

-- Функция для формирования текста урона для уведомления с цветами
local function format_boss_damage_text_for_notification(unit)
	local boss_damage_data = mod.boss_damage and mod.boss_damage[unit]
	if not boss_damage_data or not next(boss_damage_data) then
		return nil
	end
	
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
	
	-- Формируем список игроков с уроном
	local players_with_damage = {}
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
			table.insert(players_with_damage, {
				name = display_name,
				damage = damage,
				last_damage = last_damage,
				account_id = account_id
			})
		end
	end
	
	-- Сортируем по урону (больше сверху)
	table.sort(players_with_damage, function(a, b)
		return a.damage > b.damage
	end)
	
	-- Формируем текст с цветами для уведомления (как в StimmCountdown)
	local lines = {}
	for _, player in ipairs(players_with_damage) do
		local dmg = math.floor(player.damage or 0)
		local damage_number = mod.format_number(dmg)
		local damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], damage_number)
		local line = player.name .. ": " .. damage_text
		table.insert(lines, line)
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
		
		-- Если есть строки, заменяем texts на разбитые строки
		if #lines > 0 then
			notification_data.texts = lines
		end
	end
	
	return notification_data
end)

-- Отправляем уведомление при смерти босса с информацией об уроне
mod:hook_safe(CLASS.HudElementBossHealth, "event_boss_encounter_end", function(self, unit, boss_extension)
	-- Получаем данные об уроне по этому боссу
	local damage_lines = format_boss_damage_text_for_notification(unit)
	
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
