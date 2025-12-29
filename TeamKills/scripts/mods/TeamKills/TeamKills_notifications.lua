local mod = get_mod("TeamKills")

local ConstantElementNotificationFeed = mod:original_require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed")
local UISettings = require("scripts/settings/ui/ui_settings")

local function format_boss_damage_text_for_notification(unit, boss_extension, attack_data)
	local boss_damage_data = mod.boss_damage and mod.boss_damage[unit]
	if not boss_damage_data or not next(boss_damage_data) then
		return nil
	end
	
	local show_total_damage = mod:get("opt_show_total_damage_notification") ~= false
	local show_max_damage = mod:get("opt_show_max_damage_notification") ~= false
	local show_last_damage = mod:get("opt_show_last_hit_damage_notification") ~= false
	local show_killer_name = mod:get("opt_show_killer_name_notification") ~= false
	
	local current_players = mod.get_current_players()
	local boss_last_damage_data = mod.boss_last_damage and mod.boss_last_damage[unit]
	
	local damage_color_name = mod.damage_color or "orange"
	local damage_rgb = mod.color_presets[damage_color_name] or mod.color_presets["orange"]
	local last_damage_color_name = mod.last_damage_color or "orange"
	local last_damage_rgb = mod.color_presets[last_damage_color_name] or mod.color_presets["orange"]
	local white_rgb = mod.color_presets["white"] or {255, 255, 255}
	
	local players_with_damage = {}
	local total_damage = 0
	for account_id, damage in pairs(boss_damage_data) do
		if damage > 0 then
			local display_name = current_players[account_id]
			if display_name then
				local last_damage = boss_last_damage_data and boss_last_damage_data[account_id] or 0
				total_damage = total_damage + damage
				local player_color = mod.get_player_color(account_id)
				table.insert(players_with_damage, {
					name = display_name,
					damage = math.floor(damage),
					last_damage = math.floor(last_damage),
					account_id = account_id,
					player_color = player_color
				})
			end
		end
	end
	
	if #players_with_damage == 0 then
		return nil
	end
	
	table.sort(players_with_damage, function(a, b)
		return a.damage > b.damage
	end)
	
	local max_damage_player = players_with_damage[1]
	
	local boss_name = ""
	if boss_extension then
		local display_name = boss_extension:display_name()
		if display_name then
			boss_name = Localize(display_name)
		end
	end
	if boss_name == "" then
		local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
		if unit_data_extension then
			local breed = unit_data_extension:breed()
			if breed and breed.display_name then
				boss_name = Localize(breed.display_name)
			end
		end
	end
	if boss_name == "" then
		boss_name = mod:localize("i18n_notification_boss_default")
	end
	
	local lines = {}
	
	local boss_name_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", white_rgb[1], white_rgb[2], white_rgb[3], boss_name)
	lines[#lines + 1] = boss_name_text
	
	local killer_player = nil
	local killer_account_id = nil
	local killer_last_damage = 0
	if mod.last_enemy_interaction and mod.last_enemy_interaction[unit] then
		local killer_unit = mod.last_enemy_interaction[unit]
		killer_player = mod.player_from_unit(killer_unit)
		if killer_player then
			killer_account_id = killer_player:account_id() or killer_player:name()
			killer_last_damage = boss_last_damage_data and boss_last_damage_data[killer_account_id] or 0
		end
	end
	
	if killer_player and show_killer_name then
		local killer_name = current_players[killer_account_id]
		if not killer_name then
			killer_name = killer_player.character_name and killer_player:character_name() or killer_player:name() or tostring(killer_account_id)
		end
		
		local killer_name_text = killer_name
		local killer_color = mod.get_player_color(killer_account_id)
		if killer_color then
			killer_name_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", killer_color[1], killer_color[2], killer_color[3], killer_name)
		end
		
		local killer_line = mod:localize("i18n_notification_killed_by") .. killer_name_text
		if show_last_damage and killer_last_damage > 0 then
			local last_dmg_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", last_damage_rgb[1], last_damage_rgb[2], last_damage_rgb[3], mod.format_number(math.floor(killer_last_damage)))
			killer_line = killer_line .. " [" .. last_dmg_text .. "]"
		end
		lines[#lines + 1] = killer_line
	end
	
	if attack_data and type(attack_data) == "table" and show_killer_name then
		local kill_details = {}
		
		if attack_data.weapon_template_name and attack_data.weapon_template_name ~= "none" then
			local weapon_display_name = attack_data.weapon_template_name
			local success, localized = pcall(function()
				return Localize("loc_weapon_display_name_" .. attack_data.weapon_template_name)
			end)
			if success and localized and localized ~= ("loc_weapon_display_name_" .. attack_data.weapon_template_name) then
				weapon_display_name = localized
			end
			kill_details[#kill_details + 1] = weapon_display_name
		end
		
		local kill_tags = {}
		if attack_data.hit_weakspot then
			kill_tags[#kill_tags + 1] = "Weakspot"
		end
		if attack_data.is_critical_hit then
			kill_tags[#kill_tags + 1] = "Critical"
		end
		if attack_data.is_backstab then
			kill_tags[#kill_tags + 1] = "Backstab"
		end
		
		if #kill_tags > 0 then
			kill_details[#kill_details + 1] = table.concat(kill_tags, ", ")
		end
		
		if #kill_details > 0 then
			local details_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", white_rgb[1], white_rgb[2], white_rgb[3], table.concat(kill_details, " • "))
			lines[#lines + 1] = "  " .. details_text
		end
	end
	
	if show_total_damage and total_damage > 0 then
		local total_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], mod.format_number(math.floor(total_damage)))
		lines[#lines + 1] = mod:localize("i18n_notification_total") .. total_damage_text
	end
	
	if show_max_damage and max_damage_player then
		local max_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], mod.format_number(max_damage_player.damage))
		local max_percent = total_damage > 0 and math.floor((max_damage_player.damage / total_damage) * 100) or 0
		local player_name = max_damage_player.name
		if max_damage_player.player_color then
			player_name = string.format("{#color(%d,%d,%d)}%s{#reset()}", max_damage_player.player_color[1], max_damage_player.player_color[2], max_damage_player.player_color[3], player_name)
		end
		lines[#lines + 1] = mod:localize("i18n_notification_top") .. player_name .. " (" .. max_percent .. "%)" .. " " .. max_damage_text
	end
	
	if #players_with_damage > 0 then
		lines[#lines + 1] = " "
	end
	
	for _, player in ipairs(players_with_damage) do
		local damage_number = mod.format_number(player.damage)
		local percent = total_damage > 0 and math.floor((player.damage / total_damage) * 100) or 0
		
		local parts = {}
		local player_name = player.name
		if player.player_color then
			player_name = string.format("{#color(%d,%d,%d)}%s{#reset()}", player.player_color[1], player.player_color[2], player.player_color[3], player_name)
		end
		parts[#parts + 1] = player_name
		
		if show_total_damage and total_damage > 0 then
			parts[#parts + 1] = "(" .. percent .. "%)"
		end
		
		parts[#parts + 1] = ":"
		
		if show_total_damage then
			local damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", damage_rgb[1], damage_rgb[2], damage_rgb[3], damage_number)
			parts[#parts + 1] = damage_text
		end
		
		if show_last_damage and player.last_damage > 0 then
			local last_damage_text = string.format("{#color(%d,%d,%d)}%s{#reset()}", last_damage_rgb[1], last_damage_rgb[2], last_damage_rgb[3], mod.format_number(player.last_damage))
			parts[#parts + 1] = "[" .. last_damage_text .. "]"
		end
		
		if #parts > 1 then
			lines[#lines + 1] = table.concat(parts, " ")
		end
	end
	
	return #lines > 0 and lines or nil
	end

mod:hook(ConstantElementNotificationFeed, "_generate_notification_data", function(func, self, message_type, data)
	local notification_data = func(self, message_type, data)
	
	if message_type == "custom" and notification_data and data and data.line_1 then
		local lines = {}
		for line in string.gmatch(data.line_1, "([^\n]+)") do
			if line and line ~= "" then
				table.insert(lines, {
					display_name = line,
					color = data.line_1_color,
				})
			end
		end
		
		if #lines > 0 then
			if #lines > 3 then
				local extra_lines = {}
				for i = 4, #lines do
					table.insert(extra_lines, lines[i].display_name)
				end
				lines[3].display_name = lines[3].display_name .. "\n" .. table.concat(extra_lines, "\n")
				for i = 4, #lines do
					lines[i] = nil
				end
			end
			
			notification_data.texts = {}
			for i = 1, math.min(#lines, 3) do
				notification_data.texts[i] = lines[i]
			end
		end
	end
	
	return notification_data
end)

mod:hook_safe(CLASS.HudElementBossHealth, "event_boss_encounter_end", function(self, unit, boss_extension)
	if mod:get("opt_show_boss_death_notification") == false then
		return
	end
	
	if not mod.boss_damage or not mod.boss_damage[unit] or not next(mod.boss_damage[unit]) then
		return
	end
	
	if not mod.killed_units or not mod.killed_units[unit] then
		if mod.boss_damage and mod.boss_damage[unit] then
			mod.boss_damage[unit] = nil
		end
		if mod.boss_last_damage and mod.boss_last_damage[unit] then
			mod.boss_last_damage[unit] = nil
		end
		return
	end
	
	local damage_lines = format_boss_damage_text_for_notification(unit, boss_extension, nil)
	
	if damage_lines and #damage_lines > 0 then
		local all_lines = table.concat(damage_lines, "\n")
		local notification_data = {
			line_1 = all_lines,
			show_shine = false,
		}
		
		if Managers.event then
			Managers.event:trigger("event_add_notification_message", "custom", notification_data)
		end
	end
	
	if mod.boss_damage and mod.boss_damage[unit] then
		mod.boss_damage[unit] = nil
	end
	if mod.boss_last_damage and mod.boss_last_damage[unit] then
		mod.boss_last_damage[unit] = nil
	end
end)
