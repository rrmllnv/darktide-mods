local mod = get_mod("CharacterMenuReorder")

mod.localisation = {
	mod_name = {
		en = "Character Menu Reorder",
		ru = "Сортировка оперативников",
		de = "Charaktermenü-Reihenfolge",
		fr = "Réorganisation du menu des personnages",
		["zh-cn"] = "角色菜单排序",
	},
	mod_description = {
		en = "Allows reordering operatives in the character select menu via drag and drop. Order is saved immediately.",
		ru = "Позволяет менять порядок оперативников в меню выбора персонажа перетаскиванием. Порядок сохраняется сразу.",
		de = "Ermöglicht das Neuordnen von Operativen im Charakterauswahlmenü per Drag & Drop. Die Reihenfolge wird sofort gespeichert.",
		fr = "Permet de réorganiser les opérateurs dans le menu de sélection de personnage par glisser-déposer. L'ordre est sauvegardé immédiatement.",
		["zh-cn"] = "可在角色选择菜单中通过拖拽调整角色顺序，并立即保存。",
	},
	general_group = {
		en = "General",
		ru = "Основное",
		de = "Allgemein",
		fr = "Général",
		["zh-cn"] = "常规",
	},
	enabled = {
		en = "Enable mod",
		ru = "Включить мод",
		de = "Mod aktivieren",
		fr = "Activer le mod",
		["zh-cn"] = "启用模组",
	},
	enabled_description = {
		en = "When off, character list order is not changed and drag & drop is disabled.",
		ru = "Если выключено — порядок персонажей не меняется и drag & drop отключён.",
		de = "Wenn deaktiviert, wird die Reihenfolge nicht verändert und Drag & Drop ist deaktiviert.",
		fr = "Lorsque cette option est désactivée, l'ordre n'est pas modifié et le glisser-déposer est désactivé.",
		["zh-cn"] = "关闭后，不会更改列表顺序，并禁用拖拽排序。",
	},
}

return mod.localisation

