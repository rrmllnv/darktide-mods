# Описание настроек PerspectivesRedux

Подробное описание всех настроек мода и их влияния на код.

---

## Основные настройки

### `allow_switching` (checkbox)
**По умолчанию:** `true`

**Описание:** Главный переключатель мода. Разрешает или запрещает переключение между видами.

**Как работает в коде:**
```lua
-- Обработчик: mod.on_setting_changed("allow_switching")
mod.disable_3p_due_to("_mod", not val)
```
- Если `false` - добавляет причину `"_mod"` для отключения 3P режима
- Если `true` - удаляет эту причину, разрешая переключение
- Проверяется функцией `mod.is_requesting_third_person()`

---

## Горячие клавиши

### `third_person_toggle` (keybind)
**По умолчанию:** не назначена  
**Тип:** `pressed` (нажатие)

**Описание:** Переключает между видом от первого и третьего лица.

**Как работает в коде:**
```lua
-- Вызывает: mod.kb_toggle_third_person()
-- Которая вызывает: mod.toggle_third_person()
local prev = mod.is_requesting_third_person()
mod.clear_reason("slot")
mod.clear_reason("spectate")

if prev == mod.is_requesting_third_person() then
    mod.enable_3p_due_to("_base", not prev)
end
```
- Очищает временные причины (`slot`, `spectate`)
- Переключает базовое состояние 3P режима через `"_base"` reason
- Работает только когда курсор не активен

### `third_person_held` (keybind)
**По умолчанию:** не назначена  
**Тип:** `held` (удержание)

**Описание:** Временно переключает вид на время удержания клавиши.

**Как работает в коде:**
- Использует ту же функцию `mod.kb_toggle_third_person()`
- За счёт типа `held` автоматически возвращает состояние при отпускании

### `cycle_shoulder` (keybind)
**По умолчанию:** не назначена  
**Тип:** `pressed`

**Описание:** Циклически переключает плечо камеры (правое → левое → центр*).

**Как работает в коде:**
```lua
-- Вызывает: mod.kb_cycle_shoulder()
current_viewpoint = _get_next_viewpoint(current_viewpoint)
aim_node = _get_aim_node()
nonaim_node = _get_nonaim_node()

-- Логика цикла:
if previous == "pspv_right" then
    return "pspv_left"
end
if previous == "pspv_left" and cached_settings.cycle_includes_center then
    return "pspv_center"
end
return "pspv_right"
```
- Переключает между `pspv_right` → `pspv_left` → `pspv_center`* → `pspv_right`
- *Центр включается в цикл только если `cycle_includes_center = true`
- Обновляет ноды прицеливания и обычного режима

---

## Настройки перехода

### `perspective_transition_time` (numeric)
**По умолчанию:** `0.1`  
**Диапазон:** `0.0 - 1.0`  
**Точность:** 2 знака

**Описание:** Время анимации перехода между видами (в секундах).

**Как работает в коде:**
```lua
-- Модифицирует глобальные настройки камеры:
CameraTransitionTemplates.to_third_person.position.duration = val
CameraTransitionTemplates.to_first_person.position.duration = val

-- Оригинальные значения сохраняются:
original_transition_duration.to_third_person = <original_value>
original_transition_duration.to_first_person = <original_value>

-- При выгрузке мода восстанавливаются:
-- mod.on_unload() -> восстановление оригинальных значений
```
- `0.0` = мгновенное переключение
- `1.0` = медленный переход (1 секунда)
- Значение применяется к обоим направлениям перехода

---

## Режим перспективы по умолчанию

### `default_perspective_mode` (dropdown)
**По умолчанию:** `0` (Normal)

**Опции:**
- `0` - **Normal**: Стандартное поведение игры
- `-1` - **Swapped**: Инвертирует стандартное поведение игры
- `1` - **Always First Person**: Всегда первое лицо
- `2` - **Always Third Person**: Всегда третье лицо

**Как работает в коде:**
```lua
-- Хук: MissionManager.force_third_person_mode
local request_3p = func(self) -- получить дефолт из игры

if mode == -1 then
    request_3p = not request_3p  -- инвертировать
elseif mode == 1 then
    request_3p = false  -- принудительно 1P
elseif mode == 2 then
    request_3p = true   -- принудительно 3P
end

mod.enable_3p_due_to("_base", request_3p)
```
- Модифицирует базовый запрос игры на третье лицо
- Устанавливает начальное состояние через `"_base"` reason
- Влияет на все миссии, кроме хаба (хаб имеет отдельную логику)

---

## Группа: Поведение в третьем лице

### `aim_mode` (dropdown)
**По умолчанию:** `0` (Cycle)

**Опции:**
- `-1` - **1st Person**: Переходить в первое лицо при прицеливании
- `0` - **Cycle**: Использовать текущее плечо (из цикла)
- `1` - **Center**: Центральная позиция камеры
- `2` - **Right**: Правое плечо
- `3` - **Left**: Левое плечо

**Как работает в коде:**
```lua
-- Кэшируется в: cached_settings.aim_selection = val
-- Используется в: _get_aim_node()
local _get_aim_node = function()
    return _idx_to_viewpoint(cached_settings.aim_selection) .. ZOOM_SUFFIX
end

-- При прицеливании:
if alternate_fire_is_active then
    node = aim_node  -- "pspv_center_zoom", "pspv_right_zoom", etc.
end

-- Проверка перехода в 1P:
local _should_aim_to_1p = function(is_aiming, is_ogryn)
    if cached_settings.aim_selection == -1 then
        return true  -- принудительно 1P
    end
    -- ... дополнительные проверки
end

mod.disable_3p_due_to("aim", _should_aim_to_1p(alternate_fire_is_active, is_ogryn))
```
- `-1`: Добавляет `"aim"` reason для отключения 3P
- `0`: Использует `current_viewpoint` (текущее плечо из цикла)
- `1-3`: Фиксированная позиция независимо от цикла
- Добавляет суффикс `_zoom` к ноде

### `nonaim_mode` (dropdown)
**По умолчанию:** `0` (Cycle)

**Опции:**
- `0` - **Cycle**: Использовать текущее плечо (из цикла)
- `1` - **Center**: Центральная позиция
- `2` - **Right**: Правое плечо
- `3` - **Left**: Левое плечо

**Как работает в коде:**
```lua
-- Кэшируется в: cached_settings.nonaim_selection = val
-- Используется в: _get_nonaim_node()
local _get_nonaim_node = function()
    return _idx_to_viewpoint(cached_settings.nonaim_selection)
end

-- В обычном режиме (не прицеливание):
if mod.is_requesting_third_person() then
    if use_3p_freelook_node then
        node = "pspv_lookaround"
    elseif alternate_fire_is_active then
        node = aim_node
    else
        node = nonaim_node  -- "pspv_center", "pspv_right", "pspv_left"
    end
    
    if is_ogryn then
        node = node .. "_ogryn"  -- добавляет суффикс для огрина
    end
end
```
- `0`: Динамическая позиция, изменяется через `cycle_shoulder`
- `1-3`: Фиксированная позиция камеры
- Для огринов добавляется суффикс `_ogryn`

### `cycle_includes_center` (checkbox)
**По умолчанию:** `false`

**Описание:** Включать ли центральную позицию в цикл переключения плеча.

**Как работает в коде:**
```lua
-- Кэшируется в: cached_settings.cycle_includes_center = val
-- Используется в: _get_next_viewpoint()
if previous == "pspv_left" and cached_settings.cycle_includes_center then
    return "pspv_center"
end
```
- `false`: Цикл `right → left → right`
- `true`: Цикл `right → left → center → right`
- Влияет на клавишу `cycle_shoulder` и режим `Cycle`

### `center_to_1p_human` (checkbox)
**По умолчанию:** `false`

**Описание:** Переходить в первое лицо для людей при центральной камере во время прицеливания.

**Как работает в коде:**
```lua
-- Кэшируется в: cached_settings.center_to_1p_human = val
-- Используется в: _should_aim_to_1p()
if cached_settings.aim_selection == 0 and current_viewpoint == "pspv_center" then
    if is_ogryn then
        return cached_settings.center_to_1p_ogryn
    end
    return cached_settings.center_to_1p_human
end
```
- Применяется только когда `aim_mode = Cycle` и текущая позиция `center`
- Если `true` - переходит в 1P при прицеливании
- Работает только для человеческих персонажей (не огрин)

### `center_to_1p_ogryn` (checkbox)
**По умолчанию:** `true`

**Описание:** Переходить в первое лицо для огринов при центральной камере во время прицеливания.

**Как работает в коде:**
```lua
-- Аналогично center_to_1p_human, но для огринов
if is_ogryn then
    return cached_settings.center_to_1p_ogryn
end
```
- Применяется только к огринам
- По умолчанию `true` из-за большого размера огринов

### `xhair_fallback` (dropdown)
**По умолчанию:** `assault`

**Опции:** (зависит от `mod._xhair_types`)
- `assault`, `bfg`, `charge_up`, `dot`, `ironsight`, `none`, `spray_n_pray` и др.

**Описание:** Резервный прицел для оружия, которое не имеет прицела в третьем лице.

**Как работает в коде:**
```lua
-- Кэшируется в: cached_settings.xhair_fallback = val
-- Хук: HudElementCrosshair._get_current_crosshair_type
if cached_settings.xhair_fallback ~= "none" and 
   (type == "none" or type == "ironsight") and 
   not is_in_hub and 
   mod.is_requesting_third_person() then
    return cached_settings.xhair_fallback
end
```
- Заменяет `none` или `ironsight` прицелы в 3P режиме
- Не применяется в хабе
- `none` = не использовать fallback

### `use_lookaround_node` (checkbox)
**По умолчанию:** `true`

**Описание:** Использовать специальную ноду камеры при активации мода LookAround.

**Как работает в коде:**
```lua
-- Кэшируется в: cached_settings.use_lookaround_node = val
-- Интеграция с модом LookAround:
local lookaround_mod = get_mod("LookAround")
if lookaround_mod then
    mod:hook_safe(lookaround_mod, "on_freelook_changed", function(value)
        use_3p_freelook_node = value and cached_settings.use_lookaround_node
    end)
end

-- В evaluate_camera_tree:
if use_3p_freelook_node then
    node = "pspv_lookaround"
else
    node = nonaim_node
end
```
- Переключает на ноду `pspv_lookaround` при свободном обзоре
- Требует установленный мод **LookAround**
- `false` = использовать обычную ноду даже при свободном обзоре

---

## Группа: Кастомные настройки камеры

Эти настройки позволяют точно настроить позицию камеры. Используется множитель `CUSTOM_MULT = 0.75`.

### `custom_distance` (numeric)
**По умолчанию:** `0.0`  
**Диапазон:** `-1.0 - 1.0`

**Описание:** Дополнительное расстояние камеры от персонажа (вперёд/назад) для людей.

**Как работает в коде:**
```lua
-- Применяется через: mod.apply_custom_viewpoint()
-- Координаты: +y = вперед, -y = назад
local distance = mod:get("custom_distance") * CUSTOM_MULT
-- Добавляется к базовой позиции камеры
```
- Положительное значение = камера ближе к персонажу
- Отрицательное значение = камера дальше от персонажа
- Множитель `0.75` смягчает изменения

### `custom_offset` (numeric)
**По умолчанию:** `0.0`  
**Диапазон:** `-1.0 - 1.0`

**Описание:** Боковое смещение камеры (влево/вправо) для людей.

**Как работает в коде:**
```lua
// Координаты: +x = вправо, -x = влево
local offset = mod:get("custom_offset") * CUSTOM_MULT
```
- Положительное значение = сдвиг вправо
- Отрицательное значение = сдвиг влево

### `custom_distance_zoom` (numeric)
**По умолчанию:** `0.0`  
**Диапазон:** `-1.0 - 1.0`

**Описание:** Дополнительное расстояние камеры при прицеливании для людей.

**Как работает в коде:**
```lua
-- Применяется к нодам с суффиксом "_zoom"
// Позволяет иметь разные настройки для прицеливания
```
- Работает независимо от `custom_distance`
- Применяется только при `alternate_fire_is_active = true`

### `custom_offset_zoom` (numeric)
**По умолчанию:** `0.0`  
**Диапазон:** `-1.0 - 1.0`

**Описание:** Боковое смещение камеры при прицеливании для людей.

**Как работает в коде:**
```lua
-- Аналогично custom_offset, но для режима прицеливания
```

### `custom_distance_ogryn` (numeric)
**По умолчанию:** `0.0`  
**Диапазон:** `-1.0 - 1.0`

**Описание:** Дополнительное расстояние камеры для огринов.

**Как работает в коде:**
```lua
// Отдельные настройки для огринов из-за их большого размера
if is_ogryn then
    node = node .. "_ogryn"
    // применяются _ogryn настройки
end
```
- Работает только для архетипа Огрин
- Независимо от настроек людей

### `custom_offset_ogryn` (numeric)
**По умолчанию:** `0.0`  
**Диапазон:** `-1.0 - 1.0`

**Описание:** Боковое смещение камеры для огринов.

---

## Группа: Автопереключение (Autoswitch)

Автоматически переключает вид при определённых событиях. Все настройки имеют 3 опции:

**Опции:**
- `0` - **None**: Не переключать
- `1` - **To First Person**: Переключить в первое лицо
- `2` - **To Third Person**: Переключить в третье лицо

**Как работает система autoswitch:**
```lua
// При инициализации создаётся lookup-таблица:
autoswitch_events = {
    ["spectate"] = 2,
    ["slot_device"] = 1,
    ["slot_primary"] = 0,
    // ... и т.д.
}

// При событии:
local _autoswitch_from_event = function(reason, event, condition)
    local autoswitch_mode = autoswitch_events[event]
    return mod.mux_3p_due_to(reason, autoswitch_mode == 2, autoswitch_mode == 1)
end
```
- `0`: Удаляет reason (нейтрально)
- `1`: Добавляет disable reason (принудительно 1P)
- `2`: Добавляет enable reason (принудительно 3P)

### События слотов оружия/предметов

#### `autoswitch_slot_device` (dropdown)
**По умолчанию:** `1` (To First Person)

**Описание:** Переключение при использовании устройств (сканеры, взрывчатка, etc).

**Как работает:**
```lua
// Хук: PlayerUnitWeaponExtension.on_slot_wielded
_autoswitch_from_event("slot", "slot_device")
```
- Срабатывает при `slot_name == "slot_device"`

#### `autoswitch_slot_primary` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при достании основного оружия.

**Как работает:**
```lua
_autoswitch_from_event("slot", "slot_primary")
holding_primary = true
```

#### `autoswitch_slot_secondary` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при достании вторичного оружия.

**Как работает:**
```lua
_autoswitch_from_event("slot", "slot_secondary")
holding_secondary = true
```

#### `autoswitch_slot_grenade_ability` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при использовании гранат или способностей.

**Как работает:**
```lua
_autoswitch_from_event("slot", "slot_grenade_ability")
```

#### `autoswitch_slot_pocketable` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при взятии карманных предметов (медпак, большие предметы).

**Как работает:**
```lua
_autoswitch_from_event("slot", "slot_pocketable")
```

#### `autoswitch_slot_pocketable_small` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при взятии малых карманных предметов (гримуар, скриптура).

#### `autoswitch_slot_luggable` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при ношении больших объектов (батарея, бочка).

#### `autoswitch_slot_unarmed` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение когда персонаж безоружен.

### События движения

#### `autoswitch_sprint` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при спринте.

**Как работает:**
```lua
// Хук в: PlayerUnitCameraExtension._evaluate_camera_tree
if wants_sprint_camera then
    _autoswitch_from_event("movt", "sprint")
end
```
- Проверяет `sprint_character_state_component.wants_sprint_camera`
- Reason: `"movt"` (movement)

#### `autoswitch_lunge_ogryn` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при рывке огрина (бык-огрин).

**Как работает:**
```lua
if is_lunging and is_ogryn then
    _autoswitch_from_event("movt", "lunge_ogryn")
end
```
- Проверяет `lunge_character_state_component.is_lunging`
- Только для огринов

#### `autoswitch_lunge_human` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при рывке человека.

**Как работает:**
```lua
if is_lunging and not is_ogryn then
    _autoswitch_from_event("movt", "lunge_human")
end
```

### События особых действий

#### `autoswitch_act2_primary` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при зажатии особого действия основного оружия (например, раскрутка пулемёта).

**Как работает:**
```lua
// Хук: InputService._get и _get_simulate
if action_name == "action_two_hold" and holding_primary then
    _autoswitch_from_event("act2", "act2_primary", val)
end
```
- Отслеживает `action_two_hold` (обычно ПКМ или спец. кнопка)
- Reason: `"act2"` (action two)
- `val` = текущее состояние удержания

#### `autoswitch_act2_secondary` (dropdown)
**По умолчанию:** `0` (None)

**Описание:** Переключение при зажатии особого действия вторичного оружия.

**Как работает:**
```lua
if action_name == "action_two_hold" and holding_secondary then
    _autoswitch_from_event("act2", "act2_secondary", val)
end
```

### Режим наблюдения

#### `autoswitch_spectate` (dropdown)
**По умолчанию:** `2` (To Third Person)

**Описание:** Переключение при входе в режим наблюдения за другим игроком.

**Как работает:**
```lua
// Хук: CameraHandler._switch_follow_target
is_spectating = new_unit ~= self._player.player_unit
_autoswitch_from_event("spectate", "spectate", is_spectating)

// В is_requesting_third_person():
if is_spectating then
    enable = not not (enable_reasons["_base"] or enable_reasons["spectate"])
    disable = disable_reasons["_base"] or disable_reasons["spectate"]
end
```
- Reason: `"spectate"`
- Имеет приоритет при наблюдении (проверяется отдельно)

---

## Система Reasons (Причин)

Мод использует систему "reasons" для управления состоянием 3P режима:

### Enable Reasons (Причины включения 3P)
```lua
enable_reasons = {
    ["_base"] = true,      // базовое состояние (toggle/default_mode)
    ["spectate"] = true,   // режим наблюдения
    ["slot"] = true,       // autoswitch от слота
    ["movt"] = true,       // autoswitch от движения
    ["act2"] = true,       // autoswitch от особого действия
}
```

### Disable Reasons (Причины отключения 3P)
```lua
disable_reasons = {
    ["_mod"] = true,       // allow_switching = false
    ["aim"] = true,        // aim_mode = 1P или center_to_1p_*
    ["slot"] = true,       // autoswitch = 1 (to 1P)
    ["movt"] = true,
    ["act2"] = true,
    ["_unload"] = true,    // при выгрузке мода
}
```

### Приоритет
```lua
mod.is_requesting_third_person = function()
    local enable = _has_enable_reason()
    local disable = _has_disable_reason()
    return enable and not disable  // disable имеет приоритет
end
```

**Disable всегда имеет приоритет над Enable!**

---

## Производительность

### Оптимизации в Redux версии

1. **Счётчики reasons** (O(1) вместо O(n)):
```lua
enable_reasons_count = 0
disable_reasons_count = 0

local _has_enable_reason = function()
    return enable_reasons_count > 0  // мгновенная проверка
end
```

2. **Кэширование настроек**:
```lua
cached_settings = {
    aim_selection = 0,
    nonaim_selection = 0,
    // ... и т.д.
}
// Обновляется только при изменении через on_setting_changed
```

3. **Предварительный парсинг autoswitch**:
```lua
// При инициализации:
autoswitch_events = {
    ["spectate"] = 2,
    ["slot_device"] = 1,
    // ... все события
}
// В горячем пути: O(1) доступ без string операций
```

4. **Отложенное обновление**:
```lua
is_initialized = false
// Настройки применяются только после полной загрузки
```

---

## Интеграция с другими модами

### LookAround
```lua
use_3p_freelook_node = value and cached_settings.use_lookaround_node
// Использует специальную ноду "pspv_lookaround"
```

### camera_freeflight
```lua
mod:hook(freeflight_mod, "set_3p", function(func, self, enabled)
    func(self, enabled or mod.is_requesting_third_person())
end)
// Синхронизирует состояние 3P
```

### crosshair_remap
- Совместим через систему `xhair_fallback`

---

## Координатная система камеры

```
+x = право
-x = лево
+y = вперёд (к персонажу)
-y = назад (от персонажа)
+z = вверх
-z = вниз
```

**Примеры:**
- `custom_distance = 0.5` → камера ближе на 0.375 единиц (0.5 * 0.75)
- `custom_offset = -0.5` → камера сдвинута влево на 0.375 единиц

---

## Ноды камеры

### Основные ноды:
- `pspv_right` - правое плечо
- `pspv_left` - левое плечо
- `pspv_center` - центр

### С прицеливанием (zoom):
- `pspv_right_zoom`
- `pspv_left_zoom`
- `pspv_center_zoom`

### Для огринов:
- `pspv_right_ogryn`
- `pspv_left_ogryn`
- `pspv_center_ogryn`
- `pspv_right_zoom_ogryn` (и т.д.)

### Специальные:
- `pspv_lookaround` - свободный обзор (LookAround мод)
- `first_person` - первое лицо
- `third_person` - дефолтное третье лицо игры

---

## Безопасность и восстановление

### При загрузке:
```lua
// Сохранение оригинальных значений
original_transition_duration.to_third_person = CameraTransitionTemplates...
original_transition_duration.to_first_person = CameraTransitionTemplates...
```

### При выгрузке:
```lua
mod.on_unload = function(quitting)
    mod.disable_3p_due_to("_unload", true)  // отключаем 3P
    // Восстановление оригинальных значений камеры
    // Очистка кэша и таблиц reasons
    // Сброс счётчиков
end
```

### Защита от краш:
```lua
local success, error_msg = pcall(function()
    if ScriptUnit.has_extension(unit, "first_person_system") then
        local ext = ScriptUnit.extension(unit, "first_person_system")
        if ext and type(ext._force_third_person_mode) ~= "nil" then
            ext._force_third_person_mode = mod.is_requesting_third_person()
        end
    end
end)

if not success then
    mod:error("Failed to apply perspective: %s", error_msg)
end
```

---

## Примеры конфигураций

### Классическая 3P за правым плечом:
- `default_perspective_mode` = Always Third Person
- `aim_mode` = Right
- `nonaim_mode` = Right

### Динамическое переключение плеча:
- `default_perspective_mode` = Always Third Person
- `aim_mode` = Cycle
- `nonaim_mode` = Cycle
- `cycle_includes_center` = true
- Назначить `cycle_shoulder` на удобную клавишу

### Только для наблюдения:
- `default_perspective_mode` = Normal
- `autoswitch_spectate` = To Third Person
- Все остальные autoswitch = None

### Третье лицо для движения, первое для боя:
- `default_perspective_mode` = Normal
- `autoswitch_sprint` = To Third Person
- `aim_mode` = 1st Person
- `autoswitch_slot_primary` = To First Person
- `autoswitch_slot_secondary` = To First Person

