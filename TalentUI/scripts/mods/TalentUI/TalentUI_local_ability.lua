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

-- Добавление кулдауна для локального игрока
mod:hook(_G, "dofile", function(func, path)
	local instance = func(path)
	
	if path == PLAYER_ABILITY_DEF_PATH then
		local style = table.clone(UIFontSettings.hud_body)
		style.text_horizontal_alignment = "center"
		style.text_vertical_alignment = "center"
		style.font_size = mod:get("local_cooldown_font_size") or TalentUISettings.local_cooldown_font_size or TalentUISettings.cooldown_font_size
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
	
	local display_text = ""
	
	if not on_cooldown or progress >= 1 then
		display_text = ""
	else
		if format_type == "time" then
			local player = self._data.player
			local player_unit = player.player_unit
			
			if ALIVE[player_unit] then
				local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
				local ability_component = unit_data_extension:read_component("combat_ability")
				if ability_component and ability_component.cooldown then
					local time = Managers.time:time("gameplay")
					local time_remaining = math.max(ability_component.cooldown - time, 0)
					
					if time_remaining > 0 then
						if time_remaining <= 1 then
							display_text = string.format("%.1f", time_remaining)
						else
							display_text = string.format("%d", math.ceil(time_remaining))
						end
					else
						display_text = ""
					end
				else
					display_text = ""
				end
			else
				display_text = ""
			end
		elseif format_type == "percent" then
			local percent = progress * 100
			if percent >= 100 or progress >= 1 then
				display_text = ""
			else
				display_text = string.format("%d%%", math.floor(percent))
			end
		else
			display_text = ""
		end
	end
	
	text_widget.content.text = display_text
	text_widget.visible = display_text ~= ""
	text_widget.dirty = true
end)

