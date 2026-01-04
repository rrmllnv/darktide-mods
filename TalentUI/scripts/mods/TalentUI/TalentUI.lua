local mod = get_mod("TalentUI")

mod.version = "1.0.0"

local TalentUIConstants = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_constants")
local TALENT_ABILITY_METADATA = TalentUIConstants.TALENT_ABILITY_METADATA
local WEAPON_SLOTS = TalentUIConstants.WEAPON_SLOTS

local TEAM_HUD_DEF_PATH = "scripts/ui/hud/elements/team_player_panel/hud_element_team_player_panel_definitions"

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local hud_body_font_settings = UIFontSettings.hud_body

local TalentUISettings = mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_settings")

mod:hook_require(TEAM_HUD_DEF_PATH, function(instance)
	local icon_size = mod:get("teammate_ability_icon_size") or TalentUISettings.teammate_ability_icon_size
	local icon_text_alignment = mod:get("teammate_ability_text_alignment") or TalentUISettings.teammate_ability_text_alignment
	
	local text_horizontal_alignment = "center"
	local text_vertical_alignment = "center"
	
	if icon_text_alignment == "left" then
		text_horizontal_alignment = "left"
		text_vertical_alignment = "center"
	elseif icon_text_alignment == "right" then
		text_horizontal_alignment = "right"
		text_vertical_alignment = "center"
	elseif icon_text_alignment == "top" then
		text_horizontal_alignment = "center"
		text_vertical_alignment = "top"
	elseif icon_text_alignment == "bottom" then
		text_horizontal_alignment = "center"
		text_vertical_alignment = "bottom"
	elseif icon_text_alignment == "center" then
		text_horizontal_alignment = "center"
		text_vertical_alignment = "center"
	end

	local ability_spacing = TalentUISettings.teammate_ability_spacing
	local horizontal_offset = mod:get("teammate_ability_horizontal_offset") or TalentUISettings.teammate_ability_horizontal_offset
	local vertical_offset = mod:get("teammate_ability_vertical_offset") or TalentUISettings.teammate_ability_vertical_offset
	local icon_orientation = mod:get("teammate_ability_orientation") or TalentUISettings.teammate_ability_orientation
	local is_horizontal = icon_orientation == "horizontal"
	
	local text_offset = TalentUISettings.teammate_ability_text_offset
	
	for i = 1, #TALENT_ABILITY_METADATA do
		local ability_type = TALENT_ABILITY_METADATA[i]
		local position_index = i
		local offset_x, offset_y
		
		if is_horizontal then
			offset_x = horizontal_offset + ability_spacing + (position_index - 1) * (icon_size + ability_spacing)
			offset_y = vertical_offset
		else
			offset_x = horizontal_offset + ability_spacing
			offset_y = vertical_offset + (position_index - 1) * 28
		end
		
		local text_offset_x = offset_x
		local text_offset_y = offset_y
		
		if icon_text_alignment == "left" then
			text_offset_x = offset_x - text_offset
		elseif icon_text_alignment == "right" then
			text_offset_x = offset_x + text_offset
		elseif icon_text_alignment == "top" then
			text_offset_y = offset_y - text_offset
		elseif icon_text_alignment == "bottom" then
			text_offset_y = offset_y + text_offset
		end
		
		instance.widget_definitions[ability_type.name .. "_icon"] = UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "icon",
				value = "content/ui/materials/frames/talents/talent_icon_container",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "top",
					scale_to_material = true,
					material_values = {
						frame = "content/ui/textures/frames/talents/" .. ability_type.frame,
						icon_mask = "content/ui/textures/frames/talents/" .. ability_type.mask,
						icon = nil,
						gradient_map = nil,
						intensity = 0,
						saturation = 1,
					},
					offset = {
						offset_x,
						offset_y,
						2,
					},
					size = {
						icon_size,
						icon_size,
					},
					color = UIHudSettings.color_tint_main_2,
				},
			},
		}, "background")
		
		instance.widget_definitions[ability_type.name .. "_text"] = UIWidget.create_definition({
			{
				pass_type = "text",
				style_id = "text",
				value_id = "text",
				value = "",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "top",
					text_horizontal_alignment = text_horizontal_alignment,
					text_vertical_alignment = text_vertical_alignment,
					font_type = hud_body_font_settings.font_type or "machine_medium",
					font_size = mod:get("teammate_ability_cooldown_font_size") or TalentUISettings.teammate_ability_cooldown_font_size,
					line_spacing = 1.2,
					text_color = UIHudSettings.color_tint_main_1,
					drop_shadow = true,
					offset = {
						text_offset_x,
						text_offset_y,
						3,
					},
					size = {
						icon_size,
						icon_size,
					},
				},
			},
		}, "background")
	end
	
	local weapon_icon_width = TalentUISettings.teammate_weapon_icon_width
	local weapon_icon_height = TalentUISettings.teammate_weapon_icon_height
	
	for i = 1, #WEAPON_SLOTS do
		local weapon_slot = WEAPON_SLOTS[i]
		local offset_x = 0
		local offset_y = 0
		
		instance.widget_definitions[weapon_slot.name .. "_icon"] = UIWidget.create_definition({
			{
				pass_type = "texture",
				style_id = "icon",
				value_id = "icon",
				value = "content/ui/materials/icons/weapons/hud/combat_blade_01",
				style = {
					horizontal_alignment = "left",
					vertical_alignment = "top",
					offset = {
						offset_x,
						offset_y,
						1,
					},
					size = {
						weapon_icon_width,
						weapon_icon_height,
					},
					color = UIHudSettings.color_tint_main_2,
				},
			},
		}, "background")
	end
end)

local function reset_talent_ui_settings()
	mod:set("teammate_ability_vertical_offset", TalentUISettings.teammate_ability_vertical_offset)
	mod:set("teammate_ability_horizontal_offset", TalentUISettings.teammate_ability_horizontal_offset)
	mod:set("teammate_ability_orientation", TalentUISettings.teammate_ability_orientation)
	mod:set("teammate_ability_text_alignment", TalentUISettings.teammate_ability_text_alignment)
	mod:set("teammate_ability_icon_size", TalentUISettings.teammate_ability_icon_size)
	mod:set("teammate_ability_cooldown_font_size", TalentUISettings.teammate_ability_cooldown_font_size)
	mod:set("teammate_weapon_horizontal_offset", TalentUISettings.teammate_weapon_horizontal_offset)
	mod:set("teammate_weapon_vertical_offset", TalentUISettings.teammate_weapon_vertical_offset)
	mod:set("teammate_weapon_orientation", TalentUISettings.teammate_weapon_orientation)
end

function mod.on_setting_changed(setting_id)
	if setting_id == "reset_talent_ui_settings" then
		if mod:get("reset_talent_ui_settings") == 1 then
			mod:notify("Settings Reset")
			mod:set("reset_talent_ui_settings", 0)
			reset_talent_ui_settings()
		end
	end
end

mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_teammate_ability")
mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_teammate_weapons")
mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_local_ability")

