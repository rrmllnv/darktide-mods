local mod = get_mod("TeamKills")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementBossHealthSettings = require("scripts/ui/hud/elements/boss_health/hud_element_boss_health_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local hud_body_font_settings = UIFontSettings.hud_body or {}

local function get_font_size()
	return mod.font_size or mod:get("opt_font_size") or 16
end

local function get_opacity_alpha()
	local opacity = mod.opacity or mod:get("opt_opacity") or 100
	return math.floor((opacity / 100) * 255)
end

-- Функция для формирования текста урона по боссу
local function format_boss_damage_text(unit)
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
	
	-- Формируем список игроков с уроном
	local players_with_damage = {}
	for account_id, damage in pairs(boss_damage_data) do
		local display_name = current_players[account_id]
		if display_name and damage > 0 then
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
	
	-- Получаем настройки отображения
	local show_total_damage = mod:get("opt_show_boss_total_damage") ~= false
	local show_last_damage = mod:get("opt_show_boss_last_damage") == true
	
	-- Формируем текст
	local lines = {}
	local damage_color = mod.get_damage_color_string()
	local last_damage_color = mod.get_last_damage_color_string()
	local reset_color = "{#reset()}"
	
	for _, player in ipairs(players_with_damage) do
		local dmg = math.floor(player.damage or 0)
		local last_dmg = math.floor(player.last_damage or 0)
		
		local parts = {}
		table.insert(parts, player.name .. ":")
		
		if show_total_damage then
			table.insert(parts, damage_color .. mod.format_number(dmg) .. reset_color)
		end
		
		if show_last_damage and last_dmg > 0 then
			table.insert(parts, "[" .. last_damage_color .. mod.format_number(last_dmg) .. reset_color .. "]")
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

-- Добавляем виджеты для отображения списка игроков в каждую группу виджетов
-- Используем хук после того, как все виджеты созданы (включая RecolorBossHealthBars)
mod:hook_safe(CLASS.HudElementBossHealth, "_setup_widget_groups", function(self)
	local widget_groups = self._widget_groups
	if not widget_groups then
		return
	end
	
	-- Создаем виджеты для всех групп виджетов (включая созданные RecolorBossHealthBars)
	local font_size = get_font_size()
	local health_bar_size_y = HudElementBossHealthSettings.size[2]
	
	for widget_group_index, widget_group in ipairs(widget_groups) do
		if widget_group.health and not widget_group.boss_damage_list then
			local health_widget = widget_group.health
			
			-- Получаем offset health виджета из style для правильного позиционирования
			local health_bar_style = health_widget.style and health_widget.style.bar
			local health_bar_offset = health_bar_style and health_bar_style.offset or {0, -13, 4}
			
			-- Определяем размер полоски жизни (большая для первого, маленькая для остальных)
			local health_bar_size = widget_group_index == 1 and HudElementBossHealthSettings.size or HudElementBossHealthSettings.size_small
			
			-- Создаем виджет для отображения списка игроков и урона
			local damage_list_widget_definition = UIWidget.create_definition({
				{
					pass_type = "text",
					style_id = "text",
					value = "",
					value_id = "text",
					style = {
						font_size = font_size,
						font_type = hud_body_font_settings.font_type or "machine_medium",
						line_spacing = 1.2,
						horizontal_alignment = "left",
						vertical_alignment = "top",
						text_horizontal_alignment = "left",
						text_vertical_alignment = "top",
						text_color = {
							get_opacity_alpha(),
							255,
							255,
							255,
						},
						drop_shadow = true,
						offset = {
							health_bar_offset[1],
							health_bar_offset[2] + health_bar_size_y + 45,
							10,
						},
						size = {
							250,
							200,
						},
					},
				},
			}, "health_bar")
			
			widget_group.boss_damage_list = self:_create_widget("boss_damage_list_" .. widget_group_index, damage_list_widget_definition)
			
			-- Учитываем offset виджета health, если он установлен (для виджетов созданных RecolorBossHealthBars)
			if health_widget.offset then
				widget_group.boss_damage_list.offset[1] = health_widget.offset[1]
				widget_group.boss_damage_list.offset[2] = health_widget.offset[2]
			end
		end
	end
end)

-- Обновляем виджеты со списком игроков и урона
mod:hook_safe(CLASS.HudElementBossHealth, "update", function(self, dt, t, ui_renderer, render_settings, input_service)
	local is_active = self._is_active
	
	if not is_active then
		return
	end
	
	local widget_groups = self._widget_groups
	local active_targets_array = self._active_targets_array
	local num_active_targets = #active_targets_array
	local num_health_bars_to_update = math.min(num_active_targets, self._max_health_bars)
	
	-- Создаем виджеты для всех групп виджетов, которые еще не имеют нашего виджета
	-- Это нужно на случай, если RecolorBossHealthBars добавил виджеты после нашего хука _setup_widget_groups
	local font_size = get_font_size()
	local health_bar_size_y = HudElementBossHealthSettings.size[2]
	
	for widget_group_index, widget_group in ipairs(widget_groups) do
		if widget_group.health and not widget_group.boss_damage_list then
			local health_widget = widget_group.health
			
			-- Получаем offset health виджета из style для правильного позиционирования
			local health_bar_style = health_widget.style and health_widget.style.bar
			local health_bar_offset = health_bar_style and health_bar_style.offset or {0, -13, 4}
			
			-- Определяем размер полоски жизни (большая для первого, маленькая для остальных)
			local health_bar_size = widget_group_index == 1 and HudElementBossHealthSettings.size or HudElementBossHealthSettings.size_small
			
			-- Создаем виджет для отображения списка игроков и урона
			local damage_list_widget_definition = UIWidget.create_definition({
				{
					pass_type = "text",
					style_id = "text",
					value = "",
					value_id = "text",
					style = {
						font_size = font_size,
						font_type = hud_body_font_settings.font_type or "machine_medium",
						line_spacing = 1.2,
						horizontal_alignment = "left",
						vertical_alignment = "top",
						text_horizontal_alignment = "left",
						text_vertical_alignment = "top",
						text_color = {
							get_opacity_alpha(),
							255,
							255,
							255,
						},
						drop_shadow = true,
						offset = {
							health_bar_offset[1],
							health_bar_offset[2] + health_bar_size_y + 45,
							10,
						},
						size = {
							250,
							200,
						},
					},
				},
			}, "health_bar")
			
			widget_group.boss_damage_list = self:_create_widget("boss_damage_list_" .. widget_group_index, damage_list_widget_definition)
			
			-- Учитываем offset виджета health, если он установлен (для виджетов созданных RecolorBossHealthBars)
			if health_widget.offset then
				widget_group.boss_damage_list.offset[1] = health_widget.offset[1]
				widget_group.boss_damage_list.offset[2] = health_widget.offset[2]
			end
		end
	end
	
	for i = 1, num_health_bars_to_update do
		local widget_group_index = num_active_targets > 1 and i + 1 or i
		local widget_group = widget_groups[widget_group_index]
		local target = active_targets_array[i]
		local unit = target.unit
		
		if ALIVE[unit] and widget_group.boss_damage_list then
			local damage_widget = widget_group.boss_damage_list
			
			-- Проверка настройки "Показать Boss Damage Tracker"
			local show_tracker = mod:get("opt_show_boss_damage_tracker")
			if show_tracker == false then
				damage_widget.content.text = ""
				damage_widget.visible = false
				goto continue
			end
			
			-- Проверка: если обе опции выключены, нечего показывать
			local show_total_damage = mod:get("opt_show_boss_total_damage") ~= false
			local show_last_damage = mod:get("opt_show_boss_last_damage") == true
			if not show_total_damage and not show_last_damage then
				damage_widget.content.text = ""
				damage_widget.visible = false
				goto continue
			end
			
			-- Обновляем offset виджета, если health виджет имеет offset (для виджетов созданных RecolorBossHealthBars)
			local health_widget = widget_group.health
			if health_widget and health_widget.offset then
				damage_widget.offset[1] = health_widget.offset[1]
				damage_widget.offset[2] = health_widget.offset[2]
			end
			
			-- Обновляем альфа-канал текста
			local text_style = damage_widget.style and damage_widget.style.text
			if text_style and text_style.text_color then
				local alpha = get_opacity_alpha()
				text_style.text_color[1] = alpha
			end
			
			-- Получаем текст урона
			local damage_lines = format_boss_damage_text(unit)
			
			if damage_lines and #damage_lines > 0 then
				damage_widget.content.text = table.concat(damage_lines, "\n")
				damage_widget.visible = true
			else
				damage_widget.content.text = ""
				damage_widget.visible = false
			end
			::continue::
		end
	end
end)
