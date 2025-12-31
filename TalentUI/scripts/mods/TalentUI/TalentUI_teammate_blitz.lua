local mod = get_mod("TalentUI")

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local FixedFrame = require("scripts/utilities/fixed_frame")

-- Хранение данных о кулдаунах blitz тимейтов
local blitz_data = {} -- player_name -> {cooldown_timer, max_cooldown, ability_id, icon}

-- Функция для получения данных об экипированной blitz способности игрока
-- Использует API из HudElementPlayerAbilityHandler
local function get_player_blitz_data(player, extensions)
	if not extensions or not extensions.ability then
		return nil
	end
	
	local ability_extension = extensions.ability
	local equipped_abilities = ability_extension:equipped_abilities()
	
	if not equipped_abilities then
		return nil
	end
	
	local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")
	local ability_configuration = PlayerCharacterConstants.ability_configuration
	
	-- Ищем grenade_ability как в оригинальном HUD
	-- slot_id это "slot_grenade_ability", а не "grenade_ability"!
	for ability_id, ability_settings in pairs(equipped_abilities) do
		local slot_id = ability_configuration[ability_id]
		if slot_id == "slot_grenade_ability" then
			return {
				ability_id = ability_id,
				ability_type = "grenade_ability", -- Используем "grenade_ability" для компонента
				icon = ability_settings.hud_icon,
				name = ability_settings.name,
			}
		end
	end
	
	return nil
end

-- Функция для получения прогресса и состояния кулдауна blitz
-- Использует методы PlayerHuskAbilityExtension из исходников
local function get_blitz_cooldown_state(player, extensions, ability_type)
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

-- Функция для получения цветов состояния blitz способности
local function get_blitz_state_colors(on_cooldown, uses_charges, has_charges_left)
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

-- Функция для загрузки настроек
local function load_settings()
	local success, result = pcall(function()
		return mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")
	end)
	
	local DEFAULT_SETTINGS = {
		icon_position_offset = 12,
		icon_position_left_shift = 20,
		icon_position_vertical_offset = 0,
		ability_icon_size = 128,
		cooldown_font_size = 18,
	}
	
	if success and result and type(result) == "table" then
		if result.icon_position_offset and result.icon_position_left_shift then
			if not result.icon_position_vertical_offset then
				result.icon_position_vertical_offset = 0
			end
			-- Настройки для blitz, если не заданы, используем общие
			if not result.blitz_icon_position_offset then
				result.blitz_icon_position_offset = result.icon_position_offset
			end
			if not result.blitz_icon_position_left_shift then
				result.blitz_icon_position_left_shift = result.icon_position_left_shift
			end
			if not result.blitz_icon_position_vertical_offset then
				result.blitz_icon_position_vertical_offset = result.icon_position_vertical_offset
			end
			return result
		else
			return DEFAULT_SETTINGS
		end
	else
		return DEFAULT_SETTINGS
	end
end

-- Загружаем файл настроек при старте
local TalentUISettings = load_settings()

-- Добавление виджетов иконок blitz способностей в team HUD
mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
	-- Всегда добавляем виджеты, контролируем видимость через visible
	local bar_size = HudElementTeamPlayerPanelSettings.size
	-- Используем размер иконки из файла настроек или из настроек мода
	local icon_size = mod:get("ability_icon_size") or TalentUISettings.ability_icon_size
	-- В исходниках frame имеет размер 128x128, а icon_size = 80x80
	-- Используем разные размеры: иконка меньше рамки
	local frame_size = icon_size -- Рамка использует размер из настройки
	local icon_size_value = math.floor(icon_size * 0.625) -- 80/128 = 0.625 (как в исходниках)
	-- Позиционирование из файла настроек для blitz
	local base_offset = TalentUISettings.blitz_icon_position_offset or TalentUISettings.icon_position_offset
	local left_shift = TalentUISettings.blitz_icon_position_left_shift or TalentUISettings.icon_position_left_shift
	local vertical_offset = TalentUISettings.blitz_icon_position_vertical_offset or TalentUISettings.icon_position_vertical_offset or 0
	
	-- Виджет иконки blitz способности (справа от рамки, как цифры в NumericUI)
	instance.widget_definitions.talent_ui_blitz_icon = UIWidget.create_definition({
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
	
	-- Виджет текста зарядов blitz (справа от иконки, поверх иконки)
	instance.widget_definitions.talent_ui_blitz_charges = UIWidget.create_definition({
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
end)

-- Обновление иконки blitz способности для тимейта
local function update_teammate_blitz_icon(self, player, dt)
	local player_name = player:name()
	
	local blitz_icon_widget = self._widgets_by_name.talent_ui_blitz_icon
	local blitz_charges_widget = self._widgets_by_name.talent_ui_blitz_charges
	
	if not blitz_icon_widget then
		return
	end
	
	-- Проверяем настройку
	local show_setting = mod:get("show_teammate_blitz_icon")
	
	if not show_setting then
		blitz_icon_widget.visible = false
		if blitz_charges_widget then
			blitz_charges_widget.visible = false
		end
		return
	end
	
	local extensions = self:_player_extensions(player)
	
	if not extensions then
		return
	end
	
	-- Скрываем виджеты если игрок мертв
	if self._show_as_dead or self._dead or self._hogtied then
		blitz_icon_widget.visible = false
		if blitz_charges_widget then
			blitz_charges_widget.visible = false
		end
		return
	end
	
	-- Получаем данные о blitz способности (проверяем каждый раз, т.к. способность может загрузиться позже)
	if not blitz_data[player_name] or not blitz_data[player_name].ability_type then
		local blitz_info = get_player_blitz_data(player, extensions)
		if blitz_info then
			blitz_data[player_name] = {
				ability_id = blitz_info.ability_id,
				ability_type = blitz_info.ability_type,
				icon = blitz_info.icon,
			}
		else
			-- Blitz способность еще не загружена, скрываем виджеты
			blitz_icon_widget.visible = false
			if blitz_charges_widget then
				blitz_charges_widget.visible = false
			end
			return
		end
	end
	
	local ability_type = blitz_data[player_name].ability_type
	local icon = blitz_data[player_name].icon
	
	-- Обновляем размер иконки и рамки из настроек
	-- В исходниках frame = 128x128, icon_size = 80x80 (соотношение 0.625)
	local frame_size = mod:get("ability_icon_size") or 128
	local icon_size_value = math.floor(frame_size * 0.625) -- 80/128 = 0.625
	
	-- Обновляем размеры только если они изменились
	if blitz_icon_widget.style.icon.size[1] ~= icon_size_value then
		blitz_icon_widget.style.icon.size[1] = icon_size_value
		blitz_icon_widget.style.icon.size[2] = icon_size_value
		blitz_icon_widget.dirty = true
	end
	
	-- Позиционирование из файла настроек (перезагружаем каждый кадр для возможности изменения в реальном времени)
	local settings = load_settings()
	local base_offset = settings.blitz_icon_position_offset or settings.icon_position_offset
	local left_shift = settings.blitz_icon_position_left_shift or settings.icon_position_left_shift
	local vertical_offset = settings.blitz_icon_position_vertical_offset or settings.icon_position_vertical_offset
	
	-- Проверяем, нужно ли обновить размер или позицию
	local needs_offset_update = false
	if blitz_icon_widget.style.frame.size[1] ~= frame_size then
		blitz_icon_widget.style.frame.size[1] = frame_size
		blitz_icon_widget.style.frame.size[2] = frame_size
		blitz_icon_widget.dirty = true
		needs_offset_update = true
	end
	
	-- Обновляем offset каждый кадр (для возможности изменения в реальном времени через файл настроек)
	local current_frame_offset = blitz_icon_widget.style.frame.offset[1]
	local current_frame_vertical = blitz_icon_widget.style.frame.offset[2]
	local new_frame_offset = base_offset - left_shift
	local offset_adjustment = (frame_size - icon_size_value) / 2
	local new_icon_offset = base_offset - offset_adjustment - left_shift
	
	-- Обновляем только если позиция изменилась
	if needs_offset_update or current_frame_offset ~= new_frame_offset or blitz_icon_widget.style.icon.offset[1] ~= new_icon_offset or current_frame_vertical ~= vertical_offset then
		blitz_icon_widget.style.frame.offset[1] = new_frame_offset
		blitz_icon_widget.style.frame.offset[2] = vertical_offset
		blitz_icon_widget.style.icon.offset[1] = new_icon_offset
		blitz_icon_widget.style.icon.offset[2] = vertical_offset
		blitz_icon_widget.dirty = true
	end
	
	if blitz_charges_widget then
		-- Обновляем размер текста зарядов только если изменился
		if blitz_charges_widget.style.text.size[1] ~= icon_size_value then
			blitz_charges_widget.style.text.size[1] = icon_size_value
			blitz_charges_widget.style.text.size[2] = icon_size_value
			blitz_charges_widget.dirty = true
		end
		
		-- Обновляем offset текста зарядов каждый кадр (для возможности изменения в реальном времени)
		local offset_adjustment = (frame_size - icon_size_value) / 2
		local new_text_offset = base_offset - offset_adjustment - left_shift
		local current_text_offset = blitz_charges_widget.style.text.offset[1]
		local current_text_vertical = blitz_charges_widget.style.text.offset[2]
		if current_text_offset ~= new_text_offset or current_text_vertical ~= vertical_offset then
			blitz_charges_widget.style.text.offset[1] = new_text_offset
			blitz_charges_widget.style.text.offset[2] = vertical_offset
			blitz_charges_widget.dirty = true
		end
	end
	
	-- Устанавливаем иконку
	if blitz_icon_widget.style.icon.material_values.talent_icon ~= icon then
		blitz_icon_widget.style.icon.material_values.talent_icon = icon
		blitz_icon_widget.dirty = true
	end
	
	-- Получаем состояние кулдауна blitz
	local cooldown_progress, on_cooldown, remaining_charges, has_charges_left = get_blitz_cooldown_state(player, extensions, ability_type)
	local uses_charges = remaining_charges > 1
	
	-- Обновляем прогресс
	if blitz_icon_widget.content.duration_progress ~= cooldown_progress then
		blitz_icon_widget.content.duration_progress = cooldown_progress
		blitz_icon_widget.dirty = true
	end
	
	-- Обновляем цвета
	local source_colors = get_blitz_state_colors(on_cooldown, uses_charges, has_charges_left)
	
	if source_colors.icon then
		blitz_icon_widget.style.icon.color = table.clone(source_colors.icon)
		blitz_icon_widget.dirty = true
	end
	
	if source_colors.frame then
		blitz_icon_widget.style.frame.color = table.clone(source_colors.frame)
		blitz_icon_widget.dirty = true
	end
	
	blitz_icon_widget.visible = true
	
	-- Обновляем текст зарядов blitz (blitz работает на зарядах, а не на кулдауне)
	if blitz_charges_widget and mod:get("show_teammate_blitz_charges") then
		if extensions and extensions.unit_data and extensions.ability then
			local unit_data_extension = extensions.unit_data
			local ability_extension = extensions.ability
			local blitz_component = unit_data_extension:read_component("grenade_ability")
			
			if blitz_component then
				local num_charges = blitz_component.num_charges or 0
				local max_charges = ability_extension:max_ability_charges(ability_type) or 1
				
				-- Показываем количество зарядов, если их больше 1 или если зарядов нет
				if max_charges > 1 or num_charges == 0 then
					blitz_charges_widget.content.text = tostring(num_charges)
					blitz_charges_widget.visible = true
					blitz_charges_widget.dirty = true
				else
					-- Если 1 заряд и он есть, не показываем текст
					blitz_charges_widget.visible = false
					blitz_charges_widget.dirty = true
				end
			else
				blitz_charges_widget.visible = false
			end
		else
			blitz_charges_widget.visible = false
			blitz_charges_widget.dirty = true
		end
	end
end

-- Экспортируем функцию обновления для вызова из основного хука
mod.update_teammate_blitz_icon = update_teammate_blitz_icon

-- Очистка данных при уничтожении панели (blitz) - будет вызвана из основного хука
mod.clear_blitz_data = function(player_name)
	blitz_data[player_name] = nil
end

