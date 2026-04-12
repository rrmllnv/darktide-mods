local mod = get_mod("DivisionHUD")

if mod._divisionhud_wielded_weapon_icon_tint_loaded then
	return
end

mod._divisionhud_wielded_weapon_icon_tint_loaded = true

local Color = Color

local WieldedWeaponIconColors = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/wielded_weapon_icon_colors")

if type(WieldedWeaponIconColors) ~= "table" then
	WieldedWeaponIconColors = {}
end

local function setting_enabled(setting_id)
	local s = mod._settings

	if type(s) ~= "table" then
		return false
	end

	local v = s[setting_id]

	if v == false or v == 0 then
		return false
	end

	return true
end

local function is_valid_argb_255(c)
	return type(c) == "table"
		and type(c[1]) == "number"
		and type(c[2]) == "number"
		and type(c[3]) == "number"
		and type(c[4]) == "number"
end

local function color_from_game_table(color_key)
	if type(color_key) ~= "string" or color_key == "" then
		return nil
	end

	local fn = Color and Color[color_key]

	if type(fn) ~= "function" then
		return nil
	end

	local ok, tbl = pcall(fn, 255, true)

	if ok and is_valid_argb_255(tbl) then
		return tbl
	end

	return nil
end

local function apply_argb_to_icon_style(icon_style, argb_255, hud_row_opacity)
	if not icon_style or not icon_style.color or not is_valid_argb_255(argb_255) then
		return false
	end

	local c = icon_style.color
	local op = type(hud_row_opacity) == "number" and hud_row_opacity == hud_row_opacity and hud_row_opacity or 1

	c[1] = math.floor((argb_255[1] or 255) * op)
	c[2] = argb_255[2] or 255
	c[3] = argb_255[3] or 255
	c[4] = argb_255[4] or 255

	return true
end

local function inventory_item_name_for_wielded_slot(player_unit, wielded_source_slot_id)
	if not player_unit or type(wielded_source_slot_id) ~= "string" or wielded_source_slot_id == "" then
		return nil
	end

	local ude = ScriptUnit.has_extension(player_unit, "unit_data_system") and ScriptUnit.extension(player_unit, "unit_data_system")

	if not ude or type(ude.read_component) ~= "function" then
		return nil
	end

	local inv = ude:read_component("inventory")

	if type(inv) ~= "table" then
		return nil
	end

	local name = inv[wielded_source_slot_id]

	if type(name) ~= "string" or name == "" or name == "not_equipped" then
		return nil
	end

	return name
end

local function read_slot_component(player_unit, wielded_source_slot_id)
	if not player_unit or type(wielded_source_slot_id) ~= "string" or wielded_source_slot_id == "" then
		return nil
	end

	local ude = ScriptUnit.has_extension(player_unit, "unit_data_system") and ScriptUnit.extension(player_unit, "unit_data_system")

	if not ude or type(ude.read_component) ~= "function" then
		return nil
	end

	return ude:read_component(wielded_source_slot_id)
end

mod.divisionhud_try_apply_wielded_weapon_icon_state_colors = function(widget, widget_name, entry, opacity, s_cfg, player_unit)
	if widget_name ~= "slot_weapon_wielded" then
		return false
	end

	if not setting_enabled("wielded_weapon_icon_state_colors") then
		return false
	end

	if type(entry) ~= "table" or entry.slot_id ~= "slot_wielded_display" or not entry.has_equipment then
		return false
	end

	local wield_slot = entry.wielded_source_slot_id

	if type(wield_slot) ~= "string" or wield_slot == "" then
		return false
	end

	local item_name = inventory_item_name_for_wielded_slot(player_unit, wield_slot)

	if not item_name then
		return false
	end

	local weapon_row = WieldedWeaponIconColors[item_name]

	if type(weapon_row) ~= "table" then
		return false
	end

	local inactive_key = weapon_row[2]
	local active_key = weapon_row[3]
	local cooldown_key = weapon_row[4]
	local inactive_argb = color_from_game_table(inactive_key) or { 255, 255, 255, 255 }
	local active_argb = color_from_game_table(active_key) or inactive_argb
	local cooldown_argb = cooldown_key and color_from_game_table(cooldown_key) or nil
	local slot_component = read_slot_component(player_unit, wield_slot)
	local special_active = slot_component and slot_component.special_active == true
	local num_special = slot_component and slot_component.num_special_charges
	local num_special_num = type(num_special) == "number" and num_special or 0
	local is_cooldown = slot_component ~= nil and cooldown_argb ~= nil and not special_active and num_special_num == 0
	local target_argb = is_cooldown and cooldown_argb or (special_active and active_argb or inactive_argb)
	local icon_style = widget and widget.style and widget.style.icon

	if not apply_argb_to_icon_style(icon_style, target_argb, opacity) then
		return false
	end

	widget.dirty = true

	return true
end

return mod
