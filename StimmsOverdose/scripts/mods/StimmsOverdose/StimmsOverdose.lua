local mod = get_mod("StimmsOverdose")

local STIMM_SLOT_NAME = "slot_pocketable_small"
local STIMM_ABILITY_TYPE = "pocketable_ability"

local function get_buff_remaining_time(buff_extension, buff_template_name)
	if not buff_extension then
		return 0
	end

	local buffs_by_index = buff_extension._buffs_by_index
	if not buffs_by_index then
		return 0
	end

	local timer = 0
	for _, buff in pairs(buffs_by_index) do
		if buff then
			local template = buff:template()
			if template and template.name == buff_template_name then
				local remaining = buff:duration_progress() or 1
				local duration = buff:duration() or 15
				timer = math.max(timer, duration * remaining)
			end
		end
	end

	return timer
end

mod:hook("PlayerUnitVisualLoadoutExtension", "unequip_item_from_slot", function(func, self, slot_name, fixed_frame)
	-- Если это не слот стимулятора, выполняем как обычно


	if not slot_name or slot_name ~= STIMM_SLOT_NAME then
		return func(self, slot_name, fixed_frame)
	end


	
	local player_unit = self._unit
	if not player_unit then
		return func(self, slot_name, fixed_frame)
	end

	-- Проверяем активный бафф стимулятора (все типы: желтый, синий, красный, розовый)
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
	local has_active_buff = false
	if buff_extension then
		-- Проверяем все типы стимуляторов
		local buff_names = {
			"syringe_broker_buff",        -- розовый (брокер)
			"syringe_ability_boost_buff", -- желтый (ability)
			"syringe_speed_boost_buff",    -- синий (speed)
			"syringe_power_boost_buff",    -- красный (power)
		}
		
		for _, buff_name in ipairs(buff_names) do
			local remaining_buff_time = get_buff_remaining_time(buff_extension, buff_name)
			if remaining_buff_time and remaining_buff_time >= 0.05 then
				has_active_buff = true
				break
			end
		end
	end
	
	-- Проверяем кулдаун стимулятора
	local ability_extension = ScriptUnit.has_extension(player_unit, "ability_system")
	local has_cooldown = false
	if ability_extension then
		local remaining_cooldown = ability_extension:remaining_ability_cooldown(STIMM_ABILITY_TYPE)
		if remaining_cooldown and remaining_cooldown ~= math.huge and remaining_cooldown >= 0.05 then
			has_cooldown = true
		else
			-- Проверяем напрямую через компонент
			local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
			if unit_data_extension then
				local ability_component = unit_data_extension:read_component(STIMM_ABILITY_TYPE)
				if ability_component then
					local component_cooldown = ability_component.cooldown
					if component_cooldown and component_cooldown > 0 then
						local FixedFrame = require("scripts/utilities/fixed_frame")
						local fixed_frame_t = FixedFrame.get_latest_fixed_time()
						local remaining = math.max(component_cooldown - fixed_frame_t, 0)
						has_cooldown = remaining >= 0.05
					end
				end
			end
		end
	end
	
	-- Если есть активный бафф или кулдаун, НЕ очищаем слот
	if has_active_buff or has_cooldown then
		return
	end
	
	-- Если нет баффа и кулдауна, очищаем слот как обычно
	return func(self, slot_name, fixed_frame)
end)
