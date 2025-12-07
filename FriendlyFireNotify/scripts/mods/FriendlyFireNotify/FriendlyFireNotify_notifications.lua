local mod = get_mod("FriendlyFireNotify")

local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UISettings = mod:original_require("scripts/settings/ui/ui_settings")
local Text = mod:original_require("scripts/utilities/ui/text")
local ConstantElementNotificationFeed = mod:original_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed")
local NotificationFeedDefinitions = mod:original_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_definitions")

local notifications = mod.notifications or {}
mod.notifications = notifications
local FFN_MESSAGE_TYPE = "ffn_custom"

local ENABLE_CUSTOM_WIDTH = false -- переключатель расширения кастомных уведомлений
local ENABLE_TEST_PREFIX = true -- добавить префикс к первой строке (для проверки кастомного типа)

local NotificationFeed = nil

mod.COLOR_DAMAGE = mod.COLOR_DAMAGE or Color.ui_orange_light(255, true)
mod.COLOR_TOTAL_DAMAGE = mod.COLOR_TOTAL_DAMAGE or Color.ui_orange_light(255, true)
mod.COLOR_PLAYER_TOTAL = mod.COLOR_PLAYER_TOTAL or Color.ui_orange_light(255, true)
mod.COLOR_TEAM_TOTAL = mod.COLOR_TEAM_TOTAL or Color.ui_orange_light(255, true)
mod.COLOR_BACKGROUND = mod.COLOR_BACKGROUND or Color.terminal_corner_selected(60, true)
mod.DEFAULT_NOTIFICATION_COALESCE_TIME = mod.DEFAULT_NOTIFICATION_COALESCE_TIME or 3
mod.DEFAULT_NOTIFICATION_DURATION_TIME = mod.DEFAULT_NOTIFICATION_DURATION_TIME or 8
mod.settings = mod.settings or {}
mod.DEBUG = mod.DEBUG or false

local PROFILE_EXCEPTIONS = {
	fire_barrel_explosion = true,
	fire_barrel_explosion_close = true,
	barrel_explosion_close = true,
	barrel_explosion = true,
	liquid_area_fire_burning = true,
	liquid_area_fire_burning_barrel = true,
	flame_grenade_liquid_area_fire_burning = true,
	grenadier_liquid_fire_burning = true,
	cultist_flamer_liquid_fire_burning = true,
	renegade_flamer_liquid_fire_burning = true,
	poxwalker_explosion_close = true,
	poxwalker_explosion = true,
	flamer_backpack_explosion = true,
	flamer_backpack_explosion_close = true,
	interrupted_flamer_backpack_explosion = true,
	interrupted_flamer_backpack_explosion_close = true,
}

mod.PROFILE_EXCEPTIONS = mod.PROFILE_EXCEPTIONS or PROFILE_EXCEPTIONS

-- Регистрируем отдельный тип, чтобы не трогать чужие custom
mod:hook_safe(ConstantElementNotificationFeed, "init", function(self, parent, draw_layer, start_scale)
	local templates = self._notification_templates
	if templates and not templates[FFN_MESSAGE_TYPE] and templates.custom then
		templates[FFN_MESSAGE_TYPE] = table.clone(templates.custom)
	end
end)

-- Чуть расширяем уведомления: берем исходный init и переиспользуем с увеличенной шириной.
mod:hook_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_definitions", function(defs)
	if not ENABLE_CUSTOM_WIDTH then
		return
	end

	local create = defs.notification_message
	local original_init = create.init

	create.init = function(parent, widget, element)
		if element.message_type ~= FFN_MESSAGE_TYPE then
			return original_init(parent, widget, element)
		end

		-- скопировано из оригинала, но с увеличенными width/max_text_width
		local total_text_size = 0
		local icon_size = {
			0,
			0,
		}
		local text_offset = 30
		local max_text_width = 480 -- было 400
		local widget_width = 720   -- было 600
		local notification_vertical_margin = 20
		local text_margin = 5
		local notification_horizontal_start_offset = 15
		local icon_max_height_overflow = 10

		if element.icon then
			if element.icon_size == "large_weapon" then
				icon_size = UISettings.weapon_icon_size
				text_offset = 210
			elseif element.icon_size == "large_cosmetic" then
				icon_size = UISettings.cosmetics_item_size
				text_offset = 210
			elseif element.icon_size == "weapon_skin" then
				icon_size = UISettings.cosmetics_item_size
				text_offset = 210
			elseif element.icon_size == "large_gadget" then
				icon_size = UISettings.gadget_icon_size
				text_offset = 210
			elseif element.icon_size == "large_item" then
				icon_size = UISettings.ui_item_size
				text_offset = 210
			elseif element.icon_size == "large" then
				icon_size = {
					128,
					128,
				}
				text_offset = 210
			elseif element.icon_size == "medium" then
				icon_size = {
					80,
					80,
				}
				text_offset = 130
			elseif element.icon_size == "portrait_frame" then
				icon_size = ItemSlotSettings.slot_portrait_frame and ItemSlotSettings.slot_portrait_frame.item_icon_size or {
					90,
					100,
				}
				text_offset = 210
			elseif element.icon_size == "insignia" then
				icon_size = ItemSlotSettings.slot_insignia and ItemSlotSettings.slot_insignia.item_icon_size or {
					40,
					90,
				}
				text_offset = 210
			elseif element.icon_size == "currency" then
				icon_size = {
					104,
					88,
				}
				text_offset = 130
			else
				icon_size = {
					40,
					40,
				}
				text_offset = 80
			end
		end

		for i = 1, #element.texts do
			local text = element.texts[i]

			if text.display_name and text.display_name ~= "" then
				local pass_name = string.format("text_%d", i)
				local text_style = widget.style[pass_name]

				text_style.font_size = text.font_size or i == 1 and 22 or text_style.font_size

				local width, height = Text.text_size(parent._parent:ui_renderer(), text.display_name, text_style, {
					max_text_width,
					1080,
				})

				text_style.offset[2] = total_text_size
				text_style.size = {
					max_text_width,
					height,
				}
				total_text_size = total_text_size + height + text_margin
				widget.content[pass_name] = text.display_name

				if text.color then
					widget.style[pass_name].text_color = table.clone(text.color)
				end
			end
		end

		widget.content.icon = element.icon
		widget.style.icon.material_values = element.icon_material_values or {}
		element.color = element.color or Color.terminal_background(255 * ConstantElementNotificationFeedSettings.default_alpha_value, true)
		widget.style.background.material_values.background_color = _convert_to_material_color(element.color)
		widget.style.background.material_values.line_color = _convert_to_material_color(element.line_color)
		widget.style.background.material_values.background_glow_opacity = element.glow_opacity or 0
		widget.style.icon.color = element.icon_color and table.clone(element.icon_color) or table.clone(widget.style.icon.color)

		local height = total_text_size + notification_vertical_margin * 2 - text_margin

		if icon_size[2] > height + icon_max_height_overflow then
			local scale_ratio = (height + icon_max_height_overflow) / icon_size[2]

			icon_size = {
				scale_ratio * icon_size[1],
				scale_ratio * icon_size[2],
			}
		end

		widget.style.icon.size = icon_size

		local widget_height = math.max(height, icon_size[2] - notification_vertical_margin * 2)
		local background_compensation_top = widget.style.background.size_addition[2] * 0.5

		widget.size = {
			widget_width,
			widget_height,
		}
		widget.style.background.size = {
			widget_width,
			height,
		}
		widget.style.shine.size[2] = height - background_compensation_top
		widget.content.show_shine = element.show_shine

		local offset_content_compensation = (widget_height - height) * 0.5

		widget.style.shine.offset[2] = widget.style.shine.offset[2] + offset_content_compensation + background_compensation_top * 0.5
		widget.style.background.offset[2] = widget.style.background.offset[2] + offset_content_compensation - background_compensation_top
		widget.style.icon.offset = {
			-text_offset * 0.5 - notification_horizontal_start_offset,
			widget.style.icon.offset[2] + widget_height * 0.5,
			widget.style.icon.offset[3],
		}

		for i = 1, #element.texts do
			local pass_name = string.format("text_%d", i)
			local text_style = widget.style[pass_name]

			text_style.offset = {
				-text_offset - notification_horizontal_start_offset,
				text_style.offset[2] + offset_content_compensation + notification_vertical_margin,
				text_style.offset[3],
			}
		end

		widget.style.background.color[1] = 0
		widget.style.icon.color[1] = 0
		widget.style.shine.color[1] = 0
		widget.style.text_1.text_color[1] = 0
		widget.style.text_2.text_color[1] = 0
		widget.style.text_3.text_color[1] = 0

		if widget.content.text_1 then
			widget.content.text_1 = "[FFNHOOK] " .. widget.content.text_1
		end
	end
end)

local function apply_notification_duration(duration)
	if not NotificationFeed or not NotificationFeed._notification_templates or not NotificationFeed._notification_templates.custom then
		return
	end

	local new_time = duration or mod.DEFAULT_NOTIFICATION_DURATION_TIME
	NotificationFeed._notification_templates.custom.total_time = new_time

	if NotificationFeed._notifications then
		for _, notification in ipairs(NotificationFeed._notifications) do
			notification.total_time = new_time
		end
	end
end

function notifications.refresh_settings()
	local min_threshold = tonumber(mod:get("min_damage_threshold")) or 0
	local show_total = mod:get("show_total_damage")
	local show_team_total = mod:get("show_team_total_damage")
	local coalesce_time = tonumber(mod:get("notification_coalesce_time")) or mod.DEFAULT_NOTIFICATION_COALESCE_TIME
	local note_time = tonumber(mod:get("notification_duration_time")) or mod.DEFAULT_NOTIFICATION_DURATION_TIME
	local bg_setting = mod:get("notification_background_color")
	local bg_color = (bg_setting and Color[bg_setting]) and Color[bg_setting](60, true) or mod.COLOR_BACKGROUND

	mod.settings = {
		min_damage_threshold = min_threshold,
		show_total_damage = show_total ~= false,
		show_team_total_damage = show_team_total ~= false,
		notification_coalesce_time = coalesce_time,
		notification_duration_time = note_time,
		notification_background_color = bg_color,
	}

	apply_notification_duration(note_time)
end

function notifications.now()
	if Managers.time and Managers.time:has_timer("gameplay") then
		return Managers.time:time("gameplay")
	end
	return os.clock()
end

function notifications.safe_format(template, fallback, ...)
	local t = template or fallback or "%s"
	local ok, result = pcall(string.format, tostring(t), ...)
	if ok then
		return result
	end

	local ok_fallback, result_fallback = pcall(string.format, tostring(fallback or "%s"), ...)
	if ok_fallback then
		return result_fallback
	end

	return tostring(fallback or "")
end

function notifications.loc(key)
	local value = mod:localize(key, "%s")
	if value and value ~= "" and not string.find(value, "^<") then
		return value
	end
	return key or ""
end

function notifications.format_number(number)
	local num = math.floor(number or 0)
	if num < 1000 then
		return tostring(num)
	end

	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

function notifications.make_damage_phrase(amount)
	local damage_value = Text.apply_color_to_text(notifications.format_number(amount), mod.COLOR_DAMAGE)
	local localization_manager = Managers.localization
	local language = localization_manager and localization_manager:language() or "en"

	if language == "ru" then
		local n = math.abs(math.floor(amount or 0))
		local last_two = n % 100
		local last = n % 10
		local word_key

		if last_two >= 11 and last_two <= 14 then
			word_key = "friendly_fire_damage_word_other"
		elseif last == 1 then
			word_key = "friendly_fire_damage_word_one"
		else
			word_key = "friendly_fire_damage_word_other"
		end

		local word = notifications.loc(word_key)
		return notifications.safe_format("%s %s", "%s %s", damage_value, word)
	else
		local damage_suffix = notifications.loc("friendly_fire_damage_suffix")
		return notifications.safe_format(damage_suffix, "%s damage", damage_value)
	end
end

function notifications.resolve_source_text(buffer_data)
	local damage_profile = buffer_data and buffer_data.damage_profile

	if damage_profile and damage_profile.name then
		local profile_name = damage_profile.name

		if mod.PROFILE_EXCEPTIONS[profile_name] then
			return notifications.loc(profile_name)
		end

		return profile_name
	end

	local attack_type = buffer_data and buffer_data.attack_type

	if attack_type then
		return tostring(attack_type)
	end

	return ""
end

function notifications.player_from_unit(unit)
	if unit then
		local player_manager = Managers.player
		local players = player_manager and player_manager:players()
		for _, player in pairs(players or {}) do
			if player and player.player_unit == unit then
				return player
			end
		end
	end
	return nil
end

function notifications.colored_player_name(player, fallback_key)
	if not player then
		return notifications.loc(fallback_key or "friendly_fire_unknown_player")
	end

	local player_name = player:name() or player:character_name() or notifications.loc(fallback_key or "friendly_fire_unknown_player")
	local player_slot = player.slot and player:slot()
	local player_slot_colors = UISettings.player_slot_colors
	local player_slot_color = player_slot and player_slot_colors and player_slot_colors[player_slot]

	if player_name and player_slot_color then
		return Text.apply_color_to_text(player_name, player_slot_color)
	end

	return player_name
end

local function notification_data(lines, options)
	local notification_player = options and options.notification_player
	local portrait_player = options and options.portrait_player
	local portrait_target = portrait_player or notification_player or (Managers.player and Managers.player:local_player(1))
	local profile = portrait_target and portrait_target:profile()
	local frame_item = profile and profile.loadout and profile.loadout.slot_portrait_frame

	local data = {
		show_shine = false,
		icon = "content/ui/materials/base/ui_portrait_frame_base",
		icon_size = options and options.icon_size or "large_item",
		line_1 = lines.line1 or "",
		line_2 = lines.line2 or "",
		line_3 = lines.line3 or "",
		color = (options and options.background_color) or mod.settings.notification_background_color or mod.COLOR_BACKGROUND,
	}

	if portrait_target and profile and (options == nil or options.use_player_portrait ~= false) then
		data.use_player_portrait = true
		data.player = portrait_target
	end

	if frame_item then
		data.item = frame_item
	end

	return data
end

function notifications.push(lines, options)
	if not Managers.event then
		return
	end

	local data = notification_data(lines, options)

	Managers.event:trigger(
		"event_add_notification_message",
		FFN_MESSAGE_TYPE,
		data,
		nil,
		UISoundEvents.notification_matchmaking_failed
	)
end

function notifications.show_incoming_kill(player_name, total_killer_kills, team_total_kills, notification_player, portrait_player)
	local message_name = player_name or notifications.loc("friendly_fire_unknown_player")
	if message_name and not string.find(message_name, "{#") then
		message_name = Text.apply_color_to_text(message_name, Color.ui_orange_light(255, true))
	end

	local line1_template = notifications.loc("friendly_fire_kill_line1_ally")
	local line1 = notifications.safe_format(line1_template, "Player %s killed you", tostring(message_name or ""))

	local killer_total_value = Text.apply_color_to_text(notifications.format_number(total_killer_kills or 0), Color.ui_orange_light(255, true)) or notifications.format_number(total_killer_kills or 0)
	local line2_template = notifications.loc("friendly_fire_kill_total")
	local line2 = notifications.safe_format(line2_template, "total %s", tostring(killer_total_value or "0"))

	local team_total_value = Text.apply_color_to_text(notifications.format_number(team_total_kills or 0), Color.ui_orange_light(255, true)) or notifications.format_number(team_total_kills or 0)
	local line3_template = notifications.loc("friendly_fire_kill_team_total")
	local line3 = notifications.safe_format(line3_template, "Team total kills %s", tostring(team_total_value or "0"))

	notifications.push(
		{
			line1 = line1,
			line2 = line2,
			line3 = line3,
		},
		{
			background_color = mod.COLOR_BACKGROUND,
			notification_player = notification_player,
			portrait_player = portrait_player,
			icon_size = "portrait_frame",
		}
	)
end

function notifications.show_incoming_damage(args)
	local damage_amount = args.damage_amount
	local total_damage = args.total_damage
	local team_total_damage = args.team_total_damage
	local is_self_damage = args.is_self_damage
	local player_name = args.player_name
	local source_text = args.source_text
	local notification_player = args.notification_player
	local portrait_player = args.portrait_player

	local min_damage_threshold = mod.settings.min_damage_threshold or 0
	if damage_amount < min_damage_threshold then
		return
	end

	local show_total = mod.settings.show_total_damage ~= false
	local show_team_total = mod.settings.show_team_total_damage ~= false
	local message
	local damage_line = notifications.make_damage_phrase(damage_amount)

	if is_self_damage then
		local self_template = notifications.loc("friendly_fire_line1_self")
		message = notifications.safe_format(self_template, "You damaged yourself")
	else
		local unknown_name = notifications.loc("friendly_fire_unknown_player")
		local name = player_name or unknown_name
		local is_unknown = name == unknown_name
		if name and not string.find(name, "{#") and not is_unknown then
			name = Text.apply_color_to_text(name, Color.ui_orange_light(255, true))
		end
		if is_unknown then
			local unknown_template = notifications.loc("friendly_fire_line1_unknown")
			message = notifications.safe_format(unknown_template, "Unknown source damaged you")
		else
			local ally_template = notifications.loc("friendly_fire_line1_ally")
			message = notifications.safe_format(ally_template, "Player %s damaged you", tostring(name or unknown_name))
		end
	end

	local line2 = damage_line
	local line3 = ""

	if show_total and total_damage and total_damage > 0 then
		local total_value = Text.apply_color_to_text(notifications.format_number(total_damage or 0), mod.COLOR_PLAYER_TOTAL) or notifications.format_number(total_damage or 0)
		local total_template = notifications.loc("friendly_fire_total_suffix")
		line2 = notifications.safe_format("%s" .. total_template, "%s (total %s)", line2, tostring(total_value or "0"))
	end

	if source_text and source_text ~= "" then
		local source_suffix = notifications.loc("friendly_fire_source_suffix")
		line2 = notifications.safe_format("%s " .. source_suffix, "%s (%s)", line2, tostring(source_text))
	end

	if not is_self_damage then
		local allies_total = team_total_damage or 0

		if show_team_total and allies_total > 0 then
			local allies_value = Text.apply_color_to_text(notifications.format_number(allies_total or 0), mod.COLOR_TEAM_TOTAL) or notifications.format_number(allies_total or 0)
			local team_template = notifications.loc("friendly_fire_team_total")
			line3 = notifications.safe_format(team_template, "Team total damage: %s", tostring(allies_value or "0"))
		end
	end

	notifications.push(
		{
			line1 = message,
			line2 = line2,
			line3 = line3,
		},
		{
			background_color = mod.settings.notification_background_color,
			notification_player = notification_player,
			portrait_player = portrait_player,
		}
	)
end

function notifications.show_outgoing_kill(player_name, target_kills, total_team_kills, notification_player, portrait_player)
	local display_name = player_name or notifications.loc("friendly_fire_unknown_player")
	if display_name and not string.find(display_name, "{#") then
		display_name = Text.apply_color_to_text(display_name, Color.ui_orange_light(255, true))
	end

	local line1_template = notifications.loc("friendly_fire_outgoing_kill_line1_ally")
	local line1 = notifications.safe_format(line1_template, "You killed player %s", tostring(display_name or ""))

	local target_total_value = Text.apply_color_to_text(notifications.format_number(target_kills or 0), Color.ui_orange_light(255, true)) or notifications.format_number(target_kills or 0)
	local line2_template = notifications.loc("friendly_fire_kill_total")
	local line2 = notifications.safe_format(line2_template, "total %s", tostring(target_total_value or "0"))

	local team_total_value = Text.apply_color_to_text(notifications.format_number(total_team_kills or 0), Color.ui_orange_light(255, true)) or notifications.format_number(total_team_kills or 0)
	local line3_template = notifications.loc("friendly_fire_outgoing_kill_team_total")
	local line3 = notifications.safe_format(line3_template, "Your total team kills %s", tostring(team_total_value or "0"))

	notifications.push(
		{
			line1 = line1,
			line2 = line2,
			line3 = line3,
		},
		{
			background_color = mod.COLOR_BACKGROUND,
			notification_player = notification_player,
			portrait_player = portrait_player,
			icon_size = "portrait_frame",
		}
	)
end

function notifications.show_outgoing_damage(args)
	local damage_amount = args.damage_amount
	local total_damage = args.total_damage
	local team_total_damage = args.team_total_damage
	local player_name = args.player_name
	local source_text = args.source_text
	local notification_player = args.notification_player
	local portrait_player = args.portrait_player

	local min_damage_threshold = mod.settings.min_damage_threshold or 0
	if damage_amount < min_damage_threshold then
		return
	end

	local show_total = mod.settings.show_total_damage ~= false
	local show_team_total = mod.settings.show_team_total_damage ~= false

	local unknown_name = notifications.loc("friendly_fire_unknown_player")
	local name = player_name or unknown_name
	local is_unknown = name == unknown_name
	if name and not string.find(name, "{#") and not is_unknown then
		name = Text.apply_color_to_text(name, Color.ui_orange_light(255, true))
	end

	local line1_template = is_unknown and notifications.loc("friendly_fire_outgoing_line1_unknown") or notifications.loc("friendly_fire_outgoing_line1_ally")
	local line1 = notifications.safe_format(line1_template, "You damaged player %s", tostring(name or unknown_name))

	local line2 = notifications.make_damage_phrase(damage_amount)
	local line3 = ""

	if show_total and total_damage and total_damage > 0 then
		local total_value = Text.apply_color_to_text(notifications.format_number(total_damage or 0), mod.COLOR_PLAYER_TOTAL) or notifications.format_number(total_damage or 0)
		local total_template = notifications.loc("friendly_fire_total_suffix")
		line2 = notifications.safe_format("%s" .. total_template, "%s (total %s)", line2, tostring(total_value or "0"))
	end

	if source_text and source_text ~= "" then
		local source_suffix = notifications.loc("friendly_fire_source_suffix")
		line2 = notifications.safe_format("%s " .. source_suffix, "%s (%s)", line2, tostring(source_text))
	end

	if show_team_total and (team_total_damage or 0) > 0 then
		local allies_value = Text.apply_color_to_text(notifications.format_number(team_total_damage or 0), mod.COLOR_TEAM_TOTAL) or notifications.format_number(team_total_damage or 0)
		local team_template = notifications.loc("friendly_fire_outgoing_team_total")
		line3 = notifications.safe_format(team_template, "Your total team damage: %s", tostring(allies_value or "0"))
	end

	notifications.push(
		{
			line1 = line1,
			line2 = line2,
			line3 = line3,
		},
		{
			background_color = mod.settings.notification_background_color,
			notification_player = notification_player,
			portrait_player = portrait_player,
		}
	)
end

mod:hook(ConstantElementNotificationFeed, "_generate_notification_data", function(func, self, message_type, data)
	local notification_data = func(self, message_type, data)

	if message_type == "custom" and notification_data and data then
		if data.use_player_portrait then
			notification_data.use_player_portrait = true
			notification_data.player = data.player
		end

		if data.item then
			notification_data.item = data.item
		end
	end

	return notification_data
end)

mod:hook_safe(ConstantElementNotificationFeed, "_event_player_authenticated", function(self)
	NotificationFeed = self
	apply_notification_duration(mod.settings.notification_duration_time)
end)

return notifications

