local mod = get_mod("DivisionHUD")

local AlertsBossBreeds = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_boss_breeds")
local AlertsSpecialistBreeds = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_specialist_breeds")

local defaults = {
	position_x = 400,
	position_y = 200,
	opacity = 1.0,
	show_stamina_bar = true,
	show_toughness_bar = true,
	show_health_bar = true,
	show_ability_timer = true,
	stimm_slot_icon_tint_by_type = true,
	dynamic_hud = true,
	dynamic_hud_strength = 110,
	dynamic_hud_pitch_ratio = 1,
	dynamic_hud_decay = 11,
	dynamic_hud_max_offset = 100,
	hide_vanilla_team_panel_local = false,
	hide_vanilla_stamina_area = true,
	hide_vanilla_dodge_area = true,
	hide_vanilla_weapon_pivot = false,
	hide_vanilla_combat_ability_slot = false,
	hide_vanilla_player_buffs_background = false,
	integration_custom_hud = false,
	integration_stimm_countdown = true,
	integration_recolor_stimms = false,
	divisionhud_reset_all_settings = 0,
	alerts_enabled = true,
	alerts_max_visible = 3,
	alerts_duration_sec = 6,
	alerts_show_duration_bar = true,
}

if type(AlertsBossBreeds) == "table" and type(AlertsBossBreeds.list) == "table" then
	for i = 1, #AlertsBossBreeds.list do
		local breed_id = AlertsBossBreeds.list[i]

		defaults["alert_boss_" .. breed_id] = true
	end
end

if type(AlertsSpecialistBreeds) == "table" and type(AlertsSpecialistBreeds.list) == "table" then
	for i = 1, #AlertsSpecialistBreeds.list do
		local breed_id = AlertsSpecialistBreeds.list[i]

		defaults["alert_specialist_" .. breed_id] = true
	end
end

return defaults
