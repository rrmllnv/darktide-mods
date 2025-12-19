local mod = get_mod("CompassBar")

local hud_elements = {
	{
		filename = "CompassBar/scripts/mods/CompassBar/HudElementCompassBar",
		class_name = "HudElementCompassBar",
		visibility_groups = {
			"alive",
		},
	},
}

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
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

	
	-- Включаем оригинальный компас игры для сравнения
	-- if not table.find_by_key(elements, "class_name", "HudElementPlayerCompass") then
	-- 	table.insert(elements, {
	-- 		class_name = "HudElementPlayerCompass",
	-- 		filename = "scripts/ui/hud/elements/player_compass/hud_element_player_compass",
	-- 		use_hud_scale = true,
	-- 		visibility_groups = {
	-- 			"alive",
	-- 		},
	-- 	})
	-- end

	return func(self, elements, visibility_groups, params)
end)

-- Обновляем размер при изменении настроек
mod.on_setting_changed = function(setting_id)
	if setting_id == "width" then
		-- Принудительно обновляем scenegraph для всех экземпляров элемента
		local hud = Managers.ui and Managers.ui._hud
		if hud then
			local elements = hud._elements
			for _, element in pairs(elements) do
				if element.__class_name == "HudElementCompassBar" then
					element._cached_width = nil
				end
			end
		end
	end
end
