local mod = get_mod("PerspectivesRedux")

local loc = {
	mod_description = {
		en = "Switch between first and third person perspectives. Redux version with optimizations and fixes.",
		["zh-cn"] = "在第一人称和第三人称视角之间切换。优化和修复版本。",
		ru = "Переключение между видами от первого и третьего лица. Redux версия с оптимизациями и исправлениями.",
	},
	allow_switching = {
		en = "Allow Perspective Switching",
		["zh-cn"] = "允许视角切换",
		ru = "Разрешить переключение перспективы",
	},
	allow_switching_description = {
		en = "Turn off to effectively disable the mod.",
		["zh-cn"] = "关闭此选项实际禁用此模组。",
		ru = "Отключите, чтобы фактически отключить мод.",
	},
	third_person_toggle = {
		en = "Switch Perspective (Toggle)",
		["zh-cn"] = "切换视角（切换）",
		ru = "Переключить перспективу (Toggle)",
	},
	third_person_held = {
		en = "Switch Perspective (Held)",
		["zh-cn"] = "切换视角（按住）",
		ru = "Переключить перспективу (Удержание)",
	},
	cycle_shoulder = {
		en = "Cycle Viewpoint",
		["zh-cn"] = "循环视角",
		ru = "Циклический обзор",
	},
	aim_mode = {
		en = "Aiming Behavior",
		["zh-cn"] = "瞄准行为",
		ru = "Поведение прицеливания",
	},
	nonaim_mode = {
		en = "Non-Aiming Behavior",
		["zh-cn"] = "非瞄准行为",
		ru = "Поведение без прицеливания",
	},
	viewpoint_1p = {
		en = "Switch to 1st Person",
		["zh-cn"] = "切换到第一人称",
		ru = "Переключить на 1-е лицо",
	},
	viewpoint_cycle = {
		en = "Cycled Viewpoint",
		["zh-cn"] = "循环视角",
		ru = "Циклический вид",
	},
	viewpoint_center = {
		en = "Center",
		["zh-cn"] = "中心",
		ru = "Центр",
	},
	viewpoint_right = {
		en = "Right",
		["zh-cn"] = "右侧",
		ru = "Справа",
	},
	viewpoint_left = {
		en = "Left",
		["zh-cn"] = "左侧",
		ru = "Слева",
	},
	cycle_includes_center = {
		en = "Include Center in Cycle",
		["zh-cn"] = "在循环中包含中心视角",
		ru = "Включить центр в цикл",
	},
	center_to_1p_human = {
		en = "Center Aim Goes to 1st Person (Human)",
		["zh-cn"] = "中心瞄准改为第一人称（人类）",
		ru = "Центр. прицел в 1-е лицо (Человек)",
	},
	center_to_1p_ogryn = {
		en = "Center Aim Goes to 1st Person (Ogryn)",
		["zh-cn"] = "中心瞄准改为第一人称（欧格林）",
		ru = "Центр. прицел в 1-е лицо (Огрин)",
	},
	center_to_1p_description = {
		en = "If on, when cycled to a centered viewpoint and aiming, you'll temporarily go to 1st person instead of using the 3rd person centered aim camera. This is recommended for humans, and very strongly recommended for Ogryns.",
		["zh-cn"] = "启用后，切换到中心视角并在瞄准时，你会临时进入第一人称而不是第三人称中心视角。推荐为人类角色启用，强烈推荐为欧格林启用。",
		ru = "Если включено, при центральном обзоре и прицеливании вы временно перейдете в 1-е лицо вместо использования центральной камеры 3-го лица. Рекомендуется для людей и настоятельно рекомендуется для огринов.",
	},
	perspective_transition_time = {
		en = "Perspective Transition Time",
		["zh-cn"] = "视角切换时间",
		ru = "Время перехода перспективы",
	},
	group_custom_viewpoint = {
		en = "Custom Viewpoint",
		["zh-cn"] = "自定义视角",
		ru = "Пользовательский обзор",
	},
	custom_distance = {
		en = "Camera Distance (Non-Aiming)",
		["zh-cn"] = "摄像机距离（非瞄准）",
		ru = "Дистанция камеры (без прицела)",
	},
	custom_distance_description = {
		en = "Increase to push your camera farther backward.",
		["zh-cn"] = "增大表示向后移动摄像机。",
		ru = "Увеличьте, чтобы отодвинуть камеру дальше назад.",
	},
	custom_offset = {
		en = "Camera Offset (Non-Aiming)",
		["zh-cn"] = "摄像机偏移（非瞄准）",
		ru = "Смещение камеры (без прицела)",
	},
	custom_offset_description = {
		en = "Increase to push your camera farther from the center of your character. For example, the left-side viewpoint will be farther left at higher values.",
		["zh-cn"] = "增大表示摄像机远离角色中心。例如，值越大，左侧视角就更偏左。",
		ru = "Увеличьте, чтобы отодвинуть камеру дальше от центра персонажа. Например, левый вид будет дальше влево при больших значениях.",
	},
	custom_distance_zoom = {
		en = "Camera Distance (Aiming)",
		["zh-cn"] = "摄像机距离（瞄准）",
		ru = "Дистанция камеры (прицел)",
	},
	custom_offset_zoom = {
		en = "Camera Offset (Aiming)",
		["zh-cn"] = "摄像机偏移（瞄准）",
		ru = "Смещение камеры (прицел)",
	},
	custom_distance_ogryn = {
		en = "Camera Distance (Ogryn)",
		["zh-cn"] = "摄像机距离（欧格林）",
		ru = "Дистанция камеры (Огрин)",
	},
	custom_offset_ogryn = {
		en = "Camera Offset (Ogryn)",
		["zh-cn"] = "摄像机偏移（欧格林）",
		ru = "Смещение камеры (Огрин)",
	},
	xhair_fallback = {
		en = "'No Crosshair' in 3rd Person",
		["zh-cn"] = "第三人称下的"无准星时"设置",
		ru = "'Нет прицела' в 3-м лице",
	},
	use_lookaround_node = {
		en = "[LookAround] 3rd Person Inspect",
		["zh-cn"] = "[LookAround] 第三人称检视",
		ru = "[LookAround] Осмотр в 3-м лице",
	},
	use_lookaround_node_description = {
		en = "When using the mod LookAround to get freelook in 3rd person, use the 3rd Person Inspect viewpoint.",
		["zh-cn"] = "在第三人称下使用 LookAround 模组的自由查看时，使用第三人称检视视角。",
		ru = "При использовании мода LookAround для свободного обзора в 3-м лице используется точка обзора Осмотр в 3-м лице.",
	},
	default_perspective_mode = {
		en = "Initial Perspective",
		["zh-cn"] = "初始视角",
		ru = "Начальная перспектива",
	},
	defper_normal = {
		en = "Default",
		["zh-cn"] = "默认",
		ru = "По умолчанию",
	},
	defper_swapped = {
		en = "Opposite of Default",
		["zh-cn"] = "反转默认",
		ru = "Противоположность умолчанию",
	},
	defper_always_first = {
		en = "1st Person",
		["zh-cn"] = "第一人称",
		ru = "1-е лицо",
	},
	defper_always_third = {
		en = "3rd Person",
		["zh-cn"] = "第三人称",
		ru = "3-е лицо",
	},
	group_3p_behavior = {
		en = "3rd Person Behavior",
		["zh-cn"] = "第三人称行为",
		ru = "Поведение 3-го лица",
	},
	group_autoswitch = {
		en = "Auto-switch Perspectives",
		["zh-cn"] = "自动切换视角",
		ru = "Автопереключение перспектив",
	},
	autoswitch_spectate = {
		en = "Spectating",
		["zh-cn"] = "旁观者",
		ru = "Наблюдение",
	},
	autoswitch_slot_primary = {
		en = Localize("loc_ingame_wield_1")
	},
	autoswitch_slot_secondary = {
		en = Localize("loc_ingame_wield_2")
	},
	autoswitch_slot_grenade_ability = {
		en = Localize("loc_ingame_grenade_ability")
	},
	autoswitch_slot_pocketable = {
		en = Localize("loc_ingame_wield_3_v2")
	},
	autoswitch_slot_pocketable_small = {
		en = Localize("loc_ingame_wield_4_v2")
	},
	autoswitch_slot_device = {
		en = Localize("loc_ingame_wield_5")
	},
	autoswitch_slot_luggable = {
		en = Localize("loc_item_type_luggable")
	},
	autoswitch_slot_luggable_description = {
		en = Localize("loc_pickup_luggable_battery_01") .. " / " .. Localize("loc_pickup_luggable_control_rod_01")
	},
	autoswitch_slot_unarmed = {
		en = "Unarmed",
		["zh-cn"] = "无装备",
		ru = "Без оружия",
	},
	autoswitch_slot_unarmed_description = {
		en = "Occurs whenever your character puts your weapon away, e.g. when interacting with certain objects or being knocked back.",
		["zh-cn"] = "角色收起武器时出现，例如与特定对象交互或者被击退的情况。",
		ru = "Происходит, когда ваш персонаж убирает оружие, например, при взаимодействии с определенными объектами или при отбрасывании.",
	},
	autoswitch_sprint = {
		en = Localize("loc_ingame_sprint")
	},
	autoswitch_lunge_ogryn = {
		en = "Charge (Ogryn)",
		["zh-cn"] = "冲锋（欧格林）",
		ru = "Рывок (Огрин)",
	},
	autoswitch_lunge_human = {
		en = "Charge (Zealot)",
		["zh-cn"] = "冲锋（狂信徒）",
		ru = "Рывок (Фанатик)",
	},
	autoswitch_act2_primary = {
		en = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_primary")
	},
	autoswitch_act2_secondary = {
		en = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_secondary")
	},
	autoswitch_to_none = {
		en = "Don't Switch",
		["zh-cn"] = "不切换",
		ru = "Не переключать",
	},
	autoswitch_to_first = {
		en = "1st Person",
		["zh-cn"] = "第一人称",
		ru = "1-е лицо",
	},
	autoswitch_to_third = {
		en = "3rd Person",
		["zh-cn"] = "第三人称",
		ru = "3-е лицо",
	},
}

-- Интеграция с crosshair_remap если доступен
local crosshair_remap = get_mod("crosshair_remap")
if crosshair_remap and crosshair_remap.all_crosshair_names then
	mod._xhair_types = crosshair_remap.all_crosshair_names
	for _, type in ipairs(mod._xhair_types) do
		loc["xhair_" .. type] = {
			en = crosshair_remap:localize(type .. "_crosshair")
		}
	end
else
	-- Fallback к стандартным типам прицелов
	mod._xhair_types = { "none", "cross", "assault", "bfg", "shotgun", "spray_n_pray", "dot" }
	for _, type in ipairs(mod._xhair_types) do
		loc["xhair_" .. type] = {
			en = Localize(type == "none" and "loc_setting_notification_type_none" or ("loc_setting_crosshair_type_override_" .. (type ~= "cross" and type or "killshot"))),
		}
	end
end

return loc

