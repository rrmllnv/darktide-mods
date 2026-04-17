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
	ammo_text_color_by_fraction = true,
	grenade_color_by_fraction = true,
	stimm_slot_icon_tint_by_type = true,
	wielded_weapon_icon_state_colors = true,
	dynamic_hud = true,
	dynamic_hud_strength = 110,
	dynamic_hud_pitch_ratio = 1,
	dynamic_hud_decay = 11,
	dynamic_hud_max_offset = 100,
	dynamic_hud_freeze_on_ads = true,
	hide_vanilla_team_panel_local = false,
	hide_vanilla_stamina_area = true,
	hide_vanilla_dodge_area = true,
	hide_vanilla_weapon_pivot = false,
	hide_vanilla_combat_ability_slot = false,
	hide_vanilla_player_buffs_background = true,
	hide_vanilla_mission_objectives = true,
	alert_mission_objective_start = true,
	alert_mission_objective_progress = true,
	alert_mission_objective_complete = true,
	alert_mission_objective_custom_popup = true,
	proximity_enabled = true,
	proximity_radius = 15,
	proximity_show_medical_station = true,
	proximity_show_medical = true,
	proximity_show_medical_deployed = true,
	proximity_show_stimm = true,
	proximity_show_ammo_small = true,
	proximity_show_ammo_large = true,
	proximity_show_ammo_crate = true,
	proximity_show_grenade = true,
	proximity_show_grimoire = true,
	proximity_show_tome     = true,
	buff_rows_enabled = true,
	integration_custom_hud = false,
	integration_stimm_countdown = true,
	integration_recolor_stimms = false,
	divisionhud_reset_all_settings = 0,
	alerts_enabled = true,
	debug = false,
	alerts_max_visible = 2,
	alerts_duration_sec = 6,
	alerts_show_duration_bar = true,
	alerts_team_knock = true,
	alerts_team_net = true,
	alerts_team_hound = true,
	alerts_team_ledge = true,
	alerts_team_consumed = true,
	alerts_team_death = true,
}

if type(AlertsBossBreeds) == "table" and type(AlertsBossBreeds.list) == "table" then
	for i = 1, #AlertsBossBreeds.list do
		local breed_id = AlertsBossBreeds.list[i]

		defaults["alert_boss_" .. breed_id] = true
	end
end

if type(AlertsSpecialistBreeds) == "table" and type(AlertsSpecialistBreeds.settings_rows) == "table" then
	for i = 1, #AlertsSpecialistBreeds.settings_rows do
		local row = AlertsSpecialistBreeds.settings_rows[i]

		if type(row) == "table" and row.kind == "single" and type(row.breed_id) == "string" and row.breed_id ~= "" then
			defaults["alert_specialist_" .. row.breed_id] = true
		elseif type(row) == "table" and row.kind == "merged" and type(row.group) == "table" and type(row.group.setting_id) == "string" and row.group.setting_id ~= "" then
			defaults[row.group.setting_id] = true
		end
	end
end

return defaults
