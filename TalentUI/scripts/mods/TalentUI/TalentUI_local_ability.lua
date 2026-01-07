local mod = get_mod("TalentUI")

local PLAYER_ABILITY_DEF_PATH = "scripts/ui/hud/elements/player_ability/hud_element_player_ability_vertical_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local HudElementPlayerAbilitySettings = require("scripts/ui/hud/elements/player_ability/hud_element_player_ability_settings")
local FixedFrame = require("scripts/utilities/fixed_frame")

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

local ACTIVE_COLOR = UIHudSettings.color_tint_main_1
local COOLDOWN_COLOR = UIHudSettings.color_tint_alert_2
local NOTIFICATION_LINE_DEFAULT = UIHudSettings.color_tint_main_2
local NOTIFICATION_ICON_DEFAULT = UIHudSettings.color_tint_main_2
local NOTIFICATION_TEXT_DEFAULT = UIHudSettings.color_tint_main_1
local NOTIFICATION_BACKGROUND_DEFAULT = Color.terminal_grid_background(180, true)

local function clone_color(color)
	return {
		color[1],
		color[2],
		color[3],
		color[4],
	}
end

mod:hook(_G, "dofile", function(func, path)
	local instance = func(path)
	
	if path == PLAYER_ABILITY_DEF_PATH then
		local style = table.clone(UIFontSettings.hud_body)
		style.text_horizontal_alignment = "center"
		style.text_vertical_alignment = "center"
		style.font_size = mod:get("local_cooldown_font_size") or TalentUISettings.local_cooldown_font_size or TalentUISettings.teammate_ability_cooldown_font_size
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
		
		instance.widget_definitions.talentui_cooldown_timer = UIWidget.create_definition({
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

local function get_buff_remaining_time(buff_extension, buff_template_name)
	if not buff_extension then
		return 0
	end

	local buffs_by_index = buff_extension._buffs_by_index
	if not buffs_by_index then
		return 0
	end

	local timer = 0
	for _, buff in pairs(buffs_by_index) do
		local template = buff:template()
		if template and template.name == buff_template_name then
			local remaining = buff:duration_progress() or 1
			local duration = buff:duration() or 15
			timer = math.max(timer, duration * remaining)
		end
	end

	return timer
end

mod:hook_safe("HudElementPlayerAbility", "update", function(self)
	if not mod:get("show_local_ability_cooldown") then
		return
	end
	
	local widgets_by_name = self._widgets_by_name
	local text_widget = widgets_by_name.talentui_cooldown_timer
	
	if not text_widget then
		return
	end
	
	local player = self._data.player
	local player_unit = player.player_unit
	local parent = self._parent
	local ability_id = self._ability_id
	
	if not rawget(_G, "ALIVE") or not ALIVE[player_unit] then
		text_widget.content.text = ""
		text_widget.visible = false
		text_widget.dirty = true
		return
	end
	
	local ability_extension = parent:get_player_extension(player, "ability_system")
	local buff_extension = parent:get_player_extension(player, "buff_system")
	
	local progress = self._ability_progress
	local on_cooldown = self._on_cooldown
	local format_type = mod:get("cooldown_format")
	local show_active = mod:get("show_local_ability_active") ~= false
	local show_decimals = mod:get("show_local_ability_decimals") ~= false
	local show_ready_notification = mod:get("show_local_ability_ready_notification") ~= false
	
	local display_text = ""
	local display_color = COOLDOWN_COLOR
	local is_active = false
	
	if ability_extension and ability_extension:ability_is_equipped(ability_id) then
		local pause_cooldown_settings = ability_extension:ability_pause_cooldown_settings(ability_id)
		
		if pause_cooldown_settings and buff_extension then
			local duration_tracking_buff = pause_cooldown_settings.duration_tracking_buff
			
			if duration_tracking_buff then
				local has_active_buff = buff_extension:current_stacks(duration_tracking_buff) > 0
				
				if has_active_buff and show_active then
					is_active = true
					local remaining_buff_time = get_buff_remaining_time(buff_extension, duration_tracking_buff)
					
					if remaining_buff_time and remaining_buff_time >= 0.05 then
						display_color = ACTIVE_COLOR
						
						if format_type == "time" then
							if show_decimals then
								display_text = string.format("%.1f", remaining_buff_time)
							else
								display_text = string.format("%.0f", math.ceil(remaining_buff_time))
							end
						elseif format_type == "percent" then
							local duration_progress = buff_extension:buff_duration_progress(duration_tracking_buff)
							local percent = (1 - duration_progress) * 100
							display_text = string.format("%d%%", math.floor(percent))
						end
					else
						display_text = ""
					end
				end
			end
		end
	end
	
	if not is_active then
		if not on_cooldown or progress >= 1 then
			display_text = ""
		else
			display_color = COOLDOWN_COLOR
			
			if format_type == "time" then
				if rawget(_G, "ScriptUnit") then
					local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
					if unit_data_extension then
						local ability_component = unit_data_extension:read_component("combat_ability")
						if ability_component and ability_component.cooldown then
							local fixed_frame_t = FixedFrame.get_latest_fixed_time()
							local time_remaining = math.max(ability_component.cooldown - fixed_frame_t, 0)
							
							if time_remaining > 0 then
								if show_decimals then
									display_text = string.format("%.1f", time_remaining)
								else
									display_text = string.format("%.0f", math.ceil(time_remaining))
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
	end
	
	text_widget.content.text = display_text
	text_widget.style.text.text_color = display_color
	text_widget.visible = display_text ~= ""
	text_widget.dirty = true
	
	local is_ready = not on_cooldown and progress >= 1 and not is_active
	
	if show_ready_notification then
		if self._ability_ready_prev == nil then
			self._ability_ready_prev = is_ready
			self._ability_prev_on_cooldown = on_cooldown
		else
			local became_ready_after_cooldown = is_ready and not self._ability_ready_prev and (self._ability_prev_on_cooldown or on_cooldown)
			
			if became_ready_after_cooldown then
				local line_color = clone_color(NOTIFICATION_LINE_DEFAULT)
				local icon_color = clone_color(NOTIFICATION_ICON_DEFAULT)
				local background_color = clone_color(NOTIFICATION_BACKGROUND_DEFAULT)
				local text_color = clone_color(NOTIFICATION_TEXT_DEFAULT)
				local line_1_text = mod:localize("local_ability_ready_notification")
				line_1_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", text_color[2], text_color[3], text_color[4], line_1_text)
				
				local notification_data = {
					icon_size = "currency",
					color = background_color,
					line_color = line_color,
					icon_color = icon_color,
					line_1 = line_1_text,
					show_shine = true,
				}
				
				Managers.event:trigger("event_add_notification_message", "custom", notification_data)
			end
			
			self._ability_ready_prev = is_ready
			self._ability_prev_on_cooldown = on_cooldown
		end
	end
end)

