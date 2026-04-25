local mod = get_mod("DivisionHUD")

if not mod then
	return {}
end

mod.recolor_stimms_bridge = mod.recolor_stimms_bridge or {}

local Bridge = mod.recolor_stimms_bridge
local HudUtils = mod.hud_utils or {}
local _RS = nil

local function _rs()
	_RS = _RS or (HudUtils.resolve_mod and HudUtils.resolve_mod("RecolorStimms") or nil)

	return _RS
end

local function _rs_enabled(rs)
	return rs and (HudUtils.mod_is_enabled and HudUtils.mod_is_enabled(rs) or false)
end

function Bridge.refresh()
	_RS = HudUtils.resolve_mod and HudUtils.resolve_mod("RecolorStimms") or nil

	return Bridge.is_available()
end

function Bridge.is_available()
	local rs = _rs()

	return _rs_enabled(rs)
		and (
			type(rs.get_stimm_argb_255) == "function"
			or type(rs.get_stimm_color) == "function"
		)
end

function Bridge.stimm_argb255(stimm_id, fallback_argb255)
	local rs = _rs()

	if _rs_enabled(rs) and type(stimm_id) == "string" and stimm_id ~= "" then
		local fn255 = rs.get_stimm_argb_255

		if type(fn255) == "function" then
			local c = fn255(stimm_id)

			if HudUtils.is_valid_argb_255 and HudUtils.is_valid_argb_255(c) then
				return HudUtils.copy_argb_255 and HudUtils.copy_argb_255(c) or c
			end
		end

		local fn01 = rs.get_stimm_color

		if type(fn01) == "function" then
			local c01 = fn01(stimm_id)

			if type(c01) == "table" and type(c01[1]) == "number" and type(c01[2]) == "number" and type(c01[3]) == "number" then
				return {
					255,
					math.floor((c01[1] or 0) * 255 + 0.5),
					math.floor((c01[2] or 0) * 255 + 0.5),
					math.floor((c01[3] or 0) * 255 + 0.5),
				}
			end
		end
	end

	if HudUtils.copy_argb_255 and HudUtils.is_valid_argb_255 and HudUtils.is_valid_argb_255(fallback_argb255) then
		return HudUtils.copy_argb_255(fallback_argb255)
	end

	return fallback_argb255
end

return Bridge
