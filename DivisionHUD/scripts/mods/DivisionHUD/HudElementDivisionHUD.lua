local mod = get_mod("DivisionHUD")

require("scripts/ui/hud/elements/hud_element_base")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local Ammo = require("scripts/utilities/ammo")
local Stamina = require("scripts/utilities/attack/stamina")

local HudElementDivisionHUD = class("HudElementDivisionHUD", "HudElementBase")

local BAR_WIDTH = 330
local BAR_HEIGHT = 8
local BOX_SIZE = 120
local BOX_SPACING = 4
local BUFF_SIZE = 32

local COMBAT_ABILITY_TYPE = "combat_ability"
local GRENADE_ABILITY_TYPE = "grenade_ability"

local function _create_scenegraph()
	return {
		screen = {
			scale = "fit",
			size = { 1920, 1080 },
			position = { 0, 0, 0 },
		},
		root = {
			parent = "screen",
			horizontal_alignment = "center",
			vertical_alignment = "center",
			size = { BAR_WIDTH, 200 },
			position = { 300, 200, 100 },
		},
		stamina_bar = {
			parent = "root",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { BAR_WIDTH, BAR_HEIGHT },
			position = { 0, 0, 0 },
		},
		health_bar = {
			parent = "stamina_bar",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { BAR_WIDTH, BAR_HEIGHT },
			position = { 0, BAR_HEIGHT + 2, 0 },
		},
		ability_bar = {
			parent = "health_bar",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { BAR_WIDTH, BAR_HEIGHT },
			position = { 0, BAR_HEIGHT + 2, 0 },
		},
		boxes_row = {
			parent = "ability_bar",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { BAR_WIDTH, BOX_SIZE },
			position = { 0, BAR_HEIGHT + 8, 0 },
		},
		ammo_box = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { BOX_SIZE, BOX_SIZE },
			position = { 0, 0, 0 },
		},
		special_box = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { (BOX_SIZE - BOX_SPACING) / 2, BOX_SIZE },
			position = { BOX_SIZE + BOX_SPACING, 0, 0 },
		},
		ultimate_box = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { (BOX_SIZE - BOX_SPACING) / 2, (BOX_SIZE - BOX_SPACING) / 2 },
			position = { BOX_SIZE + (BOX_SIZE - BOX_SPACING) / 2 + BOX_SPACING * 2, 0, 0 },
		},
		grenades_box = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { (BOX_SIZE - BOX_SPACING) / 2, (BOX_SIZE - BOX_SPACING) / 2 },
			position = { BOX_SIZE + (BOX_SIZE - BOX_SPACING) / 2 + (BOX_SIZE - BOX_SPACING) / 2 + BOX_SPACING * 3, 0, 0 },
		},
		stimm_box = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { (BOX_SIZE - BOX_SPACING) / 2, (BOX_SIZE - BOX_SPACING) / 2 },
			position = { BOX_SIZE + (BOX_SIZE - BOX_SPACING) / 2 + BOX_SPACING * 2, (BOX_SIZE - BOX_SPACING) / 2 + BOX_SPACING, 0 },
		},
		pickup_box = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { (BOX_SIZE - BOX_SPACING) / 2, (BOX_SIZE - BOX_SPACING) / 2 },
			position = { BOX_SIZE + (BOX_SIZE - BOX_SPACING) / 2 + (BOX_SIZE - BOX_SPACING) / 2 + BOX_SPACING * 3, (BOX_SIZE - BOX_SPACING) / 2 + BOX_SPACING, 0 },
		},
		buffs_row = {
			parent = "boxes_row",
			horizontal_alignment = "left",
			vertical_alignment = "top",
			size = { BAR_WIDTH, BUFF_SIZE },
			position = { 0, BOX_SIZE + 8, 0 },
		},
	}
end

local function _create_bar_widget(scenegraph_id, color)
	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 160, 0, 0, 0 },
				offset = { 0, 0, 0 },
				size = { BAR_WIDTH, BAR_HEIGHT },
			},
		},
		{
			pass_type = "rect",
			style_id = "fill",
			value_id = "fill",
			style = {
				horizontal_alignment = "left",
				color = color or { 255, 100, 200, 100 },
				offset = { 0, 0, 1 },
				size = { BAR_WIDTH, BAR_HEIGHT },
			},
		},
	}, scenegraph_id)
end

local function _create_box_widget(scenegraph_id)
	local text_style = table.clone(UIFontSettings.hud_body)
	text_style.font_type = "machine_medium"
	text_style.font_size = 22
	text_style.drop_shadow = true
	text_style.text_horizontal_alignment = "center"
	text_style.text_vertical_alignment = "center"
	text_style.text_color = UIHudSettings.color_tint_main_1
	text_style.offset = { 0, 0, 2 }

	local label_style = table.clone(text_style)
	label_style.font_size = 14
	label_style.text_vertical_alignment = "top"
	label_style.offset = { 0, 2, 2 }

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 200, 60, 60, 60 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "",
			style_id = "text",
			style = text_style,
		},
		{
			pass_type = "text",
			value_id = "label",
			value = "",
			style_id = "label",
			style = label_style,
		},
	}, scenegraph_id)
end

local function _create_ammo_box_widget(scenegraph_id)
	local text_style = table.clone(UIFontSettings.hud_body)
	text_style.font_type = "machine_medium"
	text_style.font_size = 70
	text_style.drop_shadow = true
	text_style.text_horizontal_alignment = "center"
	text_style.text_vertical_alignment = "center"
	text_style.text_color = UIHudSettings.color_tint_main_1
	text_style.offset = { 0, -15, 2 }

	local text_style_reserve = table.clone(text_style)
	text_style_reserve.font_size = 30
	text_style_reserve.offset = { 0, 30, 2 }

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 200, 0, 0, 0 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "",
			style_id = "text",
			style = text_style,
		},
		{
			pass_type = "text",
			value_id = "text_reserve",
			value = "",
			style_id = "text_reserve",
			style = text_style_reserve,
		},
	}, scenegraph_id)
end

local function _create_ultimate_box_widget(scenegraph_id)
	local text_style = table.clone(UIFontSettings.hud_body)
	text_style.font_type = "machine_medium"
	text_style.font_size = 30
	text_style.drop_shadow = true
	text_style.text_horizontal_alignment = "center"
	text_style.text_vertical_alignment = "center"
	text_style.text_color = UIHudSettings.color_tint_main_1
	text_style.offset = { 0, 0, 2 }

	return UIWidget.create_definition({
		{
			pass_type = "rect",
			style_id = "background",
			value_id = "background",
			style = {
				color = { 10, 255, 255, 255 },
				offset = { 0, 0, 0 },
			},
		},
		{
			pass_type = "texture",
			style_id = "icon",
			value_id = "icon",
			value = "content/ui/materials/icons/talents/hud/combat_container",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = { 60, 60 },
				offset = { 0, 0, 1 },
				color = { 255, 255, 255, 255 },
				material_values = {
					progress = 1,
					talent_icon = nil,
				},
			},
		},
		{
			pass_type = "text",
			value_id = "text",
			value = "",
			style_id = "text",
			style = text_style,
		},
	}, scenegraph_id)
end

local function _create_widgets()
	return {
		stamina_bar = _create_bar_widget("stamina_bar", { 255, 100, 200, 255 }),
		health_bar = _create_bar_widget("health_bar", { 255, 100, 255, 100 }),
		ability_bar = _create_bar_widget("ability_bar", { 255, 255, 50, 50 }),
		ammo_box = _create_ammo_box_widget("ammo_box"),
		special_box = _create_box_widget("special_box"),
		ultimate_box = _create_ultimate_box_widget("ultimate_box"),
		stimm_box = _create_box_widget("stimm_box"),
		grenades_box = _create_box_widget("grenades_box"),
		pickup_box = _create_box_widget("pickup_box"),
	}
end

HudElementDivisionHUD.init = function(self, parent, draw_layer, start_scale)
	local definitions = {
		scenegraph_definition = _create_scenegraph(),
		widget_definitions = _create_widgets(),
	}

	HudElementDivisionHUD.super.init(self, parent, draw_layer, start_scale, definitions)

	self._buff_widgets = {}
	self._max_buffs = 9
	
	local widgets = self._widgets_by_name
	for _, widget in pairs(widgets) do
		widget.content.visible = false
	end
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
	local scale = mod:get("scale") or 1.0
	local opacity = mod:get("opacity") or 1.0

	local root_pos = self._ui_scenegraph.root.position
	root_pos[1] = 20 + pos_x
	root_pos[2] = 50 + pos_y

	local widgets = self._widgets_by_name

	self:_update_stamina_bar(player_unit, widgets.stamina_bar, opacity)
	self:_update_health_bar(player_unit, widgets.health_bar, opacity)
	self:_update_ability_bar(player_unit, widgets.ability_bar, opacity)
	self:_update_ammo_box(player_unit, widgets.ammo_box, opacity)
	self:_update_special_box(player_unit, widgets.special_box, opacity)
	self:_update_ultimate_box(player_unit, widgets.ultimate_box, opacity)
	self:_update_stimm_box(player_unit, widgets.stimm_box, opacity)
	self:_update_grenades_box(player_unit, widgets.grenades_box, opacity)
	self:_update_pickup_box(player_unit, widgets.pickup_box, opacity)
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

HudElementDivisionHUD._update_ammo_box = function(self, player_unit, widget, opacity)
	if not mod:get("show_ammo") then
		widget.content.visible = false
		return
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	if not unit_data_extension then
		widget.content.visible = false
		return
	end

	local inventory_component = unit_data_extension:read_component("inventory")
	local wielded_slot = inventory_component.wielded_slot

	if wielded_slot == "none" or wielded_slot == "slot_unarmed" then
		widget.content.visible = false
		return
	end

	local slot_component = unit_data_extension:read_component(wielded_slot)
	if not slot_component then
		widget.content.visible = false
		return
	end

	local current_clip = Ammo.current_ammo_in_clips(slot_component)
	local current_reserve = slot_component.current_ammunition_reserve
	local max_reserve = slot_component.max_ammunition_reserve

	if max_reserve <= 0 then
		-- widget.content.visible = false
		return
	end

	widget.content.visible = true
	widget.content.text = string.format("%d", current_clip)
	widget.content.text_reserve = string.format("%d", current_reserve)
	widget.content.label = ""
	widget.style.background.color[1] = 200 * opacity
	widget.style.text.text_color[1] = 255 * opacity
	widget.style.text_reserve.text_color[1] = 255 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_special_box = function(self, player_unit, widget, opacity)
	if not mod:get("show_special") then
		widget.content.visible = false
		return
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	local weapon_extension = ScriptUnit.has_extension(player_unit, "weapon_system")
	
	if not unit_data_extension or not weapon_extension then
		widget.content.visible = false
		return
	end

	local inventory_component = unit_data_extension:read_component("inventory")
	local wielded_slot = inventory_component.wielded_slot

	if wielded_slot == "none" or wielded_slot == "slot_unarmed" then
		widget.content.visible = false
		return
	end

	local slot_component = unit_data_extension:read_component(wielded_slot)
	if not slot_component then
		widget.content.visible = false
		return
	end

	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
	local weapon_template = visual_loadout_extension and visual_loadout_extension:weapon_template_from_slot(wielded_slot)
	local hud_configuration = weapon_template and weapon_template.hud_configuration
	local uses_special_charges = hud_configuration and hud_configuration.uses_weapon_special_charges

	if uses_special_charges then
		local charges = slot_component.num_special_charges or 0
		widget.content.visible = true
		widget.content.text = string.format("%02d", charges)
		widget.content.label = ""
		widget.style.background.color[1] = 200 * opacity
		widget.style.text.text_color[1] = 255 * opacity
		widget.dirty = true
	else
		local special_active = slot_component.special_active
		
		widget.content.visible = special_active == true
		if special_active then
			widget.content.text = "ON"
			widget.content.label = ""
			widget.style.background.color[1] = 200 * opacity
			widget.style.text.text_color[1] = 255 * opacity
			widget.dirty = true
		end
	end
end

HudElementDivisionHUD._update_ultimate_box = function(self, player_unit, widget, opacity)
	if not mod:get("show_ultimate") then
		widget.content.visible = false
		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	if not ability_extension then
		widget.content.visible = false
		return
	end

	local equipped_abilities = ability_extension:equipped_abilities()
	local combat_ability = equipped_abilities and equipped_abilities[COMBAT_ABILITY_TYPE]
	local ability_icon = combat_ability and combat_ability.hud_icon or "content/ui/materials/icons/abilities/default"
	
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(COMBAT_ABILITY_TYPE)
	
	widget.content.visible = true
	if widget.style.icon.material_values then
		widget.style.icon.material_values.talent_icon = ability_icon
	end
	
	if remaining_cooldown and remaining_cooldown > 0 then
		widget.content.text = string.format("%.0f", remaining_cooldown)
	else
		widget.content.text = ""
	end
	
	-- widget.style.background.color[1] = 200 * opacity
	widget.style.background.color[1] = 50
	widget.style.icon.color[1] = 255 * opacity
	widget.style.text.text_color[1] = 255 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_stimm_box = function(self, player_unit, widget, opacity)
	if not mod:get("show_stimm") then
		widget.content.visible = false
		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	if not ability_extension then
		widget.content.visible = false
		return
	end

	local pocketable_type = "pocketable_ability"
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(pocketable_type)
	
	widget.content.visible = true
	
	if remaining_cooldown and remaining_cooldown > 0 then
		widget.content.text = string.format("%.0f", remaining_cooldown)
	else
		widget.content.text = "RDY"
	end
	
	widget.content.label = "СТИММ"
	widget.style.background.color[1] = 200 * opacity
	widget.style.text.text_color[1] = 255 * opacity
	widget.style.label.text_color[1] = 200 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_grenades_box = function(self, player_unit, widget, opacity)
	if not mod:get("show_grenades") then
		widget.content.visible = false
		return
	end

	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	if not ability_extension then
		widget.content.visible = false
		return
	end

	local remaining_charges = ability_extension:remaining_ability_charges(GRENADE_ABILITY_TYPE)
	
	widget.content.visible = true
	widget.content.text = string.format("%02d", remaining_charges or 0)
	widget.content.label = "ГРАНАТЫ"
	widget.style.background.color[1] = 200 * opacity
	widget.style.text.text_color[1] = 255 * opacity
	widget.style.label.text_color[1] = 200 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_pickup_box = function(self, player_unit, widget, opacity)
	if not mod:get("show_pickups") then
		widget.content.visible = false
		return
	end

	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
	if not visual_loadout_extension then
		widget.content.visible = false
		return
	end

	local weapon_template = visual_loadout_extension:weapon_template_from_slot("slot_pocketable")
	if not weapon_template then
		widget.content.visible = false
		return
	end

	local pickup_name = weapon_template.pickup_name or weapon_template.name
	local display_text = "01"
	local display_label = "АММО"

	if pickup_name == "ammo_cache_deployable" then
		display_label = "АММО"
	elseif string.find(pickup_name or "", "medical") then
		display_label = "АПТЕЧКА"
	else
		widget.content.visible = false
		return
	end

	widget.content.visible = true
	widget.content.text = display_text
	widget.content.label = display_label
	widget.style.background.color[1] = 200 * opacity
	widget.style.text.text_color[1] = 255 * opacity
	widget.style.label.text_color[1] = 200 * opacity
	widget.dirty = true
end

HudElementDivisionHUD._update_buffs = function(self, player_unit, t, ui_renderer, opacity)
	if not mod:get("show_buffs") then
		for i, buff_widget in ipairs(self._buff_widgets) do
			if buff_widget then
				local widget_name = "buff_" .. i
				self:_unregister_widget_name(widget_name)
				UIWidget.destroy(ui_renderer, buff_widget)
			end
		end
		self._buff_widgets = {}
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
		local offset_x = (current_widgets - 1) * (BUFF_SIZE + 4)
		local widget = UIWidget.create_definition({
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
				value_id = "icon",
				value = "content/ui/materials/icons/generic/blank",
				style_id = "icon",
				style = {
					size = { BUFF_SIZE - 4, BUFF_SIZE - 4 },
					color = UIHudSettings.color_tint_main_1,
					offset = { offset_x + 2, 2, 1 },
				},
			},
		}, "buffs_row")
		
		local created_widget = self:_create_widget(widget_name, widget)
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
			widget.content.icon = buff_data.icon
			widget.style.background.color[1] = 200 * opacity
			widget.style.icon.color[1] = 255 * opacity
			widget.dirty = true
		end
	end
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
	for i, widget in ipairs(self._buff_widgets) do
		if widget then
			local widget_name = "buff_" .. i
			self:_unregister_widget_name(widget_name)
			UIWidget.destroy(ui_renderer, widget)
		end
	end
	self._buff_widgets = {}

	HudElementDivisionHUD.super.destroy(self, ui_renderer)
end

return HudElementDivisionHUD

