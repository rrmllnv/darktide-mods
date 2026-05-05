local mod = get_mod("RobocopHUD")

mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/defaults")
local GeneralMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/general")
local ThemeMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/theme")
local TargetingMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/targeting")
local ScannerMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/scanner")
local WarningsMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/warnings")
local VanillaHudMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/vanilla_hud")
local SystemMenu = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/menu/system")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	allow_rehooking = false,

	options = {
		widgets = {
			GeneralMenu,
			ThemeMenu,
			TargetingMenu,
			ScannerMenu,
			WarningsMenu,
			VanillaHudMenu,
			SystemMenu,
		},
	},
}

