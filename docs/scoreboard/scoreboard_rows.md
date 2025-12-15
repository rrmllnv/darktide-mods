# scoreboard_rows.lua - Определение и регистрация строк статистики

## Назначение

Файл определяет все строки статистики, которые отслеживает мод, и предоставляет функции для их регистрации и управления.

## Структура строки статистики

Каждая строка статистики представляет собой таблицу со следующими полями:

### Обязательные поля

- **`name`** (строка) - Уникальное имя строки. Используется для идентификации и обновления значений.
- **`text`** (строка) - Ключ локализации для отображения названия строки. Должен быть определен в файле локализации.
- **`validation`** (строка) - Тип валидации: `"ASC"` (больше = лучше) или `"DESC"` (меньше = лучше).
- **`iteration`** (строка) - Тип итерации: `"ADD"` (добавление), `"DIFF"` (разница), `"ADD_IF_ZERO"` (добавление только если значение 0).

### Опциональные поля

- **`group`** (строка) - Группа строки: `"offense"`, `"defense"`, `"team"`, `"none"`, `"bottom"`.
- **`setting`** (строка) - Идентификатор настройки, которая контролирует видимость строки. Может быть простым (`"plugin_damage_dealt"`) или с условием (`"plugin_ammo = 1"`).
- **`parent`** (строка) - Имя родительской строки. Дочерние строки отображаются под родительской.
- **`summary`** (таблица) - Массив имен дочерних строк, значения которых суммируются в этой строке.
- **`visible`** (булево) - Видимость строки. Если `false`, строка не отображается, но данные собираются.
- **`is_time`** (булево) - Если `true`, значение форматируется как время (секунды/минуты).
- **`is_text`** (булево) - Если `true`, значение отображается как текст, а не число.
- **`normalize`** (булево) - Если `true`, значения нормализуются к среднему 100.
- **`big`** (булево) - Если `true`, строка отображается с увеличенным шрифтом.
- **`icon`** (строка) - Путь к иконке для отображения перед значением.
- **`icon_package`** (строка) - Имя пакета, содержащего иконку.
- **`icon_width`** (число) - Ширина иконки в пикселях.
- **`update`** (функция) - Функция для периодического обновления значения (например, для когерентности).
- **`data`** (таблица) - Исходные данные строки (опционально).

## Определенные строки статистики

### Группа "team" (Командная статистика)

#### Материалы для кузницы

- **`forge_material`** - Родительская строка для всех материалов кузницы
  - `summary`: `["metal", "platinum"]`
  - `setting`: `"plugin_forge_material"`

- **`metal`** - Металл (пластель)
  - `parent`: `"forge_material"`
  - `summary`: `["small_metal", "large_metal"]`
  - `icon`: Иконка пластеля
  - Дочерние: `small_metal`, `large_metal` (скрытые)

- **`platinum`** - Платина (диамантин)
  - `parent`: `"forge_material"`
  - `summary`: `["small_platinum", "large_platinum"]`
  - `icon`: Иконка диамантина
  - Дочерние: `small_platinum`, `large_platinum` (скрытые)

#### Переноска предметов

- **`carrying`** - Общее время переноски предметов
  - `summary`: `["carrying_tomes", "carrying_grims", "carrying_other"]`
  - `update`: `mod.update_carrying`
  - `setting`: `"plugin_carrying"`

- **`carrying_tomes`** - Время переноски томов
  - `parent`: `"carrying"`
  - `is_time`: `true`

- **`carrying_grims`** - Время переноски гримуаров
  - `parent`: `"carrying"`
  - `is_time`: `true`

- **`carrying_other`** - Время переноски других предметов
  - `parent`: `"carrying"`
  - `is_time`: `true`

#### Операции с механизмами

- **`operated`** - Общее количество операций
  - `summary`: `["machinery_operated", "gadget_operated"]`
  - `setting`: `"plugin_machinery_gadget_operated"`

- **`machinery_operated`** - Операции с механизмами
  - `parent`: `"operated"`

- **`gadget_operated`** - Операции с гаджетами (сервочереп, сканер)
  - `parent`: `"operated"`

#### Боеприпасы

- **`ammo`** - Общая статистика боеприпасов
  - `summary`: `["ammo_picked_up", "ammo_wasted"]`
  - `validation`: `"DESC"` (меньше потрачено = лучше)
  - `setting`: `"plugin_ammo = 1"`

- **`ammo_picked_up`** - Подобрано боеприпасов
  - `parent`: `"ammo"`

- **`ammo_wasted`** - Потрачено впустую боеприпасов
  - `parent`: `"ammo"`
  - `validation`: `"DESC"`

- **`ammo_clip_crate_picked_up`** - Подобрано патронов/ящиков (простой режим)
  - `summary`: `["ammo_small_picked_up", "ammo_large_picked_up", "ammo_crate_picked_up"]`
  - `setting`: `"plugin_ammo = 2"`

#### Размещение предметов

- **`health_ammo_placed`** - Размещено мед. ящиков и боеприпасов
  - `summary`: `["health_placed", "ammo_placed"]`
  - `setting`: `"plugin_health_ammo_placed"`

- **`health_placed`** - Размещено мед. ящиков
  - `parent`: `"health_ammo_placed"`

- **`ammo_placed`** - Размещено ящиков с боеприпасами
  - `parent`: `"health_ammo_placed"`

#### Помощь союзникам

- **`revived_rescued`** - Воскрешения и спасения
  - `summary`: `["revived_operative", "rescued_operative"]`
  - `setting`: `"plugin_revived_rescued"`

- **`revived_operative`** - Воскрешения
  - `parent`: `"revived_rescued"`

- **`rescued_operative`** - Спасения (снятие сетей, поднятие)
  - `parent`: `"revived_rescued"`

### Группа "defense" (Оборонительная статистика)

#### Полученный урон

- **`damage_taken_heal_station_used`** - Полученный урон и использование мед. станций
  - `validation`: `"DESC"` (меньше = лучше)
  - `summary`: `["damage_taken", "heal_station_used"]`
  - `setting`: `"plugin_damage_taken_heal_station_used"`

- **`damage_taken`** - Полученный урон
  - `parent`: `"damage_taken_heal_station_used"`
  - `validation`: `"DESC"`
  - `iteration`: `"DIFF"` (разница между текущим и предыдущим значением здоровья)

- **`heal_station_used`** - Использовано мед. станций
  - `parent`: `"damage_taken_heal_station_used"`
  - `validation`: `"DESC"`

#### Оглушения и блоки

- **`enemies_staggerd`** - Оглушено врагов
  - `validation`: `"ASC"`
  - `setting`: `"plugin_enemies_staggerd"`

- **`attacks_blocked`** - Заблокировано атак
  - `validation`: `"ASC"`
  - `setting`: `"plugin_attacks_blocked"`

#### Когерентность

- **`coherency_efficiency`** - Эффективность когерентности (близость к союзникам)
  - `validation`: `"ASC"`
  - `update`: `mod.update_coherency`
  - `normalize`: `true` (значения нормализуются)
  - `setting`: `"plugin_coherency_efficiency"`

### Группа "offense" (Наступательная статистика)

#### Нанесенный урон

- **`damage_dealt`** - Общий нанесенный урон
  - `summary`: `["actual_damage_dealt", "overkill_damage_dealt"]`
  - `setting`: `"plugin_damage_dealt < 3"`

- **`actual_damage_dealt`** - Реальный урон (без избыточного)
  - `parent`: `"damage_dealt"`

- **`overkill_damage_dealt`** - Избыточный урон (больше здоровья цели)
  - `parent`: `"damage_dealt"`
  - `validation`: `"DESC"` (меньше = лучше)
  - `setting`: `"plugin_damage_dealt < 2"`

#### Урон по боссам

- **`boss_damage_dealt`** - Урон по боссам
  - `validation`: `"ASC"`
  - `setting`: `"plugin_boss_damage_dealt"`

#### Особые попадания

- **`special_hits`** - Особые попадания
  - `summary`: `["weakspot_hits", "critical_hits"]`
  - `setting`: `"plugin_special_hits"`

- **`weakspot_hits`** - Попадания в уязвимые места
  - `parent`: `"special_hits"`

- **`critical_hits`** - Критические попадания
  - `parent`: `"special_hits"`

#### Убийства врагов

Все строки убийств имеют `validation: "ASC"` и `iteration: "ADD"`.

##### Малые враги

- **`lesser_enemies`** - Общее количество малых врагов
  - `summary`: Список всех типов малых врагов
  - `setting`: `"plugin_lesser_enemies"`

Дочерние строки (скрытые):
- `chaos_newly_infected` - Новообращенные
- `chaos_poxwalker` - Чумные ходоки
- `cultist_assault` - Культисты-штурмовики
- `cultist_melee` - Культисты-ближники
- `renegade_assault` - Ренегаты-штурмовики
- `renegade_melee` - Ренегаты-ближники
- `renegade_rifleman` - Ренегаты-стрелки

##### Угрозы ближнего и дальнего боя

- **`melee_ranged_threats`** - Общее количество угроз
  - `summary`: Все типы угроз ближнего и дальнего боя
  - `setting`: `"plugin_melee_ranged_threats"`

- **`melee_threats`** - Угрозы ближнего боя
  - `parent`: `"melee_ranged_threats"`
  - `summary`: Берсерки, маулеры, булварки, крушеры

- **`ranged_threats`** - Угрозы дальнего боя
  - `parent`: `"melee_ranged_threats"`
  - `summary`: Ганнеры, шоктрооперы, рейперы

Дочерние строки (скрытые):
- `cultist_berzerker`, `renegade_berzerker` - Берсерки
- `renegade_executor` - Маулер
- `chaos_ogryn_bulwark` - Булварк
- `chaos_ogryn_executor` - Крушер
- `cultist_gunner`, `renegade_gunner` - Ганнеры
- `cultist_shocktrooper`, `renegade_shocktrooper` - Шоктрооперы
- `chaos_ogryn_gunner` - Рейпер

##### Обездвиживающие враги

- **`disabler_threats`** - Обездвиживающие враги
  - `summary`: `["chaos_hound", "cultist_mutant", "renegade_netgunner"]`
  - `setting`: `"plugin_disabler_threats"`

Дочерние строки (скрытые):
- `chaos_hound` - Чумная гончая
- `cultist_mutant` - Мутант
- `renegade_netgunner` - Траппер

##### Специальные враги

- **`special_threats`** - Специальные враги
  - `summary`: Бомберы, снайперы, флеймеры
  - `setting`: `"plugin_special_threats"`

Дочерние строки (скрытые):
- `chaos_poxwalker_bomber` - Чумной бомбер
- `renegade_grenadier`, `cultist_grenadier` - Гренадеры
- `renegade_sniper` - Снайпер
- `renegade_flamer`, `cultist_flamer` - Флеймеры

##### Боссы

- **`boss_threats`** - Боссы
  - `score_summary`: Список всех боссов (используется для подсчета очков)
  - `setting`: `"plugin_boss_threats"`

Дочерние строки (скрытые):
- `chaos_beast_of_nurgle` - Зверь Нургла
- `chaos_daemonhost` - Демон-хост
- `chaos_plague_ogryn` - Чумной огрин
- `chaos_plague_ogryn_sprayer` - Чумной огрин-распылитель
- `renegade_captain` - Капитан
- `chaos_spawn` - Порождение Хаоса
- `renegade_twin_captain` - Родин Карнак
- `renegade_twin_captain_two` - Ринда Карнак

## Функции

### `mod.collect_scoreboard_rows(loaded_rows)`

**Назначение:** Собирает и регистрирует все строки статистики из всех модов.

**Параметры:**
- `loaded_rows` (опционально) - Массив строк для загрузки из истории

**Что делает:**
1. Если `loaded_rows` не указан:
   - Очищает `mod.registered_scoreboard_rows`
   - Регистрирует строки из `mod.scoreboard_rows`
   - Проходит по всем модам DMF
   - Для каждого мода с полем `scoreboard_rows` регистрирует его строки
2. Если `loaded_rows` указан:
   - Регистрирует только указанные строки
   - Возвращает массив зарегистрированных записей

**Использование:**
- При загрузке мода для сбора всех строк
- При загрузке истории для восстановления строк из сохранения

---

### `mod.register_scoreboard_row(this_mod, template)`

**Назначение:** Регистрирует одну строку статистики.

**Параметры:**
- `this_mod` - Объект мода, которому принадлежит строка
- `template` - Шаблон строки с полями, описанными выше

**Возвращает:** Объект зарегистрированной строки

**Что делает:**
1. Преобразует строковые типы `iteration` и `validation` в объекты из `ScoreboardDefinitions`
2. Создает объект строки со всеми полями из шаблона
3. Добавляет поля:
   - `mod` - ссылка на мод
   - `iteration` - объект типа итерации
   - `validation` - объект типа валидации
   - `data` - таблица для хранения данных (если не указана)

**Структура возвращаемого объекта:**
```lua
{
    mod = this_mod,
    name = template.name,
    text = template.text,
    iteration = iteration_object,
    iteration_type = template.iteration,
    validation = validation_object,
    validation_type = template.validation,
    parent = template.parent,
    group = template.group,
    summary = template.summary,
    setting = template.setting,
    is_time = template.is_time,
    is_text = template.is_text,
    update = template.update,
    visible = template.visible,
    normalize = template.normalize,
    big = template.big,
    icon = template.icon,
    icon_package = template.icon_package,
    icon_width = template.icon_width,
    data = template.data or {},
}
```

**Использование:** Внутренняя функция, вызываемая `collect_scoreboard_rows`.

---

### `mod.update_scoreboard_rows(dt)`

**Назначение:** Обновляет строки, которые требуют периодического обновления.

**Параметры:**
- `dt` - Время, прошедшее с последнего кадра

**Что делает:**
- Проходит по всем зарегистрированным строкам
- Если у строки есть функция `update`, вызывает ее с параметрами `(row.mod, dt)`

**Использование:** Вызывается каждый кадр для обновления динамических показателей (когерентность, переноска предметов).

---

### `mod.update_row_value(row_name, account_id, value)`

**Назначение:** Обновляет значение строки статистики для конкретного игрока.

**Параметры:**
- `row_name` - Имя строки для обновления
- `account_id` - Идентификатор аккаунта игрока
- `value` - Новое значение (число или строка)

**Что делает:**
1. Если значение числовое:
   - Нормализует значение (не меньше 0)
   - Находит строку по имени через `get_scoreboard_row()`
   - Получает старое значение игрока (или 0)
   - Применяет функцию итерации для вычисления нового значения и прироста очков
   - Обновляет `value` и `score` в данных игрока
2. Если значение текстовое:
   - Сохраняет текст в `data[account_id].text`
   - Устанавливает `value = 0` и `score = 0`

**Использование:** Основная функция для обновления статистики из хуков игровых событий.

---

### `mod.get_scoreboard_row(row_name)`

**Назначение:** Находит зарегистрированную строку по имени.

**Параметры:**
- `row_name` - Имя строки для поиска

**Возвращает:** Объект строки или `nil`, если не найдена

**Что делает:**
- Проходит по всем зарегистрированным строкам
- Возвращает первую строку с совпадающим `name`

**Использование:** Поиск строки перед обновлением значений.

---

## Переменные модуля

### `mod.registered_scoreboard_rows`
**Тип:** Массив  
**Назначение:** Хранит все зарегистрированные строки статистики  
**Структура:** Массив объектов строк, созданных через `register_scoreboard_row()`

### `mod.scoreboard_rows`
**Тип:** Массив  
**Назначение:** Определения строк статистики самого мода scoreboard  
**Структура:** Массив шаблонов строк, описанных выше

---

## Примеры использования

### Добавление собственной строки из другого мода

```lua
local my_mod = get_mod("my_mod")

my_mod.scoreboard_rows = {
    {
        name = "my_custom_kills",
        text = "row_my_custom_kills",
        validation = "ASC",
        iteration = "ADD",
        group = "offense",
        setting = "plugin_my_custom_kills"
    }
}
```

### Обновление значения строки

```lua
-- Обновление числового значения
mod:update_row_value("damage_dealt", account_id, 150)

-- Обновление текстового значения
mod:update_row_value("player_status", account_id, "Alive")
```

### Получение строки

```lua
local row = mod:get_scoreboard_row("damage_dealt")
if row then
    local player_data = row.data[account_id]
    if player_data then
        local score = player_data.score
    end
end
```

---

## Зависимости

- `scoreboard_definitions.lua` - Для типов итерации и валидации
- `scoreboard.lua` - Для доступа к модулю и менеджерам
