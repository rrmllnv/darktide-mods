local mod = get_mod("CharacterMenuReorder")

local function _is_enabled()
	return mod:get("enabled") ~= false
end

local function _is_array(t)
	if type(t) ~= "table" then
		return false
	end

	local n = #t

	for k, _ in pairs(t) do
		if type(k) ~= "number" then
			return false
		end
	end

	return n >= 0
end

local function _safe_character_id(profile)
	if type(profile) ~= "table" then
		return nil
	end

	return profile.character_id
end

local function _save_now()
	local dmf = get_mod("DMF")

	if dmf and dmf.save_unsaved_settings_to_file then
		dmf.save_unsaved_settings_to_file()
	end
end

local function _load_character_order()
	local saved = mod:get("character_order")

	if not _is_array(saved) then
		return {}
	end

	local order = {}
	local seen = {}

	for i = 1, #saved do
		local id = saved[i]

		if id ~= nil and not seen[id] then
			seen[id] = true
			order[#order + 1] = id
		end
	end

	return order
end

local function _persist_character_order(order)
	if not _is_array(order) then
		return
	end

	mod:set("character_order", order)
	_save_now()
end

local function _build_order_from_profiles(profiles)
	local order = {}

	for i = 1, #profiles do
		local id = _safe_character_id(profiles[i])

		if id ~= nil then
			order[#order + 1] = id
		end
	end

	return order
end

local function _apply_saved_order_to_profiles(profiles)
	if not _is_array(profiles) or #profiles == 0 then
		return profiles, false
	end

	local saved_order = _load_character_order()

	if #saved_order == 0 then
		return profiles, false
	end

	local position_by_id = {}
	for i = 1, #saved_order do
		position_by_id[saved_order[i]] = i
	end

	local indexed = {}
	for i = 1, #profiles do
		local profile = profiles[i]
		local id = _safe_character_id(profile)
		local pos = id ~= nil and position_by_id[id] or nil

		indexed[i] = {
			profile = profile,
			orig_i = i,
			pos = pos,
		}
	end

	table.sort(indexed, function(a, b)
		local ap = a.pos
		local bp = b.pos

		if ap == nil and bp == nil then
			return a.orig_i < b.orig_i
		elseif ap == nil then
			return false
		elseif bp == nil then
			return true
		elseif ap ~= bp then
			return ap < bp
		end

		return a.orig_i < b.orig_i
	end)

	local sorted_profiles = {}
	for i = 1, #indexed do
		sorted_profiles[i] = indexed[i].profile
	end

	local new_order = _build_order_from_profiles(sorted_profiles)

	local should_persist = false
	if #new_order ~= #saved_order then
		should_persist = true
	else
		for i = 1, #new_order do
			if new_order[i] ~= saved_order[i] then
				should_persist = true
				break
			end
		end
	end

	return sorted_profiles, should_persist and new_order or false
end

local function _find_index_by_character_id(profiles, character_id)
	if character_id == nil then
		return nil
	end

	for i = 1, #profiles do
		local profile = profiles[i]

		if profile and profile.character_id == character_id then
			return i
		end
	end
end

local function _clear_on_pressed(character_widgets)
	for i = 1, #character_widgets do
		local w = character_widgets[i]
		local hotspot = w and w.content and w.content.hotspot

		if hotspot then
			hotspot.on_pressed = false
		end
	end
end

local function _rebuild_profiles_from_widgets(character_widgets)
	local profiles = {}

	for i = 1, #character_widgets do
		local w = character_widgets[i]
		local p = w and w.content and w.content.profile

		profiles[i] = p
	end

	return profiles
end

local function _swap_array_entries(arr, i, j)
	local tmp = arr[i]
	arr[i] = arr[j]
	arr[j] = tmp
end

local function _update_saved_order_from_widgets(character_widgets)
	local order = {}

	for i = 1, #character_widgets do
		local w = character_widgets[i]
		local p = w and w.content and w.content.profile
		local id = _safe_character_id(p)

		if id ~= nil then
			order[#order + 1] = id
		end
	end

	_persist_character_order(order)
end

mod._drag_state = mod._drag_state or {
	active = false,
	dragged_index = nil,
	has_swapped = false,
}

mod:hook("MainMenuView", "_event_profiles_changed", function(func, self, profiles, ...)
	if not _is_enabled() then
		return func(self, profiles, ...)
	end

	local sorted_profiles, persist = _apply_saved_order_to_profiles(profiles)

	if persist and persist ~= false then
		_persist_character_order(persist)
	end

	return func(self, sorted_profiles, ...)
end)

mod:hook("MainMenuView", "_handle_input", function(func, self, input_service, dt, t, ...)
	if not _is_enabled() then
		return func(self, input_service, dt, t, ...)
	end

	if self and (self._profiles_wait_overlay_active or self._server_migration_element or self._is_main_menu_open) then
		return func(self, input_service, dt, t, ...)
	end

	local grid = self and self._character_list_grid
	local widgets = self and self._character_list_widgets

	if not grid or not widgets or not input_service or type(input_service.get) ~= "function" then
		return func(self, input_service, dt, t, ...)
	end

	local drag = mod._drag_state

	local left_pressed = input_service:get("left_pressed") == true
	local left_hold = input_service:get("left_hold") == true
	local left_released = input_service:get("left_released") == true

	local hovered_index = grid:hovered_grid_index()

	if left_pressed and hovered_index and widgets[hovered_index] then
		drag.active = true
		drag.dragged_index = hovered_index
		drag.has_swapped = false
	end

	if drag.active and left_hold and hovered_index and drag.dragged_index and widgets[hovered_index] and widgets[drag.dragged_index] then
		if hovered_index ~= drag.dragged_index then
			local selected_profile = self._selected_profile
			local selected_character_id = selected_profile and selected_profile.character_id

			_swap_array_entries(widgets, hovered_index, drag.dragged_index)

			local profiles = self._character_profiles
			if type(profiles) == "table" and #profiles == #widgets then
				_swap_array_entries(profiles, hovered_index, drag.dragged_index)
			else
				self._character_profiles = _rebuild_profiles_from_widgets(widgets)
				profiles = self._character_profiles
			end

			grid:force_update_list_size()
			grid:clear_scroll_progress()

			_update_saved_order_from_widgets(widgets)

			if selected_character_id ~= nil then
				local new_selected_index = _find_index_by_character_id(profiles, selected_character_id)

				if new_selected_index then
					self._selected_character_list_index = new_selected_index

					if type(grid.select_grid_index) == "function" then
						grid:select_grid_index(new_selected_index, nil, true, false)
					end
				end
			end

			drag.dragged_index = hovered_index
			drag.has_swapped = true
		end
	end

	if left_released and drag.active then
		if drag.has_swapped then
			_clear_on_pressed(widgets)
		end

		drag.active = false
		drag.dragged_index = nil
		drag.has_swapped = false
	end

	return func(self, input_service, dt, t, ...)
end)

