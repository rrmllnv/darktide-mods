-- Все отслеживаемые типы пикапов с категорией, иконкой и дополнительными данными
local PICKUP_DATA = {
	-- Гранаты (обычные и экспедиционные) → иконка из team panel HUD
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
	-- Медстанция
	health_station = {
		cat  = "medical",
		icon = "content/ui/materials/hud/interactions/icons/pocketable_medkit",
	},
	-- Медкейты (только pocketable — deployable сканируется отдельно)
	medical_crate_pocketable = {
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
		cat        = "ammo_small",
		icon       = "content/ui/materials/hud/icons/party_ammo",
		size_label = nil,
	},
	large_clip = {
		cat        = "ammo_small",
		icon       = "content/ui/materials/hud/icons/party_ammo",
		size_label = "big",
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

local CATEGORIES = { "medical", "medical_deployed", "stimm_corruption", "stimm_power", "stimm_speed", "stimm_ability", "ammo_small", "ammo_large", "grenade" }

local MED_DEPLOYED_ICON = "content/ui/materials/icons/pocketables/hud/small/party_medic_crate"

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
	elseif pickup_name == "medical_crate_deployable" then
		local ok, v = pcall(function()
			local ext = ScriptUnit.extension(unit, "proximity_system")

			if not ext then
				return nil
			end

			local has_job, logic = ext:has_job()

			if has_job and logic then
				local reserve = logic._heal_reserve
				local healed  = logic._amount_of_damage_healed or 0

				if reserve then
					return math.max(0, math.floor(reserve - healed))
				end
			end
		end)

		if ok and v and v > 0 then
			return v
		end
	end

	return nil
end

-- Проверяет что юнит является развёрнутым медицинским ящиком.
-- Используется двойная проверка: через deployable_type (owner/server)
-- или через _target_type SmartTagExtension (husk-клиенты).
local function _is_medical_deployed(unit, st_ext)
	-- Вариант 1: deployable_type установлен в local_init (server/owner)
	local ok1, dt = pcall(function()
		return Unit.get_data(unit, "deployable_type")
	end)

	if ok1 and dt == "medical_crate" then
		return true
	end

	-- Вариант 2: SmartTagExtension._target_type из husk_init
	if st_ext then
		local ok2, tt = pcall(function()
			return rawget(st_ext, "_target_type")
		end)

		if ok2 and tt == "medical_crate_deployable" then
			return true
		end
	end

	return false
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

	local radius_sq    = radius * radius
	local best_dist_sq = {}

	-- ── Первый проход: стандартные пикапы через InteracteeExtension ──────────────
	local ok, interactees = pcall(function()
		return extension_system:get_entities("InteracteeExtension")
	end)

	if ok and interactees then
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
							dist_m     = math.max(0, math.floor(math.sqrt(dist_sq) + 0.5)),
							icon       = pd.icon,
							stimm_id   = pd.stimm_id,
							size_label = pd.size_label,
							count      = _read_count(unit, pickup_name),
						}
							end
						end
					end
				end
			end
		end
	end

	-- ── Второй проход: развёрнутые медкейты через SmartTagExtension ──────────────
	-- У medical_crate_deployable нет InteracteeExtension, поэтому сканируем
	-- SmartTagExtension который добавляется и в local_init и в husk_init.
	local ok_st, smart_tags = pcall(function()
		return extension_system:get_entities("SmartTagExtension")
	end)

	if ok_st and smart_tags then
		local med_cat = "medical_deployed"

		for unit, st_ext in pairs(smart_tags) do
			if unit and Unit.alive(unit) and unit ~= player_unit then
				if _is_medical_deployed(unit, st_ext) then
					local upos = Unit.world_position(unit, 1)
					local dx = upos.x - player_pos.x
					local dy = upos.y - player_pos.y
					local dz = upos.z - player_pos.z
					local dist_sq = dx * dx + dy * dy + dz * dz

					if dist_sq <= radius_sq then
						if not best_dist_sq[med_cat] or dist_sq < best_dist_sq[med_cat] then
							best_dist_sq[med_cat] = dist_sq
							result[med_cat] = {
								dist_m   = math.max(0, math.floor(math.sqrt(dist_sq) + 0.5)),
								icon     = MED_DEPLOYED_ICON,
								stimm_id = nil,
								count    = _read_count(unit, "medical_crate_deployable"),
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
