local mod = get_mod("DivisionHUD")

local Defaults = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/settings/defaults")
local AlertsBreedTitle = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_breed_title")
local Localization = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/localization")
local language_id = Application.user_setting("language_id")

if type(Defaults) ~= "table" then
	Defaults = {}
end

if type(Localization) ~= "table" then
	Localization = {}
end

local function d(key, fallback)
	local v = Defaults[key]

	if v ~= nil then
		return v
	end

	return fallback
end

local function breed_title(breed_id)
	if type(AlertsBreedTitle) == "table" and type(AlertsBreedTitle.resolve) == "function" then
		local t = AlertsBreedTitle.resolve(mod, breed_id)

		if type(t) == "string" and t ~= "" then
			return t
		end
	end

	return breed_id
end

local function tooltip(key)
	local entry = Localization[key]

	if type(entry) == "table" then
		local text = entry[language_id] or entry.en

		if type(text) == "string" and text ~= "" then
			return text
		end
	end

	return key
end

return {
	setting_id = "divisionhud_super_danger_zone",
	type = "group",
	title = "divisionhud_super_danger_zone",
	sub_widgets = {
		{
			setting_id = "danger_zone_enabled",
			type = "checkbox",
			title = "danger_zone_enabled",
			tooltip = "danger_zone_enabled_description",
			default_value = d("danger_zone_enabled", true),
		},
		{
			setting_id = "danger_zone_radius",
			type = "numeric",
			title = "danger_zone_radius",
			tooltip = "danger_zone_radius_description",
			default_value = d("danger_zone_radius", 5),
			range = { 1, 30 },
			decimals_number = 0,
		},
		{
			setting_id = "danger_zone_los_check",
			type = "checkbox",
			title = "danger_zone_los_check",
			tooltip = "danger_zone_los_check_description",
			default_value = d("danger_zone_los_check", true),
		},
		{
			setting_id = "danger_zone_show_daemonhost",
			type = "checkbox",
			localize = false,
			title = breed_title("chaos_daemonhost"),
			tooltip = tooltip("danger_zone_show_daemonhost_description"),
			default_value = d("danger_zone_show_daemonhost", true),
		},
		{
			setting_id = "danger_zone_show_daemonhost_aura",
			type = "checkbox",
			title = "danger_zone_show_daemonhost_aura",
			tooltip = "danger_zone_show_daemonhost_aura_description",
			default_value = d("danger_zone_show_daemonhost_aura", true),
		},
		{
			setting_id = "danger_zone_show_poxburster",
			type = "checkbox",
			localize = false,
			title = breed_title("chaos_poxwalker_bomber"),
			tooltip = tooltip("danger_zone_show_poxburster_description"),
			default_value = d("danger_zone_show_poxburster", true),
		},
		{
			setting_id = "danger_zone_show_tox_flamer",
			type = "checkbox",
			localize = false,
			title = breed_title("cultist_flamer"),
			tooltip = tooltip("danger_zone_show_tox_flamer_description"),
			default_value = d("danger_zone_show_tox_flamer", true),
		},
		{
			setting_id = "danger_zone_show_scab_flamer",
			type = "checkbox",
			localize = false,
			title = breed_title("renegade_flamer"),
			tooltip = tooltip("danger_zone_show_scab_flamer_description"),
			default_value = d("danger_zone_show_scab_flamer", true),
		},
		{
			setting_id = "danger_zone_show_bomber_grenade",
			type = "checkbox",
			title = "danger_zone_show_bomber_grenade",
			tooltip = "danger_zone_show_bomber_grenade_description",
			default_value = d("danger_zone_show_bomber_grenade", true),
		},
		{
			setting_id = "danger_zone_show_explosive_barrel",
			type = "checkbox",
			title = "danger_zone_show_explosive_barrel",
			tooltip = "danger_zone_show_explosive_barrel_description",
			default_value = d("danger_zone_show_explosive_barrel", true),
		},
		{
			setting_id = "danger_zone_show_fire_barrel",
			type = "checkbox",
			title = "danger_zone_show_fire_barrel",
			tooltip = "danger_zone_show_fire_barrel_description",
			default_value = d("danger_zone_show_fire_barrel", true),
		},
	},
}
