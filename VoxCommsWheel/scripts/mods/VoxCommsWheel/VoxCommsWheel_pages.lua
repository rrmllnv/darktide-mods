local PAGE_CONFIGS = {
	page_1 = {
		id = "page_1",
		name_key = "loc_page_1",
		commands = {
			"yes",
			"no",
			"please",
			"sorry",
			"need_help",
			"take_this",
			"i_need_this",
			"daemonhost",
			"almost_there",
			"away_from_squad",
		}
	},
	page_2 = {
		id = "page_2",
		name_key = "loc_page_2",
		commands = {
			"follow_you",
			"follow_me",
			"cover_me",
			"coming_to_you",
			"waiting_for_you",
			"dont_fall_behind",
			"faster",
			"wait",
			"back",
		}
	},
}

local function get_page_config(page_number)
	return PAGE_CONFIGS["page_" .. page_number] or PAGE_CONFIGS["page_1"]
end

local function get_max_pages()
	local count = 0
	for _ in pairs(PAGE_CONFIGS) do
		count = count + 1
	end
	return count
end

return {
	PAGE_CONFIGS = PAGE_CONFIGS,
	get_page_config = get_page_config,
	get_max_pages = get_max_pages,
}

