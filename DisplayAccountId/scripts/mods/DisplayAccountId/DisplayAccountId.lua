local mod = get_mod("DisplayAccountId")

local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

local ACCOUNT_ID_CALLBACK_NAME = "__displayaccountid_cb_copy_account_id"

local function account_id_from_player_info(player_info)
	if player_info and type(player_info.account_id) == "function" then
		local account_id = player_info:account_id()

		if account_id then
			return tostring(account_id)
		end
	end

	return mod:localize("display_account_id_unknown")
end

local function account_id_label(player_info)
	return string.format("%s: %s", mod:localize("display_account_id_label"), account_id_from_player_info(player_info))
end

local function copy_to_clipboard(value)
	local clipboard = rawget(_G, "Clipboard")
	local clipboard_put = clipboard and clipboard.put

	if type(clipboard_put) ~= "function" then
		return false
	end

	local ok, copied = pcall(clipboard_put, value)

	return ok and copied == true
end

mod:hook_safe("SocialMenuRosterView", "init", function(self, settings, context)
	self[ACCOUNT_ID_CALLBACK_NAME] = function(self, player_info)
		local account_id = account_id_from_player_info(player_info)

		if copy_to_clipboard(account_id) then
			mod:notify(mod:localize("display_account_id_copied", account_id))
		else
			mod:notify(account_id_label(player_info))
		end
	end
end)

mod:hook_require("scripts/ui/view_elements/view_element_player_social_popup/view_element_player_social_popup_content_list", function(instance)
	mod:hook(instance, "from_player_info", function(func, parent, player_info)
		local menu_items, num_menu_items = func(parent, player_info)
		local entry = {
			label = account_id_label(player_info),
			on_pressed_sound = UISoundEvents.default_click,
			callback = callback(parent, ACCOUNT_ID_CALLBACK_NAME, player_info),
			blueprint = "button",
		}

		if (not num_menu_items) or menu_items[1].blueprint ~= "group_divider" then
			table.insert(menu_items, 1, {
				label = "divider_display_account_id",
				blueprint = "group_divider",
			})
			num_menu_items = num_menu_items + 1
		end

		table.insert(menu_items, 1, entry)
		num_menu_items = num_menu_items + 1

		return menu_items, num_menu_items
	end)
end)
