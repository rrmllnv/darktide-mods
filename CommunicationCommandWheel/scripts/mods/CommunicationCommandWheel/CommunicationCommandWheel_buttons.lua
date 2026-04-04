local VOQueryConstants = require("scripts/settings/dialogue/vo_query_constants")
local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
local ChannelTags = ChatManagerConstants.ChannelTag

local button_definitions = {
	{
		id = "yes",
		label_key = "ccw_command_yes",
		icon = "content/ui/materials/icons/list_buttons/check",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_yes,
		},
		chat_message_data = {
			text = "ccw_command_yes",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "please",
		label_key = "ccw_command_please",
		icon = "content/ui/materials/hud/icons/speaker",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_my_pleasure,
		},
		chat_message_data = {
			text = "ccw_command_please",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "sorry",
		label_key = "ccw_command_sorry",
		icon = "content/ui/materials/hud/icons/party_cohesion",
		chat_message_data = {
			text = "ccw_command_sorry",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "need_help",
		label_key = "ccw_command_need_help",
		icon = "content/ui/materials/hud/interactions/icons/help",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.generic_mission_vo,
			voice_tag_id = "calling_for_help",
		},
		chat_message_data = {
			text = "ccw_command_need_help",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "no",
		label_key = "ccw_command_no",
		icon = "content/ui/materials/icons/list_buttons/cross",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_no,
		},
		chat_message_data = {
			text = "ccw_command_no",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "take_this",
		label_key = "ccw_command_take_this",
		icon = "content/ui/materials/hud/interactions/icons/pocketable_default",
		smart_tag_type = "location_attention",
		prefer_contextual_unit_tag = true,
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_take_this,
		},
		chat_message_data = {
			text = "ccw_command_take_this",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "i_need_this",
		label_key = "ccw_command_i_need_this",
		icon = "content/ui/materials/hud/icons/party_ammo",
		smart_tag_type = "location_attention",
		prefer_contextual_unit_tag = true,
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_that,
		},
		chat_message_data = {
			text = "ccw_command_i_need_this",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "daemonhost",
		label_key = "ccw_command_daemonhost",
		icon = "content/ui/materials/hud/interactions/icons/enemy",
		smart_tag_type = "location_threat",
		prefer_contextual_unit_tag = true,
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_vo_tag_enemy,
			voice_tag_id = "chaos_daemonhost",
		},
		chat_message_data = {
			text = "ccw_command_daemonhost",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "enemy_ahead",
		label_key = "ccw_command_enemy_ahead",
		icon = "content/ui/materials/hud/communication_wheel/icons/enemy",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_enemy_over_here,
		},
		chat_message_data = {
			text = "ccw_command_enemy_ahead",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "dont_shoot_poxbuster",
		label_key = "ccw_command_dont_shoot_poxbuster",
		icon = "content/ui/materials/hud/interactions/icons/enemy",
		chat_message_data = {
			text = "ccw_command_dont_shoot_poxbuster",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "follow_you",
		label_key = "ccw_command_follow_you",
		icon = "content/ui/materials/hud/interactions/icons/location",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_follow_you,
		},
		chat_message_data = {
			text = "ccw_command_follow_you",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "follow_me",
		label_key = "ccw_command_follow_me",
		icon = "content/ui/materials/hud/interactions/icons/location",
		chat_message_data = {
			text = "ccw_command_follow_me",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "cover_me",
		label_key = "ccw_command_cover_me",
		icon = "content/ui/materials/hud/interactions/icons/attention",
		chat_message_data = {
			text = "ccw_command_cover_me",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "coming_to_you",
		label_key = "ccw_command_coming_to_you",
		icon = "content/ui/materials/hud/interactions/icons/location",
		chat_message_data = {
			text = "ccw_command_coming_to_you",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "waiting_for_you",
		label_key = "ccw_command_waiting_for_you",
		icon = "content/ui/materials/hud/interactions/icons/location",
		chat_message_data = {
			text = "ccw_command_waiting_for_you",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "dont_fall_behind",
		label_key = "ccw_command_dont_fall_behind",
		icon = "content/ui/materials/hud/interactions/icons/location",
		chat_message_data = {
			text = "ccw_command_dont_fall_behind",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "faster",
		label_key = "ccw_command_faster",
		icon = "content/ui/materials/hud/interactions/icons/location",
		chat_message_data = {
			text = "ccw_command_faster",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "wait",
		label_key = "ccw_command_wait",
		icon = "content/ui/materials/hud/interactions/icons/attention",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_over_here,
		},
		chat_message_data = {
			text = "ccw_command_wait",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "hold_position",
		label_key = "ccw_command_hold_position",
		icon = "content/ui/materials/hud/interactions/icons/attention",
		smart_tag_type = "location_ping",
		chat_message_data = {
			text = "ccw_command_hold_position",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "hold_exit",
		label_key = "ccw_command_hold_exit",
		icon = "content/ui/materials/hud/interactions/icons/attention",
		chat_message_data = {
			text = "ccw_command_hold_exit",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "dont_split_up",
		label_key = "ccw_command_dont_split_up",
		icon = "content/ui/materials/hud/icons/party_cohesion",
		chat_message_data = {
			text = "ccw_command_dont_split_up",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "almost_there",
		label_key = "ccw_command_almost_there",
		icon = "content/ui/materials/hud/interactions/icons/location",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.generic_mission_vo,
			voice_tag_id = "almost_there",
		},
		chat_message_data = {
			text = "ccw_command_almost_there",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "away_from_squad",
		label_key = "ccw_command_away_from_squad",
		icon = "content/ui/materials/hud/interactions/icons/location",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.generic_mission_vo,
			voice_tag_id = "away_from_squad",
		},
		chat_message_data = {
			text = "ccw_command_away_from_squad",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "back",
		label_key = "ccw_command_back",
		icon = "content/ui/materials/hud/interactions/icons/location",
		chat_message_data = {
			text = "ccw_command_back",
			channel = ChannelTags.MISSION,
		},
	},
}

local button_definitions_by_id = {}

for i, button in ipairs(button_definitions) do
	button_definitions_by_id[button.id] = button
end

return {
	button_definitions = button_definitions,
	button_definitions_by_id = button_definitions_by_id,
}
