local mod = get_mod("DivisionHUD")

local Defaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/defaults")
local AlertsBreedTitle = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_breed_title")
local AlertsBossBreeds = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_boss_breeds")
local AlertsSpecialistBreeds = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_specialist_breeds")

if type(Defaults) ~= "table" then
	Defaults = {}
end

local function d(key, fallback)
	local v = Defaults[key]

	if v ~= nil then
		return v
	end

	return fallback
end

local function alert_settings_breed_title(breed_id)
	if type(AlertsBreedTitle) == "table" and type(AlertsBreedTitle.resolve) == "function" then
		return AlertsBreedTitle.resolve(mod, breed_id)
	end

	return type(breed_id) == "string" and breed_id or ""
end

return {
	setting_id = "alerts_super",
	type = "group",
	title = "alerts_super",
	sub_widgets = {
		{
			setting_id = "alerts_enabled",
			type = "checkbox",
			title = "alerts_enabled",
			default_value = d("alerts_enabled", true),
		},
		{
			setting_id = "alerts_max_visible",
			type = "numeric",
			title = "alerts_max_visible",
			default_value = d("alerts_max_visible", 2),
			range = { 1, 5 },
			decimals_number = 0,
		},
		{
			setting_id = "alerts_duration_sec",
			type = "numeric",
			title = "alerts_duration_sec",
			default_value = d("alerts_duration_sec", 6),
			range = { 1, 60 },
			decimals_number = 1,
		},
		{
			setting_id = "alerts_show_duration_bar",
			type = "checkbox",
			title = "alerts_show_duration_bar",
			default_value = d("alerts_show_duration_bar", true),
		},
		(function()
			local boss_sub = {
				setting_id = "alerts_group_bosses",
				type = "group",
				title = "alerts_group_bosses",
				sub_widgets = {},
			}

			if type(AlertsBossBreeds) == "table" and type(AlertsBossBreeds.list) == "table" then
				for i = 1, #AlertsBossBreeds.list do
					local breed_id = AlertsBossBreeds.list[i]

					boss_sub.sub_widgets[#boss_sub.sub_widgets + 1] = {
						setting_id = "alert_boss_" .. breed_id,
						type = "checkbox",
						localize = false,
						title = alert_settings_breed_title(breed_id),
						default_value = d("alert_boss_" .. breed_id, true),
					}
				end
			end

			return boss_sub
		end)(),
		(function()
			local specialist_sub = {
				setting_id = "alerts_group_specialists",
				type = "group",
				title = "alerts_group_specialists",
				sub_widgets = {},
			}

			if type(AlertsSpecialistBreeds) == "table" and type(AlertsSpecialistBreeds.settings_rows) == "table" then
				for ri = 1, #AlertsSpecialistBreeds.settings_rows do
					local row = AlertsSpecialistBreeds.settings_rows[ri]

					if type(row) == "table" and row.kind == "single" and type(row.breed_id) == "string" and row.breed_id ~= "" then
						local breed_id = row.breed_id

						specialist_sub.sub_widgets[#specialist_sub.sub_widgets + 1] = {
							setting_id = "alert_specialist_" .. breed_id,
							type = "checkbox",
							localize = false,
							title = alert_settings_breed_title(breed_id),
							default_value = d("alert_specialist_" .. breed_id, true),
						}
					elseif type(row) == "table" and row.kind == "merged" and type(row.group) == "table" then
						local g = row.group

						if type(g.setting_id) == "string" and g.setting_id ~= "" and type(g.title_breed_id) == "string" and g.title_breed_id ~= "" then
							specialist_sub.sub_widgets[#specialist_sub.sub_widgets + 1] = {
								setting_id = g.setting_id,
								type = "checkbox",
								localize = false,
								title = alert_settings_breed_title(g.title_breed_id),
								default_value = d(g.setting_id, true),
							}
						end
					end
				end
			end

			return specialist_sub
		end)(),
		{
			setting_id = "mission_objectives_super",
			type = "group",
			title = "mission_objectives_super",
			tooltip_text = "mission_objectives_super_description",
			sub_widgets = {
				{
					setting_id = "alert_mission_objective_start",
					type = "checkbox",
					title = "alert_mission_objective_start",
					tooltip_text = "alert_mission_objective_start_description",
					default_value = d("alert_mission_objective_start", true),
				},
				{
					setting_id = "alert_mission_objective_progress",
					type = "checkbox",
					title = "alert_mission_objective_progress",
					tooltip_text = "alert_mission_objective_progress_description",
					default_value = d("alert_mission_objective_progress", true),
				},
				{
					setting_id = "alert_mission_objective_complete",
					type = "checkbox",
					title = "alert_mission_objective_complete",
					tooltip_text = "alert_mission_objective_complete_description",
					default_value = d("alert_mission_objective_complete", true),
				},
				{
					setting_id = "alert_mission_objective_custom_popup",
					type = "checkbox",
					title = "alert_mission_objective_custom_popup",
					tooltip_text = "alert_mission_objective_custom_popup_description",
					default_value = d("alert_mission_objective_custom_popup", true),
				},
			},
		},
		{
			setting_id = "alerts_group_team",
			type = "group",
			title = "alerts_group_team",
			tooltip_text = "alerts_group_team_description",
			sub_widgets = {
				{
					setting_id = "alerts_team_knock",
					type = "checkbox",
					title = "alerts_team_knock",
					tooltip_text = "alerts_team_knock_description",
					default_value = d("alerts_team_knock", true),
				},
				{
					setting_id = "alerts_team_net",
					type = "checkbox",
					title = "alerts_team_net",
					tooltip_text = "alerts_team_net_description",
					default_value = d("alerts_team_net", true),
				},
				{
					setting_id = "alerts_team_hound",
					type = "checkbox",
					title = "alerts_team_hound",
					tooltip_text = "alerts_team_hound_description",
					default_value = d("alerts_team_hound", true),
				},
				{
					setting_id = "alerts_team_ledge",
					type = "checkbox",
					title = "alerts_team_ledge",
					tooltip_text = "alerts_team_ledge_description",
					default_value = d("alerts_team_ledge", true),
				},
				{
					setting_id = "alerts_team_consumed",
					type = "checkbox",
					title = "alerts_team_consumed",
					tooltip_text = "alerts_team_consumed_description",
					default_value = d("alerts_team_consumed", true),
				},
				{
					setting_id = "alerts_team_death",
					type = "checkbox",
					title = "alerts_team_death",
					tooltip_text = "alerts_team_death_description",
					default_value = d("alerts_team_death", true),
				},
			},
		},
	},
}
