require("scripts/foundation/utilities/color")

local MATERIAL_GRADIENT_VERTICAL = "content/ui/materials/gradients/gradient_vertical"
local MATERIAL_WEAPON_HUD = "content/ui/materials/hud/backgrounds/terminal_background_weapon"

local function set_strip_fill_size_addition(widget, add_w, add_h)
	local st = widget.style and widget.style.strip_fill

	if not st then
		return
	end

	if not st.size_addition then
		st.size_addition = { 0, 0 }
	end

	st.size_addition[1] = add_w
	st.size_addition[2] = add_h
end

local function copy_argb(dst, src)
	if not dst or not src then
		return
	end

	dst[1] = src[1]
	dst[2] = src[2]
	dst[3] = src[3]
	dst[4] = src[4]
end

local function tint_strip_fill(widget, get_rgba)
	if not widget or type(get_rgba) ~= "function" then
		return
	end

	local st = widget.style and widget.style.strip_fill

	if not st then
		return
	end

	local rgba = get_rgba()

	if not rgba then
		return
	end

	if st.color then
		copy_argb(st.color, rgba)
	end

	if st.default_color then
		copy_argb(st.default_color, rgba)
	end
end

local function apply_simple_strip(widget, get_tint_rgba)
	local c = widget.content

	c.weapon_stats_dim_visible = false
	c.strip_fill_visible = true
	c.terminal_chrome_visible = true
	c.shadow_visible = true
	c.strip_fill_material = MATERIAL_GRADIENT_VERTICAL

	set_strip_fill_size_addition(widget, 0, 0)

	tint_strip_fill(widget, get_tint_rgba)
end

local function apply_vanilla_weapon_hud_strip(widget)
	local c = widget.content

	c.weapon_stats_dim_visible = false
	c.strip_fill_visible = true
	c.terminal_chrome_visible = true
	c.shadow_visible = true
	c.strip_fill_material = MATERIAL_WEAPON_HUD

	set_strip_fill_size_addition(widget, 0, 0)

	tint_strip_fill(widget, function()
		return table.clone(Color.terminal_background_gradient(255, true))
	end)
end

local function apply_vanilla_weapon_hud_strip_no_chrome(widget)
	local c = widget.content

	c.weapon_stats_dim_visible = false
	c.strip_fill_visible = true
	c.terminal_chrome_visible = false
	c.shadow_visible = false
	c.strip_fill_material = MATERIAL_WEAPON_HUD

	set_strip_fill_size_addition(widget, 0, 0)

	tint_strip_fill(widget, function()
		return table.clone(Color.terminal_background_gradient(255, true))
	end)
end

local function tonumber_safe(raw)
	if type(raw) == "string" then
		return tonumber(raw)
	end

	return raw
end

local function normalize_mode_main(raw, raw_default)
	local v = tonumber_safe(raw)

	if v == 0 or v == 1 or v == 2 or v == 3 then
		return v
	end

	local d = tonumber_safe(raw_default)

	if d == 0 or d == 1 or d == 2 or d == 3 then
		return d
	end

	return 0
end

local function normalize_mode_proximity(raw, raw_default)
	local v = tonumber_safe(raw)

	if v == 0 or v == 1 or v == 2 then
		return v + 1
	end

	local d = tonumber_safe(raw_default)

	if d == 0 or d == 1 or d == 2 then
		return d + 1
	end

	return 1
end

local function normalize_mode_enemy_target(raw, raw_default)
	local v = tonumber_safe(raw)

	if v == 0 or v == 1 or v == 2 or v == 3 or v == 4 then
		return v
	end

	local d = tonumber_safe(raw_default)

	if d == 0 or d == 1 or d == 2 or d == 3 or d == 4 then
		return d
	end

	return 0
end

local function apply_strip_background_to_widget(widget, internal_mode)
	if not widget or not widget.content then
		return
	end

	internal_mode = tonumber_safe(internal_mode) or 0

	if internal_mode == 0 then
		apply_vanilla_weapon_hud_strip_no_chrome(widget)
	elseif internal_mode == 1 then
		apply_vanilla_weapon_hud_strip(widget)
	elseif internal_mode == 2 then
		apply_simple_strip(widget, function()
			return table.clone(Color.terminal_background_gradient(nil, true))
		end)
	elseif internal_mode == 3 then
		apply_simple_strip(widget, function()
			return table.clone(Color.black(nil, true))
		end)
	end

	widget.dirty = true
end

local PRESETS = {
	[0] = { id = "vanilla_hud_weapon_slot_background_no_chrome" },
	[1] = { id = "vanilla_hud_weapon_slot_background" },
	[2] = { id = "simple_terminal_background_gradient" },
	[3] = { id = "simple_black" },
}

local function resolve_preset(internal_mode)
	return PRESETS[tonumber_safe(internal_mode) or 0] or PRESETS[0]
end

return {
	PRESETS = PRESETS,
	DROPDOWN_VALUES_MAIN = { 0, 1, 2, 3 },
	DROPDOWN_VALUES_PROXIMITY = { 0, 1, 2 },
	DROPDOWN_VALUES_ENEMY_TARGET = { 0, 1, 2, 3, 4 },
	normalize_mode_main = normalize_mode_main,
	normalize_mode_proximity = normalize_mode_proximity,
	normalize_mode_enemy_target = normalize_mode_enemy_target,
	resolve_preset = resolve_preset,
	apply_strip_background_to_widget = apply_strip_background_to_widget,
}
