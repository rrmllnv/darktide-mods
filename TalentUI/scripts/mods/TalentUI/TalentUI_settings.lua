local mod = get_mod("TalentUI")

-- Настройки позиционирования иконок способностей
return {
	-- Базовое смещение позиции иконки
	icon_position_offset = 200,
	
	-- Дополнительный сдвиг влево/вправо
	icon_position_left_shift = 0,
	
	-- Вертикальное смещение (вверх/вниз)
	icon_position_vertical_offset = -20,
	
	-- Размер иконки (можно переопределить из настроек мода)
	ability_icon_size = 60,
	
	-- Размер шрифта кулдауна
	cooldown_font_size = 18,
	-- Размер шрифта кулдауна локального игрока
	local_cooldown_font_size = 40,
	
	-- Настройки позиционирования иконок blitz (grenade ability)
	blitz_icon_position_offset = 40,
	blitz_icon_position_left_shift = 60,
	blitz_icon_position_vertical_offset = 0,
	
	-- Настройки intensity и saturation для иконок способностей в зависимости от состояния
	-- Формат: ability_id -> state -> {intensity, saturation}
	icon_material_settings = {
		ability = {
			active = {intensity = 1, saturation = 1},
			on_cooldown = {intensity = -0.25, saturation = 1},
			has_charges_cooldown = {intensity = 0.5, saturation = 1},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.75, saturation = 0.3},
		},
		blitz = {
			active = {intensity = 1, saturation = 1},
			on_cooldown = {intensity = -0.25, saturation = 1},
			has_charges_cooldown = {intensity = 0.5, saturation = 1},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.75, saturation = 0.3},
		},
		aura = {
			active = {intensity = 1, saturation = 1},
			on_cooldown = {intensity = -0.25, saturation = 1},
			has_charges_cooldown = {intensity = 0.5, saturation = 1},
			out_of_charges_cooldown = {intensity = -0.5, saturation = 0.5},
			inactive = {intensity = -0.75, saturation = 0.3},
		},
	},
}

