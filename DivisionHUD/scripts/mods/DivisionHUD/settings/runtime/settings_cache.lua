local mod = get_mod("DivisionHUD")

local DivisionHUD_settings_defaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/defaults")

mod._settings = mod._settings or {}

local APPLY_SETTINGS_HANDLERS = {
	"divisionhud_debug_apply_settings",
	"divisionhud_vanilla_hud_apply_settings",
	"divisionhud_mission_objective_apply_settings",
	"divisionhud_proximity_apply_settings",
	"divisionhud_alerts_apply_settings",
}

local function divisionhud_apply_settings_handlers(setting_id)
	for i = 1, #APPLY_SETTINGS_HANDLERS do
		local fn = mod[APPLY_SETTINGS_HANDLERS[i]]

		if type(fn) == "function" then
			pcall(fn, setting_id)
		end
	end
end

function mod.divisionhud_refresh_settings_cache()
	if type(DivisionHUD_settings_defaults) ~= "table" then
		return
	end

	for key in pairs(DivisionHUD_settings_defaults) do
		mod._settings[key] = mod:get(key)
	end
end

mod.divisionhud_refresh_settings_cache()

mod.on_setting_changed = function(setting_id)
	mod._settings[setting_id] = mod:get(setting_id)

	divisionhud_apply_settings_handlers(setting_id)

	if setting_id ~= "divisionhud_reset_all_settings" then
		return
	end

	if mod:get("divisionhud_reset_all_settings") ~= 1 then
		return
	end

	mod:set("divisionhud_reset_all_settings", 0, true)

	if type(DivisionHUD_settings_defaults) ~= "table" then
		return
	end

	for key, value in pairs(DivisionHUD_settings_defaults) do
		mod:set(key, value, true)
	end

	mod:notify(mod:localize("divisionhud_reset_done"))
	mod.divisionhud_refresh_settings_cache()
	divisionhud_apply_settings_handlers("divisionhud_reset_all_settings")
end

return mod
