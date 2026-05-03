local mod = get_mod("CharacterMenuReorder")

mod.localisation = {
	mod_name = {
		en = "Character Menu Reorder",
		ru = "Сортировка оперативников",
	},
	mod_description = {
		en = "Allows reordering operatives in the character select menu via drag and drop. Order is saved immediately.",
		ru = "Позволяет менять порядок оперативников в меню выбора персонажа перетаскиванием. Порядок сохраняется сразу.",
	},
	general_group = {
		en = "General",
		ru = "Основное",
	},
	enabled = {
		en = "Enable mod",
		ru = "Включить мод",
	},
	enabled_description = {
		en = "When off, character list order is not changed and drag & drop is disabled.",
		ru = "Если выключено — порядок персонажей не меняется и drag & drop отключён.",
	},
}

return mod.localisation

