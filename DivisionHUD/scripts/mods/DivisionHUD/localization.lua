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
	divisionhud_visible = {
		en = "Show Division HUD",
		ru = "Показывать Division HUD",
		["zh-cn"] = "显示 Division HUD",
	},
	divisionhud_visible_description = {
		en = "When off, the entire Division HUD overlay is hidden.",
		ru = "Если выключено, скрыт весь оверлей Division HUD.",
		["zh-cn"] = "关闭时隐藏整个 Division HUD。",
	},
	divisionhud_toggle_visible_keybind = {
		en = "Toggle HUD visibility",
		ru = "Переключить видимость HUD",
		["zh-cn"] = "切换 HUD 显示",
	},
	divisionhud_toggle_visible_keybind_description = {
		en = "Same as «Show Division HUD» above.",
		ru = "То же, что чекбокс «Показывать Division HUD» выше.",
		["zh-cn"] = "与上方「显示 Division HUD」相同。",
	},
	divisionhud_auto_switch = {
		en = string.rep("\194\160", 8) .. "Auto visibility switch",
		ru = string.rep("\194\160", 8) .. "Авто переключение видимости",
		["zh-cn"] = string.rep("\194\160", 8) .. "自动切换可见性",
	},
	divisionhud_auto_first_person = {
		en = "First person",
		ru = "От первого лица",
		["zh-cn"] = "第一人称",
	},
	divisionhud_auto_first_person_description = {
		en = "Show HUD in first person.",
		ru = "Показывать HUD от первого лица.",
		["zh-cn"] = "第一人称时显示。",
	},
	divisionhud_auto_third_person = {
		en = "Third person",
		ru = "От третьего лица",
		["zh-cn"] = "第三人称",
	},
	divisionhud_auto_third_person_description = {
		en = "Show HUD in third person.",
		ru = "Показывать HUD от третьего лица.",
		["zh-cn"] = "第三人称时显示。",
	},
	divisionhud_auto_slot_device = {
		en = "Device in hand",
		ru = "Устройство в руках",
		["zh-cn"] = "手持设备",
	},
	divisionhud_auto_slot_device_description = {
		en = "If you hold a device: off — hide Division HUD. On — do not hide.",
		ru = "Если в руках устройство: выкл — скрыть Division HUD. Вкл — не скрывать.",
		["zh-cn"] = "手持设备时：关 — 隐藏 Division HUD；开 — 不隐藏。",
	},
	divisionhud_placement = {
		en = string.rep("\194\160", 8) .. "Position, opacity & scale",
		ru = string.rep("\194\160", 8) .. "Позиция, прозрачность и масштаб",
		["zh-cn"] = string.rep("\194\160", 8) .. "位置、不透明度与缩放",
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
	hud_scale = {
		en = "HUD scale",
		ru = "Масштаб HUD",
		["zh-cn"] = "界面缩放",
	},
	hud_scale_description = {
		en = "Scale multiplier applied to the whole Division HUD (reference canvas 1920×1080). Values below 1 shrink the HUD, values above 1 enlarge it.",
		ru = "Множитель масштаба, применяемый ко всему Division HUD (эталонный холст 1920×1080). Значения меньше 1 уменьшают HUD, больше 1 — увеличивают.",
		["zh-cn"] = "对整个 Division HUD 应用的缩放倍率（参考分辨率 1920×1080）。小于1缩小，大于1放大。",
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
	show_ability_icon = {
		en = "Ability icon",
		ru = "Иконка способности",
		["zh-cn"] = "技能图标",
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
	buff_rows_enabled = {
		en = "Buff rows",
		ru = "Строки баффов",
		["zh-cn"] = "增益行",
	},
	buff_rows_enabled_description = {
		en = "Displays active player buffs in rows below the stamina/dodge bars (up to 15 buffs, 5 per row).",
		ru = "Отображает активные бафы игрока рядами ниже полос стамины/уклонения (до 15 бафов, по 5 в ряд).",
		["zh-cn"] = "在耐力/闪避栏下方以行显示玩家的激活增益（最多15个，每行5个）。",
	},
	main_strip_background_fill = {
		en = "Weapon & ammo slots background",
		ru = "Фон под слотами оружия и патронов",
		["zh-cn"] = "武器与弹药槽背景",
	},
	main_strip_background_fill_description = {
		en = "Fill behind the weapon and ammo slots (Division HUD).",
		ru = "Заливка под слотами оружия и патронов (Division HUD).",
		["zh-cn"] = "武器与弹药槽背后的填充（Division HUD）。",
	},
	proximity_strip_background_fill = {
		en = "Detected items area background",
		ru = "Фон под иконками обнаруженных предметов",
		["zh-cn"] = "探测物品图标区域背景",
	},
	proximity_strip_background_fill_description = {
		en = "Fill behind proximity item icons; separate from weapon/ammo slots.",
		ru = "Заливка под иконками обнаруженных предметов (proximity), отдельно от слотов оружия и патронов.",
		["zh-cn"] = "近距离探测到的物品图标背后的填充（与武器/弹药槽分开）。",
	},
	main_strip_background_fill_weapon_hud_plain = {
		en = "Weapon fill only",
		ru = "Только оружейная заливка",
		["zh-cn"] = "仅武器填充",
	},
	main_strip_background_fill_weapon_hud = {
		en = "Weapon fill + frame",
		ru = "Оружейная заливка + рамка",
		["zh-cn"] = "武器填充 + 边框",
	},
	main_strip_background_fill_terminal = {
		en = "Terminal gradient green",
		ru = "Терминальный градиент зеленый",
		["zh-cn"] = "终端渐变绿色",
	},
	main_strip_background_fill_black = {
		en = "Terminal gradient black",
		ru = "Терминальный градиент черный",
		["zh-cn"] = "终端渐变黑色",
	},
	divisionhud_super_danger_zone = {
		en = "\238\128\161 DANGER ZONE",
		ru = "\238\128\161 ОПАСНАЯ ЗОНА",
		["zh-cn"] = "\238\128\161 危险区域",
	},
	danger_zone_label = {
		en = "Danger zone",
		ru = "Опасная зона",
		["zh-cn"] = "危险区域",
	},
	danger_zone_in_zone = {
		en = "In blast\nzone",
		ru = "В зоне\nпоражения",
		["zh-cn"] = "位于\n危险区",
	},
	danger_zone_enabled = {
		en = "Enable danger zone",
		ru = "Включить опасную зону",
		["zh-cn"] = "启用危险区域",
	},
	danger_zone_enabled_description = {
		en = "Shows the Danger zone block when you approach tracked hazardous areas.",
		ru = "Показывает блок Danger zone при приближении к отслеживаемым опасным зонам.",
		["zh-cn"] = "接近已追踪的危险区域时显示 Danger zone 模块。",
	},
	danger_zone_radius = {
		en = "Detection distance (m)",
		ru = "Расстояние обнаружения (м)",
		["zh-cn"] = "检测距离（米）",
	},
	danger_zone_radius_description = {
		en = "Maximum distance in meters from the edge of a tracked danger zone to show the Danger zone block.",
		ru = "Максимальное расстояние в метрах от границы отслеживаемой опасной зоны, на котором показывается блок Danger zone.",
		["zh-cn"] = "距离已追踪危险区域边缘的最大显示距离（米）。",
	},
	danger_zone_los_check = {
		en = "Account for obstacles (line of sight)",
		ru = "Учитывать препятствия (видимость)",
		["zh-cn"] = "考虑遮挡物（视线）",
	},
	danger_zone_los_check_description = {
		en = "Ignore danger sources separated from you by walls, floors or bridges (line-of-sight raycast). Disable to use distance only.",
		ru = "Игнорировать источники опасности, отделённые от вас стенами, полом или мостом (проверка прямой видимости лучом). Отключите, чтобы учитывать только расстояние.",
		["zh-cn"] = "忽略被墙壁、楼板或桥梁分隔的危险源（视线射线检测）。关闭则仅按距离判定。",
	},
	danger_zone_show_daemonhost = {
		en = "Daemonhost",
		ru = "Демонхост",
		["zh-cn"] = "恶魔宿主",
	},
	danger_zone_show_daemonhost_description = {
		en = "Show alerts for this unit (spawn and alert stages).",
		ru = "Показывать оповещения для этого юнита (появление и стадии тревоги).",
		["zh-cn"] = "显示该单位的警报（出生与各警戒阶段）。",
	},
	danger_zone_show_daemonhost_aura = {
		en = "Daemonhost corruption aura",
		ru = "Аура демонхоста",
		["zh-cn"] = "恶魔宿主腐化光环",
	},
	danger_zone_show_daemonhost_aura_description = {
		en = "Show the radius of this corruption aura (area effect around the unit).",
		ru = "Показывать радиус этой коррумпирующей ауры (область воздействия вокруг юнита).",
		["zh-cn"] = "显示该腐化光环的半径（单位周围的区域效果）。",
	},
	danger_zone_show_poxburster = {
		en = "Poxburster",
		ru = "Поксбёрстер",
		["zh-cn"] = "瘟疫爆弹者",
	},
	danger_zone_show_poxburster_description = {
		en = "Show alerts for this explosion threat — uses its explosion radius.",
		ru = "Показывать оповещения для этой взрывной угрозы — используется её радиус взрыва.",
		["zh-cn"] = "显示该爆炸威胁的警报（使用其爆炸半径）。",
	},
	danger_zone_show_tox_flamer = {
		en = "Tox flamer",
		ru = "Токс-огнемётчик",
		["zh-cn"] = "毒焰喷射者",
	},
	danger_zone_show_tox_flamer_description = {
		en = "Show alerts for this fire threat (backpack/flare explosions). Uses its explosion radius.",
		ru = "Показывать оповещения для этой огненной угрозы (взрывы ранца). Используется её радиус взрыва.",
		["zh-cn"] = "显示该火焰威胁的警报（背包/喷射器爆炸），使用其爆炸半径。",
	},
	danger_zone_show_scab_flamer = {
		en = "Scab flamer",
		ru = "Скаб-огнемётчик",
		["zh-cn"] = "血痂喷火兵",
	},
	danger_zone_show_scab_flamer_description = {
		en = "Show alerts for this fire threat (backpack explosions). Uses its explosion radius.",
		ru = "Показывать оповещения для этой огненной угрозы (взрывы ранца). Используется её радиус взрыва.",
		["zh-cn"] = "显示该火焰威胁的警报（背包爆炸），使用其爆炸半径。",
	},
	danger_zone_show_bomber_grenade = {
		en = "Bomber grenade",
		ru = "Граната бомбардира",
		["zh-cn"] = "投弹兵手雷",
	},
	danger_zone_show_bomber_grenade_description = {
		en = "Show alerts for Bomber grenade explosions — uses the grenade explosion radius.",
		ru = "Показывать оповещения о гранатах бомбардира — используется радиус взрыва гранаты.",
		["zh-cn"] = "显示投弹兵手雷爆炸警报（使用手雷爆炸半径）。",
	},
	danger_zone_show_explosive_barrel = {
		en = "Explosive barrel",
		ru = "Взрывная бочка",
		["zh-cn"] = "爆炸桶",
	},
	danger_zone_show_explosive_barrel_description = {
		en = "Show alerts for explosive barrels — uses the barrel explosion radius.",
		ru = "Показывать оповещения о взрывных бочках — используется радиус взрыва бочки.",
		["zh-cn"] = "显示爆炸桶的警报（使用其爆炸半径）。",
	},
	danger_zone_show_fire_barrel = {
		en = "Fire barrel",
		ru = "Огненная бочка",
		["zh-cn"] = "火焰桶",
	},
	danger_zone_show_fire_barrel_description = {
		en = "Show alerts for fire barrels — uses the fire barrel radius.",
		ru = "Показывать оповещения о огненных бочках — используется радиус их воздействия.",
		["zh-cn"] = "显示火焰桶的警报（使用其影响半径）。",
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
		en = "Detect pocketable ammo crates and ammo crates placed on the level.",
		ru = "Обнаруживать карманные ящики патронов и ящики с патронами, размещённые на уровне.",
		["zh-cn"] = "检测可携带弹药箱和关卡内放置的弹药箱。",
	},
	proximity_show_ammo_crate_deployed = {
		en = "Show deployed ammo crates",
		ru = "Показывать развёрнутые ящики патронов",
		["zh-cn"] = "显示已部署弹药箱",
	},
	proximity_show_ammo_crate_deployed_description = {
		en = "Detect deployed ammo crates placed by players.",
		ru = "Обнаруживать развёрнутые ящики патронов, выставленные игроками.",
		["zh-cn"] = "检测玩家放置的已部署弹药箱。",
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
	divisionhud_super_enemy_target = {
		en = "\238\128\178 ENEMY TARGET",
		ru = "\238\128\178 ВРАЖЕСКАЯ ЦЕЛЬ",
		["zh-cn"] = "\238\128\178 敌方目标",
	},
	enemy_target_enabled = {
		en = "Enable enemy target block",
		ru = "Включить блок вражеской цели",
		["zh-cn"] = "启用敌方目标模块",
	},
	enemy_target_enabled_description = {
		en = "Shows or hides the enemy target block.",
		ru = "Показывает или скрывает блок вражеской цели.",
		["zh-cn"] = "显示或隐藏敌方目标模块。",
	},
	enemy_target_sources = {
		en = string.rep("\194\160", 8) .. "Information sources",
		ru = string.rep("\194\160", 8) .. "Источники информации",
		["zh-cn"] = string.rep("\194\160", 8) .. "信息来源",
	},
	enemy_target_sources_description = {
		en = "Choose which events are allowed to show the enemy target block.",
		ru = "Выберите, какие события могут показывать блок цели.",
		["zh-cn"] = "选择哪些事件可以显示敌方目标模块。",
	},
	enemy_target_show_on_hover = {
		en = "Hover enemy",
		ru = "Наведение на врага",
		["zh-cn"] = "瞄准敌人",
	},
	enemy_target_show_on_hover_description = {
		en = "Show the block when the current target is under the crosshair.",
		ru = "Показывать блок, когда текущая цель находится под прицелом.",
		["zh-cn"] = "当当前目标处于准星下时显示模块。",
	},
	enemy_target_show_on_hit = {
		en = "Hit enemy",
		ru = "Попадание по врагу",
		["zh-cn"] = "命中敌人",
	},
	enemy_target_show_on_hit_description = {
		en = "Show the block when you damage an enemy.",
		ru = "Показывать блок, когда вы наносите урон врагу.",
		["zh-cn"] = "当你对敌人造成伤害时显示模块。",
	},
	enemy_target_hold_time = {
		en = "Display time",
		ru = "Время показа",
		["zh-cn"] = "显示时间",
	},
	enemy_target_hold_time_description = {
		en = "How many seconds the block remains visible after a hit trigger (does not affect hover).",
		ru = "Сколько секунд блок остается видимым после триггера попадания (не влияет на наведение).",
		["zh-cn"] = "命中触发后模块保持显示的秒数（不影响瞄准触发）。",
	},
	enemy_target_show_debuffs = {
		en = "Show debuffs",
		ru = "Показывать дебафы",
		["zh-cn"] = "显示减益",
	},
	enemy_target_show_debuffs_description = {
		en = "Show the list of active debuffs on the enemy target inside the block.",
		ru = "Показывать список активных дебафов на вражеской цели внутри блока.",
		["zh-cn"] = "在模块中显示敌方目标身上的有效减益列表。",
	},
	enemy_target_groups = {
		en = string.rep("\194\160", 8) .. "Enemy groups",
		ru = string.rep("\194\160", 8) .. "Группы врагов",
		["zh-cn"] = string.rep("\194\160", 8) .. "敌人分组",
	},
	enemy_target_groups_description = {
		en = "Choose which enemy groups are allowed to appear in the block.",
		ru = "Выберите, какие группы врагов можно показывать в блоке.",
		["zh-cn"] = "选择允许在模块中显示的敌人分组。",
	},
	enemy_target_show_boss = {
		en = "Boss",
		ru = "Боссы",
		["zh-cn"] = "Boss",
	},
	enemy_target_show_boss_description = {
		en = "Allow bosses in the enemy target block.",
		ru = "Разрешить показ боссов в блоке цели.",
		["zh-cn"] = "允许在敌方目标模块中显示 Boss。",
	},
	enemy_target_show_elite = {
		en = "Elite",
		ru = "Элита",
		["zh-cn"] = "精英",
	},
	enemy_target_show_elite_description = {
		en = "Allow elites in the enemy target block.",
		ru = "Разрешить показ элиты в блоке цели.",
		["zh-cn"] = "允许在敌方目标模块中显示精英。",
	},
	enemy_target_show_special = {
		en = "Special",
		ru = "Специалисты",
		["zh-cn"] = "专家",
	},
	enemy_target_show_special_description = {
		en = "Allow specials in the enemy target block.",
		ru = "Разрешить показ специалистов в блоке цели.",
		["zh-cn"] = "允许在敌方目标模块中显示专家。",
	},
	divisionhud_super_system = {
		en = "\238\128\169 SYSTEM SETTINGS",
		ru = "\238\128\169 СИСТЕМНЫЕ НАСТРОЙКИ",
		["zh-cn"] = "⚙️ 系统设置",
	},
	debug = {
		en = "Debug",
		ru = "Debug",
		["zh-cn"] = "调试",
	},
	debug_description = {
		en = "Enables the internal DivisionHUD debug hotkeys on the numpad. Numpad 1 shows the alert \"Enemies nearby\". Numpad 2 simulates the invulnerability toughness buff and the 125 + 170 toughness label.",
		ru = "Включает внутренние debug-горячие клавиши DivisionHUD на numpad. Numpad 1 показывает алерт «Враги рядом». Numpad 2 имитирует баф неуязвимости на стойкость и подпись стойкости 125 + 170.",
		["zh-cn"] = "启用 DivisionHUD 的数字小键盘调试热键。小键盘 1 显示“敌人接近”警报，小键盘 2 模拟无敌韧性增益和 125 + 170 韧性文本。",
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
	enemy_target_type_monster = {
		en = "Miniboss",
		ru = "Минибосс",
		["zh-cn"] = "小BOSS",
	},
	enemy_target_type_captain = {
		en = "Boss",
		ru = "Босс",
		["zh-cn"] = "BOSS",
	},
	enemy_target_type_disabler = {
		en = "Disabler",
		ru = "Контроль",
		["zh-cn"] = "控制专家",
	},
	enemy_target_type_witch = {
		en = "Daemonhost",
		ru = "Демонхост",
		["zh-cn"] = "恶魔宿主",
	},
	enemy_target_type_sniper = {
		en = "Sniper",
		ru = "Снайпер",
		["zh-cn"] = "狙击手",
	},
	enemy_target_type_far = {
		en = "Ranged elite",
		ru = "Дальний элитник",
		["zh-cn"] = "远程精英",
	},
	enemy_target_type_elite = {
		en = "Melee elite",
		ru = "Ближний элитник",
		["zh-cn"] = "近战精英",
	},
	enemy_target_type_special = {
		en = "Special",
		ru = "Специалист",
		["zh-cn"] = "输出专家",
	},
	enemy_target_type_horde = {
		en = "Horde",
		ru = "Орда",
		["zh-cn"] = "尸潮怪",
	},
	enemy_target_type_enemy = {
		en = "Enemy",
		ru = "Враг",
		["zh-cn"] = "敌人",
	},
	enemy_target_debuff_label_generic = {
		en = "Generic",
		ru = "Прочее",
		["zh-cn"] = "通用",
	},
	enemy_target_debuff_label_bleed = {
		en = "Bleed",
		ru = "Кровотечение",
		["zh-cn"] = "流血",
	},
	enemy_target_debuff_label_fire = {
		en = "Fire",
		ru = "Поджог",
		["zh-cn"] = "燃烧",
	},
	enemy_target_debuff_label_warp = {
		en = "Warp",
		ru = "Варп",
		["zh-cn"] = "灵能",
	},
	enemy_target_debuff_label_shock = {
		en = "Shock",
		ru = "Шок",
		["zh-cn"] = "电击",
	},
	enemy_target_debuff_label_toxin = {
		en = "Toxin",
		ru = "Токсин",
		["zh-cn"] = "中毒",
	},
	enemy_target_debuff_label_rending = {
		en = "Rending",
		ru = "Пробив брони",
		["zh-cn"] = "破甲",
	},
	enemy_target_debuff_label_arbites = {
		en = "Arbites",
		ru = "Арбитр",
		["zh-cn"] = "仲裁者",
	},
	enemy_target_debuff_label_rage = {
		en = "Rage",
		ru = "Ярость",
		["zh-cn"] = "狂怒",
	},
	enemy_target_debuff_label_stagger = {
		en = "Stagger",
		ru = "Оглушение",
		["zh-cn"] = "击晕",
	},
	enemy_target_debuff_label_blind = {
		en = "Blind",
		ru = "Ослепление",
		["zh-cn"] = "致盲",
	},
	enemy_target_debuff_label_damage_taken = {
		en = "Damage",
		ru = "Урон",
		["zh-cn"] = "易伤",
	},
	enemy_target_debuff_label_melee_damage_taken = {
		en = "Melee Damage",
		ru = "Урон в ближнем",
		["zh-cn"] = "近战易伤",
	},
	enemy_target_debuff_label_stagger_damage = {
		en = "Stagger Damage",
		ru = "Урон по оглушённому",
		["zh-cn"] = "击晕易伤",
	},
	enemy_target_debuff_label_bleed_damage = {
		en = "Bleed Damage",
		ru = "Урон по кровящему",
		["zh-cn"] = "流血易伤",
	},
	enemy_target_debuff_label_toxin_damage = {
		en = "Toxin Damage",
		ru = "Урон по отравленному",
		["zh-cn"] = "中毒易伤",
	},
}
