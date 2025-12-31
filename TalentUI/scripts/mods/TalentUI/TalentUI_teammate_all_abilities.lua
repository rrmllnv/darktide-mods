local mod = get_mod("TalentUI")

local CharacterSheet
local success_require = pcall(function()
	CharacterSheet = require("scripts/utilities/character_sheet")
end)

if not success_require or not CharacterSheet then
	mod:error("Failed to load CharacterSheet module")
	CharacterSheet = {}
	CharacterSheet.class_loadout = function() end
end

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementTeamPlayerPanelSettings = require("scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")

-- Хранение данных о способностях тимейтов
-- Кэш: player_name + "_" + ability_id -> {ability_id, ability_type, icon}
local teammate_abilities_data = {}

local function get_talent_from_character_sheet(player, ability_key)
	local profile = player and player:profile()

	if not profile then
		return nil
	end

	local loadout_data = {
		ability = {},
		blitz = {},
		aura = {},
	}

	local success, entry = pcall(function()
		CharacterSheet.class_loadout(profile, loadout_data, false, profile.talents or {})

		local entry = loadout_data[ability_key]

		return entry
	end)

	if success then
		return entry
	end

	return nil
end

local TALENT_ABILITY_METADATA = {
	{
		id = "aura",
		slot = "slot_coherency_ability",
		type = "coherency_ability",
		name = "talent_ui_all_aura",
		frame = "circular_frame",
		mask = "circular_frame_mask",
	},
	{
		id = "blitz",
		slot = "slot_grenade_ability",
		type = "grenade_ability",
		name = "talent_ui_all_blitz",
		frame = "square_frame",
		mask = "square_frame_mask",
	},
	{
		id = "ability",
		slot = "slot_combat_ability",
		type = "combat_ability",
		name = "talent_ui_all_ability",
		frame = "hex_frame",
		mask = "hex_frame_mask",
	},
}

-- Функция для получения данных об экипированной способности по типу
local function get_player_ability_by_type(player, extensions, slot_type)
	-- Для ауры (coherency) получаем данные через CharacterSheet (аура это талант, а не ability)
	if slot_type == "slot_coherency_ability" then
		local aura_entry = get_talent_from_character_sheet(player, "aura")

		if aura_entry and aura_entry.icon then
			return {
				ability_id = "aura",
				ability_type = "coherency_ability",
				icon = aura_entry.icon,
				name = aura_entry.talent and aura_entry.talent.display_name or "Aura",
			}
		end

		local success, result = pcall(function()
			local profile = player:profile()
			if profile then
				local loadout_data = {
					ability = {},
					blitz = {},
					aura = {},
				}
				local loadout_success = pcall(function()
					CharacterSheet.class_loadout(profile, loadout_data, false, profile.talents or {})
				end)
				if loadout_success and loadout_data and loadout_data.aura then
					local icon = loadout_data.aura.icon
					
					if icon then
						return {
							ability_id = "aura",
							ability_type = "coherency_ability",
							icon = icon,
							name = loadout_data.aura.talent and loadout_data.aura.talent.display_name or "Aura",
						}
					end
				end
			end
			return nil
		end)
		
		if success and result then
			return result
		end

		return nil
	end
	
	-- Для combat_ability и grenade_ability получаем через ability_extension
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
	
	for ability_id, ability_settings in pairs(equipped_abilities) do
		local slot_id = ability_configuration[ability_id]
		if slot_id == slot_type then
			local ability_type
			if slot_type == "slot_combat_ability" then
				ability_type = "combat_ability"
			elseif slot_type == "slot_grenade_ability" then
				ability_type = "grenade_ability"
			else
				ability_type = nil
			end
			
			if ability_type then
				local icon = nil

				if slot_type == "slot_grenade_ability" then
					-- Иконка блитца может быть взята из дерева талантов, если там задана
					local blitz_entry = get_talent_from_character_sheet(player, "blitz")
					icon = blitz_entry and blitz_entry.icon

					if not icon and extensions.visual_loadout and extensions.unit_data then
						local inventory_component = extensions.unit_data:read_component("inventory")
						if inventory_component then
							local visual_loadout_extension = extensions.visual_loadout
							local slot_name = "slot_grenade_ability"
							local item_name = inventory_component[slot_name]
							local weapon_template = item_name and visual_loadout_extension:weapon_template_from_slot(slot_name)

							if weapon_template and weapon_template.hud_icon_small then
								icon = weapon_template.hud_icon_small
							end
						end
					end

					if not icon then
						icon = ability_settings.hud_icon
					end
				else
					icon = ability_settings.hud_icon
				end
				
				-- Возвращаем данные даже если иконка nil (способность может загрузиться позже)
				return {
					ability_id = ability_id,
					ability_type = ability_type,
					icon = icon,
					name = ability_settings.name,
				}
			end
		end
	end
	
	return nil
end

-- Функция для получения состояния кулдауна/зарядов
local function get_ability_state(player, extensions, ability_type)
	-- Аура (coherency_ability) всегда активна, это пассивный баф
	if ability_type == "coherency_ability" then
		return 1, false, 1, true, 1
	end
	
	if not extensions or not extensions.ability then
		return 1, false, 1, true, 1
	end
	
	local ability_extension = extensions.ability
	
	if not ability_extension:ability_is_equipped(ability_type) then
		return 1, false, 1, true, 1
	end
	
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(ability_type)
	local max_cooldown = ability_extension:max_ability_cooldown(ability_type)
	local remaining_charges = ability_extension:remaining_ability_charges(ability_type)
	local max_charges = ability_extension:max_ability_charges(ability_type)
	
	local uses_charges = max_charges and max_charges > 1
	local has_charges_left = remaining_charges > 0
	
	local cooldown_progress = 1
	
	if max_cooldown and max_cooldown > 0 then
		cooldown_progress = 1 - math.lerp(0, 1, remaining_cooldown / max_cooldown)
		if cooldown_progress == 0 then
			cooldown_progress = 1
		end
	else
		cooldown_progress = uses_charges and 1 or 0
	end
	
	local on_cooldown = cooldown_progress ~= 1
	
	return cooldown_progress, on_cooldown, remaining_charges or 1, has_charges_left, max_charges or 1
end

-- Функция для получения цветов состояния
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

-- Функция для получения настроек материала (intensity, saturation) в зависимости от состояния
local function get_ability_material_settings(ability_id, on_cooldown, uses_charges, has_charges_left)
	if not TalentUISettings then
		return {intensity = 0, saturation = 1}
	end
	
	local icon_settings = TalentUISettings.icon_material_settings
	if not icon_settings or not icon_settings[ability_id] then
		return {intensity = 0, saturation = 1}
	end
	
	local ability_settings = icon_settings[ability_id]
	local state_key
	
	if on_cooldown then
		if uses_charges then
			if has_charges_left then
				state_key = "has_charges_cooldown"
			else
				state_key = "out_of_charges_cooldown"
			end
		else
			state_key = "on_cooldown"
		end
	elseif not uses_charges or (uses_charges and has_charges_left) then
		state_key = "active"
	else
		state_key = "inactive"
	end
	
	local state_settings = ability_settings[state_key]
	if state_settings then
		local intensity = state_settings.intensity or 0
		local saturation = state_settings.saturation or 1
		return {
			intensity = intensity,
			saturation = saturation,
		}
	end
	
	return {intensity = 0, saturation = 1}
end

-- Функция для глубокого копирования таблицы
local function deep_copy(original)
	local copy
	if type(original) == "table" then
		copy = {}
		for key, value in pairs(original) do
			copy[key] = deep_copy(value)
		end
	else
		copy = original
	end
	return copy
end

-- Функция для глубокого мержа таблиц
local function deep_merge(target, source)
	for key, value in pairs(source) do
		if type(value) == "table" and type(target[key]) == "table" then
			deep_merge(target[key], value)
		else
			target[key] = deep_copy(value)
		end
	end
	return target
end

-- Функция для загрузки настроек
local function load_settings()
	local DEFAULT_SETTINGS = {
		icon_position_offset = 12,
		icon_position_left_shift = 20,
		icon_position_vertical_offset = 0,
		ability_icon_size = 200,  -- Размер иконок
		cooldown_font_size = 18,
		icon_material_settings = {
			ability = {
				active = {intensity = 1, saturation = 1},
				on_cooldown = {intensity = -0.25, saturation = 1},
				has_charges_cooldown = {intensity = 0.5, saturation = 1},
				out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
				inactive = {intensity = -0.75, saturation = 0.3},
			},
			blitz = {
				active = {intensity = 1, saturation = 1},
				on_cooldown = {intensity = -0.25, saturation = 1},
				has_charges_cooldown = {intensity = 0.5, saturation = 1},
				out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
				inactive = {intensity = -0.75, saturation = 0.3},
			},
			aura = {
				active = {intensity = 1, saturation = 1},
				on_cooldown = {intensity = -0.25, saturation = 1},
				has_charges_cooldown = {intensity = 0.5, saturation = 1},
				out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
				inactive = {intensity = -0.75, saturation = 0.3},
			},
		},
	}
	
	local success, result = pcall(function()
		return mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")
	end)
	
	if success and result and type(result) == "table" then
		-- Создаем копию дефолтных настроек
		local merged_settings = deep_copy(DEFAULT_SETTINGS)
		-- Мержим настройки из файла с дефолтными
		deep_merge(merged_settings, result)
		mod:info("Settings loaded successfully, icon_material_settings for ability active: intensity=" .. tostring(merged_settings.icon_material_settings.ability.active.intensity) .. ", saturation=" .. tostring(merged_settings.icon_material_settings.ability.active.saturation))
		return merged_settings
	else
		mod:warning("Failed to load settings, using defaults")
		return DEFAULT_SETTINGS
	end
end

-- Загружаем файл настроек при старте
local TalentUISettings = load_settings()

-- Убеждаемся, что настройки всегда инициализированы
if not TalentUISettings then
	TalentUISettings = {
		icon_position_offset = 12,
		icon_position_left_shift = 20,
		icon_position_vertical_offset = 0,
		ability_icon_size = 200,
		cooldown_font_size = 18,
		icon_material_settings = {
			ability = {
				active = {intensity = 1, saturation = 1},
				on_cooldown = {intensity = -0.25, saturation = 1},
				has_charges_cooldown = {intensity = 0.5, saturation = 1},
				out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
				inactive = {intensity = -0.75, saturation = 0.3},
			},
			blitz = {
				active = {intensity = 1, saturation = 1},
				on_cooldown = {intensity = -0.25, saturation = 1},
				has_charges_cooldown = {intensity = 0.5, saturation = 1},
				out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
				inactive = {intensity = -0.75, saturation = 0.3},
			},
			aura = {
				active = {intensity = 1, saturation = 1},
				on_cooldown = {intensity = -0.25, saturation = 1},
				has_charges_cooldown = {intensity = 0.5, saturation = 1},
				out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
				inactive = {intensity = -0.75, saturation = 0.3},
			},
		},
	}
end

-- Создание виджетов для всех 3 способностей
mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
	local bar_size = HudElementTeamPlayerPanelSettings.size
	local icon_size = TalentUISettings.ability_icon_size
	local icon_size_value = icon_size
	local base_offset = TalentUISettings.icon_position_offset
	local left_shift = TalentUISettings.icon_position_left_shift
	local vertical_offset = TalentUISettings.icon_position_vertical_offset or 0
	
	-- Расстояние между иконками способностей
	local ability_spacing = 50

	for i = 1, #TALENT_ABILITY_METADATA do
		local ability_type = TALENT_ABILITY_METADATA[i]
		local offset_x = base_offset - left_shift - (i - 1) * ability_spacing
		
		-- Виджет иконки способности с контейнером как в дереве талантов (без дополнительных рамок)
		instance.widget_definitions[ability_type.name .. "_icon"] = UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "icon",
				value = "content/ui/materials/frames/talents/talent_icon_container",
				style = {
					horizontal_alignment = "right",
					vertical_alignment = "center",
					material_values = {
						frame = "content/ui/textures/frames/talents/" .. ability_type.frame,
						icon_mask = "content/ui/textures/frames/talents/" .. ability_type.mask,
						icon = nil,
						intensity = 0,
						saturation = 1,
					},
					offset = {
						offset_x,
						vertical_offset,
						1,
					},
					size = {
						icon_size_value,
						icon_size_value,
					},
					color = UIHudSettings.color_tint_main_2,
				},
			},
		}, "bar")
		
		-- Виджет текста кулдауна/зарядов
		instance.widget_definitions[ability_type.name .. "_text"] = UIWidget.create_definition({
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
					offset = {
						offset_x,
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
	end
end)

-- Обновление всех способностей для тимейта
local function update_teammate_all_abilities(self, player, dt)
	local player_name = player:name()
	
	local extensions = self:_player_extensions(player)
	
	if not extensions then
		return
	end
	
	-- Скрываем виджеты если игрок мертв
	if self._show_as_dead or self._dead or self._hogtied then
		for _, ability_type in ipairs(TALENT_ABILITY_METADATA) do
			local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_icon"]
			local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_type.id .. "_text"]
			if icon_widget then
				icon_widget.visible = false
			end
			if text_widget then
				text_widget.visible = false
			end
		end
		return
	end
	
	-- Обновляем данные для каждой способности
	for i = 1, #TALENT_ABILITY_METADATA do
		local ability_info = TALENT_ABILITY_METADATA[i]
		local icon_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_icon"]
		local text_widget = self._widgets_by_name["talent_ui_all_" .. ability_info.id .. "_text"]
		
		if not icon_widget then
			-- Пропускаем если виджет не создан
		else
			-- Ключ для кэширования: player_name + "_" + ability_id
			local data_key = player_name .. "_" .. ability_info.id
			
			-- Получаем данные о способности (проверяем каждый раз, т.к. способность может загрузиться позже)
			if not teammate_abilities_data[data_key] or not teammate_abilities_data[data_key].ability_type then
				local ability_data = get_player_ability_by_type(player, extensions, ability_info.slot)
				if ability_data then
					teammate_abilities_data[data_key] = {
						ability_id = ability_data.ability_id,
						ability_type = ability_data.ability_type,
						icon = ability_data.icon,
					}
				else
					-- Способность еще не загружена, скрываем виджеты
					icon_widget.visible = false
					if text_widget then
						text_widget.visible = false
					end
				end
			end
			
			if icon_widget and teammate_abilities_data[data_key] and teammate_abilities_data[data_key].ability_type then
				local ability_type = teammate_abilities_data[data_key].ability_type
				local icon = teammate_abilities_data[data_key].icon
				
				-- Получаем состояние способности
				local cooldown_progress, on_cooldown, remaining_charges, has_charges_left, max_charges = get_ability_state(player, extensions, ability_type)
				local uses_charges = max_charges > 1
				
				-- Обновляем цвета
				local source_colors = get_ability_state_colors(on_cooldown, uses_charges, has_charges_left)
				
				if source_colors.icon then
					icon_widget.style.icon.color = table.clone(source_colors.icon)
					icon_widget.dirty = true
				end
				
				-- Получаем настройки материала в зависимости от состояния
				local material_settings = get_ability_material_settings(ability_info.id, on_cooldown, uses_charges, has_charges_left)
				
				-- Обновляем intensity и saturation (принудительно обновляем каждый кадр)
				icon_widget.style.icon.material_values.intensity = material_settings.intensity
				icon_widget.style.icon.material_values.saturation = material_settings.saturation
				icon_widget.dirty = true
				
				-- Устанавливаем иконку в правильное поле material_values
				if icon_widget.style.icon.material_values.icon ~= icon then
					icon_widget.style.icon.material_values.icon = icon
					icon_widget.dirty = true
				end
				
				icon_widget.visible = true
				
				-- Обновляем текст кулдауна/зарядов
				if text_widget then
					local display_text = ""
					
					if ability_info.id == "ability" then
						-- Для ability показываем кулдаун
						if on_cooldown then
							local format_type = mod:get("cooldown_format")
							if format_type == "time" then
								-- Нужно получить время из компонента
								local unit_data_extension = extensions.unit_data
								if unit_data_extension then
									local ability_component = unit_data_extension:read_component("combat_ability")
									if ability_component then
										local time = Managers.time:time("gameplay")
										local time_remaining = ability_component.cooldown - time
										if time_remaining > 0 then
											if time_remaining <= 1 then
												display_text = string.format("%.1f", time_remaining)
											else
												display_text = string.format("%d", math.ceil(time_remaining))
											end
										end
									end
								end
							elseif format_type == "percent" then
								local percent = (1 - cooldown_progress) * 100
								if percent < 99 then
									display_text = string.format("%d%%", math.floor(percent))
								end
							end
						end
					elseif ability_info.id == "blitz" then
						-- Для blitz показываем заряды
						if uses_charges then
							if remaining_charges > 1 or remaining_charges == 0 then
								display_text = tostring(remaining_charges)
							end
						elseif remaining_charges == 0 then
							display_text = "0"
						end
					end
					-- Для aura ничего не показываем (обычно пассивная)
					
					text_widget.content.text = display_text
					text_widget.visible = display_text ~= ""
					text_widget.dirty = true
				end
			end
		end
	end
end

-- Экспортируем функцию для вызова из основного хука
mod.update_teammate_all_abilities = update_teammate_all_abilities

-- Очистка данных при уничтожении панели
mod.clear_teammate_all_abilities_data = function(player_name)
	-- Очищаем все данные для этого тимейта (по префиксу player_name_)
	for key, _ in pairs(teammate_abilities_data) do
		if string.find(key, player_name .. "_", 1, true) == 1 then
			teammate_abilities_data[key] = nil
		end
	end
end

-- Хук для обновления тимейтов
local function update_player_features_hook(func, self, dt, t, player, ui_renderer)
	func(self, dt, t, player, ui_renderer)
	
	-- Обновляем все 3 способности для тимейта
	update_teammate_all_abilities(self, player, dt)
end

mod:hook("HudElementTeamPlayerPanel", "_update_player_features", update_player_features_hook)

-- Очистка данных при уничтожении панели
mod:hook_safe("HudElementTeamPlayerPanel", "destroy", function(self)
	local player = self._data.player
	if player then
		local success, player_name = pcall(function()
			return player:name()
		end)
		if success and player_name then
			mod.clear_teammate_all_abilities_data(player_name)
		end
	end
end)


