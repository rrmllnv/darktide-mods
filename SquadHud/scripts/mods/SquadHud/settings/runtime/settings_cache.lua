local mod = get_mod("SquadHud")

local SquadHudSettingsDefaults = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/defaults")

mod._settings = mod._settings or {}

local APPLY_SETTINGS_HANDLERS = {
	"squadhud_debug_apply_settings",
	"squadhud_vanilla_hud_apply_settings",
}

local function apply_settings_handlers(setting_id)
	for i = 1, #APPLY_SETTINGS_HANDLERS do
		local fn = mod[APPLY_SETTINGS_HANDLERS[i]]

		if type(fn) == "function" then
			pcall(fn, setting_id)
		end
	end
end

function mod.squadhud_refresh_settings_cache()
	if type(SquadHudSettingsDefaults) ~= "table" then
		return
	end

	for key in pairs(SquadHudSettingsDefaults) do
		mod._settings[key] = mod:get(key)
	end
end

mod.squadhud_refresh_settings_cache()

mod.on_setting_changed = function(setting_id)
	mod._settings[setting_id] = mod:get(setting_id)

	apply_settings_handlers(setting_id)

	if setting_id ~= "squadhud_reset_all_settings" then
		return
	end

	if mod:get("squadhud_reset_all_settings") ~= 1 then
		return
	end

	mod:set("squadhud_reset_all_settings", 0, true)

	if type(SquadHudSettingsDefaults) ~= "table" then
		return
	end

	for key, value in pairs(SquadHudSettingsDefaults) do
		mod:set(key, value, true)
	end

	mod:notify(mod:localize("squadhud_reset_done"))
	mod.squadhud_refresh_settings_cache()
	apply_settings_handlers("squadhud_reset_all_settings")
end

return mod
