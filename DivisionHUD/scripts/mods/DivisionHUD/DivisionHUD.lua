local mod = get_mod("DivisionHUD")

mod._division_hud_recolor_stimms_mod = nil

mod.on_all_mods_loaded = function()
	local get_mod_fn = rawget(_G, "get_mod")

	mod._division_hud_recolor_stimms_mod = type(get_mod_fn) == "function" and get_mod_fn("RecolorStimms") or nil
end

local hud_elements = {
	{
		filename = "DivisionHUD/scripts/mods/DivisionHUD/hud/HudElementDivisionHUD",
		class_name = "HudElementDivisionHUD",
		visibility_groups = {
			"alive",
		},
	},
}

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/slot_data")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/core/vanilla_stamina_dodge_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/widgets/vanilla_stamina_dodge")

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	local is_spectator_hud = params and params.renderer_name == "spectator_hud_ui_renderer"

	if not is_spectator_hud then
		for _, hud_element in ipairs(hud_elements) do
			if not table.find_by_key(elements, "class_name", hud_element.class_name) then
				table.insert(elements, {
					class_name = hud_element.class_name,
					filename = hud_element.filename,
					use_hud_scale = true,
					visibility_groups = hud_element.visibility_groups or {
						"alive",
					},
				})
			end
		end
	end

	return func(self, elements, visibility_groups, params)
end)

mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/hud_utils")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/vanilla_hud_suppression")
mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/systems/settings")

