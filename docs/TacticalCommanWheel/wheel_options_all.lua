-- Полный список всех доступных голосовых реплик из исходного кода Darktide
-- Собрано из: scripts/settings/dialogue/vo_query_constants.lua

local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
local VOQueryConstants = require("scripts/settings/dialogue/vo_query_constants")

local ChannelTags = ChatManagerConstants.ChannelTag

-- Все доступные опции из vo_query_constants.lua
local WHEEL_OPTION = table.enum(
	"ammo",              -- Нужны патроны
	"attention",         -- Внимание (сюда)
	"emperor",           -- За Императора!
	"enemy",             -- Враг здесь
	"follow_you",        -- Следую за тобой
	"health",            -- Нужно здоровье
	"help",              -- Нужна помощь (кастомная)
	"location",          -- Местоположение
	"my_pleasure",       -- Пожалуйста (ответ на спасибо)
	"need_that",         -- Мне это нужно (dibs)
	"no",                -- Нет
	"thanks",            -- Спасибо
	"take_this",         -- Возьми это
	"yes"                -- Да
)

local wheel_options = {
	-- Стандартные опции из игры
	[WHEEL_OPTION.ammo] = {
		display_name = "loc_communication_wheel_display_name_need_ammo",
		icon = "content/ui/materials/hud/communication_wheel/icons/ammo",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_ammo,
		},
		chat_message_data = {
			text = "loc_communication_wheel_need_ammo",
			channel = ChannelTags.MISSION,
		},
	},
	
	[WHEEL_OPTION.attention] = {
		display_name = "loc_communication_wheel_display_name_attention",
		icon = "content/ui/materials/hud/communication_wheel/icons/attention",
		tag_type = "location_attention",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_over_here,
		},
	},
	
	[WHEEL_OPTION.emperor] = {
		display_name = "loc_communication_wheel_display_name_cheer", -- или "loc_for_the_emperor" если добавлена локализация
		icon = "content/ui/materials/hud/communication_wheel/icons/for_the_emperor",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_for_the_emperor,
		},
	},
	
	[WHEEL_OPTION.enemy] = {
		display_name = "loc_communication_wheel_display_name_enemy",
		icon = "content/ui/materials/hud/communication_wheel/icons/enemy",
		tag_type = "location_threat",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_enemy_over_here,
		},
	},
	
	[WHEEL_OPTION.health] = {
		display_name = "loc_communication_wheel_display_name_need_health",
		icon = "content/ui/materials/hud/communication_wheel/icons/health",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_health,
		},
		chat_message_data = {
			text = "loc_communication_wheel_need_health",
			channel = ChannelTags.MISSION,
		},
	},
	
	[WHEEL_OPTION.location] = {
		display_name = "loc_communication_wheel_display_name_location",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		tag_type = "location_ping",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_lets_go_this_way,
		},
	},
	
	[WHEEL_OPTION.thanks] = {
		display_name = "loc_communication_wheel_display_name_thanks",
		icon = "content/ui/materials/hud/communication_wheel/icons/thanks",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_thank_you,
		},
		chat_message_data = {
			text = "loc_communication_wheel_thanks",
			channel = ChannelTags.MISSION,
		},
	},
	
	-- Дополнительные опции из ForTheEmperor
	[WHEEL_OPTION.help] = {
		display_name = "loc_communication_wheel_need_help",
		icon = "content/ui/materials/hud/interactions/icons/help",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "", -- Кастомная логика в need_help.lua
		},
	},
	
	[WHEEL_OPTION.yes] = {
		display_name = "loc_social_menu_confirmation_popup_confirm_button",
		icon = "content/ui/materials/icons/list_buttons/check",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_yes,
		},
	},
	
	[WHEEL_OPTION.no] = {
		display_name = "loc_social_menu_confirmation_popup_decline_button",
		icon = "content/ui/materials/icons/list_buttons/cross",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_no,
		},
	},
	
	-- Новые опции из исходного кода (не используются в стандартном колесе)
	[WHEEL_OPTION.follow_you] = {
		display_name = "loc_reply_smart_tag_follow", -- Используется в smart_tag_settings.lua
		icon = "content/ui/materials/icons/list_buttons/check", -- Временная иконка, нужно найти подходящую
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_follow_you,
		},
	},
	
	[WHEEL_OPTION.my_pleasure] = {
		display_name = "loc_reply_smart_tag_ok", -- Временный ключ, нужно найти правильный
		icon = "content/ui/materials/hud/communication_wheel/icons/thanks", -- Временная иконка
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_my_pleasure,
		},
	},
	
	[WHEEL_OPTION.need_that] = {
		display_name = "loc_reply_smart_tag_dibs", -- Используется в smart_tag_settings.lua
		icon = "content/ui/materials/icons/list_buttons/check", -- Временная иконка
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_that,
		},
	},
	
	[WHEEL_OPTION.take_this] = {
		display_name = "loc_reply_smart_tag_ok", -- Временный ключ, нужно найти правильный
		icon = "content/ui/materials/hud/communication_wheel/icons/ammo", -- Временная иконка
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_take_this,
		},
	},
}

return {
	WHEEL_OPTION = WHEEL_OPTION,
	wheel_options = wheel_options,
}

