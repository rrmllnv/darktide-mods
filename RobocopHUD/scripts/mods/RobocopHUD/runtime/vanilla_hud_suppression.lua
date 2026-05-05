local mod = get_mod("RobocopHUD")

mod.robocophud_vanilla_hud_apply_settings = function(setting_id)
	local relevant = setting_id == "hide_vanilla_stamina" or setting_id == "hide_vanilla_dodge"

	if not relevant then
		return
	end
end

mod:hook("HudElementStamina", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and s.hide_vanilla_stamina == true then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

mod:hook("HudElementDodgeCounter", "draw", function(func, self, dt, t, ui_renderer, render_settings, input_service)
	local s = mod._settings

	if type(s) == "table" and s.hide_vanilla_dodge == true then
		return
	end

	return func(self, dt, t, ui_renderer, render_settings, input_service)
end)

return mod

