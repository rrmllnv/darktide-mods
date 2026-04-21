local mod = get_mod("DivisionHUD")

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/defaults")
local LayoutMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/layout")
local BarsMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/bars")
local DangerZoneMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/danger_zone")
local DynamicMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/dynamic")
local VanillaHudMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/vanilla_hud")
local AlertsMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/alerts")
local ProximityMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/proximity")
local IntegrationsMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/integrations")
local SystemMenu = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/menu/system")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			LayoutMenu,
			BarsMenu,
			DangerZoneMenu,
			DynamicMenu,
			VanillaHudMenu,
			AlertsMenu,
			ProximityMenu,
			IntegrationsMenu,
			SystemMenu,
		},
	},
}
