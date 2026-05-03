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

## Способы реализации

### Способ 1. Parallax correction по camera hit position

Алгоритм:

1. Сделать raycast из камеры по центру экрана.
2. Взять первую точку hit, кроме собственного игрока.
3. Если hit нет, взять дальнюю точку: `camera_position + camera_direction * max_distance`.
4. Построить направление из `shooting_position` в эту точку.
5. Подменить rotation в `_shoot`.
6. Не трогать `HitScan.process_hits`.

Плюсы:

- простой и предсказуемый подход;
- не выбирает цель за игрока;
- не требует знать hit zones заранее;
- стены, щиты, броня, бафы и урон остаются в оригинальной логике игры.

Минусы:

- если camera ray попадает в мелкий obstacle рядом с врагом, пуля честно пойдет туда;
- если камера видит врага, а muzzle ray перекрыт стеной, игра должна сама решить попадание по стене;
- для оружия со spread нужно сохранить offset spread/recoil поверх исправленной базовой rotation.

Когда применять:

- основной надежный вариант для hitscan;
- подходит для bullet weapons, если correction делается один раз в `_shoot`.

### Способ 2. Camera hit position + validation shooting ray

Алгоритм:

1. Найти target point через camera ray.
2. Построить corrected rotation из `shooting_position`.
3. Сделать контрольный raycast из `shooting_position`.
4. Применять correction только если контрольный raycast попал в валидный `hit_actor`/`hit_zone`.

Плюсы:

- снижает риск ложных попаданий без урона;
- можно явно проверить `HitZone.get_name`;
- можно отсеять `afro`, `shield`, props.

Минусы:

- может отказаться от коррекции, хотя оригинальный `HitScan` с penetration/sphere/collision_tests все равно дал бы hit;
- разные weapons используют разные `hit_scan_template.collision_tests`, а простой validation raycast может не совпасть с реальным `_shoot`;
- легко получить ситуацию "иногда работает, иногда нет".

Когда применять:

- только если нужен строгий режим "подворачивать пулю только при гарантированном damage hit";
- лучше делать validation теми же collision settings, что использует конкретный `hit_scan_template`.

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

1. Найти enemy unit через broadphase или camera ray.
2. Взять `enemy_aim_target_03`, `enemy_aim_target_02` или `enemy_aim_target_01`.
3. Довернуть пулю в node.

Плюсы:

- просто;
- nodes есть у большинства enemies;
- удобно для coarse targeting.

Минусы:

- node не является damage hit actor;
- node не гарантирует `HitZone.get_name`;
- на слабых врагах и мелких целях легко получить визуальное попадание без урона;
- broadphase может выбрать врага рядом с прицелом, даже если camera ray не попал в него.

Когда применять:

- лучше не применять для боевого hitscan;
- можно использовать только как вспомогательный fallback для визуальных эффектов или aim assist, но не как точку финального выстрела.

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
3. Target point брать из camera ray hit position.
4. Если camera ray ничего не задел, использовать дальнюю точку по camera direction.
5. Не использовать broadphase для выбора врага.
6. Не использовать `enemy_aim_target_*` как финальную точку выстрела.
7. Сохранять spread/recoil/sway:
   - вычислить offset между `aim_rotation` и текущим `shooting_rotation`;
   - построить corrected base rotation в target point;
   - применить offset поверх corrected base rotation.
8. Для projectile actions обрабатывать отдельно, потому что `ActionShootProjectile._shoot` читает `action_component.shooting_rotation` внутри.

Если нужен "магнит" именно к врагу, это должен быть отдельный режим:

- camera ray сначала должен попасть в enemy actor;
- actor должен иметь валидный `HitZone`;
- target point можно брать из hit position или center of mass этой hit zone;
- угол коррекции должен быть маленьким;
- broadphase можно использовать только как fallback и только с line of sight проверкой.

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

Файл `ThirdPersonAimCorrection.lua` сейчас должен рассматриваться как экспериментальная реализация. Перед дальнейшей правкой нужно выбрать один из подходов выше и не смешивать несколько моделей одновременно.

Самый безопасный следующий шаг: оставить только `_shoot` correction для hitscan/pellets по camera hit position и отдельно написать чистую ветку для projectile weapons.
