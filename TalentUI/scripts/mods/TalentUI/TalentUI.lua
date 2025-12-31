local mod = get_mod("TalentUI")

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"
local PLAYER_ABILITY_DEF_PATH = "scripts/ui/hud/elements/player_ability/hud_element_player_ability_vertical_definitions"

-- Значения по умолчанию для настроек
local DEFAULT_SETTINGS = {
	icon_position_offset = 12,
	icon_position_left_shift = 20,
	icon_position_vertical_offset = 0,
	ability_icon_size = 128,
	cooldown_font_size = 18,
}

-- Функция для загрузки настроек из файла (для возможности изменения в реальном времени)
local function load_settings()
	local success, result = pcall(function()
		return mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")
	end)
	
	if success and result and type(result) == "table" then
		-- Проверяем, что все необходимые поля присутствуют
		if result.icon_position_offset and result.icon_position_left_shift then
			-- vertical_offset опционален, используем 0 по умолчанию
			if not result.icon_position_vertical_offset then
				result.icon_position_vertical_offset = 0
			end
			return result
		else
			mod:warning("TalentUI: Settings file loaded but missing required fields, using defaults")
			return DEFAULT_SETTINGS
		end
	else
		if not success then
			mod:warning("TalentUI: Error loading settings file: " .. tostring(result) .. ", using defaults")
		else
			mod:warning("TalentUI: Settings file returned nil or invalid type, using defaults")
		end
		return DEFAULT_SETTINGS
	end
end

-- Загружаем файл настроек при старте
local TalentUISettings = load_settings()

local backups = mod:persistent_table("talent_ui_backups")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")
local FixedFrame = require("scripts/utilities/fixed_frame")

local ability_configuration = PlayerCharacterConstants.ability_configuration

-- Хранение данных о кулдаунах
local ability_data = {} -- player_name -> {cooldown_timer, max_cooldown, ability_id, icon}

-- Константы
local ABILITY_ICON_SIZE = 60
local COOLDOWN_FONT_SIZE = TalentUISettings.cooldown_font_size

-- Функция для получения данных об экипированной способности игрока
-- Использует API из HudElementPlayerAbilityHandler
local function get_player_ability_data(player, extensions)
	if not extensions or not extensions.ability then
		mod:echo("TalentUI: get_player_ability_data - no extensions or ability extension")
		return nil
	end
	
	local ability_extension = extensions.ability
	local equipped_abilities = ability_extension:equipped_abilities()
	
	if not equipped_abilities then
		mod:echo("TalentUI: get_player_ability_data - equipped_abilities() returned nil")
		return nil
	end
	
	-- Отладка: выводим все способности
	local ability_count = 0
	local abilities_list = {}
	for ability_id, ability_settings in pairs(equipped_abilities) do
		ability_count = ability_count + 1
		local slot_id = ability_configuration[ability_id]
		table.insert(abilities_list, ability_id .. " -> " .. tostring(slot_id))
	end
	mod:echo("TalentUI: Found " .. ability_count .. " abilities: " .. table.concat(abilities_list, ", "))
	
	-- Ищем combat_ability как в оригинальном HUD
	-- slot_id это "slot_combat_ability", а не "combat_ability"!
	for ability_id, ability_settings in pairs(equipped_abilities) do
		local slot_id = ability_configuration[ability_id]
		mod:echo("TalentUI: Checking ability " .. ability_id .. " -> slot_id: " .. tostring(slot_id))
		if slot_id == "slot_combat_ability" then
			mod:echo("TalentUI: Found combat_ability: " .. ability_id .. " icon: " .. tostring(ability_settings.hud_icon))
			return {
				ability_id = ability_id,
				ability_type = "combat_ability", -- Используем "combat_ability" для компонента
				icon = ability_settings.hud_icon,
				name = ability_settings.name,
			}
		end
	end
	
	mod:echo("TalentUI: No combat_ability found in equipped_abilities")
	return nil
end

-- Функция для получения прогресса и состояния кулдауна
-- Использует методы PlayerHuskAbilityExtension из исходников
local function get_ability_cooldown_state(player, extensions, ability_type)
	if not extensions or not extensions.ability then
		return 1, false, 1, true -- полный прогресс, не на кулдауне, 1 заряд, есть заряды
	end
	
	local ability_extension = extensions.ability
	
	-- Используем методы extension как в HudElementPlayerAbility
	if not ability_extension:ability_is_equipped(ability_type) then
		return 1, false, 1, true
	end
	
	-- Безопасные методы из PlayerHuskAbilityExtension
	local remaining_ability_cooldown = ability_extension:remaining_ability_cooldown(ability_type)
	local max_ability_cooldown = ability_extension:max_ability_cooldown(ability_type)
	local remaining_ability_charges = ability_extension:remaining_ability_charges(ability_type)
	local max_ability_charges = ability_extension:max_ability_charges(ability_type)
	
	local uses_charges = max_ability_charges and max_ability_charges > 1
	local has_charges_left = remaining_ability_charges > 0
	
	local cooldown_progress = 1
	
	-- Логика из HudElementPlayerAbility.update
	if max_ability_cooldown and max_ability_cooldown > 0 then
		cooldown_progress = 1 - math.lerp(0, 1, remaining_ability_cooldown / max_ability_cooldown)
		if cooldown_progress == 0 then
			cooldown_progress = 1
		end
	else
		cooldown_progress = uses_charges and 1 or 0
	end
	
	local on_cooldown = cooldown_progress ~= 1
	
	return cooldown_progress, on_cooldown, remaining_ability_charges or 1, has_charges_left
end

-- Функция для получения цветов состояния способности
local function get_ability_state_colors(on_cooldown, uses_charges, has_charges_left)
	local source_colors
	
	if on_cooldown then
		if uses_charges then
			if has_charges_left then
				source_colors = HudElementPlayerAbilitySettings.has_charges_cooldown_colors
			else
				source_colors = HudElementPlayerAbilitySettings.out_of_charges_cooldown_colors
			end
		else
			source_colors = HudElementPlayerAbilitySettings.cooldown_colors
		end
	elseif not uses_charges or uses_charges and has_charges_left then
		source_colors = HudElementPlayerAbilitySettings.active_colors
	else
		source_colors = HudElementPlayerAbilitySettings.inactive
	end
	
	return source_colors
end

-- Сохраняем оригинальные определения
backups.team_hud_definitions = backups.team_hud_definitions or mod:original_require(TEAM_HUD_DEF_PATH)

-- Добавление виджетов иконок способностей в team HUD
mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
	mod:echo("TalentUI: Creating widgets in hook_require")
	-- Всегда добавляем виджеты, контролируем видимость через visible
	local bar_size = HudElementTeamPlayerPanelSettings.size
	-- Используем размер иконки из файла настроек или из настроек мода
	local icon_size = mod:get("ability_icon_size") or TalentUISettings.ability_icon_size
	-- В исходниках frame имеет размер 128x128, а icon_size = 80x80
	-- Используем разные размеры: иконка меньше рамки
	local frame_size = icon_size -- Рамка использует размер из настройки
	local icon_size_value = math.floor(icon_size * 0.625) -- 80/128 = 0.625 (как в исходниках)
	-- Позиционирование из файла настроек
	local base_offset = TalentUISettings.icon_position_offset
	local left_shift = TalentUISettings.icon_position_left_shift
	local vertical_offset = TalentUISettings.icon_position_vertical_offset or 0
	
	-- Виджет иконки способности (справа от рамки, как цифры в NumericUI)
	instance.widget_definitions.talent_ui_ability_icon = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "icon",
			value = "content/ui/materials/icons/talents/hud/combat_container",
			style = {
				-- В исходниках иконка не имеет явного размера и заполняет scenegraph
				-- У нас иконка центрируется внутри рамки через offset
				horizontal_alignment = "right",
				vertical_alignment = "center",
				material_values = {
					progress = 1,
					talent_icon = nil,
				},
				-- Позиционируем иконку: базовое смещение рамки минус половина разницы размеров для центрирования
				-- минус дополнительный сдвиг влево
				offset = {
					base_offset - (frame_size - icon_size_value) / 2 - left_shift, -- Центрируем внутри рамки + сдвиг влево
					vertical_offset,
					1,
				},
				size = {
					icon_size_value,
					icon_size_value,
				},
				color = UIHudSettings.color_tint_main_2,
			},
			change_function = function(content, style)
				local duration_progress = content.duration_progress or 1
				style.material_values.progress = duration_progress
			end,
		},
		{
			pass_type = "texture",
			style_id = "frame",
			value = "content/ui/materials/icons/talents/hud/combat_frame_inner",
			style = {
				-- В исходниках рамка использует horizontal_alignment = "center" для центрирования
				-- У нас используем "right" для выравнивания с цифрами, поэтому offset задаем явно
				horizontal_alignment = "right",
				vertical_alignment = "center",
				-- Базовое позиционирование рамки: справа от scenegraph (как цифры в NumericUI)
				offset = {
					base_offset - left_shift, -- Базовое смещение минус сдвиг влево
					vertical_offset,
					2,
				},
				size = {
					frame_size,
					frame_size,
				},
				color = UIHudSettings.color_tint_main_2,
			},
		},
	}, "bar")
	
	mod:echo("TalentUI: Created talent_ui_ability_icon widget")
	
	-- Виджет текста кулдауна (справа от иконки, поверх иконки)
	instance.widget_definitions.talent_ui_ability_cooldown = UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "text",
			value_id = "text",
			value = "",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				font_type = "machine_medium",
				font_size = mod:get("cooldown_font_size") or TalentUISettings.cooldown_font_size,
				text_color = UIHudSettings.color_tint_main_1,
				drop_shadow = true,
				-- Позиционируем текст кулдауна поверх иконки (центрируем относительно рамки)
				offset = {
					base_offset - (frame_size - icon_size_value) / 2 - left_shift,
					vertical_offset,
					3,
				},
				size = {
					icon_size_value,
					icon_size_value,
				},
			},
		},
	}, "bar")
	
	mod:echo("TalentUI: Created talent_ui_ability_cooldown widget")
end)

-- Добавление кулдауна для локального игрока (как в NumericUI)
mod:hook(_G, "dofile", function(func, path)
	local instance = func(path)
	
	if path == PLAYER_ABILITY_DEF_PATH then
		local style = table.clone(UIFontSettings.hud_body)
		style.text_horizontal_alignment = "center"
		style.text_vertical_alignment = "center"
		style.font_size = mod:get("cooldown_font_size") or TalentUISettings.cooldown_font_size
		style.font_type = "machine_medium"
		style.drop_shadow = true
		
		instance.scenegraph_definition.cooldown = {
			parent = "slot",
			vertical_alignment = "center",
			horizontal_alignment = "center",
			size = HudElementPlayerAbilitySettings.icon_size,
			position = {
				0,
				0,
				10,
			},
		}
		
		instance.widget_definitions.cooldown_timer = UIWidget.create_definition({
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = "",
				style = style,
			},
		}, "cooldown")
	end
	
	return instance
end)

-- Обновление иконки способности для тимейта
local function update_teammate_ability_icon(self, player, dt)
	local player_name = player:name()
	mod:echo("TalentUI: update_teammate_ability_icon called for " .. player_name)
	
	local ability_icon_widget = self._widgets_by_name.talent_ui_ability_icon
	local ability_cooldown_widget = self._widgets_by_name.talent_ui_ability_cooldown
	
	if not ability_icon_widget then
		mod:echo("TalentUI: Widget talent_ui_ability_icon NOT FOUND for " .. player_name)
		-- Выводим список всех виджетов
		if self._widgets_by_name then
			local widget_names = {}
			for name, _ in pairs(self._widgets_by_name) do
				table.insert(widget_names, name)
			end
			mod:echo("TalentUI: Available widgets: " .. table.concat(widget_names, ", "))
		end
		return
	end
	
	mod:echo("TalentUI: Widget found for " .. player_name)
	
	-- Проверяем настройку
	local show_setting = mod:get("show_teammate_ability_icon")
	mod:echo("TalentUI: show_teammate_ability_icon setting = " .. tostring(show_setting))
	
	if not show_setting then
		mod:echo("TalentUI: Setting disabled for " .. player_name)
		ability_icon_widget.visible = false
		if ability_cooldown_widget then
			ability_cooldown_widget.visible = false
		end
		return
	end
	
	local extensions = self:_player_extensions(player)
	
	if not extensions then
		mod:echo("TalentUI: No extensions for " .. player_name)
		return
	end
	
	mod:echo("TalentUI: Extensions found for " .. player_name .. ", ability extension: " .. tostring(extensions.ability))
	
	-- Скрываем виджеты если игрок мертв
	if self._show_as_dead or self._dead or self._hogtied then
		mod:echo("TalentUI: Player dead/hogtied for " .. player_name)
		ability_icon_widget.visible = false
		if ability_cooldown_widget then
			ability_cooldown_widget.visible = false
		end
		return
	end
	
	-- Получаем данные о способности (проверяем каждый раз, т.к. способность может загрузиться позже)
	if not ability_data[player_name] or not ability_data[player_name].ability_type then
		mod:echo("TalentUI: Getting ability data for " .. player_name)
		local ability_info = get_player_ability_data(player, extensions)
		if ability_info then
			ability_data[player_name] = {
				ability_id = ability_info.ability_id,
				ability_type = ability_info.ability_type,
				icon = ability_info.icon,
			}
			mod:echo("TalentUI: Found ability for " .. player_name .. ": " .. ability_info.name .. " icon: " .. tostring(ability_info.icon))
		else
			mod:echo("TalentUI: No ability found for " .. player_name)
			-- Способность еще не загружена, скрываем виджеты
			ability_icon_widget.visible = false
			if ability_cooldown_widget then
				ability_cooldown_widget.visible = false
			end
			return
		end
	end
	
	local ability_type = ability_data[player_name].ability_type
	local icon = ability_data[player_name].icon
	
	-- Обновляем размер иконки и рамки из настроек
	-- В исходниках frame = 128x128, icon_size = 80x80 (соотношение 0.625)
	local frame_size = mod:get("ability_icon_size") or 128
	local icon_size_value = math.floor(frame_size * 0.625) -- 80/128 = 0.625
	
	-- Обновляем размеры только если они изменились
	if ability_icon_widget.style.icon.size[1] ~= icon_size_value then
		ability_icon_widget.style.icon.size[1] = icon_size_value
		ability_icon_widget.style.icon.size[2] = icon_size_value
		ability_icon_widget.dirty = true
	end
	
	-- Позиционирование из файла настроек (перезагружаем каждый кадр для возможности изменения в реальном времени)
	local settings = load_settings()
	if not settings then
		settings = DEFAULT_SETTINGS
	end
	local base_offset = settings.icon_position_offset or DEFAULT_SETTINGS.icon_position_offset
	local left_shift = settings.icon_position_left_shift or DEFAULT_SETTINGS.icon_position_left_shift
	local vertical_offset = settings.icon_position_vertical_offset or DEFAULT_SETTINGS.icon_position_vertical_offset
	
	-- Проверяем, нужно ли обновить размер или позицию
	local needs_offset_update = false
	if ability_icon_widget.style.frame.size[1] ~= frame_size then
		ability_icon_widget.style.frame.size[1] = frame_size
		ability_icon_widget.style.frame.size[2] = frame_size
		ability_icon_widget.dirty = true
		needs_offset_update = true
	end
	
	-- Обновляем offset каждый кадр (для возможности изменения в реальном времени через файл настроек)
	local current_frame_offset = ability_icon_widget.style.frame.offset[1]
	local current_frame_vertical = ability_icon_widget.style.frame.offset[2]
	local new_frame_offset = base_offset - left_shift
	local offset_adjustment = (frame_size - icon_size_value) / 2
	local new_icon_offset = base_offset - offset_adjustment - left_shift
	
	-- Обновляем только если позиция изменилась
	if needs_offset_update or current_frame_offset ~= new_frame_offset or ability_icon_widget.style.icon.offset[1] ~= new_icon_offset or current_frame_vertical ~= vertical_offset then
		ability_icon_widget.style.frame.offset[1] = new_frame_offset
		ability_icon_widget.style.frame.offset[2] = vertical_offset
		ability_icon_widget.style.icon.offset[1] = new_icon_offset
		ability_icon_widget.style.icon.offset[2] = vertical_offset
		ability_icon_widget.dirty = true
	end
	
	if ability_cooldown_widget then
		-- Обновляем размер текста кулдауна только если изменился
		if ability_cooldown_widget.style.text.size[1] ~= icon_size_value then
			ability_cooldown_widget.style.text.size[1] = icon_size_value
			ability_cooldown_widget.style.text.size[2] = icon_size_value
			ability_cooldown_widget.dirty = true
		end
		
		-- Обновляем offset текста кулдауна каждый кадр (для возможности изменения в реальном времени)
		local offset_adjustment = (frame_size - icon_size_value) / 2
		local new_text_offset = base_offset - offset_adjustment - left_shift
		local current_text_offset = ability_cooldown_widget.style.text.offset[1]
		local current_text_vertical = ability_cooldown_widget.style.text.offset[2]
		if current_text_offset ~= new_text_offset or current_text_vertical ~= vertical_offset then
			ability_cooldown_widget.style.text.offset[1] = new_text_offset
			ability_cooldown_widget.style.text.offset[2] = vertical_offset
			ability_cooldown_widget.dirty = true
		end
	end
	
	-- Устанавливаем иконку
	if ability_icon_widget.style.icon.material_values.talent_icon ~= icon then
		ability_icon_widget.style.icon.material_values.talent_icon = icon
		ability_icon_widget.dirty = true
	end
	
	-- Получаем состояние кулдауна
	local cooldown_progress, on_cooldown, remaining_charges, has_charges_left = get_ability_cooldown_state(player, extensions, ability_type)
	local uses_charges = remaining_charges > 1
	
	-- Обновляем прогресс
	if ability_icon_widget.content.duration_progress ~= cooldown_progress then
		ability_icon_widget.content.duration_progress = cooldown_progress
		ability_icon_widget.dirty = true
	end
	
	-- Обновляем цвета
	local source_colors = get_ability_state_colors(on_cooldown, uses_charges, has_charges_left)
	
	if source_colors.icon then
		ability_icon_widget.style.icon.color = table.clone(source_colors.icon)
		ability_icon_widget.dirty = true
	end
	
	if source_colors.frame then
		ability_icon_widget.style.frame.color = table.clone(source_colors.frame)
		ability_icon_widget.dirty = true
	end
	
	ability_icon_widget.visible = true
	mod:echo("TalentUI: Setting visible=true for " .. player_name .. " icon: " .. tostring(icon))
	
	-- Обновляем текст кулдауна
	if ability_cooldown_widget and mod:get("show_teammate_ability_cooldown") then
		if on_cooldown and extensions and extensions.unit_data then
			local unit_data_extension = extensions.unit_data
			local ability_component = unit_data_extension:read_component("combat_ability")
			
			if ability_component then
				local format_type = mod:get("cooldown_format")
				local cooldown_text = ""
				
				if format_type == "time" then
					local fixed_frame_t = FixedFrame.get_latest_fixed_time()
					local time_remaining = math.max(ability_component.cooldown - fixed_frame_t, 0)
					
					if time_remaining <= 1 then
						cooldown_text = string.format("%.1f", time_remaining)
					else
						cooldown_text = string.format("%d", math.ceil(time_remaining))
					end
				elseif format_type == "percent" then
					local percent = cooldown_progress * 100
					cooldown_text = string.format("%d%%", math.floor(percent))
				end
				
				ability_cooldown_widget.content.text = cooldown_text
				ability_cooldown_widget.visible = true
				ability_cooldown_widget.dirty = true
			else
				ability_cooldown_widget.visible = false
			end
		else
			ability_cooldown_widget.visible = false
			ability_cooldown_widget.dirty = true
		end
	end
end

-- Обновление кулдауна для локального игрока
mod:hook_safe("HudElementPlayerAbility", "update", function(self)
	if not mod:get("show_local_ability_cooldown") then
		return
	end
	
	local widgets_by_name = self._widgets_by_name
	local text_widget = widgets_by_name.cooldown_timer
	
	if not text_widget then
		return
	end
	
	local progress = self._ability_progress
	local on_cooldown = self._on_cooldown
	local format_type = mod:get("cooldown_format")
	
	if not on_cooldown or progress >= 1 then
		text_widget.content.text = ""
	else
		if format_type == "time" then
			local player = self._data.player
			local player_unit = player.player_unit
			
			if ALIVE[player_unit] then
				local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
				local ability_component = unit_data_extension:read_component("combat_ability")
				local time = Managers.time:time("gameplay")
				local time_remaining = ability_component.cooldown - time
				
				if time_remaining <= 1 then
					text_widget.content.text = string.format("%.1f", time_remaining)
				else
					text_widget.content.text = string.format("%d", math.ceil(time_remaining))
				end
			end
		elseif format_type == "percent" then
			local percent = progress * 100
			text_widget.content.text = string.format("%d%%", math.floor(percent))
		else
			text_widget.content.text = ""
		end
	end
	
	text_widget.dirty = true
end)

-- Хук для обновления тимейтов
local function update_player_features_hook(func, self, dt, t, player, ui_renderer)
	func(self, dt, t, player, ui_renderer)
	
	-- Обновляем иконку способности для тимейта
	mod:echo("TalentUI: update_player_features_hook called for " .. player:name())
	update_teammate_ability_icon(self, player, dt)
end

mod:hook("HudElementTeamPlayerPanel", "_update_player_features", update_player_features_hook)

-- Инициализация данных при создании панели тимейта
mod:hook("HudElementTeamPlayerPanel", "init", function(func, self, _parent, _draw_layer, _start_scale, data)
	func(self, _parent, _draw_layer, _start_scale, data)
	
	-- Проверяем наличие виджетов после инициализации
	if self._widgets_by_name then
		if self._widgets_by_name.talent_ui_ability_icon then
			mod:echo("TalentUI: Widget found in init for " .. data.player:name())
		else
			mod:echo("TalentUI: Widget NOT found in init for " .. data.player:name())
			-- Выводим список всех виджетов для отладки
			local widget_names = {}
			for name, _ in pairs(self._widgets_by_name) do
				table.insert(widget_names, name)
			end
			mod:echo("TalentUI: Available widgets: " .. table.concat(widget_names, ", "))
		end
	end
end)

-- Очистка данных при уничтожении панели
mod:hook_safe("HudElementTeamPlayerPanel", "destroy", function(self)
	local player = self._data.player
	if player then
		local player_name = player:name()
		ability_data[player_name] = nil
	end
end)

