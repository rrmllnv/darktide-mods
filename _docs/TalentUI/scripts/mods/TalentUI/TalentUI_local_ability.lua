local mod = get_mod("TalentUI")

local PLAYER_ABILITY_DEF_PATH = "scripts/ui/hud/elements/player_ability/hud_element_player_ability_vertical_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local FixedFrame = require("scripts/utilities/fixed_frame")

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

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
			
			if rawget(_G, "ALIVE") and ALIVE[player_unit] then
				if rawget(_G, "ScriptUnit") then
					local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
					if unit_data_extension then
						local ability_component = unit_data_extension:read_component("combat_ability")
						if ability_component and ability_component.cooldown then
							local fixed_frame_t = FixedFrame.get_latest_fixed_time()
							local time_remaining = math.max(ability_component.cooldown - fixed_frame_t, 0)
							
							if time_remaining > 0 then
								display_text = string.format("%d", math.ceil(time_remaining))
							else
								display_text = ""
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

