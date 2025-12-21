local mod = get_mod("PrivateModeBypass")

-- Перехватываем _update_can_start_mission в HordePlayView
-- Это основная проверка, которая блокирует запуск миссии в приватном режиме без пати
mod:hook("HordePlayView", "_update_can_start_mission", function(func, self)
	if not mod:get("enabled") then
		return func(self)
	end
	
	local player_level = self._player_level
	local mission = self._selected_mission
	local required_level = mission and mission.requiredLevel or 0
	local is_locked = false

	-- Проверка уровня
	if player_level < required_level then
		local _required_level_loc_table = {
			required_level = required_level,
		}
		self:_set_info_text("warning", Localize("loc_mission_board_view_required_level", true, _required_level_loc_table))
		is_locked = true
	-- Проверка, что все участники в хабе
	elseif not self._party_manager:are_all_members_in_hub() then
		self:_set_info_text("warning", Localize("loc_mission_board_team_mate_not_available"))
		is_locked = true
	-- Проверка приватного режима - ОБХОДИМ ЭТУ ПРОВЕРКУ, если мод включен
	elseif self._private_match then
		local num_other = self._party_manager:num_other_members()
		-- Если мод включен, игнорируем проверку количества участников
		if num_other < 1 then
			if mod:get("enabled") then
				-- Мод включен - пропускаем проверку
				self:_set_info_text("info", nil)
			else
				-- Мод выключен - показываем предупреждение
				self:_set_info_text("warning", Localize("loc_mission_board_cannot_private_match"))
				is_locked = true
			end
		else
			self:_set_info_text("info", nil)
		end
	else
		self:_set_info_text("info", nil)
	end

	local widgets_by_name = self._widgets_by_name

	widgets_by_name.play_button.content.visible = not is_locked
	widgets_by_name.play_button_legend.content.visible = not is_locked

	if is_locked then
		self._play_button_anim_delay = nil
	end

	self.can_start_mission = not is_locked

	return is_locked
end)

-- Перехватываем _update_info_state в MissionBoardView
-- Это проверка, которая показывает предупреждение о невозможности приватного режима
mod:hook("MissionBoardView", "_update_info_state", function(func, self, t)
	-- Вызываем оригинальную функцию
	func(self, t)
	
	-- Если мод включен, обходим проверку приватного режима
	if mod:get("enabled") then
		local party_manager = self._party_manager
		local mission_board_logic = self._mission_board_logic
		
		if mission_board_logic and mission_board_logic:is_private_match() then
			local is_alone = party_manager:num_other_members() < 1
			
			-- Если мы одни, но мод включен, не показываем ошибку
			if is_alone then
				-- Удаляем ошибку приватного режима, устанавливая условие в false
				self:_poll_issue_localized("private_error", 2, false, nil)
			end
		end
	end
end)

