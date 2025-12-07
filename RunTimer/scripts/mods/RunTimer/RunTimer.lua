local mod = get_mod("RunTimer")

local hud_elements = {
	{
		filename = "RunTimer/scripts/mods/RunTimer/HudElementRunTimer",
		class_name = "HudElementRunTimer",
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

	return func(self, elements, visibility_groups, params)
end)

-- Переменная для хранения времени окончания intro
mod._intro_end_time = nil

-- Хук на init системы - проверяем есть ли intro вообще
mod:hook_safe("CinematicSceneSystem", "init", function(self, extension_init_context, system_init_data)
	-- Проверяем что мы на миссии, а не в хабе
	local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
	local is_in_hub = not game_mode_name or game_mode_name == "hub"
	
	if is_in_hub then
		return
	end
	
	if self._skip_intro_cinematic then
		-- Если intro пропущен (нет в миссии) - устанавливаем 0
		mod._intro_end_time = 0
	else
		-- Intro есть, ждем его окончания
		mod._intro_end_time = nil
	end
end)

-- Хук на update CinematicManager - ловим момент окончания intro
mod:hook("CinematicManager", "update", function(func, self, dt, t)
	local story = self._active_story
	
	-- Проверяем что это intro на миссии
	if story and story.cinematic_scene_name == "intro_abc" then
		-- Проверяем что мы на миссии, а не в хабе
		local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
		local is_in_hub = not game_mode_name or game_mode_name == "hub"
		
		if not is_in_hub then
			local story_id = story.story_id
			local story_time = self._storyteller:time(story_id)
			local length = self._storyteller:length(story_id)
			local story_done = length < story_time
			
			-- Если intro ТОЛЬКО сейчас закончился
			if story_done and mod._intro_end_time == nil then
				if Managers.time and Managers.time:has_timer("gameplay") then
					mod._intro_end_time = Managers.time:time("gameplay")
				end
			end
		end
	end
	
	return func(self, dt, t)
end)

function mod.on_setting_changed(setting_id)
	if not mod._run_timer_hud_element then
		return
	end

	if setting_id == "font_size" or setting_id == "font_color" or setting_id == "opacity" then
		mod._run_timer_hud_element:_apply_style()
	elseif setting_id == "timer_position" then
		mod._run_timer_hud_element:_apply_layout()
	elseif setting_id == "timer_format" then
		-- Обновляем кэш формата
		mod._run_timer_hud_element._cached_timer_format = mod:get("timer_format") or 2
	elseif setting_id == "exclude_intro_time" then
		-- Обновляем кэш настройки intro
		mod._run_timer_hud_element._cached_exclude_intro = mod:get("exclude_intro_time") or 1
	end
end

