local mod = get_mod("QuickDeploy")

local POCKETABLE_SLOT = "slot_pocketable"
local POCKETABLE_SMALL_SLOT = "slot_pocketable_small"

local DEPLOY_STAGES = {
	NONE = 0,
	SWITCH_TO = 1,
	PLACE = 2,
	AIM_ALLY = 3,      -- Прицеливание на союзника (ПКМ)
	INJECT_ALLY = 4,   -- Введение стима союзнику (ЛКМ)
}

local deploy_stage = DEPLOY_STAGES.NONE
local target_slot = nil
local current_wield_slot = nil
local inject_mode = "self"  -- "self" или "ally"
local deploy_stage_start_time = 0  -- Время начала стадии
local DEPLOY_TIMEOUT = 2.0  -- Таймаут в секундах

local _get_player_unit = function()
	local plr = Managers.player and Managers.player:local_player_safe(1)
	return plr and plr.player_unit
end

local _start_quick_deploy = function(slot_name, mode)
	local plr_unit = _get_player_unit()
	if not plr_unit then
		return
	end
	
	local unit_data_extension = plr_unit and ScriptUnit.extension(plr_unit, "unit_data_system")
	if not unit_data_extension then
		return
	end
	
	local inventory_component = unit_data_extension:read_component("inventory")
	if not inventory_component then
		return
	end
	
	local pocketable_name = inventory_component[slot_name]
	
	if pocketable_name and pocketable_name ~= "not_equipped" then
		target_slot = slot_name
		inject_mode = mode or "self"
		
		-- Если уже держим нужный слот
		if current_wield_slot == slot_name then
			if inject_mode == "ally" and slot_name == POCKETABLE_SMALL_SLOT then
				deploy_stage = DEPLOY_STAGES.AIM_ALLY
				deploy_stage_start_time = Managers.time:time("gameplay")
			else
				deploy_stage = DEPLOY_STAGES.PLACE
				deploy_stage_start_time = Managers.time:time("gameplay")
			end
		else
			deploy_stage = DEPLOY_STAGES.SWITCH_TO
			deploy_stage_start_time = Managers.time:time("gameplay")
		end
	end
end

-- Хук на смену слота
mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
	if self._player == Managers.player:local_player(1) then
		current_wield_slot = slot_name
		
		-- Если переключились на целевой слот, переходим к нужному действию
		if deploy_stage == DEPLOY_STAGES.SWITCH_TO and slot_name == target_slot then
			if inject_mode == "ally" and target_slot == POCKETABLE_SMALL_SLOT then
				deploy_stage = DEPLOY_STAGES.AIM_ALLY
				deploy_stage_start_time = Managers.time:time("gameplay")
			else
				deploy_stage = DEPLOY_STAGES.PLACE
				deploy_stage_start_time = Managers.time:time("gameplay")
			end
		end
		
		-- Если переключились обратно с расходника, значит действие завершено
		if (deploy_stage == DEPLOY_STAGES.PLACE or deploy_stage == DEPLOY_STAGES.INJECT_ALLY) and slot_name ~= target_slot then
			deploy_stage = DEPLOY_STAGES.NONE
			target_slot = nil
			inject_mode = "self"
			deploy_stage_start_time = 0
		end
	end
end)

-- Хук на InputService для подмены входных данных
local _input_action_hook = function(func, self, action_name)
	local val = func(self, action_name)
	
	-- ВАЖНО: Глобально блокируем ПКМ для стимов в режиме "self" во всех стадиях
	if inject_mode == "self" and target_slot == POCKETABLE_SMALL_SLOT and action_name == "action_two_hold" then
		if deploy_stage ~= DEPLOY_STAGES.NONE then
			return false  -- Блокируем ПКМ для стимов в режиме "self"
		end
	end
	
	-- ВАЖНО: Глобально держим ПКМ для стимов в режиме "ally" в нужных стадиях
	if inject_mode == "ally" and target_slot == POCKETABLE_SMALL_SLOT and action_name == "action_two_hold" then
		if deploy_stage == DEPLOY_STAGES.AIM_ALLY or deploy_stage == DEPLOY_STAGES.INJECT_ALLY then
			return true  -- Держим ПКМ для прицеливания на союзника
		end
	end
	
	-- Если находимся в процессе переключения, подставляем wield действия
	if deploy_stage == DEPLOY_STAGES.SWITCH_TO then
		-- Для slot_pocketable используем wield_3 / wield_3_gamepad
		if target_slot == POCKETABLE_SLOT and (action_name == "wield_3" or action_name == "wield_3_gamepad") then
			return true
		end
		-- Для slot_pocketable_small используем wield_4
		if target_slot == POCKETABLE_SMALL_SLOT and action_name == "wield_4" then
			return true
		end
	end
	
	-- Размещение/использование (ЛКМ)
	if deploy_stage == DEPLOY_STAGES.PLACE and action_name == "action_one_pressed" then
		return true
	end
	
	-- Введение стима союзнику (нажимаем ЛКМ, ПКМ уже держится глобально)
	if deploy_stage == DEPLOY_STAGES.INJECT_ALLY and action_name == "action_one_pressed" then
		return true
	end
	
	return val
end

mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

-- Update функция для проверки таймаута
mod.update = function(dt)
	if deploy_stage == DEPLOY_STAGES.NONE then
		return
	end
	
	local current_time = Managers.time and Managers.time:time("gameplay")
	if not current_time then
		return
	end
	
	local elapsed = current_time - deploy_stage_start_time
	
	-- Если прошло слишком много времени, сбрасываем состояние
	if elapsed > DEPLOY_TIMEOUT then
		deploy_stage = DEPLOY_STAGES.NONE
		target_slot = nil
		inject_mode = "self"
		deploy_stage_start_time = 0
	end
end

-- Хук на начало действия, чтобы отследить размещение или использование
mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input, ...)
	if _get_player_unit() == self._unit then
		-- Когда начинается действие размещения на землю
		if deploy_stage == DEPLOY_STAGES.PLACE and action_name == "action_place_complete" then
			deploy_stage = DEPLOY_STAGES.NONE
			target_slot = nil
			inject_mode = "self"
			deploy_stage_start_time = 0
		end
		
		-- Когда начинается использование стима на себя
		if deploy_stage == DEPLOY_STAGES.PLACE and action_name == "action_use_self" then
			deploy_stage = DEPLOY_STAGES.NONE
			target_slot = nil
			inject_mode = "self"
			deploy_stage_start_time = 0
		end
		
		-- Когда начинается прицеливание для передачи союзнику (action_aim или action_flair)
		if deploy_stage == DEPLOY_STAGES.AIM_ALLY and (action_name == "action_aim" or action_name == "action_flair") then
			deploy_stage = DEPLOY_STAGES.INJECT_ALLY
			deploy_stage_start_time = Managers.time:time("gameplay")
		end
		
		-- Когда начинается введение стима союзнику
		if deploy_stage == DEPLOY_STAGES.INJECT_ALLY and action_name == "action_use_self" then
			deploy_stage = DEPLOY_STAGES.NONE
			target_slot = nil
			inject_mode = "self"
			deploy_stage_start_time = 0
		end
	end
end)

-- Команды для вызова из горячих клавиш
mod.deploy_pocketable = function()
	-- Проверяем, что курсор не активен (не открыто меню)
	if Managers.input and Managers.input:cursor_active() then
		return
	end
	
	if deploy_stage ~= DEPLOY_STAGES.NONE then
		-- Если уже в процессе, отменяем
		deploy_stage = DEPLOY_STAGES.NONE
		target_slot = nil
		inject_mode = "self"
		deploy_stage_start_time = 0
		return
	end
	_start_quick_deploy(POCKETABLE_SLOT, "self")
end

mod.deploy_pocketable_small = function()
	-- Проверяем, что курсор не активен (не открыто меню)
	if Managers.input and Managers.input:cursor_active() then
		return
	end
	
	if deploy_stage ~= DEPLOY_STAGES.NONE then
		-- Если уже в процессе, отменяем
		deploy_stage = DEPLOY_STAGES.NONE
		target_slot = nil
		inject_mode = "self"
		deploy_stage_start_time = 0
		return
	end
	_start_quick_deploy(POCKETABLE_SMALL_SLOT, "self")
end

mod.inject_ally_small = function()
	-- Проверяем, что курсор не активен (не открыто меню)
	if Managers.input and Managers.input:cursor_active() then
		return
	end
	
	if deploy_stage ~= DEPLOY_STAGES.NONE then
		-- Если уже в процессе, отменяем
		deploy_stage = DEPLOY_STAGES.NONE
		target_slot = nil
		inject_mode = "self"
		deploy_stage_start_time = 0
		return
	end
	_start_quick_deploy(POCKETABLE_SMALL_SLOT, "ally")
end

-- Чистим состояние при выгрузке
mod.on_game_state_changed = function(status, state_name)
	if state_name == "StateGameplay" and status == "exit" then
		deploy_stage = DEPLOY_STAGES.NONE
		target_slot = nil
		inject_mode = "self"
		deploy_stage_start_time = 0
	end
end

