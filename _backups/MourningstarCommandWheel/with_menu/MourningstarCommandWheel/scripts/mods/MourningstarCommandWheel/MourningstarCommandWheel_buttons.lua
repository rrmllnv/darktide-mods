local button_definitions = {
	{
		id = "barber",
		view = "barber_vendor_background_view",
		label_key = "loc_body_shop_view_display_name",
		icon = "content/ui/materials/hud/interactions/icons/barber",
	},
	{
		id = "contracts",
		view = "contracts_background_view",
		label_key = "loc_marks_vendor_view_title",
		icon = "content/ui/materials/hud/interactions/icons/contracts",
	},
	{
		id = "crafting",
		view = "crafting_view",
		label_key = "loc_crafting_view",
		icon = "content/ui/materials/hud/interactions/icons/forge",
	},
	{
		id = "credits_vendor",
		view = "credits_vendor_background_view",
		label_key = "loc_vendor_view_title",
		icon = "content/ui/materials/hud/interactions/icons/credits_store",
	},
	{
		id = "mission_board",
		view = "mission_board_view",
		label_key = "loc_mission_board_view",
		icon = "content/ui/materials/hud/interactions/icons/mission_board",
	},
	{
		id = "premium_store",
		view = "store_view",
		label_key = "loc_store_view_display_name",
		icon = "content/ui/materials/icons/system/escape/premium_store",
	},
	{
		id = "training_grounds",
		view = "training_grounds_view",
		label_key = "loc_training_ground_view",
		icon = "content/ui/materials/hud/interactions/icons/training_grounds",
	},
	{
		id = "exit_psychanium",
		view = nil,
		label_key = "loc_tg_exit_training_grounds",
		icon = "content/ui/materials/icons/system/escape/leave_training",
		action = "exit_psychanium",
	},
	{
		id = "social",
		view = "social_menu_view",
		label_key = "loc_social_view_display_name",
		icon = "content/ui/materials/icons/system/escape/social",
	},
	{
		id = "commissary",
		view = "cosmetics_vendor_background_view",
		label_key = "loc_cosmetics_vendor_view_title",
		icon = "content/ui/materials/hud/interactions/icons/cosmetics_store",
	},
	{
		id = "penance",
		view = "penance_overview_view",
		label_key = "loc_achievements_view_display_name",
		icon = "content/ui/materials/icons/system/escape/achievements",
	},
	{
		id = "inventory",
		view = "inventory_background_view",
		label_key = "loc_character_view_display_name",
		icon = "content/ui/materials/icons/system/escape/inventory",
	},
	{
		id = "change_character",
		view = nil,
		label_key = "loc_exit_to_main_menu_display_name",
		icon = "content/ui/materials/icons/system/escape/change_character",
		action = "change_character",
	},
	{
		id = "havoc",
		view = "havoc_background_view",
		label_key = "loc_havoc_name",
		icon = "content/ui/materials/hud/interactions/icons/havoc",
	},
}

local button_definitions_by_id = {}
for i, button in ipairs(button_definitions) do
	button_definitions_by_id[button.id] = button
end

return {
	button_definitions = button_definitions,
	button_definitions_by_id = button_definitions_by_id,
}

