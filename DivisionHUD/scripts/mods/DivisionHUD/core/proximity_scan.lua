-- Все отслеживаемые типы пикапов с категорией, иконкой и дополнительными данными
local PICKUP_DATA = {
	-- Гранаты (обычные и экспедиционные)
	small_grenade = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/interactions/icons/grenade",
	},
	expedition_grenade_airstrike_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/interactions/icons/grenade",
	},
	expedition_grenade_artillery_strike_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/interactions/icons/grenade",
	},
	expedition_grenade_big_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/interactions/icons/grenade",
	},
	expedition_grenade_valkyrie_hover_pocketable = {
		cat  = "grenade",
		icon = "content/ui/materials/hud/interactions/icons/grenade",
	},
	-- Медстанция
	health_station = {
		cat  = "medical",
		icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
	},
	-- Медкейты
	medical_crate_pocketable = {
		cat  = "medical",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	},
	medical_crate_deployable = {
		cat  = "medical",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
	},
	-- Стимуляторы — каждый тип в отдельный слот, цвет применяется в HUD по stimm_id
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
	-- Патронные клипы (маленький и большой) → иконка из командного HUD
	small_clip = {
		cat  = "ammo_small",
		icon = "content/ui/materials/hud/icons/party_ammo",
	},
	large_clip = {
		cat  = "ammo_small",
		icon = "content/ui/materials/hud/icons/party_ammo",
	},
	-- Ящики патронов (pocketable + deployable)
	ammo_cache_pocketable = {
		cat  = "ammo_large",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	},
	ammo_cache_deployable = {
		cat  = "ammo_large",
		icon = "content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
	},
}

local CATEGORIES = { "medical", "stimm_corruption", "stimm_power", "stimm_speed", "stimm_ability", "ammo_small", "ammo_large", "grenade" }

local function _pickup_name_for_unit(unit, ext)
	local pickup_name = Unit.get_data(unit, "pickup_type")

	if not pickup_name and ext and ext.interaction_type then
		local ok, itype = pcall(function()
			return ext:interaction_type()
		end)

		if ok and itype == "health_station" then
			pickup_name = "health_station"
		end
	end

	if pickup_name == "health_station" then
		local hs_ok, hs_ext = pcall(function()
			return ScriptUnit.extension(unit, "health_station_system")
		end)

		if hs_ok and hs_ext and hs_ext.charge_amount then
			local charges_ok, charges = pcall(function()
				return hs_ext:charge_amount()
			end)

			if not charges_ok or not charges or charges <= 0 then
				return nil
			end
		end
	end

	return pickup_name
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

	local extension_system = Managers.state and Managers.state.extension

	if not extension_system then
		return result
	end

	local ok, interactees = pcall(function()
		return extension_system:get_entities("InteracteeExtension")
	end)

	if not ok or not interactees then
		return result
	end

	local radius_sq   = radius * radius
	local best_dist_sq = {}

	for unit, ext in pairs(interactees) do
		if unit and Unit.alive(unit) then
			local pickup_name = _pickup_name_for_unit(unit, ext)

			if pickup_name then
				local pd = PICKUP_DATA[pickup_name]

				if pd then
					local upos = Unit.world_position(unit, 1)
					local dx = upos.x - player_pos.x
					local dy = upos.y - player_pos.y
					local dz = upos.z - player_pos.z
					local dist_sq = dx * dx + dy * dy + dz * dz
					local cat = pd.cat

					if dist_sq <= radius_sq then
						if not best_dist_sq[cat] or dist_sq < best_dist_sq[cat] then
							best_dist_sq[cat] = dist_sq
							result[cat] = {
								dist_m   = math.max(0, math.floor(math.sqrt(dist_sq) + 0.5)),
								icon     = pd.icon,
								stimm_id = pd.stimm_id,
							}
						end
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
