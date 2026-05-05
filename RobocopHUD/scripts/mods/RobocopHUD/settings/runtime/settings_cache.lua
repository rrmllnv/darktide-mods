local mod = get_mod("RobocopHUD")

local defaults = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/defaults")

mod._settings = mod._settings or {}

local APPLY_SETTINGS_HANDLERS = {
	"robocophud_vanilla_hud_apply_settings",
}

local function apply_settings_handlers(setting_id)
	for i = 1, #APPLY_SETTINGS_HANDLERS do
		local fn = mod[APPLY_SETTINGS_HANDLERS[i]]

		if type(fn) == "function" then
			pcall(fn, setting_id)
		end
	end
end

function mod.robocophud_refresh_settings_cache()
	if type(defaults) ~= "table" then
		return
	end

	for key in pairs(defaults) do
		local v = mod:get(key)

		if v == nil then
			v = defaults[key]
		end

		mod._settings[key] = v
	end
end

mod.robocophud_refresh_settings_cache()

mod.on_setting_changed = function(setting_id)
	mod._settings[setting_id] = mod:get(setting_id)

	if mod._settings[setting_id] == nil and type(defaults) == "table" and defaults[setting_id] ~= nil then
		mod._settings[setting_id] = defaults[setting_id]
	end

	apply_settings_handlers(setting_id)
end

return mod

