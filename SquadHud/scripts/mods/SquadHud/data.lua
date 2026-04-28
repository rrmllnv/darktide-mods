local mod = get_mod("SquadHud")

mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/defaults")

local LayoutMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/layout")
local SquadHudMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/squad_hud")
local SystemMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/system")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			LayoutMenu,
			SquadHudMenu,
			SystemMenu,
		},
	},
}
