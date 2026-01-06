local mod = get_mod("ConsoleLog")

-- Глобальное хранилище логов
mod._logs = {}

-- API для других модов
mod.add_log = function(self, mod_name, text, color)
	if not mod_name or not text then
		return
	end
	
	local log_entry = {
		mod_name = mod_name,
		text = tostring(text),
		color = color or {255, 255, 255, 255},
		timestamp = Managers.time and Managers.time:time("main") or 0,
	}
	
	table.insert(mod._logs, log_entry)
	
	-- Ограничиваем количество логов
	local max_logs = mod:get("max_lines") or 20
	if #mod._logs > max_logs * 2 then
		-- Удаляем старые логи, оставляем только последние max_logs
		local start_index = #mod._logs - max_logs + 1
		local new_logs = {}
		for i = start_index, #mod._logs do
			table.insert(new_logs, mod._logs[i])
		end
		mod._logs = new_logs
	end
end

mod.clear_logs = function(self)
	mod._logs = {}
end

mod.set_enabled = function(self, enabled)
	mod:set("enabled", enabled)
end

-- Регистрация HUD элемента
local hud_elements = {
	{
		filename = "ConsoleLog/scripts/mods/ConsoleLog/HudElementConsoleLog",
		class_name = "HudElementConsoleLog",
		visibility_groups = {
			"alive",
			"communication_wheel",
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

	return func(self, elements, visibility_groups, params)
end)

-- Обработка изменения настроек
mod.on_setting_changed = function(setting_id)
	if setting_id == "max_lines" then
		-- Ограничиваем количество логов при изменении настройки
		local max_logs = mod:get("max_lines") or 20
		if #mod._logs > max_logs then
			local start_index = #mod._logs - max_logs + 1
			local new_logs = {}
			for i = start_index, #mod._logs do
				table.insert(new_logs, mod._logs[i])
			end
			mod._logs = new_logs
		end
	end
end

-- Выгрузка мода
mod.on_unload = function(exit_game)
	mod._logs = {}
end

