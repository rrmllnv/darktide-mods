local mod = get_mod("RobocopHUD")

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local themes = {
	classic_green = {
		id = "classic_green",
		text = { 255, 120, 255, 160 },
		accent = { 255, 60, 255, 120 },
		alert = UIHudSettings.color_tint_alert_2 or { 255, 255, 0, 0 },
		bg = { 120, 0, 0, 0 },
	},
	amber_tactical = {
		id = "amber_tactical",
		text = { 255, 255, 200, 80 },
		accent = { 255, 255, 160, 40 },
		alert = UIHudSettings.color_tint_alert_2 or { 255, 255, 0, 0 },
		bg = { 120, 0, 0, 0 },
	},
	police_blue = {
		id = "police_blue",
		text = { 255, 180, 220, 255 },
		accent = { 255, 120, 180, 255 },
		alert = UIHudSettings.color_tint_alert_2 or { 255, 255, 0, 0 },
		bg = { 120, 0, 0, 0 },
	},
}

function themes.resolve_theme(mod_settings)
	local id = mod_settings and mod_settings.theme_id
	local theme = (type(id) == "string" and themes[id]) or themes.classic_green

	return theme
end

mod.robocophud_themes = themes

return themes

