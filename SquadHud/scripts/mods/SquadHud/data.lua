local mod = get_mod("SquadHud")

mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/defaults")

local LayoutMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/layout")
local SocialMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/social")
local SquadHudMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/squad_hud")
local StrikeTeamMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/strike_team")
local VanillaHudMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/vanilla_hud")
local IntegrationsMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/integrations")
local SystemMenu = mod:io_dofile("SquadHud/scripts/mods/SquadHud/settings/menu/system")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			LayoutMenu,
			SocialMenu,
			SquadHudMenu,
			StrikeTeamMenu,
			VanillaHudMenu,
			IntegrationsMenu,
			SystemMenu,
		},
	},
}
