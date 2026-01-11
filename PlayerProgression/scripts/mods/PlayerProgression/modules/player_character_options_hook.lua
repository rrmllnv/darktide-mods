local player_character_options_hook = {}

local VIEW_NAME = "player_progress_stats_view"

player_character_options_hook.setup = function(mod)
	-- Добавляем локализацию для кнопки
	mod:add_global_localize_strings({
		player_progression_inspect_button = {
			en = "Player Progression",
			ru = "Прогресс игрока",
		},
	})

	-- Хук для добавления кнопки в definitions
	mod:hook_require("scripts/ui/views/player_character_options_view/player_character_options_view_definitions", function(definitions)
		local UIWidget = require("scripts/managers/ui/ui_widget")
		local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
		
		local scenegraph_definitions = definitions.scenegraph_definition
		local widget_definitions = definitions.widget_definitions

		-- Пересчитываем позиции кнопок с учетом новой кнопки
		-- Кнопки имеют высоту 40, позиция указывает верхний край от bottom
		-- inspect_button: -145 (заканчивается на -105)
		-- invite_button: -95 (заканчивается на -55)
		-- player_progression_button: -55 (заканчивается на -15)
		-- close_button: -15 (заканчивается на 25)
		
		-- Сдвигаем close_button выше, чтобы освободить место для новой кнопки
		scenegraph_definitions.close_button.position[2] = -5
		
		-- Добавляем scenegraph для кнопки Player Progression (между invite_button и close_button)
		scenegraph_definitions.player_progression_button = {
			horizontal_alignment = "left",
			parent = "player_panel",
			vertical_alignment = "bottom",
			size = {
				380,
				40,
			},
			position = {
				60,
				-50,  -- Сразу после invite_button (которая заканчивается на -55)
				13,
			},
		}

		-- Добавляем виджет кнопки
		widget_definitions.player_progression_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button, "player_progression_button", {
			visible = true,
			original_text = Localize("player_progression_inspect_button"),
		})
		
		-- Обновляем анимации, чтобы новая кнопка тоже появлялась
		local animation_definitions = definitions.animations
		if animation_definitions and animation_definitions.on_enter then
			for _, animation in ipairs(animation_definitions.on_enter) do
				if animation.name == "fade_in_content" then
					-- Обновляем функцию анимации, чтобы включить новую кнопку
					local original_update = animation.update
					animation.update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
						if original_update then
							original_update(parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
						end
						
						local anim_progress = math.easeOutCubic(progress)
						local player_progression_button = widgets.player_progression_button
						if player_progression_button then
							player_progression_button.alpha_multiplier = anim_progress
						end
					end
				elseif animation.name == "init" then
					-- Обновляем функцию init, чтобы скрыть новую кнопку в начале
					local original_init = animation.init
					animation.init = function(parent, ui_scenegraph, scenegraph_definition, widgets, params)
						if original_init then
							original_init(parent, ui_scenegraph, scenegraph_definition, widgets, params)
						end
						
						local player_progression_button = widgets.player_progression_button
						if player_progression_button then
							player_progression_button.alpha_multiplier = 0
						end
					end
				end
			end
		end
		
		-- Обновляем анимацию on_exit
		if animation_definitions and animation_definitions.on_exit then
			for _, animation in ipairs(animation_definitions.on_exit) do
				if animation.name == "fade_out_content" then
					local original_update = animation.update
					animation.update = function(parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
						if original_update then
							original_update(parent, ui_scenegraph, scenegraph_definition, widgets, progress, params)
						end
						
						local anim_progress = math.easeOutCubic(1 - progress)
						local player_progression_button = widgets.player_progression_button
						if player_progression_button then
							player_progression_button.alpha_multiplier = anim_progress
						end
					end
				end
			end
		end
	end)

	-- Хук для добавления кнопки в список навигации и обработчика
	mod:hook("PlayerCharacterOptionsView", "_setup_buttons_interactions", function(func, self, ...)
		func(self, ...)

		local widgets_by_name = self._widgets_by_name
		local player_progression_button = widgets_by_name.player_progression_button

		if player_progression_button then
			-- Добавляем обработчик нажатия напрямую
			player_progression_button.content.hotspot.pressed_callback = function()
				-- Открываем PlayerProgression view с данными инспектируемого игрока
				local inspected_player = self._inspected_player
				if inspected_player and Managers and Managers.ui then
					Managers.ui:open_view(VIEW_NAME, nil, true, nil, nil, {
						inspected_player = inspected_player,
					})
				end
			end

			-- Добавляем кнопку в список навигации (между invite_button и close_button)
			local button_list = self._button_gamepad_navigation_list
			if button_list then
				-- Вставляем кнопку перед close_button (индекс 3)
				table.insert(button_list, 3, player_progression_button)
			end
		end
	end)
end

return player_character_options_hook
