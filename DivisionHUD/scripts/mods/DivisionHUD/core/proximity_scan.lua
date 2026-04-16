local PICKUP_DATA = {
	small_grenade = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/icons/party_throwable",
	},
	expedition_grenade_airstrike_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/icons/party_throwable",
	},
	expedition_grenade_artillery_strike_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/icons/party_throwable",
	},
	expedition_grenade_big_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/icons/party_throwable",
	},
	expedition_grenade_valkyrie_hover_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/icons/party_throwable",
	},
	health_station = {
		cat  = "medical_station",
		icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
	},
	medical_crate_pocketable = {
		cat  = "medical",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	},
	syringe_corruption_pocketable = {
		cat      = "stimm_corruption",
		icon     = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
		stimm_id = "syringe_corruption_pocketable",
	},
	syringe_power_boost_pocketable = {
		cat      = "stimm_power",
		icon     = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
		stimm_id = "syringe_power_boost_pocketable",
	},
	syringe_speed_boost_pocketable = {
		cat      = "stimm_speed",
		icon     = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
		stimm_id = "syringe_speed_boost_pocketable",
	},
	syringe_ability_boost_pocketable = {
		cat      = "stimm_ability",
		icon     = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
		stimm_id = "syringe_ability_boost_pocketable",
	},
	small_clip = {
		cat        = "ammo_small",
		icon       = "content/ui/materials/hud/icons/party_ammo",
		size_label = nil,
	},
	large_clip = {
		cat                = "ammo_large",
		icon               = "content/ui/materials/hud/icons/party_ammo",
		size_label_loc_key = "ammo_size_big",
	},
	grimoire = {
		cat  = "grimoire",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_grimoire",
	},
	tome = {
		cat  = "tome",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_scripture",
	},
	ammo_cache_pocketable = {
		cat  = "ammo_crate",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	},
	ammo_cache_deployable = {
		cat  = "ammo_crate",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	},
	large_ammunition_crate = {
		cat  = "ammo_crate",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	},
}

local CATEGORIES = { "medical_station", "medical", "medical_deployed", "stimm_corruption", "stimm_power", "stimm_speed", "stimm_ability", "ammo_small", "ammo_large", "ammo_crate", "grenade", "grimoire", "tome" }

local MED_DEPLOYED_ICON = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate"


local function _get_system(system_name)
	local ext_manager = Managers.state and Managers.state.extension

	if not ext_manager or not ext_manager.system then
		return nil
	end

	local ok, system = pcall(function()
		return ext_manager:system(system_name)
	end)

	if ok then
		return system
	end

	return nil
end

local function _get_system_map(system_name)
	local system = _get_system(system_name)

	if not system or not system.unit_to_extension_map then
		return nil
	end

	local ok, map = pcall(function()
		return system:unit_to_extension_map()
	end)

	if ok and type(map) == "table" then
		return map
	end

	return nil
end

local function _unit_data_string(unit, field)
	if not unit then
		return nil
	end

	local has = Unit.has_data(unit, field)

	if not has then
		return nil
	end

	local ok, v = pcall(Unit.get_data, unit, field)

	if ok and v ~= nil then
		return type(v) == "string" and string.lower(v) or v
	end

	return nil
end

local function _interactee_is_available(ext, player_unit)
	if ext.active then
		local ok, v = pcall(function() return ext:active() end)

		if ok and not v then
			return false
		end
	end

	if ext.used then
		local ok, v = pcall(function() return ext:used() end)

		if ok and v then
			return false
		end
	end

	if player_unit and ext.show_marker then
		local ok, v = pcall(function() return ext:show_marker(player_unit) end)

		if ok and not v then
			return false
		end
	end

	return true
end

local function _pickup_name_for_unit(unit, ext)
	local pickup_name = _unit_data_string(unit, "pickup_type")

	if not pickup_name then
		local ok, itype = pcall(function() return ext:interaction_type() end)

		if ok and itype == "health_station" then
			pickup_name = "health_station"
		end
	end

	if pickup_name == "health_station" then
		local ok, hs_ext = pcall(function()
			return ScriptUnit.extension(unit, "health_station_system")
		end)

		if ok and hs_ext and hs_ext.charge_amount then
			local ok2, charges = pcall(function() return hs_ext:charge_amount() end)

			if not ok2 or not charges or charges <= 0 then
				return nil
			end
		end
	end

	return pickup_name
end

local function _read_count(unit, pickup_name)
	if pickup_name == "health_station" then
		local ok, v = pcall(function()
			local ext = ScriptUnit.extension(unit, "health_station_system")

			return ext and ext.charge_amount and ext:charge_amount()
		end)

		if ok and v and v > 0 then
			return v
		end
	elseif pickup_name == "ammo_cache_deployable" then
		local ok, v = pcall(function()
			local gs   = Managers.state.game_session:game_session()
			local goid = Managers.state.unit_spawner:game_object_id(unit)

			return GameSession.game_object_field(gs, goid, "charges")
		end)

		if ok and v and v > 0 then
			return v
		end
	end

	return nil
end

local function _add_result(result, best_dist_sq, cat, dist_sq, dist_m, icon, stimm_id, size_label, size_label_loc_key, count, prox_icon_tint)
	if not best_dist_sq[cat] or dist_sq < best_dist_sq[cat] then
		best_dist_sq[cat] = dist_sq
		result[cat] = {
			dist_m             = dist_m,
			icon               = icon,
			stimm_id           = stimm_id,
			size_label         = size_label,
			size_label_loc_key = size_label_loc_key,
			count              = count,
			prox_icon_tint     = prox_icon_tint,
		}
	end
end

local function _dist_sq(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z

	return dx * dx + dy * dy + dz * dz
end

local function scan(player_unit, radius)
	local result = {}

	if not player_unit or not Unit.alive(player_unit) then
		return result
	end

	local player_pos = Unit.world_position(player_unit, 1)

	if not player_pos then
		return result
	end

	local radius_sq    = radius * radius
	local best_dist_sq = {}

	local interactee_map = _get_system_map("interactee_system")

	if interactee_map then
		for unit, ext in pairs(interactee_map) do
			if unit and Unit.alive(unit) and unit ~= player_unit then
				if _interactee_is_available(ext, player_unit) then
					local pickup_name = _pickup_name_for_unit(unit, ext)

					if pickup_name then
						local pd = PICKUP_DATA[pickup_name]

						if pd then
							local upos    = Unit.world_position(unit, 1)
							local dist_sq = _dist_sq(upos, player_pos)

							if dist_sq <= radius_sq then
								local prox_icon_tint = nil

								if pd.cat == "ammo_crate" and (pickup_name == "ammo_cache_deployable" or pickup_name == "large_ammunition_crate") then
									prox_icon_tint = "ammo_deployed"
								end

								_add_result(
									result, best_dist_sq, pd.cat, dist_sq,
									math.max(0, math.floor(math.sqrt(dist_sq) + 0.5)),
									pd.icon, pd.stimm_id, pd.size_label, pd.size_label_loc_key,
									_read_count(unit, pickup_name),
									prox_icon_tint
								)
							end
						end
					end
				end
			end
		end
	end

	local smart_tag_map = _get_system_map("smart_tag_system")

	if smart_tag_map then
		local med_cat = "medical_deployed"

		for unit, _ in pairs(smart_tag_map) do
			if unit and Unit.alive(unit) and unit ~= player_unit then
				local stt = _unit_data_string(unit, "smart_tag_target_type")
				local dt  = _unit_data_string(unit, "deployable_type")

				if stt == "medical_crate_deployable" or dt == "medical_crate" then
					local upos    = Unit.world_position(unit, 1)
					local dist_sq = _dist_sq(upos, player_pos)

					if dist_sq <= radius_sq then
						_add_result(
							result, best_dist_sq, med_cat, dist_sq,
							math.max(0, math.floor(math.sqrt(dist_sq) + 0.5)),
							MED_DEPLOYED_ICON, nil, nil, nil,
							nil,
							nil
						)
					end
				end
			end
		end
	end

	return result
end

return {
	scan       = scan,
	CATEGORIES = CATEGORIES,
}
