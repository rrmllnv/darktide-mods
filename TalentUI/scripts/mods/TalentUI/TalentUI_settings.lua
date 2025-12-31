local mod = get_mod("TalentUI")

-- Настройки позиционирования иконок способностей
return {
	-- Базовое смещение позиции иконки
	icon_position_offset = 90,
	
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
}

