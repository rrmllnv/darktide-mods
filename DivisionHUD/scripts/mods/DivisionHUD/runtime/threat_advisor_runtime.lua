local mod = get_mod("DivisionHUD")

local Text = require("scripts/utilities/ui/text")
local UISettings = require("scripts/settings/ui/ui_settings")
local HudElementCombatFeed = require("scripts/ui/hud/elements/combat_feed/hud_element_combat_feed")

local DivisionHudModderToolsDisplay = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/runtime/modder_tools_display_runtime")

local previous_target_by_enemy = {}

local function _setting_enabled(key, fallback)
	local settings = mod._settings
	local value = settings and settings[key]

	if value == false or value == 0 then
		return false
	end

	if value == true or value == 1 then
		return true
	end

	return fallback
end

local function _is_alive_unit(unit)
	return unit and HEALTH_ALIVE[unit] and Unit.alive(unit)
end

local function _threat_target_change_alert_allowed_for_enemy(enemy_unit)
	if not enemy_unit or not Unit.alive(enemy_unit) then
		return false
	end

	if not ScriptUnit.has_extension(enemy_unit, "health_system") then
		return true
	end

	local health_ext = ScriptUnit.extension(enemy_unit, "health_system")

	if not health_ext then
		return true
	end

	if type(health_ext.is_alive) == "function" then
		local ok_alive, alive = pcall(function()
			return health_ext:is_alive()
		end)

		if ok_alive and alive == false then
			return false
		end
	end

	if type(health_ext.health_depleted) == "function" then
		local ok_dep, depleted = pcall(function()
			return health_ext:health_depleted()
		end)

		if ok_dep and depleted == true then
			return false
		end
	end

	if type(health_ext.current_health_percent) == "function" then
		local ok_hp, hp = pcall(function()
			return health_ext:current_health_percent()
		end)

		if ok_hp and type(hp) == "number" and hp <= 0 then
			return false
		end
	end

	return true
end

local function _resolve_side_system()
	local extension_manager = Managers.state and Managers.state.extension

	return extension_manager and extension_manager:system("side_system") or nil
end

local function _resolve_perception_map()
	local extension_manager = Managers.state and Managers.state.extension
	local perception_system = extension_manager and extension_manager:system("perception_system")

	if not perception_system or type(perception_system.unit_to_extension_map) ~= "function" then
		return nil
	end

	local ok, map = pcall(function()
		return perception_system:unit_to_extension_map()
	end)

	if ok and type(map) == "table" then
		return map
	end

	return nil
end

local function _resolve_game_session()
	local game_session_manager = Managers.state and Managers.state.game_session

	if not game_session_manager or type(game_session_manager.game_session) ~= "function" then
		return nil
	end

	local ok, game_session = pcall(function()
		return game_session_manager:game_session()
	end)

	if ok then
		return game_session
	end

	return nil
end

local function _resolve_unit_spawner()
	return Managers.state and Managers.state.unit_spawner or nil
end

local function _is_enemy_side(player_unit, unit, side_system)
	if not side_system or not player_unit or not unit then
		return false
	end

	local player_side = side_system.side_by_unit[player_unit]
	local target_side = side_system.side_by_unit[unit]

	if not player_side or not target_side then
		return false
	end

	local enemy_side_names = player_side:relation_side_names("enemy")

	for i = 1, #enemy_side_names do
		if enemy_side_names[i] == target_side:name() then
			return true
		end
	end

	return false
end

local function _breed_for_unit(unit)
	local unit_data_extension = unit and ScriptUnit.has_extension(unit, "unit_data_system")

	return unit_data_extension and unit_data_extension:breed() or nil
end

local function _threat_type_for_breed(breed)
	if type(breed) ~= "table" then
		return nil
	end

	local tags = breed.tags or {}

	if tags.monster or breed.is_boss == true then
		return "monster"
	end

	return nil
end

local function _threat_type_allowed(threat_type)
	if threat_type == "monster" then
		return _setting_enabled("threat_advisor_show_monsters", true)
	end

	return false
end

local function _display_name_for_breed(breed)
	if type(breed) ~= "table" then
		return ""
	end

	local display_name = breed.display_name and Localize(breed.display_name) or ""

	if type(display_name) == "string" and display_name ~= "" and not string.find(display_name, "^<") then
		return display_name
	end

	return breed.name or ""
end

local function _player_for_unit(unit)
	local player_unit_spawn_manager = Managers.state and Managers.state.player_unit_spawn

	return player_unit_spawn_manager and player_unit_spawn_manager:owner(unit) or nil
end

local function _valid_player(player)
	if not player or player.__deleted then
		return false
	end

	local player_type = type(player)

	return player_type == "table" or player_type == "userdata"
end

local function _player_method_value(player, method_name)
	if not _valid_player(player) then
		return nil
	end

	local ok, value = pcall(function()
		return player[method_name](player)
	end)

	return ok and value or nil
end

local function _player_slot_color(player, unit)
	if unit and Unit.alive(unit) then
		local owner = _player_for_unit(unit)

		if _valid_player(owner) then
			player = owner
		end
	end

	local slot = _player_method_value(player, "slot")
	local colors = UISettings.player_slot_colors

	return slot and colors and colors[slot] or nil
end

local function _player_display_name(player, unit)
	if not _valid_player(player) then
		return ""
	end

	local original_name = _player_method_value(player, "name") or ""

	if type(original_name) ~= "string" then
		original_name = ""
	end

	if unit and Unit.alive(unit) then
		local from_feed = HudElementCombatFeed._get_unit_presentation_name(HudElementCombatFeed, unit)

		if type(from_feed) == "string" and from_feed ~= "" then
			if DivisionHudModderToolsDisplay and type(DivisionHudModderToolsDisplay.replace_in_player_text) == "function" then
				return DivisionHudModderToolsDisplay.replace_in_player_text(from_feed, player, original_name)
			end

			return from_feed
		end
	end

	if original_name == "" then
		return ""
	end

	local name = original_name

	if DivisionHudModderToolsDisplay and type(DivisionHudModderToolsDisplay.resolve_plain_player_name) == "function" then
		name = DivisionHudModderToolsDisplay.resolve_plain_player_name(name, player)
	end

	if type(name) ~= "string" or name == "" then
		return ""
	end

	local col = _player_slot_color(player, unit)

	if col then
		return Text.apply_color_to_text(name, col)
	end

	return name
end

local function _local_target_display_name(local_player, target_unit)
	local text = mod:localize("alerts_threat_target_you_label")

	if type(text) ~= "string" or text == "" or string.find(text, "^<unlocalized") then
		text = "you"
	end

	local col = _player_slot_color(local_player, target_unit)

	if col then
		return Text.apply_color_to_text(text, col)
	end

	return text
end

local function _player_identity_value(player, method_name)
	return _player_method_value(player, method_name)
end

local function _is_same_player(left, right)
	if left == right then
		return true
	end

	if not _valid_player(left) or not _valid_player(right) then
		return false
	end

	local left_account_id = _player_identity_value(left, "account_id")
	local right_account_id = _player_identity_value(right, "account_id")

	if left_account_id ~= nil and right_account_id ~= nil then
		return left_account_id == right_account_id
	end

	local left_unique_id = _player_identity_value(left, "unique_id")
	local right_unique_id = _player_identity_value(right, "unique_id")

	return left_unique_id ~= nil and right_unique_id ~= nil and left_unique_id == right_unique_id
end

local function _target_from_perception_extension(perception_extension)
	local perception_component = perception_extension and perception_extension._perception_component
	local target_unit = perception_component and perception_component.target_unit

	if _is_alive_unit(target_unit) then
		return target_unit
	end

	return nil
end

local function _target_from_game_object(enemy_unit, game_session, unit_spawner)
	if not enemy_unit or not game_session or not unit_spawner then
		return nil
	end

	local ok_game_object_id, game_object_id = pcall(function()
		return unit_spawner:game_object_id(enemy_unit)
	end)

	if not ok_game_object_id or not game_object_id then
		return nil
	end

	local ok_has_target_unit_id, has_target_unit_id = pcall(function()
		return GameSession.has_game_object_field(game_session, game_object_id, "target_unit_id")
	end)

	if not ok_has_target_unit_id or has_target_unit_id ~= true then
		return nil
	end

	local ok_target_unit_id, target_unit_id = pcall(function()
		return GameSession.game_object_field(game_session, game_object_id, "target_unit_id")
	end)

	if
		not ok_target_unit_id
		or not target_unit_id
		or target_unit_id == NetworkConstants.invalid_game_object_id
	then
		return nil
	end

	local ok_target_unit, target_unit = pcall(function()
		return unit_spawner:unit(target_unit_id)
	end)

	if ok_target_unit and _is_alive_unit(target_unit) then
		return target_unit
	end

	return nil
end

local function _target_for_enemy(enemy_unit, perception_map, game_session, unit_spawner)
	local target_unit = _target_from_game_object(enemy_unit, game_session, unit_spawner)

	if target_unit then
		return target_unit
	end

	return _target_from_perception_extension(perception_map and perception_map[enemy_unit])
end

local function scan(player_unit)
	if not _is_alive_unit(player_unit) then
		table.clear(previous_target_by_enemy)

		return {
			active = false,
			events = {},
		}
	end

	if not _setting_enabled("threat_advisor_show_monsters", true) then
		return {
			active = false,
			events = {},
		}
	end

	local perception_map = _resolve_perception_map()
	local side_system = _resolve_side_system()
	local game_session = _resolve_game_session()
	local unit_spawner = _resolve_unit_spawner()

	if not side_system then
		return {
			active = false,
			events = {},
		}
	end

	local local_player = Managers.player and Managers.player:local_player(1)
	local events = {}
	local side_by_unit = side_system.side_by_unit

	if type(side_by_unit) ~= "table" then
		return {
			active = false,
			events = {},
		}
	end

	for enemy_unit, _ in pairs(side_by_unit) do
		if not _is_alive_unit(enemy_unit) then
			previous_target_by_enemy[enemy_unit] = nil
		elseif not _is_enemy_side(player_unit, enemy_unit, side_system) then
			previous_target_by_enemy[enemy_unit] = nil
		else
			local target_unit = _target_for_enemy(enemy_unit, perception_map, game_session, unit_spawner)

			if not target_unit then
				previous_target_by_enemy[enemy_unit] = nil
			else
				local breed = _breed_for_unit(enemy_unit)
				local threat_type = _threat_type_for_breed(breed)

				if not _threat_type_allowed(threat_type) then
					previous_target_by_enemy[enemy_unit] = target_unit
				else
					local target_player = _player_for_unit(target_unit)

					if not target_player then
						previous_target_by_enemy[enemy_unit] = target_unit
					else
						local previous_target = previous_target_by_enemy[enemy_unit]

						if previous_target ~= nil and previous_target ~= target_unit then
							if _threat_target_change_alert_allowed_for_enemy(enemy_unit) then
								local target_is_local = local_player ~= nil and _is_same_player(target_player, local_player)
								local target_player_name = target_is_local and _local_target_display_name(target_player, target_unit) or _player_display_name(target_player, target_unit)

								events[#events + 1] = {
									enemy_unit = enemy_unit,
									target_unit = target_unit,
									threat_type = threat_type,
									enemy_name = _display_name_for_breed(breed),
									target_is_local = target_is_local,
									target_player_name = target_player_name,
								}
							end
						end

						previous_target_by_enemy[enemy_unit] = target_unit
					end
				end
			end
		end
	end

	return {
		active = #events > 0,
		events = events,
	}
end

local ThreatAdvisorRuntime = {
	scan = scan,
}

mod.threat_advisor_runtime = ThreatAdvisorRuntime

return ThreatAdvisorRuntime
