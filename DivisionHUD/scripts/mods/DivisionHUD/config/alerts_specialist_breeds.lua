local Breeds = require("scripts/settings/breed/breeds")

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

local list = {}

for i = 1, #CANDIDATE_BREED_IDS do
	local breed_id = CANDIDATE_BREED_IDS[i]
	local breed = Breeds[breed_id]

	if breed and breed.tags and breed.tags.special and breed.is_boss ~= true then
		list[#list + 1] = breed_id
	end
end

table.sort(list)

return {
	list = list,
}
