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
	divisionhud_super_bars = {
		en = "\238\128\178 COMBAT HUD",
		ru = "\238\128\178 БОЕВОЙ HUD",
		["zh-cn"] = "\238\128\178 战斗界面",
	},
	divisionhud_super_dynamic = {
		en = "\238\129\135 DYNAMIC HUD",
		ru = "\238\129\135 ДИНАМИЧЕСКИЙ HUD",
		["zh-cn"] = "\238\129\135 动态界面",
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
	alerts_group_bosses = {
		en = "Bosses",
		ru = "Боссы",
		["zh-cn"] = "首领",
	},
	alerts_group_specialists = {
		en = "Specialists",
		ru = "Специалисты",
		["zh-cn"] = "专家单位",
	},
	alerts_ui_banner_alert = {
		en = "ALERT",
		ru = "ВНИМАНИЕ",
		["zh-cn"] = "警报",
	},
	alerts_message_specialist_approach = {
		en = "Approaching %s",
		ru = "Приближение %s",
		["zh-cn"] = "接近：%s",
	},
	alerts_message_boss_approach = {
		en = "Approaching %s",
		ru = "Приближение %s",
		["zh-cn"] = "接近：%s",
	},
}