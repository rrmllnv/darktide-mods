return {
	mod_name = {
		en = "Division HUD",
		ru = "Division HUD",
		["zh-cn"] = "全境封锁风格 HUD",
	},
	mod_description = {
		en = "Adds extra combat HUD styled like The Division.",
		ru = "Добавляет дополнительный боевой HUD в стиле The Division.",
		["zh-cn"] = "添加《全境封锁》风格的额外战斗界面。",
	},
	divisionhud_super_layout = {
		en = "\238\128\140 DISPLAY",
		ru = "\238\128\140 ОТОБРАЖЕНИЕ",
		["zh-cn"] = "\238\128\140 显示设置",
	},
	position_x = {
		en = "Offset X",
		ru = "Смещение по X",
		["zh-cn"] = "水平偏移 X",
	},
	position_x_description = {
		en = "Horizontal offset from the screen center in logical pixels (reference canvas 1920×1080). Range ±960. Negative moves the HUD left, positive moves it right. The root block is center-aligned.",
		ru = "Горизонтальное смещение от центра экрана в логических пикселях (эталонный холст 1920×1080). Диапазон ±960. Отрицательные значения — влево, положительные — вправо. Корневой блок привязан к центру экрана.",
		["zh-cn"] = "以屏幕中心为基准的水平偏移（参考分辨率 1920×1080），范围 ±960。负值左移，正值右移。根节点默认居中。",
	},
	position_y = {
		en = "Offset Y",
		ru = "Смещение по Y",
		["zh-cn"] = "垂直偏移 Y",
	},
	position_y_description = {
		en = "Vertical offset from the screen center in logical pixels (reference canvas 1920×1080). Range ±540. Negative moves the HUD up, positive moves it down. The root block is center-aligned.",
		ru = "Вертикальное смещение от центра экрана в логических пикселях (эталонный холст 1920×1080). Диапазон ±540. Отрицательные значения — вверх, положительные — вниз. Корневой блок привязан к центру экрана.",
		["zh-cn"] = "以屏幕中心为基准的垂直偏移（参考分辨率 1920×1080），范围 ±540。负值上移，正值下移。根节点默认居中。",
	},
	opacity = {
		en = "Opacity",
		ru = "Прозрачность",
		["zh-cn"] = "不透明度",
	},
	divisionhud_super_bars = {
		en = "\238\128\178 COMBAT HUD",
		ru = "\238\128\178 БОЕВОЙ HUD",
		["zh-cn"] = "\238\128\178 战斗界面",
	},
	show_stamina_bar = {
		en = "Stamina and dodge bar",
		ru = "Полоса стамины и уворотов",
		["zh-cn"] = "体力与闪避条",
	},
	show_toughness_bar = {
		en = "Toughness bar",
		ru = "Полоса стойкости",
		["zh-cn"] = "韧性条",
	},
	show_health_bar = {
		en = "Health bar",
		ru = "Полоса здоровья",
		["zh-cn"] = "生命值条",
	},
	show_ability_timer = {
		en = "Ability bar",
		ru = "Полоса способности",
		["zh-cn"] = "技能冷却条",
	},
	stimm_slot_icon_tint_by_type = {
		en = "Color pocket stimm icon",
		ru = "Цвет иконки шприца",
		["zh-cn"] = "注射器图标按类型着色",
	},
	stimm_slot_icon_tint_by_type_description = {
		en = "When enabled, the pocket stimm icon in the Division HUD strip is tinted by syringe template (speed, power, corruption cleanse, ability boost, broker syringe, etc.) using built-in colors. When off, the icon uses the default white tint.",
		ru = "Если включено, иконка карманного шприца в полоске Division HUD окрашивается по шаблону шприца (скорость, сила, снятие порчи, усиление способности, шприц брокера и т.д.) встроенными цветами. Если выключено — обычный белый тон.",
		["zh-cn"] = "启用后，根据注射器类型（速度、力量、腐蚀清除、技能强化、巢都渣滓注射器等）使用内置颜色为图标着色。关闭时使用默认白色。",
	},
	ammo_text_color_by_fraction = {
		en = "Ammo text color by remaining fraction",
		ru = "Цвет патронов по доле боезапаса",
		["zh-cn"] = "弹药文字按剩余比例变色",
	},
	ammo_text_color_by_fraction_description = {
		en = "When enabled, the large ammo numbers tint by total ammo fraction: above 75% main, above 50% low, above 25% medium, 25% or less high. When off, they use the default main color.",
		ru = "Если включено, крупные цифры патронов окрашиваются по доле боезапаса: выше 75% — основной цвет; выше 50% и не выше 75% — низкий запас; выше 25% и не выше 50% — средний; 25% и ниже — критический. Если выключено — обычный основной цвет.",
		["zh-cn"] = "启用后，大号弹药数字按剩余比例变色：75%以上为主色，50%–75%为低量色，25%–50%为中量色，25%及以下为警告色。关闭时使用默认主色。",
	},
	ammo_size_big = {
		en = "big",
		ru = "big",
		["zh-cn"] = "big",
	},
	grenade_color_by_fraction = {
		en = "Grenade slot color by charge fraction",
		ru = "Цвет гранаты по доле зарядов",
		["zh-cn"] = "手雷槽按充能比例着色",
	},
	grenade_color_by_fraction_description = {
		en = "When enabled, the grenade ability slot icon and counter tint by remaining charges, using the same color bands and fraction thresholds as the large ammo numbers. When off, the slot uses the default colors.",
		ru = "Если включено, иконка и счётчик слота гранаты окрашиваются по доле оставшихся зарядов — те же цветовые полосы и пороги доли, что у крупного текста патронов. Если выключено — цвета по умолчанию.",
		["zh-cn"] = "启用后，手雷图标与计数按剩余充能比例着色，规则与弹药数字一致。关闭时使用默认颜色。",
	},
	wielded_weapon_icon_state_colors = {
		en = "Current weapon icon colors",
		ru = "Цвет текущего оружия",
		["zh-cn"] = "当前武器图标按状态着色",
	},
	wielded_weapon_icon_state_colors_description = {
		en = "When enabled, tints the wielded-weapon strip icon for weapons included in this mod's internal list by inactive, active, and optional cooldown states. Other weapons stay full white.",
		ru = "Если включено, для оружия из внутреннего списка мода окрашивает иконку текущего оружия в полоске Division HUD по неактивному, активному и при необходимости кулдауну. Для остального оружия остаётся обычный белый.",
		["zh-cn"] = "启用后，模组支持的武器会按未激活、激活、冷却状态变色，其他武器保持白色。",
	},
	divisionhud_super_dynamic = {
		en = "\238\129\135 DYNAMIC HUD",
		ru = "\238\129\135 ДИНАМИЧЕСКИЙ HUD",
		["zh-cn"] = "\238\129\135 动态界面",
	},
	dynamic_hud = {
		en = "Dynamic HUD",
		ru = "Динамический HUD",
		["zh-cn"] = "动态界面",
	},
	dynamic_hud_strength = {
		en = "HUD shift strength",
		ru = "Сила сдвига HUD",
		["zh-cn"] = "界面偏移强度",
	},
	dynamic_hud_pitch_ratio = {
		en = "Vertical ratio",
		ru = "Вертикаль относительно горизонтали",
		["zh-cn"] = "垂直偏移比例",
	},
	dynamic_hud_decay = {
		en = "Return speed",
		ru = "Скорость возврата",
		["zh-cn"] = "界面回弹速度",
	},
	dynamic_hud_max_offset = {
		en = "Max offset",
		ru = "Макс. смещение",
		["zh-cn"] = "界面最大偏移量",
	},
	dynamic_hud_freeze_on_ads = {
		en = "Freeze when aiming",
		ru = "Стабилизировать при прицеливании",
		["zh-cn"] = "瞄准时锁定界面",
	},
	dynamic_hud_freeze_on_ads_description = {
		en = "Freezes HUD movement while aiming down sights (works with mouse and controllers).",
		ru = "Фиксирует динамику HUD при прицеливании. Работает с мышью и геймпадом.",
		["zh-cn"] = "瞄准时锁定界面偏移（支持鼠标和手柄）。",
	},
	divisionhud_super_vanilla_hide = {
		en = "\238\128\161 VANILLA HUD",
		ru = "\238\128\161 ВАНИЛЬНЫЙ HUD",
		["zh-cn"] = "\238\128\161 原版界面",
	},
	hide_vanilla_team_panel_local = {
		en = "Hide local player panel",
		ru = "Скрыть панель локального игрока",
		["zh-cn"] = "隐藏本地玩家面板",
	},
	hide_vanilla_stamina_area = {
		en = "Hide stamina",
		ru = "Скрыть стамину",
		["zh-cn"] = "隐藏体力条",
	},
	hide_vanilla_dodge_area = {
		en = "Hide dodges",
		ru = "Скрыть увороты",
		["zh-cn"] = "隐藏闪避计数",
	},
	hide_vanilla_weapon_pivot = {
		en = "Hide weapons",
		ru = "Скрыть оружие",
		["zh-cn"] = "隐藏武器显示",
	},
	hide_vanilla_combat_ability_slot = {
		en = "Hide combat ability",
		ru = "Скрыть боевую способность",
		["zh-cn"] = "隐藏战斗技能",
	},
	hide_vanilla_player_buffs_background = {
		en = "Hide buffs",
		ru = "Скрыть баффы",
		["zh-cn"] = "隐藏增益效果",
	},
	hide_vanilla_mission_objectives = {
		en = "Hide mission objectives",
		ru = "Скрыть цели миссии",
		["zh-cn"] = "隐藏任务目标",
	},
	hide_vanilla_mission_objectives_description = {
		en = "When enabled, only the center mission objective popups are hidden; the objective feed (including the area strip) keeps drawing. Use the Mission objectives section to mirror selected popup events into the Division HUD notification strip.",
		ru = "Если включено, скрываются только центральные всплывающие окна целей; лента целей (включая область area) продолжает отображаться. В блоке «Цели миссии» можно дублировать выбранные события попапов в полоску оповещений Division HUD.",
		["zh-cn"] = "启用后仅隐藏中央任务弹窗，目标条带仍保留。可在任务目标设置中，将弹窗事件同步显示到 Division HUD 提示栏。",
	},
	alerts_super = {
		en = "\238\128\161 ALERTS",
		ru = "\238\128\161 ОПОВЕЩЕНИЯ",
		["zh-cn"] = "\238\128\161 警报",
	},
	alerts_enabled = {
		en = "Enable approach alerts",
		ru = "Включить оповещения о приближении",
		["zh-cn"] = "启用敌人接近警报",
	},
	alerts_max_visible = {
		en = "Maximum simultaneous alerts",
		ru = "Максимум одновременных оповещений",
		["zh-cn"] = "同时显示警报上限",
	},
	alerts_duration_sec = {
		en = "Alert duration (seconds)",
		ru = "Время показа оповещения (сек.)",
		["zh-cn"] = "警报显示时长（秒）",
	},
	alerts_show_duration_bar = {
		en = "Alert display time bar",
		ru = "Полоса времени показа оповещения",
		["zh-cn"] = "显示警报持续时间条",
	},
	alerts_group_bosses = {
		en = string.rep("\194\160", 8) .. "Bosses",
		ru = string.rep("\194\160", 8) .. "Боссы",
		["zh-cn"] = string.rep("\194\160", 8) .. "首领",
	},
	alerts_group_specialists = {
		en = string.rep("\194\160", 8) .. "Specialists",
		ru = string.rep("\194\160", 8) .. "Специалисты",
		["zh-cn"] = string.rep("\194\160", 8) .. "专家",
	},
	mission_objectives_super = {
		en = string.rep("\194\160", 8) .. "Mission objectives",
		ru = string.rep("\194\160", 8) .. "Цели миссии",
		["zh-cn"] = string.rep("\194\160", 8) .. "任务目标",
	},
	mission_objectives_super_description = {
		en = "When «Hide mission objectives» is on (VANILLA HUD section), these toggles choose which objective events appear in the Division HUD strip (title row + body; same look as enemy approach notifications).",
		ru = "Когда включено «Скрыть цели миссии» (супергруппа «Ванильный HUD»), эти переключатели задают, какие события целей показывать в полоске оповещений Division HUD (заголовок в полоске + текст цели, оформление как при оповещении о приближении).",
		["zh-cn"] = "在原版界面设置中启用“隐藏任务目标”后，可通过这些开关选择哪些事件显示在 Division HUD 提示栏。",
	},
	alert_mission_objective_start = {
		en = "New objective",
		ru = "Новая цель",
		["zh-cn"] = "新目标",
	},
	alert_mission_objective_start_description = {
		en = "When enabled, show in the Division HUD strip when a mission objective starts (same title and description as the standard center popup).",
		ru = "Показывать в полоске Division HUD при старте цели миссии (тот же заголовок и текст, что у стандартного попапа по центру).",
		["zh-cn"] = "任务目标开始时，在 Division HUD 栏显示与中央弹窗相同的标题与描述。",
	},
	alert_mission_objective_progress = {
		en = "Objective progress",
		ru = "Прогресс цели",
		["zh-cn"] = "目标进度",
	},
	alert_mission_objective_progress_description = {
		en = "When enabled, show in the Division HUD strip when the game would show a progression popup for an objective (with counter text when applicable).",
		ru = "Показывать в полоске Division HUD, когда игра показала бы попап прогресса цели (со счётчиком, если он есть).",
		["zh-cn"] = "游戏显示目标进度弹窗时，在 Division HUD 栏同步显示（含计数）。",
	},
	alert_mission_objective_complete = {
		en = "Objective complete",
		ru = "Цель выполнена",
		["zh-cn"] = "目标完成",
	},
	alert_mission_objective_complete_description = {
		en = "When enabled, show in the Division HUD strip when a mission objective completes.",
		ru = "Показывать в полоске Division HUD при завершении цели миссии.",
		["zh-cn"] = "任务目标完成时在 Division HUD 栏显示提示。",
	},
	alert_mission_objective_custom_popup = {
		en = "Scripted objective popups",
		ru = "Сюжетные всплывашки целей",
		["zh-cn"] = "剧情脚本目标弹窗",
	},
	alert_mission_objective_custom_popup_description = {
		en = "When enabled, show in the Division HUD strip for generic mission popup events (event_show_objective_popup), e.g. some narrative beats.",
		ru = "Показывать в полоске Division HUD для общих всплывашек целей (event_show_objective_popup), например сюжетных сообщений.",
		["zh-cn"] = "对通用任务弹窗事件（如剧情提示）在 Division HUD 栏显示。",
	},
	mission_objective_custom_popup_strip_fallback = {
		en = "OBJECTIVE",
		ru = "ЦЕЛЬ",
		["zh-cn"] = "目标",
	},
	alerts_group_team = {
		en = string.rep("\194\160", 8) .. "Strike team",
		ru = string.rep("\194\160", 8) .. "Ударная группа",
		["zh-cn"] = string.rep("\194\160", 8) .. "小队",
	},
	alerts_group_team_description = {
		en = "Show teammate knockdowns, trapper net, Pox Hound pin, ledge hang, Beast of Nurgle consume, and deaths in the Division HUD alert strip. The player name uses the squad slot color.",
		ru = "Показывать нокдауны, сеть ловушечника, схват чумной гончей, висение на уступе, поглощение зверем Нургла и смерти в полоске оповещений Division HUD. Ник окрашивается цветом слота отряда.",
		["zh-cn"] = "在警报栏显示队友倒地、被网、被狗咬、悬挂悬崖、被吞、阵亡等状态。玩家名称使用队伍颜色。",
	},
	alerts_team_knock = {
		en = "Teammate knocked down",
		ru = "Союзник упал",
		["zh-cn"] = "队友倒地",
	},
	alerts_team_knock_description = {
		en = "When a teammate enters the knocked down state, enqueue an alert line (wording includes that help is needed).",
		ru = "Когда союзник падает в нокдаун, добавлять строку в оповещения (в тексте указано, что нужна помощь).",
		["zh-cn"] = "队友倒地时显示警报，并提示需要帮助。",
	},
	alerts_team_net = {
		en = "Caught in net",
		ru = "Пойман в сеть",
		["zh-cn"] = "被网困住",
	},
	alerts_team_net_description = {
		en = "When a teammate is netted (Scab Trapper), enqueue an alert. Uses character_state / disabled checks like the player panel, and also when the state machine applies a server correction to netted so other players on your client are covered.",
		ru = "Когда союзник в сети ловушечника — строка в оповещениях. Те же проверки character_state / disabled, что у панели игрока; дополнительно при server_correction_occurred в netted, чтобы срабатывало и для союзников с репликацией состояния.",
		["zh-cn"] = "队友被陷阱兵网住时显示警报，判定逻辑与原版玩家面板一致，并兼容服务器状态同步。",
	},
	alerts_team_hound = {
		en = "Pox Hound on teammate",
		ru = "Чумная Гончая на союзнике",
		["zh-cn"] = "瘟疫猎犬扑中队友",
	},
	alerts_team_hound_description = {
		en = "When a teammate enters the pounced disabled state (Pox Hound pin), enqueue an alert line. Uses the same disabled_character_state check as the vanilla player panel.",
		ru = "Когда союзник в состоянии «схвачен» с типом pounced (чумная гончая), добавлять строку. Проверка disabled_character_state + PlayerUnitStatus.is_pounced, как у ванильной панели игрока.",
		["zh-cn"] = "队友被瘟疫猎犬扑倒压制时显示警报，使用与原版一致的状态判定。",
	},
	alerts_team_ledge = {
		en = "Hanging on ledge",
		ru = "Висит на уступе",
		["zh-cn"] = "悬挂悬崖",
	},
	alerts_team_ledge_description = {
		en = "When a teammate enters ledge_hanging (needs pull-up help), enqueue an alert line. Uses PlayerUnitStatus.is_ledge_hanging on character_state.",
		ru = "Когда союзник в состоянии ledge_hanging (висит на уступе, нужен подтяг), добавлять строку. Проверка PlayerUnitStatus.is_ledge_hanging по character_state.",
		["zh-cn"] = "队友悬挂在悬崖需要救援时显示警报。",
	},
	alerts_team_consumed = {
		en = "Swallowed by Beast of Nurgle",
		ru = "Поглощён Зверем Нургла",
		["zh-cn"] = "被纳垢巨兽吞噬",
	},
	alerts_team_consumed_description = {
		en = "When a teammate enters the consumed disabled state (Beast of Nurgle), enqueue an alert line. Uses PlayerUnitStatus.is_consumed on disabled_character_state.",
		ru = "Когда союзник в состоянии consumed (поглощён зверем Нургла), добавлять строку. Проверка PlayerUnitStatus.is_consumed по disabled_character_state.",
		["zh-cn"] = "队友被纳垢巨兽吞入体内时显示警报。",
	},
	alerts_team_death = {
		en = "Teammate death",
		ru = "Смерть союзника",
		["zh-cn"] = "队友阵亡",
	},
	alerts_team_death_description = {
		en = "When a teammate dies, enqueue an alert line.",
		ru = "Когда союзник умирает, добавлять строку в оповещения.",
		["zh-cn"] = "队友死亡时显示警报。",
	},
	alerts_team_strip = {
		en = "Strike team",
		ru = "Ударная группа",
		["zh-cn"] = "小队",
	},
	alerts_team_suffix_knock = {
		en = "knocked down, needs help",
		ru = "упал, нужна помощь",
		["zh-cn"] = "倒地，需要帮助",
	},
	alerts_team_suffix_death = {
		en = "died",
		ru = "погиб",
		["zh-cn"] = "阵亡",
	},
	alerts_team_suffix_trapper_net = {
		en = "was ensnared by a Scab Trapper",
		ru = "пойман в сеть Скаб Ловушечника",
		["zh-cn"] = "被血痂陷阱手的网困住",
	},
	alerts_team_suffix_hound_pounce = {
		en = "was pinned by a Pox Hound",
		ru = "схватила Чумная гончая",
		["zh-cn"] = "被瘟疫猎犬扑倒",
	},
	alerts_team_suffix_ledge_hanging = {
		en = "is hanging on a ledge, needs help",
		ru = "висит на уступе, нужна помощь",
		["zh-cn"] = "悬挂在悬崖，需要救援",
	},
	alerts_team_suffix_consumed = {
		en = "consumed by a Beast of Nurgle",
		ru = "поглощён зверем Нургла",
		["zh-cn"] = "被纳垢兽吞噬",
	},
	alerts_ui_banner_alert = {
		en = "ALERT",
		ru = "ВНИМАНИЕ",
		["zh-cn"] = "警报",
	},
	alerts_message_specialist_approach = {
		en = "Detected %s",
		ru = "Обнаружен %s",
		["zh-cn"] = "侦测到：%s",
	},
	alerts_message_boss_approach = {
		en = "Detected %s",
		ru = "Обнаружен %s",
		["zh-cn"] = "侦测到：%s",
	},
	alerts_message_spawn_grouped = {
		en = "Detected %s x%d",
		ru = "Обнаружен %s x%d",
		["zh-cn"] = "侦测到：%s x%d",
	},
	alerts_message_mission_objective_grouped = {
		en = "%s x%d",
		ru = "%s x%d",
		["zh-cn"] = "%s x%d",
	},
	alerts_breed_title_override_chaos_mutator_daemonhost = {
		en = "Daemonhost (mutator)",
		ru = "Демонхост (мутатор)",
		["zh-cn"] = "恶魔宿主（突变）",
	},
	alerts_breed_title_override_chaos_hound_mutator = {
		en = "Pox Hound (mutator)",
		ru = "Чумная гончая (мутатор)",
		["zh-cn"] = "瘟疫猎犬（突变）",
	},
	alerts_breed_title_override_renegade_grenadier = {
		en = "Renegade Grenadier",
		ru = "Скаб-Бомбардир",
		["zh-cn"] = "血痂火雷兵",
	},
	divisionhud_super_proximity = {
		en = "\238\128\161 PROXIMITY DETECTOR",
		ru = "\238\128\161 ДЕТЕКТОР ПРЕДМЕТОВ",
		["zh-cn"] = "\238\128\161 近距感应",
	},
	proximity_enabled = {
		en = "Enable proximity detector",
		ru = "Включить детектор предметов",
		["zh-cn"] = "启用近距感应",
	},
	proximity_enabled_description = {
		en = "Shows nearby pickups (medkits, ammo, stimms) to the right of the HUD slots.",
		ru = "Показывает ближайшие предметы (аптечки, патроны, стимы) справа от слотов HUD.",
		["zh-cn"] = "在HUD槽右侧显示附近的拾取物（急救箱、弹药、注射器）。",
	},
	proximity_radius = {
		en = "Detection radius (m)",
		ru = "Радиус обнаружения (м)",
		["zh-cn"] = "检测半径（米）",
	},
	proximity_radius_description = {
		en = "Maximum distance in meters to detect nearby items.",
		ru = "Максимальное расстояние в метрах для обнаружения предметов.",
		["zh-cn"] = "检测附近物品的最大距离（米）。",
	},
	proximity_show_medical_station = {
		en = "Show health stations",
		ru = "Показывать мед станции",
		["zh-cn"] = "显示医疗站",
	},
	proximity_show_medical_station_description = {
		en = "Detect health stations (only those with remaining charges).",
		ru = "Обнаруживать мед станции (только с оставшимися зарядами).",
		["zh-cn"] = "检测医疗站（仅剩余充能时显示）。",
	},
	proximity_show_medical = {
		en = "Show medkits",
		ru = "Показывать аптечки",
		["zh-cn"] = "显示急救箱",
	},
	proximity_show_medical_description = {
		en = "Detect pocketable medical crates.",
		ru = "Обнаруживать карманные мед ящики.",
		["zh-cn"] = "检测可携带医疗箱。",
	},
	proximity_show_medical_deployed = {
		en = "Show deployed medical crates",
		ru = "Показывать развёрнутые мед ящики",
		["zh-cn"] = "显示已部署医疗箱",
	},
	proximity_show_medical_deployed_description = {
		en = "Detect deployed medical crates placed by players.",
		ru = "Обнаруживать развёрнутые мед ящики, выставленные игроками.",
		["zh-cn"] = "检测玩家放置的已部署医疗箱。",
	},
	proximity_show_stimm = {
		en = "Show stimulants",
		ru = "Показывать стимуляторы",
		["zh-cn"] = "显示注射器",
	},
	proximity_show_stimm_description = {
		en = "Detect stimulant syringes.",
		ru = "Обнаруживать стимулирующие шприцы.",
		["zh-cn"] = "检测刺激注射器。",
	},
	proximity_show_ammo_small = {
		en = "Show small ammo clips",
		ru = "Показывать малые патроны",
		["zh-cn"] = "显示小弹夹",
	},
	proximity_show_ammo_small_description = {
		en = "Detect small ammo clips.",
		ru = "Обнаруживать малые обоймы с патронами.",
		["zh-cn"] = "检测小弹夹。",
	},
	proximity_show_ammo_large = {
		en = "Show large ammo clips",
		ru = "Показывать крупные патроны",
		["zh-cn"] = "显示大弹夹",
	},
	proximity_show_ammo_large_description = {
		en = "Detect large ammo clips.",
		ru = "Обнаруживать крупные обоймы с патронами.",
		["zh-cn"] = "检测大弹夹。",
	},
	proximity_show_ammo_crate = {
		en = "Show ammo crates",
		ru = "Показывать ящики патронов",
		["zh-cn"] = "显示弹药箱",
	},
	proximity_show_ammo_crate_description = {
		en = "Detect ammo crates (pocketable, deployed, and level crates).",
		ru = "Обнаруживать ящики патронов (карманные, развёрнутые и на уровне).",
		["zh-cn"] = "检测弹药箱（可携带、已部署和地图内）。",
	},
	proximity_show_grenade = {
		en = "Show grenades",
		ru = "Показывать гранаты",
		["zh-cn"] = "显示手榴弹",
	},
	proximity_show_grenade_description = {
		en = "Detect grenades (standard and expedition).",
		ru = "Обнаруживать гранаты (обычные и экспедиционные).",
		["zh-cn"] = "检测手榴弹（普通和远征）。",
	},
	proximity_show_grimoire = {
		en = "Show grimoires",
		ru = "Показывать гримуары",
		["zh-cn"] = "显示秘典",
	},
	proximity_show_grimoire_description = {
		en = "Detect grimoires on the map.",
		ru = "Обнаруживать гримуары на карте.",
		["zh-cn"] = "检测地图上的秘典。",
	},
	proximity_show_tome = {
		en = "Show scriptures",
		ru = "Показывать писания",
		["zh-cn"] = "显示圣书",
	},
	proximity_show_tome_description = {
		en = "Detect scriptures (tomes) on the map.",
		ru = "Обнаруживать писания на карте.",
		["zh-cn"] = "检测地图上的圣书。",
	},
	divisionhud_integrations = {
		en = "\238\128\172 INTEGRATIONS",
		ru = "\238\128\172 ИНТЕГРАЦИИ",
		["zh-cn"] = "\238\128\172 模组兼容",
	},
	integration_custom_hud = {
		en = "Custom HUD",
		ru = "Custom HUD",
		["zh-cn"] = "Custom HUD 兼容",
	},
	integration_custom_hud_description = {
		en = "When enabled and Custom HUD has saved layout for this HUD (including root), Division HUD applies that position every frame and adds Dynamic HUD motion on top. Offset X/Y sliders are ignored for root. If only inner nodes are saved, root is left unchanged. Until anything is saved in Custom HUD, the X/Y sliders still move the block.",
		ru = "Если включено и в Custom HUD сохранена раскладка этого HUD (в т.ч. root), Division HUD каждый кадр ставит эту позицию и при необходимости добавляет смещение Dynamic HUD. Слайдеры X/Y для root не используются. Если в Custom HUD сохранены только внутренние узлы, root не трогаем. Пока в Custom HUD нет сохранений — блок двигают слайдеры X/Y.",
		["zh-cn"] = "启用后，若 Custom HUD 已保存布局，Division HUD 将使用其位置并叠加动态效果，忽略 X/Y 偏移。未保存布局时仍可使用滑块调整。",
	},
	integration_stimm_countdown = {
		en = "StimmCountdown",
		ru = "StimmCountdown",
		["zh-cn"] = "StimmCountdown 兼容",
	},
	integration_stimm_countdown_description = {
		en = "When enabled and the StimmCountdown mod is loaded and enabled, the pocket stimm slot in the Division HUD strip shows its countdown (active / cooldown) using that mod’s display options. When off, the slot uses the usual 01/00 counter only.",
		ru = "Если включено и мод StimmCountdown загружен и включён, в слоте карманного шприца в полоске Division HUD показывается отсчёт (действие / перезарядка) с учётом настроек того мода. Если выключено — только обычные 01/00.",
		["zh-cn"] = "启用后，若已加载 StimmCountdown，注射器槽会显示持续/冷却倒计时；关闭则只显示 01/00。",
	},
	integration_recolor_stimms = {
		en = "RecolorStimms",
		ru = "RecolorStimms",
		["zh-cn"] = "RecolorStimms 兼容",
	},
	integration_recolor_stimms_description = {
		en = "When enabled and the RecolorStimms mod is loaded and enabled, pocket stimm icon colors are taken from that mod (get_stimm_argb_255). When off or the mod is unavailable, built-in syringe colors are used.",
		ru = "Если включено и мод RecolorStimms загружен и включён, цвета иконки карманного шприца берутся из него (get_stimm_argb_255). Иначе используются встроенные цвета шприцев.",
		["zh-cn"] = "启用后，注射器图标颜色将从 RecolorStimms 读取；未启用时使用内置颜色。",
	},
	divisionhud_super_system = {
		en = "\238\128\169 SYSTEM SETTINGS",
		ru = "\238\128\169 СИСТЕМНЫЕ НАСТРОЙКИ",
		["zh-cn"] = "⚙️ 系统设置",
	},
	divisionhud_reset_all_settings = {
		en = "Reset settings",
		ru = "Сбросить настройки",
		["zh-cn"] = "重置设置",
	},
	divisionhud_reset_all_settings_description = {
		en = "Pick the confirm entry and apply. All Division HUD options return to defaults.",
		ru = "Выберите подтверждение и примените. Все параметры Division HUD вернутся к значениям по умолчанию.",
		["zh-cn"] = "选择确认并应用，所有 Division HUD 设置恢复默认。",
	},
	divisionhud_reset_confirm = {
		en = "Yes, reset",
		ru = "Да, сбросить",
		["zh-cn"] = "确认重置",
	},
	divisionhud_reset_done = {
		en = "Division HUD: settings restored to defaults.",
		ru = "Division HUD: настройки сброшены к значениям по умолчанию.",
		["zh-cn"] = "全境封锁 HUD：已恢复默认设置。",
	},
}
