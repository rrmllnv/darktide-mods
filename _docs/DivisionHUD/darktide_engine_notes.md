# DivisionHUD — заметки по движку Darktide и инструментам

Сводка по исходникам из репозитория (`Darktide-Source-Code`, `mods/dmf`, `limn`). Пути указаны относительно корня проекта `warhammer`, если не сказано иное.

---

## 1. Цели миссии: таймеры, «держимся», что считает «достаточно»

### Центральная логика

За цели отвечает **`MissionObjectiveSystem`**:  
`Darktide-Source-Code/scripts/extension_systems/mission_objective/mission_objective_system.lua`.

На **сервере** каждый кадр для активных целей (если цель **не** помечена как обновляемая только снаружи) вызываются `update` → `update_progression` → синхронизация; если **`progression == 1`** (цель «заполнена») и нет флага **`evaluate_at_level_end`**, цель **автоматически завершается** (`end_mission_objective`).

Условие «достаточно» в коде — **`max_progression_achieved`**, т.е. **`_progression == 1`**:

- `Darktide-Source-Code/scripts/extension_systems/mission_objective/utilities/mission_objective_base.lua`

Типы целей задаются таблицей в начале `mission_objective_system.lua`:  
`collect`, `goal`, `decode`, `kill`, `timed`, `demolition`, `luggable`, `zone`, `side`.

### Есть ли «таймер события»

**Да, но только для типа `timed`.**  
Файл: `Darktide-Source-Code/scripts/extension_systems/mission_objective/utilities/mission_objective_timed.lua`.

Длительность из шаблона: `duration` или `duration_by_difficulty`. В `update` крутится `_time_elapsed`, прогресс — доля времени; при достижении конца — `stage_done()`.  
Показ таймера/полосы в UI завязан на поля шаблона (`progress_timer`, `progress_bar` и т.д. в `mission_objective_base.lua`).

### «Стоим, убиваем — когда хватит»

Один универсальный «таймер удержания» в движке не описан; сценарий собирается из **типа цели** и **данных миссии/уровня**:

1. **`kill`** — прогресс с синхронизатора убийств:  
   `Darktide-Source-Code/scripts/extension_systems/mission_objective/utilities/mission_objective_kill.lua`  
   (`kill_synchronizer_extension:progression()`).

2. **`zone`** — прогресс из активной зоны и `mission_objective_zone_system`  
   (`zone_progression`, `max_progression`, расширения зоны). Часто волны / удержание зоны до выполнения условий зоны.

3. **`goal`** — `set_updated_externally(true)` в `mission_objective_goal.lua`: автоматический кадровый цикл **не** двигает прогресс; завершение дают **flow-колбэки** и явные обновления.

4. **Flow уровня** — старт/обновление/конец цели с сервера:  
   `Darktide-Source-Code/scripts/script_flow_nodes/flow_callbacks.lua`  
   (`start_mission_objective`, `update_mission_objective`, `end_mission_objective`).  
   При старте цели может быть колбэк на **`objective_ended`** в скрипте уровня — дальше цепочка (босс, двери) обычно идёт через **события уровня / flow**, а не через HUD.

5. **`evaluate_at_level_end`** — цели из списка `level_end_objectives` завершаются через **`evaluate_level_end_objectives`**, а не в обычном `update`.

6. **`external_update_mission_objective`** — для части режимов/объективов (см. вызовы в коде экспедиций и др.).

### Итог

- **Таймер «сколько секунд держаться»** — там, где тип **`timed`** и в шаблоне задана длительность.
- **«Убили достаточно / волна закончилась»** — типы **`kill`** / **`zone`** (и логика синхронизаторов/зон в данных уровня), либо **`goal` + flow**, либо **внешнее обновление**.
- Конкретные числа волн и юнитов — в **шаблонах** `scripts/settings/mission_objective/mission_objective_templates.lua` и в **привязке имён целей к юнитам/flow** на уровне.

---

## 2. DivisionHUD + DMF: ошибка локализации при перезагрузке мода

Сообщение: `(localize): localization file was not loaded for this mod`.

### Где в DMF

`mods/dmf/scripts/mods/dmf/modules/core/localization.lua` — если `_localization_database[self:get_name()]` отсутствует, пишется эта ошибка.

Регистрация: **`dmf.initialize_mod_localization`** вызывается из **`load_mod_resource`** внутри **`new_mod`**, порядок: **localization → data → script**  
(`mods/dmf/scripts/mods/dmf/modules/dmf_mod_manager.lua`).

### Почему при перезагрузке

- Таблица `_localization_database` — **локальная** в модуле `localization.lua`; она **нигде явно не очищается**, кроме как при **повторной загрузке** этого файла (новый экземпляр модуля → пустая таблица).
- После **`dmf.all_mods_were_loaded`** повторный **`new_mod`** **запрещён** (`too_late_for_mod_creation` в `dmf_mod_manager.lua`). Если при «перезагрузке» модуль локализации DMF поднялся заново с **пустой** таблицой, а **`new_mod` для DivisionHUD не выполнился снова**, записи для мода в таблице нет — каждый `mod:localize` логирует ошибку.
- Стандартный **`on_reload`** в `mods/dmf/scripts/mods/dmf/dmf_loader.lua` **не** вызывает `init()` и **не** перезагружает `localization.lua` сам по себе; если ошибка всё же есть, возможен **другой** сценарий полной перезагрузки Lua/пакетов.
- Несколько одинаковых строк в логе — несколько вызовов `mod:localize` подряд (например, `data.lua` и инициализация опций).

У DivisionHUD путь к локализации задан в `darktide-mods/DivisionHUD/DivisionHUD.mod` (`mod_localization`).

---

## 3. limn: что это и как собрать в exe

**limn** — утилита на Rust для **распаковки бандлов** Darktide. В репозитории: `limn/`, репозиторий автора в `limn/Cargo.toml`.

### Использование (кратко)

- Рядом с `limn.exe` нужен **`oo2core_9_win64.dll`** из каталога игры.
- Примеры: см. `limn/README.md` (`-i` путь к `bundle`, фильтр `*` или `lua` и т.д.; вывод по умолчанию в `out`).
- Опции: `limn --help` / `print_help` в `limn/src/main.rs` (`--dict`, `--dump-hashes`, `-o`, …).

### Сборка `limn.exe`

В каталоге `limn`:

```powershell
cargo build --release
```

Готовый файл: `limn/target/release/limn.exe`.

Нужны установленный **Rust (rustup)** и на Windows обычно **MSVC Build Tools** (рабочая нагрузка C++). Проект на **edition 2024** — нужен актуальный `rustc`.

### `cargo` не распознаётся в PowerShell

Обычно Rust **не установлен** или **не в PATH**. Проверь наличие `%USERPROFILE%\.cargo\bin\cargo.exe`. Установка: https://rustup.rs/ — после установки **новый** терминал. Альтернатива: готовые бинарники с релизов https://github.com/manshanko/limn/releases (если автор выкладывает).

---

## Связь с DivisionHUD

Мод дублирует/читает события целей миссии в HUD (см. код мода: `mission_objective_hud`, оповещения и т.д.). Поведение **когда** цель начинается/заканчивается в игре определяется **движком и уровнем** (раздел 1), а не модом. Раздел 2 полезен при отладке **перезагрузки** мода в DMF.
