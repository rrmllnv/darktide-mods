local mod = get_mod("MourningstarCommandWheel")

local Utils = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_utils")
local is_in_valid_lvl = Utils.is_in_valid_lvl

local can_activate_view = function(ui_manager, view)
	return is_in_valid_lvl() and (not ui_manager:chat_using_input()) and (not ui_manager:has_active_view(view))
end

local close_views = function(view, ui_manager)
	local activeViews = ui_manager:active_views()
	for _, active_view in pairs(activeViews) do
		if active_view == view then
			ui_manager:close_all_views()
			return false
		end
	end
	return true
end

local activate_hub_view = function(view)
	local ui_manager = Managers.ui

	if ui_manager and close_views(view, ui_manager) and can_activate_view(ui_manager, view) then
		local context = {
			hub_interaction = true
		}

		ui_manager:open_view(view, nil, nil, nil, nil, context)
	end
end

mod.activate_barber_vendor_background_view = function(self)
	activate_hub_view("barber_vendor_background_view")
end

mod.activate_contracts_background_view = function(self)
	activate_hub_view("contracts_background_view")
end

mod.activate_crafting_view = function(self)
	activate_hub_view("crafting_view")
end

mod.activate_credits_vendor_background_view = function(self)
	activate_hub_view("credits_vendor_background_view")
end

mod.activate_mission_board_view = function(self)
	activate_hub_view("mission_board_view")
end

mod.activate_store_view = function(self)
	activate_hub_view("store_view")
end

mod.activate_training_grounds_view = function(self)
	activate_hub_view("training_grounds_view")
end

mod.activate_social_view = function(self)
	activate_hub_view("social_menu_view")
end

mod.activate_commissary_view = function(self)
	activate_hub_view("cosmetics_vendor_background_view")
end

mod.activate_penance_overview_view = function(self)
	activate_hub_view("penance_overview_view")
end

mod.activate_havoc_background_view = function(self)
	activate_hub_view("havoc_background_view")
end

