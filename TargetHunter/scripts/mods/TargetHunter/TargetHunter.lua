local mod = get_mod("TargetHunter")

mod._tracked_markers = {}
mod._marker_seq = 0
local DEFAULT_MAX_DISTANCE = 40

local function is_unit(value)
	return type(value) == "userdata" and Unit and Unit.alive and Unit.alive(value)
end

local function fetch_breed(unit)
	local unit_data = ScriptUnit.has_extension and ScriptUnit.has_extension(unit, "unit_data_system")

	return unit_data and unit_data:breed()
end

local function resolve_unit(unit_or_position_or_id)
	if is_unit(unit_or_position_or_id) then
		return unit_or_position_or_id
	end

	if Application and Application.flow_callback_context_unit then
		local context_unit = Application.flow_callback_context_unit()

		if is_unit(context_unit) then
			return context_unit
		end
	end

	return nil
end

local function should_track_breed(breed)
	if not breed or not breed.tags then
		return false
	end

	local tags = breed.tags
	local is_boss = tags.boss or tags.monster
	local is_elite = tags.elite or tags.special

	if is_boss and mod:get("enable_bosses") then
		return true, true
	end

	if is_elite and mod:get("enable_elites") then
		return true, false
	end

	return false, false
end

local function remove_marker(unit, entry)
	if entry and entry.marker_id then
		Managers.event:trigger("remove_world_marker", entry.marker_id)
	end

	mod._tracked_markers[unit] = nil
end

local function register_marker(unit, breed, is_boss)
	if mod._tracked_markers[unit] then
		return
	end

	mod._marker_seq = mod._marker_seq + 1

	local tag_id = string.format("target_hunter_%s_%d", breed.name or "enemy", mod._marker_seq)
	local marker_type = is_boss and "target_hunter_boss" or "target_hunter_elite"
	local data = {
		tag_id = tag_id,
		visual_type = "default",
	}

	local function cb(marker_id)
		mod._tracked_markers[unit] = {
			marker_id = marker_id,
			breed_name = breed.name,
			is_boss = is_boss,
		}
	end

	Managers.event:trigger("add_world_marker_unit", marker_type, unit, cb, data)
end

local function try_track_unit(unit_or_position_or_id)
	local unit = resolve_unit(unit_or_position_or_id)

	if not unit or mod._tracked_markers[unit] then
		return
	end

	local breed = fetch_breed(unit)
	local should_track, is_boss = should_track_breed(breed)

	if should_track then
		register_marker(unit, breed, is_boss)
	end
end

local function cleanup_dead_units()
	for unit, entry in pairs(mod._tracked_markers) do
		if not is_unit(unit) then
			remove_marker(unit, entry)
		end
	end
end

local function reset_if_in_hub()
	local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()

	if game_mode_name == "hub" or not game_mode_name then
		for unit, entry in pairs(mod._tracked_markers) do
			remove_marker(unit, entry)
		end
	end
end

mod:hook_safe(WwiseWorld, "trigger_resource_event", function(_wwise_world, event_name, unit_or_position_or_id)
	if not event_name then
		return
	end

	if string.match(event_name, "player") or string.match(event_name, "weapon_player") then
		return
	end

	try_track_unit(unit_or_position_or_id)
end)

mod:hook_safe(WwiseWorld, "trigger_resource_external_event", function(_wwise_world, _sound_event, _sound_source, _file_path, _file_format, wwise_source_id)
	try_track_unit(wwise_source_id)
end)

-- Регистрируем свои шаблоны маркеров без smart tagging
mod:hook_safe(CLASS.HudElementWorldMarkers, "init", function(self)
	if not self._marker_templates["target_hunter_elite"] then
		local max_distance = mod:get("max_distance") or DEFAULT_MAX_DISTANCE
		local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
		local UIWidget = require("scripts/managers/ui/ui_widget")
		local icon_size = {64, 64}
		local arrow_size = {100, 100}

		local function make_template(name, icon, color_func)
			local template = {
				name = name,
				using_smart_tag_system = false,
				size = {100, 100},
				unit_node = "j_head",
				position_offset = {0, 0, 1.0}, -- увеличил высоту маркера было 0,8
				check_line_of_sight = false,
				max_distance = max_distance,
				screen_clamp = true,
				screen_margins = {down = 0.23, left = 0.234, right = 0.234, up = 0.23},
				scale_settings = {distance_max = 50, distance_min = 5, scale_from = 0.5, scale_to = 1},
			}

			template.create_widget_defintion = function(_, scenegraph_id)
				local header_font_setting_name = "hud_body"
				local header_font_settings = UIFontSettings[header_font_setting_name]
				local header_font_color = color_func and color_func(255, true) or Color.ui_hud_red_light(255, true)

				return UIWidget.create_definition({
					{
						pass_type = "texture",
						style_id = "icon",
						value = icon,
						value_id = "icon",
						style = {
							horizontal_alignment = "center",
							vertical_alignment = "center",
							size = icon_size,
							default_size = icon_size,
							offset = {0, -10, 1},
							color = header_font_color,
						},
						visibility_function = function(content, style)
							return content.icon ~= nil
						end,
					},
					{
						pass_type = "rotated_texture",
						style_id = "arrow",
						value = "content/ui/materials/hud/interactions/frames/direction",
						value_id = "arrow",
						style = {
							horizontal_alignment = "center",
							vertical_alignment = "center",
							size = arrow_size,
							offset = {0, 0, 1},
							color = header_font_color,
						},
						visibility_function = function(content, style)
							return content.is_clamped
						end,
						change_function = function(content, style)
							style.angle = content.angle
						end,
					},
					{
						pass_type = "text",
						style_id = "text",
						value = "-",
						value_id = "text",
						style = {
							horizontal_alignment = "center",
							text_horizontal_alignment = "center",
							text_vertical_alignment = "top",
							vertical_alignment = "center",
							offset = {0, 20, 2},
							default_offset = {0, 20, 2},
							font_type = header_font_settings.font_type,
							font_size = header_font_settings.font_size,
							text_color = header_font_color,
							default_text_color = header_font_color,
							size = {200, 20},
						},
						visibility_function = function(content, style)
							return content.distance >= 5 and (content.is_hovered or content.is_clamped)
						end,
					},
				}, scenegraph_id)
			end

			template.update_function = function(parent, ui_renderer, widget, marker, template, dt, t)
				local content = widget.content
				local style = widget.style
				local distance = content.distance

				local is_inside_frustum = content.is_inside_frustum
				local alpha_multiplier = 1

				if not is_inside_frustum then
					local pulse_progress = Application.time_since_launch() * 1 % 1
					local pulse_anim_progress = (pulse_progress * 2 - 1) ^ 2
					alpha_multiplier = 0.7 + pulse_anim_progress * 0.3
				end

				widget.alpha_multiplier = alpha_multiplier
				local distance_text = tostring(math.floor(distance)) .. "m"
				content.text = distance > 1 and distance_text or ""
				marker.ignore_scale = content.is_clamped or content.is_hovered
				return false
			end

			return template
		end

		self._marker_templates["target_hunter_elite"] =
			make_template("target_hunter_elite", "content/ui/materials/hud/interactions/icons/enemy", Color.ui_hud_red_light)
		self._marker_templates["target_hunter_boss"] = make_template(
			"target_hunter_boss",
			"content/ui/materials/hud/interactions/icons/enemy_priority",
			function(a, b)
				return Color.ui_hud_yellow_medium(a, b)
			end
		)
	end
end)

-- Обновляем max_distance шаблонов на лету
mod:hook_safe("HudElementWorldMarkers", "_calculate_markers", function(self, dt, t, input_service, ui_renderer, render_settings)
	local max_distance = mod:get("max_distance") or DEFAULT_MAX_DISTANCE
	local templates = self._marker_templates

	if templates then
		local elite = templates["target_hunter_elite"]
		local boss = templates["target_hunter_boss"]

		if elite then
			elite.max_distance = max_distance
		end

		if boss then
			boss.max_distance = max_distance
		end
	end
end)

-- Игнорируем наши маркеры в smart tagging, если на юните нет smart_tag_extension
mod:hook("HudElementSmartTagging", "_find_best_smart_tag_interaction", function(func, self, ui_renderer, render_settings, force_update_targets)
	-- если оригинал недоступен (неожиданный конфликт), не трогаем
	if type(func) ~= "function" then
		return func
	end

	local best_marker, best_unit, extra = func(self, ui_renderer, render_settings, force_update_targets)

	-- Защита: если у маркера нет smart_tag_extension и нет готового tag_id, отбрасываем (независимо от того, чей это маркер)
	if best_marker then
		local marker_data = best_marker.data
		local tag_id = marker_data and marker_data.tag_id
		local unit = best_marker.unit
		local has_ext = unit and ScriptUnit.has_extension(unit, "smart_tag_system")

		if not tag_id and not has_ext then
			best_marker = nil
			best_unit = nil
		end
	end

	return best_marker, best_unit, extra
end)

-- Блокируем отрисовку интеракции, если активный маркер без smart_tag_extension (любые маркеры)
mod:hook("HudElementSmartTagging", "_handle_interaction_draw", function(func, self, dt, t, input_service, ui_renderer, render_settings)
	local active = self._active_interaction_data
	local marker = active and active.marker
	local marker_data = marker and marker.data

	if marker then
		local unit = marker.unit
		local has_ext = unit and ScriptUnit.has_extension(unit, "smart_tag_system")
		local tag_id = marker_data and marker_data.tag_id

		if not tag_id and not has_ext then
			-- сбрасываем активный маркер и выходим, чтобы не вызвать nil:*
			self._active_interaction_data = nil
			return
		end
	end

	return func(self, dt, t, input_service, ui_renderer, render_settings)
end)

function mod.update(dt)
	reset_if_in_hub()
	cleanup_dead_units()
end

function mod.on_setting_changed(setting_id)
	if setting_id == "enable_bosses" or setting_id == "enable_elites" then
		for unit, entry in pairs(mod._tracked_markers) do
			local breed = fetch_breed(unit)
			local should_track = should_track_breed(breed)

			if not should_track then
				remove_marker(unit, entry)
			end
		end
	end
end

function mod.on_unload()
	for unit, entry in pairs(mod._tracked_markers) do
		remove_marker(unit, entry)
	end
end


