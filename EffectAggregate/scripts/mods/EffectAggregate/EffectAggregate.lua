local mod = get_mod("EffectAggregate")

-- Добавляем require для aggregatum_view и его зависимостей
mod:add_require_path("EffectAggregate/scripts/mods/EffectAggregate/Views/aggregatum_view")
mod:add_require_path("EffectAggregate/scripts/mods/EffectAggregate/Views/aggregatum_view_definitions")

-- Регистрация aggregatum_view
mod.on_all_mods_loaded = function()
	mod:register_view({
		view_name = "aggregatum_view",
		view_settings = {
			init_view_function = function(ingame_ui_context)
				return true
			end,
			class = "AggregatumView",
			disable_game_world = true,
			display_name = "loc_aggregatum_view_display_name",
			path = "EffectAggregate/scripts/mods/EffectAggregate/Views/aggregatum_view",
			state_bound = true,
			use_transition_ui = true,
			levels = {
				"content/levels/ui/cosmetics_preview/cosmetics_preview",
			},
		},
		view_transitions = {},
		view_options = {
			close_all = false,
			close_previous = false,
			close_transition_time = nil,
			transition_time = nil
		}
	})
	-- Загружаем файл view, чтобы класс был доступен
	mod:io_dofile("EffectAggregate/scripts/mods/EffectAggregate/Views/aggregatum_view")
end


-- Добавляем таб Aggregatum в меню inventory_background_view
mod:hook("InventoryBackgroundView", "_setup_top_panel", function(func, self)
	func(self)
	
	-- Добавляем наш таб в _views_settings после создания всех табов, но перед созданием меню
	if self._views_settings then
		local aggregatum_view_tab = {
			display_name = "loc_aggregatum_view_display_name",
			view_name = "inventory_view",
			update = function (content, style, dt)
				content.hotspot.disabled = not self:is_inventory_synced()
				
				if not self._is_own_player or self._is_readonly then
					return false
				end
			end,
			view_context = {
				tabs = {
					{
						allow_item_hover_information = false,
						display_name = "aggregatum_tab_name",
						draw_wallet = false,
						icon = "content/ui/materials/icons/system/settings/appearance",
						is_grid_layout = false,
						telemetry_name = "aggregatum_view",
						ui_animation = "loadout_on_enter",
						camera_settings = {
							{
								"event_inventory_set_target_camera_offset",
								0,
								0,
								0,
							},
							{
								"event_inventory_set_target_camera_rotation",
								false,
							},
							{
								"event_inventory_set_camera_default_focus",
							},
						},
						layout = {},
					},
				},
			},
		}
		
		-- Добавляем таб в конец списка
		self._views_settings[#self._views_settings + 1] = aggregatum_view_tab
		
		-- Добавляем таб в меню вручную, так как меню уже создано
		local display_name = mod:localize("loc_aggregatum_view_display_name")
		local function entry_callback_function()
			self:_on_panel_option_pressed(#self._views_settings)
		end
		local optional_update_function = aggregatum_view_tab.update
		local cb = callback(entry_callback_function)
		
		self._top_panel:add_entry(display_name, cb, optional_update_function)
	end
end)
