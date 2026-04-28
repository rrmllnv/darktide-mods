local mod = get_mod("SquadHud")

local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local ELEMENT_CLASS_NAME = "HudElementSquadHud"
local ELEMENT_FILENAME = "SquadHud/scripts/mods/SquadHud/hud/hud_element_squad_hud"

local function remove_existing_squad_hud_element()
	local ui_manager = Managers.ui
	local hud = ui_manager and ui_manager._hud
	local elements = hud and hud._elements
	local element = elements and elements[ELEMENT_CLASS_NAME]

	if not element then
		return
	end

	local elements_array = hud._elements_array

	if elements_array then
		local element_index = table.index_of(elements_array, element)

		if element_index ~= -1 then
			table.remove(elements_array, element_index)
		end
	end

	local visibility_groups = hud._visibility_groups

	if visibility_groups then
		for _, visibility_group in ipairs(visibility_groups) do
			local visible_elements = visibility_group.visible_elements

			if visible_elements then
				visible_elements[ELEMENT_CLASS_NAME] = nil
			end
		end
	end

	if hud._elements_hud_scale_lookup then
		hud._elements_hud_scale_lookup[ELEMENT_CLASS_NAME] = nil
	end

	if hud._elements_hud_retained_mode_lookup then
		hud._elements_hud_retained_mode_lookup[ELEMENT_CLASS_NAME] = nil
	end

	elements[ELEMENT_CLASS_NAME] = nil

	if element.destroy then
		element:destroy(hud._ui_renderer)
	end

	mod:remove_require_path(ELEMENT_FILENAME)
end

UIHudSettings.element_draw_layers[ELEMENT_CLASS_NAME] = 302

remove_existing_squad_hud_element()

mod:register_hud_element({
	filename = ELEMENT_FILENAME,
	class_name = ELEMENT_CLASS_NAME,
	use_hud_scale = true,
	visibility_groups = {
		"alive",
		"dead",
	},
})

return mod
