local Breeds = require("scripts/settings/breed/breeds")

local M = {}

function M.try_override(mod, breed_id)
	if type(breed_id) ~= "string" or breed_id == "" then
		return nil
	end

	local dmf_mod = rawget(_G, "get_mod") and get_mod("DMF")

	if not dmf_mod or type(dmf_mod.quick_localize) ~= "function" then
		return nil
	end

	local custom = dmf_mod.quick_localize(mod, "alerts_breed_title_override_" .. breed_id)

	if type(custom) == "string" and custom ~= "" then
		return custom
	end

	return nil
end

function M.resolve(mod, breed_id)
	local overridden = M.try_override(mod, breed_id)

	if overridden then
		return overridden
	end

	if type(breed_id) ~= "string" or breed_id == "" then
		return ""
	end

	local b = Breeds[breed_id]

	if b and type(b.display_name) == "string" and b.display_name ~= "" then
		local localized = Localize(b.display_name)

		if type(localized) == "string" and localized ~= "" then
			return localized
		end
	end

	return breed_id
end

return M
