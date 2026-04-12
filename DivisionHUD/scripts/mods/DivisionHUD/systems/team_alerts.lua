local mod = get_mod("DivisionHUD")

local AttackSettings = require("scripts/settings/damage/attack_settings")
local attack_results = AttackSettings.attack_results
local Breed = require("scripts/utilities/breed")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local HudElementCombatFeed = require("scripts/ui/hud/elements/combat_feed/hud_element_combat_feed")
local PlayerCharacterStateNetted = require("scripts/extension_systems/character_state_machine/character_states/player_character_state_netted")
local PlayerCharacterStatePounced = require("scripts/extension_systems/character_state_machine/character_states/player_character_state_pounced")

local already_reported = {}
local special_alert_cooldown_until = {}
local SPECIAL_ALERT_COOLDOWN_SEC = 2.5

local function division_team_alerts_settings_allow_net()
	local s = mod._settings
	local v = s and s.alerts_team_net

	if v == false or v == 0 then
		return false
	end

	return true
end

local function division_team_alerts_settings_allow_hound()
	local s = mod._settings
	local v = s and s.alerts_team_hound

	if v == false or v == 0 then
		return false
	end

	return true
end

local function division_team_alerts_consume_special_cooldown(key, gt)
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

local function division_team_alerts_resolve_human_teammate_unit(unit)
	if not unit then
		return nil, nil
	end

	local ude = ScriptUnit.has_extension(unit, "unit_data_system")

	if not ude then
		return nil, nil
	end

	local breed = ude:breed()

	if not Breed.is_player(breed) then
		return nil, nil
	end

	local player_unit_spawn_manager = Managers.state.player_unit_spawn
	local player = player_unit_spawn_manager and player_unit_spawn_manager:owner(unit)

	if not player then
		return nil, nil
	end

	local local_player = Managers.player and Managers.player:local_player(1)

	if player == local_player then
		return nil, nil
	end

	return player, player:name()
end

local function division_team_alerts_enqueue_strip_for_unit(unit, suffix_key, default_suffix_en)
	if not mod.alerts_enqueue_strip_body then
		return
	end

	local attacked_player, player_name = division_team_alerts_resolve_human_teammate_unit(unit)

	if not attacked_player or type(player_name) ~= "string" or player_name == "" then
		return
	end

	local gt = division_team_alerts_gameplay_time()

	if type(gt) ~= "number" or gt ~= gt then
		return
	end

	local victim_display = HudElementCombatFeed._get_unit_presentation_name(HudElementCombatFeed, unit)

	if type(victim_display) ~= "string" or victim_display == "" then
		victim_display = player_name
	end

	local suffix = mod:localize(suffix_key)

	if type(suffix) ~= "string" or suffix == "" or string.find(suffix, "^<unlocalized") then
		suffix = default_suffix_en
	end

	local body = victim_display .. " " .. suffix
	local strip = mod:localize("alerts_team_strip")

	if type(strip) ~= "string" or strip == "" or string.find(strip, "^<unlocalized") then
		strip = "Team"
	end

	mod.alerts_enqueue_strip_body(strip, body, gt, "team")
end

local function division_team_alerts_settings_allow_death()
	local s = mod._settings
	local v = s and s.alerts_team_death

	if v == false or v == 0 then
		return false
	end

	return true
end

local function division_team_alerts_settings_allow_knock()
	local s = mod._settings
	local v = s and s.alerts_team_knock

	if v == false or v == 0 then
		return false
	end

	return true
end

local function division_team_alerts_gameplay_time()
	local Hu = mod.hud_utils

	if Hu and type(Hu.safe_gameplay_time) == "function" then
		return Hu.safe_gameplay_time()
	end

	return nil
end

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

	local killed_unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
	local killed_breed_or_nil = killed_unit_data_extension and killed_unit_data_extension:breed()
	local killed_is_player = Breed.is_player(killed_breed_or_nil)

	if not killed_is_player then
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

	local killed_character_state_component = killed_unit_data_extension:read_component("character_state")
	local killed_is_dead = PlayerUnitStatus.is_dead(killed_character_state_component)
	local player_name = attacked_player:name()

	if already_reported[player_name] == killed_is_dead then
		return
	end

	already_reported[player_name] = killed_is_dead

	Promise.delay(0.1):next(function()
		local function division_team_alerts_abort_pending_report()
			already_reported[player_name] = nil
		end

		if not ScriptUnit.has_extension(attacked_unit, "unit_data_system") then
			division_team_alerts_abort_pending_report()

			return
		end

		local ude = ScriptUnit.extension(attacked_unit, "unit_data_system")
		local csc = ude and ude:read_component("character_state")

		if not csc then
			division_team_alerts_abort_pending_report()

			return
		end

		local is_dead = PlayerUnitStatus.is_dead(csc)
		local is_knocked = PlayerUnitStatus.is_knocked_down(csc)

		if is_dead and not division_team_alerts_settings_allow_death() then
			division_team_alerts_abort_pending_report()

			return
		end

		if not is_dead and is_knocked and not division_team_alerts_settings_allow_knock() then
			division_team_alerts_abort_pending_report()

			return
		end

		if not is_dead and not is_knocked then
			division_team_alerts_abort_pending_report()

			return
		end

		local gt = division_team_alerts_gameplay_time()

		if type(gt) ~= "number" or gt ~= gt then
			division_team_alerts_abort_pending_report()

			return
		end

		local suffix_key = is_dead and "alerts_team_suffix_death" or "alerts_team_suffix_knock"
		local default_suf = is_dead and "died" or "knocked down"

		local victim_display = HudElementCombatFeed._get_unit_presentation_name(HudElementCombatFeed, attacked_unit)

		if type(victim_display) ~= "string" or victim_display == "" then
			victim_display = attacked_player:name()
		end

		local suffix = mod:localize(suffix_key)

		if type(suffix) ~= "string" or suffix == "" or string.find(suffix, "^<unlocalized") then
			suffix = default_suf
		end

		local body = victim_display .. " " .. suffix
		local strip = mod:localize("alerts_team_strip")

		if type(strip) ~= "string" or strip == "" or string.find(strip, "^<unlocalized") then
			strip = "Team"
		end

		mod.alerts_enqueue_strip_body(strip, body, gt, "team")

		Promise.delay(5):next(function()
			if already_reported[player_name] == killed_is_dead then
				already_reported[player_name] = nil
			end
		end)
	end)
end)

mod:hook_safe(PlayerCharacterStateNetted, "on_enter", function(self, unit, dt, t, previous_state, params)
	if not division_team_alerts_settings_allow_net() then
		return
	end

	local ude = unit and ScriptUnit.has_extension(unit, "unit_data_system") and ScriptUnit.extension(unit, "unit_data_system")

	if not ude then
		return
	end

	local character_state_component = ude:read_component("character_state")
	local disabled_character_state_component = ude:read_component("disabled_character_state")
	local net_ok = character_state_component and character_state_component.state_name == "netted"

	if not net_ok and disabled_character_state_component then
		net_ok = PlayerUnitStatus.is_netted(disabled_character_state_component)
	end

	if not net_ok then
		return
	end

	local _, player_name = division_team_alerts_resolve_human_teammate_unit(unit)

	if type(player_name) ~= "string" or player_name == "" then
		return
	end

	local gt = division_team_alerts_gameplay_time()

	if not division_team_alerts_consume_special_cooldown("team_net:" .. player_name, gt) then
		return
	end

	division_team_alerts_enqueue_strip_for_unit(unit, "alerts_team_suffix_trapper_net", "caught in a trapper net")
end)

mod:hook_safe(PlayerCharacterStatePounced, "on_enter", function(self, unit, dt, t, previous_state, params)
	if not division_team_alerts_settings_allow_hound() then
		return
	end

	local attacked_player, player_name = division_team_alerts_resolve_human_teammate_unit(unit)

	if not attacked_player or type(player_name) ~= "string" or player_name == "" then
		return
	end

	Promise.delay(0.05):next(function()
		if not unit or not ALIVE[unit] then
			return
		end

		local ude = ScriptUnit.has_extension(unit, "unit_data_system") and ScriptUnit.extension(unit, "unit_data_system")

		if not ude then
			return
		end

		local character_state_component = ude:read_component("character_state")
		local disabled_character_state_component = ude:read_component("disabled_character_state")
		local pounce_ok = character_state_component and character_state_component.state_name == "pounced"

		if not pounce_ok and disabled_character_state_component then
			pounce_ok = PlayerUnitStatus.is_pounced(disabled_character_state_component)
		end

		if not pounce_ok then
			return
		end

		local gt = division_team_alerts_gameplay_time()

		if not division_team_alerts_consume_special_cooldown("team_pounce:" .. player_name, gt) then
			return
		end

		division_team_alerts_enqueue_strip_for_unit(unit, "alerts_team_suffix_hound_pounce", "pinned by a Pox Hound")
	end)
end)
