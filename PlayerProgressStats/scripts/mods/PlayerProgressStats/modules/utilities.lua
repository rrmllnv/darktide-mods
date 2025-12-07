local utilities = {}

-- Форматирование числа с разделителем тысяч
utilities.format_number = function(number)
	local num = math.floor(number)
	if num < 1000 then
		return tostring(num)
	end

	local formatted = tostring(num)
	local k

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")

		if k == 0 then
			break
		end
	end

	return formatted
end

return utilities

