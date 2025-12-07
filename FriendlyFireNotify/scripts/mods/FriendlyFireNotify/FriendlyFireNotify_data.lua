local mod = get_mod("FriendlyFireNotify")

local color_options = {}

for i, color_name in ipairs(Color.list) do
	table.insert(
		color_options,
		{
			text = color_name,
			value = color_name
		}
	)
end

table.sort(color_options, function(a, b) return a.text < b.text end)

local function get_color_options()
	return table.clone(color_options)
end

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "min_damage_threshold",
				type = "numeric",
				default_value = 1,
				range = {1, 100},
			},
			{
				setting_id = "show_total_damage",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "notification_coalesce_time",
				type = "numeric",
				default_value  = 3,
				range = {1, 10},
			},
			{
				setting_id = "notification_background_color",
				type = "dropdown",
				default_value = "terminal_corner_selected",
				options = get_color_options(),
			},
		},
	},
}

