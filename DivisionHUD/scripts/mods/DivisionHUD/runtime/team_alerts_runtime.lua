local mod = get_mod("DivisionHUD")

if mod._divisionhud_team_alerts_hooked then
	return mod
end

mod._divisionhud_team_alerts_hooked = true

local AttackSettings = require("scripts/settings/damage/attack_settings")
local attack_results = AttackSettings.attack_results
local Breed = require("scripts/utilities/breed")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local HudElementCombatFeed = require("scripts/ui/hud/elements/combat_feed/hud_element_combat_feed")
local Text = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")

local DivisionHudModderToolsDisplay = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/modder_tools_display_runtime")

local already_reported = {}

local special_alert_cooldown_until = {}
local SPECIAL_ALERT_COOLDOWN_SEC = 2.5

local team_panel_handler_status_prev = {}

local function setting_enabled(setting_id)
	local s = mod._settings
	if type(s) ~= "table" then
		return false
	end

	local v = s[setting_id]
	if v == false or v == 0 then
		return false
	end

	return true
end

local function gameplay_time()
	local Hu = mod.hud_utils

	if Hu and type(Hu.safe_time_for_alerts) == "function" then
		local t1 = Hu.safe_time_for_alerts()
		if type(t1) == "number" and t1 == t1 then
			return t1
		end
	end

	if Hu and type(Hu.safe_gameplay_time) == "function" then
		local t2 = Hu.safe_gameplay_time()
		if type(t2) == "number" and t2 == t2 then
			return t2
		end
	end

	local tm = Managers and Managers.time
	if tm and type(tm.has_timer) == "function" and tm:has_timer("gameplay") and type(tm.time) == "function" then
		local ok, t3 = pcall(function()
			return tm:time("gameplay")
		end)

		if ok and type(t3) == "number" and t3 == t3 then
			return t3
		end
	end

	return nil
end

local function consume_cooldown(key, gt)
	if type(key) ~= "string" or key == "" then
		return false
	end

	if type(gt) ~= "number" or gt ~= gt then
		return false
	end

	local until_t = special_alert_cooldown_until[key]
	if until_t and type(until_t) == "number" and gt < until_t then
		return false
	end

	special_alert_cooldown_until[key] = gt + SPECIAL_ALERT_COOLDOWN_SEC
	return true
end

local function mod_localize_or_fallback(key, fallback_en)
	local s = mod:localize(key)
	if type(s) == "string" and s ~= "" and not string.find(s, "^<unlocalized") then
		return s
	end
	return fallback_en
end

local function player_identity_key(player)
	if type(player) ~= "table" then
		return "unknown"
	end

	local name_fn = player.name
	local nm = type(name_fn) == "function" and name_fn(player) or nil
	if type(nm) == "string" and nm ~= "" then
		return nm
	end

	local uid_fn = player.unique_id
	local uid = type(uid_fn) == "function" and uid_fn(player) or nil
	if uid ~= nil then
		return tostring(uid)
	end

	return tostring(player)
end

local function player_display_name(player, unit)
	if type(player) ~= "table" then
		return ""
	end

	local original_name = type(player.name) == "function" and player:name() or ""

	if type(original_name) ~= "string" then
		original_name = ""
	end

	local display_core = original_name

	if unit and Unit.alive(unit) then
		local from_feed = HudElementCombatFeed._get_unit_presentation_name(HudElementCombatFeed, unit)

		if type(from_feed) == "string" and from_feed ~= "" then
			display_core = from_feed
		end
	end

	if type(display_core) ~= "string" or display_core == "" then
		return ""
	end

	if DivisionHudModderToolsDisplay then
		if display_core == original_name then
			if type(DivisionHudModderToolsDisplay.resolve_plain_player_name) == "function" then
				display_core = DivisionHudModderToolsDisplay.resolve_plain_player_name(display_core, player)
			end
		else
			if type(DivisionHudModderToolsDisplay.replace_in_player_text) == "function" then
				display_core = DivisionHudModderToolsDisplay.replace_in_player_text(display_core, player, original_name)
			end
		end
	end

	if type(display_core) ~= "string" or display_core == "" then
		return ""
	end

	local slot_fn = player.slot
	local slot = type(slot_fn) == "function" and slot_fn(player)
	local colors = UISettings.player_slot_colors
	local col = slot and colors and colors[slot]

	if col then
		return Text.apply_color_to_text(display_core, col)
	end

	return display_core
end

local function enqueue_team_alert(player, unit, suffix_text, cooldown_key)
	if not mod.alerts_enqueue_strip_body then
		return false
	end

	local local_player = Managers.player and Managers.player:local_player(1)
	if player == local_player then
		return false
	end

	if type(suffix_text) ~= "string" or suffix_text == "" then
		return false
	end

	local gt = gameplay_time()
	if type(gt) ~= "number" or gt ~= gt then
		return false
	end

	if not consume_cooldown(cooldown_key, gt) then
		return false
	end

	local display = player_display_name(player, unit)
	if type(display) ~= "string" or display == "" then
		display = type(player.name) == "function" and player:name() or ""
	end
	if type(display) ~= "string" or display == "" then
		return false
	end

	local strip = mod:localize("alerts_team_strip")
	if type(strip) ~= "string" or strip == "" or string.find(strip, "^<unlocalized") then
		strip = "Team"
	end

	mod.alerts_enqueue_strip_body(strip, display .. " " .. suffix_text, gt, "team")
	return true
end

local function captive_status_token(unit)
	if not unit or not HEALTH_ALIVE[unit] then
		return nil
	end

	local he = ScriptUnit.has_extension(unit, "health_system") and ScriptUnit.extension(unit, "health_system")
	if not (he and he.is_alive and he:is_alive()) then
		return nil
	end

	local uds = ScriptUnit.has_extension(unit, "unit_data_system") and ScriptUnit.extension(unit, "unit_data_system")
	if not uds then
		return nil
	end

	local cs = uds:read_component("character_state")
	local ds = uds:read_component("disabled_character_state")
	local hogtied = cs and PlayerUnitStatus.is_hogtied(cs) or false
	local pounced = ds and PlayerUnitStatus.is_pounced(ds) or false
	local netted = ds and PlayerUnitStatus.is_netted(ds) or false
	local consumed = ds and PlayerUnitStatus.is_consumed(ds) or false
	local ledge_hanging = cs and PlayerUnitStatus.is_ledge_hanging(cs) or false

	if hogtied then
		return "hogtied"
	end
	if pounced then
		return "pounced"
	end
	if netted then
		return "netted"
	end
	if consumed then
		return "consumed"
	end
	if ledge_hanging then
		return "ledge_hanging"
	end

	return nil
end

local function on_team_panel_handler_post_update(handler)
	local allow_net = setting_enabled("alerts_team_net")
	local allow_hound = setting_enabled("alerts_team_hound")
	local allow_ledge = setting_enabled("alerts_team_ledge")
	local allow_consumed = setting_enabled("alerts_team_consumed")
	if not allow_net and not allow_hound and not allow_ledge and not allow_consumed then
		return
	end

	local arr = handler and handler._player_panels_array
	if type(arr) ~= "table" then
		return
	end

	local local_player = Managers.player and Managers.player:local_player(1)

	for i = 1, #arr do
		local data = arr[i]
		local player = type(data) == "table" and data.player

		if type(player) == "table" and player ~= local_player then
			local unit = player.player_unit
			local uid_fn = player.unique_id
			local uid = type(uid_fn) == "function" and uid_fn(player) or nil
			if uid == nil then
				uid = "name:" .. player_identity_key(player)
			end

			local prev_token = team_panel_handler_status_prev[uid]
			local cur_token = (unit and HEALTH_ALIVE[unit]) and captive_status_token(unit) or nil

			if allow_net and cur_token == "netted" and prev_token ~= "netted" then
				local suffix = mod_localize_or_fallback("alerts_team_suffix_trapper_net", "was ensnared by a Scab Trapper")
				local cd = "team_net:" .. player_identity_key(player)
				enqueue_team_alert(player, unit, suffix, cd)
			end

			if allow_hound and cur_token == "pounced" and prev_token ~= "pounced" then
				local suffix = mod_localize_or_fallback("alerts_team_suffix_hound_pounce", "was pinned by a Pox Hound")
				local cd = "team_pounce:" .. player_identity_key(player)
				enqueue_team_alert(player, unit, suffix, cd)
			end

			if allow_ledge and cur_token == "ledge_hanging" and prev_token ~= "ledge_hanging" then
				local suffix = mod_localize_or_fallback("alerts_team_suffix_ledge_hanging", "is hanging on a ledge, needs help")
				local cd = "team_ledge:" .. player_identity_key(player)
				enqueue_team_alert(player, unit, suffix, cd)
			end

			if allow_consumed and cur_token == "consumed" and prev_token ~= "consumed" then
				local suffix = mod_localize_or_fallback("alerts_team_suffix_consumed", "consumed by a Beast of Nurgle")
				local cd = "team_consumed:" .. player_identity_key(player)
				enqueue_team_alert(player, unit, suffix, cd)
			end

			team_panel_handler_status_prev[uid] = cur_token
		end
	end
end

mod:hook_safe("HudElementTeamPanelHandler", "update", function(self, dt, t, ui_renderer, render_settings, input_service)
	on_team_panel_handler_post_update(self)
end)

mod:hook_safe("AttackReportManager", "_process_attack_result", function(self, buffer_data)
	if not mod.alerts_enqueue_strip_body then
		return
	end

	if type(buffer_data) ~= "table" then
		return
	end

	local attacked_unit = buffer_data.attacked_unit
	local attack_result = buffer_data.attack_result
	if not attacked_unit then
		return
	end

	local ude_or_nil = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
	local killed_breed_or_nil = ude_or_nil and ude_or_nil:breed()
	if not Breed.is_player(killed_breed_or_nil) then
		return
	end

	local player_unit_spawn_manager = Managers.state.player_unit_spawn
	local attacked_player = player_unit_spawn_manager and player_unit_spawn_manager:owner(attacked_unit)
	if not attacked_player then
		return
	end

	local local_player = Managers.player and Managers.player:local_player(1)
	if attacked_player == local_player then
		return
	end

	local health_extension = ScriptUnit.extension(attacked_unit, "health_system")
	local killed_health_1 = health_extension and health_extension:current_health()
	if type(killed_health_1) ~= "number" or killed_health_1 ~= killed_health_1 then
		return
	end

	if not ((killed_health_1 == 0 or killed_health_1 > 600) and (attack_result == attack_results.knock_down or attack_result == attack_results.died or attack_result == attack_results.toughness_broken or attack_result == attack_results.blocked or attack_result == attack_results.toughness_absorbed_melee)) then
		return
	end

	local killed_character_state_component = ude_or_nil:read_component("character_state")
	local killed_is_dead = PlayerUnitStatus.is_dead(killed_character_state_component)
	local player_name = attacked_player:name()
	if already_reported[player_name] == killed_is_dead then
		return
	end

	already_reported[player_name] = killed_is_dead

	Promise.delay(0.1):next(function()
		local function abort()
			already_reported[player_name] = nil
		end

		if not ScriptUnit.has_extension(attacked_unit, "unit_data_system") then
			abort()
			return
		end

		local ude = ScriptUnit.extension(attacked_unit, "unit_data_system")
		local csc = ude and ude:read_component("character_state")
		if not csc then
			abort()
			return
		end

		local is_dead = PlayerUnitStatus.is_dead(csc)
		local is_knocked = PlayerUnitStatus.is_knocked_down(csc)

		if is_dead and not setting_enabled("alerts_team_death") then
			abort()
			return
		end

		if not is_dead and is_knocked and not setting_enabled("alerts_team_knock") then
			abort()
			return
		end

		if not is_dead and not is_knocked then
			abort()
			return
		end

		local suffix_key = is_dead and "alerts_team_suffix_death" or "alerts_team_suffix_knock"
		local default_suf = is_dead and "died" or "knocked down, needs help"
		local suffix = mod_localize_or_fallback(suffix_key, default_suf)
		local cd = "team_kd_death:" .. player_identity_key(attacked_player)
		enqueue_team_alert(attacked_player, attacked_unit, suffix, cd)

		Promise.delay(5):next(function()
			if already_reported[player_name] == killed_is_dead then
				already_reported[player_name] = nil
			end
		end)
	end)
end)

mod.team_alerts_wants_alerts_ui = function()
	return setting_enabled("alerts_team_net")
		or setting_enabled("alerts_team_hound")
		or setting_enabled("alerts_team_ledge")
		or setting_enabled("alerts_team_consumed")
		or setting_enabled("alerts_team_knock")
		or setting_enabled("alerts_team_death")
end

return mod
