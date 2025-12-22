local mod = get_mod("MourningstarCommandWheel")

mod.open_inventory_background_view = function(self)
	mod:toggle_view_safe("inventory_background_view")
end

mod.open_change_character = function(self)
	mod:change_character()
end

mod.open_barber_vendor_background_view = function(self)
	mod:toggle_view_safe("barber_vendor_background_view")
end

mod.open_contracts_background_view = function(self)
	mod:toggle_view_safe("contracts_background_view")
end

mod.open_crafting_view = function(self)
	mod:toggle_view_safe("crafting_view")
end

mod.open_credits_vendor_background_view = function(self)
	mod:toggle_view_safe("credits_vendor_background_view")
end

mod.open_mission_board_view = function(self)
	mod:toggle_view_safe("mission_board_view")
end

mod.open_store_view = function(self)
	mod:toggle_view_safe("store_view")
end

mod.open_training_grounds_view = function(self)
	mod:toggle_view_safe("training_grounds_view")
end

mod.open_social_view = function(self)
	mod:toggle_view_safe("social_menu_view")
end

mod.open_commissary_view = function(self)
	mod:toggle_view_safe("cosmetics_vendor_background_view")
end

mod.open_penance_overview_view = function(self)
	mod:toggle_view_safe("penance_overview_view")
end

mod.open_havoc_background_view = function(self)
	mod:toggle_view_safe("havoc_background_view")
end

mod.open_group_finder_view = function(self)
	mod:toggle_view_safe("group_finder_view")
end

