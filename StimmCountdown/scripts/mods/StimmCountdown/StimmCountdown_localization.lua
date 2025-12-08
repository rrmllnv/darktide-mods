local InputUtils = require("scripts/managers/input/input_utils")

local localizations = {
	mod_name = {
		en = "Stimm Countdown",
		ru = "Счётчик Стимма",
	},
	mod_description = {
		en = "Shows stimm duration and cooldown timer for Hive Scum (Broker) class.",
		ru = "Показывает таймер действия и перезарядки стимма для класса Hive Scum (Broker).",
	},

	display_group = {
		en = "Display",
		ru = "Отображение",
	},
	colors_group = {
		en = "Colors",
		ru = "Цвета",
	},

	-- Настройки
	show_active = {
		en = "Show Active Timer",
		ru = "Показывать таймер действия",
	},
	show_active_tooltip = {
		en = "Show remaining stimm effect duration when active.",
		ru = "Показывать оставшееся время действия стимма когда он активен.",
	},
	show_cooldown = {
		en = "Show Cooldown Timer",
		ru = "Показывать таймер перезарядки",
	},
	show_cooldown_tooltip = {
		en = "Show stimm ability cooldown when recharging.",
		ru = "Показывать время перезарядки способности стимма.",
	},
	show_decimals = {
		en = "Show Decimals",
		ru = "Показывать десятичные",
	},
	show_decimals_tooltip = {
		en = "Show time with decimal point (e.g. 12.5 instead of 13).",
		ru = "Показывать время с десятичной точкой (например 12.5 вместо 13).",
	},
	show_ready_notification = {
		en = "Notify when stimm is ready",
		ru = "Уведомлять когда стим готов",
	},
	show_ready_notification_tooltip = {
		en = "Show a notification when the stimm syringe is ready to use.",
		ru = "Показывать уведомление когда стим готов к использованию.",
	},
	stimm_ready_notification = {
		en = "Stimm ready",
		ru = "Стим готов",
	},
	enable_ready_color_override = {
		en = "Enable ready colors",
		ru = "Включить цвета готовности",
	},
	enable_ready_color_override_tooltip = {
		en = "Use custom colors for ready state timer and icon.",
		ru = "Использовать свои цвета таймера и иконки в состоянии готовности.",
	},
	ready_countdown_color = {
		en = "Ready countdown color",
		ru = "Цвет таймера (готов)",
	},
	ready_icon_color = {
		en = "Ready icon color",
		ru = "Цвет иконки (готов)",
	},
	enable_active_color_override = {
		en = "Enable active colors",
		ru = "Включить цвета активности",
	},
	enable_active_color_override_tooltip = {
		en = "Use custom colors for active timer and icon.",
		ru = "Использовать свои цвета таймера и иконки в активности.",
	},
	active_countdown_color = {
		en = "Active countdown color",
		ru = "Цвет таймера (активен)",
	},
	active_icon_color = {
		en = "Active icon color",
		ru = "Цвет иконки (активен)",
	},
	enable_cooldown_color_override = {
		en = "Enable cooldown colors",
		ru = "Включить цвета перезарядки",
	},
	enable_cooldown_color_override_tooltip = {
		en = "Use custom colors for cooldown timer and icon.",
		ru = "Использовать свои цвета таймера и иконки в перезарядке.",
	},
	cooldown_countdown_color = {
		en = "Cooldown countdown color",
		ru = "Цвет таймера (перезарядка)",
	},
	cooldown_icon_color = {
		en = "Cooldown icon color",
		ru = "Цвет иконки (перезарядка)",
	},
	enable_notification_color_override = {
		en = "Enable notification colors",
		ru = "Включить цвета уведомления",
	},
	enable_notification_color_override_tooltip = {
		en = "Use custom colors for ready notification.",
		ru = "Использовать свои цвета для уведомления о готовности.",
	},
	notification_line_color = {
		en = "Notification border color",
		ru = "Цвет рамки уведомления",
	},
	notification_icon_color = {
		en = "Notification icon color",
		ru = "Цвет иконки уведомления",
	},
	notification_background_color = {
		en = "Notification background color",
		ru = "Цвет фона уведомления",
	},
	notification_text_color = {
		en = "Notification text color",
		ru = "Цвет текста уведомления",
	},
	default_ready_color_option = {
		en = "Default (ready timer)",
		ru = "По умолчанию (таймер готовности)",
	},
	default_ready_icon_option = {
		en = "Default (ready icon)",
		ru = "По умолчанию (иконка готовности)",
	},
	default_active_color_option = {
		en = "Default (active timer)",
		ru = "По умолчанию (таймер активности)",
	},
	default_active_icon_option = {
		en = "Default (active icon)",
		ru = "По умолчанию (иконка активности)",
	},
	default_cooldown_color_option = {
		en = "Default (cooldown timer)",
		ru = "По умолчанию (таймер перезарядки)",
	},
	default_cooldown_icon_option = {
		en = "Default (cooldown icon)",
		ru = "По умолчанию (иконка перезарядки)",
	},
	default_notification_line_option = {
		en = "Default (notification border)",
		ru = "По умолчанию (рамка уведомления)",
	},
	default_notification_icon_option = {
		en = "Default (notification icon)",
		ru = "По умолчанию (иконка уведомления)",
	},
	default_notification_background_option = {
		en = "Default (notification background)",
		ru = "По умолчанию (фон уведомления)",
	},
}

local function readable(text)
	local readable_string = ""
	for token in string.gmatch(text, "([^_]+)") do
		local first = string.sub(token, 1, 1)
		token = string.format("%s%s", string.upper(first), string.sub(token, 2))
		readable_string = string.trim(string.format("%s %s", readable_string, token))
	end
	return readable_string
end

for _, color_name in ipairs(Color.list) do
	local color_values = Color[color_name](100, true)
	local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
	localizations[color_name] = {
		en = text,
	}
end

return localizations
