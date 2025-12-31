local mod = get_mod("TalentUI")

-- Настройки позиционирования иконок способностей
return {
	-- Базовое смещение позиции иконки
	icon_position_offset = 210,
	
	-- Дополнительный сдвиг влево/вправо
	icon_position_left_shift = 0,
	
	-- Вертикальное смещение (вверх/вниз)
	icon_position_vertical_offset = -20,
	
	-- Размер иконки (можно переопределить из настроек мода)
	ability_icon_size = 60,

	-- Расстояние между иконками способностей
	ability_spacing = 55,
	
	-- Размер шрифта кулдауна
	cooldown_font_size = 18,
	-- Размер шрифта кулдауна локального игрока
	local_cooldown_font_size = 40,
	
	-- Настройки позиционирования иконок blitz (grenade ability)
	blitz_icon_position_offset = 40,
	blitz_icon_position_left_shift = 60,
	blitz_icon_position_vertical_offset = 0,
	
	-- Показывать способности у ботов
	show_abilities_for_bots = true,
	

	
	-- Настройки intensity и saturation для иконок способностей в зависимости от состояния
	-- Формат: ability_id -> state -> {intensity, saturation}
	-- intensity: -1 (темное) до 1 (яркое), 0 = нормальное
	-- saturation: 0 (черно-белое) до 1 (цветное)
	icon_material_settings = {
		-- ability (combat ability) - боевая способность
		-- Использует 2 состояния: active (готов) и on_cooldown (на кулдауне)
		ability = {
			active = {intensity = 0, saturation = 1}, -- Готов к использованию - яркая и цветная
			on_cooldown = {intensity = -0.5, saturation = 0.5}, -- На кулдауне - темная и менее цветная
			-- Остальные состояния не используются для ability, но оставлены для совместимости
			has_charges_cooldown = {intensity = 0.5, saturation = 1},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.75, saturation = 0.3},
		},
		-- blitz (grenade ability) - гранаты
		-- Использует 2 состояния: active (есть заряды) и out_of_charges_cooldown (нет зарядов)
		blitz = {
			active = {intensity = 0, saturation = 1}, -- Есть заряды - яркая и цветная
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5}, -- Нет зарядов - темная и менее цветная
			-- Остальные состояния не используются для blitz, но оставлены для совместимости
			on_cooldown = {intensity = -0.25, saturation = 1},
			has_charges_cooldown = {intensity = 0.5, saturation = 1},
			inactive = {intensity = -0.75, saturation = 0.3},
		},
		-- aura (coherency ability) - аура
		-- Всегда использует только active (пассивный баф, нет кулдауна и зарядов)
		aura = {
			active = {intensity = 0, saturation = 1}, -- Всегда активна - яркая и цветная
			-- Остальные состояния не используются для aura, но оставлены для совместимости
			on_cooldown = {intensity = -0.25, saturation = 1},
			has_charges_cooldown = {intensity = 0.5, saturation = 1},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.75, saturation = 0.3},
		},
	},
}

