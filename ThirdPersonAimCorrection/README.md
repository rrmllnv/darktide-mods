# ThirdPersonAimCorrection

## Цель

Мод должен исправить проблему вида от третьего лица: камера и оружие находятся в разных точках, поэтому центр экрана может быть наведен на врага, а реальный луч выстрела из `shooting_position` летит мимо.

Требуемое поведение:

- игрок наводит центр камеры на врага;
- мод определяет, куда реально смотрит камера;
- мод доворачивает направление выстрела так, чтобы пуля летела к этой точке;
- штатная логика игры сама решает, был ли реальный hit, какой `hit_zone`, прошел ли урон, сработали ли бафы.

Нельзя делать так, чтобы визуально пуля попадала, но `HitScan.process_hits` не получал валидный hit. В этом случае не будет урона, `on_hit` и бафов вроде токсина needle pistol.

## Оригинальный путь выстрела

Основной pipeline из исходников Darktide:

1. `ActionShoot._prepare_shooting`
   - берет `first_person_component.position`;
   - берет `first_person_component.rotation`;
   - применяет recoil, sway, aim assist, spread;
   - записывает результат в `action_component.shooting_position`;
   - записывает результат в `action_component.shooting_rotation`.

2. `ActionShoot.fixed_update`
   - берет `action_component.shooting_position`;
   - берет `action_component.shooting_rotation`;
   - вызывает `_shoot(position, rotation, ...)`.

3. `ActionShootHitScan._shoot`
   - делает `direction = Quaternion.forward(rotation)`;
   - вызывает `HitScan.raycast(...)`;
   - вызывает `HitScan.process_hits(...)`.

4. `HitScan.process_hits`
   - читает `hit.actor`;
   - получает `hit_unit = Actor.unit(hit_actor)`;
   - получает `hit_zone_name_or_nil = HitZone.get_name(hit_unit, hit_actor)`;
   - проверяет `Health.is_damagable(hit_unit)`;
   - вызывает `RangedAction.execute_attack(...)`, если hit валиден.

5. `Attack.execute`
   - применяет урон;
   - вызывает `proc_events.on_hit`;
   - через `on_hit` работают weapon buffs, traits и эффекты.

## Важные термины

### Camera ray

Raycast из позиции камеры по направлению `Quaternion.forward(camera_rotation)`.

Это то, куда смотрит центр экрана. Для third person correction это главный источник намерения игрока.

### Shooting ray

Raycast из `action_component.shooting_position` по `Quaternion.forward(action_component.shooting_rotation)`.

Это реальный боевой луч. Именно он должен попадать в валидный actor, иначе урона не будет.

### Hit

Результат `PhysicsWorld.raycast`. Обычно содержит:

- `position` или `[1]`;
- `distance` или `[2]`;
- `normal` или `[3]`;
- `actor` или `[4]`.

Сам факт `hit` не означает, что урон пройдет. Hit может быть по actor без damage hit zone.

### Hit actor

Физический actor, по которому попал raycast. Из него игра получает unit:

```lua
local hit_unit = Actor.unit(hit_actor)
```

Actor может принадлежать врагу, стене, щиту, ragdoll, декоративной части или actor без hit zone.

### Hit zone

Damage zone на actor врага. Получается так:

```lua
local hit_zone_name = HitZone.get_name(hit_unit, hit_actor)
```

Если `hit_zone_name == nil`, то для обычного врага урон может не пройти, потому что `HitScan.process_hits` не считает это валидным damage hit.

Особые случаи:

- `afro` - hit zone, которую игра часто игнорирует для урона;
- `shield` - может блокировать или не давать нужный proc;
- `center_mass`, `torso`, `head`, руки, ноги - обычные зоны урона.

### Enemy aim target nodes

`enemy_aim_target_01`, `enemy_aim_target_02`, `enemy_aim_target_03` - это nodes на unit врага.

Они полезны для AI, smart targeting, line of sight и вспомогательного наведения, но это не hit actor и не hit zone. Если доворачивать пулю в node, луч может пройти рядом с валидным collision actor или попасть в actor без damage zone. Тогда визуально кажется, что пуля попала, но урона и `on_hit` нет.

## Почему урон может не проходить

Возможные причины:

- луч камеры попал во врага, но луч из оружия после коррекции попал в другой actor;
- коррекция довела выстрел до `enemy_aim_target_*`, а не до физической точки hit;
- hit пришелся в actor без `HitZone.get_name`;
- hit пришелся в `afro`, `shield` или другой actor, который не дает нужный proc;
- мод изменил `shooting_rotation` слишком рано, а потом `_shoot` получил уже измененную rotation и применил коррекцию повторно;
- мод стер spread/recoil/sway, из-за чего оружие ведет себя не как оригинальное;
- projectile weapon читает не аргумент `rotation`, а `action_component.shooting_rotation`, поэтому его надо обрабатывать отдельно.

## Тестовый режим

Мод теперь должен рассматриваться как тестовый стенд. Активный способ выбирается через настройку `correction_method` в Mod Options.

Доступные значения dropdown:

- `method_1_camera_hit_position`;
- `method_2_validated_shooting_ray`;
- `method_3_hit_zone_center`;
- `method_4_enemy_aim_target_node`;
- `method_5_prepare_shooting`;
- `method_6_shoot_hook`.

Default value: `method_4_enemy_aim_target_node`, потому что это текущий подтверждённый baseline.

Hooks регистрируются один раз в главном файле. Активный способ выбирается через dispatcher при каждом выстреле.

Важно: `correction_method` можно менять в Mod Options во время теста. Новый способ должен применяться к следующим выстрелам без перезагрузки миссии.

Главный файл:

- `scripts/mods/ThirdPersonAimCorrection/ThirdPersonAimCorrection.lua` — точка входа, registry методов, чтение настроек, единый dispatcher hooks.

Общий код:

- `scripts/mods/ThirdPersonAimCorrection/methods/shared.lua` — camera ray, weapon whitelist, hit helpers, enemy side helpers, hit zone helpers, игнор player-owned units, расчет corrected rotation.
- `camera_enemy_actor_hit` — настоящий enemy actor под camera ray.
- `validated_damageable_muzzle_hit` — проверка, что corrected muzzle ray даёт damageable hit zone.
- `broadphase_target_node_position` — отдельный baseline-путь для метода 4.

Файлы способов:

| Dropdown value | Файл | Назначение |
| --- | --- | --- |
| `method_1_camera_hit_position` | `methods/method_1_camera_hit_position.lua` | Assist: точка попадания camera ray в enemy actor, fallback в broadphase node. |
| `method_2_validated_shooting_ray` | `methods/method_2_validated_shooting_ray.lua` | Assist: validation уточняет target, но не блокирует fallback. |
| `method_3_hit_zone_center` | `methods/method_3_hit_zone_center.lua` | Assist: центр hit zone enemy actor, fallback в broadphase node. |
| `method_4_enemy_aim_target_node` | `methods/method_4_enemy_aim_target_node.lua` | Baseline: broadphase-поиск hit zone center вдоль camera line с проверкой damageable muzzle ray, затем fallback в `enemy_aim_target_*` nodes. |
| `method_5_prepare_shooting` | `methods/method_5_prepare_shooting.lua` | Assist через hook `_prepare_shooting`, fallback в broadphase node. |
| `method_6_shoot_hook` | `methods/method_6_shoot_hook.lua` | Assist через hook `_shoot` для hitscan/pellets, fallback в broadphase node. |

Метод 4 считается контрольным baseline. Методы 1/2/3/5/6 используют его broadphase/node путь как fallback, потому что цель мода — помогать стрельбе от третьего лица, а не блокировать коррекцию из-за слишком строгих hit zone проверок.

Для диагностики включить `debug_enabled`. Тогда при отказе метода мод пишет в log через `mod:info`, а не в чат:

- `disabled`;
- `not_local_player`;
- `not_third_person`;
- `not_whitelisted`;
- `no_physics_world`;
- `no_camera_pose`;
- `no_camera_hit`;
- `no_enemy_actor`;
- `no_hit_actor`;
- `not_damageable`;
- `no_hit_zone`;
- `invalid_hit_zone`;
- `no_hit_zone_center`;
- `no_muzzle_hit`;
- `no_target_position`;
- `no_shooting_position`;
- `no_shooting_rotation`;
- `target_too_close`;
- `angle_limit`.

Тестировать нужно по одному способу за раз:

1. Выбрать способ в dropdown.
2. Включить `debug_enabled`, если метод не подворачивает пулю.
3. Сделать следующий выстрел без перезагрузки миссии.
4. Проверить слабого врага в упор.
5. Проверить слабого врага на средней дистанции.
6. Проверить выстрел рядом с врагом, но не по нему.
7. Проверить obstacle между оружием и врагом.
8. Проверить needle pistol: урон, `on_hit`, токсин.
9. Проверить pellets/shotgun.
10. Записать результат и debug reason перед правкой метода.

## Способы реализации

| Способ | Суть | Когда пуля подворачивается | Плюсы | Минусы | Риск для урона/бафов |
| --- | --- | --- | --- | --- | --- |
| 1. Parallax correction по camera hit position | Camera ray ищет enemy actor под прицелом, shooting ray доворачивается из `shooting_position` в hit position этого actor. | Только когда camera ray попал в настоящий enemy actor. | Простой диагностический способ; не выбирает цель через broadphase; оставляет урон, стены, щиты, hit zone и бафы штатной логике игры. | Если camera ray не даёт enemy actor, метод честно не сработает и пишет debug reason. | Низкий, если correction применяется один раз в `_shoot` и не подменяет `HitScan.process_hits`. |
| 2. Camera hit position + validation shooting ray | После выбора точки камеры делается дополнительный raycast из оружия, чтобы проверить будущий hit. | Только если corrected shooting ray из `shooting_position` попадает в допустимый actor или hit zone. | Можно заранее отсеять ложные попадания; можно проверить `HitZone.get_name`, `afro`, `shield`, props. | Validation может не совпадать с реальным `hit_scan_template`, sphere sweep, penetration и collision tests; может давать нестабильное "то работает, то нет". | Средний: если validation проще оригинального `_shoot`, она может блокировать корректные выстрелы или пропускать некорректные. |
| 3. Наведение по enemy hit zone center | Camera ray находит enemy actor, затем пуля доворачивается в центр выбранной hit zone. | Когда camera ray попал во врага и у actor есть валидный `hit_zone`. | Целится именно в damage zone; меньше шанс попасть в actor без урона; можно выбрать `torso`, `head`, `center_mass`. | Это уже aim assist/магнит, а не чистая parallax correction; может перетягивать пулю с края модели в центр; зависит от breed и hit zone layout. | Низкий-средний: урон обычно проходит, но поведение может стать нечестным и отличаться от намерения игрока. |
| 4. Наведение по `enemy_aim_target_*` | Мод выбирает node врага: `enemy_aim_target_01/02/03`, затем доворачивает пулю в него. | Когда broadphase или camera ray нашел enemy unit с нужным node. | Просто реализовать; nodes есть у большинства enemies; удобно для coarse targeting. | Node не является hit actor и не гарантирует hit zone; broadphase может выбрать врага не под прицелом; на слабых врагах возможны визуальные попадания без урона. | Высокий: можно попасть "в модель", но не получить валидный `HitZone.get_name`, поэтому не будет урона и `on_hit`. |
| 5. Hook `_prepare_shooting` | Мод заранее меняет `action_component.shooting_rotation` после оригинального `_prepare_shooting`. | До `_shoot`, когда action component уже содержит `shooting_position` и `shooting_rotation`. | Подходит для классов, которые внутри `_shoot` читают component; полезно для projectile actions. | Легко получить двойную коррекцию; component может использоваться другими системами; сложнее контролировать один выстрел. | Средний-высокий: при повторной коррекции пуля может улетать в сторону или ломать spread/recoil. |
| 6. Hook `_shoot` | Мод не трогает component, а заменяет локальный аргумент `rotation` прямо перед оригинальным `_shoot`. | В момент выстрела, когда уже известны `position`, `rotation`, `fire_config`. | Лучший вариант для `ActionShootHitScan` и `ActionShootPellets`; коррекция применяется один раз; меньше побочных эффектов. | Не подходит напрямую для классов, которые игнорируют аргумент `rotation` и читают component внутри; projectiles требуют отдельной ветки. | Низкий для hitscan/pellets, если target point выбран правильно. |

### Способ 1. Parallax correction по camera hit position

Алгоритм:

1. Сделать raycast из камеры по центру экрана.
2. Взять hit position, если hit actor принадлежит enemy unit.
3. Если enemy actor нет, использовать broadphase/node fallback.
4. Построить направление из `shooting_position` в эту точку.
5. Подменить rotation в `_shoot`.
6. Не трогать `HitScan.process_hits`.

Плюсы:

- простой и предсказуемый подход;
- не выбирает цель за игрока;
- не требует знать hit zones заранее;
- стены, щиты, броня, бафы и урон остаются в оригинальной логике игры.

Минусы:

- если camera ray попадает в obstacle рядом с врагом, метод может перейти на broadphase fallback;
- если камера видит врага, а muzzle ray перекрыт стеной, игра должна сама решить попадание по стене;
- текущий диагностический режим не накладывает старый spread/recoil offset поверх corrected rotation, чтобы исключить увод выстрела в сторону.

Когда применять:

- основной надежный вариант для hitscan;
- подходит для bullet weapons, если correction делается один раз в `_shoot`.

### Способ 2. Camera hit position + validation shooting ray

Алгоритм:

1. Найти target point через camera ray.
2. Построить corrected rotation из `shooting_position`.
3. Сделать контрольный raycast из `shooting_position`.
4. Если контрольный raycast попал в валидный `hit_actor`/`hit_zone`, использовать его точку.
5. Если validation не прошла, оставить исходный target point или broadphase fallback.

Плюсы:

- снижает риск ложных попаданий без урона;
- можно явно проверить `HitZone.get_name`;
- можно отсеять `afro`, `shield`, props.

Минусы:

- может отказаться от коррекции, хотя оригинальный `HitScan` с penetration/sphere/collision_tests все равно дал бы hit;
- разные weapons используют разные `hit_scan_template.collision_tests`, а простой validation raycast может не совпасть с реальным `_shoot`;
- легко получить ситуацию "иногда работает, иногда нет".

Когда применять:

- когда нужно уточнить target point, но не блокировать assist;
- validation не должна отменять коррекцию, если broadphase/node fallback уже нашел цель.

### Способ 3. Наведение по enemy hit zone center

Алгоритм:

1. Camera ray находит enemy actor.
2. Из actor получается `hit_unit`.
3. Выбирается hit zone: например `center_mass`, `torso`, `head`.
4. Через `HitZone.hit_zone_center_of_mass(...)` берется точка зоны.
5. Пуля доворачивается в эту точку.

Плюсы:

- можно целиться именно в damage zone;
- меньше риска попасть в actor без урона;
- можно явно выбирать body/head.

Минусы:

- это уже aim assist, а не простая parallax correction;
- если игрок навелся в руку или край тела, мод может перетянуть пулю в центр;
- hit zone names и actor layout зависят от breed;
- может ломать ощущение честного прицеливания.

Когда применять:

- если задача именно "магнитить" пули к врагу;
- нужно ограничивать углом, дистанцией и line of sight.

### Способ 4. Наведение по enemy aim target nodes

Алгоритм:

1. Найти enemy unit через broadphase относительно текущей camera position.
2. Выбрать центр валидной hit zone, ближайший к camera line: голова, торс, руки, ноги и другие damage zones.
3. Проверить ray из `shooting_position` в выбранную точку: он должен первым попасть в damageable hit zone, а не в `afro`/surface.
4. Если hit zone center недоступен или не проходит damageable validation, взять `enemy_aim_target_03`, `enemy_aim_target_02` или `enemy_aim_target_01` и тоже проверить ray из `shooting_position`.
5. Довернуть пулю в выбранную точку.

Плюсы:

- просто;
- nodes есть у большинства enemies;
- удобно для coarse targeting.

Минусы:

- hit zone center ближе к damage model, чем `enemy_aim_target_*`;
- `enemy_aim_target_*` используется только как fallback, если hit zone center недоступен;
- на слабых врагах и мелких целях легко получить визуальное попадание без урона;
- broadphase может выбрать врага рядом с camera ray, даже если точный camera ray не попал в actor.

Когда применять:

- лучше не применять для боевого hitscan;
- можно использовать как отдельный baseline или отдельный aim assist режим, но не как скрытую подмену внутри других способов.

### Способ 5. Hook `_prepare_shooting`

Алгоритм:

1. После оригинального `_prepare_shooting` изменить `action_component.shooting_rotation`.
2. Оригинальный `_shoot` потом использует уже измененную rotation.

Плюсы:

- работает для классов, которые читают `action_component.shooting_rotation`;
- полезно для projectile weapons, где `_shoot` внутри заново читает component.

Минусы:

- легко получить двойную коррекцию, если отдельно hook-нуть `_shoot`;
- component может использоваться другими системами;
- сложнее гарантировать, что correction применяется ровно один раз.

Когда применять:

- только если конкретный action class не принимает rotation аргумент или игнорирует его;
- обязательно исключить повторную коррекцию в `_shoot`.

### Способ 6. Hook `_shoot`

Алгоритм:

1. Не трогать `_prepare_shooting`.
2. В `_shoot(position, rotation, ...)` заменить только локальный `rotation`.
3. Вызвать оригинальный `_shoot` с corrected rotation.

Плюсы:

- коррекция применяется ровно в момент выстрела;
- не портит `action_component`;
- хорошо подходит для `ActionShootHitScan` и `ActionShootPellets`.

Минусы:

- не подходит напрямую для classes, которые игнорируют аргумент `rotation` и читают component внутри;
- projectile weapons требуют отдельной обработки.

Когда применять:

- основной вариант для hitscan и pellets.

## Как понимать "когда пуля подворачивается"

Коррекция должна применяться только если:

- мод включен;
- это локальный player unit;
- игрок находится в third person, если включена настройка `only_third_person`;
- weapon whitelisted;
- есть `shooting_position`;
- есть исходный `shooting_rotation`;
- есть camera position/rotation;
- correction angle не превышает безопасный предел;
- target point находится впереди камеры и достижим по выбранной логике.

Коррекция не должна применяться если:

- camera ray невалиден;
- target point слишком близко к `shooting_position`;
- correction angle слишком большой;
- weapon class использует другой pipeline, который не обработан;
- correction уже была применена на этом же выстреле.

## Рекомендованный профессиональный подход

Для этого мода базовый надежный вариант:

1. Для `ActionShootHitScan` и `ActionShootPellets` корректировать только в `_shoot`.
2. Не менять `action_component.shooting_rotation` для hitscan/pellets.
3. Target point брать из camera ray enemy actor hit position.
4. Если camera ray не нашел enemy actor, не применять диагностические методы 1/2/3/5/6 и смотреть debug reason.
5. Не использовать broadphase для выбора врага.
6. Не использовать `enemy_aim_target_*` как финальную точку выстрела.
7. В диагностическом режиме строить corrected rotation напрямую в target point, без повторного применения offset от старой rotation.
8. Для projectile actions обрабатывать отдельно, потому что `ActionShootProjectile._shoot` читает `action_component.shooting_rotation` внутри.

Если нужен "магнит" именно к врагу, это должен быть отдельный режим:

- camera ray сначала должен попасть в enemy actor;
- actor должен иметь валидный `HitZone`;
- target point можно брать из hit position или center of mass этой hit zone;
- угол коррекции должен быть маленьким;
- broadphase можно использовать как общий assist fallback, если camera actor/hit zone проверка не дала usable target.

## Что проверять при тестировании

Минимальные тесты:

- враг в центре экрана, близко;
- враг в центре экрана, средняя дистанция;
- враг рядом с краем прицела;
- враг частично за стеной;
- стрельба рядом с врагом, но не по нему;
- слабые enemies;
- enemies со щитами;
- needle pistol и его токсин;
- shotgun/pellets;
- projectile weapons.

Для каждого теста нужно смотреть:

- куда летит визуальная трасса;
- был ли реальный урон;
- сработал ли `on_hit`;
- наложился ли debuff/buff;
- не проходит ли урон через стены;
- не магнитит ли пулю к врагу, когда игрок не навелся.

## Текущее состояние

Файл `ThirdPersonAimCorrection.lua` сейчас должен рассматриваться как registry тестового стенда. Конкретную логику нужно править в отдельном файле выбранного способа.

Самый безопасный следующий шаг: оставить только `_shoot` correction для hitscan/pellets по camera hit position и отдельно написать чистую ветку для projectile weapons.
