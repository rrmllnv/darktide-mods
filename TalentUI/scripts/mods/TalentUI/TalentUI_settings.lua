local mod = get_mod("TalentUI")

-- Настройки позиционирования иконок способностей
return {
	-- Базовое смещение позиции иконки (как у цифр в NumericUI)
	icon_position_offset = 90,
	
	-- Дополнительный сдвиг влево/вправо
	icon_position_left_shift = 0,
	
	-- Вертикальное смещение (вверх/вниз)
	icon_position_vertical_offset = -20,
	
	-- Размер иконки (можно переопределить из настроек мода)
	ability_icon_size = 128,
	
	-- Размер шрифта кулдауна
	cooldown_font_size = 18,
	-- Размер шрифта кулдауна локального игрока
	local_cooldown_font_size = 30,
}

