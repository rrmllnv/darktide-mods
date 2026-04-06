local function dynamic_hud_enabled(mod_ref, defaults_table)
	local settings = mod_ref._settings
	local v = settings and settings.dynamic_hud

	if v == false or v == 0 then
		return false
	end

	if v == true or v == 1 then
		return true
	end

	if type(defaults_table) ~= "table" then
		return false
	end

	local fb = defaults_table.dynamic_hud

	return fb ~= false and fb ~= 0
end

return {
	dynamic_hud_enabled = dynamic_hud_enabled,
}
