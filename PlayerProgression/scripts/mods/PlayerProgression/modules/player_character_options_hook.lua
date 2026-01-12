local player_character_options_hook = {}

local VIEW_NAME = "player_progress_stats_view"

player_character_options_hook.setup = function(mod)
	mod:add_global_localize_strings({
		player_progression_inspect_button = {
			en = "Player Progression",
			ru = "Прогресс игрока",
		},
	})

	mod:hook_require("scripts/ui/views/player_character_options_view/player_character_options_view_definitions", function(definitions)
		local UIWidget = require("scripts/managers/ui/ui_widget")
		local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
		
		local scenegraph_definitions = definitions.scenegraph_definition
		local widget_definitions = definitions.widget_definitions

		scenegraph_definitions.close_button.position[2] = -5
		
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
				-50,
				13,
			},
		}

		widget_definitions.player_progression_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button, "player_progression_button", {
			visible = true,
			original_text = Localize("player_progression_inspect_button"),
		})
		
		local animation_definitions = definitions.animations
		if animation_definitions and animation_definitions.on_enter then
			for _, animation in ipairs(animation_definitions.on_enter) do
				if animation.name == "fade_in_content" then
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

	mod:hook("PlayerCharacterOptionsView", "_setup_buttons_interactions", function(func, self, ...)
		func(self, ...)

		local widgets_by_name = self._widgets_by_name
		local player_progression_button = widgets_by_name.player_progression_button

		if player_progression_button then
			player_progression_button.content.hotspot.pressed_callback = function()
				local inspected_player = self._inspected_player
				if inspected_player and Managers and Managers.ui then
					Managers.ui:open_view(VIEW_NAME, nil, true, nil, nil, {
						inspected_player = inspected_player,
					})
				end
			end

			local button_list = self._button_gamepad_navigation_list
			if button_list then
				table.insert(button_list, 3, player_progression_button)
			end
		end
	end)
end

return player_character_options_hook
