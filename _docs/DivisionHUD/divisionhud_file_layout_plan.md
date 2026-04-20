# DivisionHUD — план раскладки и нейминга файлов

Цель этого плана: привести `DivisionHUD` к более аккуратной и предсказуемой структуре по тому же принципу, который видно в `mods/crosshair_hud`:

- короткий и понятный entrypoint;
- явное разделение `bootstrap / settings / hud / runtime / compat`;
- рядом лежат файлы одной зоны ответственности;
- имена файлов описывают роль файла, а не только историческое происхождение кода.

Этот документ описывает только план реорганизации. Логику мода он не меняет.

---

## 1. Что в `crosshair_hud` сделано удачно

По текущей структуре `crosshair_hud` видно несколько полезных правил:

1. Корневые entry-файлы сразу понятны:
   - `crosshair_hud.lua`
   - `crosshair_hud_data.lua`
   - `crosshair_hud_localization.lua`

2. Весь HUD собран в одном отдельном узле:
   - `hud_element_crosshair_hud/`
   - внутри него отдельно `features/`
   - внутри feature при необходимости есть свои `templates/`

3. Настройки отделены от runtime-кода:
   - корневой `*_data.lua` отвечает за меню настроек;
   - `settings/migrations.lua` отвечает только за миграции.

4. Имена файлов плоские и предсказуемые:
   - `ammo.lua`, `reload.lua`, `coherency.lua`, `ally.lua`
   - по имени файла сразу видно, за что он отвечает.

---

## 2. Что сейчас в `DivisionHUD` разложено неудачно

По текущей структуре `DivisionHUD` видны следующие смешения ответственности:

1. `DivisionHUD.lua` слишком перегружен:
   - регистрация HUD-элемента;
   - hook'и загрузки HUD;
   - tracking deployable-объектов;
   - загрузка runtime-модулей;
   - apply-функции настроек.

2. `data.lua` уже очень большой и содержит несколько независимых секций:
   - layout;
   - bars;
   - dynamic hud;
   - hide vanilla hud;
   - alerts;
   - proximity;
   - integrations;
   - system.

3. Папка `core/` сейчас смешивает разные типы сущностей:
   - общую layout-геометрию (`definitions.lua`);
   - slot data (`slot_data.lua`);
   - определения для частных виджетов (`alerts_definitions.lua`, `buff_rows_definitions.lua`, `stamina_dodge_definitions.lua`, `toughness_health_definitions.lua`);
   - runtime-сканирование (`proximity_scan.lua`).

4. Папка `widgets/` содержит и чистые UI-модули, и модули с системной логикой:
   - `alerts.lua` фактически не только рисует, но и хранит runtime state и правила агрегации.

5. Нейминг непоследовательный:
   - `HudElementDivisionHUD.lua` в PascalCase;
   - рядом остальные файлы в snake_case;
   - `data.lua` и `localization.lua` названы слишком общо;
   - `systems/hud_utils.lua` по сути не system, а shared utility/runtime helper.

---

## 3. Что не нужно переименовывать в первую очередь

Так как `DivisionHUD.mod` сейчас явно ссылается на:

- `DivisionHUD/scripts/mods/DivisionHUD/DivisionHUD`
- `DivisionHUD/scripts/mods/DivisionHUD/data`
- `DivisionHUD/scripts/mods/DivisionHUD/localization`

на первом этапе лучше **не ломать entrypoint-цепочку**.

То есть в первой реорганизации:

- оставить `DivisionHUD.lua`;
- оставить `data.lua`;
- оставить `localization.lua`.

И уже после стабилизации можно делать второй этап со стандартизацией корневых имён.

---

## 4. Целевые правила раскладки для `DivisionHUD`

### 4.1. Корень мода

В корне должны остаться только entry и действительно глобальные файлы:

```text
scripts/mods/DivisionHUD/
  DivisionHUD.lua
  data.lua
  localization.lua
  bootstrap/
  settings/
  hud/
  runtime/
  context/
  compat/
  util/
```

### 4.2. Правила нейминга

Для новых и переносимых файлов использовать только `snake_case`.

Правило по именам:

- файл описывает **одну роль**;
- имя должно отвечать на вопрос "что это за модуль";
- в имени не держать технический мусор типа `new`, `old`, `temp`, `final`.

Нормальные примеры:

- `hud_registration.lua`
- `deployable_tracker.lua`
- `settings_cache.lua`
- `alerts_runtime.lua`
- `proximity_runtime.lua`
- `main_hud_definitions.lua`
- `weapon_slots.lua`

Нежелательные примеры:

- `definitions.lua` без уточнения;
- `utils.lua` без области;
- `helpers.lua` без области;
- `misc.lua`.

---

## 5. Целевая структура папок

Ниже структура, которая лучше соответствует текущему коду `DivisionHUD` и при этом ближе к аккуратной раскладке `crosshair_hud`.

```text
scripts/mods/DivisionHUD/
  DivisionHUD.lua
  data.lua
  localization.lua

  bootstrap/
    hud_registration.lua
    hud_hooks.lua
    deployable_tracker.lua
    module_loader.lua

  settings/
    defaults.lua
    menu/
      layout.lua
      bars.lua
      dynamic.lua
      vanilla_hud.lua
      alerts.lua
      proximity.lua
      integrations.lua
      system.lua
    runtime/
      settings_cache.lua
      settings_reset.lua
      settings_apply.lua
    migrations/
      migrations.lua

  hud/
    hud_element_division_hud.lua
    definitions/
      main_hud_definitions.lua
      alerts_definitions.lua
      buff_rows_definitions.lua
      stamina_dodge_definitions.lua
      toughness_health_definitions.lua
    widgets/
      stamina_dodge.lua
      toughness_health.lua
      combat_ability_bar.lua
      division_buffs.lua
      alerts_panel.lua
    data/
      slot_data.lua

  runtime/
    alerts_runtime.lua
    proximity_runtime.lua
    mission_objective_runtime.lua
    team_alerts_runtime.lua
    vanilla_hud_suppression.lua
    wielded_weapon_icon_tint.lua
    debug_runtime.lua

  context/
    auto_switch_hud.lua
    dynamic_hud.lua
    game_flow.lua

  compat/
    recolor_stimms_bridge.lua

  util/
    hud_utils.lua
```

---

## 6. Карта переносов `текущий файл -> целевой файл`

Ниже конкретная карта без выдуманных сущностей. Все целевые файлы основаны только на том, что уже есть в моде.

### 6.1. Entry и bootstrap

- `DivisionHUD.lua`
  - оставить как entrypoint;
  - сократить до загрузки bootstrap/runtime модулей;
  - вынести код из него в:
    - `bootstrap/hud_registration.lua`
    - `bootstrap/hud_hooks.lua`
    - `bootstrap/deployable_tracker.lua`
    - `bootstrap/module_loader.lua`

### 6.2. Настройки

- `config/settings_defaults.lua` -> `settings/defaults.lua`
- `systems/settings.lua` -> `settings/runtime/settings_cache.lua`
- `data.lua`
  - оставить как агрегатор меню;
  - разнести внутренние секции по:
    - `settings/menu/layout.lua`
    - `settings/menu/bars.lua`
    - `settings/menu/dynamic.lua`
    - `settings/menu/vanilla_hud.lua`
    - `settings/menu/alerts.lua`
    - `settings/menu/proximity.lua`
    - `settings/menu/integrations.lua`
    - `settings/menu/system.lua`

Если нужен минимальный шаг без риска, можно сначала сделать эти файлы как возвращающие `sub_widgets`, а `data.lua` оставить сборщиком итоговой таблицы.

### 6.3. HUD-элемент и layout

- `hud/HudElementDivisionHUD.lua` -> `hud/hud_element_division_hud.lua`
- `core/definitions.lua` -> `hud/definitions/main_hud_definitions.lua`
- `core/slot_data.lua` -> `hud/data/slot_data.lua`

### 6.4. Определения частных частей HUD

- `core/alerts_definitions.lua` -> `hud/definitions/alerts_definitions.lua`
- `core/buff_rows_definitions.lua` -> `hud/definitions/buff_rows_definitions.lua`
- `core/stamina_dodge_definitions.lua` -> `hud/definitions/stamina_dodge_definitions.lua`
- `core/toughness_health_definitions.lua` -> `hud/definitions/toughness_health_definitions.lua`

### 6.5. UI-виджеты

- `widgets/stamina_dodge.lua` -> `hud/widgets/stamina_dodge.lua`
- `widgets/toughness_health.lua` -> `hud/widgets/toughness_health.lua`
- `widgets/combat_ability_bar.lua` -> `hud/widgets/combat_ability_bar.lua`
- `widgets/division_buffs.lua` -> `hud/widgets/division_buffs.lua`
- `widgets/alerts.lua` -> `hud/widgets/alerts_panel.lua`

Причина переименования `alerts.lua` -> `alerts_panel.lua`: файл относится к конкретной HUD-панели, а не к alert-системе в целом.

### 6.6. Runtime / systems

- `core/proximity_scan.lua` -> `runtime/proximity_runtime.lua`
- `systems/mission_objective_hud.lua` -> `runtime/mission_objective_runtime.lua`
- `systems/team_alerts.lua` -> `runtime/team_alerts_runtime.lua`
- `systems/vanilla_hud_suppression.lua` -> `runtime/vanilla_hud_suppression.lua`
- `systems/wielded_weapon_icon_tint.lua` -> `runtime/wielded_weapon_icon_tint.lua`
- `systems/debug.lua` -> `runtime/debug_runtime.lua`
- `systems/hud_utils.lua` -> `util/hud_utils.lua`

Для `alerts.lua` после выноса UI-части в `hud/widgets/alerts_panel.lua` нужно отдельно выделить runtime-логику:

- часть state / event logic из `widgets/alerts.lua` -> `runtime/alerts_runtime.lua`

Это самый важный структурный долг в текущем моде.

### 6.7. Context и compat

Эти папки уже названы удачно, здесь достаточно сохранить текущую раскладку:

- `context/auto_switch_hud.lua`
- `context/dynamic_hud.lua`
- `context/game_flow.lua`
- `compat/recolor_stimms_bridge.lua`

---

## 7. Что именно должно стать тоньше после реорганизации

### 7.1. `DivisionHUD.lua`

После реорганизации в этом файле должно остаться только:

1. создание `mod`;
2. подключение bootstrap-модулей;
3. подключение runtime-модулей;
4. экспорт нескольких публичных точек входа мода, если они реально нужны.

В нём не должно жить:

- длинное описание hook-логики;
- большие обработчики deployable;
- логика перезагрузки apply settings;
- служебные локальные структуры большого объёма.

### 7.2. `data.lua`

После реорганизации этот файл должен быть только сборщиком меню:

1. подключить `settings/defaults.lua`;
2. подключить секции из `settings/menu/*`;
3. вернуть итоговую таблицу `options.widgets`.

В нём не должны жить длинные локальные helper-функции, не относящиеся к сборке меню, если они используются только в одной секции.

### 7.3. `hud/hud_element_division_hud.lua`

Этот файл должен быть только оркестратором HUD-элемента:

1. init;
2. update;
3. draw;
4. вызовы дочерних widget/runtime-модулей;
5. чтение настроек и context.

Крупные статические данные layout должны лежать в `hud/definitions/*`, как сейчас это частично уже сделано.

---

## 8. Рекомендуемый порядок рефакторинга

Чтобы не сломать мод, переносить не всё сразу, а по этапам.

### Этап 1. Безопасная раскладка без изменения поведения

1. Оставить `DivisionHUD.lua`, `data.lua`, `localization.lua` как есть по именам.
2. Перенести `systems/hud_utils.lua` в `util/hud_utils.lua`.
3. Перенести `core/slot_data.lua` в `hud/data/slot_data.lua`.
4. Перенести `core/definitions.lua` и частные `*_definitions.lua` в `hud/definitions/`.
5. Перенести UI-виджеты в `hud/widgets/`.
6. Обновить все `mod:io_dofile` и `mod:add_require_path`.

Это самый безопасный этап, потому что логика почти не меняется.

### Этап 2. Разгрузка `DivisionHUD.lua`

1. Вынести регистрацию HUD-элемента в `bootstrap/hud_registration.lua`.
2. Вынести hook'и `UIHud` и `hook_require` в `bootstrap/hud_hooks.lua`.
3. Вынести tracking deployable-объектов в `bootstrap/deployable_tracker.lua`.
4. Оставить в `DivisionHUD.lua` только загрузку этих модулей.

### Этап 3. Разгрузка `data.lua`

1. Создать `settings/menu/` секции.
2. Вынести группы настроек из `data.lua` по функциональным блокам.
3. Оставить `data.lua` только сборщиком секций.

### Этап 4. Разделение `alerts.lua`

1. Отделить чисто UI-часть alert-панели в `hud/widgets/alerts_panel.lua`.
2. Отделить runtime state, очередь, merge-логику и event-обработку в `runtime/alerts_runtime.lua`.

Именно этот этап даст самый заметный выигрыш по читаемости.

### Этап 5. Финальная стандартизация корня

Только после стабилизации можно решить, стоит ли приводить entry-файлы к единому стилю:

- `DivisionHUD.lua` -> `division_hud.lua`
- `data.lua` -> `division_hud_data.lua`
- `localization.lua` -> `division_hud_localization.lua`

Но это уже отдельный шаг, потому что потребует правки `DivisionHUD.mod` и всех путей.

---

## 9. Правила, которых нужно придерживаться при переносе

1. Не смешивать runtime-логику и определения виджетов в одном файле, если это можно разделить без дублирования.
2. Не использовать абстрактные имена вроде `definitions.lua` без уточнения области.
3. Не плодить папки ради одной маленькой сущности.
4. Не менять публичные ключи настроек во время файлового рефакторинга.
5. Не менять class name HUD-элемента во время первого этапа.
6. Каждый перенос делать с немедленным обновлением всех путей `io_dofile`, `add_require_path`, `hook_require`.

---

## 10. Итоговое решение для `DivisionHUD`

Если делать по минимально рискованной схеме, итог для этого мода такой:

1. Корневые файлы оставить entry-точками.
2. Всё, что относится к раскладке HUD, собрать под `hud/`.
3. Всё, что относится к runtime-логике и hook/state, собрать под `runtime/`.
4. Всё, что относится к настройкам, собрать под `settings/`.
5. `DivisionHUD.lua` и `data.lua` превратить в тонкие агрегаторы.

Это даст ту же читаемость, которая сейчас лучше ощущается в `crosshair_hud`: когда по имени файла и папки сразу понятно, где искать конкретный кусок мода.
