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
	squadhud_expanded_view_group = {
		en = "\238\128\171 EXPANDED VIEW",
		ru = "\238\128\171 РАСШИРЕННЫЙ ВИД",
	},
	squadhud_expanded_view_mode = {
		en = "Expanded squad view",
		ru = "Расширенный вид отряда",
	},
	squadhud_expanded_view_mode_description = {
		en = "Controls how much extra squad HUD information is visible by default.",
		ru = "Определяет, сколько дополнительных данных HUD отряда видно по умолчанию.",
	},
	squadhud_expanded_view_mode_short = {
		en = "Short",
		ru = "Короткий",
	},
	squadhud_expanded_view_mode_full = {
		en = "Full",
		ru = "Полный",
	},
	squadhud_expanded_view_keybind = {
		en = "Show expanded view",
		ru = "Показать расширенный вид",
	},
	squadhud_expanded_view_keybind_description = {
		en = "Shows account names, platform icons, and additional squad HUD details according to the selected key mode.",
		ru = "Показывает имена аккаунтов, иконки платформ и дополнительные данные HUD отряда по выбранному режиму клавиши.",
	},
	squadhud_expanded_view_keybind_mode = {
		en = "Expanded view key mode",
		ru = "Режим клавиши расширенного вида",
	},
	squadhud_expanded_view_keybind_mode_description = {
		en = "Toggle switches expanded squad view on/off. Hold shows it only while the key is held.",
		ru = "Toggle переключает расширенный вид отряда вкл/выкл. Hold показывает его только пока клавиша удерживается.",
	},
	squadhud_expanded_view_keybind_mode_toggle = {
		en = "Toggle",
		ru = "Toggle",
	},
	squadhud_expanded_view_keybind_mode_hold = {
		en = "Hold",
		ru = "Hold",
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
	squadhud_panel_display_mode = {
		en = "Visible panels",
		ru = "Отображаемые панели",
	},
	squadhud_panel_display_mode_description = {
		en = "Controls which Squad HUD panels are shown. Teammates-only mode packs teammate panels into the lower slots so the layout keeps the same visual anchor.",
		ru = "Определяет, какие панели Squad HUD показывать. В режиме только тимейтов панели сдвигаются в нижние слоты, чтобы сохранить визуальную привязку.",
	},
	squadhud_panel_display_mode_all = {
		en = "Full squad",
		ru = "Весь сквад",
	},
	squadhud_panel_display_mode_local = {
		en = "Only me",
		ru = "Только я",
	},
	squadhud_panel_display_mode_teammates = {
		en = "Only teammates",
		ru = "Только тимейты",
	},
	squadhud_elements_group = {
		en = "\238\128\178 SQUAD HUD",
		ru = "\238\128\178 SQUAD HUD",
	},
	squadhud_show_class_icon = {
		en = "Show class icon",
		ru = "Показать иконку класса",
	},
	squadhud_show_ability_icon = {
		en = "Show ability icon",
		ru = "Показать иконку способности",
	},
	squadhud_show_teammate_level = {
		en = "Show player total level",
		ru = "Показать общий уровень игроков",
	},
	squadhud_show_teammate_level_description = {
		en = "Shows the total level next to the nickname. The total level is calculated from the character progression data exposed by the game backend.",
		ru = "Показывает общий уровень рядом с ником. Общий уровень считается из данных прогресса персонажа, которые отдает игровой backend.",
	},
	squadhud_coherency_group = {
		en = string.rep("\194\160", 8) .. "Coherency",
		ru = string.rep("\194\160", 8) .. "Сплоченность (когерентность)",
	},
	squadhud_show_teammate_distance = {
		en = "Show meters to teammate",
		ru = "Показать метры до тимейта",
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
		en = "Show grenade/blitz icon",
		ru = "Показать иконку гранаты/блитца",
	},
	squadhud_grenade_value_mode = {
		en = "When to show grenade/blitz value",
		ru = "Когда показывать значение гранаты/блитца",
	},
	squadhud_grenade_value_mode_description = {
		en = "Controls when the grenade/blitz value text is shown next to the grenade/blitz icon.",
		ru = "Определяет, когда рядом с иконкой гранаты/блитца показывать текст со значением гранаты/блитца.",
	},
	squadhud_grenade_value_mode_never = {
		en = "Never",
		ru = "Никогда",
	},
	squadhud_grenade_value_mode_always = {
		en = "Always",
		ru = "Всегда",
	},
	squadhud_grenade_value_mode_changed = {
		en = "When changed",
		ru = "Когда они изменяются",
	},
	squadhud_show_ammo = {
		en = "Show ammo icon",
		ru = "Показать иконку патронов",
	},
	squadhud_ammo_value_format = {
		en = "Ammo value format",
		ru = "Формат значения патронов",
	},
	squadhud_ammo_value_format_description = {
		en = "Select whether the ammo value is shown as a percentage, as the current ammo count only, or as current count divided by maximum reserve.",
		ru = "Выберите формат: проценты, только текущее количество патронов или текущее / максимальное количество.",
	},
	squadhud_ammo_value_format_percent = {
		en = "Percentage",
		ru = "Проценты",
	},
	squadhud_ammo_value_format_count = {
		en = "Ammo count",
		ru = "Количество патронов",
	},
	squadhud_ammo_value_format_current_max = {
		en = "Current / max ammo",
		ru = "Текущие / все патроны",
	},
	squadhud_ammo_percent_mode = {
		en = "When to show ammo value",
		ru = "Когда показывать значение патронов",
	},
	squadhud_ammo_percent_mode_description = {
		en = "Controls when the ammo value text is shown next to the ammo icon.",
		ru = "Определяет, когда рядом с иконкой патронов показывать текст со значением патронов.",
	},
	squadhud_ammo_percent_mode_never = {
		en = "Never",
		ru = "Никогда",
	},
	squadhud_ammo_percent_mode_always = {
		en = "Always",
		ru = "Всегда",
	},
	squadhud_ammo_percent_mode_changed = {
		en = "When changed",
		ru = "Когда они изменяются",
	},
	squadhud_show_stimm = {
		en = "Show stimm icon",
		ru = "Показать иконку стима",
	},
	squadhud_show_medical_crate = {
		en = "Show med crate icon",
		ru = "Показать иконку медицинского ящика",
	},
	squadhud_show_ammo_crate = {
		en = "Show ammo crate icon",
		ru = "Показать иконку ящика боеприпасов",
	},
	squadhud_health_toughness_group = {
		en = string.rep("\194\160", 8) .. "Health and toughness",
		ru = string.rep("\194\160", 8) .. "Здоровье и стойкость",
	},
	squadhud_show_health_value = {
		en = "Show health numbers",
		ru = "Показать цифры здоровья",
	},
	squadhud_show_toughness_value = {
		en = "Show toughness numbers",
		ru = "Показать цифры стойкости",
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
