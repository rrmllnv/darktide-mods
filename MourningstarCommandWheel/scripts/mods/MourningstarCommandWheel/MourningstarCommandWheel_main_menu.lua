local mod = get_mod("MourningstarCommandWheel")

-- Добавляем глобальную локализацию для переключения кнопок
-- mod:add_global_localize_strings({
-- 	loc_toggle_view_buttons = {
-- 		en = "Toggle Buttons",
-- 		["zh-cn"] = "切换按钮",
-- 		ru = "Переключить кнопки",
-- 		ja = "ボタンの切り替え",
-- 		["zh-tw"] = "切換按鈕",
-- 		ko = "버튼 전환",
-- 	}
-- })

local Promise = require("scripts/foundation/utilities/promise")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local _setup_complete = false

-- Имя кнопки для открытия view
local _open_menu_button = "main_menu_open_menu_button"

-- Функция для открытия нашего view
local function _open_main_menu_view()
	Managers.ui:open_view("mourningstar_command_wheel_main_menu_view", nil, nil, nil, nil, {})
end

-- Hook на main_menu_view_definitions для добавления одной кнопки
local main_menu_definitions_file = "scripts/ui/views/main_menu_view/main_menu_view_definitions"
mod:hook_require(main_menu_definitions_file, function(definitions)
	-- Добавляем одну кнопку для открытия view
	local button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, _open_menu_button, {
		text = mod:localize("main_menu_open_menu_button"),
	})

	definitions.widget_definitions[_open_menu_button] = button
	definitions.scenegraph_definition[_open_menu_button] = {
		parent = "play_button",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = { 240, 50 },
		position = { 0, 45, 0 }
	}
end)

-- Hook на MainMenuView._setup_interactions для установки callback
mod:hook_safe(CLASS.MainMenuView, "_setup_interactions", function(self)
	local widgets_by_name = self._widgets_by_name

	-- Устанавливаем callback для кнопки открытия view
	local button_widget = widgets_by_name[_open_menu_button]
	if button_widget then
		local content = button_widget.content
		if content and content.hotspot then
			content.hotspot.pressed_callback = function()
				_open_main_menu_view()
			end
		end
	end

	_setup_complete = true
end)

-- Hook на MainMenuView._handle_input для обработки input
mod:hook(CLASS.MainMenuView, "_handle_input", function(func, self, input_service, dt, t)
	func(self, input_service, dt, t)

	local is_in_matchmaking = Managers.party_immaterium:is_in_matchmaking()

	-- Отключаем кнопку во время matchmaking
	local button_widget = self._widgets_by_name[_open_menu_button]
	if button_widget then
		button_widget.content.hotspot.disabled = is_in_matchmaking
	end

	if not _setup_complete then
		self:_setup_interactions()
	end
end)

