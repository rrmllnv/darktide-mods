-- Настройки группы divisionhud_auto_switch (data.lua): видимость Division HUD по
-- от первого/третьего лица (мод Perspectives, иначе first_person_system) и по слоту устройства в руках.

local mod = get_mod("DivisionHUD")
local SlotData = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/hud/data/slot_data")

local function is_first_person_effective(player_unit)
	if not player_unit or not ALIVE[player_unit] then
		return true
	end

	local perspectives_mod = get_mod("Perspectives")

	if perspectives_mod and type(perspectives_mod.is_requesting_third_person) == "function" then
		return not perspectives_mod.is_requesting_third_person()
	end

	if ScriptUnit.has_extension(player_unit, "first_person_system") then
		local fp_ext = ScriptUnit.extension(player_unit, "first_person_system")

		if fp_ext and type(fp_ext.wants_first_person_camera) == "function" then
			return fp_ext:wants_first_person_camera()
		end
	end

	return true
end

local function effective_hud_visible(s_op, player_unit, defaults)
	local base = type(s_op) ~= "table" or (s_op.divisionhud_visible ~= false and s_op.divisionhud_visible ~= 0)

	if not base then
		return false
	end

	if not player_unit then
		return base
	end

	local d = type(defaults) == "table" and defaults or {}
	local show_1p = s_op.divisionhud_auto_first_person

	if show_1p == nil then
		show_1p = d.divisionhud_auto_first_person
	end

	if show_1p == nil then
		show_1p = true
	end

	show_1p = show_1p ~= false and show_1p ~= 0

	local show_3p = s_op.divisionhud_auto_third_person

	if show_3p == nil then
		show_3p = d.divisionhud_auto_third_person
	end

	if show_3p == nil then
		show_3p = true
	end

	show_3p = show_3p ~= false and show_3p ~= 0

	local allow_hud_with_slot_device = mod:get("divisionhud_auto_slot_device")

	if allow_hud_with_slot_device == nil and type(s_op) == "table" then
		allow_hud_with_slot_device = s_op.divisionhud_auto_slot_device
	end

	if allow_hud_with_slot_device == nil then
		allow_hud_with_slot_device = d.divisionhud_auto_slot_device
	end

	if allow_hud_with_slot_device == nil then
		allow_hud_with_slot_device = false
	end

	allow_hud_with_slot_device = allow_hud_with_slot_device ~= false and allow_hud_with_slot_device ~= 0

	local ok_1p_3p

	if is_first_person_effective(player_unit) then
		ok_1p_3p = show_1p
	else
		ok_1p_3p = show_3p
	end

	if not allow_hud_with_slot_device and type(SlotData.is_wielding_slot_device) == "function" and SlotData.is_wielding_slot_device(player_unit) then
		return false
	end

	return ok_1p_3p
end

return {
	is_first_person_effective = is_first_person_effective,
	effective_hud_visible = effective_hud_visible,
}
