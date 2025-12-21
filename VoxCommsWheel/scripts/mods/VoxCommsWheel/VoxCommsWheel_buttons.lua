local VOQueryConstants = require("scripts/settings/dialogue/vo_query_constants")
local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
local ChannelTags = ChatManagerConstants.ChannelTag

local button_definitions = {
	-- Страница 1
	{
		id = "yes",
		label_key = "loc_command_yes",
		icon = "content/ui/materials/icons/list_buttons/check",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_yes,
		},
		chat_message_data = {
			text = "loc_command_yes",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "no",
		label_key = "loc_command_no",
		icon = "content/ui/materials/icons/list_buttons/cross",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_no,
		},
		chat_message_data = {
			text = "loc_command_no",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "please",
		label_key = "loc_command_please",
		icon = "content/ui/materials/hud/communication_wheel/icons/thanks",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_my_pleasure,
		},
		chat_message_data = {
			text = "loc_command_please",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "sorry",
		label_key = "loc_command_sorry",
		icon = "content/ui/materials/icons/list_buttons/cross",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_sorry",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "need_help",
		label_key = "loc_command_need_help",
		icon = "content/ui/materials/hud/interactions/icons/help",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.generic_mission_vo,
			voice_tag_id = "calling_for_help",
		},
		chat_message_data = {
			text = "loc_command_need_help",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "take_this",
		label_key = "loc_command_take_this",
		icon = "content/ui/materials/hud/communication_wheel/icons/take_this",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_take_this,
		},
		chat_message_data = {
			text = "loc_command_take_this",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "i_need_this",
		label_key = "loc_command_i_need_this",
		icon = "content/ui/materials/hud/communication_wheel/icons/need_that",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_that,
		},
		chat_message_data = {
			text = "loc_command_i_need_this",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "daemonhost",
		label_key = "loc_command_daemonhost",
		icon = "content/ui/materials/hud/communication_wheel/icons/enemy",
		-- Нет прямой голосовой реплики для демонхоста в com_wheel
		-- Можно использовать on_demand_vo_tag_enemy с enemy_tag = "chaos_daemonhost"
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_vo_tag_enemy,
			voice_tag_id = "chaos_daemonhost",
		},
		chat_message_data = {
			text = "loc_command_daemonhost",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "almost_there",
		label_key = "loc_command_almost_there",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.generic_mission_vo,
			voice_tag_id = "almost_there",
		},
		chat_message_data = {
			text = "loc_command_almost_there",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "away_from_squad",
		label_key = "loc_command_away_from_squad",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.generic_mission_vo,
			voice_tag_id = "away_from_squad",
		},
		chat_message_data = {
			text = "loc_command_away_from_squad",
			channel = ChannelTags.MISSION,
		},
	},
	-- Страница 2
	{
		id = "follow_you",
		label_key = "loc_command_follow_you",
		icon = "content/ui/materials/hud/communication_wheel/icons/follow",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_follow_you,
		},
		chat_message_data = {
			text = "loc_command_follow_you",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "follow_me",
		label_key = "loc_command_follow_me",
		icon = "content/ui/materials/hud/communication_wheel/icons/follow",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_follow_me",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "cover_me",
		label_key = "loc_command_cover_me",
		icon = "content/ui/materials/hud/communication_wheel/icons/attention",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_cover_me",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "coming_to_you",
		label_key = "loc_command_coming_to_you",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_coming_to_you",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "waiting_for_you",
		label_key = "loc_command_waiting_for_you",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_waiting_for_you",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "dont_fall_behind",
		label_key = "loc_command_dont_fall_behind",
		icon = "content/ui/materials/hud/communication_wheel/icons/follow",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_dont_fall_behind",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "faster",
		label_key = "loc_command_faster",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_faster",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "wait",
		label_key = "loc_command_wait",
		icon = "content/ui/materials/hud/communication_wheel/icons/attention",
		-- Используем com_wheel_vo_over_here как аналог wait
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_over_here,
		},
		chat_message_data = {
			text = "loc_command_wait",
			channel = ChannelTags.MISSION,
		},
	},
	{
		id = "back",
		label_key = "loc_command_back",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		-- Нет голосовой реплики
		chat_message_data = {
			text = "loc_command_back",
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

