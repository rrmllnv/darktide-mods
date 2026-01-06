# Диагностика проблем с autoswitch

## Проблема: autoswitch не переключает камеру

### Частые причины:

#### 1. **Конфликт с базовым режимом**

Если у вас стоит `default_perspective_mode = Always Third Person`, то autoswitch в **1P не сработает**.

**Почему?**
```lua
-- Логика мода:
return enable and not disable

-- Пример:
enable_reasons["_base"] = true  -- от default_perspective_mode
disable_reasons["slot"] = true  -- от autoswitch_slot_device = 1P

return true and not true = false  -- ДОЛЖНО ПЕРЕКЛЮЧИТЬ В 1P!
```

**НО!** Проблема может быть в том, что игра **принудительно** запрашивает 3P для некоторых ситуаций.

---

#### 2. **Конфликт с другими autoswitch**

Если у вас несколько autoswitch настроек активны одновременно:

```
autoswitch_slot_device = To First Person (1)
autoswitch_sprint = To Third Person (2)
```

И вы **одновременно** держите device и бежите:
- `enable_reasons["movt"] = true` (от sprint)
- `disable_reasons["slot"] = true` (от device)
- Результат: `return true and not true = false` ✅ Переключит в 1P

**Disable всегда имеет приоритет!**

---

#### 3. **Игра использует другой слот**

Возможно, некоторые "device" используют `slot_pocketable` вместо `slot_device`.

**Примеры слотов:**
- `slot_device` - сканеры, взрывчатка
- `slot_pocketable` - медпаки
- `slot_pocketable_small` - гримуары, скриптуры
- `slot_luggable` - батареи, бочки
- `slot_grenade_ability` - гранаты/блитцы

---

## Как диагностировать проблему

### Способ 1: Добавить отладочный код

Откройте `PerspectivesRedux.lua` и найдите строку 429:

```lua
mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
	_autoswitch_from_event("slot", slot_name)
```

**Замените на:**

```lua
mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
	-- ОТЛАДКА: Показать какой слот был использован
	mod:echo("=== SLOT WIELDED: " .. tostring(slot_name) .. " ===")
	
	-- ОТЛАДКА: Проверить есть ли настройка для этого слота
	local setting_key = "autoswitch_" .. slot_name
	local setting_value = mod:get(setting_key)
	mod:echo("Setting: " .. setting_key .. " = " .. tostring(setting_value))
	
	-- ОТЛАДКА: Проверить autoswitch_events
	if autoswitch_events[slot_name] then
		mod:echo("autoswitch_events[" .. slot_name .. "] = " .. tostring(autoswitch_events[slot_name]))
	else
		mod:echo("autoswitch_events[" .. slot_name .. "] = NIL (not found!)")
	end
	
	_autoswitch_from_event("slot", slot_name)
```

Теперь в чате будет показываться информация при смене оружия!

---

### Способ 2: Проверить текущее состояние

Добавьте команду для проверки состояния. В конец файла `PerspectivesRedux.lua`:

```lua
-- ОТЛАДКА: Команда для проверки состояния
mod.debug_state = function()
	mod:echo("=== DEBUG STATE ===")
	mod:echo("is_requesting_third_person: " .. tostring(mod.is_requesting_third_person()))
	mod:echo("enable_reasons_count: " .. tostring(enable_reasons_count))
	mod:echo("disable_reasons_count: " .. tostring(disable_reasons_count))
	
	mod:echo("Enable reasons:")
	for reason, value in pairs(enable_reasons) do
		mod:echo("  [" .. reason .. "] = " .. tostring(value))
	end
	
	mod:echo("Disable reasons:")
	for reason, value in pairs(disable_reasons) do
		mod:echo("  [" .. reason .. "] = " .. tostring(value))
	end
	
	mod:echo("Autoswitch events:")
	for event, mode in pairs(autoswitch_events) do
		local mode_text = mode == 0 and "None" or (mode == 1 and "To 1P" or "To 3P")
		mod:echo("  [" .. event .. "] = " .. mode_text)
	end
end
```

Вызовите в консоли: `/mod PerspectivesRedux debug_state`

---

## Решения типичных проблем

### Проблема: "Device не переключает в 1P"

**Проверьте:**

1. **Правильно ли установлена настройка?**
   ```
   autoswitch_slot_device = 1 (To First Person)
   ```

2. **Нет ли конфликтующих настроек?**
   - `default_perspective_mode` должен быть `Normal` или `Swapped`, НЕ `Always Third Person`
   - Другие autoswitch должны быть `None` или совместимы

3. **Это действительно slot_device?**
   - Добавьте отладочный код выше
   - Посмотрите какой слот отображается в чате
   - Настройте правильный autoswitch для этого слота

---

### Проблема: "Блитц не переключает в 1P"

**Важно:** `slot_grenade_ability` **НЕ срабатывает при броске**!

Он срабатывает только когда вы **достаете** гранату как оружие (некоторые блитцы).

**Для большинства блитцов** используйте другой autoswitch:
- `autoswitch_sprint` - если блитц используется во время бега
- НЕТ отдельного autoswitch для "момента броска" в оригинальном моде

**Возможное решение:**
Нужно добавить отдельный хук на бросок гранаты. Это требует доработки мода.

---

### Проблема: "Настройка работает, но камера возвращается обратно"

**Причины:**

1. **Временное событие:**
   ```
   Достали device → переключилось в 1P
   Убрали device → вернулось в 3P
   ```
   Это **нормальное поведение**! Autoswitch работает только пока событие активно.

2. **Конфликт с другим autoswitch:**
   ```
   Sprint активен → переключает в 3P
   Device активен → пытается переключить в 1P
   Disable НЕ срабатывает, т.к. enable от sprint перекрывает
   ```
   **НЕТ!** Disable всегда имеет приоритет. Проверьте логику выше.

---

## Таблица приоритетов

| Состояние | enable_reasons | disable_reasons | Результат |
|-----------|---------------|-----------------|-----------|
| Normal | `[]` | `[]` | **1P** (дефолт игры) |
| Always 3P | `[_base]` | `[]` | **3P** |
| Device в руках | `[_base]` | `[slot]` | **1P** (disable приоритет) |
| Sprint | `[movt]` | `[]` | **3P** |
| Sprint + Device | `[movt]` | `[slot]` | **1P** (disable приоритет) |
| Mod выключен | `[любые]` | `[_mod]` | **1P** (disable приоритет) |

---

## Код логики (для понимания)

```lua
-- 1. Собрать все причины
enable = _has_enable_reason()   -- есть ли хоть одна причина для 3P?
disable = _has_disable_reason() -- есть ли хоть одна причина против 3P?

-- 2. Принять решение
return enable and not disable

-- Примеры:
-- enable=false, disable=false → false and true → false (1P)
-- enable=true,  disable=false → true and true → true (3P)
-- enable=true,  disable=true  → true and false → false (1P)
-- enable=false, disable=true  → false and false → false (1P)
```

**Вывод:** Disable ВСЕГДА выигрывает, если присутствует!

---

## Чеклист диагностики

- [ ] Добавил отладочный код
- [ ] Проверил какой слот используется в чате
- [ ] Убедился что настройка autoswitch для этого слота установлена правильно
- [ ] Проверил `default_perspective_mode` (не должен быть Always 3P)
- [ ] Проверил другие autoswitch на конфликты
- [ ] Проверил текущее состояние через `debug_state`
- [ ] Проверил список enable_reasons и disable_reasons
- [ ] Убедился что `allow_switching = true`

---

## Известные ограничения

1. **Бросок гранаты** не имеет autoswitch (только если достаешь как оружие)
2. **Особые действия** (action_two_hold) имеют отдельные настройки `autoswitch_act2_*`
3. **Прицеливание** управляется через `aim_mode`, НЕ через autoswitch
4. **Наблюдение** имеет отдельную логику и приоритет

---

## Если ничего не помогло

Создайте issue с:
1. Скриншот настроек PerspectivesRedux
2. Вывод отладочного кода из чата
3. Вывод `debug_state`
4. Описание: какой предмет используете, что ожидаете, что происходит

---

**Совет:** Начните с простой конфигурации:
- `default_perspective_mode = Normal`
- Все autoswitch = None
- Включайте по одному и тестируйте

