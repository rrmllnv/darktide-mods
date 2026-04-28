return {
	mod_name = {
		en = "Squad HUD",
		ru = "Squad HUD",
	},
	mod_description = {
		en = "Shows the full squad in four compact panels with class, name, distance/status, toughness, health, and wounds.",
		ru = "Показывает весь отряд в четырёх компактных панелях: класс, имя, дистанция/статус, стойкость, здоровье и ранения.",
	},
	squadhud_layout_group = {
		en = "\238\128\140 DISPLAY",
		ru = "\238\128\140 ОТОБРАЖЕНИЕ",
	},
	squadhud_system_group = {
		en = "\238\128\169 SYSTEM SETTINGS",
		ru = "\238\128\169 СИСТЕМНЫЕ НАСТРОЙКИ",
	},
	squadhud_placement = {
		en = string.rep("\194\160", 8) .. "Position, opacity & scale",
		ru = string.rep("\194\160", 8) .. "Позиция, прозрачность и масштаб",
	},
	position_x = {
		en = "Offset X",
		ru = "Смещение по X",
	},
	position_x_description = {
		en = "Horizontal offset from the top-left screen area in logical pixels. 0 is the left screen edge.",
		ru = "Горизонтальное смещение от верхней левой области экрана в логических пикселях. 0 — левый край экрана.",
	},
	position_y = {
		en = "Offset Y",
		ru = "Смещение по Y",
	},
	position_y_description = {
		en = "Vertical offset from the top-left screen area in logical pixels. 0 is the top screen edge.",
		ru = "Вертикальное смещение от верхней левой области экрана в логических пикселях. 0 — верхний край экрана.",
	},
	opacity = {
		en = "Opacity",
		ru = "Прозрачность",
	},
	hud_scale = {
		en = "Scale",
		ru = "Масштаб",
	},
	hud_scale_description = {
		en = "Scale multiplier applied to the whole Squad HUD. Values below 1 shrink the HUD, values above 1 enlarge it.",
		ru = "Множитель масштаба для всего Squad HUD. Значения меньше 1 уменьшают HUD, больше 1 — увеличивают.",
	},
	squadhud_enabled = {
		en = "Enable Squad HUD",
		ru = "Включить Squad HUD",
	},
	squadhud_enabled_description = {
		en = "Shows the custom four-slot squad panel.",
		ru = "Показывать кастомную панель отряда на четыре слота.",
	},
	squadhud_elements_group = {
		en = "\238\128\178 SQUAD HUD",
		ru = "\238\128\178 SQUAD HUD",
	},
	squadhud_show_class_icon = {
		en = "Class icon",
		ru = "Иконка класса",
	},
	squadhud_show_ability_icon = {
		en = "Ability icon",
		ru = "Иконка способности",
	},
	squadhud_coherency_group = {
		en = string.rep("\194\160", 8) .. "Coherency",
		ru = string.rep("\194\160", 8) .. "Сплоченность (когерентность)",
	},
	squadhud_show_teammate_distance = {
		en = "Meters to teammate",
		ru = "Метры до тимейта",
	},
	squadhud_show_teammate_distance_description = {
		en = "When disabled, the nickname uses the full name block width and the marquee animation recalculates for the wider area.",
		ru = "Если выключено, ник занимает всю ширину блока имени, а карусельная анимация пересчитывается под расширенную область.",
	},
	squadhud_inventory_group = {
		en = string.rep("\194\160", 8) .. "Items",
		ru = string.rep("\194\160", 8) .. "Предметы",
	},
	squadhud_show_grenade = {
		en = "Grenades, blitz",
		ru = "Гранаты, блитц",
	},
	squadhud_show_ammo = {
		en = "Ammo",
		ru = "Патроны",
	},
	squadhud_show_stimm = {
		en = "Stimms",
		ru = "Стимы",
	},
	squadhud_show_medical_crate = {
		en = "Med crate",
		ru = "Мед ящик",
	},
	squadhud_show_ammo_crate = {
		en = "Ammo crate",
		ru = "Ящик боеприпасов",
	},
	squadhud_health_toughness_group = {
		en = string.rep("\194\160", 8) .. "Health and toughness",
		ru = string.rep("\194\160", 8) .. "Здоровье и стойкость",
	},
	squadhud_show_health_value = {
		en = "Health numbers",
		ru = "Цифры здоровья",
	},
	squadhud_show_toughness_value = {
		en = "Toughness numbers",
		ru = "Цифры стойкости",
	},
	debug = {
		en = "Debug",
		ru = "Debug",
	},
	debug_description = {
		en = "Enables internal Squad HUD debug hotkeys. Numpad 1 toggles a long local player name for text animation and mask testing.",
		ru = "Включает внутренние debug-горячие клавиши Squad HUD. Numpad 1 переключает длинный ник локального игрока для проверки анимации текста и маски.",
	},
	squadhud_reset_all_settings = {
		en = "Reset settings",
		ru = "Сбросить настройки",
	},
	squadhud_reset_all_settings_description = {
		en = "Pick the confirm entry and apply. All Squad HUD options return to defaults.",
		ru = "Выберите подтверждение и примените. Все параметры Squad HUD вернутся к значениям по умолчанию.",
	},
	squadhud_reset_confirm = {
		en = "Yes, reset",
		ru = "Да, сбросить",
	},
	squadhud_reset_done = {
		en = "Squad HUD: settings restored to defaults.",
		ru = "Squad HUD: настройки сброшены к значениям по умолчанию.",
	},
	squadhud_status_down = {
		en = "UNCONSCIOUS",
		ru = "БЕЗ СОЗНАНИЯ",
	},
	squadhud_status_dead = {
		en = "DEAD",
		ru = "МЁРТВ",
	},
	squadhud_status_rescue_available = {
		en = "CAN BE RESCUED",
		ru = "МОЖНО СПАСТИ",
	},
	squadhud_status_rescue_available_in = {
		en = "CAN BE RESCUED:",
		ru = "МОЖНО СПАСТИ:",
	},
	squadhud_status_disabled = {
		en = "DISABLED",
		ru = "СХВАЧЕН",
	},
	squadhud_status_pounced = {
		en = "POUNCED BY HOUND",
		ru = "ПОЙМАН ПСОМ",
	},
	squadhud_status_netted = {
		en = "NETTED",
		ru = "ПОЙМАН СЕТЬЮ",
	},
	squadhud_status_warp_grabbed = {
		en = "WARP GRABBED",
		ru = "СХВАЧЕН ВАРПОМ",
	},
	squadhud_status_vortex_grabbed = {
		en = "IN VORTEX",
		ru = "В ВИХРЕ",
	},
	squadhud_status_mutant_charged = {
		en = "GRABBED BY MUTANT",
		ru = "МУТАНТ СХВАТИЛ",
	},
	squadhud_status_consumed = {
		en = "CONSUMED",
		ru = "ПОГЛОЩЁН",
	},
	squadhud_status_grabbed = {
		en = "GRABBED",
		ru = "СХВАЧЕН",
	},
	squadhud_status_ledge_hanging = {
		en = "CAN BE RESCUED",
		ru = "МОЖНО СПАСТИ",
	},
	squadhud_status_luggable = {
		en = "CARRYING OBJECTIVE",
		ru = "НЕСЁТ ГРУЗ",
	},
	squadhud_status_critical_health = {
		en = "CRITICALLY WOUNDED",
		ru = "ТЯЖЕЛО РАНЕН",
	},
	squadhud_status_reviving = {
		en = "REVIVING",
		ru = "РЕАНИМАЦИЯ",
	},
	squadhud_status_rescuing = {
		en = "RESCUE",
		ru = "СПАСЕНИЕ",
	},
	squadhud_empty_name = {
		en = "EMPTY",
		ru = "ПУСТО",
	},
}
