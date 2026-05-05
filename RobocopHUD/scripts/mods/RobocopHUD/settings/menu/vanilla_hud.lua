local mod = get_mod("RobocopHUD")

local Defaults = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/settings/defaults")

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

return {
	setting_id = "robocophud_super_vanilla_hide",
	type = "group",
	title = "vanilla_hud_group",
	sub_widgets = {
		{
			setting_id = "hide_vanilla_stamina",
			type = "checkbox",
			default_value = d("hide_vanilla_stamina", false),
		},
		{
			setting_id = "hide_vanilla_dodge",
			type = "checkbox",
			default_value = d("hide_vanilla_dodge", false),
		},
	},
}

