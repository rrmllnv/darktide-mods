# MourningstarCommandWheel_buttons.lua - Документация

## Описание файла

Файл определений кнопок для колеса команд. Содержит массив всех доступных кнопок с их параметрами (id, view, label_key, icon, action) и словарь для быстрого доступа по id.

## Структура файла

Файл определяет:
- `button_definitions` - массив всех определений кнопок
- `button_definitions_by_id` - словарь для быстрого доступа к кнопкам по их id

Файл возвращает таблицу с этими двумя полями.

---

## Структура определения кнопки

Каждая кнопка представляет собой таблицу со следующими полями:

### `id`
Уникальный идентификатор кнопки.

**Тип:** `string`  
**Примеры:** `"barber"`, `"crafting"`, `"change_character"`

### `view`
Имя вью (view), которое открывается при клике на кнопку.

**Тип:** `string` или `nil`  
**Примеры:** `"barber_vendor_background_view"`, `"crafting_view"`, `nil` (для кнопок с action)

**Примечание:** Если `view` равен `nil`, кнопка использует `action` вместо открытия вью.

### `label_key`
Ключ локализации для названия кнопки.

**Тип:** `string`  
**Примеры:** `"loc_body_shop_view_display_name"`, `"loc_crafting_view"`

**Примечание:** Если ключ начинается с `"loc_"`, используется встроенная локализация игры, иначе - локализация мода.

### `icon`
Путь к иконке кнопки.

**Тип:** `string`  
**Примеры:** `"content/ui/materials/hud/interactions/icons/barber"`, `"content/ui/materials/icons/system/escape/change_character"`

### `action`
Действие, которое выполняется при клике на кнопку (вместо открытия вью).

**Тип:** `string` или `nil`  
**Возможные значения:**
- `"change_character"` - смена персонажа
- `"exit_psychanium"` - выход из псайкинариума
- `nil` - используется `view` вместо действия

---

## Список доступных кнопок

### 1. `barber` - Парикмахерская
- **view:** `"barber_vendor_background_view"`
- **label_key:** `"loc_body_shop_view_display_name"`
- **icon:** `"content/ui/materials/hud/interactions/icons/barber"`

### 2. `contracts` - Контракты
- **view:** `"contracts_background_view"`
- **label_key:** `"loc_marks_vendor_view_title"`
- **icon:** `"content/ui/materials/hud/interactions/icons/contracts"`

### 3. `crafting` - Крафтинг
- **view:** `"crafting_view"`
- **label_key:** `"loc_crafting_view"`
- **icon:** `"content/ui/materials/hud/interactions/icons/forge"`

### 4. `credits_vendor` - Торговец кредитами
- **view:** `"credits_vendor_background_view"`
- **label_key:** `"loc_vendor_view_title"`
- **icon:** `"content/ui/materials/hud/interactions/icons/credits_store"`

### 5. `mission_board` - Доска миссий
- **view:** `"mission_board_view"`
- **label_key:** `"loc_mission_board_view"`
- **icon:** `"content/ui/materials/hud/interactions/icons/mission_board"`

### 6. `premium_store` - Премиум магазин
- **view:** `"store_view"`
- **label_key:** `"loc_store_view_display_name"`
- **icon:** `"content/ui/materials/icons/system/escape/premium_store"`

### 7. `training_grounds` - Псайкинариум
- **view:** `"training_grounds_view"`
- **label_key:** `"loc_training_ground_view"`
- **icon:** `"content/ui/materials/hud/interactions/icons/training_grounds"`

**Примечание:** Эта кнопка динамически заменяется на `exit_psychanium` при входе в псайкинариум.

### 8. `exit_psychanium` - Выход из псайкинариума
- **view:** `nil`
- **label_key:** `"loc_tg_exit_training_grounds"`
- **icon:** `"content/ui/materials/icons/system/escape/leave_training"`
- **action:** `"exit_psychanium"`

**Примечание:** Эта кнопка появляется только в псайкинариуме, заменяя кнопку `training_grounds`.

### 9. `social` - Социальное меню
- **view:** `"social_menu_view"`
- **label_key:** `"loc_social_view_display_name"`
- **icon:** `"content/ui/materials/icons/system/escape/social"`

### 10. `commissary` - Комиссариат
- **view:** `"cosmetics_vendor_background_view"`
- **label_key:** `"loc_cosmetics_vendor_view_title"`
- **icon:** `"content/ui/materials/hud/interactions/icons/cosmetics_store"`

### 11. `penance` - Достижения
- **view:** `"penance_overview_view"`
- **label_key:** `"loc_achievements_view_display_name"`
- **icon:** `"content/ui/materials/icons/system/escape/achievements"`

### 12. `inventory` - Инвентарь
- **view:** `"inventory_background_view"`
- **label_key:** `"loc_character_view_display_name"`
- **icon:** `"content/ui/materials/icons/system/escape/inventory"`

### 13. `change_character` - Смена персонажа
- **view:** `nil`
- **label_key:** `"loc_exit_to_main_menu_display_name"`
- **icon:** `"content/ui/materials/icons/system/escape/change_character"`
- **action:** `"change_character"`

**Примечание:** Эта кнопка неактивна в главном меню.

### 14. `havoc` - Хаос
- **view:** `"havoc_background_view"`
- **label_key:** `"loc_havoc_name"`
- **icon:** `"content/ui/materials/hud/interactions/icons/havoc"`

---

## `button_definitions_by_id`

Словарь для быстрого доступа к кнопкам по их id.

**Тип:** `table`  
**Ключи:** `string` (id кнопки)  
**Значения:** `table` (определение кнопки)

**Создание:** Автоматически создается из `button_definitions` при загрузке файла.

**Использование:** Используется в `HudElementCommandWheel.lua` для быстрого поиска кнопок по id при генерации опций из конфигурации.

---

## Использование

Файл используется в `HudElementCommandWheel.lua`:

1. **Загрузка определений:**
   ```lua
   local Buttons = require("MourningstarCommandWheel/scripts/mods/MourningstarCommandWheel/MourningstarCommandWheel_buttons")
   local button_definitions = Buttons.button_definitions
   local button_definitions_by_id = Buttons.button_definitions_by_id
   ```

2. **Генерация опций из конфигурации:**
   - Используется `button_definitions_by_id` для поиска кнопок по id
   - Используется для динамической замены `training_grounds` на `exit_psychanium`

3. **Загрузка конфигурации:**
   - Используется `button_definitions` для проверки валидности сохраненной конфигурации
   - Используется для добавления новых кнопок в конфигурацию по умолчанию

---

## Примечания

- Кнопка `exit_psychanium` не добавляется в конфигурацию по умолчанию, так как она является динамической заменой
- Порядок кнопок в `button_definitions` определяет порядок по умолчанию при первой загрузке
- Все кнопки с `action` не имеют `view` и наоборот
- Иконки находятся в различных путях игры, в зависимости от типа кнопки

