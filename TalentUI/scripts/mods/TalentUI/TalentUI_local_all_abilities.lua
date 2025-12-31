local mod = get_mod("TalentUI")

local PLAYER_ABILITY_DEF_PATH = "scripts/ui/hud/elements/player_ability/hud_element_player_ability_vertical_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")

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
		local_cooldown_font_size = 18,
	}
	
	if success and result and type(result) == "table" then
		if result.icon_position_offset and result.icon_position_left_shift then
			if not result.icon_position_vertical_offset then
				result.icon_position_vertical_offset = 0
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

-- Добавление виджетов для всех 3 способностей (ability, blitz, aura)
mod:hook(_G, "dofile", function(func, path)
	local instance = func(path)
	
	if path == PLAYER_ABILITY_DEF_PATH then
		-- Виджет для ability с кулдауном
		local ability_style = table.clone(UIFontSettings.hud_body)
		ability_style.text_horizontal_alignment = "center"
		ability_style.text_vertical_alignment = "center"
		ability_style.font_size = mod:get("local_cooldown_font_size") or TalentUISettings.local_cooldown_font_size or TalentUISettings.cooldown_font_size
		ability_style.font_type = "machine_medium"
		ability_style.drop_shadow = true
		
		instance.scenegraph_definition.ability_cooldown = {
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
		
		instance.widget_definitions.ability_cooldown_timer = UIWidget.create_definition({
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = "",
				style = ability_style,
			},
		}, "ability_cooldown")
		
		-- Виджет для blitz с зарядами
		local blitz_style = table.clone(UIFontSettings.hud_body)
		blitz_style.text_horizontal_alignment = "center"
		blitz_style.text_vertical_alignment = "center"
		blitz_style.font_size = mod:get("local_cooldown_font_size") or TalentUISettings.local_cooldown_font_size or TalentUISettings.cooldown_font_size
		blitz_style.font_type = "machine_medium"
		blitz_style.drop_shadow = true
		
		instance.scenegraph_definition.blitz_charges = {
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
		
		instance.widget_definitions.blitz_charges_text = UIWidget.create_definition({
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = "",
				style = blitz_style,
			},
		}, "blitz_charges")
		
		-- Виджет для aura (обычно без кулдауна, но можно добавить статус)
		local aura_style = table.clone(UIFontSettings.hud_body)
		aura_style.text_horizontal_alignment = "center"
		aura_style.text_vertical_alignment = "center"
		aura_style.font_size = mod:get("local_cooldown_font_size") or TalentUISettings.local_cooldown_font_size or TalentUISettings.cooldown_font_size
		aura_style.font_type = "machine_medium"
		aura_style.drop_shadow = true
		
		instance.scenegraph_definition.aura_status = {
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
		
		instance.widget_definitions.aura_status_text = UIWidget.create_definition({
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = "",
				style = aura_style,
			},
		}, "aura_status")
	end
	
	return instance
end)

-- Обновление всех способностей для локального игрока
mod:hook_safe("HudElementPlayerAbility", "update", function(self)
	if not mod:get("show_local_ability_cooldown") then
		return
	end
	
	local widgets_by_name = self._widgets_by_name
	local ability_cooldown_widget = widgets_by_name.ability_cooldown_timer
	local blitz_charges_widget = widgets_by_name.blitz_charges_text
	local aura_status_widget = widgets_by_name.aura_status_text
	
	if not ability_cooldown_widget and not blitz_charges_widget and not aura_status_widget then
		return
	end
	
	local player = self._data.player
	local player_unit = player.player_unit
	
	if not ALIVE[player_unit] then
		if ability_cooldown_widget then
			ability_cooldown_widget.content.text = ""
			ability_cooldown_widget.dirty = true
		end
		if blitz_charges_widget then
			blitz_charges_widget.content.text = ""
			blitz_charges_widget.dirty = true
		end
		if aura_status_widget then
			aura_status_widget.content.text = ""
			aura_status_widget.dirty = true
		end
		return
	end
	
	local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
	local ability_component = unit_data_extension:read_component("combat_ability")
	local grenade_component = unit_data_extension:read_component("grenade_ability")
	
	local ability_extension = ScriptUnit.extension(player_unit, "ability_system")
	local format_type = mod:get("cooldown_format")
	
	-- Обновление ability (combat_ability) - кулдаун
	if ability_cooldown_widget then
		if ability_extension:ability_is_equipped("combat_ability") then
			local remaining_cooldown = ability_extension:remaining_ability_cooldown("combat_ability")
			local max_cooldown = ability_extension:max_ability_cooldown("combat_ability")
			
			if format_type == "time" then
				local time = Managers.time:time("gameplay")
				local time_remaining = ability_component.cooldown - time
				
				if time_remaining <= 0 then
					ability_cooldown_widget.content.text = " "
				elseif time_remaining <= 1 then
					ability_cooldown_widget.content.text = string.format("%.1f", time_remaining)
				else
					ability_cooldown_widget.content.text = string.format("%d", math.ceil(time_remaining))
				end
			elseif format_type == "percent" then
				if max_cooldown and max_cooldown > 0 then
					local progress = 1 - (remaining_cooldown / max_cooldown)
					local percent = progress * 100
					if percent >= 99 then
						ability_cooldown_widget.content.text = " "
					else
						ability_cooldown_widget.content.text = string.format("%d%%", math.floor(percent))
					end
				else
					ability_cooldown_widget.content.text = " "
				end
			else
				ability_cooldown_widget.content.text = " "
			end
		else
			ability_cooldown_widget.content.text = " "
		end
		ability_cooldown_widget.dirty = true
	end
	
	-- Обновление blitz (grenade_ability) - заряды
	if blitz_charges_widget then
		if ability_extension:ability_is_equipped("grenade_ability") then
			local remaining_charges = ability_extension:remaining_ability_charges("grenade_ability")
			local max_charges = ability_extension:max_ability_charges("grenade_ability")
			
			if max_charges and max_charges > 1 then
				-- Показываем только если зарядов больше 1 или если зарядов нет
				if remaining_charges > 1 or remaining_charges == 0 then
					blitz_charges_widget.content.text = tostring(remaining_charges)
				else
					-- Если 1 заряд и он есть, не показываем
					blitz_charges_widget.content.text = " "
				end
			elseif remaining_charges == 0 then
				-- Показываем 0 если зарядов нет
				blitz_charges_widget.content.text = "0"
			else
				blitz_charges_widget.content.text = " "
			end
		else
			blitz_charges_widget.content.text = " "
		end
		blitz_charges_widget.dirty = true
	end
	
	-- Обновление aura - обычно без кулдауна, но можно показать статус
	if aura_status_widget then
		-- Aura обычно пассивная, поэтому скрываем текст
		aura_status_widget.content.text = " "
		aura_status_widget.dirty = true
	end
end)

