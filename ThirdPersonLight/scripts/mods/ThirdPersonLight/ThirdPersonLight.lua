local mod = get_mod("ThirdPersonLight")

-- Простая проверка режима третьего лица
local function check_third_person_mode()
	-- Безопасная проверка всех необходимых объектов
	if not Managers then
		return false
	end
	
	if not Managers.player then
		return false
	end

	-- Безопасный вызов local_player с проверкой на ошибки
	local success, player = pcall(function()
		return Managers.player:local_player(1)
	end)
	
	if not success or not player then
		return false
	end

	-- Проверяем что у player есть player_unit
	if not player.player_unit then
		return false
	end

	local player_unit = player.player_unit
	if not Unit.alive(player_unit) then
		return false
	end

	-- Безопасная проверка расширения
	local first_person_extension = ScriptUnit.has_extension(player_unit, "first_person_system")
	if first_person_extension then
		-- Проверяем _force_third_person_mode от модов третьего лица
		if first_person_extension._force_third_person_mode == true then
			return true
		end

		-- Безопасный вызов wants_first_person_camera
		local wants_first_person_success, wants_first_person = pcall(function()
			return first_person_extension:wants_first_person_camera()
		end)
		
		if wants_first_person_success and wants_first_person ~= nil then
			return not wants_first_person
		end
	end

	return false
end

-- Проверка включен ли фонарик через special_active
local function is_flashlight_enabled()
	if not Managers or not Managers.player then
		return false
	end

	local player = Managers.player:local_player(1)
	if not player then
		return false
	end

	local player_unit = player.player_unit
	if not player_unit or not Unit.alive(player_unit) then
		return false
	end

	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	if not unit_data_extension then
		return false
	end

	local inventory_component = unit_data_extension:read_component("inventory")
	if not inventory_component then
		return false
	end

	local wielded_slot = inventory_component.wielded_slot
	if not wielded_slot or wielded_slot == "none" or wielded_slot == "slot_unarmed" then
		return false
	end

	local slot_component = unit_data_extension:read_component(wielded_slot)
	if not slot_component then
		return false
	end

	return slot_component.special_active == true
end

-- Таблица для сбора отладочной информации
local debug_info = {}

-- Получение attachment units с фонариком напрямую (без скрипта)
local function get_flashlight_attachments_3p()
	if not Managers or not Managers.player then
		return nil
	end

	local player = Managers.player:local_player(1)
	if not player then
		return nil
	end

	local player_unit = player.player_unit
	if not player_unit or not Unit.alive(player_unit) then
		return nil
	end

	local visual_loadout_extension = ScriptUnit.has_extension(player_unit, "visual_loadout_system")
	if not visual_loadout_extension then
		return nil
	end

	-- Получаем текущий слот
	local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
	if not unit_data_extension then
		return nil
	end

	local inventory_component = unit_data_extension:read_component("inventory")
	if not inventory_component then
		return nil
	end

	local wielded_slot = inventory_component.wielded_slot
	if not wielded_slot or wielded_slot == "none" or wielded_slot == "slot_unarmed" then
		return nil
	end

	-- Получаем unit_3p и attachments для текущего слота
	local unit_1p, unit_3p, attachments_by_unit_1p, attachments_by_unit_3p = visual_loadout_extension:unit_and_attachments_from_slot(wielded_slot)
	
	-- Собираем отладочную информацию вместо немедленного вывода
	table.clear(debug_info)
	debug_info.wielded_slot = wielded_slot
	debug_info.unit_3p = unit_3p and tostring(unit_3p) or "nil"
	debug_info.has_attachments_by_unit_3p = attachments_by_unit_3p ~= nil
	
	if not unit_3p then
		debug_info.error = "unit_3p is nil"
		return nil
	end
	
	if not attachments_by_unit_3p then
		debug_info.error = "attachments_by_unit_3p is nil"
		return nil
	end

	-- Ищем attachment units с компонентом WeaponFlashlight (ТОЧНО как в исходниках _components)
	local Component = require("scripts/utilities/component")
	local flashlights = {}
	local attachments_3p = attachments_by_unit_3p[unit_3p]
	
	-- СНАЧАЛА проверяем сам unit_3p на наличие компонента WeaponFlashlight
	if unit_3p and Unit.alive(unit_3p) then
		local flash_light_components = Component.get_components_by_name(unit_3p, "WeaponFlashlight")
		debug_info.unit_3p_components = #flash_light_components
		
		for _, flash_light_component in ipairs(flash_light_components) do
			table.insert(flashlights, {
				unit = unit_3p,
				component = flash_light_component,
			})
		end
	end
	
	if not attachments_3p then
		debug_info.error = "attachments_3p is nil"
		return #flashlights > 0 and flashlights or nil
	end
	
	debug_info.num_attachments = #attachments_3p
	debug_info.attachment_details = {}
	
	-- Затем проверяем attachments
	for i = 1, #attachments_3p do
		local attachment_unit = attachments_3p[i]
		if attachment_unit and Unit.alive(attachment_unit) then
			local flash_light_components = Component.get_components_by_name(attachment_unit, "WeaponFlashlight")
			table.insert(debug_info.attachment_details, {
				index = i,
				unit = tostring(attachment_unit),
				num_components = #flash_light_components
			})
			
			for _, flash_light_component in ipairs(flash_light_components) do
				table.insert(flashlights, {
					unit = attachment_unit,
					component = flash_light_component,
				})
			end
		else
			table.insert(debug_info.attachment_details, {
				index = i,
				unit = "nil or not alive",
				num_components = 0
			})
		end
	end

	debug_info.found_flashlights = #flashlights
	return #flashlights > 0 and flashlights or nil
end

-- Обновление каждый кадр
mod.update = function(dt)
	if not mod:get("enable_light") then
		return
	end

	local is_3p = check_third_person_mode()
	
	-- Если в третьем лице - включаем свет третьего лица напрямую через attachment units (ТОЧНО как в _enable_light)
	if is_3p then
		local flashlights_3p = get_flashlight_attachments_3p()
		if flashlights_3p and #flashlights_3p > 0 then
			-- Включаем все фонарики третьего лица (как в _enable_light из исходников)
			for i = 1, #flashlights_3p do
				local flashlight = flashlights_3p[i]
				if flashlight and flashlight.component and flashlight.unit and Unit.alive(flashlight.unit) then
					-- Включаем свет ТОЧНО как в исходниках: flashlight.component:enable(flashlight.unit)
					local success, err = pcall(function()
						flashlight.component:enable(flashlight.unit)
					end)
					if not success then
						mod:echo(string.format("ThirdPersonLight: Error enabling light: %s", tostring(err)))
					end
				end
			end
		end
	end
	
	-- Отладка каждые 10 секунд (собираем информацию, выводим реже)
	local current_time = Managers.time and Managers.time:time("main") or 0
	if not mod._last_debug_time or current_time - mod._last_debug_time > 10.0 then
		mod._last_debug_time = current_time
		
		-- Получаем информацию (это заполнит debug_info)
		local flashlights_3p = get_flashlight_attachments_3p()
		local has_attachments = flashlights_3p ~= nil and #flashlights_3p > 0
		local flashlight_on = is_flashlight_enabled()
		
		-- Выводим собранную информацию через ConsoleLog если доступен
		local console_log_mod = get_mod("ConsoleLog")
		if console_log_mod and console_log_mod.add_log then
			-- Очищаем предыдущие логи ThirdPersonLight
			-- (ConsoleLog сам управляет количеством логов)
			
			-- Выводим основную информацию
			console_log_mod:add_log("ThirdPersonLight", string.format("3P=%s, Flashlight=%s, Enabled=%s",
				tostring(is_3p),
				tostring(flashlight_on),
				tostring(mod:get("enable_light"))
			))
			
			if debug_info.error then
				console_log_mod:add_log("ThirdPersonLight", string.format("ERROR: %s", debug_info.error), {255, 255, 0, 0})
			else
				console_log_mod:add_log("ThirdPersonLight", string.format("WieldedSlot=%s, Unit3P=%s", 
					tostring(debug_info.wielded_slot), 
					tostring(debug_info.unit_3p)))
				console_log_mod:add_log("ThirdPersonLight", string.format("HasAttachmentsByUnit3P=%s, NumAttachments=%s, Unit3PComponents=%s",
					tostring(debug_info.has_attachments_by_unit_3p),
					tostring(debug_info.num_attachments or 0),
					tostring(debug_info.unit_3p_components or 0)
				))
				
				if debug_info.attachment_details and #debug_info.attachment_details > 0 then
					for i = 1, #debug_info.attachment_details do
						local det = debug_info.attachment_details[i]
						console_log_mod:add_log("ThirdPersonLight", string.format("  Att[%d]: unit=%s, components=%d",
							det.index, det.unit, det.num_components))
					end
				end
				
				console_log_mod:add_log("ThirdPersonLight", string.format("Found Flashlights: %d", debug_info.found_flashlights or 0))
				
				if has_attachments then
					for i = 1, #flashlights_3p do
						local f = flashlights_3p[i]
						local unit_alive = f.unit and Unit.alive(f.unit)
						local has_component = f.component ~= nil
						local num_lights = f.unit and Unit.num_lights(f.unit) or 0
						console_log_mod:add_log("ThirdPersonLight", string.format("  Flashlight[%d]: unit_alive=%s, has_component=%s, num_lights=%d",
							i, tostring(unit_alive), tostring(has_component), num_lights))
					end
				end
			end
		else
			-- Fallback на обычный echo если ConsoleLog недоступен
			mod:echo("=== ThirdPersonLight Debug Info ===")
			mod:echo(string.format("3P=%s, Flashlight=%s, Enabled=%s",
				tostring(is_3p),
				tostring(flashlight_on),
				tostring(mod:get("enable_light"))
			))
			if debug_info.error then
				mod:echo(string.format("ERROR: %s", debug_info.error))
			else
				mod:echo(string.format("WieldedSlot=%s, Unit3P=%s", 
					tostring(debug_info.wielded_slot), 
					tostring(debug_info.unit_3p)))
				mod:echo(string.format("HasAttachmentsByUnit3P=%s, NumAttachments=%s, Unit3PComponents=%s",
					tostring(debug_info.has_attachments_by_unit_3p),
					tostring(debug_info.num_attachments or 0),
					tostring(debug_info.unit_3p_components or 0)
				))
				if debug_info.attachment_details and #debug_info.attachment_details > 0 then
					for i = 1, #debug_info.attachment_details do
						local det = debug_info.attachment_details[i]
						mod:echo(string.format("  Att[%d]: unit=%s, components=%d",
							det.index, det.unit, det.num_components))
					end
				end
				mod:echo(string.format("Found Flashlights: %d", debug_info.found_flashlights or 0))
			end
			mod:echo("===================================")
		end
	end
end

-- Обработка изменения настроек
mod.on_setting_changed = function(setting_id)
	-- Настройки обрабатываются автоматически
end

-- Выгрузка мода
mod.on_unload = function(exit_game)
	-- Ничего не нужно очищать
end
