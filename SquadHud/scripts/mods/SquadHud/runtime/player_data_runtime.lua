local mod = get_mod("SquadHud")

local PlayerCompositions = require("scripts/utilities/players/player_compositions")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local PlayerUnitVisualLoadout = require("scripts/extension_systems/visual_loadout/utilities/player_unit_visual_loadout")
local ProfileUtils = require("scripts/utilities/profile_utils")
local UISettings = require("scripts/settings/ui/ui_settings")

local M = {}

local COLOR_FALLBACK_SLOT = {
	180,
	160,
	160,
	160,
}
local PLATFORM_ICONS = {
	steam = "\238\129\171",
	xbox = "\238\129\172",
	psn = "\238\129\177",
	ps5 = "\238\129\177",
	unknown = "\238\129\175",
}
local PLATFORM_LABELS = {
	steam = "Steam",
	xbox = "Xbox",
	psn = "PlayStation",
	ps5 = "PlayStation",
	unknown = "Unknown",
}
local LUGGABLE_SLOT_NAME = "slot_luggable"

function M.player_slot(player)
	if type(player) == "table" and type(player.slot) == "function" then
		local ok, slot = pcall(function()
			return player:slot()
		end)

		if ok and type(slot) == "number" then
			return slot
		end
	end

	return 99
end

function M.player_unique_id(player)
	if type(player) == "table" and type(player.unique_id) == "function" then
		local ok, unique_id = pcall(function()
			return player:unique_id()
		end)

		if ok and unique_id ~= nil then
			return tostring(unique_id)
		end
	end

	return tostring(player)
end

function M.is_bot(player)
	if type(player) == "table" and type(player.is_human_controlled) == "function" then
		local ok, is_human_controlled = pcall(function()
			return player:is_human_controlled()
		end)

		if ok then
			return is_human_controlled ~= true
		end
	end

	return false
end

local function player_raw_unique_id(player)
	if type(player) == "table" and type(player.unique_id) == "function" then
		local ok, unique_id = pcall(function()
			return player:unique_id()
		end)

		if ok and unique_id ~= nil then
			return unique_id
		end
	end

	return player
end

local function is_same_player(left, right)
	if left == right then
		return true
	end

	if left == nil or right == nil then
		return false
	end

	return M.player_unique_id(left) == M.player_unique_id(right)
end

function M.sorted_squad_players(composition_name, output, local_player)
	table.clear(output)

	if type(composition_name) ~= "string" or composition_name == "" then
		return output
	end

	local players = PlayerCompositions.players(composition_name, {})

	for _, player in pairs(players) do
		output[#output + 1] = player
	end

	table.sort(output, function(a, b)
		local a_is_local = is_same_player(a, local_player)
		local b_is_local = is_same_player(b, local_player)

		if a_is_local ~= b_is_local then
			return not a_is_local
		end

		local slot_a = M.player_slot(a)
		local slot_b = M.player_slot(b)

		if slot_a == slot_b then
			return M.player_unique_id(a) < M.player_unique_id(b)
		end

		return slot_a < slot_b
	end)

	return output
end

function M.fixed_squad_slots(composition_name, output, scratch, local_player, max_players)
	table.clear(output)

	max_players = type(max_players) == "number" and math.max(1, math.floor(max_players)) or 4
	scratch = M.sorted_squad_players(composition_name, scratch or {}, local_player)

	local local_player_entry = nil
	local teammate_count = 0

	for i = 1, #scratch do
		local player = scratch[i]

		if is_same_player(player, local_player) then
			local_player_entry = player
		else
			teammate_count = teammate_count + 1
		end
	end

	if local_player_entry then
		local visible_teammate_count = math.min(teammate_count, max_players - 1)
		local slot_index = max_players - visible_teammate_count

		for i = 1, #scratch do
			local player = scratch[i]

			if not is_same_player(player, local_player) and slot_index < max_players then
				output[slot_index] = player
				slot_index = slot_index + 1
			end
		end

		output[max_players] = local_player_entry
	else
		local visible_player_count = math.min(#scratch, max_players)
		local slot_index = max_players - visible_player_count + 1

		for i = 1, #scratch do
			if slot_index <= max_players then
				output[slot_index] = scratch[i]
				slot_index = slot_index + 1
			end
		end
	end

	return output
end

function M.filtered_squad_slots(composition_name, output, scratch, local_player, max_players, display_mode)
	table.clear(output)

	max_players = type(max_players) == "number" and math.max(1, math.floor(max_players)) or 4

	if display_mode == "all" or display_mode == nil then
		return M.fixed_squad_slots(composition_name, output, scratch, local_player, max_players)
	end

	scratch = M.sorted_squad_players(composition_name, scratch or {}, local_player)

	if display_mode == "local" then
		for i = 1, #scratch do
			local player = scratch[i]

			if is_same_player(player, local_player) then
				output[max_players] = player

				break
			end
		end

		return output
	end

	if display_mode == "teammates" then
		local teammate_count = 0

		for i = 1, #scratch do
			if not is_same_player(scratch[i], local_player) then
				teammate_count = teammate_count + 1
			end
		end

		local visible_teammate_count = math.min(teammate_count, max_players)
		local slot_index = max_players - visible_teammate_count + 1

		for i = 1, #scratch do
			local player = scratch[i]

			if not is_same_player(player, local_player) and slot_index <= max_players then
				output[slot_index] = player
				slot_index = slot_index + 1
			end
		end

		return output
	end

	return M.fixed_squad_slots(composition_name, output, scratch, local_player, max_players)
end

function M.gameplay_hud_composition_name()
	local game_mode_manager = Managers.state and Managers.state.game_mode
	local hud_settings = game_mode_manager and game_mode_manager.hud_settings and game_mode_manager:hud_settings()

	return hud_settings and hud_settings.player_composition or nil
end

function M.strip_format_directives(text)
	if type(text) ~= "string" or text == "" then
		return text
	end

	text = string.gsub(text, "{#color%([^}]*%)}", "")
	text = string.gsub(text, "{#reset%(%)}", "")
	text = string.gsub(text, "{#size%([^}]*%)}", "")

	return text
end

function M.player_name(player)
	if M.is_bot(player) and type(player) == "table" and type(player.profile) == "function" then
		local ok_profile, profile = pcall(function()
			return player:profile()
		end)

		if ok_profile and type(profile) == "table" then
			local raw = profile.display_name or profile.name

			if type(raw) == "string" and raw ~= "" then
				return M.strip_format_directives(raw)
			end
		end
	end

	if type(player) == "table" and type(player.name) == "function" then
		local ok, name = pcall(function()
			return player:name()
		end)

		if ok and type(name) == "string" and name ~= "" then
			return M.strip_format_directives(name)
		end
	end

	return mod:localize("squadhud_empty_name")
end

local player_profile

local true_level_cache = mod:persistent_table("player_total_level_cache")
local true_level_queue = mod:persistent_table("player_total_level_queue")
local account_info_cache = mod:persistent_table("player_account_info_cache")
local presence_promises = {}
local account_presence_promises = {}
local true_level_promises = {}
local xp_settings = mod:persistent_table("player_total_level_xp_settings")

local function true_levels_from_progression(progression)
	local level_array = xp_settings.level_array
	local total_xp = xp_settings.total_xp
	local max_level = xp_settings.max_level

	if type(progression) ~= "table" or type(level_array) ~= "table" or type(total_xp) ~= "number" or type(max_level) ~= "number" then
		return nil
	end

	local current_level = progression.currentLevel
	local current_xp = progression.currentXp
	local current_xp_in_level = progression.currentXpInLevel
	local needed_xp_for_next = progression.neededXpForNextLevel

	if type(current_level) ~= "number" or type(current_xp) ~= "number" then
		return nil
	end

	local true_levels = {
		current_xp = current_xp,
		current_level = current_level,
	}

	if current_level < max_level then
		true_levels.xp_per_level = level_array[current_level + 1] - level_array[current_level]
		true_levels.remaining_xp = current_xp_in_level
		true_levels.needed_xp = needed_xp_for_next

		return true_levels
	end

	local xp_per_level = level_array[max_level] - level_array[max_level - 1]
	local xp_over_max_level = current_xp - total_xp
	local remaining_xp = xp_over_max_level % xp_per_level
	local additional_level = math.floor(xp_over_max_level / xp_per_level)
	local true_level = current_level + additional_level

	true_levels.xp_per_level = xp_per_level
	true_levels.remaining_xp = remaining_xp
	true_levels.needed_xp = xp_per_level - remaining_xp
	true_levels.additional_level = additional_level
	true_levels.true_level = true_level
	true_levels.prestige = math.floor(current_xp / total_xp)

	return true_levels
end

local function cache_total_level(character_id, progression)
	if not character_id or type(progression) ~= "table" then
		return
	end

	local true_levels = true_levels_from_progression(progression)

	if type(true_levels) == "table" then
		true_level_cache[character_id] = true_levels
	end
end

local function cached_true_levels(character_id)
	local true_levels = character_id and true_level_cache[character_id]

	if true_levels == nil then
		return nil
	end

	if type(true_levels) == "table" then
		return true_levels
	end

	true_level_cache[character_id] = nil

	return nil
end

local function fetch_xp_settings()
	if xp_settings.promise or xp_settings.level_array then
		return
	end

	local backend_interface = Managers.backend and Managers.backend.interfaces
	local progression_interface = backend_interface and backend_interface.progression

	if not progression_interface or type(progression_interface.get_xp_table) ~= "function" then
		return
	end

	local ok, promise = pcall(function()
		return progression_interface:get_xp_table("character")
	end)

	if not ok or not promise or type(promise.next) ~= "function" then
		return
	end

	xp_settings.promise = promise

	promise:next(function(xp_per_level_array)
		local max_level = type(xp_per_level_array) == "table" and #xp_per_level_array or 0

		if max_level > 1 then
			xp_settings.level_array = xp_per_level_array
			xp_settings.total_xp = xp_per_level_array[max_level]
			xp_settings.max_level = max_level

			for character_id, progression in pairs(true_level_queue) do
				cache_total_level(character_id, progression)
				true_level_queue[character_id] = nil
			end
		end

		xp_settings.promise = nil
	end):catch(function()
		xp_settings.promise = nil
	end)
end

local function queue_or_cache_total_level(character_id, progression)
	if not character_id or type(progression) ~= "table" then
		return
	end

	if not xp_settings.level_array then
		true_level_queue[character_id] = progression
		fetch_xp_settings()

		return
	end

	cache_total_level(character_id, progression)
end

local function fetch_player_total_level(character_id)
	if not character_id or true_level_promises[character_id] or cached_true_levels(character_id) then
		return
	end

	if not xp_settings.level_array then
		fetch_xp_settings()

		return
	end

	local backend_interface = Managers.backend and Managers.backend.interfaces
	local progression_interface = backend_interface and backend_interface.progression

	if not progression_interface or type(progression_interface.get_progression) ~= "function" then
		return
	end

	local ok, promise = pcall(function()
		return progression_interface:get_progression("character", character_id)
	end)

	if not ok or not promise or type(promise.next) ~= "function" then
		return
	end

	true_level_promises[character_id] = promise

	promise:next(function(progression)
		cache_total_level(character_id, progression)
		true_level_promises[character_id] = nil
	end):catch(function()
		true_level_promises[character_id] = nil
	end)
end

local function cache_total_level_from_presence_entry(presence_entry)
	local immaterium_entry = presence_entry and presence_entry._immaterium_entry
	local key_values = immaterium_entry and immaterium_entry.key_values
	local character_profile = key_values and key_values.character_profile
	local character_id = key_values and key_values.character_id and key_values.character_id.value

	if not character_profile or not character_profile.value or character_profile.value == "" or not character_id or cached_true_levels(character_id) then
		return
	end

	local ok, backend_profile_data = pcall(function()
		return ProfileUtils.process_backend_body(cjson.decode(character_profile.value))
	end)

	if ok and backend_profile_data and backend_profile_data.progression then
		queue_or_cache_total_level(character_id, backend_profile_data.progression)
	end
end

local function fetch_presence_total_level(account_id)
	if not account_id or presence_promises[account_id] or not Managers.presence or type(Managers.presence.get_presence) ~= "function" then
		return
	end

	local ok, promise = pcall(function()
		local _, presence_promise = Managers.presence:get_presence(account_id)

		return presence_promise
	end)

	if not ok or not promise or type(promise.next) ~= "function" then
		return
	end

	presence_promises[account_id] = promise

	promise:next(function(presence_entry)
		cache_total_level_from_presence_entry(presence_entry)
		presence_promises[account_id] = nil
	end):catch(function()
		presence_promises[account_id] = nil
	end)
end

local function player_account_id(player)
	if type(player) == "table" and type(player.account_id) == "function" then
		local ok, account_id = pcall(function()
			return player:account_id()
		end)

		if ok and account_id ~= nil then
			return account_id
		end
	end

	return nil
end

M.player_account_id = player_account_id

function M.apply_modder_tools_display_name(base_name, player)
	if type(base_name) ~= "string" or base_name == "" then
		return base_name
	end

	local get_mod_fn = rawget(_G, "get_mod")

	if type(get_mod_fn) ~= "function" then
		return base_name
	end

	local ok_modder, modder_tools = pcall(get_mod_fn, "ModderTools")

	if not ok_modder or not modder_tools or type(modder_tools.get_player_name) ~= "function" then
		return base_name
	end

	local ok_feature = pcall(function()
		return modder_tools:get("enable_random_names") == true
	end)

	if not ok_feature then
		return base_name
	end

	local cache_key = player_account_id(player)

	if cache_key == nil and type(modder_tools.player_name_cache_key) == "function" then
		local ok_key, resolved_key = pcall(function()
			return modder_tools.player_name_cache_key(player)
		end)

		if ok_key and resolved_key ~= nil then
			cache_key = resolved_key
		end
	end

	if cache_key == nil then
		cache_key = M.player_unique_id(player)
	end

	if cache_key == nil then
		return base_name
	end

	local ok_resolved, resolved = pcall(function()
		return modder_tools.get_player_name(cache_key, base_name)
	end)

	if ok_resolved and type(resolved) == "string" and resolved ~= "" then
		return resolved
	end

	return base_name
end

local function strip_platform_icons(text)
	if type(text) ~= "string" or text == "" then
		return text
	end

	for _, icon in pairs(PLATFORM_ICONS) do
		text = string.gsub(text, icon .. "%s*", "")
	end

	return text
end

local function account_name_is_unknown(account_name)
	if type(account_name) ~= "string" or account_name == "" then
		return true
	end

	local stripped = strip_platform_icons(account_name)

	return stripped == "N/A" or stripped == "[unknown]" or stripped == ""
end

local function fetch_account_presence(account_id)
	if not account_id or account_presence_promises[account_id] or not Managers.presence or type(Managers.presence.get_presence) ~= "function" then
		return
	end

	local ok, promise = pcall(function()
		local _, presence_promise = Managers.presence:get_presence(account_id)

		return presence_promise
	end)

	if not ok or not promise or type(promise.next) ~= "function" then
		return
	end

	account_presence_promises[account_id] = promise

	promise:next(function()
		account_presence_promises[account_id] = nil
	end):catch(function()
		account_presence_promises[account_id] = nil
	end)
end

local function player_info_for_account(account_id)
	local social_service = Managers.data_service and Managers.data_service.social

	if not account_id or not social_service or type(social_service.get_player_info_by_account_id) ~= "function" then
		return nil
	end

	local ok, player_info = pcall(function()
		return social_service:get_player_info_by_account_id(account_id)
	end)

	if ok and player_info then
		return player_info
	end

	return nil
end

local function player_info_value(player_info, method_name)
	if not player_info or type(player_info[method_name]) ~= "function" then
		return nil
	end

	local ok, value = pcall(function()
		return player_info[method_name](player_info)
	end)

	if ok and type(value) == "string" and value ~= "" then
		return value
	end

	return nil
end

function M.player_account_info(player)
	local account_id = player_account_id(player)

	if not account_id then
		return nil
	end

	local cache_key = tostring(account_id)
	local cached = account_info_cache[cache_key]

	if type(cached) == "table" and type(cached.account_name) == "string" and cached.account_name ~= "" then
		return cached
	end

	local player_info = player_info_for_account(account_id)

	if not player_info then
		fetch_account_presence(account_id)

		return nil
	end

	local account_name = player_info_value(player_info, "user_display_name")

	if account_name_is_unknown(account_name) then
		return nil
	end

	local platform = player_info_value(player_info, "platform") or "unknown"

	if not PLATFORM_ICONS[platform] then
		platform = "unknown"
	end

	local account_info = {
		account_name = strip_platform_icons(account_name),
		platform = platform,
		platform_icon = PLATFORM_ICONS[platform] or PLATFORM_ICONS.unknown,
		platform_label = PLATFORM_LABELS[platform] or PLATFORM_LABELS.unknown,
	}

	account_info_cache[cache_key] = account_info

	return account_info
end

function M.player_account_name(player)
	local account_info = M.player_account_info(player)

	return account_info and account_info.account_name or nil
end

function M.player_account_platform_icon(player)
	local account_info = M.player_account_info(player)

	return account_info and account_info.platform_icon or PLATFORM_ICONS.unknown
end

local function player_character_id(player, profile)
	if type(player) == "table" and type(player.character_id) == "function" then
		local ok, character_id = pcall(function()
			return player:character_id()
		end)

		if ok and character_id ~= nil then
			return character_id
		end
	end

	return profile and profile.character_id or nil
end

function M.player_total_level(player)
	local profile = player_profile(player)

	if not profile then
		return nil
	end

	local character_id = player_character_id(player, profile)
	local true_levels = cached_true_levels(character_id)

	if type(true_levels) == "table" then
		return true_levels.true_level or true_levels.current_level
	end

	fetch_presence_total_level(player_account_id(player))
	fetch_player_total_level(character_id)

	return nil
end

function M.player_unit(player)
	return type(player) == "table" and player.player_unit or nil
end

function player_profile(player)
	if type(player) == "table" and type(player.profile) == "function" then
		local ok, profile = pcall(function()
			return player:profile()
		end)

		if ok then
			return profile
		end
	end

	return nil
end

if not mod._squadhud_player_data_presence_entry_hooked and CLASS and CLASS.PresenceEntryImmaterium and type(mod.hook_safe) == "function" then
	mod._squadhud_player_data_presence_entry_hooked = true

	mod:hook_safe(CLASS.PresenceEntryImmaterium, "update_with", function(self, new_entry)
		cache_total_level_from_presence_entry({
			_immaterium_entry = new_entry,
		})
	end)
end

function M.archetype_icon(player)
	local profile = player_profile(player)
	local archetype = profile and profile.archetype
	local archetype_name = archetype and archetype.name
	local icons = UISettings.archetype_font_icon
	local icon = archetype_name and icons and icons[archetype_name]

	if type(icon) == "string" and icon ~= "" then
		return icon
	end

	local title = archetype and archetype.archetype_name and Localize(archetype.archetype_name) or ""

	if type(title) == "string" and title ~= "" then
		return string.sub(title, 1, 1)
	end

	return "?"
end

function M.slot_color(player)
	local slot = M.player_slot(player)

	return UISettings.player_slot_colors and UISettings.player_slot_colors[slot] or COLOR_FALLBACK_SLOT
end

function M.extensions_for_player(parent, player)
	local unit = M.player_unit(player)

	if not unit or not Unit.alive(unit) then
		return nil
	end

	if parent and type(parent.get_all_player_extensions) == "function" then
		local ok, extensions = pcall(function()
			return parent:get_all_player_extensions(player, {})
		end)

		if ok and type(extensions) == "table" then
			extensions.health = extensions.health or ScriptUnit.has_extension(unit, "health_system")
			extensions.toughness = extensions.toughness or ScriptUnit.has_extension(unit, "toughness_system")
			extensions.unit_data = extensions.unit_data or ScriptUnit.has_extension(unit, "unit_data_system")
			extensions.visual_loadout = extensions.visual_loadout or ScriptUnit.has_extension(unit, "visual_loadout_system")
			extensions.coherency = extensions.coherency or ScriptUnit.has_extension(unit, "coherency_system")
			extensions.interactee = extensions.interactee or ScriptUnit.has_extension(unit, "interactee_system")
			extensions.ability = extensions.ability or ScriptUnit.has_extension(unit, "ability_system")

			return extensions
		end
	end

	return {
		health = ScriptUnit.has_extension(unit, "health_system"),
		toughness = ScriptUnit.has_extension(unit, "toughness_system"),
		unit_data = ScriptUnit.has_extension(unit, "unit_data_system"),
		visual_loadout = ScriptUnit.has_extension(unit, "visual_loadout_system"),
		coherency = ScriptUnit.has_extension(unit, "coherency_system"),
		interactee = ScriptUnit.has_extension(unit, "interactee_system"),
		ability = ScriptUnit.has_extension(unit, "ability_system"),
	}
end

local function read_component(unit_data_extension, component_name)
	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return nil
	end

	local ok, component = pcall(function()
		return unit_data_extension:read_component(component_name)
	end)

	return ok and component or nil
end

local function is_luggable_wielded(unit_data_extension, visual_loadout_extension)
	local inventory_component = read_component(unit_data_extension, "inventory")

	if not inventory_component or not visual_loadout_extension then
		return false
	end

	local ok, slot_equipped = pcall(function()
		return PlayerUnitVisualLoadout.slot_equipped(inventory_component, visual_loadout_extension, LUGGABLE_SLOT_NAME)
	end)

	return ok and slot_equipped and inventory_component.wielded_slot == LUGGABLE_SLOT_NAME
end

function M.status_from_extensions(extensions)
	local unit_data_extension = extensions and extensions.unit_data
	local health_extension = extensions and extensions.health

	if not health_extension or type(health_extension.is_alive) ~= "function" or not health_extension:is_alive() then
		return "dead"
	end

	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return "alive"
	end

	local character_state_component = read_component(unit_data_extension, "character_state")
	local disabled_character_state_component = read_component(unit_data_extension, "disabled_character_state")

	if character_state_component and PlayerUnitStatus.is_hogtied(character_state_component) then
		return "hogtied"
	end

	if disabled_character_state_component and disabled_character_state_component.is_disabled then
		if PlayerUnitStatus.is_pounced(disabled_character_state_component) then
			return "pounced"
		end

		if PlayerUnitStatus.is_netted(disabled_character_state_component) then
			return "netted"
		end

		if PlayerUnitStatus.is_warp_grabbed(disabled_character_state_component) then
			return "warp_grabbed"
		end

		if PlayerUnitStatus.is_vortex_grabbed(disabled_character_state_component) then
			return "vortex_grabbed"
		end

		if PlayerUnitStatus.is_mutant_charged(disabled_character_state_component) then
			return "mutant_charged"
		end

		if PlayerUnitStatus.is_consumed(disabled_character_state_component) then
			return "consumed"
		end

		if PlayerUnitStatus.is_grabbed(disabled_character_state_component) then
			return "grabbed"
		end
	end

	if character_state_component and PlayerUnitStatus.is_knocked_down(character_state_component) then
		return "down"
	end

	if character_state_component and PlayerUnitStatus.is_ledge_hanging(character_state_component) then
		return "ledge_hanging"
	end

	local disabled = character_state_component and PlayerUnitStatus.is_disabled(character_state_component)

	if disabled or disabled_character_state_component and disabled_character_state_component.is_disabled then
		return "disabled"
	end

	if is_luggable_wielded(unit_data_extension, extensions.visual_loadout) then
		return "luggable"
	end

	return "alive"
end

function M.in_coherency_with_local_player(local_player, extensions)
	local coherency_extension = extensions and extensions.coherency
	local in_coherence_units = coherency_extension and coherency_extension:in_coherence_units()
	local player_unit_spawn = Managers.state and Managers.state.player_unit_spawn

	if not local_player or not in_coherence_units or not player_unit_spawn then
		return false
	end

	for unit, _ in pairs(in_coherence_units) do
		local owner = player_unit_spawn:owner(unit)

		if owner and owner == local_player then
			return true
		end
	end

	return false
end

function M.player_distance_text(local_player, player, extensions)
	if local_player == player then
		return ""
	end

	if M.in_coherency_with_local_player(local_player, extensions) then
		return ""
	end

	local local_unit = M.player_unit(local_player)
	local target_unit = M.player_unit(player)

	if local_unit and target_unit and Unit.alive(local_unit) and Unit.alive(target_unit) then
		local local_position = Unit.world_position(local_unit, 1)
		local target_position = Unit.world_position(target_unit, 1)
		local distance = Vector3.distance(local_position, target_position)
		local rounded_distance = math.min(999, math.floor(distance + 0.5))

		return string.format("%dм", rounded_distance)
	end

	return ""
end

function M.health_data(extensions, status)
	local health_extension = extensions and extensions.health

	if not health_extension then
		return 0, 0, 1
	end

	local max_health = health_extension:max_health() or 0
	local health_fraction = health_extension:current_health_percent() or 0
	local permanent_damage = health_extension:permanent_damage_taken() or 0
	local health_max_fraction = max_health > 0 and 1 - permanent_damage / max_health or 0
	local max_wounds = status == "down" and 1 or health_extension:max_wounds() or 1

	return math.clamp(health_fraction, 0, 1), math.clamp(health_max_fraction, 0, 1), math.max(1, math.min(10, max_wounds))
end

local function extension_number(extension, method_name)
	if not extension or type(extension[method_name]) ~= "function" then
		return nil
	end

	local ok, value = pcall(function()
		return extension[method_name](extension)
	end)

	return ok and type(value) == "number" and value or nil
end

local function value_text(value)
	if type(value) ~= "number" then
		return ""
	end

	return tostring(math.ceil(math.max(0, value)))
end

function M.health_value_text(extensions)
	return value_text(M.health_value(extensions))
end

function M.health_value(extensions)
	local health_extension = extensions and extensions.health
	local current_health = extension_number(health_extension, "current_health")

	if current_health == nil then
		local max_health = extension_number(health_extension, "max_health") or 0
		local health_fraction = extension_number(health_extension, "current_health_percent") or 0

		current_health = health_fraction * max_health
	end

	return current_health
end

local function player_ready_time_to_spawn(game_mode_manager, player)
	if game_mode_manager and type(game_mode_manager.player_time_until_spawn) == "function" then
		local ok, ready_time = pcall(function()
			return game_mode_manager:player_time_until_spawn(player)
		end)

		if ok and type(ready_time) == "number" and ready_time > 0 then
			return ready_time
		end
	end

	local game_mode = game_mode_manager and game_mode_manager._game_mode
	local players_respawn_time = game_mode and game_mode._players_respawn_time

	if type(players_respawn_time) ~= "table" then
		return nil
	end

	local unique_id = player_raw_unique_id(player)
	local ready_time = players_respawn_time[unique_id]

	if ready_time == nil and unique_id ~= nil then
		ready_time = players_respawn_time[tostring(unique_id)]
	end

	if type(ready_time) == "number" and ready_time > 0 then
		return ready_time
	end

	return nil
end

function M.rescue_timer_status(player, status)
	if status ~= "dead" then
		return {
			available = false,
			time_left = nil,
		}
	end

	local game_mode_manager = Managers.state and Managers.state.game_mode
	local time_manager = Managers.time
	local has_gameplay_timer = time_manager and type(time_manager.has_timer) == "function" and time_manager:has_timer("gameplay")
	local current_time = has_gameplay_timer and time_manager:time("gameplay") or nil
	local ready_time_to_spawn = player_ready_time_to_spawn(game_mode_manager, player)

	if ready_time_to_spawn and current_time then
		local time_left = math.max(0, ready_time_to_spawn - current_time)

		return {
			available = time_left == 0,
			time_left = time_left,
		}
	end

	return {
		available = false,
		time_left = nil,
	}
end

function M.toughness_fraction(extensions)
	local toughness_extension = extensions and extensions.toughness

	if not toughness_extension then
		return 0
	end

	if type(toughness_extension.current_toughness_percent_visual) == "function" then
		return math.clamp(toughness_extension:current_toughness_percent_visual() or 0, 0, 1)
	end

	return math.clamp(toughness_extension:current_toughness_percent() or 0, 0, 1)
end

function M.toughness_value_text(extensions, has_overshield)
	local values = M.toughness_values(extensions)

	if has_overshield and values.bonus > 0 then
		return value_text(values.normal)
	end

	return value_text(values.current)
end

function M.toughness_values(extensions)
	local toughness_extension = extensions and extensions.toughness
	local toughness_percentage = extension_number(toughness_extension, "current_toughness_percent") or 0
	local toughness_percentage_visual = extension_number(toughness_extension, "current_toughness_percent_visual") or toughness_percentage
	local max_toughness = extension_number(toughness_extension, "max_toughness") or 0
	local max_toughness_visual = extension_number(toughness_extension, "max_toughness_visual") or max_toughness

	if max_toughness <= 0 or max_toughness_visual <= 0 then
		return {
			bonus = 0,
			current = 0,
			normal = 0,
		}
	end

	local current_toughness = math.max(0, toughness_percentage * max_toughness)
	local current_toughness_visual = math.max(0, toughness_percentage * max_toughness_visual)
	local display_toughness = math.max(0, toughness_percentage_visual * max_toughness_visual)
	local overshield_amount = current_toughness_visual < max_toughness and math.max(current_toughness - max_toughness_visual, 0) or 0
	local has_overshield = math.floor(overshield_amount) > 0
	local normal_toughness = has_overshield and math.min(max_toughness_visual, current_toughness) or current_toughness

	return {
		bonus = overshield_amount,
		current = has_overshield and current_toughness or display_toughness,
		normal = normal_toughness,
	}
end

function M.has_overshield(extensions)
	local toughness_extension = extensions and extensions.toughness

	if not toughness_extension then
		return false
	end

	if type(toughness_extension.current_toughness_percent) ~= "function" or type(toughness_extension.max_toughness) ~= "function" or type(toughness_extension.max_toughness_visual) ~= "function" then
		return false
	end

	local toughness_percentage = toughness_extension:current_toughness_percent() or 0
	local max_toughness = toughness_extension:max_toughness() or 0
	local max_toughness_visual = toughness_extension:max_toughness_visual() or 0

	if max_toughness <= 0 or max_toughness_visual <= 0 then
		return false
	end

	local current_toughness = toughness_percentage * max_toughness
	local current_toughness_visual = toughness_percentage * max_toughness_visual
	local overshield_amount = current_toughness_visual < max_toughness and math.max(current_toughness - max_toughness_visual, 0) or 0

	return math.floor(overshield_amount) > 0
end

local function safe_read_component(unit_data_extension, component_name)
	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return nil
	end

	local ok, component = pcall(function()
		return unit_data_extension:read_component(component_name)
	end)

	return ok and component or nil
end

function M.revive_state(extensions)
	local unit_data_extension = extensions and extensions.unit_data

	if not unit_data_extension or type(unit_data_extension.read_component) ~= "function" then
		return {
			in_progress = false,
			progress = 0,
		}
	end

	local assisted_state_input = safe_read_component(unit_data_extension, "assisted_state_input")
	local in_progress = assisted_state_input and assisted_state_input.in_progress == true

	if not in_progress then
		return {
			in_progress = false,
			progress = 0,
		}
	end

	local interactee_component = safe_read_component(unit_data_extension, "interactee")
	local interactee_extension = extensions and extensions.interactee
	local interactor_unit = interactee_component and interactee_component.interactor_unit
	local duration = 0
	local progress = 0
	local exact_progress = false

	if interactee_extension and type(interactee_extension.interaction_length) == "function" then
		local ok, interaction_length = pcall(function()
			return interactee_extension:interaction_length()
		end)

		if ok and type(interaction_length) == "number" then
			duration = math.max(0, interaction_length)
		end
	end

	if interactor_unit and Unit.alive(interactor_unit) then
		local interactor_extension = ScriptUnit.has_extension(interactor_unit, "interactor_system")

		if interactor_extension and type(interactor_extension.interaction_progress) == "function" then
			local ok, interaction_progress = pcall(function()
				return interactor_extension:interaction_progress()
			end)

			if ok and type(interaction_progress) == "number" then
				progress = math.clamp(interaction_progress, 0, 1)
				exact_progress = true
			end
		end
	end

	return {
		duration = duration,
		exact_progress = exact_progress,
		in_progress = true,
		progress = progress,
	}
end

return M
