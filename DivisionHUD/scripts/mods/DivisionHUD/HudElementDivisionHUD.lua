local mod = get_mod("DivisionHUD")

require("scripts/ui/hud/elements/hud_element_base")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Ammo = require("scripts/utilities/ammo")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")

local Definitions = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_definitions")
local SlotData = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_slot_data")

local HudElementDivisionHUD = class("HudElementDivisionHUD", "HudElementBase")

local BAR_WIDTH = Definitions.BAR_WIDTH
local BUFF_SIZE = Definitions.BUFF_SIZE
local BUFF_SPACING = Definitions.BUFF_SPACING
local RIGHT_SLOT_COUNT = Definitions.RIGHT_SLOT_COUNT
local right_slot_widget_names = Definitions.right_slot_widget_names
local BUFF_ICON_FALLBACK_TEXTURE = SlotData.DEFAULT_GRENADE_FLAT_ICON
local BUFF_ICON_BASE_MATERIAL = "content/ui/materials/base/ui_default_base"

local COMBAT_ABILITY_TYPE = "combat_ability"
local GRENADE_ABILITY_TYPE = "grenade_ability"

HudElementDivisionHUD._slot_cell_visible = function(self, slot_id)
	if slot_id == "slot_grenade_ability" then
		return mod:get("show_grenades") ~= false and mod:get("show_grenades") ~= 0
	elseif slot_id == "slot_pocketable" then
		return mod:get("show_pickups") ~= false and mod:get("show_pickups") ~= 0
	elseif slot_id == "slot_pocketable_small" then
		return mod:get("show_stimm") ~= false and mod:get("show_stimm") ~= 0
	elseif slot_id == "slot_combat_ability" then
		return mod:get("show_ultimate") ~= false and mod:get("show_ultimate") ~= 0
	end

	return true
end

HudElementDivisionHUD._build_extensions = function(self, player_unit)
	local unit_data = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local visual_loadout = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
	local ability = ScriptUnit.has_extension(player_unit, "ability_system")

	if not unit_data or not visual_loadout or not ability then
		return nil
	end

	return {
		unit_data = unit_data,
		visual_loadout = visual_loadout,
		ability = ability,
	}
end

HudElementDivisionHUD._apply_slot_icon_material = function(self, widget, entry)
	if not widget or not widget.content then
		return
	end

	local slot_id = entry and entry.slot_id
	local icon = entry and entry.icon

	if type(icon) ~= "string" or icon == "" or icon == "content/ui/materials/base/ui_default_base" then
		if slot_id == "slot_combat_ability" then
			icon = Definitions.DEFAULT_COMBAT_ABILITY_ICON_TEXTURE
		else
			icon = Definitions.RIGHT_SLOT_ICON_FALLBACK
		end
	end

	local icon_style = widget.style and widget.style.icon

	if slot_id == "slot_combat_ability" then
		widget.content.icon = Definitions.HUD_WEAPON_ICON_CONTAINER

		if icon_style then
			local material_values = icon_style.material_values

			if not material_values then
				icon_style.material_values = {}
				material_values = icon_style.material_values
			end

			material_values.texture_map = icon
			material_values.use_placeholder_texture = 0
		end
	else
		widget.content.icon = icon

		if icon_style and icon_style.material_values ~= nil then
			icon_style.material_values = nil
		end
	end

	widget.dirty = true
end

HudElementDivisionHUD._slot_numeric_text = function(self, slot_id, entry, player_unit)
	if slot_id == "slot_combat_ability" then
		local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

		if not ability_extension then
			return "0"
		end

		local remaining_cooldown = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE)

		if remaining_cooldown and remaining_cooldown > 0 then
			return string.format("%.0f", remaining_cooldown)
		end

		return "0"
	end

	if slot_id == "slot_grenade_ability" then
		local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")

		if not ability_extension then
			return "00"
		end

		local remaining_charges = ability_extension:remaining_ability_charges(GRENADE_ABILITY_TYPE)

		return string.format("%02d", remaining_charges or 0)
	end

	if slot_id == "slot_pocketable" or slot_id == "slot_pocketable_small" then
		if entry.has_equipment and entry.weapon_template then
			return "01"
		end

		return "00"
	end

	return "0"
end

HudElementDivisionHUD._slot_has_ranged_ammunition = function(self, unit_data_extension, visual_loadout_extension, slot_id)
	if not unit_data_extension or not visual_loadout_extension then
		return false
	end

	local slot_configuration = PlayerCharacterConstants.slot_configuration
	local slot_settings = slot_configuration and slot_configuration[slot_id]

	if not slot_settings or slot_settings.slot_type ~= "weapon" then
		return false
	end

	local inventory_component = unit_data_extension:read_component("inventory")

	if not inventory_component or inventory_component[slot_id] == "not_equipped" then
		return false
	end

	local weapon_template = visual_loadout_extension:weapon_template_from_slot(slot_id)

	if not weapon_template then
		return false
	end

	local hud_configuration = weapon_template.hud_configuration

	if not hud_configuration or not hud_configuration.uses_ammunition then
		return false
	end

	local slot_component = unit_data_extension:read_component(slot_id)

	if not slot_component then
		return false
	end

	local max_reserve = slot_component.max_ammunition_reserve

	return max_reserve ~= nil and max_reserve > 0
end

HudElementDivisionHUD._read_weapon_slot_clip_reserve = function(self, unit_data_extension, visual_loadout_extension, slot_id)
	if not unit_data_extension or not visual_loadout_extension then
		return 0, 0
	end

	if not self:_slot_has_ranged_ammunition(unit_data_extension, visual_loadout_extension, slot_id) then
		return 0, 0
	end

	local slot_component = unit_data_extension:read_component(slot_id)
	local ok, clip = pcall(function()
		return Ammo.current_ammo_in_clips(slot_component)
	end)

	if not ok then
		return 0, 0
	end

	local reserve = slot_component.current_ammunition_reserve or 0

	return clip or 0, reserve
end

HudElementDivisionHUD._pick_ranged_ammo_slot_id = function(self, unit_data_extension, visual_loadout_extension)
	if self:_slot_has_ranged_ammunition(unit_data_extension, visual_loadout_extension, "slot_primary") then
		return "slot_primary"
	end

	if self:_slot_has_ranged_ammunition(unit_data_extension, visual_loadout_extension, "slot_secondary") then
		return "slot_secondary"
	end

	return nil
end

HudElementDivisionHUD._update_ammo_big = function(self, player_unit, widget, opacity)
	if not mod:get("show_ammo") then
		widget.content.visible = false
		return
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")

	if not unit_data_extension or not visual_loadout_extension then
		widget.content.visible = false
		return
	end

	widget.content.visible = true

	local ammo_slot_id = self:_pick_ranged_ammo_slot_id(unit_data_extension, visual_loadout_extension)

	if not ammo_slot_id then
		widget.content.text = ""
		widget.content.text_reserve = ""
		widget.style.background.color[1] = 200 * opacity
		widget.style.text.text_color[1] = 255 * opacity
		widget.style.text_reserve.text_color[1] = 255 * opacity
		widget.dirty = true
		return
	end

	local clip, reserve = self:_read_weapon_slot_clip_reserve(unit_data_extension, visual_loadout_extension, ammo_slot_id)

	widget.content.text = string.format("%d", clip)
	widget.content.text_reserve = string.format("%d", reserve)
	widget.style.background.color[1] = 200 * opacity
	widget.style.text.text_color[1] = 255 * opacity
	widget.style.text_reserve.text_color[1] = 255 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_right_slot_grid = function(self, player_unit, widgets, opacity)
	local extensions = self:_build_extensions(player_unit)

	if not extensions then
		for i = 1, RIGHT_SLOT_COUNT do
			local name = right_slot_widget_names[i]
			local widget = widgets[name]

			if widget then
				widget.content.visible = false
			end
		end

		return
	end

	local row = SlotData.build_division_right_slots(extensions)

	for i = 1, RIGHT_SLOT_COUNT do
		local name = right_slot_widget_names[i]
		local widget = widgets[name]
		local entry = row[i]

		if not widget or not entry then
			if widget then
				widget.content.visible = false
			end
		else
			local slot_id = entry.slot_id
			local visible = self:_slot_cell_visible(slot_id)

			widget.content.visible = visible

			if visible then
				self:_apply_slot_icon_material(widget, entry)
				widget.content.text = self:_slot_numeric_text(slot_id, entry, player_unit)
				widget.style.background.color[1] = 200 * opacity
				widget.style.text.text_color[1] = 255 * opacity
				widget.style.icon.color[1] = 255 * opacity
				widget.dirty = true
			end
		end
	end
end

HudElementDivisionHUD.init = function(self, parent, draw_layer, start_scale)
	local definitions = {
		scenegraph_definition = Definitions.scenegraph_definition,
		widget_definitions = Definitions.widget_definitions,
	}

	HudElementDivisionHUD.super.init(self, parent, draw_layer, start_scale, definitions)

	self._buff_widgets = {}
	self._max_buffs = 9

	local widgets = self._widgets_by_name

	for _, widget in pairs(widgets) do
		widget.content.visible = false
	end

	Managers.event:register(self, "event_player_profile_updated", "_event_player_profile_updated")
end

HudElementDivisionHUD.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementDivisionHUD.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local game_mode_manager = Managers.state.game_mode
	local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()
	local is_in_hub = not game_mode_name or game_mode_name == "hub" or game_mode_name == "prologue_hub"

	if is_in_hub then
		self:_set_all_visible(false)
		return
	end

	local player = Managers.player:local_player(1)

	if not player then
		self:_set_all_visible(false)
		return
	end

	local player_unit = player.player_unit

	if not player_unit or not ALIVE[player_unit] then
		self:_set_all_visible(false)
		return
	end

	local pos_x = mod:get("position_x") or 0
	local pos_y = mod:get("position_y") or 0
	local opacity = mod:get("opacity") or 1.0

	local root_pos = self._ui_scenegraph.root.position

	root_pos[1] = 20 + pos_x
	root_pos[2] = 50 + pos_y

	local widgets = self._widgets_by_name

	self:_update_stamina_bar(player_unit, widgets.stamina_bar, opacity)
	self:_update_health_bar(player_unit, widgets.health_bar, opacity)
	self:_update_ability_bar(player_unit, widgets.ability_bar, opacity)
	self:_update_ammo_big(player_unit, widgets.ammo_big, opacity)
	self:_update_right_slot_grid(player_unit, widgets, opacity)
	self:_update_buffs(player_unit, t, ui_renderer, opacity)
end

HudElementDivisionHUD._update_stamina_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_stamina_bar") then
		widget.content.visible = false
		return
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

	if not unit_data_extension then
		widget.content.visible = false
		return
	end

	local stamina_component = unit_data_extension:read_component("stamina")

	if not stamina_component then
		widget.content.visible = false
		return
	end

	local stamina_fraction = stamina_component.current_fraction or 0

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * stamina_fraction
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_health_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_health_bar") then
		widget.content.visible = false
		return
	end

	local health_extension = ScriptUnit.has_extension(player_unit, "health_system")

	if not health_extension then
		widget.content.visible = false
		return
	end

	local health_percent = health_extension:current_health_percent() or 0

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * health_percent
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_ability_bar = function(self, player_unit, widget, opacity)
	if not mod:get("show_ability_timer") then
		widget.content.visible = false
		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not ability_extension or not buff_extension then
		widget.content.visible = false
		return
	end

	local remaining_cooldown = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE)
	local max_cooldown = ability_extension:max_ability_cooldown(COMBAT_ABILITY_TYPE)

	if not remaining_cooldown or remaining_cooldown <= 0 or not max_cooldown or max_cooldown <= 0 then
		widget.content.visible = false
		return
	end

	local progress = 1 - (remaining_cooldown / max_cooldown)

	widget.content.visible = true
	widget.style.fill.size[1] = BAR_WIDTH * progress
	widget.style.fill.color[1] = 255 * opacity
	widget.style.background.color[1] = 160 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_buffs = function(self, player_unit, t, ui_renderer, opacity)
	if not mod:get("show_buffs") then
		self:_clear_buff_widgets(ui_renderer)

		return
	end

	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	if not buff_extension then
		return
	end

	local active_buffs = {}
	local buffs_by_index = buff_extension._buffs_by_index

	if buffs_by_index then
		for _, buff in pairs(buffs_by_index) do
			local template = buff:template()

			if template and template.hud_icon then
				local remaining = buff:duration() or 0

				if remaining > 0 then
					table.insert(active_buffs, {
						icon = template.hud_icon,
						duration = remaining,
					})
				end
			end
		end
	end

	local needed_widgets = math.min(#active_buffs, self._max_buffs)
	local current_widgets = #self._buff_widgets

	while current_widgets < needed_widgets do
		current_widgets = current_widgets + 1
		local widget_name = "buff_" .. current_widgets
		local offset_x = (current_widgets - 1) * (BUFF_SIZE + BUFF_SPACING)
		local widget_def = UIWidget.create_definition({
			{
				pass_type = "rect",
				style_id = "background",
				style = {
					color = { 200, 200, 200, 50 },
					size = { BUFF_SIZE, BUFF_SIZE },
					offset = { offset_x, 0, 0 },
				},
			},
			{
				pass_type = "texture",
				style_id = "icon",
				value = BUFF_ICON_BASE_MATERIAL,
				value_id = "icon",
				style = {
					size = { BUFF_SIZE - 4, BUFF_SIZE - 4 },
					color = UIHudSettings.color_tint_main_1,
					offset = { offset_x + 2, 2, 1 },
					material_values = {
						texture_map = BUFF_ICON_FALLBACK_TEXTURE,
						use_placeholder_texture = 0,
					},
				},
			},
		}, "buffs_row")

		local created_widget = self:_create_widget(widget_name, widget_def)

		self._buff_widgets[current_widgets] = created_widget
	end

	while current_widgets > needed_widgets do
		local widget = self._buff_widgets[current_widgets]

		if widget then
			local widget_name = "buff_" .. current_widgets

			self:_unregister_widget_name(widget_name)
			UIWidget.destroy(ui_renderer, widget)
		end

		self._buff_widgets[current_widgets] = nil
		current_widgets = current_widgets - 1
	end

	for i = 1, needed_widgets do
		local widget = self._buff_widgets[i]
		local buff_data = active_buffs[i]

		if widget and buff_data then
			local tex = buff_data.icon

			if type(tex) ~= "string" or tex == "" or tex == "content/ui/materials/base/ui_default_base" then
				tex = BUFF_ICON_FALLBACK_TEXTURE
			end

			widget.content.icon = BUFF_ICON_BASE_MATERIAL

			local icon_style = widget.style and widget.style.icon

			if icon_style then
				local mv = icon_style.material_values

				if not mv then
					icon_style.material_values = {}
					mv = icon_style.material_values
				end

				mv.texture_map = tex
				mv.use_placeholder_texture = 0
			end

			widget.style.background.color[1] = 200 * opacity
			widget.style.icon.color[1] = 255 * opacity
			widget.dirty = true
		end
	end
end

HudElementDivisionHUD._clear_buff_widgets = function(self, ui_renderer)
	for i, buff_widget in ipairs(self._buff_widgets) do
		if buff_widget then
			local widget_name = "buff_" .. i

			self:_unregister_widget_name(widget_name)

			if ui_renderer then
				UIWidget.destroy(ui_renderer, buff_widget)
			end
		end
	end

	self._buff_widgets = {}
end

HudElementDivisionHUD._event_player_profile_updated = function(self)
	local ui_renderer = self._parent and self._parent._ui_renderer

	self:_clear_buff_widgets(ui_renderer)
end

HudElementDivisionHUD._set_all_visible = function(self, visible)
	local widgets = self._widgets_by_name

	for _, widget in pairs(widgets) do
		widget.content.visible = visible
	end
end

HudElementDivisionHUD._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	HudElementDivisionHUD.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

	for i = 1, #self._buff_widgets do
		local widget = self._buff_widgets[i]

		if widget then
			UIWidget.draw(widget, ui_renderer)
		end
	end
end

HudElementDivisionHUD.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementDivisionHUD.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

HudElementDivisionHUD.destroy = function(self, ui_renderer)
	Managers.event:unregister(self, "event_player_profile_updated")
	self:_clear_buff_widgets(ui_renderer)

	HudElementDivisionHUD.super.destroy(self, ui_renderer)
end

return HudElementDivisionHUD
