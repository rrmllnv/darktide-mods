local mod = get_mod("TeamKills")

local Color = Color
local Managers = Managers
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UISettings = mod:original_require("scripts/settings/ui/ui_settings")

local KillstreakWidgetSettings = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetSettings")
local base_z = KillstreakWidgetSettings.killsboard_base_z
local base_x = 0

local mutator_localization_map = {
	["chaos_mutator_daemonhost"] = "i18n_breed_chaos_mutator_daemonhost",
	["renegade_flamer_mutator"] = "i18n_breed_renegade_flamer_mutator",
	["cultist_mutant_mutator"] = "i18n_breed_cultist_mutant_mutator",
	["chaos_hound_mutator"] = "i18n_breed_chaos_hound_mutator",
	["chaos_mutator_ritualist"] = "i18n_breed_chaos_mutator_ritualist",
	["chaos_plague_ogryn_sprayer"] = "i18n_breed_chaos_plague_ogryn_sprayer",
}

local localization_cache = {}

local function localize_enemy(breed_name, key)
	local cache_key = breed_name or key
	if localization_cache[cache_key] then
		return localization_cache[cache_key]
	end
	
	if breed_name and mutator_localization_map[breed_name] then
		local mod_loc_key = mutator_localization_map[breed_name]
		local success, result = pcall(function()
			return mod:localize(mod_loc_key)
		end)
		if success and result and result ~= "" then
			localization_cache[cache_key] = result
			return result
		end
	end
	
	if key then
		local success, result = pcall(function()
			return Localize(key)
		end)
		if success and result and result ~= "" and result ~= key then
			localization_cache[cache_key] = result
			return result
		end
	end
	
	local fallback = key or breed_name or ""
	localization_cache[cache_key] = fallback
	return fallback
end

local group_localization_map = {
	["Melee Lessers"] = "i18n_stats_melee_lessers",
	["Ranged Lessers"] = "i18n_stats_ranged_lessers",
	["Melee Elites"] = "i18n_stats_melee_elites",
	["Ranged Elites"] = "i18n_stats_ranged_elites",
	["Specials"] = "i18n_stats_specials",
	["Disablers"] = "i18n_stats_disablers",
	["Bosses"] = "i18n_stats_bosses",
}

local function localize_group(group_name)
	if not group_name then
		return ""
	end
	
	local cache_key = "group_" .. group_name
	if localization_cache[cache_key] then
		return localization_cache[cache_key]
	end
	
	if group_localization_map[group_name] then
		local loc_key = group_localization_map[group_name]
		
		local success, result = pcall(function()
			return mod:localize(loc_key)
		end)
		if success and result and result ~= "" then
			localization_cache[cache_key] = result
			return result
		end
		
		local loc_key_with_prefix = "loc_" .. loc_key
		success, result = pcall(function()
			return Localize(loc_key_with_prefix)
		end)
		if success and result and result ~= "" and result ~= loc_key_with_prefix then
			localization_cache[cache_key] = result
			return result
		end
		
		success, result = pcall(function()
			return Localize(loc_key)
		end)
		if success and result and result ~= "" and result ~= loc_key then
			localization_cache[cache_key] = result
			return result
		end
	end
	
	localization_cache[cache_key] = group_name
	return group_name
end

local categories = {
	{"renegade_twin_captain_two", "loc_breed_display_name_renegade_twin_captain_two", "Bosses"},
	{"renegade_twin_captain", "loc_breed_display_name_renegade_twin_captain", "Bosses"},
	{"cultist_captain", "loc_breed_display_name_cultist_captain", "Bosses"},
	{"renegade_captain", "loc_breed_display_name_renegade_captain", "Bosses"},
	{"chaos_plague_ogryn_sprayer", "loc_breed_display_name_chaos_plage_ogryn", "Bosses"},
	{"chaos_plague_ogryn", "loc_breed_display_name_chaos_plage_ogryn", "Bosses"},
	{"chaos_spawn", "loc_breed_display_name_chaos_spawn", "Bosses"},
	{"chaos_daemonhost", "loc_breed_display_name_chaos_daemonhost", "Bosses"},
	{"chaos_mutator_daemonhost", "loc_breed_display_name_chaos_daemonhost", "Bosses"},
	{"chaos_beast_of_nurgle", "loc_breed_display_name_chaos_beast_of_nurgle", "Bosses"},
	{"chaos_ogryn_gunner", "loc_breed_display_name_chaos_ogryn_gunner", "Ranged Elites"},
	{"renegade_shocktrooper", "loc_breed_display_name_renegade_shocktrooper", "Ranged Elites"},
	{"cultist_shocktrooper", "loc_breed_display_name_cultist_shocktrooper", "Ranged Elites"},
	{"renegade_radio_operator", "loc_breed_display_name_renegade_radio_operator", "Ranged Elites"},
	{"renegade_plasma_gunner", "loc_breed_display_name_renegade_plasma_gunner", "Ranged Elites"},
	{"renegade_gunner", "loc_breed_display_name_renegade_gunner", "Ranged Elites"},
	{"cultist_gunner", "loc_breed_display_name_cultist_gunner", "Ranged Elites"},
	{"chaos_ogryn_executor", "loc_breed_display_name_chaos_ogryn_executor", "Melee Elites"},
	{"chaos_ogryn_bulwark", "loc_breed_display_name_chaos_ogryn_bulwark", "Melee Elites"},
	{"renegade_executor", "loc_breed_display_name_renegade_executor", "Melee Elites"},
	{"renegade_berzerker", "loc_breed_display_name_renegade_berzerker", "Melee Elites"},
	{"cultist_berzerker", "loc_breed_display_name_cultist_berzerker", "Melee Elites"},
	{"cultist_flamer", "loc_breed_display_name_cultist_flamer", "Specials"},
	{"renegade_flamer", "loc_breed_display_name_renegade_flamer", "Specials"},
	{"renegade_flamer_mutator", "loc_breed_display_name_renegade_flamer", "Specials"},
	{"renegade_sniper", "loc_breed_display_name_renegade_sniper", "Specials"},
	{"cultist_grenadier", "loc_breed_display_name_cultist_grenadier", "Specials"},
	{"renegade_grenadier", "loc_breed_display_name_renegade_grenadier", "Specials"},
	{"chaos_poxwalker_bomber", "loc_breed_display_name_chaos_poxwalker_bomber", "Specials"},
	{"renegade_netgunner", "loc_breed_display_name_renegade_netgunner", "Disablers"},
	{"cultist_mutant", "loc_breed_display_name_cultist_mutant", "Disablers"},
	{"cultist_mutant_mutator", "loc_breed_display_name_cultist_mutant", "Disablers"},
	{"chaos_hound", "loc_breed_display_name_chaos_hound", "Disablers"},
	{"chaos_hound_mutator", "loc_breed_display_name_chaos_hound", "Disablers"},
	{"renegade_rifleman", "loc_breed_display_name_renegade_rifleman", "Ranged Lessers"},
	{"renegade_assault", "loc_breed_display_name_renegade_assault", "Ranged Lessers"},
	{"cultist_assault", "loc_breed_display_name_cultist_assault", "Ranged Lessers"},
	{"chaos_lesser_mutated_poxwalker", "loc_breed_display_name_chaos_lesser_mutated_poxwalker", "Ranged Lessers"},
	{"renegade_melee", "loc_breed_display_name_renegade_melee", "Melee Lessers"},
	{"cultist_ritualist", "loc_breed_display_name_cultist_ritualist", "Melee Lessers"},
	{"chaos_mutator_ritualist", "loc_breed_display_name_cultist_ritualist", "Melee Lessers"},
	{"cultist_melee", "loc_breed_display_name_cultist_melee", "Melee Lessers"},
	{"chaos_armored_infected", "loc_chaos_armored_infected_breed_name", "Melee Lessers"},
	{"chaos_mutated_poxwalker", "loc_breed_display_name_chaos_mutated_poxwalker", "Melee Lessers"},
	{"chaos_poxwalker", "loc_breed_display_name_chaos_poxwalker", "Melee Lessers"},
	{"chaos_newly_infected", "loc_breed_display_name_chaos_newly_infected", "Melee Lessers"},
}

local function get_players()
	local players = {}
	local local_account_id = nil
	
	if Managers and Managers.player then
		local local_player = Managers.player:local_player(1)
		if local_player then
			local_account_id = local_player:account_id() or local_player:name()
		end
	end
	
	if Managers and Managers.player then
		local player_manager = Managers.player
		if player_manager and player_manager.players then
			local all_players = player_manager:players()
			if all_players then
				local local_player_data = nil
				
				for _, player in pairs(all_players) do
					if player and type(player) == "table" then
						local account_id = nil
						if player.account_id then
							account_id = player:account_id()
						end
						
						if account_id then
							local name = "Unknown"
							if player.character_name then
								name = player:character_name() or name
							elseif player.name then
								name = player:name() or name
							end
							
							local symbol = nil
							if player.profile then
								local profile = player:profile()
								if profile and profile.archetype then
									local archetype_name = profile.archetype.name
									symbol = archetype_name and UISettings.archetype_font_icon[archetype_name]
								end
							end
							if symbol then
								name = symbol .. " " .. name
							end
							
							local player_data = {
								account_id = account_id,
								name = name,
								player = player
							}
							
							if local_account_id and account_id == local_account_id then
								local_player_data = player_data
							else
								table.insert(players, player_data)
							end
						end
					end
				end
				
				if local_player_data then
					table.insert(players, 1, local_player_data)
				end
			end
		end
	end
	return players
end

mod.create_killsboard_row_widget = function(self, index, current_offset, visible_rows, row_data, widgets_by_name, loaded_players, _obj, _create_widget_callback, ui_renderer)
	local _blueprints = mod:io_dofile("TeamKills/scripts/mods/TeamKills/KillStreakBoard/WidgetBlueprints")
	local _settings = KillstreakWidgetSettings
	local killsboard_widget = widgets_by_name["killsboard"]
	
	local widget = nil
	local template = table.clone(_blueprints["killsboard_row"])
	local size = template.size
	local pass_template = template.pass_template
	local name = "killsboard_row_" .. (row_data.name or index)
	local header = row_data.type == "header"
	local subheader = row_data.type == "subheader"
	local total = row_data.type == "total"
	local group_header = row_data.type == "group_header"
	local spacer = row_data.type == "spacer"
	local no_data = row_data.type == "no_data"
	
	local base_row_height = (header or group_header or no_data or total) and _settings.killsboard_row_header_height or _settings.killsboard_row_height
	local bottom_offset = row_data.bottom_offset or 0
	local row_height = base_row_height + bottom_offset
	local font_size
	if header then
		font_size = _settings.killsboard_font_size_player_names
	elseif group_header or no_data or total then
		font_size = _settings.killsboard_font_size_header
	else
		font_size = _settings.killsboard_font_size
	end
	
	local content_width = _settings.killsboard_column_header_width + (_settings.killsboard_column_player_width * 4)
	local row_width = _settings.killsboard_size[1]
	local left_offset = (row_width - content_width) / 2
	
	local k_pass_map = {2, 5, 8, 11}
	local d_pass_map = {3, 6, 9, 12}
	local background_pass_map = {4, 7, 10, 13}
	
	local players = loaded_players or get_players()
	
	pass_template[1].style.font_size = font_size
	pass_template[1].style.size[2] = row_height
	pass_template[1].style.offset[1] = left_offset + _settings.killsboard_category_text_offset + 10
	
	for _, i in pairs(k_pass_map) do
		pass_template[i].style.font_size = font_size
		pass_template[i].style.size[1] = _settings.killsboard_column_kills_width
		pass_template[i].style.size[2] = row_height
	end
	for _, i in pairs(d_pass_map) do
		pass_template[i].style.font_size = font_size
		pass_template[i].style.size[1] = _settings.killsboard_column_damage_width
		pass_template[i].style.size[2] = row_height
	end
	
	pass_template[2].style.offset[1] = left_offset + _settings.killsboard_column_header_width
	pass_template[3].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_kills_width
	pass_template[5].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width
	pass_template[6].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width + _settings.killsboard_column_kills_width
	pass_template[8].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2
	pass_template[9].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2 + _settings.killsboard_column_kills_width
	pass_template[11].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3
	pass_template[12].style.offset[1] = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3 + _settings.killsboard_column_kills_width
	
	if header then
		pass_template[1].value = ""
		local num_players = 0
		for i = 1, 4 do
			pass_template[k_pass_map[i]].value = ""
			pass_template[d_pass_map[i]].value = ""
			pass_template[k_pass_map[i]].style.text_horizontal_alignment = "center"
			pass_template[k_pass_map[i]].style.size[1] = _settings.killsboard_column_player_bg_width
		end
		for _, player_data in pairs(players) do
			num_players = num_players + 1
			if num_players <= 4 then
				local name = player_data.name or "Unknown"
				
				local max_name_length = 14
				
				local space_pos = string.find(name, " ")
				if space_pos then
					local symbol_part = string.sub(name, 1, space_pos)
					local name_part = string.sub(name, space_pos + 1)
					
					if string.len(name_part) > max_name_length then
						name_part = string.sub(name_part, 1, max_name_length)
					end
					name = symbol_part .. name_part
				else
					if string.len(name) > max_name_length then
						name = string.sub(name, 1, max_name_length)
					end
				end
				
				local account_id = player_data.account_id
				local player_color = mod.get_player_color(account_id)
				if player_color then
					name = string.format("{#color(%d,%d,%d)}%s{#reset()}", player_color[1], player_color[2], player_color[3], name)
				end
				
				pass_template[k_pass_map[num_players]].value = name
				pass_template[d_pass_map[num_players]].value = ""
			end
		end
	elseif subheader then
		pass_template[1].value = ""
		for i = 1, 4 do
			if players[i] then
				pass_template[k_pass_map[i]].value = mod:localize("i18n_killsboard_kills")
				pass_template[d_pass_map[i]].value = mod:localize("i18n_killsboard_damage")
			else
				pass_template[k_pass_map[i]].value = ""
				pass_template[d_pass_map[i]].value = ""
			end
		end
	elseif group_header then
		local group_name = row_data.group_name or ""
		local localized_group_name = localize_group(group_name)
		pass_template[1].value = localized_group_name
		pass_template[1].style.text_horizontal_alignment = "left"
		pass_template[1].style.offset[1] = left_offset + _settings.killsboard_category_text_offset -- + 10
		pass_template[1].style.text_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.default_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.hover_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.disabled_color = Color.terminal_text_body_sub_header(255, true)
		
		local player_num = 1
		for _, player_data in pairs(players) do
			if player_num <= 4 then
				local account_id = player_data.account_id
				local total_kills = 0
				local total_dmg = 0
				local total_killstreak_kills = 0
				local total_killstreak_dmg = 0
				
				for _, category_data in ipairs(categories) do
					local category_key = category_data[1]
					local category_group = category_data[3]
					
					if category_group == group_name then
						if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][category_key] then
							total_kills = total_kills + (mod.kills_by_category[account_id][category_key] or 0)
						elseif mod.saved_kills_by_category and mod.saved_kills_by_category[account_id] and mod.saved_kills_by_category[account_id][category_key] then
							total_kills = total_kills + (mod.saved_kills_by_category[account_id][category_key] or 0)
						end
						
						if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][category_key] then
							total_dmg = total_dmg + (mod.damage_by_category[account_id][category_key] or 0)
						elseif mod.saved_damage_by_category and mod.saved_damage_by_category[account_id] and mod.saved_damage_by_category[account_id][category_key] then
							total_dmg = total_dmg + (mod.saved_damage_by_category[account_id][category_key] or 0)
						end
						
						if mod.display_killstreak_kills_by_category and mod.display_killstreak_kills_by_category[account_id] and mod.display_killstreak_kills_by_category[account_id][category_key] then
							total_killstreak_kills = total_killstreak_kills + (mod.display_killstreak_kills_by_category[account_id][category_key] or 0)
						end
						
						if mod.display_killstreak_damage_by_category and mod.display_killstreak_damage_by_category[account_id] and mod.display_killstreak_damage_by_category[account_id][category_key] then
							total_killstreak_dmg = total_killstreak_dmg + (mod.display_killstreak_damage_by_category[account_id][category_key] or 0)
						end
					end
				end
				
				local show_killstreak_progress = mod:get("opt_show_killstreak_progress_in_killsboard") ~= false
				local show_category_totals = mod:get("opt_show_category_totals_in_group_header") ~= false
				local orange_color = mod.get_damage_color_string and mod.get_damage_color_string() or "{#color(255,183,44)}"
				local reset_color = "{#reset()}"
				local kills_text = ""
				if show_category_totals then
					kills_text = tostring(total_kills)
					if show_killstreak_progress and total_killstreak_kills > 0 then
						kills_text = kills_text .. " (" .. orange_color .. "+" .. tostring(total_killstreak_kills) .. reset_color .. ")"
					end
				end
				
				local dmg_text = ""
				if show_category_totals then
					dmg_text = mod.format_number and mod.format_number(total_dmg) or tostring(total_dmg)
					if show_killstreak_progress and total_killstreak_dmg > 0 then
						dmg_text = dmg_text .. " (" .. orange_color .. "+" .. (mod.format_number and mod.format_number(total_killstreak_dmg) or tostring(total_killstreak_dmg)) .. reset_color .. ")"
					end
				end
				
				pass_template[k_pass_map[player_num]].value = kills_text
				pass_template[d_pass_map[player_num]].value = dmg_text
				
				pass_template[k_pass_map[player_num]].style.visible = show_category_totals
				pass_template[d_pass_map[player_num]].style.visible = show_category_totals
				pass_template[background_pass_map[player_num]].style.visible = show_category_totals
			end
			player_num = player_num + 1
		end
	elseif total then
		local total_text = mod:localize("i18n_killsboard_total")
		pass_template[1].value = total_text
		pass_template[1].style.text_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.default_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.hover_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.disabled_color = Color.terminal_text_body_sub_header(255, true)
		pass_template[1].style.offset[1] = left_offset + _settings.killsboard_category_text_offset -- + 30
		local player_num = 1
		for _, player_data in pairs(players) do
			if player_num <= 4 then
				local account_id = player_data.account_id
				local total_kills = 0
				local total_dmg = 0
				local total_killstreak_kills = 0
				local total_killstreak_dmg = 0
				
				if mod.player_kills and mod.player_kills[account_id] then
					total_kills = mod.player_kills[account_id] or 0
				elseif mod.saved_player_kills and mod.saved_player_kills[account_id] then
					total_kills = mod.saved_player_kills[account_id] or 0
				end
				
				if mod.player_damage and mod.player_damage[account_id] then
					total_dmg = mod.player_damage[account_id] or 0
				elseif mod.saved_player_damage and mod.saved_player_damage[account_id] then
					total_dmg = mod.saved_player_damage[account_id] or 0
				end
				
				if mod.display_killstreak_kills_by_category and mod.display_killstreak_kills_by_category[account_id] then
					for _, kills in pairs(mod.display_killstreak_kills_by_category[account_id]) do
						total_killstreak_kills = total_killstreak_kills + (kills or 0)
					end
				end
				
				if mod.display_killstreak_damage_by_category and mod.display_killstreak_damage_by_category[account_id] then
					for _, damage in pairs(mod.display_killstreak_damage_by_category[account_id]) do
						total_killstreak_dmg = total_killstreak_dmg + (damage or 0)
					end
				end
				
			local show_killstreak_progress = mod:get("opt_show_killstreak_progress_in_killsboard") ~= false
			local orange_color = mod.get_damage_color_string and mod.get_damage_color_string() or "{#color(255,183,44)}"
			local reset_color = "{#reset()}"
			local kills_text = tostring(total_kills)
			if show_killstreak_progress and total_killstreak_kills > 0 then
				kills_text = kills_text .. " (" .. orange_color .. "+" .. tostring(total_killstreak_kills) .. reset_color .. ")"
			end
			
			local dmg_text = mod.format_number and mod.format_number(total_dmg) or tostring(total_dmg)
			if show_killstreak_progress and total_killstreak_dmg > 0 then
				dmg_text = dmg_text .. " (" .. orange_color .. "+" .. (mod.format_number and mod.format_number(total_killstreak_dmg) or tostring(total_killstreak_dmg)) .. reset_color .. ")"
			end
				
				pass_template[k_pass_map[player_num]].value = kills_text
				pass_template[d_pass_map[player_num]].value = dmg_text
				
				pass_template[k_pass_map[player_num]].style.visible = true
				pass_template[d_pass_map[player_num]].style.visible = true
				pass_template[background_pass_map[player_num]].style.visible = true
			end
			player_num = player_num + 1
		end
	elseif spacer then
		pass_template[1].value = ""
		for i = 1, 4 do
			pass_template[k_pass_map[i]].value = ""
			pass_template[d_pass_map[i]].value = ""
		end
	elseif no_data then
		local no_data_text = mod:localize("i18n_killsboard_no_data")
		pass_template[1].value = no_data_text
		pass_template[1].style.text_horizontal_alignment = _settings.killsboard_no_data_text_horizontal_alignment
		pass_template[1].style.text_vertical_alignment = _settings.killsboard_no_data_text_vertical_alignment
		pass_template[1].style.offset[1] = left_offset + _settings.killsboard_no_data_text_offset
		local no_data_text_color_func = _settings.killsboard_no_data_text_color_func or Color.terminal_text_body_sub_header
		local no_data_text_color = no_data_text_color_func(_settings.killsboard_no_data_text_color_alpha, true)
		pass_template[1].style.text_color = no_data_text_color
		pass_template[1].style.color = no_data_text_color
		pass_template[1].style.default_color = no_data_text_color
		pass_template[1].style.hover_color = no_data_text_color
		pass_template[1].style.disabled_color = no_data_text_color
		for i = 1, 4 do
			pass_template[k_pass_map[i]].value = ""
			pass_template[d_pass_map[i]].value = ""
			pass_template[k_pass_map[i]].style.visible = false
			pass_template[d_pass_map[i]].style.visible = false
			pass_template[background_pass_map[i]].style.visible = false
		end
		pass_template[14].style.visible = false
	else
		local category_key = row_data.key
		local category_label = row_data.label
		pass_template[1].value = category_label
		
		local player_num = 1
		for _, player_data in pairs(players) do
			if player_num <= 4 then
				local account_id = player_data.account_id
				local kills = 0
				local dmg = 0
				local killstreak_kills = 0
				local killstreak_dmg = 0
				
				if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][category_key] then
					kills = mod.kills_by_category[account_id][category_key] or 0
				elseif mod.saved_kills_by_category and mod.saved_kills_by_category[account_id] and mod.saved_kills_by_category[account_id][category_key] then
					kills = mod.saved_kills_by_category[account_id][category_key] or 0
				end
				
				if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][category_key] then
					dmg = mod.damage_by_category[account_id][category_key] or 0
				elseif mod.saved_damage_by_category and mod.saved_damage_by_category[account_id] and mod.saved_damage_by_category[account_id][category_key] then
					dmg = mod.saved_damage_by_category[account_id][category_key] or 0
				end
				
				if mod.display_killstreak_kills_by_category and mod.display_killstreak_kills_by_category[account_id] and mod.display_killstreak_kills_by_category[account_id][category_key] then
					killstreak_kills = mod.display_killstreak_kills_by_category[account_id][category_key] or 0
				end
				
				if mod.display_killstreak_damage_by_category and mod.display_killstreak_damage_by_category[account_id] and mod.display_killstreak_damage_by_category[account_id][category_key] then
					killstreak_dmg = mod.display_killstreak_damage_by_category[account_id][category_key] or 0
				end
				
				local show_killstreak_progress = mod:get("opt_show_killstreak_progress_in_killsboard") ~= false
				local orange_color = mod.get_damage_color_string and mod.get_damage_color_string() or "{#color(255,183,44)}"
				local reset_color = "{#reset()}"
				local kills_text = tostring(kills)
				if show_killstreak_progress and killstreak_kills > 0 then
					kills_text = kills_text .. " (" .. orange_color .. "+" .. tostring(killstreak_kills) .. reset_color .. ")"
				end
				
				local dmg_text = mod.format_number and mod.format_number(dmg) or tostring(dmg)
				if show_killstreak_progress and killstreak_dmg > 0 then
					dmg_text = dmg_text .. " (" .. orange_color .. "+" .. (mod.format_number and mod.format_number(killstreak_dmg) or tostring(killstreak_dmg)) .. reset_color .. ")"
				end
				
				pass_template[k_pass_map[player_num]].value = kills_text
				pass_template[d_pass_map[player_num]].value = dmg_text
				
				pass_template[k_pass_map[player_num]].style.visible = true
				pass_template[d_pass_map[player_num]].style.visible = true
				pass_template[background_pass_map[player_num]].style.visible = true
			end
			player_num = player_num + 1
		end
	end
	
	local total_column_width = _settings.killsboard_column_kills_width + _settings.killsboard_column_damage_width
	local row_color = nil
	
	if header then
		row_color = Color.black(_settings.killsboard_header_bg_alpha, true)
	elseif subheader then
		row_color = Color.black(_settings.killsboard_subheader_bg_alpha, true)
	elseif total then
		row_color = Color.black(_settings.killsboard_total_bg_alpha, true)
	elseif group_header then
		row_color = Color.black(_settings.killsboard_group_header_bg_alpha, true)
	elseif spacer then
		row_color = Color.black(_settings.killsboard_spacer_bg_alpha, true)
	elseif no_data then
		row_color = nil
	else
		local is_even_row = visible_rows % 2 == 0
		
		local color_dark_func = _settings.killsboard_row_color_dark_func or Color.black
		local color_light_func = _settings.killsboard_row_color_light_func or Color.black
		local color_dark = color_dark_func(_settings.killsboard_row_color_dark_alpha, true)
		local color_light = color_light_func(_settings.killsboard_row_color_light_alpha, true)
		
		local has_recent_kill = false
		if row_data.type == "data" and row_data.key then
			local category_key = row_data.key
			
			local highlight_my_killstreaks = mod:get("opt_highlight_my_killstreaks") ~= false
			local highlight_team_killstreaks = mod:get("opt_highlight_team_killstreaks") ~= false
			
			if (highlight_my_killstreaks or highlight_team_killstreaks) and mod.highlighted_categories_by_category and mod.highlighted_categories_by_category[category_key] then
				local local_account_id = nil
				if Managers and Managers.player then
					local local_player = Managers.player:local_player(1)
					if local_player then
						local_account_id = local_player:account_id() or local_player:name()
					end
				end
				
				for account_id, _ in pairs(mod.highlighted_categories_by_category[category_key]) do
					local is_local_player = (local_account_id and account_id == local_account_id)
					local should_check_highlight = (is_local_player and highlight_my_killstreaks) or (not is_local_player and highlight_team_killstreaks)
					
					if should_check_highlight then
						has_recent_kill = true
						break
					end
				end
			end
		end
		
		local base_row_color = is_even_row and color_dark or color_light
		row_color = has_recent_kill and Color.terminal_frame(_settings.killsboard_row_color_highlight_alpha, true) or base_row_color
	end
	
	if row_color and not no_data then
		pass_template[14].style.size[2] = row_height
		pass_template[14].style.visible = true
		pass_template[14].style.color = row_color
		pass_template[14].style.disabled_color = row_color
		pass_template[14].style.default_color = row_color
		pass_template[14].style.hover_color = row_color
		pass_template[14].style.offset[1] = left_offset

		local k1_start = left_offset + _settings.killsboard_column_header_width
		local d1_end = k1_start + total_column_width
		local center_k1_d1 = (k1_start + d1_end) / 2
		pass_template[4].style.size[2] = row_height
		pass_template[4].style.visible = true
		pass_template[4].style.color = row_color
		pass_template[4].style.disabled_color = row_color
		pass_template[4].style.default_color = row_color
		pass_template[4].style.hover_color = row_color
		pass_template[4].style.offset[1] = center_k1_d1 - (_settings.killsboard_column_player_bg_width / 2)

		local k2_start = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width
		local d2_end = k2_start + total_column_width
		local center_k2_d2 = (k2_start + d2_end) / 2
		pass_template[7].style.size[2] = row_height
		pass_template[7].style.visible = true
		pass_template[7].style.color = row_color
		pass_template[7].style.disabled_color = row_color
		pass_template[7].style.default_color = row_color
		pass_template[7].style.hover_color = row_color
		pass_template[7].style.offset[1] = center_k2_d2 - (_settings.killsboard_column_player_bg_width / 2)

		local k3_start = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 2
		local d3_end = k3_start + total_column_width
		local center_k3_d3 = (k3_start + d3_end) / 2
		pass_template[10].style.size[2] = row_height
		pass_template[10].style.visible = true
		pass_template[10].style.color = row_color
		pass_template[10].style.disabled_color = row_color
		pass_template[10].style.default_color = row_color
		pass_template[10].style.hover_color = row_color
		pass_template[10].style.offset[1] = center_k3_d3 - (_settings.killsboard_column_player_bg_width / 2)

		local k4_start = left_offset + _settings.killsboard_column_header_width + _settings.killsboard_column_player_width * 3
		local d4_end = k4_start + total_column_width
		local center_k4_d4 = (k4_start + d4_end) / 2
		pass_template[13].style.size[2] = row_height
		pass_template[13].style.visible = true
		pass_template[13].style.color = row_color
		pass_template[13].style.disabled_color = row_color
		pass_template[13].style.default_color = row_color
		pass_template[13].style.hover_color = row_color
		pass_template[13].style.offset[1] = center_k4_d4 - (_settings.killsboard_column_player_bg_width / 2)
	end
	
	size[2] = row_height
	
	local widget_definition = UIWidget.create_definition(pass_template, "killsboard_rows", nil, size)
	
	if widget_definition then
		widget = _obj[_create_widget_callback](_obj, name, widget_definition)
		widget.alpha_multiplier = 0
		widget.offset = {0, current_offset, 0}
		return widget, row_height
	end
end

mod.setup_killsboard_row_widgets = function(self, row_widgets, widgets_by_name, loaded_players, _obj, _create_widget_callback, ui_renderer)
	local _settings = KillstreakWidgetSettings
	local current_offset = 0
	local visible_rows = 0
	local total_height = 0
	
	local players = loaded_players or get_players()
	
	local categories_to_show = {}
	local current_group = nil
	local show_enemy_list = mod:get("opt_show_enemy_list_in_groups") ~= false

	for _, data in ipairs(categories) do
		local key, label, group_name = data[1], data[2], data[3]
		local has_data = false
		
			for _, player_data in pairs(players) do
			if player_data and player_data.account_id then
				local account_id = player_data.account_id
				local kills = 0
				local dmg = 0
				
				if mod.kills_by_category and mod.kills_by_category[account_id] and mod.kills_by_category[account_id][key] then
					kills = mod.kills_by_category[account_id][key] or 0
				elseif mod.saved_kills_by_category and mod.saved_kills_by_category[account_id] and mod.saved_kills_by_category[account_id][key] then
					kills = mod.saved_kills_by_category[account_id][key] or 0
				end
				
				if mod.damage_by_category and mod.damage_by_category[account_id] and mod.damage_by_category[account_id][key] then
					dmg = mod.damage_by_category[account_id][key] or 0
				elseif mod.saved_damage_by_category and mod.saved_damage_by_category[account_id] and mod.saved_damage_by_category[account_id][key] then
					dmg = mod.saved_damage_by_category[account_id][key] or 0
				end
				
				if _settings.killsboard_show_empty_categories then
					has_data = true
					break
				else
					if kills > 0 or dmg > 0 then
						has_data = true
						break
					end
				end
			end
		end
		
		if has_data then
			if group_name and group_name ~= current_group then
				table.insert(categories_to_show, {type = "group_header", name = "group_" .. group_name, group_name = group_name})
				current_group = group_name
			end
			if show_enemy_list then
				table.insert(categories_to_show, {type = "data", key = key, label = localize_enemy(key, label)})
			end
		end
	end
	
	local has_data_rows = false
	for _, category_data in ipairs(categories_to_show) do
		if category_data.type == "data" or category_data.type == "group_header" then
			has_data_rows = true
			break
		end
	end
	
	local index = 1
	
	if not has_data_rows then
		local no_data_row = {type = "no_data", name = "no_data"}
		widget, row_height = self:create_killsboard_row_widget(index, current_offset + 80, visible_rows, no_data_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
		if widget then
			row_widgets = row_widgets or {}
			row_widgets[#row_widgets + 1] = widget
			widgets_by_name = widgets_by_name or {}
			widgets_by_name["killsboard_row_no_data"] = widget
			current_offset = current_offset + row_height
		end
		return row_widgets, current_offset
	end
	
	local header_row = {type = "header", name = "header"}
	widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, header_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets = row_widgets or {}
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name = widgets_by_name or {}
		widgets_by_name["killsboard_row_header"] = widget
		current_offset = current_offset + row_height
		visible_rows = visible_rows + 1
	end
	index = index + 1
	
	local subheader_row = {type = "subheader", name = "subheader"}
	widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, subheader_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name["killsboard_row_subheader"] = widget
		current_offset = current_offset + row_height
		visible_rows = visible_rows + 1
	end
	index = index + 1
	
	for _, category_data in ipairs(categories_to_show) do
		local row_data = category_data
		if not row_data.type then
			row_data.type = "data"
		end
		if not row_data.name then
			row_data.name = row_data.key or row_data.group_name or "unknown"
		end
		widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, row_data, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
		if widget then
			row_widgets[#row_widgets + 1] = widget
			widgets_by_name["killsboard_row_" .. row_data.name] = widget
			current_offset = current_offset + row_height
			if row_data.type == "data" then
				visible_rows = visible_rows + 1
			end
		end
		index = index + 1
	end
	
	local total_row = {type = "total", name = "total"}
	widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, total_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name["killsboard_row_total"] = widget
		current_offset = current_offset + row_height
	end
	index = index + 1
	
	local empty_row = {type = "spacer", name = "empty_after_total", bottom_offset = _settings.killsboard_rows_bottom_offset or 0}
	widget, row_height = self:create_killsboard_row_widget(index, current_offset, visible_rows, empty_row, widgets_by_name, players, _obj, _create_widget_callback, ui_renderer)
	if widget then
		row_widgets[#row_widgets + 1] = widget
		widgets_by_name["killsboard_row_empty_after_total"] = widget
		current_offset = current_offset + row_height
	end
	
	return row_widgets, current_offset
end

mod.adjust_killsboard_size = function(self, total_height, killsboard_widget, scenegraph, row_widgets)
	local _settings = KillstreakWidgetSettings
	local height = total_height + _settings.killsboard_rows_top_offset + _settings.killsboard_rows_bottom_offset
	height = math.max(height, _settings.killsboard_min_height)
	height = math.min(height, _settings.killsboard_max_height)
	
	local killsboard_graph = scenegraph.killsboard
	if killsboard_graph then
		killsboard_graph.size[2] = height
		killsboard_graph.dirty = true
	end
	
	local killsboard_rows_graph = scenegraph.killsboard_rows
	if killsboard_rows_graph then
		killsboard_rows_graph.size[2] = total_height
		killsboard_rows_graph.dirty = true
	end
end

mod.get_players_for_killsboard = get_players
