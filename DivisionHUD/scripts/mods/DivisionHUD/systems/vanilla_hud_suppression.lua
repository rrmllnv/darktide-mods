local mod = get_mod("DivisionHUD")

-- Как Custom HUD: при скрытии не трогаем content.visible, а не вызываем отрисовку
-- (mods/custom_hud/hud_element_customizer.lua — hook на draw, return если скрыто).
-- Иначе остаются артефакты: _draw_stamina_chunks, _draw_dodge_bars, сегменты здоровья,
-- отдельные draw у дочерних weapon/ability.

local HudElementPlayerAbilityHandler = require("scripts/ui/hud/elements/player_ability_handler/hud_element_player_ability_handler")

local function divisionhud_panel_is_team_handler_local_player(panel)
	local d = panel._data

	return d ~= nil and d.scenegraph_id == "local_player"
end

mod:hook("HudElementStamina", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and s.hide_vanilla_stamina_area == true then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

mod:hook("HudElementDodgeCounter", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and s.hide_vanilla_dodge_area == true then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

local function divisionhud_hook_local_player_panel_draw(class_name)
	mod:hook(class_name, "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
		local s = mod._settings

		if type(s) == "table" and s.hide_vanilla_team_panel_local == true and divisionhud_panel_is_team_handler_local_player(self) then
			return
		end

		return func(self, dt, t, ui_renderer, render_settings, input_service)
	end)
end

divisionhud_hook_local_player_panel_draw("HudElementPersonalPlayerPanel")
divisionhud_hook_local_player_panel_draw("HudElementPersonalPlayerPanelHub")

-- HudElementPlayerWeaponHandler|weapon_pivot — весь блок оружия на HUD (исходник: draw обходит _player_weapons).
mod:hook("HudElementPlayerWeaponHandler", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and s.hide_vanilla_weapon_pivot == true then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

-- HudElementPlayerAbilityHandler|slot_combat_ability — только один слот; исходник draw: super + цикл instance:draw.
mod:hook("HudElementPlayerAbilityHandler", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) ~= "table" or s.hide_vanilla_combat_ability_slot ~= true then
		return func(self, dt, t, ui_renderer, render_settings, input_service)
	end

	HudElementPlayerAbilityHandler.super.draw(self, dt, t, ui_renderer, render_settings, input_service)

	local instance_data_tables = self._instance_data_tables

	for _, data in pairs(instance_data_tables) do
		if data.scenegraph_id ~= "slot_combat_ability" then
			local instance = data.instance

			instance:draw(dt, t, ui_renderer, render_settings, input_service)
		end
	end
end)

-- HudElementPlayerBuffs|background: в definitions все иконки баффов — scenegraph "buff", parent "background".
mod:hook("HudElementPlayerBuffs", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and s.hide_vanilla_player_buffs_background == true then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

return mod
