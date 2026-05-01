local mod = get_mod("SquadHud")

local PlayerDataRuntime = mod:io_dofile("SquadHud/scripts/mods/SquadHud/runtime/player_data_runtime")

local M = {}

local KEY_NAME_HIGHLIGHT_COLOR = {
	255,
	38,
	204,
	26,
}

local SHOW_DELAY = 5
local VISIBLE_DURATION = 10
local TRANSITION_DURATION = 0.45

local KEY_NAME_OVERRIDES = {
	["left alt"] = "Left Alt",
	["left ctrl"] = "Left Ctrl",
	["left shift"] = "Left Shift",
	["mouse left"] = "Mouse Left",
	["mouse middle"] = "Mouse Middle",
	["mouse right"] = "Mouse Right",
	["right alt"] = "Right Alt",
	["right ctrl"] = "Right Ctrl",
	["right shift"] = "Right Shift",
	["space"] = "Space",
}

local function smoothstep(value)
	value = math.clamp(value or 0, 0, 1)

	return value * value * (3 - 2 * value)
end

local function append_key_names(output, keys)
	if type(keys) == "string" then
		output[#output + 1] = keys
	elseif type(keys) == "table" then
		for i = 1, #keys do
			append_key_names(output, keys[i])
		end
	end
end

local function title_case_key_name(key_name)
	local normalized = string.lower(tostring(key_name or ""))
	local override = KEY_NAME_OVERRIDES[normalized]

	if override then
		return override
	end

	return string.gsub(normalized, "(%a)([%w_']*)", function(first, rest)
		return string.upper(first) .. rest
	end)
end

function M.keybind_text()
	local key_names = {}

	append_key_names(key_names, mod:get("squadhud_expanded_view_keybind"))

	if #key_names == 0 then
		return mod:localize("squadhud_expanded_view_hint_key_unbound")
	end

	for i = 1, #key_names do
		key_names[i] = title_case_key_name(key_names[i])
	end

	return table.concat(key_names, " + ")
end

local function wrap_key_name_colored(plain_key_text)
	local color = KEY_NAME_HIGHLIGHT_COLOR

	if type(color) ~= "table" or type(plain_key_text) ~= "string" or plain_key_text == "" then
		return plain_key_text
	end

	return "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. plain_key_text .. "{#reset()}"
end

function M.hint_text()
	if not M.hint_keybind_assigned() then
		return mod:localize("squadhud_expanded_view_hint_assign_key")
	end

	return mod:localize("squadhud_expanded_view_hint_text", wrap_key_name_colored(M.keybind_text()))
end

function M.reset(hud)
	hud._expanded_view_hint_eligible_start_t = nil
	hud._expanded_view_hint_show_start_t = nil
	hud._expanded_view_hint_finished = false
	hud._expanded_view_hint_fraction = 0
	hud._expanded_view_hint_text = nil
	hud._expanded_view_hint_dismiss_token_at_show = nil
end

function M.hint_location_allowed()
	return not PlayerDataRuntime.is_hub_game_mode()
end

function M.hint_keybind_assigned()
	local key_names = {}

	append_key_names(key_names, mod:get("squadhud_expanded_view_keybind"))

	for i = 1, #key_names do
		if type(key_names[i]) == "string" and string.match(key_names[i], "%S") then
			return true
		end
	end

	return false
end

function M.update_fraction(hud, t, eligible)
	if not eligible or not M.hint_location_allowed() then
		M.reset(hud)

		return 0
	end

	local now = type(t) == "number" and t or 0

	if hud._expanded_view_hint_finished then
		hud._expanded_view_hint_fraction = 0

		return 0
	end

	if not hud._expanded_view_hint_eligible_start_t then
		hud._expanded_view_hint_eligible_start_t = now
		hud._expanded_view_hint_fraction = 0

		return 0
	end

	if now - hud._expanded_view_hint_eligible_start_t < SHOW_DELAY then
		hud._expanded_view_hint_fraction = 0

		return 0
	end

	if not hud._expanded_view_hint_show_start_t then
		hud._expanded_view_hint_show_start_t = now
		hud._expanded_view_hint_text = M.hint_text()
		hud._expanded_view_hint_dismiss_token_at_show = mod._squadhud_expanded_view_hint_dismiss_token or 0
	end

	local dismiss_token = mod._squadhud_expanded_view_hint_dismiss_token or 0

	if dismiss_token > (hud._expanded_view_hint_dismiss_token_at_show or 0) then
		hud._expanded_view_hint_show_start_t = now - (TRANSITION_DURATION + VISIBLE_DURATION)
		hud._expanded_view_hint_dismiss_token_at_show = dismiss_token
	end

	local elapsed = now - hud._expanded_view_hint_show_start_t
	local fraction

	if elapsed < TRANSITION_DURATION then
		fraction = smoothstep(elapsed / TRANSITION_DURATION)
	elseif elapsed < TRANSITION_DURATION + VISIBLE_DURATION then
		fraction = 1
	elseif elapsed < TRANSITION_DURATION * 2 + VISIBLE_DURATION then
		fraction = 1 - smoothstep((elapsed - TRANSITION_DURATION - VISIBLE_DURATION) / TRANSITION_DURATION)
	else
		hud._expanded_view_hint_finished = true
		fraction = 0
	end

	hud._expanded_view_hint_fraction = fraction

	return fraction
end

function M.apply_widget(widget, fraction, settings)
	if not widget or not widget.content then
		return
	end

	local visible = fraction > 0.001

	widget.content.visible = visible
	widget.content.text = visible and widget.content.text or ""

	local style = widget.style

	if style then
		local background = style.background
		local text = style.text
		local slide_offset = settings.expanded_view_hint_slide_offset * (1 - math.clamp(fraction or 0, 0, 1))

		if background then
			background.offset[2] = -slide_offset
			background.color[1] = math.floor((settings.color_expanded_view_hint_background[1] or 255) * fraction + 0.5)
		end

		if text then
			text.offset[2] = -slide_offset

			local base_text = settings.color_text_default

			if base_text then
				text.text_color[1] = math.floor((base_text[1] or 255) * fraction + 0.5)
				text.text_color[2] = base_text[2]
				text.text_color[3] = base_text[3]
				text.text_color[4] = base_text[4]
			end
		end
	end

	widget.dirty = true
end

return M
