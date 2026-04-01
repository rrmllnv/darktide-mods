return {
	mod_name = {
		en = "Auspex Wayfinder",
		ru = "Auspex Wayfinder",
	},
	mod_description = {
		en = "After marking a point of interest on the expedition Auspex map, draws a navmesh path from your position to the target. Uses client nav settings; propagation box may need tuning on large maps.",
		ru = "После отметки точки интереса на карте Аусплекса в экспедиции рисует путь по навмешу от вас до цели. Использует клиентские настройки навигации; на больших картах может понадобиться настройка propagation box.",
	},
	path_enabled = {
		en = "Draw path line",
		ru = "Рисовать линию пути",
	},
	path_propagation_box = {
		en = "A* propagation box extent",
		ru = "Размер propagation box для A*",
	},
	path_propagation_box_description = {
		en = "First pass only: boxed A* around start/end. If it fails, the mod retries once with full-map GwNavAStar.start (no box).",
		ru = "Только для первого прохода: A* в коробке. При неудаче мод один раз перезапускает поиск по всему навмешу (GwNavAStar.start).",
	},
	path_line_thickness = {
		en = "Path line thickness",
		ru = "Толщина линии пути",
	},
	path_height = {
		en = "Path Z offset (m)",
		ru = "Смещение Z линии (м)",
	},
	path_color = {
		en = "Path color",
		ru = "Цвет пути",
	},
	path_failed_echo = {
		en = "[Auspex Wayfinder] No path after box, full navmesh, and main-path snap (different nav island or no main path on this mission).",
		ru = "[Auspex Wayfinder] Нет пути: коробка, полный навмеш и снап к main path не помогли (другой остров сетки или нет main path).",
	},
	path_echo_on_fail = {
		en = "Chat echo when path fails",
		ru = "Сообщение в чат при ошибке пути",
	},
	awf_color_warp_high = {
		en = "Warp high (green)",
		ru = "Warp high (зелёный)",
	},
	awf_color_header = {
		en = "Header",
		ru = "Заголовок",
	},
	awf_color_body = {
		en = "Body",
		ru = "Основной текст",
	},
	awf_color_red_light = {
		en = "Red light",
		ru = "Красный светлый",
	},
	awf_color_red_medium = {
		en = "Red medium",
		ru = "Красный средний",
	},
	awf_color_orange = {
		en = "Orange",
		ru = "Оранжевый",
	},
}
