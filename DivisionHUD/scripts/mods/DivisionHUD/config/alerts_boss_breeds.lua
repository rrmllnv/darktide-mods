local Breeds = require("scripts/settings/breed/breeds")

local CANDIDATE_BASE_BREED_IDS = {
	"chaos_beast_of_nurgle",
	"chaos_daemonhost",
	"chaos_mutator_daemonhost",
	"chaos_plague_ogryn",
	"chaos_spawn",
	"renegade_captain",
	"renegade_twin_captain",
}

local list = {}

for i = 1, #CANDIDATE_BASE_BREED_IDS do
	local breed_id = CANDIDATE_BASE_BREED_IDS[i]
	local breed = Breeds[breed_id]

	if breed and breed.is_boss then
		list[#list + 1] = breed_id
	end
end

table.sort(list)

return {
	list = list,
}
