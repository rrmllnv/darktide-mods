-- ОТЛАДОЧНЫЙ ПАТЧ для PerspectivesRedux
-- Вставьте этот код в конец файла PerspectivesRedux.lua

local mod = get_mod("PerspectivesRedux")

-- Команда для проверки текущего состояния
mod.debug_state = function()
	mod:echo("========================================")
	mod:echo("=== PERSPECTIVES REDUX DEBUG STATE ===")
	mod:echo("========================================")
	
	-- Основное состояние
	local requesting_3p = mod.is_requesting_third_person()
	mod:echo("🎥 Requesting 3rd Person: " .. tostring(requesting_3p))
	
	-- Счётчики reasons
	mod:echo("")
	mod:echo("📊 Reasons counters:")
	mod:echo("  Enable count: " .. tostring(enable_reasons_count))
	mod:echo("  Disable count: " .. tostring(disable_reasons_count))
	
	-- Enable reasons
	mod:echo("")
	mod:echo("✅ Enable reasons (forces 3P):")
	local has_enable = false
	for reason, value in pairs(enable_reasons) do
		mod:echo("  • [" .. reason .. "] = " .. tostring(value))
		has_enable = true
	end
	if not has_enable then
		mod:echo("  (none)")
	end
	
	-- Disable reasons
	mod:echo("")
	mod:echo("❌ Disable reasons (forces 1P):")
	local has_disable = false
	for reason, value in pairs(disable_reasons) do
		mod:echo("  • [" .. reason .. "] = " .. tostring(value))
		has_disable = true
	end
	if not has_disable then
		mod:echo("  (none)")
	end
	
	-- Autoswitch events
	mod:echo("")
	mod:echo("🔄 Autoswitch events configuration:")
	for event, mode in pairs(autoswitch_events) do
		local mode_text = mode == 0 and "None" or (mode == 1 and "→ 1P" or "→ 3P")
		mod:echo("  • [" .. event .. "] = " .. mode_text)
	end
	
	-- Текущие настройки
	mod:echo("")
	mod:echo("⚙️ Current settings:")
	mod:echo("  allow_switching: " .. tostring(mod:get("allow_switching")))
	mod:echo("  default_perspective_mode: " .. tostring(mod:get("default_perspective_mode")))
	mod:echo("  aim_mode: " .. tostring(cached_settings.aim_selection))
	mod:echo("  nonaim_mode: " .. tostring(cached_settings.nonaim_selection))
	mod:echo("  current_viewpoint: " .. tostring(current_viewpoint))
	
	-- Состояние
	mod:echo("")
	mod:echo("🎮 Current state:")
	mod:echo("  is_spectating: " .. tostring(is_spectating))
	mod:echo("  holding_primary: " .. tostring(holding_primary))
	mod:echo("  holding_secondary: " .. tostring(holding_secondary))
	mod:echo("  use_3p_freelook_node: " .. tostring(use_3p_freelook_node))
	
	mod:echo("========================================")
end

-- Улучшенный хук на смену слота
mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
	mod:echo("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	mod:echo("🔧 SLOT WIELDED: " .. tostring(slot_name))
	
	-- Проверяем настройку
	local setting_key = "autoswitch_" .. slot_name
	local setting_value = mod:get(setting_key)
	local setting_text = "Not found"
	if setting_value == 0 then
		setting_text = "None"
	elseif setting_value == 1 then
		setting_text = "To First Person"
	elseif setting_value == 2 then
		setting_text = "To Third Person"
	end
	mod:echo("⚙️ Setting: " .. setting_key .. " = " .. setting_text)
	
	-- Проверяем autoswitch_events
	if autoswitch_events[slot_name] ~= nil then
		local mode = autoswitch_events[slot_name]
		local mode_text = mode == 0 and "None" or (mode == 1 and "→ 1P" or "→ 3P")
		mod:echo("🔄 Autoswitch mode: " .. mode_text)
	else
		mod:echo("❌ WARNING: autoswitch_events[" .. slot_name .. "] = NIL!")
	end
	
	-- Проверяем состояние ДО
	local before_3p = mod.is_requesting_third_person()
	mod:echo("🎥 Before: " .. (before_3p and "3P" or "1P"))
	
	-- Показываем reasons ДО
	mod:echo("📊 Enable reasons count: " .. tostring(enable_reasons_count))
	mod:echo("📊 Disable reasons count: " .. tostring(disable_reasons_count))
end)

-- Хук ПОСЛЕ обработки autoswitch
local original_autoswitch_from_event = _autoswitch_from_event
_autoswitch_from_event = function(reason, event, condition)
	local result = original_autoswitch_from_event(reason, event, condition)
	
	-- Логируем результат
	if event then
		-- Проверяем состояние ПОСЛЕ
		local after_3p = mod.is_requesting_third_person()
		mod:echo("🎥 After: " .. (after_3p and "3P" or "1P"))
		mod:echo("📊 Enable reasons count: " .. tostring(enable_reasons_count))
		mod:echo("📊 Disable reasons count: " .. tostring(disable_reasons_count))
		
		if enable_reasons[reason] then
			mod:echo("✅ Added enable reason: [" .. reason .. "]")
		end
		if disable_reasons[reason] then
			mod:echo("❌ Added disable reason: [" .. reason .. "]")
		end
		
		mod:echo("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	end
	
	return result
end

mod:echo("🐛 DEBUG MODE ENABLED for PerspectivesRedux")
mod:echo("💡 Type: /mod PerspectivesRedux debug_state")
mod:echo("💡 Slot changes will be logged to chat")

