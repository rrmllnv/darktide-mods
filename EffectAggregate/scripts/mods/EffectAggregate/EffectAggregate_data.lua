local mod = get_mod("EffectAggregate")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			-- Настройки мода будут добавлены здесь
		},
	},
}

