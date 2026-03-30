local mod = get_mod("CommunicationCommandWheel")

local PageInfo = mod:io_dofile("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_pages")
local command_dropdown_options = mod:io_dofile("CommunicationCommandWheel/scripts/mods/CommunicationCommandWheel/CommunicationCommandWheel_setting_dropdown_options")

local NUM_PAGES = PageInfo and PageInfo.MAX_PAGES or 3
local NUM_SLOTS = PageInfo and PageInfo.CONFIGURED_SLOT_COUNT or 8
local DEFAULT_SLOT_LAYOUT = PageInfo and PageInfo.DEFAULT_SLOT_LAYOUT

if type(DEFAULT_SLOT_LAYOUT) ~= "table" then
	DEFAULT_SLOT_LAYOUT = {}
end

if not command_dropdown_options or type(command_dropdown_options) ~= "table" then
	command_dropdown_options = {
		{
			text = "ccw_command_none",
			value = "",
		},
	}
end

local function copy_dropdown_options_template(source)
	local out = {}

	for i = 1, #source do
		local o = source[i]

		out[i] = {
			text = o.text,
			value = o.value,
		}
	end

	return out
end

local hold_delay_options = {
	{
		text = "communication_wheel_hold_0_1s",
		value = 100,
	},
	{
		text = "communication_wheel_hold_0_15s",
		value = 150,
	},
	{
		text = "communication_wheel_hold_0_2s",
		value = 200,
	},
	{
		text = "communication_wheel_hold_0_25s",
		value = 250,
	},
	{
		text = "communication_wheel_hold_0_5s",
		value = 500,
	},
	{
		text = "communication_wheel_hold_0_75s",
		value = 750,
	},
	{
		text = "communication_wheel_hold_1s",
		value = 1000,
	},
}

local function build_slot_widgets(page_index)
	local sub_widgets = {}

	for slot_index = 1, NUM_SLOTS do
		sub_widgets[#sub_widgets + 1] = {
			setting_id = string.format("page_%d_slot_%d", page_index, slot_index),
			type = "dropdown",
			default_value = (DEFAULT_SLOT_LAYOUT[page_index] and DEFAULT_SLOT_LAYOUT[page_index][slot_index]) or "",
			title = "ccw_slot_" .. slot_index,
			options = copy_dropdown_options_template(command_dropdown_options),
		}
	end

	return sub_widgets
end

local page_widget_groups = {}

for page_index = 1, NUM_PAGES do
	page_widget_groups[#page_widget_groups + 1] = {
		setting_id = "ccw_page_group_" .. page_index,
		type = "group",
		title = "ccw_page_" .. page_index,
		sub_widgets = build_slot_widgets(page_index),
	}
end

local widgets = {
	{
		setting_id = "communication_command_wheel_group",
		type = "group",
		title = "communication_command_wheel_group",
		sub_widgets = {
			{
				setting_id = "open_communication_command_wheel_key",
				type = "keybind",
				default_value = {},
				title = "open_communication_command_wheel_key",
				tooltip_text = "open_communication_command_wheel_key_description",
				keybind_trigger = "held",
				keybind_type = "function_call",
				function_name = "communication_command_wheel_held",
			},
			{
				setting_id = "communication_wheel_open_hold_delay_sec",
				type = "dropdown",
				default_value = 100,
				title = "communication_wheel_open_hold_delay_sec",
				tooltip_text = "communication_wheel_open_hold_delay_description",
				options = hold_delay_options,
			},
		},
	},
}

for i = 1, #page_widget_groups do
	widgets[#widgets + 1] = page_widget_groups[i]
end

widgets[#widgets + 1] = {
	setting_id = "ccw_settings_group",
	type = "group",
	title = "ccw_settings_group",
	sub_widgets = {
		{
			setting_id = "reset_slot_commands",
			type = "dropdown",
			default_value = 0,
			options = {
				{
					text = "",
					value = 0,
				},
				{
					text = "reset_slot_commands",
					value = 1,
				},
			},
		},
	},
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets,
	},
}
