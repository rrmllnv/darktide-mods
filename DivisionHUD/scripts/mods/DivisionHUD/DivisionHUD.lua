local mod = get_mod("DivisionHUD")

local hud_elements = {
	{
		filename = "DivisionHUD/scripts/mods/DivisionHUD/HudElementDivisionHUD",
		class_name = "HudElementDivisionHUD",
		visibility_groups = {
			"alive",
		},
	},
}

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_slot_data")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_vanilla_stamina_dodge_definitions")
mod:add_require_path("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_vanilla_stamina_dodge")

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	-- UIManager.create_spectator_hud задаёт params.renderer_name == "spectator_hud_ui_renderer"
	-- (scripts/managers/ui/ui_manager.lua). Иначе DivisionHUD попадает в spectator HUD: группа
	-- "alive" смотрит на здоровье наблюдаемого игрока, а данные берутся с local_player — HUD
	-- остаётся видимым при смерти и наблюдении за союзниками.
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

local DivisionHUD_settings_defaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD_settings_defaults")

mod.on_setting_changed = function(setting_id)
	if setting_id ~= "divisionhud_reset_all_settings" then
		return
	end

	if mod:get("divisionhud_reset_all_settings") ~= 1 then
		return
	end

	mod:set("divisionhud_reset_all_settings", 0, true)

	if type(DivisionHUD_settings_defaults) ~= "table" then
		return
	end

	for key, value in pairs(DivisionHUD_settings_defaults) do
		mod:set(key, value, true)
	end

	mod:notify(mod:localize("divisionhud_reset_done"))
end

