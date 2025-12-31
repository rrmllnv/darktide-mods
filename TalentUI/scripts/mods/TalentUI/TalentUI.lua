local mod = get_mod("TalentUI")

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"
local PLAYER_ABILITY_DEF_PATH = "scripts/ui/hud/elements/player_ability/hud_element_player_ability_vertical_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")
local FixedFrame = require("scripts/utilities/fixed_frame")

local ability_configuration = PlayerCharacterConstants.ability_configuration

-- Хранение данных о кулдаунах
local ability_data = {} -- player_name -> {cooldown_timer, max_cooldown, ability_id, icon}

-- Функция для получения размера иконки
local function get_ability_icon_size()
	return mod:get("ability_icon_size") or 60
end

-- Функция для получения данных об экипированной способности игрока
local function get_player_ability_data(player, extensions)
	if not extensions or not extensions.ability then
		return nil
	end
	
	local ability_extension = extensions.ability
	local equipped_abilities = ability_extension:equipped_abilities()
	
	-- Ищем основную боевую способность (combat_ability)
	for ability_id, ability_settings in pairs(equipped_abilities) do
		local slot_id = ability_configuration[ability_id]
		if slot_id == "combat_ability" then
			return {
				ability_id = ability_id,
				icon = ability_settings.hud_icon,
				name = ability_settings.name,
			}
		end
	end
	
	return nil
end

-- Функция для получения прогресса и состояния кулдауна
local function get_ability_cooldown_state(player, extensions, ability_id)
	if not extensions or not extensions.ability then
		return 1, false, 1, true -- полный прогресс, не на кулдауне, 1 заряд, есть заряды
	end
	
	local ability_extension = extensions.ability
	
	if not ability_extension:ability_is_equipped(ability_id) then
		return 1, false, 1, true
	end
	
	local remaining_ability_cooldown = ability_extension:remaining_ability_cooldown(ability_id)
	local max_ability_cooldown = ability_extension:max_ability_cooldown(ability_id)
	local is_paused = ability_extension:is_cooldown_paused(ability_id)
	local remaining_ability_charges = ability_extension:remaining_ability_charges(ability_id)
	local max_ability_charges = ability_extension:max_ability_charges(ability_id)
	
	local uses_charges = max_ability_charges and max_ability_charges > 1
	local has_charges_left = remaining_ability_charges > 0
	
	local cooldown_progress = 1
	
	if is_paused then
		cooldown_progress = 0
	elseif max_ability_cooldown and max_ability_cooldown > 0 then
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

-- Добавление виджетов иконок способностей в team HUD
mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
	if not mod:get("show_teammate_ability_icon") then
		return
	end
	
	local icon_size = get_ability_icon_size()
	
	-- Виджет иконки способности
	instance.widget_definitions.talent_ui_ability_icon = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "icon",
			value = "content/ui/materials/icons/talents/hud/combat_container",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				material_values = {
					progress = 1,
					talent_icon = nil,
				},
				offset = {
					-icon_size - 10,
					0,
					1,
				},
				size = {
					icon_size,
					icon_size,
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
				horizontal_alignment = "left",
				vertical_alignment = "center",
				offset = {
					-icon_size - 10,
					0,
					2,
				},
				size = {
					icon_size,
					icon_size,
				},
				color = UIHudSettings.color_tint_main_2,
			},
		},
	}, "bar")
	
	-- Виджет текста кулдауна
	if mod:get("show_teammate_ability_cooldown") then
		local cooldown_font_size = mod:get("cooldown_font_size") or 18
		
		instance.widget_definitions.talent_ui_ability_cooldown = UIWidget.create_definition({
			{
				pass_type = "text",
				style_id = "text",
				value_id = "text",
				value = "",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "center",
					text_horizontal_alignment = "center",
					text_vertical_alignment = "center",
					font_type = "machine_medium",
					font_size = cooldown_font_size,
					text_color = UIHudSettings.color_tint_main_1,
					drop_shadow = true,
					offset = {
						-icon_size - 10,
						0,
						3,
					},
					size = {
						icon_size,
						icon_size,
					},
				},
			},
		}, "bar")
	end
end)

-- Добавление кулдауна для локального игрока (как в NumericUI)
mod:hook(_G, "dofile", function(func, path)
	local instance = func(path)
	
	if path == PLAYER_ABILITY_DEF_PATH and mod:get("show_local_ability_cooldown") then
		local cooldown_font_size = mod:get("cooldown_font_size") or 18
		local style = table.clone(UIFontSettings.hud_body)
		style.text_horizontal_alignment = "center"
		style.text_vertical_alignment = "center"
		style.font_size = cooldown_font_size
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
	if not mod:get("show_teammate_ability_icon") then
		return
	end
	
	local ability_icon_widget = self._widgets_by_name.talent_ui_ability_icon
	local ability_cooldown_widget = self._widgets_by_name.talent_ui_ability_cooldown
	
	if not ability_icon_widget then
		return
	end
	
	local player_name = player:name()
	local extensions = self:_player_extensions(player)
	
	-- Скрываем виджеты если игрок мертв
	if self._show_as_dead or self._dead or self._hogtied then
		ability_icon_widget.visible = false
		if ability_cooldown_widget then
			ability_cooldown_widget.visible = false
		end
		return
	end
	
	-- Получаем данные о способности
	if not ability_data[player_name] or not ability_data[player_name].ability_id then
		local ability_info = get_player_ability_data(player, extensions)
		if ability_info then
			ability_data[player_name] = {
				ability_id = ability_info.ability_id,
				icon = ability_info.icon,
			}
		else
			ability_icon_widget.visible = false
			if ability_cooldown_widget then
				ability_cooldown_widget.visible = false
			end
			return
		end
	end
	
	local ability_id = ability_data[player_name].ability_id
	local icon = ability_data[player_name].icon
	
	-- Устанавливаем иконку
	if ability_icon_widget.style.icon.material_values.talent_icon ~= icon then
		ability_icon_widget.style.icon.material_values.talent_icon = icon
		ability_icon_widget.dirty = true
	end
	
	-- Получаем состояние кулдауна
	local cooldown_progress, on_cooldown, remaining_charges, has_charges_left = get_ability_cooldown_state(player, extensions, ability_id)
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
	update_teammate_ability_icon(self, player, dt)
end

mod:hook("HudElementTeamPlayerPanel", "_update_player_features", update_player_features_hook)

-- Инициализация данных при создании панели тимейта
mod:hook("HudElementTeamPlayerPanel", "init", function(func, self, _parent, _draw_layer, _start_scale, data)
	func(self, _parent, _draw_layer, _start_scale, data)
	
	local player = data.player
	local player_name = player:name()
	local extensions = self:_player_extensions(player)
	
	-- Инициализируем данные о способности
	if extensions then
		local ability_info = get_player_ability_data(player, extensions)
		if ability_info then
			ability_data[player_name] = {
				ability_id = ability_info.ability_id,
				icon = ability_info.icon,
			}
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

