local mod = get_mod("RobocopHUD")

require("scripts/ui/hud/elements/hud_element_base")

local UIWidget = require("scripts/managers/ui/ui_widget")

local Definitions = mod.robocophud_definitions or mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/definitions/robocop_hud_definitions")
local Themes = mod.robocophud_themes or mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/themes/themes")
local ThreatQuery = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/threat_query")
local ThreatScoring = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/threat_scoring")
local TargetLock = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/target_lock")
local ScannerSweepRuntime = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/scanner_sweep")
local WarningsRuntime = mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/runtime/warnings_runtime")

local function _noop_table()
	return {
		update = function() end,
	}
end

local function _safe_widget(module_value)
	if type(module_value) == "table" and type(module_value.update) == "function" then
		return module_value
	end

	return _noop_table()
end

local LockFrameWidget = _safe_widget(mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/widgets/lock_frame"))
local ThreatLadderWidget = _safe_widget(mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/widgets/threat_ladder"))
local RecorderOverlayWidget = _safe_widget(mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/widgets/recorder_overlay"))
local DirectivesWidget = _safe_widget(mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/widgets/directives"))
local ScannerSweepWidget = _safe_widget(mod:io_dofile("RobocopHUD/scripts/mods/RobocopHUD/hud/widgets/scanner_sweep"))

local HudElementRobocopHUD = class("HudElementRobocopHUD", "HudElementBase")

local function enabled()
	local s = mod._settings
	local on = type(s) ~= "table" or (s.robocophud_enabled ~= false and s.robocophud_enabled ~= 0)

	return on
end

local function _local_player_unit()
	local player_manager = Managers.player

	if not player_manager then
		return nil
	end

	local player = player_manager.local_player_safe and player_manager:local_player_safe(1) or player_manager:local_player(1)

	return player and player.player_unit or nil
end

local LOS_FILTER = "filter_minion_line_of_sight_check"
local LOS_END_MARGIN = 0.4
local LOS_EYE_OFFSET = 1.65
local LOS_HIT_ACTOR_INDEX = 4

local function _get_physics_world()
	local wm = Managers.world

	if not wm then
		return nil
	end

	if wm.has_world and wm:has_world("level_world") then
		local ok_w, world = pcall(wm.world, wm, "level_world")

		if ok_w and world then
			local ok_pw, pw = pcall(World.physics_world, world)

			if ok_pw and pw then
				return pw
			end
		end
	end

	return nil
end

-- Cast one ray from `from` to `target_pos`.
-- Returns true if the path is clear (only the target_unit itself may be hit).
local function _ray_clear(pw, from, target_pos, target_unit)
	local delta = target_pos - from
	local full_dist = Vector3.length(delta)

	if full_dist <= LOS_END_MARGIN then
		return true
	end

	local dir = Vector3.normalize(delta)
	local ray_dist = full_dist - LOS_END_MARGIN
	local ok, hits = pcall(PhysicsWorld.raycast, pw, from, dir, ray_dist, "all", "collision_filter", LOS_FILTER)

	if not ok or not hits then
		return true
	end

	for i = 1, #hits do
		local hit = hits[i]
		local actor = hit and hit[LOS_HIT_ACTOR_INDEX]
		local hit_unit = actor and Actor.unit(actor)

		if hit_unit ~= target_unit then
			return false
		end
	end

	return true
end

-- Multi-point LoS check.
-- Origin: camera world position (matches what the player actually sees).
-- Targets: torso node + head node of the enemy.
-- Returns true if AT LEAST ONE target point has a clear ray (partial walls don't fully hide).
local function _has_line_of_sight(camera, player_pos, target_unit, target_positions)
	local pw = _get_physics_world()

	if not pw then
		return true
	end

	-- Use camera position as the eye origin — matches the player's actual view.
	local from
	if camera and Camera.world_position then
		local ok_cam, cam_pos = pcall(Camera.world_position, camera)
		if ok_cam and cam_pos then
			from = cam_pos
		end
	end

	-- Fallback: approximate eye height from foot position.
	if not from then
		if not player_pos then
			return true
		end

		from = Vector3(player_pos.x, player_pos.y, player_pos.z + LOS_EYE_OFFSET)
	end

	-- Check each target point; visible if ANY is unobstructed.
	for _, target_pos in ipairs(target_positions) do
		if target_pos and _ray_clear(pw, from, target_pos, target_unit) then
			return true
		end
	end

	return false
end

local FRAME_LINE_LEN = 3000
local FRAME_LERP = 0.25
local SCAN_DWELL = 0.5

local function _update_lock_frame_offset(instance, widget, lock_state, render_settings, has_los)
	if not instance or not widget or not widget.content then
		return
	end

	-- Hide by default; only show if all conditions pass and position is successfully computed.
	widget.content.visible = false

	local stage = lock_state and lock_state.stage
	if stage ~= "LOCK" then
		return
	end

	local unit = lock_state and lock_state.unit

	if not unit or not HEALTH_ALIVE[unit] or not Unit.alive(unit) then
		return
	end

	-- LoS controls frame visibility; target lock is preserved in state but frame is hidden.
	if has_los == false then
		return
	end

	local parent = instance._parent
	local camera = parent and parent.player_camera and parent:player_camera()

	local node_torso = Unit.has_node(unit, "enemy_aim_target_02") and Unit.node(unit, "enemy_aim_target_02") or nil
	local node_head = Unit.has_node(unit, "enemy_aim_target_03") and Unit.node(unit, "enemy_aim_target_03") or nil
	local node_lower = Unit.has_node(unit, "enemy_aim_target_01") and Unit.node(unit, "enemy_aim_target_01") or nil

	local target_pos = node_torso and Unit.world_position(unit, node_torso) or (POSITION_LOOKUP and POSITION_LOOKUP[unit])
	local head_pos = node_head and Unit.world_position(unit, node_head) or nil
	local lower_pos = node_lower and Unit.world_position(unit, node_lower) or nil

	if not camera or not target_pos then
		return
	end

	local wts_torso = Camera.world_to_screen(camera, target_pos)
	local sx = wts_torso and (wts_torso.x or wts_torso[1])
	local sy = wts_torso and (wts_torso.y or wts_torso[2])

	if type(sx) ~= "number" or type(sy) ~= "number" then
		return
	end

	local scale = (render_settings and render_settings.scale) or 1
	local inverse_scale = (render_settings and render_settings.inverse_scale) or ((scale ~= 0) and (1 / scale) or 1)

	local center_world_px = instance:scenegraph_world_position("center", scale)
	local center_size_ui = instance:scenegraph_size("center")
	local cx_px = center_world_px and (center_world_px[1] or center_world_px.x)
	local cy_px = center_world_px and (center_world_px[2] or center_world_px.y)
	local cw_ui = center_size_ui and (center_size_ui[1] or center_size_ui.x) or 0
	local ch_ui = center_size_ui and (center_size_ui[2] or center_size_ui.y) or 0

	if type(cx_px) ~= "number" or type(cy_px) ~= "number" then
		return
	end

	local pivot_x_px = cx_px + (cw_ui * scale) * 0.5
	local pivot_y_px = cy_px + (ch_ui * scale) * 0.5
	local dx = (sx - pivot_x_px) * inverse_scale
	local dy = (sy - pivot_y_px) * inverse_scale
	local o = widget.offset

	if not o then
		widget.offset = { dx, dy, 0 }
	else
		o[1] = dx
		o[2] = dy
	end

	local frame_style = widget.style

	if not frame_style then
		return
	end

	-- Frame height: project head and feet nodes to screen → pixel height → UI units.
	-- Naturally scales with distance (closer = larger) without any distance formula.
	-- Fallback: approximate from distance when nodes are unavailable.
	local raw_h = nil
	local raw_w = nil

	if head_pos and lower_pos then
		local wts_head = Camera.world_to_screen(camera, head_pos)
		local wts_low = Camera.world_to_screen(camera, lower_pos)
		local py_head = wts_head and (wts_head.y or wts_head[2])
		local py_low = wts_low and (wts_low.y or wts_low[2])

		if type(py_head) == "number" and type(py_low) == "number" then
			local screen_h_px = math.abs(py_head - py_low)
			if screen_h_px > 2 then
				raw_h = screen_h_px * inverse_scale
				raw_w = raw_h * 0.65
			end
		end
	end

	-- Fallback when head/feet nodes are missing: approximate using distance.
	-- Enemy height ~1.8m; focal length approximation for 70° vFOV on 1080px: ~790.
	if not raw_h then
		local player_unit = _local_player_unit()
		local player_pos = player_unit and POSITION_LOOKUP and POSITION_LOOKUP[player_unit]
		local origin = player_pos or (Camera.world_position and Camera.world_position(camera))
		local dist_fb = (origin and Vector3.distance(origin, target_pos)) or 10

		if dist_fb < 0.5 then
			dist_fb = 0.5
		end

		raw_h = (1.8 / dist_fb) * 790 * inverse_scale
		raw_w = raw_h * 0.65
	end

	raw_h = math.clamp(raw_h, 20, 700)
	raw_w = math.clamp(raw_w, 14, 455)

	-- Lerp size toward target to prevent single-frame jumps.
	local prev_h = instance._robocophud_frame_h or raw_h
	local prev_w = instance._robocophud_frame_w or raw_w
	local est_h = prev_h + (raw_h - prev_h) * FRAME_LERP
	local est_w = prev_w + (raw_w - prev_w) * FRAME_LERP
	instance._robocophud_frame_h = est_h
	instance._robocophud_frame_w = est_w

	instance._robocophud_dbg_frame_w = math.floor(est_w + 0.5)
	instance._robocophud_dbg_frame_h = math.floor(est_h + 0.5)

	local half_w = est_w * 0.5
	local half_h = est_h * 0.5

	if frame_style.frame_top then
		frame_style.frame_top.size[1] = est_w
		frame_style.frame_top.offset[2] = half_h
	end

	if frame_style.frame_bottom then
		frame_style.frame_bottom.size[1] = est_w
		frame_style.frame_bottom.offset[2] = -half_h
	end

	if frame_style.frame_left then
		frame_style.frame_left.size[2] = est_h
		frame_style.frame_left.offset[1] = -half_w
	end

	if frame_style.frame_right then
		frame_style.frame_right.size[2] = est_h
		frame_style.frame_right.offset[1] = half_w
	end

	-- Extending lines: positioned just outside the frame borders.
	if frame_style.line_top then
		frame_style.line_top.size[2] = FRAME_LINE_LEN
		frame_style.line_top.offset[2] = half_h + FRAME_LINE_LEN * 0.5
	end

	if frame_style.line_bottom then
		frame_style.line_bottom.size[2] = FRAME_LINE_LEN
		frame_style.line_bottom.offset[2] = -(half_h + FRAME_LINE_LEN * 0.5)
	end

	if frame_style.line_left then
		frame_style.line_left.size[1] = FRAME_LINE_LEN
		frame_style.line_left.offset[1] = -(half_w + FRAME_LINE_LEN * 0.5)
	end

	if frame_style.line_right then
		frame_style.line_right.size[1] = FRAME_LINE_LEN
		frame_style.line_right.offset[1] = half_w + FRAME_LINE_LEN * 0.5
	end

	-- All calculations succeeded — show the widget.
	widget.content.visible = true
end

HudElementRobocopHUD.init = function(self, parent, draw_layer, start_scale)
	HudElementRobocopHUD.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = Definitions.scenegraph_definition,
		widget_definitions = Definitions.widget_definitions,
	})

	self._is_initialized = true
	self._theme = Themes.resolve_theme(mod._settings)
	self._threat_state = {}
	self._scoring_state = {}
	self._lock_state = {}
	self._scanner_state = {}
	self._warnings_state = {}
end

HudElementRobocopHUD.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	if not enabled() then
		return
	end

	self._theme = Themes.resolve_theme(mod._settings)

	local s = mod._settings
	local opacity = type(s) == "table" and s.hud_opacity
	local scale = type(s) == "table" and s.hud_scale

	if type(opacity) ~= "number" or opacity ~= opacity then
		opacity = 1
	end

	if type(scale) ~= "number" or scale ~= scale then
		scale = 1
	end

	opacity = math.clamp(opacity, 0, 1)
	scale = math.clamp(scale, 0.5, 1.5)

	local theme_text = self._theme and self._theme.text
	local status_widget = self._widgets_by_name and self._widgets_by_name.status_text

	local parent_hud = self._parent
	local camera = parent_hud and parent_hud.player_camera and parent_hud:player_camera()

	local scanner_compass_angle = 0
	if camera and Camera.local_rotation and Quaternion and Quaternion.yaw then
		local ok_rot, cam_rot = pcall(Camera.local_rotation, camera)
		if ok_rot and cam_rot then
			local ok_yaw, yaw = pcall(Quaternion.yaw, cam_rot)
			if ok_yaw and type(yaw) == "number" then
				-- Rotate the compass ring opposite to camera yaw.
				scanner_compass_angle = -yaw
			else
				local fwd = Quaternion.forward(cam_rot)
				fwd.z = 0
				if Vector3.length_squared(fwd) > 0.0001 then
					fwd = Vector3.normalize(fwd)
					scanner_compass_angle = -math.atan2(fwd.x, fwd.y)
				end
			end
		end
	end

	local runtime_settings = {
		target_scan_interval = 0.10,
		max_candidates = 64,
		max_distance = 80,
		sticky_bonus = 30,
		distance_weight = 10,
		targeting_enabled = type(s) ~= "table" or (s.targeting_enabled ~= false and s.targeting_enabled ~= 0),
		lock_scan_seconds = type(s) == "table" and s.lock_scan_seconds or 0.20,
		lock_track_seconds = type(s) == "table" and s.lock_track_seconds or 0.25,
		target_hold_seconds = type(s) == "table" and s.target_hold_seconds or 1.0,
		camera = camera,
	}

	local scanner_settings = {
		enabled = type(s) == "table" and (s.scanner_enabled == true or s.scanner_enabled == 1) or false,
		passive = type(s) == "table" and (s.scanner_passive == true or s.scanner_passive == 1) or true,
		sweep_seconds = type(s) == "table" and s.scanner_sweep_seconds or 2.0,
		range_m = type(s) == "table" and s.scanner_range_m or 80.0,
		max_blips = math.min(24, type(s) == "table" and s.scanner_max_blips or 24),
		blip_fade_seconds = type(s) == "table" and s.scanner_blip_fade_seconds or 1.0,
		camera = camera,
		manual_pulse = mod._robocophud_scanner_manual_pulse == true,
	}

	local scanner_offset_x = type(s) == "table" and s.scanner_offset_x
	local scanner_offset_y = type(s) == "table" and s.scanner_offset_y

	if type(scanner_offset_x) ~= "number" or scanner_offset_x ~= scanner_offset_x then
		scanner_offset_x = 0
	end
	if type(scanner_offset_y) ~= "number" or scanner_offset_y ~= scanner_offset_y then
		scanner_offset_y = 0
	end

	mod._robocophud_scanner_manual_pulse = false

	local prev_lock_unit = self._lock_state.unit

	local candidates, count
	candidates, count, self._threat_state = ThreatQuery.acquire(self._threat_state, t, runtime_settings)

	local best_unit, top_threats
	best_unit, top_threats, self._scoring_state = ThreatScoring.rank(self._scoring_state, candidates, count, self._lock_state.unit, runtime_settings)

	if mod._robocophud_mode == "SCAN" then
		-- SCAN mode: automatically cycle through all visible enemies one by one.
		-- Each enemy is shown for SCAN_DWELL seconds.
		-- Once all visible enemies have been shown, the frame hides.
		-- When a shown enemy leaves the frustum, its "shown" flag resets so it can appear again.
		local ss = mod._robocophud_scan_state
		if not ss then
			ss = { shown_set = {}, current_unit = nil, show_until_t = 0 }
			mod._robocophud_scan_state = ss
		end

		-- Build lookup of units currently in the candidates list (in frustum).
		local in_candidates = {}
		for i = 1, count do
			local e = candidates[i]
			if e and e.unit then
				in_candidates[e.unit] = true
			end
		end

		-- Reset shown flag for units that have left the frustum.
		for u, _ in pairs(ss.shown_set) do
			if not in_candidates[u] then
				ss.shown_set[u] = nil
			end
		end

		-- Manage the currently displayed scan target.
		local cur_scan = ss.current_unit
		if cur_scan then
			local ok, alive = pcall(Unit.alive, cur_scan)
			if not ok or not alive or not in_candidates[cur_scan] then
				-- Target died or left frustum — don't mark as shown (it left on its own).
				cur_scan = nil
				ss.current_unit = nil
			elseif t >= (ss.show_until_t or 0) then
				-- Dwell time expired — mark this unit as shown and advance.
				ss.shown_set[cur_scan] = true
				cur_scan = nil
				ss.current_unit = nil
			end
		end

		-- Pick next unshown candidate if we have no current target.
		if not cur_scan then
			local next_candidates = {}
			for i = 1, count do
				local e = candidates[i]
				if e and e.unit and not ss.shown_set[e.unit] then
					local ok, alive = pcall(Unit.alive, e.unit)
					if ok and alive then
						next_candidates[#next_candidates + 1] = e
					end
				end
			end
			if #next_candidates > 0 then
				table.sort(next_candidates, function(a, b)
					return (a.distance or 9999) < (b.distance or 9999)
				end)
				cur_scan = next_candidates[1].unit
				ss.current_unit = cur_scan
				ss.show_until_t = t + SCAN_DWELL
			end
		end

		-- Directly control lock_state in SCAN mode — bypass TargetLock timing.
		if cur_scan then
			if self._lock_state.unit ~= cur_scan then
				self._robocophud_frame_h = nil
				self._robocophud_frame_w = nil
			end
			self._lock_state.unit = cur_scan
			self._lock_state.stage = "LOCK"
			self._lock_state.stage_t = t
		else
			self._lock_state.unit = nil
			self._lock_state.stage = "IDLE"
			self._lock_state.stage_t = t
		end
	else
		-- AUTO mode: use best_unit from ThreatScoring (already computed above).
		self._lock_state = TargetLock.update(self._lock_state, t, best_unit, runtime_settings)
	end

	-- Reset cached frame size when target changes to avoid lerping from wrong previous size.
	if self._lock_state.unit ~= prev_lock_unit then
		self._robocophud_frame_h = nil
		self._robocophud_frame_w = nil
	end

	-- Frustum check (AUTO TARGET only): if locked target left the field of view, reset lock for re-acquisition.
	-- In SCAN mode the scan logic already uses candidates (frustum-filtered), so no separate check needed.
	local cur_lock_unit = self._lock_state.unit
	local cur_lock_has_los = true

	if mod._robocophud_mode ~= "SCAN" and cur_lock_unit and HEALTH_ALIVE[cur_lock_unit] and Unit.alive(cur_lock_unit) and camera then
		local node_torso = Unit.has_node(cur_lock_unit, "enemy_aim_target_02") and Unit.node(cur_lock_unit, "enemy_aim_target_02") or nil
		local cur_pos = (node_torso and Unit.world_position(cur_lock_unit, node_torso)) or (POSITION_LOOKUP and POSITION_LOOKUP[cur_lock_unit])
		local in_frustum = cur_pos and Camera.inside_frustum and Camera.inside_frustum(camera, cur_pos)

		if not cur_pos or (in_frustum and in_frustum <= 0) then
			self._lock_state.unit = nil
			self._lock_state.stage = "IDLE"
			self._lock_state.stage_t = t
			cur_lock_unit = nil
		end
	end

	-- LoS check (both modes): only hides the frame widget, does NOT clear the target lock.
	-- Casts rays to torso + head; visible if ANY point is unobstructed.
	if cur_lock_unit and HEALTH_ALIVE[cur_lock_unit] and Unit.alive(cur_lock_unit) then
		local node_torso = Unit.has_node(cur_lock_unit, "enemy_aim_target_02") and Unit.node(cur_lock_unit, "enemy_aim_target_02") or nil
		local node_head = Unit.has_node(cur_lock_unit, "enemy_aim_target_03") and Unit.node(cur_lock_unit, "enemy_aim_target_03") or nil
		local torso_pos = (node_torso and Unit.world_position(cur_lock_unit, node_torso)) or (POSITION_LOOKUP and POSITION_LOOKUP[cur_lock_unit])
		local head_pos = node_head and Unit.world_position(cur_lock_unit, node_head) or nil

		local target_positions = {}
		if torso_pos then target_positions[#target_positions + 1] = torso_pos end
		if head_pos then target_positions[#target_positions + 1] = head_pos end

		if #target_positions > 0 then
			local player_unit = _local_player_unit()
			local player_pos = player_unit and POSITION_LOOKUP and POSITION_LOOKUP[player_unit]
			cur_lock_has_los = _has_line_of_sight(camera, player_pos, cur_lock_unit, target_positions)
		end
	end

	local warning_ctx = {
		target_lost = (self._lock_state.stage == "IDLE" and self._lock_state.unit == nil and self._last_lock_had_unit == true) or false,
	}
	self._last_lock_had_unit = self._lock_state.unit ~= nil
	self._warnings_state = WarningsRuntime.update(self._warnings_state, t, warning_ctx, runtime_settings)

	local widgets = self._widgets_by_name
	if widgets then
		local lock_w = widgets.lock_frame
		local ladder_w = widgets.threat_ladder
		local rec_w = widgets.recorder_text
		local dir_w = widgets.directives
		local scan_w = widgets.scanner_sweep

		if scan_w then
			local o = scan_w.offset
			if not o then
				scan_w.offset = { scanner_offset_x, scanner_offset_y, 0 }
			else
				o[1] = scanner_offset_x
				o[2] = scanner_offset_y
			end
		end

		self._scanner_state = ScannerSweepRuntime.update(self._scanner_state, dt, t, scanner_settings)
		self._scanner_state.t = t
		self._scanner_state.compass_angle = scanner_compass_angle

		RecorderOverlayWidget.update(rec_w, t, self._theme, opacity, mod._robocophud_mode)
		-- Colors/text first, then position+visibility (_update_lock_frame_offset is the sole authority on widget.content.visible).
		LockFrameWidget.update(lock_w, self._lock_state, self._theme, opacity)
		_update_lock_frame_offset(self, lock_w, self._lock_state, render_settings, cur_lock_has_los)
		ThreatLadderWidget.update(ladder_w, top_threats, self._theme, opacity)
		DirectivesWidget.update(dir_w, self._lock_state, self._theme, opacity)
		ScannerSweepWidget.update(scan_w, self._scanner_state, self._theme, opacity)
	end

	if status_widget and status_widget.content and status_widget.style and status_widget.style.text then
		local stage = self._lock_state.stage or "IDLE"
		local target_txt = "NONE"

		if self._lock_state.unit and Unit.alive(self._lock_state.unit) then
			target_txt = "TARGET"
		end

		local dbg_w = self._robocophud_dbg_frame_w
		local dbg_h = self._robocophud_dbg_frame_h

		if mod:get("debug_overlay") == true then
			status_widget.content.text = string.format(
				"ROBOCOPHUD DBG | STAGE:%s | TARGET:%s | frame:%dx%d",
				tostring(stage),
				tostring(target_txt),
				tonumber(dbg_w) or 0,
				tonumber(dbg_h) or 0
			)
		else
			status_widget.content.text = string.format("REC 00:00:00  |  MODE: COMBAT  |  %s  |  %s  |  SCALE: %.2f", stage, target_txt, scale)
		end

		local c = status_widget.style.text.text_color
		local a = math.floor(255 * opacity + 0.5)

		if theme_text then
			c[1] = a
			c[2] = theme_text[2]
			c[3] = theme_text[3]
			c[4] = theme_text[4]
		else
			c[1] = a
		end

		status_widget.dirty = true
	end
end

HudElementRobocopHUD.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementRobocopHUD.super.draw(self, dt, t, ui_renderer, render_settings, input_service)

	if not enabled() then
		return
	end

	-- widget drawing handled by HudElementBase
end

HudElementRobocopHUD.destroy = function(self, ui_renderer)
	HudElementRobocopHUD.super.destroy(self, ui_renderer)
end

return HudElementRobocopHUD

