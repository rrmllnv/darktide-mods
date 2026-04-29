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
	squadhud_integrations_group = {
		en = "\238\128\172 INTEGRATIONS",
		ru = "\238\128\172 ИНТЕГРАЦИИ",
	},
	integration_custom_hud = {
		en = "Custom HUD",
		ru = "Custom HUD",
	},
	integration_custom_hud_description = {
		en = "Allows Custom HUD to control Squad HUD scenegraph nodes. When Custom HUD has saved Squad HUD nodes, the Offset X and Offset Y sliders are not applied.",
		ru = "Позволяет Custom HUD управлять scenegraph-узлами Squad HUD. Если Custom HUD сохранил узлы Squad HUD, смещения X и Y из настроек не применяются.",
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
	squadhud_show_teammate_level = {
		en = "Teammate total level",
		ru = "Общий уровень тимейта",
	},
	squadhud_show_teammate_level_description = {
		en = "Shows the teammate total level next to the nickname. Uses True Level data when available, otherwise falls back to the character level exposed by the game profile.",
		ru = "Показывает общий уровень тимейта рядом с ником. Использует данные True Level, если они доступны, иначе берет уровень персонажа из игрового профиля.",
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
	squadhud_strike_team_group = {
		en = "\238\128\171 STRIKE TEAM",
		ru = "\238\128\171 УДАРНАЯ ГРУППА",
	},
	squadhud_show_status_rescuing = {
		en = "RESCUE",
		ru = "СПАСЕНИЕ",
	},
	squadhud_show_status_rescuing_description = {
		en = "Shows when a teammate is being rescued from a non-downed disabled state.",
		ru = "Показывать, когда тимейта спасают из состояния, где нужна помощь, но это не реанимация.",
	},
	squadhud_show_status_reviving = {
		en = "REVIVING",
		ru = "РЕАНИМАЦИЯ",
	},
	squadhud_show_status_reviving_description = {
		en = "Shows when a downed teammate is being revived.",
		ru = "Показывать, когда тимейта поднимают из состояния без сознания.",
	},
	squadhud_show_status_rescue_available = {
		en = "CAN BE RESCUED: N",
		ru = "МОЖНО СПАСТИ: N",
	},
	squadhud_show_status_rescue_available_description = {
		en = "Shows the rescue availability status for dead or hogtied teammates, including the countdown when the game provides one.",
		ru = "Показывать статус спасения для погибшего или связанного тимейта, включая счетчик, если игра его отдает.",
	},
	squadhud_show_status_dead = {
		en = "DEAD",
		ru = "МЁРТВ",
	},
	squadhud_show_status_dead_description = {
		en = "Shows when a teammate is dead and the game does not provide a rescue timer.",
		ru = "Показывать, когда тимейт мертв и игра не отдает счетчик до спасения.",
	},
	squadhud_show_status_unconscious = {
		en = "UNCONSCIOUS",
		ru = "БЕЗ СОЗНАНИЯ",
	},
	squadhud_show_status_unconscious_description = {
		en = "Shows when a teammate is knocked down and needs reviving.",
		ru = "Показывать, когда тимейт без сознания и его нужно реанимировать.",
	},
	squadhud_show_status_disabled = {
		en = "IMMOBILIZED",
		ru = "ОБЕЗДВИЖЕН",
	},
	squadhud_show_status_disabled_description = {
		en = "Shows the generic disabled fallback when the game does not expose a more specific disabled state.",
		ru = "Показывать общий статус обездвиживания, когда игра не отдает более точное состояние.",
	},
	squadhud_show_status_pounced = {
		en = "POUNCED BY HOUND",
		ru = "ПОЙМАН ПСОМ",
	},
	squadhud_show_status_pounced_description = {
		en = "Shows when a teammate is pinned by a hound.",
		ru = "Показывать, когда тимейта поймала собака.",
	},
	squadhud_show_status_netted = {
		en = "NETTED",
		ru = "ПОЙМАН СЕТЬЮ",
	},
	squadhud_show_status_netted_description = {
		en = "Shows when a teammate is trapped in a trapper net.",
		ru = "Показывать, когда тимейт пойман сетью траппера.",
	},
	squadhud_show_status_warp_grabbed = {
		en = "WARP GRABBED",
		ru = "СХВАЧЕН ВАРПОМ",
	},
	squadhud_show_status_warp_grabbed_description = {
		en = "Shows when a teammate is grabbed by a warp effect.",
		ru = "Показывать, когда тимейта схватил варп-эффект.",
	},
	squadhud_show_status_vortex_grabbed = {
		en = "IN VORTEX",
		ru = "В ВИХРЕ",
	},
	squadhud_show_status_vortex_grabbed_description = {
		en = "Shows when a teammate is caught in a vortex.",
		ru = "Показывать, когда тимейт находится в вихре.",
	},
	squadhud_show_status_mutant_charged = {
		en = "GRABBED BY MUTANT",
		ru = "МУТАНТ СХВАТИЛ",
	},
	squadhud_show_status_mutant_charged_description = {
		en = "Shows when a mutant has grabbed a teammate.",
		ru = "Показывать, когда мутант схватил тимейта.",
	},
	squadhud_show_status_consumed = {
		en = "CONSUMED",
		ru = "ПОГЛОЩЁН",
	},
	squadhud_show_status_consumed_description = {
		en = "Shows when a teammate is swallowed by a Beast of Nurgle.",
		ru = "Показывать, когда тимейта поглотил зверь Нургла.",
	},
	squadhud_show_status_grabbed = {
		en = "GRABBED",
		ru = "СХВАЧЕН",
	},
	squadhud_show_status_grabbed_description = {
		en = "Shows when a teammate is grabbed by an enemy disabled state.",
		ru = "Показывать, когда тимейта схватил враг.",
	},
	squadhud_show_status_ledge_hanging = {
		en = "LEDGE HANGING",
		ru = "МОЖНО СПАСТИ",
	},
	squadhud_show_status_ledge_hanging_description = {
		en = "Shows when a teammate is hanging from a ledge and can be rescued.",
		ru = "Показывать, когда тимейт висит на уступе и его можно спасти.",
	},
	squadhud_show_status_critical_health = {
		en = "CRITICALLY WOUNDED",
		ru = "ТЯЖЕЛО РАНЕН",
	},
	squadhud_show_status_critical_health_description = {
		en = "Shows when a teammate has critically low health.",
		ru = "Показывать, когда у тимейта критически мало здоровья.",
	},
	squadhud_show_status_luggable = {
		en = "CARRYING OBJECTIVE",
		ru = "НЕСЁТ ГРУЗ",
	},
	squadhud_show_status_luggable_description = {
		en = "Shows when a teammate is carrying a luggable objective item.",
		ru = "Показывать, когда тимейт несет переносимый груз цели.",
	},
	squadhud_vanilla_hud_group = {
		en = "\238\128\161 VANILLA HUD",
		ru = "\238\128\161 ВАНИЛЬНЫЙ HUD",
	},
	hide_vanilla_team_panel_local = {
		en = "Hide local player panel",
		ru = "Скрыть панель локального игрока",
	},
	hide_vanilla_team_panel_teammates = {
		en = "Hide teammate panels",
		ru = "Скрыть панели тимейтов",
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
		en = "IMMOBILIZED",
		ru = "ОБЕЗДВИЖЕН",
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
