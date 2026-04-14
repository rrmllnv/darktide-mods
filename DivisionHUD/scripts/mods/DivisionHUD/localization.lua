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
		["zh-cn"] = "口袋注射器着色",
	},
	stimm_slot_icon_tint_by_type_description = {
		en = "When enabled, the pocket stimm icon in the Division HUD strip is tinted by syringe template (speed, power, corruption cleanse, ability boost, broker syringe, etc.) using built-in colors. When off, the icon uses the default white tint.",
		ru = "Если включено, иконка карманного шприца в полоске Division HUD окрашивается по шаблону шприца (скорость, сила, снятие порчи, усиление способности, шприц брокера и т.д.) встроенными цветами. Если выключено — обычный белый тон.",
		["zh-cn"] = "启用后，按注射器模板（速度、力量、腐蚀治疗、技能强化、经纪人注射器等）用内置颜色为 Division HUD 条带中的口袋注射器图标着色。关闭时使用默认白色。",
	},
	ammo_text_color_by_fraction = {
		en = "Ammo text color by remaining fraction",
		ru = "Цвет патронов по доле боезапаса",
		["zh-cn"] = "按弹药比例着色弹药文字",
	},
	ammo_text_color_by_fraction_description = {
		en = "When enabled, the large ammo numbers tint by total ammo fraction: above 75% main, above 50% low, above 25% medium, 25% or less high. When off, they use the default main color.",
		ru = "Если включено, крупные цифры патронов окрашиваются по доле боезапаса: выше 75% — основной цвет; выше 50% и не выше 75% — низкий запас; выше 25% и не выше 50% — средний; 25% и ниже — критический. Если выключено — обычный основной цвет.",
		["zh-cn"] = "启用后，大号弹药数字按总弹药比例着色：高于 75% 主色；高于 50% 且不高于 75% 为低弹药色；高于 25% 且不高于 50% 为中档；25% 及以下为高警示色。关闭时使用默认主色。",
	},
	grenade_color_by_fraction = {
		en = "Grenade slot color by charge fraction",
		ru = "Цвет гранаты по доле зарядов",
		["zh-cn"] = "手雷槽按充能比例着色",
	},
	grenade_color_by_fraction_description = {
		en = "When enabled, the grenade ability slot icon and counter tint by remaining charges, using the same color bands and fraction thresholds as the large ammo numbers. When off, the slot uses the default colors.",
		ru = "Если включено, иконка и счётчик слота гранаты окрашиваются по доле оставшихся зарядов — те же цветовые полосы и пороги доли, что у крупного текста патронов. Если выключено — цвета по умолчанию.",
		["zh-cn"] = "启用后，手雷技能槽的图标与数字按剩余充能比例着色，色带与比例阈值与大号弹药文字一致。关闭时使用默认颜色。",
	},
	wielded_weapon_icon_state_colors = {
		en = "Current weapon icon colors",
		ru = "Цвет текущего оружия",
		["zh-cn"] = "当前武器图标颜色",
	},
	wielded_weapon_icon_state_colors_description = {
		en = "When enabled, tints the wielded-weapon strip icon for weapons included in this mod's internal list by inactive, active, and optional cooldown states. Other weapons stay full white.",
		ru = "Если включено, для оружия из внутреннего списка мода окрашивает иконку текущего оружия в полоске Division HUD по неактивному, активному и при необходимости кулдауну. Для остального оружия остаётся обычный белый.",
		["zh-cn"] = "启用后，对本模组配置内的武器，按非激活、激活（及可选冷却）为当前武器条图标着色；其他武器保持纯白。",
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
		["zh-cn"] = "垂直/水平偏移比例",
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
		["zh-cn"] = "启用后，仅隐藏中央任务目标弹窗，目标条带（含 area 区域）仍会绘制。可在「任务目标」分组中将所选弹窗事件镜像到 Division HUD 提示条。",
	},
	alerts_super = {
		en = "\238\128\161 ALERTS",
		ru = "\238\128\161 ОПОВЕЩЕНИЯ",
		["zh-cn"] = "\238\128\161 警报",
	},
	alerts_enabled = {
		en = "Enable approach alerts",
		ru = "Включить оповещения о приближении",
		["zh-cn"] = "启用接近警报",
	},
	alerts_max_visible = {
		en = "Maximum simultaneous alerts",
		ru = "Максимум одновременных оповещений",
		["zh-cn"] = "同时显示的警报数量上限",
	},
	alerts_duration_sec = {
		en = "Alert duration (seconds)",
		ru = "Время показа оповещения (сек.)",
		["zh-cn"] = "警报显示时长（秒）",
	},
	alerts_show_duration_bar = {
		en = "Alert display time bar",
		ru = "Полоса времени показа оповещения",
		["zh-cn"] = "警报剩余时间条",
	},
	alerts_group_bosses = {
		en = string.rep("\194\160", 8) .. "Bosses",
		ru = string.rep("\194\160", 8) .. "Боссы",
		["zh-cn"] = string.rep("\194\160", 8) .. "首领",
	},
	alerts_group_specialists = {
		en = string.rep("\194\160", 8) .. "Specialists",
		ru = string.rep("\194\160", 8) .. "Специалисты",
		["zh-cn"] = string.rep("\194\160", 8) .. "专家单位",
	},
	mission_objectives_super = {
		en = string.rep("\194\160", 8) .. "Mission objectives",
		ru = string.rep("\194\160", 8) .. "Цели миссии",
		["zh-cn"] = string.rep("\194\160", 8) .. "任务目标",
	},
	mission_objectives_super_description = {
		en = "When «Hide mission objectives» is on (VANILLA HUD section), these toggles choose which objective events appear in the Division HUD strip (title row + body; same look as enemy approach notifications).",
		ru = "Когда включено «Скрыть цели миссии» (супергруппа «Ванильный HUD»), эти переключатели задают, какие события целей показывать в полоске оповещений Division HUD (заголовок в полоске + текст цели, оформление как при оповещении о приближении).",
		["zh-cn"] = "在「VANILLA HUD」中启用「隐藏任务目标」后，这些开关决定哪些目标事件在 Division HUD 条带中显示（条带标题 + 正文，样式与接近敌人通知一致）。",
	},
	alert_mission_objective_start = {
		en = "New objective",
		ru = "Новая цель",
		["zh-cn"] = "新目标",
	},
	alert_mission_objective_start_description = {
		en = "When enabled, show in the Division HUD strip when a mission objective starts (same title and description as the standard center popup).",
		ru = "Показывать в полоске Division HUD при старте цели миссии (тот же заголовок и текст, что у стандартного попапа по центру).",
		["zh-cn"] = "任务目标开始时在 Division HUD 条带中显示（标题与正文与游戏中央弹窗一致）。",
	},
	alert_mission_objective_progress = {
		en = "Objective progress",
		ru = "Прогресс цели",
		["zh-cn"] = "目标进度",
	},
	alert_mission_objective_progress_description = {
		en = "When enabled, show in the Division HUD strip when the game would show a progression popup for an objective (with counter text when applicable).",
		ru = "Показывать в полоске Division HUD, когда игра показала бы попап прогресса цели (со счётчиком, если он есть).",
		["zh-cn"] = "当游戏会显示目标进度弹窗时在 Division HUD 条带中显示（含计数文本）。",
	},
	alert_mission_objective_complete = {
		en = "Objective complete",
		ru = "Цель выполнена",
		["zh-cn"] = "目标完成",
	},
	alert_mission_objective_complete_description = {
		en = "When enabled, show in the Division HUD strip when a mission objective completes.",
		ru = "Показывать в полоске Division HUD при завершении цели миссии.",
		["zh-cn"] = "任务目标完成时在 Division HUD 条带中显示。",
	},
	alert_mission_objective_custom_popup = {
		en = "Scripted objective popups",
		ru = "Сюжетные всплывашки целей",
		["zh-cn"] = "脚本目标弹窗",
	},
	alert_mission_objective_custom_popup_description = {
		en = "When enabled, show in the Division HUD strip for generic mission popup events (event_show_objective_popup), e.g. some narrative beats.",
		ru = "Показывать в полоске Division HUD для общих всплывашек целей (event_show_objective_popup), например сюжетных сообщений.",
		["zh-cn"] = "为通用任务弹窗事件（event_show_objective_popup）在 Division HUD 条带中显示，例如部分叙事提示。",
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
		["zh-cn"] = "在小队警报条中显示队友倒地、陷阱网、瘟疫猎犬压制、悬崖悬挂、纳垢巨兽吞噬、死亡。玩家昵称使用队伍槽位颜色。",
	},
	alerts_team_knock = {
		en = "Teammate knocked down",
		ru = "Союзник упал",
		["zh-cn"] = "队友倒地",
	},
	alerts_team_knock_description = {
		en = "When a teammate enters the knocked down state, enqueue an alert line (wording includes that help is needed).",
		ru = "Когда союзник падает в нокдаун, добавлять строку в оповещения (в тексте указано, что нужна помощь).",
		["zh-cn"] = "队友进入倒地状态时加入一条警报（文案中会提示需要帮助）。",
	},
	alerts_team_net = {
		en = "Caught in net",
		ru = "Пойман в сеть",
		["zh-cn"] = "被网困住",
	},
	alerts_team_net_description = {
		en = "When a teammate is netted (Scab Trapper), enqueue an alert. Uses character_state / disabled checks like the player panel, and also when the state machine applies a server correction to netted so other players on your client are covered.",
		ru = "Когда союзник в сети ловушечника — строка в оповещениях. Те же проверки character_state / disabled, что у панели игрока; дополнительно при server_correction_occurred в netted, чтобы срабатывало и для союзников с репликацией состояния.",
		["zh-cn"] = "队友被陷阱兵网住时加入一条警报；与玩家面板一致的 character_state / disabled 判定，并在状态机 server_correction 同步到 netted 时触发，以覆盖其他玩家客户端上的表现。",
	},
	alerts_team_hound = {
		en = "Pox Hound on teammate",
		ru = "Чумная Гончая на союзнике",
		["zh-cn"] = "瘟疫猎犬扑向队友",
	},
	alerts_team_hound_description = {
		en = "When a teammate enters the pounced disabled state (Pox Hound pin), enqueue an alert line. Uses the same disabled_character_state check as the vanilla player panel.",
		ru = "Когда союзник в состоянии «схвачен» с типом pounced (чумная гончая), добавлять строку. Проверка disabled_character_state + PlayerUnitStatus.is_pounced, как у ванильной панели игрока.",
		["zh-cn"] = "队友进入 pounced 压制（瘟疫猎犬）时加入一条警报；与游戏内玩家面板一致读取 disabled_character_state 与 is_pounced。",
	},
	alerts_team_ledge = {
		en = "Hanging on ledge",
		ru = "Висит на уступе",
		["zh-cn"] = "悬在悬崖边",
	},
	alerts_team_ledge_description = {
		en = "When a teammate enters ledge_hanging (needs pull-up help), enqueue an alert line. Uses PlayerUnitStatus.is_ledge_hanging on character_state.",
		ru = "Когда союзник в состоянии ledge_hanging (висит на уступе, нужен подтяг), добавлять строку. Проверка PlayerUnitStatus.is_ledge_hanging по character_state.",
		["zh-cn"] = "队友进入 ledge_hanging（悬挂悬崖需拉一把）时加入一条警报；对 character_state 使用 PlayerUnitStatus.is_ledge_hanging。",
	},
	alerts_team_consumed = {
		en = "Swallowed by Beast of Nurgle",
		ru = "Поглощён Зверем Нургла",
		["zh-cn"] = "被纳垢巨兽吞噬",
	},
	alerts_team_consumed_description = {
		en = "When a teammate enters the consumed disabled state (Beast of Nurgle), enqueue an alert line. Uses PlayerUnitStatus.is_consumed on disabled_character_state.",
		ru = "Когда союзник в состоянии consumed (поглощён зверем Нургла), добавлять строку. Проверка PlayerUnitStatus.is_consumed по disabled_character_state.",
		["zh-cn"] = "队友进入 consumed（被纳垢巨兽吞噬）时加入一条警报；对 disabled_character_state 使用 PlayerUnitStatus.is_consumed。",
	},
	alerts_team_death = {
		en = "Teammate death",
		ru = "Смерть союзника",
		["zh-cn"] = "队友阵亡",
	},
	alerts_team_death_description = {
		en = "When a teammate dies, enqueue an alert line.",
		ru = "Когда союзник умирает, добавлять строку в оповещения.",
		["zh-cn"] = "队友死亡时加入一条警报。",
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
		["zh-cn"] = "陷入斯卡布陷阱兵的网中",
	},
	alerts_team_suffix_hound_pounce = {
		en = "was pinned by a Pox Hound",
		ru = "схватила Чумная гончая",
		["zh-cn"] = "遭瘟疫猎犬扑倒",
	},
	alerts_team_suffix_ledge_hanging = {
		en = "is hanging on a ledge, needs help",
		ru = "висит на уступе, нужна помощь",
		["zh-cn"] = "挂在悬崖边，需要帮助",
	},
	alerts_team_suffix_consumed = {
		en = "consumed by a Beast of Nurgle",
		ru = "поглощён зверем Нургла",
		["zh-cn"] = "被纳垢巨兽吞噬",
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
		["zh-cn"] = "恶魔宿主（异变）",
	},
	alerts_breed_title_override_chaos_hound_mutator = {
		en = "Pox Hound (mutator)",
		ru = "Чумная гончая (мутатор)",
		["zh-cn"] = "瘟疫猎犬（异变）",
	},
	alerts_breed_title_override_renegade_grenadier = {
		ru = "Скаб-Бомбардир",
	},
	divisionhud_integrations = {
		en = "\238\128\172 INTEGRATIONS",
		ru = "\238\128\172 ИНТЕГРАЦИИ",
		["zh-cn"] = "\238\128\172 功能兼容",
	},
	integration_custom_hud = {
		en = "Custom HUD",
		ru = "Custom HUD",
		["zh-cn"] = "自定义界面兼容",
	},
	integration_custom_hud_description = {
		en = "When enabled and Custom HUD has saved layout for this HUD (including root), Division HUD applies that position every frame and adds Dynamic HUD motion on top. Offset X/Y sliders are ignored for root. If only inner nodes are saved, root is left unchanged. Until anything is saved in Custom HUD, the X/Y sliders still move the block.",
		ru = "Если включено и в Custom HUD сохранена раскладка этого HUD (в т.ч. root), Division HUD каждый кадр ставит эту позицию и при необходимости добавляет смещение Dynamic HUD. Слайдеры X/Y для root не используются. Если в Custom HUD сохранены только внутренние узлы, root не трогаем. Пока в Custom HUD нет сохранений — блок двигают слайдеры X/Y.",
		["zh-cn"] = "启用后，若自定义界面已保存本界面布局（含根节点），全境封锁 HUD 会每帧应用该位置并叠加动态效果。根节点将忽略 X/Y 偏移滑块。若仅保存内部节点，根节点保持不变。自定义界面未保存任何布局时，仍可使用 X/Y 滑块移动。",
	},
	integration_stimm_countdown = {
		en = "StimmCountdown",
		ru = "StimmCountdown",
		["zh-cn"] = "StimmCountdown",
	},
	integration_stimm_countdown_description = {
		en = "When enabled and the StimmCountdown mod is loaded and enabled, the pocket stimm slot in the Division HUD strip shows its countdown (active / cooldown) using that mod’s display options. When off, the slot uses the usual 01/00 counter only.",
		ru = "Если включено и мод StimmCountdown загружен и включён, в слоте карманного шприца в полоске Division HUD показывается отсчёт (действие / перезарядка) с учётом настроек того мода. Если выключено — только обычные 01/00.",
		["zh-cn"] = "启用后，若 StimmCountdown 模组已加载并启用，Division HUD 条带中的口袋注射器槽位将按该模组显示倒计时（生效中/冷却中）。关闭时，槽位仅显示常规的 01/00 计数。",
	},
	integration_recolor_stimms = {
		en = "RecolorStimms",
		ru = "RecolorStimms",
		["zh-cn"] = "RecolorStimms",
	},
	integration_recolor_stimms_description = {
		en = "When enabled and the RecolorStimms mod is loaded and enabled, pocket stimm icon colors are taken from that mod (get_stimm_argb_255). When off or the mod is unavailable, built-in syringe colors are used.",
		ru = "Если включено и мод RecolorStimms загружен и включён, цвета иконки карманного шприца берутся из него (get_stimm_argb_255). Иначе используются встроенные цвета шприцев.",
		["zh-cn"] = "启用后，若 RecolorStimms 模组已加载并启用，口袋注射器图标颜色从该模组读取（get_stimm_argb_255）。关闭或模组不可用时使用内置注射器颜色。",
	},
	divisionhud_super_system = {
		en = "\238\128\169 SYSTEM SETTINGS",
		ru = "\238\128\169 СИСТЕМНЫЕ НАСТРОЙКИ",
		["zh-cn"] = "⚙️ 系统设置",
	},
	divisionhud_reset_all_settings = {
		en = "Reset settings",
		ru = "Сбросить настройки",
		["zh-cn"] = "重置所有设置",
	},
	divisionhud_reset_all_settings_description = {
		en = "Pick the confirm entry and apply. All Division HUD options return to defaults.",
		ru = "Выберите подтверждение и примените. Все параметры Division HUD вернутся к значениям по умолчанию.",
		["zh-cn"] = "选择确认选项并应用，所有全境封锁 HUD 设置将恢复默认。",
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
