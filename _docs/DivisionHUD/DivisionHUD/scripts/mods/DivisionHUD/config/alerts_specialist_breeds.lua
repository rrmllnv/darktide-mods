local Breeds = require("scripts/settings/breed/breeds")

local mod = get_mod("DivisionHUD")
local SpecialistMergeCfg = mod:io_dofile("DivisionHUD/scripts/mods/DivisionHUD/config/alerts_specialist_merge")

local CANDIDATE_BREED_IDS = {
	"chaos_hound",
	"chaos_hound_mutator",
	"chaos_armored_hound",
	"renegade_sniper",
	"renegade_netgunner",
	"chaos_poxwalker_bomber",
	"cultist_mutant",
	"cultist_mutant_mutator",
	"cultist_grenadier",
	"renegade_grenadier",
}

local merge_groups = type(SpecialistMergeCfg) == "table" and type(SpecialistMergeCfg.groups) == "table" and SpecialistMergeCfg.groups or {}

local member_to_group = {}

for gi = 1, #merge_groups do
	local g = merge_groups[gi]

	if type(g) == "table" and type(g.members) == "table" and type(g.setting_id) == "string" and g.setting_id ~= "" then
		for mi = 1, #g.members do
			local m = g.members[mi]

			if type(m) == "string" and m ~= "" then
				member_to_group[m] = g
			end
		end
	end
end

local settings_rows = {}
local merge_setting_emitted = {}
local setting_id_by_stripped = {}
local merge_group_by_stripped = {}

for i = 1, #CANDIDATE_BREED_IDS do
	local breed_id = CANDIDATE_BREED_IDS[i]
	local breed = Breeds[breed_id]

	if breed and breed.tags and breed.tags.special and breed.is_boss ~= true then
		local mg = member_to_group[breed_id]

		if mg then
			merge_group_by_stripped[breed_id] = mg

			if not merge_setting_emitted[mg.setting_id] then
				merge_setting_emitted[mg.setting_id] = true
				settings_rows[#settings_rows + 1] = {
					kind = "merged",
					group = mg,
				}
			end

			setting_id_by_stripped[breed_id] = mg.setting_id
		else
			settings_rows[#settings_rows + 1] = {
				kind = "single",
				breed_id = breed_id,
			}
			setting_id_by_stripped[breed_id] = "alert_specialist_" .. breed_id
		end
	end
end

local M = {}

M.settings_rows = settings_rows

M.alert_setting_id_for_stripped = function(stripped_raw)
	if type(stripped_raw) ~= "string" or stripped_raw == "" then
		return nil
	end

	return setting_id_by_stripped[stripped_raw]
end

M.merge_group_for_stripped = function(stripped_raw)
	if type(stripped_raw) ~= "string" or stripped_raw == "" then
		return nil
	end

	return merge_group_by_stripped[stripped_raw]
end

return M
