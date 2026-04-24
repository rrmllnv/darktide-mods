local mod = get_mod("DivisionHUD")

local function divisionhud_insert_or_replace_element(element_pool, data)
	if type(element_pool) ~= "table" or type(data) ~= "table" then
		return
	end

	for i = 1, #element_pool do
		local element = element_pool[i]

		if type(element) == "table" and element.class_name == data.class_name then
			element_pool[i] = data

			return
		end
	end

	element_pool[#element_pool + 1] = data
end

local function add_or_replace_division_hud_elements(element_pool)
	local hud_elements = mod.divisionhud_hud_elements or {}

	for _, hud_element in ipairs(hud_elements) do
		divisionhud_insert_or_replace_element(element_pool, {
			class_name = hud_element.class_name,
			filename = hud_element.filename,
			use_hud_scale = true,
			visibility_groups = hud_element.visibility_groups or {
				"alive",
			},
		})
	end
end

mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_player", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_training_grounds", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_shooting_range", add_or_replace_division_hud_elements)
mod:hook_require("scripts/ui/hud/hud_elements_tutorial", add_or_replace_division_hud_elements)

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	local is_spectator_hud = params and params.renderer_name == "spectator_hud_ui_renderer"
	local hud_elements = mod.divisionhud_hud_elements or {}

	if not is_spectator_hud then
		for _, hud_element in ipairs(hud_elements) do
			if not table.find_by_key(elements, "class_name", hud_element.class_name) then
				table.insert(elements, {
					class_name = hud_element.class_name,
					filename = hud_element.filename,
					use_hud_scale = true,
					visibility_groups = hud_element.visibility_groups or {
						"alive",
					},
				})
			end
		end
	end

	return func(self, elements, visibility_groups, params)
end)

mod:hook("MechanismManager", "mechanism_data", function(func, self)
	return func(self)
end)

return mod
