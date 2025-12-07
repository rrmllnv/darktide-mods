local InputUtils = require("scripts/managers/input/input_utils")

local localizations = {
	mod_title = {
		en = "Friendly Fire Notify",
		ru = "Уведомления об уроне союзников",
	},
	mod_description = {
		en = "FriendlyFireNotify - Shows notifications when you take damage from teammates.",
		ru = "FriendlyFireNotify - Показывает уведомления при получении урона от сокомандников.",
	},
	min_damage_threshold = {
		en = "Minimum damage threshold",
		ru = "Минимальный порог урона",
	},
	show_total_damage = {
		en = "Show total damage from player",
		ru = "Показывать общий урон от игрока",
	},
	show_team_total_damage = {
		en = "Show total damage from team",
		ru = "Показывать общий урон от команды",
	},
	notification_coalesce_time = {
		en = "Damage aggregation window (sec)",
		ru = "Окно агрегации урона (сек)",
	},
	notification_duration_time = {
		en = "Notification display time (sec)",
		ru = "Время показа уведомления (сек)",
	},
	notification_background_color = {
		en = "Notification background color",
		ru = "Цвет фона уведомления",
	},
	friendly_fire_line1_self = {
		en = "You damaged yourself",
		ru = "Вы нанесли себе",
	},
	friendly_fire_line1_ally = {
		en = "Player %s damaged you",
		ru = "Игрок %s нанес вам",
	},
	friendly_fire_line1_unknown = {
		en = "You took incidental damage",
		ru = "Вы получили побочный урон",
	},
	friendly_fire_damage_suffix = {
		en = "%s damage",
		ru = "%s урона",
	},
	friendly_fire_total_suffix = {
		en = " (total %s)",
		ru = " (всего %s)",
	},
	friendly_fire_total_line = {
		en = "Total damage from player: %s",
		ru = "Общий урон от игрока: %s",
	},
	friendly_fire_team_total = {
		en = "Team total damage: %s",
		ru = "Общий урон от команды: %s",
	},
	friendly_fire_kill_line1_ally = {
		en = "Player %s killed you",
		ru = "Игрок %s убил вас",
	},
	friendly_fire_kill_total = {
		en = "total %s",
		ru = "всего %s",
	},
	friendly_fire_kill_team_total = {
		en = "Team total kills %s",
		ru = "Общие убийства от команды %s",
	},
	friendly_fire_damage_word_one = {
		en = "damage",
		ru = "урон",
	},
	friendly_fire_damage_word_other = {
		en = "damage",
		ru = "урона",
	},
	friendly_fire_unknown_player = {
		en = "Unknown",
		ru = "Неизвестный",
	},
	friendly_fire_unknown_account = {
		en = "Unknown",
		ru = "Неизвестный",
	},
	friendly_fire_source_suffix = {
		en = "via %s",
		ru = "через %s",
	},
	fire_barrel_explosion = {
		en = "barrel explosion",
		ru = "взрыв бочки",
	},
	fire_barrel_explosion_close = {
		en = "barrel explosion",
		ru = "взрыв бочки",
	},
	barrel_explosion_close = {
		en = "barrel explosion",
		ru = "взрыв бочки",
	},
	barrel_explosion = {
		en = "barrel explosion",
		ru = "взрыв бочки",
	},
	liquid_area_fire_burning_barrel = {
		en = "barrel fire",
		ru = "огонь от бочки",
	},
	liquid_area_fire_burning = {
		en = "fire",
		ru = "огонь",
	},
	flame_grenade_liquid_area_fire_burning = {
		en = "fire",
		ru = "огонь",
	},
	grenadier_liquid_fire_burning = {
		en = "fire",
		ru = "огонь",
	},
	cultist_flamer_liquid_fire_burning = {
		en = "fire",
		ru = "огонь",
	},
	renegade_flamer_liquid_fire_burning = {
		en = "fire",
		ru = "огонь",
	},
	flamer_backpack_explosion = {
		en = "flamer backpack explosion",
		ru = "взрыв ранца огнемета",
	},
	flamer_backpack_explosion_close = {
		en = "flamer backpack explosion",
		ru = "взрыв ранца огнемета",
	},
	interrupted_flamer_backpack_explosion = {
		en = "flamer backpack explosion",
		ru = "взрыв ранца огнемета",
	},
	interrupted_flamer_backpack_explosion_close = {
		en = "flamer backpack explosion",
		ru = "взрыв ранца огнемета",
	},
	poxwalker_explosion = {
		en = "poxburster explosion",
		ru = "взрыв чумного взрывуна",
	},
	poxwalker_explosion_close = {
		en = "poxburster explosion",
		ru = "взрыв чумного взрывуна",
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

local color_names = Color.list
for _, color_name in ipairs(color_names) do
	local color_values = Color[color_name](100, true)
	local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
	localizations[color_name] = {
		en = text,
	}
end

return localizations