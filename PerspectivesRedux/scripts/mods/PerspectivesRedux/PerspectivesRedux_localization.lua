local mod = get_mod("PerspectivesRedux")

local loc = {
	mod_description = {
		en = "Switch between first and third person perspectives.",
		ru = "Переключение между первым и третьим лицом.",
		["zh-cn"] = "在第一人称和第三人称视角之间切换。",
	},
	allow_switching = {
		en = "Allow Perspective Switching",
		ru = "Разрешить переключение перспективы",
		["zh-cn"] = "允许视角切换",
	},
	allow_switching_description = {
		en = "Turn off to effectively disable the mod.",
		ru = "Выключить, чтобы фактически отключить мод.",
		["zh-cn"] = "关闭此选项实际禁用此模组。",
	},
	third_person_toggle = {
		en = "Switch Perspective (Toggle)",
		ru = "Переключить перспективу (нажатие)",
		["zh-cn"] = "切换视角（切换）",
	},
	third_person_held = {
		en = "Switch Perspective (Held)",
		ru = "Переключить перспективу (удержание)",
		["zh-cn"] = "切换视角（按住）",
	},
	cycle_shoulder = {
		en = "Cycle Viewpoint",
		ru = "Циклический взгляд",
		["zh-cn"] = "循环视角",
	},
	aim_mode = {
		en = "Aiming Behavior",
		ru = "Поведение прицеливания",
		["zh-cn"] = "瞄准行为",
	},
	nonaim_mode = {
		en = "Non-Aiming Behavior",
		ru = "Поведение без прицеливания",
		["zh-cn"] = "非瞄准行为",
	},
	viewpoint_1p = {
		en = "Switch to 1st Person",
		ru = "Переключить на первое лицо",
		["zh-cn"] = "切换到第一人称",
	},
	viewpoint_cycle = {
		en = "Cycled Viewpoint",
		ru = "Циклический взгляд",
		["zh-cn"] = "循环视角",
	},
	viewpoint_center = {
		en = "Center",
		ru = "Центр",
		["zh-cn"] = "中心",
	},
	viewpoint_right = {
		en = "Right",
		ru = "Право",
		["zh-cn"] = "右侧",
	},
	viewpoint_left = {
		en = "Left",
		ru = "Лево",
		["zh-cn"] = "左侧",
	},
	cycle_includes_center = {
		en = "Include Center in Cycle",
		ru = "Включить центр в цикл",
		["zh-cn"] = "在循环中包含中心视角",
	},
	center_to_1p_human = {
		en = "Center Aim Goes to 1st Person (Human)",
		ru = "Центр прицеливания переключается на первое лицо (человек)",
		["zh-cn"] = "中心瞄准改为第一人称（人类）",
	},
	center_to_1p_ogryn = {
		en = "Center Aim Goes to 1st Person (Ogryn)",
		ru = "Центр прицеливания переключается на первое лицо (огр)",
		["zh-cn"] = "中心瞄准改为第一人称（欧格林）",
	},
	center_to_1p_description = {
		en = "If on, when cycled to a centered viewpoint and aiming, you'll temporarily go to 1st person instead of using the 3rd person centered aim camera. This is recommended for humans, and very strongly recommended for Ogryns.",
		ru = "Если включено, при переключении на центр и прицеливание, вы временно переключитесь на первое лицо вместо использования камеры прицеливания в третьем лице. Это рекомендуется для людей и очень сильно рекомендуется для Огренов.",
		["zh-cn"] = "启用后，切换到中心视角并在瞄准时，你会临时进入第一人称而不是第三人称中心视角。推荐为人类角色启用，强烈推荐为欧格林启用。",
	},
	perspective_transition_time = {
		en = "Perspective Transition Time",
		ru = "Время переключения перспективы",
		["zh-cn"] = "视角切换时间",
	},
	group_custom_viewpoint = {
		en = "Custom Viewpoint",
		ru = "Пользовательский взгляд",
		["zh-cn"] = "自定义视角",
	},
	custom_distance = {
		en = "Camera Distance (Non-Aiming)",
		ru = "Расстояние камеры (без прицеливания)",
		["zh-cn"] = "摄像机距离（非瞄准）",
	},
	custom_distance_description = {
		en = "Increase to push your camera farther backward.",
		ru = "Увеличение расстояния приближает камеру ближе к вам.",
		["zh-cn"] = "增大表示向后移动摄像机。",
	},
	custom_offset = {
		en = "Camera Offset (Non-Aiming)",
		ru = "Смещение камеры (без прицеливания)",
		["zh-cn"] = "摄像机偏移（非瞄准）",
	},
	custom_offset_description = {
		en = "Increase to push your camera farther from the center of your character. For example, the left-side viewpoint will be farther left at higher values.",
		ru = "Увеличение смещения приближает камеру ближе к вам.",
		["zh-cn"] = "增大表示摄像机远离角色中心。例如，值越大，左侧视角就更偏左。",
	},
	custom_distance_zoom = {
		en = "Camera Distance (Aiming)",
		ru = "Расстояние камеры (прицеливание)",
		["zh-cn"] = "摄像机距离（瞄准）",
	},
	custom_offset_zoom = {
		en = "Camera Offset (Aiming)",
		ru = "Смещение камеры (прицеливание)",
		["zh-cn"] = "摄像机偏移（瞄准）",
	},
	custom_distance_ogryn = {
		en = "Camera Distance (Ogryn)",
		ru = "Расстояние камеры (огр)",
		["zh-cn"] = "摄像机距离（欧格林）",
	},
	custom_offset_ogryn = {
		en = "Camera Offset (Ogryn)",
		ru = "Смещение камеры (огр)",
		["zh-cn"] = "摄像机偏移（欧格林）",
	},
	xhair_fallback = {
		en = "'No Crosshair' in 3rd Person",
		ru = "“Без прицела” в третьем лице",
		["zh-cn"] = "第三人称下的“无准星时”设置",
	},
	use_lookaround_node = {
		en = "[LookAround] 3rd Person Inspect",
		ru = "[LookAround] Третье лицо для осмотра",
		["zh-cn"] = "[LookAround] 第三人称检视",
	},
	use_lookaround_node_description = {
		en = "When using the mod LookAround to get freelook in 3rd person, use the 3rd Person Inspect viewpoint.",
		ru = "При использовании мода LookAround для свободного обзора в третьем лице, используйте взгляд для осмотра в третьем лице.",
		["zh-cn"] = "在第三人称下使用 LookAround 模组的自由查看时，使用第三人称检视视角。",
	},
	default_perspective_mode = {
		en = "Initial Perspective",
		ru = "Начальная перспектива",
		["zh-cn"] = "初始视角",
	},
	defper_normal = {
		en = "Default",
		ru = "По умолчанию",
		["zh-cn"] = "默认",
	},
	defper_swapped = {
		en = "Opposite of Default",
		ru = "Противоположность по умолчанию",
		["zh-cn"] = "反转默认",
	},
	defper_always_first = {
		en = "1st Person",
		ru = "Первое лицо",
		["zh-cn"] = "第一人称",
	},
	defper_always_third = {
		en = "3rd Person",
		ru = "Третье лицо",
		["zh-cn"] = "第三人称",
	},
	group_3p_behavior = {
		en = "3rd Person Behavior",
		ru = "Поведение в третьем лице",
		["zh-cn"] = "第三人称行为",
	},
	group_autoswitch = {
		en = "Auto-switch Perspectives",
		ru = "Автоматическое переключение перспективы",
		["zh-cn"] = "自动切换视角",
	},
	autoswitch_spectate = {
		en = "Spectating",
		ru = "Наблюдение",
		["zh-cn"] = "旁观者",
	},
	autoswitch_slot_primary = {
		en = Localize("loc_ingame_wield_1"),
		ru = Localize("loc_ingame_wield_1"),
	},
	autoswitch_slot_secondary = {
		en = Localize("loc_ingame_wield_2"),
		ru = Localize("loc_ingame_wield_2"),
	},
	autoswitch_slot_grenade_ability = {
		en = Localize("loc_ingame_grenade_ability"),
		ru = Localize("loc_ingame_grenade_ability"),
	},
	autoswitch_slot_pocketable = {
		en = Localize("loc_ingame_wield_3_v2"),
		ru = Localize("loc_ingame_wield_3_v2"),
	},
	autoswitch_slot_pocketable_small = {
		en = Localize("loc_ingame_wield_4_v2"),
		ru = Localize("loc_ingame_wield_4_v2"),
	},
	autoswitch_slot_device = {
		en = Localize("loc_ingame_wield_5"),
		ru = Localize("loc_ingame_wield_5"),
	},
	autoswitch_slot_luggable = {
		en = Localize("loc_item_type_luggable"),
		ru = Localize("loc_item_type_luggable"),
	},
	autoswitch_slot_luggable_description = {
		en = Localize("loc_pickup_luggable_battery_01") .. " / " .. Localize("loc_pickup_luggable_control_rod_01"),
		ru = Localize("loc_pickup_luggable_battery_01") .. " / " .. Localize("loc_pickup_luggable_control_rod_01"),
	},
	autoswitch_slot_unarmed = {
		en = "Unarmed",
		ru = "Без оружия",
		["zh-cn"] = "无装备",
	},
	autoswitch_slot_unarmed_description = {
		en = "Occurs whenever your character puts your weapon away, e.g. when interacting with certain objects or being kocked back.",
		ru = "Происходит, когда ваш персонаж кладет оружие, например, при взаимодействии с определенными объектами или при ударе.",
		["zh-cn"] = "角色收起武器时出现，例如与特定对象交互或者被击退的情况。",
	},
	autoswitch_sprint = {
		en = Localize("loc_ingame_sprint"),
		ru = Localize("loc_ingame_sprint"),
	},
	autoswitch_lunge_ogryn = {
		en = "Charge (Ogryn)",
		ru = "Зарядка (Огр)",
		["zh-cn"] = "冲锋（欧格林）",
	},
	autoswitch_lunge_human = {
		en = "Charge (Zealot)",
		ru = "Зарядка (Зеалот)",
		["zh-cn"] = "冲锋（狂信徒）",
	},
	autoswitch_act2_primary = {
		en = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_primary"),
		ru = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_primary"),
	},
	autoswitch_act2_secondary = {
		en = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_secondary"),
		ru = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_secondary"),
	},
	autoswitch_to_none = {
		en = "Don't Switch",
		ru = "Не переключать",
		["zh-cn"] = "不切换",
	},
	autoswitch_to_first = {
		en = "1st Person",
		ru = "Первое лицо",
		["zh-cn"] = "第一人称",
	},
	autoswitch_to_third = {
		en = "3rd Person",
		ru = "Третье лицо",
		["zh-cn"] = "第三人称",
	},
	group_tracer = {
		en = "Tracer Beam",
		ru = "Луч трассера",
		["zh-cn"] = "弹道轨迹",
	},
	tracer_enabled = {
		en = "Enable Tracer Beam",
		ru = "Включить луч трассера",
		["zh-cn"] = "启用弹道轨迹",
	},
	tracer_duration = {
		en = "Tracer Duration",
		ru = "Длительность луча",
		["zh-cn"] = "轨迹持续时间",
	},
	tracer_color_r = {
		en = "Tracer Color (Red)",
		ru = "Цвет луча (Красный)",
		["zh-cn"] = "轨迹颜色（红色）",
	},
	tracer_color_g = {
		en = "Tracer Color (Green)",
		ru = "Цвет луча (Зеленый)",
		["zh-cn"] = "轨迹颜色（绿色）",
	},
	tracer_color_b = {
		en = "Tracer Color (Blue)",
		ru = "Цвет луча (Синий)",
		["zh-cn"] = "轨迹颜色（蓝色）",
	},
}

local crosshair_remap = get_mod("crosshair_remap")
if crosshair_remap and crosshair_remap.all_crosshair_names then
	mod._xhair_types = crosshair_remap.all_crosshair_names
	for _, type in ipairs(mod._xhair_types) do
		loc["xhair_" .. type] = {
			en = crosshair_remap:localize(type .. "_crosshair"),
			ru = crosshair_remap:localize(type .. "_crosshair"),
		}
	end
else
	mod._xhair_types = { "none", "cross", "assault", "bfg", "shotgun", "spray_n_pray", "dot" }
	for _, type in ipairs(mod._xhair_types) do
		loc["xhair_" .. type] = {
			en = Localize(type == "none" and "loc_setting_notification_type_none" or ("loc_setting_crosshair_type_override_" .. (type ~= "cross" and type or "killshot"))),
			ru = Localize(type == "none" and "loc_setting_notification_type_none" or ("loc_setting_crosshair_type_override_" .. (type ~= "cross" and type or "killshot"))),
		}
	end
end

return loc
