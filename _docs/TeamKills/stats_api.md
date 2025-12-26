# Darktide Stats API Documentation

## Overview

Darktide uses a statistics system managed by `Managers.stats` to track various gameplay events during missions. This system provides two main functions for recording statistics: `record_private` (for player-specific stats) and `record_team` (for team-wide stats).

## Functions

### `Managers.stats:record_private(stat_name, player, ...)`

Records a private statistic for a specific player.

**Parameters:**
- `stat_name` (string): The name of the statistic hook (e.g., `"hook_kill"`, `"hook_damage_dealt"`)
- `player` (Player): The player object for whom the statistic is recorded
- `...` (varargs): Additional parameters specific to each statistic type

**Usage:**
```lua
Managers.stats:record_private("hook_kill", attacking_player, attack_table)
Managers.stats:record_private("hook_damage_dealt", attacking_player, attack_table)
```

**Note:** The function only records statistics if the player is being tracked (`user.state == UserStates.tracking`).

### `Managers.stats:record_team(stat_name, ...)`

Records a team-wide statistic.

**Parameters:**
- `stat_name` (string): The name of the statistic hook (e.g., `"hook_boss_died"`)
- `...` (varargs): Additional parameters specific to each statistic type

**Usage:**
```lua
Managers.stats:record_team("hook_boss_died", breed_name, boss_max_health, boss_unit_id, time_since_first_damage, attack_table)
```

**Note:** The function only records statistics if a session is active (`has_session() == true`).

## Available Statistics (Hook Events)

### Combat Statistics

#### `hook_kill`
**Triggered when:** A player kills an enemy
**Parameters:**
- `player`: The player who made the kill
- `attack_table`: Table containing attack information:
  - `attacking_unit`: Unit that attacked
  - `attacked_unit`: Unit that was killed
  - `target_breed_name`: Name of the killed enemy breed
  - `attack_type`: Type of attack ("melee", "ranged", "explosion")
  - `damage_dealt`: Amount of damage dealt
  - `hit_zone_name`: Zone that was hit
  - `weapon_template_name`: Name of the weapon used
  - `is_weakspot_hit`: Whether it was a weakspot hit
  - `solo_kill`: Whether only one player damaged the enemy
  - And many more fields...

**Used in:** `scripts/utilities/attack/attack.lua:774`

#### `hook_damage_dealt`
**Triggered when:** A player deals damage to any unit
**Parameters:**
- `player`: The player who dealt damage
- `attack_table`: Same structure as `hook_kill`

**Used in:** `scripts/utilities/attack/attack.lua:771`

#### `hook_damage_taken`
**Triggered when:** A player takes damage
**Parameters:**
- `player`: The player who took damage
- `damage_dealt`: Amount of damage taken
- `attack_type`: Type of attack ("melee", "ranged", etc.)
- `attacker_breed`: Breed of the attacker (if applicable)

**Used in:** `scripts/utilities/attack/attack.lua:812`

#### `hook_blocked_damage`
**Triggered when:** A player blocks damage
**Parameters:**
- `player`: The player who blocked
- `weapon_template_name`: Name of the weapon used to block
- `damage_absorbed`: Amount of damage blocked

**Used in:** `scripts/utilities/attack/attack.lua:797`

#### `hook_blocked_damage_from_unique_enemy`
**Triggered when:** A player blocks damage from an enemy for the first time
**Parameters:**
- `player`: The player who blocked
- `weapon_template_name`: Name of the weapon used to block
- `damage_absorbed`: Amount of damage blocked

**Used in:** `scripts/utilities/attack/attack.lua:803`

#### `hook_dodged_attack`
**Triggered when:** A player dodges an attack
**Parameters:**
- `player`: The player who dodged
- `attacker_breed_name`: Breed name of the attacker
- `attack_type`: Type of attack (usually "ranged")
- `stat_dodge_type`: Type of dodge
- `attacked_action`: Action that was dodged
- `previously_dodged`: Whether this enemy was dodged before
- `dodging_unit_buff_keywords`: Buff keywords active during dodge

**Used in:** `scripts/utilities/attack/hit_scan.lua:185`

#### `hook_melee_kill_toughness_regenerated`
**Triggered when:** A player regenerates toughness from a melee kill
**Parameters:**
- `player`: The player who regenerated toughness
- `amount`: Amount of toughness regenerated

**Used in:** `scripts/utilities/attack/attack.lua:925`

### Boss Statistics

#### `hook_boss_died` (Team Stat)
**Triggered when:** A boss is killed
**Parameters:**
- `breed_name`: Name of the boss breed
- `boss_max_health`: Maximum health of the boss
- `boss_unit_id`: Unit ID of the boss
- `time_since_first_damage`: Time since first damage was dealt
- `attack_table`: Attack information table

**Used in:** `scripts/utilities/attack/attack.lua:783`

### Ability Statistics

#### `hook_alternate_fire_start`
**Triggered when:** A player starts using alternate fire
**Parameters:**
- `player`: The player who started alternate fire

**Used in:** `scripts/utilities/alternate_fire.lua:62`

#### `hook_alternate_fire_stop`
**Triggered when:** A player stops using alternate fire
**Parameters:**
- `player`: The player who stopped alternate fire

**Used in:** `scripts/utilities/alternate_fire.lua:103`

### Veteran (Sharpshooter) Statistics

#### `hook_volley_fire_start`
**Triggered when:** Veteran activates Volley Fire ability
**Parameters:**
- `player`: The Veteran player

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:43`

#### `hook_volley_fire_stop`
**Triggered when:** Veteran deactivates Volley Fire ability
**Parameters:**
- `player`: The Veteran player
- `total_time`: Total time Volley Fire was active

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:59`

#### `hook_veteran_kill_volley_fire_target`
**Triggered when:** Veteran kills a target while Volley Fire is active
**Parameters:**
- `player`: The Veteran player

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:67`

#### `hook_veteran_ammo_given`
**Triggered when:** Veteran gives ammo to teammates
**Parameters:**
- `player`: The Veteran player
- `ammo_gained`: Amount of ammo given

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:1529, 1579`

#### `hook_veteran_infiltrate_stagger`
**Triggered when:** Veteran's Infiltrate ability staggers enemies
**Parameters:**
- `player`: The Veteran player
- `number_of_enemies_staggered`: Number of enemies staggered

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:1254`

#### `hook_focus_fire_max_stacks`
**Triggered when:** Veteran reaches max Focus Fire stacks
**Parameters:**
- `player`: The Veteran player

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:2784`

#### `hook_focus_fire_max_reset`
**Triggered when:** Veteran's Focus Fire max stacks reset
**Parameters:**
- `player`: The Veteran player

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:2788`

#### `hook_veteran_weapon_switch_keystone`
**Triggered when:** Veteran's weapon switch keystone activates
**Parameters:**
- `player`: The Veteran player
- `params`: Additional parameters

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:3031, 3121`

#### `hook_veteran_improved_tag`
**Triggered when:** Veteran uses improved tag ability
**Parameters:**
- `player`: The Veteran player

**Used in:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:3282`

### Zealot (Preacher) Statistics

#### `hook_shroudfield_start`
**Triggered when:** Zealot activates Shroudfield ability
**Parameters:**
- `player`: The Zealot player

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:43`

#### `hook_shroudfield_stop`
**Triggered when:** Zealot deactivates Shroudfield ability
**Parameters:**
- `player`: The Zealot player

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:49`

#### `hook_zealot_fanatic_rage_start`
**Triggered when:** Zealot enters Fanatic Rage
**Parameters:**
- `player`: The Zealot player

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:894`

#### `hook_zealot_fanatic_rage_stop`
**Triggered when:** Zealot exits Fanatic Rage
**Parameters:**
- `player`: The Zealot player

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:946`

#### `hook_martyrdom_stacks`
**Triggered when:** Zealot's Martyrdom stacks change
**Parameters:**
- `player`: The Zealot player
- `missing_segments`: Number of missing health segments

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:1353`

#### `hook_zealot_engulfed_enemies`
**Triggered when:** Zealot engulfs enemies with ability
**Parameters:**
- `player`: The Zealot player
- `engulfed_enemies`: Number of enemies engulfed

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:1417`

#### `hook_zealot_movement_keystone_start`
**Triggered when:** Zealot's movement keystone activates
**Parameters:**
- `player`: The Zealot player
- `num_child_stacks_removed`: Number of child stacks removed
- `achievement_target`: Achievement target value

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:241`

#### `hook_zealot_movement_keystone_stop`
**Triggered when:** Zealot's movement keystone deactivates
**Parameters:**
- `player`: The Zealot player

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:203`

#### `hook_zealot_loner_aura`
**Triggered when:** Zealot's Loner aura activates
**Parameters:**
- `player`: The Zealot player

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:3187`

#### `hook_zealot_health_leeched_during_resist_death`
**Triggered when:** Zealot leeches health during Resist Death
**Parameters:**
- `player`: The Zealot player
- `heal_percentage`: Percentage of health leeched

**Used in:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:3577`

### Psyker Statistics

#### `hook_overcharge_stance_start`
**Triggered when:** Psyker enters Overcharge stance
**Parameters:**
- `player`: The Psyker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:50`

#### `hook_overcharge_stance_stop`
**Triggered when:** Psyker exits Overcharge stance
**Parameters:**
- `player`: The Psyker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:56`

#### `hook_psyker_reached_max_souls`
**Triggered when:** Psyker reaches maximum soul stacks
**Parameters:**
- `player`: The Psyker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:202`

#### `hook_psyker_time_at_max_souls`
**Triggered when:** Psyker spends time at max souls
**Parameters:**
- `player`: The Psyker player
- `time_at_max`: Time spent at max souls

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:266`

#### `hook_psyker_lost_max_souls`
**Triggered when:** Psyker loses max soul stacks
**Parameters:**
- `player`: The Psyker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:280`

#### `hook_psyker_spent_max_unnatural_stack`
**Triggered when:** Psyker spends max unnatural stack
**Parameters:**
- `player`: The Psyker player
- `rounded_time_value`: Rounded time value

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:760`

#### `hook_psyker_empowered_ability`
**Triggered when:** Psyker uses empowered ability
**Parameters:**
- `player`: The Psyker player
- `params`: Additional parameters

**Used in:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:2476`

### Ogryn Statistics

#### `hook_ogryn_heavy_hitter_at_max_stacks`
**Triggered when:** Ogryn reaches max Heavy Hitter stacks
**Parameters:**
- `player`: The Ogryn player

**Used in:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:239`

#### `hook_ogryn_heavy_hitter_at_max_lost`
**Triggered when:** Ogryn loses max Heavy Hitter stacks
**Parameters:**
- `player`: The Ogryn player

**Used in:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:204`

#### `hook_ogryn_feel_no_pain_kills_at_max`
**Triggered when:** Ogryn gets kills at max Feel No Pain stacks
**Parameters:**
- `player`: The Ogryn player

**Used in:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:669`

#### `hook_ogryn_frag_grenade`
**Triggered when:** Ogryn uses frag grenade
**Parameters:**
- `player`: The Ogryn player

**Used in:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:1275`

#### `hook_ogryn_barrage_end`
**Triggered when:** Ogryn's Barrage ability ends
**Parameters:**
- `player`: The Ogryn player

**Used in:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:2021`

#### `hook_ogryn_leadbelcher_free_shot`
**Triggered when:** Ogryn gets a free shot from Leadbelcher
**Parameters:**
- `player`: The Ogryn player

**Used in:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:2042`

### Broker Statistics

#### `hook_broker_exited_punk_rage`
**Triggered when:** Broker exits Punk Rage
**Parameters:**
- `player`: The Broker player
- `time_spent_in_punk_rage`: Time spent in Punk Rage

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:748`

#### `hook_broker_time_ally_buffed_by_stimm_field`
**Triggered when:** Broker's stimm field buffs an ally
**Parameters:**
- `player`: The Broker player (owner)
- `time_buffed`: Time the ally was buffed

**Used in:** `scripts/settings/buff/buff_utils.lua:198`

#### `hook_broker_stack_of_vulture_keystone`
**Triggered when:** Broker's Stack of Vulture keystone activates
**Parameters:**
- `player`: The Broker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:2809`

#### `hook_broker_proc_max_stacks_adrenaline_keystone`
**Triggered when:** Broker procs max stacks of Adrenaline keystone
**Parameters:**
- `player`: The Broker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3104`

#### `hook_broker_exited_max_stacks_of_chemical_dependency`
**Triggered when:** Broker exits max stacks of Chemical Dependency
**Parameters:**
- `player`: The Broker player
- `time_spent_at_max_stacks`: Time spent at max stacks

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:2984, 3003`

#### `hook_broker_stimm_used`
**Triggered when:** Broker uses a stimm
**Parameters:**
- `player`: The Broker player
- `stimm_stat_increases`: Stat increases from stimm
- `target_player`: Player who used the stimm

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3434`

#### `hook_broker_stimm_restored_tougness`
**Triggered when:** Broker's stimm restores toughness
**Parameters:**
- `player`: The Broker player
- `recovered_toughness`: Amount of toughness recovered
- `target_player`: Player who received the toughness

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3232`

#### `hook_broker_cluster_staggered_by_flash_grenade`
**Triggered when:** Broker's flash grenade staggers a cluster of enemies
**Parameters:**
- `player`: The Broker player

**Used in:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3530`

### Adamant Statistics

#### `hook_adamant_time_enemy_electrocuted_by_shockmine`
**Triggered when:** Enemy is electrocuted by Adamant's shockmine
**Parameters:**
- `player`: The Adamant player
- `rounded_time_shocked`: Rounded time enemy was shocked

**Used in:** `scripts/settings/buff/weapon_buff_templates.lua:487`

#### `hook_adamant_whistle_explosion_stagger_monster`
**Triggered when:** Adamant's whistle explosion staggers a monster
**Parameters:**
- `player`: The Adamant player

**Used in:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:380`

#### `hook_adamant_killed_cluster_of_enemies_with_grenade`
**Triggered when:** Adamant kills a cluster of enemies with grenade
**Parameters:**
- `player`: The Adamant player

**Used in:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:418`

#### `hook_adamant_killed_enemy_marked_by_execution_order`
**Triggered when:** Adamant kills an enemy marked by Execution Order
**Parameters:**
- `player`: The Adamant player

**Used in:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:1068`

#### `hook_adamant_exited_max_forceful_stacks`
**Triggered when:** Adamant exits max Forceful stacks
**Parameters:**
- `player`: The Adamant player
- `time_at_max_stacks_rounded`: Rounded time at max stacks

**Used in:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:1429`

### Syringe/Stimm Statistics

#### `hook_red_stimm_active`
**Triggered when:** Red stimm is activated
**Parameters:**
- `player`: The player who activated the stimm

**Used in:** `scripts/settings/buff/syringe_buff_templates.lua:259`

#### `hook_red_stimm_deactivated`
**Triggered when:** Red stimm is deactivated
**Parameters:**
- `player`: The player who deactivated the stimm

**Used in:** `scripts/settings/buff/syringe_buff_templates.lua:272`

#### `hook_blue_stimm_active`
**Triggered when:** Blue stimm is activated
**Parameters:**
- `player`: The player who activated the stimm

**Used in:** `scripts/settings/buff/syringe_buff_templates.lua:306`

#### `hook_blue_stimm_deactivated`
**Triggered when:** Blue stimm is deactivated
**Parameters:**
- `player`: The player who deactivated the stimm

**Used in:** `scripts/settings/buff/syringe_buff_templates.lua:319`

#### `hook_green_stimm_corruption_healed`
**Triggered when:** Green stimm heals corruption
**Parameters:**
- `player`: The player who provided the stimm
- `corruption_heal`: Amount of corruption healed

**Used in:** `scripts/settings/buff/syringe_buff_templates.lua:174`

#### `hook_ability_time_saved_by_yellow_stimm`
**Triggered when:** Yellow stimm saves ability time
**Parameters:**
- `player`: The player who used the stimm
- `time_reduced`: Time reduced from ability cooldown

**Used in:** `scripts/settings/buff/syringe_buff_templates.lua:232`

### Mission/Objective Statistics

#### `hook_mission_ended` (Team Stat)
**Triggered when:** Mission ends
**Parameters:** Varies by mission type

**Used in:** Various mission scripts

#### `hook_objective_side_incremented_progression` (Team Stat)
**Triggered when:** Objective side progression is incremented
**Parameters:**
- `objective_name`: Name of the objective
- `incremented_progression`: Amount of progression incremented

**Used in:** `scripts/extension_systems/mission_objective/utilities/mission_objective_side.lua:48`

#### `hook_game_mode_survival_island_completed` (Team Stat)
**Triggered when:** Survival mode island is completed
**Parameters:**
- `island_number`: Number of the completed island

**Used in:** `scripts/managers/game_mode/game_modes/game_mode_survival.lua:521`

#### `hook_team_explosion` (Team Stat)
**Triggered when:** A team-wide explosion occurs
**Parameters:**
- `explosion_template`: Template of the explosion
- `data`: Explosion data

**Used in:** `scripts/extension_systems/weapon/weapon_system.lua:355`

#### `hook_mission_twins_mine_triggered` (Team Stat)
**Triggered when:** Twins mine is triggered
**Parameters:** None

**Used in:** `scripts/extension_systems/projectile_damage/projectile_damage_extension.lua:258`

#### `hook_mission_twins_boss_started_mine_intialized` (Team Stat)
**Triggered when:** Twins boss mine is initialized
**Parameters:** None

**Used in:** `scripts/managers/mutator/mutators/mutator_toxic_gas_twins.lua:761`

#### `hook_saint_points_acquired` (Team Stat)
**Triggered when:** Saint points are acquired
**Parameters:**
- `points`: Number of points acquired

**Used in:** `scripts/managers/mutator/mutators/mutator_gameplay/mutator_gameplay_live_event_saints_simplified.lua:40, 200`

### Other Statistics

#### `hook_player_spawned`
**Triggered when:** A player spawns
**Parameters:**
- `player`: The player who spawned
- `profile`: Player profile data

**Used in:** `scripts/managers/player/player_unit_spawn_manager.lua:228`

#### `hook_ranged_attack_concluded`
**Triggered when:** A ranged attack concludes
**Parameters:**
- `hit_minion`: Whether a minion was hit
- `hit_weakspot`: Whether a weakspot was hit
- `killing_blow`: Whether it was a killing blow
- `last_round_in_mag`: Whether it was the last round in magazine

**Used in:** Various weapon scripts

#### `hook_health_update`
**Triggered when:** Player health updates
**Parameters:**
- `dt`: Delta time
- `remaining_health_segments`: Remaining health segments
- `is_knocked_down`: Whether player is knocked down

**Used in:** Health system scripts

#### `hook_knocked_down`
**Triggered when:** A player is knocked down
**Parameters:**
- `player`: The player who was knocked down

**Used in:** Various scripts

#### `hook_death`
**Triggered when:** A player dies
**Parameters:**
- `player`: The player who died

**Used in:** Various scripts

#### `hook_collect_material`
**Triggered when:** A player collects material
**Parameters:**
- `player`: The player who collected
- `material_type`: Type of material collected

**Used in:** Various scripts

#### `hook_picked_up_item`
**Triggered when:** A player picks up an item
**Parameters:**
- `player`: The player who picked up
- `item_type`: Type of item picked up

**Used in:** Various scripts

#### `hook_placed_item`
**Triggered when:** A player places an item
**Parameters:**
- `player`: The player who placed
- `item_type`: Type of item placed

**Used in:** Various scripts

#### `hook_collect_collectible`
**Triggered when:** A player collects a collectible
**Parameters:**
- `player`: The player who collected
- `collectible_type`: Type of collectible

**Used in:** Various scripts

#### `hook_team_chest_opened` (Team Stat)
**Triggered when:** A team chest is opened
**Parameters:**
- `chest_type`: Type of chest opened

**Used in:** Various scripts

#### `hook_health_station_interaccion_success`
**Triggered when:** A player successfully interacts with a health station
**Parameters:**
- `player`: The player who interacted

**Used in:** Various scripts

#### `hook_assist_ally`
**Triggered when:** A player assists an ally
**Parameters:**
- `player`: The player who assisted
- `ally`: The ally who was assisted

**Used in:** Various scripts

#### `hook_rescue_ally`
**Triggered when:** A player rescues an ally
**Parameters:**
- `player`: The player who rescued
- `ally`: The ally who was rescued

**Used in:** Various scripts

#### `hook_escaped_captivitiy`
**Triggered when:** A player escapes captivity
**Parameters:**
- `player`: The player who escaped

**Used in:** Various scripts

#### `hook_coherency_update`
**Triggered when:** Player coherency updates
**Parameters:**
- `player`: The player
- `coherency_data`: Coherency data

**Used in:** Various scripts

#### `hook_coherency_toughness_regenerated`
**Triggered when:** Toughness is regenerated from coherency
**Parameters:**
- `player`: The player
- `amount`: Amount regenerated

**Used in:** Various scripts

#### `hook_toughness_broken`
**Triggered when:** Player toughness is broken
**Parameters:**
- `player`: The player whose toughness broke

**Used in:** Various scripts

#### `hook_ammo_consumed`
**Triggered when:** Ammo is consumed
**Parameters:**
- `player`: The player
- `amount`: Amount consumed

**Used in:** Various scripts

## What the Game Tracks During a Session

The game tracks a comprehensive set of statistics during each mission session:

### Player-Specific Stats (Private)
- **Kills:** Total kills, kills by breed, kills by weapon type, weakspot kills, headshot kills
- **Damage:** Damage dealt, damage taken, blocked damage
- **Accuracy:** Shots fired, shots missed, accuracy percentage
- **Abilities:** Ability usage, cooldowns, buff activations
- **Survival:** Health segments, toughness, knockdowns, deaths
- **Interactions:** Items picked up/placed, materials collected, objectives completed
- **Class-Specific:** All archetype-specific abilities and keystones

### Team Stats
- **Team Kills:** Total team kills, kills by faction, kills by attack type
- **Bosses:** Boss deaths, boss damage, boss kill time
- **Objectives:** Objective progression, mission completion
- **Events:** Team explosions, special events, mutator events

### Session Management
- Statistics are tracked per player using `user.data` tables
- Team statistics are tracked in `team.data` table
- Statistics can be marked with flags:
  - `backend`: Saved to backend (persistent)
  - `team`: Team-wide statistic
  - `hook`: Event hook (not a calculated stat)
  - `no_sync`: Not synchronized across network
  - `never_log`: Never logged
  - `no_recover`: Not recovered on rejoin

### Statistics Flow
1. **Event occurs** → Game calls `record_private` or `record_team`
2. **Hook triggered** → `_trigger` function processes the hook
3. **Triggers execute** → Stat definitions with matching hook IDs update their values
4. **Listeners notified** → Any registered listeners are called
5. **Network sync** → Stats marked for sync are sent to other clients
6. **Backend save** → Stats marked `backend` are saved when session ends

## Accessing Statistics

To access statistics from other mods, you can use:

```lua
-- Read a user stat
local kills = Managers.stats:read_user_stat(player.stat_id, "total_kills")

-- Read a team stat
local team_kills = Managers.stats:read_team_stat("session_team_kills")

-- Add a listener for stat changes
local listener_id = Managers.stats:add_listener(
    player.stat_id,
    {"total_kills", "accuracy"},
    function(listener_id, stat_name, ...)
        -- Handle stat change
    end
)
```

## Notes

- Statistics are only tracked when a session is active (`has_session() == true`)
- Player statistics are only tracked when the player is in `tracking` state
- Some statistics are calculated from other statistics (e.g., `accuracy` from `shots_fired` and `shots_missed`)
- Statistics marked with `hook` flag are event hooks, not actual stored values
- Statistics marked with `never_log` are not logged but can still be used for triggers
- Statistics marked with `no_sync` are not synchronized across the network

---

# Документация по API статистик Darktide

## Обзор

Darktide использует систему статистики, управляемую `Managers.stats`, для отслеживания различных игровых событий во время миссий. Эта система предоставляет две основные функции для записи статистики: `record_private` (для статистики конкретного игрока) и `record_team` (для командной статистики).

## Функции

### `Managers.stats:record_private(stat_name, player, ...)`

Записывает приватную статистику для конкретного игрока.

**Параметры:**
- `stat_name` (string): Имя статистического хука (например, `"hook_kill"`, `"hook_damage_dealt"`)
- `player` (Player): Объект игрока, для которого записывается статистика
- `...` (varargs): Дополнительные параметры, специфичные для каждого типа статистики

**Использование:**
```lua
Managers.stats:record_private("hook_kill", attacking_player, attack_table)
Managers.stats:record_private("hook_damage_dealt", attacking_player, attack_table)
```

**Примечание:** Функция записывает статистику только если игрок отслеживается (`user.state == UserStates.tracking`).

### `Managers.stats:record_team(stat_name, ...)`

Записывает командную статистику.

**Параметры:**
- `stat_name` (string): Имя статистического хука (например, `"hook_boss_died"`)
- `...` (varargs): Дополнительные параметры, специфичные для каждого типа статистики

**Использование:**
```lua
Managers.stats:record_team("hook_boss_died", breed_name, boss_max_health, boss_unit_id, time_since_first_damage, attack_table)
```

**Примечание:** Функция записывает статистику только если сессия активна (`has_session() == true`).

## Доступные статистики (Хуки событий)

### Боевая статистика

#### `hook_kill`
**Срабатывает когда:** Игрок убивает врага
**Параметры:**
- `player`: Игрок, совершивший убийство
- `attack_table`: Таблица с информацией об атаке:
  - `attacking_unit`: Юнит, который атаковал
  - `attacked_unit`: Юнит, который был убит
  - `target_breed_name`: Имя породы убитого врага
  - `attack_type`: Тип атаки ("melee", "ranged", "explosion")
  - `damage_dealt`: Нанесенный урон
  - `hit_zone_name`: Зона попадания
  - `weapon_template_name`: Имя используемого оружия
  - `is_weakspot_hit`: Попадание ли в слабое место
  - `solo_kill`: Убил ли только один игрок
  - И многие другие поля...

**Используется в:** `scripts/utilities/attack/attack.lua:774`

#### `hook_damage_dealt`
**Срабатывает когда:** Игрок наносит урон любому юниту
**Параметры:**
- `player`: Игрок, нанесший урон
- `attack_table`: Та же структура, что и в `hook_kill`

**Используется в:** `scripts/utilities/attack/attack.lua:771`

#### `hook_damage_taken`
**Срабатывает когда:** Игрок получает урон
**Параметры:**
- `player`: Игрок, получивший урон
- `damage_dealt`: Количество полученного урона
- `attack_type`: Тип атаки ("melee", "ranged" и т.д.)
- `attacker_breed`: Порода атакующего (если применимо)

**Используется в:** `scripts/utilities/attack/attack.lua:812`

#### `hook_blocked_damage`
**Срабатывает когда:** Игрок блокирует урон
**Параметры:**
- `player`: Игрок, который заблокировал
- `weapon_template_name`: Имя оружия, использованного для блока
- `damage_absorbed`: Количество заблокированного урона

**Используется в:** `scripts/utilities/attack/attack.lua:797`

#### `hook_blocked_damage_from_unique_enemy`
**Срабатывает когда:** Игрок блокирует урон от врага в первый раз
**Параметры:**
- `player`: Игрок, который заблокировал
- `weapon_template_name`: Имя оружия, использованного для блока
- `damage_absorbed`: Количество заблокированного урона

**Используется в:** `scripts/utilities/attack/attack.lua:803`

#### `hook_dodged_attack`
**Срабатывает когда:** Игрок уклоняется от атаки
**Параметры:**
- `player`: Игрок, который уклонился
- `attacker_breed_name`: Имя породы атакующего
- `attack_type`: Тип атаки (обычно "ranged")
- `stat_dodge_type`: Тип уклонения
- `attacked_action`: Действие, от которого уклонились
- `previously_dodged`: Уклонялись ли от этого врага ранее
- `dodging_unit_buff_keywords`: Ключевые слова баффов, активных во время уклонения

**Используется в:** `scripts/utilities/attack/hit_scan.lua:185`

#### `hook_melee_kill_toughness_regenerated`
**Срабатывает когда:** Игрок восстанавливает стойкость от ближнего убийства
**Параметры:**
- `player`: Игрок, восстановивший стойкость
- `amount`: Количество восстановленной стойкости

**Используется в:** `scripts/utilities/attack/attack.lua:925`

### Статистика боссов

#### `hook_boss_died` (Командная статистика)
**Срабатывает когда:** Босс убит
**Параметры:**
- `breed_name`: Имя породы босса
- `boss_max_health`: Максимальное здоровье босса
- `boss_unit_id`: ID юнита босса
- `time_since_first_damage`: Время с момента первого урона
- `attack_table`: Таблица информации об атаке

**Используется в:** `scripts/utilities/attack/attack.lua:783`

### Статистика способностей

#### `hook_alternate_fire_start`
**Срабатывает когда:** Игрок начинает использовать альтернативный огонь
**Параметры:**
- `player`: Игрок, начавший альтернативный огонь

**Используется в:** `scripts/utilities/alternate_fire.lua:62`

#### `hook_alternate_fire_stop`
**Срабатывает когда:** Игрок прекращает использовать альтернативный огонь
**Параметры:**
- `player`: Игрок, прекративший альтернативный огонь

**Используется в:** `scripts/utilities/alternate_fire.lua:103`

### Статистика Ветерана (Снайпера)

#### `hook_volley_fire_start`
**Срабатывает когда:** Ветеран активирует способность Залповый огонь
**Параметры:**
- `player`: Игрок-Ветеран

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:43`

#### `hook_volley_fire_stop`
**Срабатывает когда:** Ветеран деактивирует способность Залповый огонь
**Параметры:**
- `player`: Игрок-Ветеран
- `total_time`: Общее время активности Залпового огня

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:59`

#### `hook_veteran_kill_volley_fire_target`
**Срабатывает когда:** Ветеран убивает цель во время Залпового огня
**Параметры:**
- `player`: Игрок-Ветеран

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:67`

#### `hook_veteran_ammo_given`
**Срабатывает когда:** Ветеран дает патроны союзникам
**Параметры:**
- `player`: Игрок-Ветеран
- `ammo_gained`: Количество выданных патронов

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:1529, 1579`

#### `hook_veteran_infiltrate_stagger`
**Срабатывает когда:** Способность Инфильтрация Ветра оглушает врагов
**Параметры:**
- `player`: Игрок-Ветеран
- `number_of_enemies_staggered`: Количество оглушенных врагов

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:1254`

#### `hook_focus_fire_max_stacks`
**Срабатывает когда:** Ветеран достигает максимальных стаков Фокусированного огня
**Параметры:**
- `player`: Игрок-Ветеран

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:2784`

#### `hook_focus_fire_max_reset`
**Срабатывает когда:** Максимальные стаки Фокусированного огня Ветра сбрасываются
**Параметры:**
- `player`: Игрок-Ветеран

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:2788`

#### `hook_veteran_weapon_switch_keystone`
**Срабатывает когда:** Кистоун переключения оружия Ветра активируется
**Параметры:**
- `player`: Игрок-Ветеран
- `params`: Дополнительные параметры

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:3031, 3121`

#### `hook_veteran_improved_tag`
**Срабатывает когда:** Ветеран использует улучшенную метку
**Параметры:**
- `player`: Игрок-Ветеран

**Используется в:** `scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:3282`

### Статистика Зелота (Проповедника)

#### `hook_shroudfield_start`
**Срабатывает когда:** Зелот активирует способность Поле Тени
**Параметры:**
- `player`: Игрок-Зелот

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:43`

#### `hook_shroudfield_stop`
**Срабатывает когда:** Зелот деактивирует способность Поле Тени
**Параметры:**
- `player`: Игрок-Зелот

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:49`

#### `hook_zealot_fanatic_rage_start`
**Срабатывает когда:** Зелот входит в Фанатическую Ярость
**Параметры:**
- `player`: Игрок-Зелот

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:894`

#### `hook_zealot_fanatic_rage_stop`
**Срабатывает когда:** Зелот выходит из Фанатической Ярости
**Параметры:**
- `player`: Игрок-Зелот

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:946`

#### `hook_martyrdom_stacks`
**Срабатывает когда:** Стаки Мученичества Зелота изменяются
**Параметры:**
- `player`: Игрок-Зелот
- `missing_segments`: Количество отсутствующих сегментов здоровья

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:1353`

#### `hook_zealot_engulfed_enemies`
**Срабатывает когда:** Зелот поглощает врагов способностью
**Параметры:**
- `player`: Игрок-Зелот
- `engulfed_enemies`: Количество поглощенных врагов

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:1417`

#### `hook_zealot_movement_keystone_start`
**Срабатывает когда:** Кистоун движения Зелота активируется
**Параметры:**
- `player`: Игрок-Зелот
- `num_child_stacks_removed`: Количество удаленных дочерних стаков
- `achievement_target`: Целевое значение достижения

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:241`

#### `hook_zealot_movement_keystone_stop`
**Срабатывает когда:** Кистоун движения Зелота деактивируется
**Параметры:**
- `player`: Игрок-Зелот

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:203`

#### `hook_zealot_loner_aura`
**Срабатывает когда:** Аура Одиночки Зелота активируется
**Параметры:**
- `player`: Игрок-Зелот

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:3187`

#### `hook_zealot_health_leeched_during_resist_death`
**Срабатывает когда:** Зелот высасывает здоровье во время Сопротивления Смерти
**Параметры:**
- `player`: Игрок-Зелот
- `heal_percentage`: Процент высасанного здоровья

**Используется в:** `scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:3577`

### Статистика Псайкера

#### `hook_overcharge_stance_start`
**Срабатывает когда:** Псайкер входит в стойку Перегрузки
**Параметры:**
- `player`: Игрок-Псайкер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:50`

#### `hook_overcharge_stance_stop`
**Срабатывает когда:** Псайкер выходит из стойки Перегрузки
**Параметры:**
- `player`: Игрок-Псайкер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:56`

#### `hook_psyker_reached_max_souls`
**Срабатывает когда:** Псайкер достигает максимальных стаков душ
**Параметры:**
- `player`: Игрок-Псайкер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:202`

#### `hook_psyker_time_at_max_souls`
**Срабатывает когда:** Псайкер проводит время на максимальных стаках душ
**Параметры:**
- `player`: Игрок-Псайкер
- `time_at_max`: Время на максимальных стаках

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:266`

#### `hook_psyker_lost_max_souls`
**Срабатывает когда:** Псайкер теряет максимальные стаки душ
**Параметры:**
- `player`: Игрок-Псайкер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:280`

#### `hook_psyker_spent_max_unnatural_stack`
**Срабатывает когда:** Псайкер тратит максимальный стак Неестественного
**Параметры:**
- `player`: Игрок-Псайкер
- `rounded_time_value`: Округленное значение времени

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:760`

#### `hook_psyker_empowered_ability`
**Срабатывает когда:** Псайкер использует усиленную способность
**Параметры:**
- `player`: Игрок-Псайкер
- `params`: Дополнительные параметры

**Используется в:** `scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:2476`

### Статистика Огруна

#### `hook_ogryn_heavy_hitter_at_max_stacks`
**Срабатывает когда:** Огрун достигает максимальных стаков Тяжелого Удара
**Параметры:**
- `player`: Игрок-Огрун

**Используется в:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:239`

#### `hook_ogryn_heavy_hitter_at_max_lost`
**Срабатывает когда:** Огрун теряет максимальные стаки Тяжелого Удара
**Параметры:**
- `player`: Игрок-Огрун

**Используется в:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:204`

#### `hook_ogryn_feel_no_pain_kills_at_max`
**Срабатывает когда:** Огрун получает убийства на максимальных стаках Не Чувствую Боли
**Параметры:**
- `player`: Игрок-Огрун

**Используется в:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:669`

#### `hook_ogryn_frag_grenade`
**Срабатывает когда:** Огрун использует осколочную гранату
**Параметры:**
- `player`: Игрок-Огрун

**Используется в:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:1275`

#### `hook_ogryn_barrage_end`
**Срабатывает когда:** Способность Залп Огруна заканчивается
**Параметры:**
- `player`: Игрок-Огрун

**Используется в:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:2021`

#### `hook_ogryn_leadbelcher_free_shot`
**Срабатывает когда:** Огрун получает бесплатный выстрел от Свинцового Жеребца
**Параметры:**
- `player`: Игрок-Огрун

**Используется в:** `scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:2042`

### Статистика Брокера

#### `hook_broker_exited_punk_rage`
**Срабатывает когда:** Брокер выходит из Панк Ярости
**Параметры:**
- `player`: Игрок-Брокер
- `time_spent_in_punk_rage`: Время в Панк Ярости

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:748`

#### `hook_broker_time_ally_buffed_by_stimm_field`
**Срабатывает когда:** Поле стимуляторов Брокера баффает союзника
**Параметры:**
- `player`: Игрок-Брокер (владелец)
- `time_buffed`: Время, в течение которого союзник был под баффом

**Используется в:** `scripts/settings/buff/buff_utils.lua:198`

#### `hook_broker_stack_of_vulture_keystone`
**Срабатывает когда:** Кистоун Стая Стервятников Брокера активируется
**Параметры:**
- `player`: Игрок-Брокер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:2809`

#### `hook_broker_proc_max_stacks_adrenaline_keystone`
**Срабатывает когда:** Брокер процирует максимальные стаки кистоуна Адреналин
**Параметры:**
- `player`: Игрок-Брокер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3104`

#### `hook_broker_exited_max_stacks_of_chemical_dependency`
**Срабатывает когда:** Брокер выходит из максимальных стаков Химической Зависимости
**Параметры:**
- `player`: Игрок-Брокер
- `time_spent_at_max_stacks`: Время на максимальных стаках

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:2984, 3003`

#### `hook_broker_stimm_used`
**Срабатывает когда:** Брокер использует стимулятор
**Параметры:**
- `player`: Игрок-Брокер
- `stimm_stat_increases`: Увеличения статистик от стимулятора
- `target_player`: Игрок, использовавший стимулятор

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3434`

#### `hook_broker_stimm_restored_tougness`
**Срабатывает когда:** Стимулятор Брокера восстанавливает стойкость
**Параметры:**
- `player`: Игрок-Брокер
- `recovered_toughness`: Количество восстановленной стойкости
- `target_player`: Игрок, получивший стойкость

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3232`

#### `hook_broker_cluster_staggered_by_flash_grenade`
**Срабатывает когда:** Световая граната Брокера оглушает группу врагов
**Параметры:**
- `player`: Игрок-Брокер

**Используется в:** `scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3530`

### Статистика Адаманта

#### `hook_adamant_time_enemy_electrocuted_by_shockmine`
**Срабатывает когда:** Враг поражен электричеством от шоковой мины Адаманта
**Параметры:**
- `player`: Игрок-Адамант
- `rounded_time_shocked`: Округленное время поражения электричеством

**Используется в:** `scripts/settings/buff/weapon_buff_templates.lua:487`

#### `hook_adamant_whistle_explosion_stagger_monster`
**Срабатывает когда:** Взрыв свистка Адаманта оглушает монстра
**Параметры:**
- `player`: Игрок-Адамант

**Используется в:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:380`

#### `hook_adamant_killed_cluster_of_enemies_with_grenade`
**Срабатывает когда:** Адамант убивает группу врагов гранатой
**Параметры:**
- `player`: Игрок-Адамант

**Используется в:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:418`

#### `hook_adamant_killed_enemy_marked_by_execution_order`
**Срабатывает когда:** Адамант убивает врага, помеченного Приказом Казни
**Параметры:**
- `player`: Игрок-Адамант

**Используется в:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:1068`

#### `hook_adamant_exited_max_forceful_stacks`
**Срабатывает когда:** Адамант выходит из максимальных стаков Силы
**Параметры:**
- `player`: Игрок-Адамант
- `time_at_max_stacks_rounded`: Округленное время на максимальных стаках

**Используется в:** `scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:1429`

### Статистика Стимуляторов

#### `hook_red_stimm_active`
**Срабатывает когда:** Красный стимулятор активируется
**Параметры:**
- `player`: Игрок, активировавший стимулятор

**Используется в:** `scripts/settings/buff/syringe_buff_templates.lua:259`

#### `hook_red_stimm_deactivated`
**Срабатывает когда:** Красный стимулятор деактивируется
**Параметры:**
- `player`: Игрок, деактивировавший стимулятор

**Используется в:** `scripts/settings/buff/syringe_buff_templates.lua:272`

#### `hook_blue_stimm_active`
**Срабатывает когда:** Синий стимулятор активируется
**Параметры:**
- `player`: Игрок, активировавший стимулятор

**Используется в:** `scripts/settings/buff/syringe_buff_templates.lua:306`

#### `hook_blue_stimm_deactivated`
**Срабатывает когда:** Синий стимулятор деактивируется
**Параметры:**
- `player`: Игрок, деактивировавший стимулятор

**Используется в:** `scripts/settings/buff/syringe_buff_templates.lua:319`

#### `hook_green_stimm_corruption_healed`
**Срабатывает когда:** Зеленый стимулятор лечит порчу
**Параметры:**
- `player`: Игрок, предоставивший стимулятор
- `corruption_heal`: Количество вылеченной порчи

**Используется в:** `scripts/settings/buff/syringe_buff_templates.lua:174`

#### `hook_ability_time_saved_by_yellow_stimm`
**Срабатывает когда:** Желтый стимулятор экономит время способности
**Параметры:**
- `player`: Игрок, использовавший стимулятор
- `time_reduced`: Время, сэкономленное на перезарядке способности

**Используется в:** `scripts/settings/buff/syringe_buff_templates.lua:232`

### Статистика миссий/целей

#### `hook_mission_ended` (Командная статистика)
**Срабатывает когда:** Миссия завершается
**Параметры:** Различаются в зависимости от типа миссии

**Используется в:** Различных скриптах миссий

#### `hook_objective_side_incremented_progression` (Командная статистика)
**Срабатывает когда:** Прогресс побочной цели увеличивается
**Параметры:**
- `objective_name`: Имя цели
- `incremented_progression`: Количество увеличенного прогресса

**Используется в:** `scripts/extension_systems/mission_objective/utilities/mission_objective_side.lua:48`

#### `hook_game_mode_survival_island_completed` (Командная статистика)
**Срабатывает когда:** Остров режима Выживания завершен
**Параметры:**
- `island_number`: Номер завершенного острова

**Используется в:** `scripts/managers/game_mode/game_modes/game_mode_survival.lua:521`

#### `hook_team_explosion` (Командная статистика)
**Срабатывает когда:** Происходит командный взрыв
**Параметры:**
- `explosion_template`: Шаблон взрыва
- `data`: Данные взрыва

**Используется в:** `scripts/extension_systems/weapon/weapon_system.lua:355`

#### `hook_mission_twins_mine_triggered` (Командная статистика)
**Срабатывает когда:** Мина Близнецов активирована
**Параметры:** Нет

**Используется в:** `scripts/extension_systems/projectile_damage/projectile_damage_extension.lua:258`

#### `hook_mission_twins_boss_started_mine_intialized` (Командная статистика)
**Срабатывает когда:** Мина босса Близнецов инициализирована
**Параметры:** Нет

**Используется в:** `scripts/managers/mutator/mutators/mutator_toxic_gas_twins.lua:761`

#### `hook_saint_points_acquired` (Командная статистика)
**Срабатывает когда:** Приобретены очки Святого
**Параметры:**
- `points`: Количество приобретенных очков

**Используется в:** `scripts/managers/mutator/mutators/mutator_gameplay/mutator_gameplay_live_event_saints_simplified.lua:40, 200`

### Другие статистики

#### `hook_player_spawned`
**Срабатывает когда:** Игрок появляется
**Параметры:**
- `player`: Игрок, который появился
- `profile`: Данные профиля игрока

**Используется в:** `scripts/managers/player/player_unit_spawn_manager.lua:228`

#### `hook_ranged_attack_concluded`
**Срабатывает когда:** Дальняя атака завершается
**Параметры:**
- `hit_minion`: Попал ли в миньона
- `hit_weakspot`: Попал ли в слабое место
- `killing_blow`: Был ли это смертельный удар
- `last_round_in_mag`: Был ли это последний патрон в магазине

**Используется в:** Различных скриптах оружия

#### `hook_health_update`
**Срабатывает когда:** Здоровье игрока обновляется
**Параметры:**
- `dt`: Дельта времени
- `remaining_health_segments`: Оставшиеся сегменты здоровья
- `is_knocked_down`: Сбит ли игрок с ног

**Используется в:** Скриптах системы здоровья

#### `hook_knocked_down`
**Срабатывает когда:** Игрок сбит с ног
**Параметры:**
- `player`: Игрок, который был сбит с ног

**Используется в:** Различных скриптах

#### `hook_death`
**Срабатывает когда:** Игрок умирает
**Параметры:**
- `player`: Игрок, который умер

**Используется в:** Различных скриптах

#### `hook_collect_material`
**Срабатывает когда:** Игрок собирает материал
**Параметры:**
- `player`: Игрок, который собрал
- `material_type`: Тип собранного материала

**Используется в:** Различных скриптах

#### `hook_picked_up_item`
**Срабатывает когда:** Игрок поднимает предмет
**Параметры:**
- `player`: Игрок, который поднял
- `item_type`: Тип поднятого предмета

**Используется в:** Различных скриптах

#### `hook_placed_item`
**Срабатывает когда:** Игрок размещает предмет
**Параметры:**
- `player`: Игрок, который разместил
- `item_type`: Тип размещенного предмета

**Используется в:** Различных скриптах

#### `hook_collect_collectible`
**Срабатывает когда:** Игрок собирает коллекционный предмет
**Параметры:**
- `player`: Игрок, который собрал
- `collectible_type`: Тип собранного предмета

**Используется в:** Различных скриптах

#### `hook_team_chest_opened` (Командная статистика)
**Срабатывает когда:** Командный сундук открыт
**Параметры:**
- `chest_type`: Тип открытого сундука

**Используется в:** Различных скриптах

#### `hook_health_station_interaccion_success`
**Срабатывает когда:** Игрок успешно взаимодействует с медицинской станцией
**Параметры:**
- `player`: Игрок, который взаимодействовал

**Используется в:** Различных скриптах

#### `hook_assist_ally`
**Срабатывает когда:** Игрок помогает союзнику
**Параметры:**
- `player`: Игрок, который помог
- `ally`: Союзник, которому помогли

**Используется в:** Различных скриптах

#### `hook_rescue_ally`
**Срабатывает когда:** Игрок спасает союзника
**Параметры:**
- `player`: Игрок, который спас
- `ally`: Союзник, которого спасли

**Используется в:** Различных скриптах

#### `hook_escaped_captivitiy`
**Срабатывает когда:** Игрок сбегает из плена
**Параметры:**
- `player`: Игрок, который сбежал

**Используется в:** Различных скриптах

#### `hook_coherency_update`
**Срабатывает когда:** Когерентность игрока обновляется
**Параметры:**
- `player`: Игрок
- `coherency_data`: Данные когерентности

**Используется в:** Различных скриптах

#### `hook_coherency_toughness_regenerated`
**Срабатывает когда:** Стойкость восстанавливается от когерентности
**Параметры:**
- `player`: Игрок
- `amount`: Количество восстановленной стойкости

**Используется в:** Различных скриптах

#### `hook_toughness_broken`
**Срабатывает когда:** Стойкость игрока пробита
**Параметры:**
- `player`: Игрок, чья стойкость пробита

**Используется в:** Различных скриптах

#### `hook_ammo_consumed`
**Срабатывает когда:** Патроны расходуются
**Параметры:**
- `player`: Игрок
- `amount`: Количество израсходованных патронов

**Используется в:** Различных скриптах

## Что игра отслеживает во время сессии

Игра отслеживает обширный набор статистики во время каждой миссии:

### Статистика игрока (Приватная)
- **Убийства:** Всего убийств, убийства по породам, убийства по типу оружия, убийства в слабое место, убийства в голову
- **Урон:** Нанесенный урон, полученный урон, заблокированный урон
- **Точность:** Выстрелы, промахи, процент точности
- **Способности:** Использование способностей, перезарядки, активации баффов
- **Выживание:** Сегменты здоровья, стойкость, сбивания с ног, смерти
- **Взаимодействия:** Поднятые/размещенные предметы, собранные материалы, выполненные цели
- **Класс-специфичные:** Все способности и кистоуны, специфичные для архетипа

### Командная статистика
- **Командные убийства:** Всего командных убийств, убийства по фракциям, убийства по типу атаки
- **Боссы:** Смерти боссов, урон по боссам, время убийства босса
- **Цели:** Прогресс целей, завершение миссии
- **События:** Командные взрывы, специальные события, события мутаторов

### Управление сессией
- Статистика отслеживается для каждого игрока с использованием таблиц `user.data`
- Командная статистика отслеживается в таблице `team.data`
- Статистика может быть помечена флагами:
  - `backend`: Сохраняется в бэкенд (постоянная)
  - `team`: Командная статистика
  - `hook`: Хук события (не вычисляемая статистика)
  - `no_sync`: Не синхронизируется по сети
  - `never_log`: Никогда не логируется
  - `no_recover`: Не восстанавливается при повторном присоединении

### Поток статистики
1. **Событие происходит** → Игра вызывает `record_private` или `record_team`
2. **Хук срабатывает** → Функция `_trigger` обрабатывает хук
3. **Триггеры выполняются** → Определения статистики с соответствующими ID хуков обновляют свои значения
4. **Слушатели уведомляются** → Вызываются все зарегистрированные слушатели
5. **Синхронизация сети** → Статистика, помеченная для синхронизации, отправляется другим клиентам
6. **Сохранение в бэкенд** → Статистика, помеченная `backend`, сохраняется при завершении сессии

## Доступ к статистике

Для доступа к статистике из других модов можно использовать:

```lua
-- Чтение статистики игрока
local kills = Managers.stats:read_user_stat(player.stat_id, "total_kills")

-- Чтение командной статистики
local team_kills = Managers.stats:read_team_stat("session_team_kills")

-- Добавление слушателя для изменений статистики
local listener_id = Managers.stats:add_listener(
    player.stat_id,
    {"total_kills", "accuracy"},
    function(listener_id, stat_name, ...)
        -- Обработка изменения статистики
    end
)
```

## Примечания

- Статистика отслеживается только когда сессия активна (`has_session() == true`)
- Статистика игрока отслеживается только когда игрок находится в состоянии `tracking`
- Некоторые статистики вычисляются из других статистик (например, `accuracy` из `shots_fired` и `shots_missed`)
- Статистика, помеченная флагом `hook`, является хуком события, а не фактическим сохраненным значением
- Статистика, помеченная флагом `never_log`, не логируется, но все еще может использоваться для триггеров
- Статистика, помеченная флагом `no_sync`, не синхронизируется по сети

