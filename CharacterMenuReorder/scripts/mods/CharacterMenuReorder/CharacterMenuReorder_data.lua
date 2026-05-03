local mod = get_mod("CharacterMenuReorder")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	allow_rehooking = false,
	options = {
		widgets = {},
	},
}

