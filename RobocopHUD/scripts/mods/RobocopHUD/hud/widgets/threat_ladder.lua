local M = {}

local function _breed_name(entry)
	local breed = entry and entry.breed
	if type(breed) ~= "table" then
		return "unknown"
	end

	local display_name = breed.display_name and Localize(breed.display_name) or ""
	if type(display_name) == "string" and display_name ~= "" and not string.find(display_name, "^<") then
		return display_name
	end

	return breed.name or "unknown"
end

M.update = function(widget, top_threats, theme, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	local lines = {}
	lines[1] = "TOP THREATS"

	for i = 1, 20 do
		local e = top_threats and top_threats[i]
		local unit = e and e.unit

		if unit and Unit.alive(unit) then
			local dist = e.distance
			local name = _breed_name(e)
			local kind = e.threat_kind or "?"
			lines[#lines + 1] = string.format("%d) %s  [%s]  %.0fm", i, name, kind, dist or 0)
		end
	end

	widget.content.text = table.concat(lines, "\n")

	local c = widget.style.text.text_color
	local a = math.floor(255 * (opacity or 1) + 0.5)
	local tc = theme and theme.text

	if tc then
		c[1] = a
		c[2] = tc[2]
		c[3] = tc[3]
		c[4] = tc[4]
	else
		c[1] = a
	end

	widget.content.visible = true
	widget.dirty = true
end

return M

