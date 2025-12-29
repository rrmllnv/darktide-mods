TEAMKILLS MOD - VERSION 2.0.0
A comprehensive mod for Warhammer 40,000: Darktide that tracks team statistics including kills, damage, killstreaks, and boss damage in real-time.

:: REQUIREMENTS ::
• Darktide Mod Framework (DMF)
• Warhammer 40,000: Darktide (up to date)

:: FEATURES ::
• Real-time team statistics tracking
• Three HUD trackers (Team Kills, Shot Tracker, Boss Damage)
• Full-screen tactical overlay with detailed statistics
• Killstreak system with configurable difficulty
• Boss death notifications with damage breakdown
• Tracks 46 enemy types across 7 categories
• API for integration with other mods
• Highly customizable (colors, fonts, opacity, display modes)

:: COMPATIBILITY ::
⚠ IMPORTANT: If you previously used TeamKillTracker mod, you MUST completely remove it before installing TeamKills.
These mods are incompatible and cannot work simultaneously.

:: API DOCUMENTATION ::

This mod provides an API for other mods to access team statistics data.

USAGE EXAMPLE:
```lua
local teamkills_mod = get_mod("TeamKills")
if teamkills_mod then
    -- For reading data (fast, no copying):
    local player_kills_readonly = teamkills_mod.get_player_kills_readonly()
    
    -- For modifying data (safe, with deep copy):
    local player_kills = teamkills_mod.get_player_kills()
    
    -- Get data for specific player
    local player_data = teamkills_mod.get_player_data(account_id)
    
    -- Get all data
    local all_data = teamkills_mod.get_all_data()
end
```

NOTE: All functions have two versions:
• Standard version (e.g., get_player_kills()) - Returns a deep copy of the data (safe for modification)
• Readonly version (e.g., get_player_kills_readonly()) - Returns direct reference to data (faster, but read-only)

:: API FUNCTIONS ::

♦ get_player_kills() / get_player_kills_readonly()
Returns all player kills data.
• Returns: table - {account_id = kills_count, ...}

♦ get_player_damage() / get_player_damage_readonly()
Returns all player damage data.
• Returns: table - {account_id = damage_amount, ...}

♦ get_player_last_damage() / get_player_last_damage_readonly()
Returns all player last damage data.
• Returns: table - {account_id = last_damage_amount, ...}

♦ get_kills_by_category() / get_kills_by_category_readonly()
Returns kills by category for all players.
• Returns: table - {account_id = {breed_name = count, ...}, ...}

♦ get_damage_by_category() / get_damage_by_category_readonly()
Returns damage by category for all players.
• Returns: table - {account_id = {breed_name = damage, ...}, ...}

♦ get_player_killstreak() / get_player_killstreak_readonly()
Returns all player killstreak data.
• Returns: table - {account_id = killstreak_count, ...}

♦ get_boss_damage() / get_boss_damage_readonly()
Returns boss damage data.
• Returns: table - {boss_unit = {account_id = damage, ...}, ...}

♦ get_boss_last_damage() / get_boss_last_damage_readonly()
Returns last damage to bosses.
• Returns: table - {boss_unit = {account_id = last_damage, ...}, ...}

♦ get_player_data(account_id)
Returns all data for a specific player.
• Parameters:
  - account_id (string) - Player account ID
• Returns: table - Player data object containing:
  - kills (number) - Total kills
  - damage (number) - Total damage
  - last_damage (number) - Last damage dealt
  - killstreak (number) - Current killstreak
  - kills_by_category (table) - Kills by breed category
  - damage_by_category (table) - Damage by breed category
• Note: Returns empty structure if account_id is invalid

♦ get_all_data()
Returns all mod data in a single table.
• Returns: table - Object containing all available data:
  - player_kills (table)
  - player_damage (table)
  - player_last_damage (table)
  - kills_by_category (table)
  - damage_by_category (table)
  - player_killstreak (table)
  - boss_damage (table)
  - boss_last_damage (table)

♦ get_version()
Returns the mod version.
• Returns: string - Mod version (e.g., "2.0.0")

:: API NOTES ::
• All standard API functions return deep copies of data to prevent modification of original data
• All _readonly functions return direct references for better performance, but should not be modified
• All functions are safe to call even if data doesn't exist yet (returns empty tables or default structures)
• The account_id parameter should be the player's account ID or name
• Use _readonly functions when you only need to read data for better performance
• Use standard functions when you need to modify returned data

:: HUD TRACKERS ::

♦ Team Kills Tracker
Main panel showing team summary and individual player statistics: kills, total damage, last damage, and active killstreaks.
• 4 display modes: All players / Only me / All except me / Hide all
• Auto-sorts players by kills, then by damage
• Dynamic panel height
• Customizable colors for each stat type
• Adjustable font size (15-30)
• Configurable transparency (0-100%)

♦ Shot Tracker
Tracks shooting statistics for local player only.
• Shots Fired - Total number of shots
• Shots Missed - Number of missed shots
• Headshot Kills - Kills with headshots
• Uses icons for visual display
• Only shown during missions (not in hub)

♦ Boss Damage Tracker
Integrates into boss health bar showing damage per player in real-time.
• Damage per player with percentage distribution
• Last damage dealt by each player
• Sorts players by damage (highest to lowest)
• Supports multiple bosses simultaneously

:: KILLSTREAK BOARD ::

Full-screen tactical overlay with detailed statistics by enemy categories.
• Shows localized enemy names
• Kills and damage per player per enemy type (46 enemy types)
• Highlights active killstreaks
• Auto-opens after mission completion
• Toggleable with hotkey
• Organized into 7 categories:
  - Bosses
  - Ranged Elites
  - Melee Elites
  - Specials
  - Disablers
  - Ranged Lessers
  - Melee Lessers

:: NOTIFICATIONS ::

♦ Boss Death Notification
Detailed notification upon boss kill showing:
• Who killed the boss (with last hit information)
• Total team damage
• Top damage player with percentage contribution
• Full damage list for all players with percentages
• Color-coded by player class

:: KILLSTREAK SYSTEM ::

• Starts with first kill
• Each new kill extends the timer
• If no kill within time limit - streak ends
• Three difficulty levels:
  - Recruit: 4 seconds between kills
  - Veteran: 2.5 seconds (default)
  - Ruthless: 1 second
• Configurable minimum display threshold (1-50 kills)
• Default shows from 2 kills
• Tracks kills and damage per enemy category during streak

:: TRACKED ENEMY TYPES ::

♦ Melee Lessers (8 types)
chaos_newly_infected, chaos_poxwalker, chaos_mutated_poxwalker, chaos_armored_infected, 
cultist_melee, cultist_ritualist, chaos_mutator_ritualist, renegade_melee

♦ Ranged Lessers (4 types)
chaos_lesser_mutated_poxwalker, cultist_assault, renegade_assault, renegade_rifleman

♦ Melee Elites (5 types)
cultist_berzerker, renegade_berzerker, renegade_executor, chaos_ogryn_bulwark, chaos_ogryn_executor

♦ Ranged Elites (7 types)
cultist_gunner, renegade_gunner, renegade_plasma_gunner, renegade_radio_operator, 
cultist_shocktrooper, renegade_shocktrooper, chaos_ogryn_gunner

♦ Specials (7 types)
chaos_poxwalker_bomber, renegade_grenadier, cultist_grenadier, renegade_sniper, 
renegade_flamer, renegade_flamer_mutator, cultist_flamer

♦ Disablers (5 types)
chaos_hound, chaos_hound_mutator, cultist_mutant, cultist_mutant_mutator, renegade_netgunner

♦ Bosses (10 types)
chaos_beast_of_nurgle, chaos_daemonhost, chaos_mutator_daemonhost, chaos_spawn, 
chaos_plague_ogryn, chaos_plague_ogryn_sprayer, renegade_captain, cultist_captain, 
renegade_twin_captain, renegade_twin_captain_two

Total: 46 enemy types across 7 categories

:: CUSTOMIZATION OPTIONS ::

♦ Display Settings
• Display modes: All players / Only me / All except me / Hide all
• Show/hide kills
• Show/hide total damage
• Show/hide last damage
• Show/hide team summary

♦ Visual Settings
• 16 color presets for kills, damage, and last damage:
  white, red, green, blue, yellow, orange, purple, cyan,
  teal, gold, purple_deep, magenta, orange_dark, orange_medium, amber, grey
• Font size (15-30)
• Background opacity (0-100%)
• Show/hide background panels

♦ Killstreak Settings
• Show/hide killstreaks
• Difficulty levels (affects timer): Recruit/Veteran/Ruthless
• Minimum display threshold (1-50)

♦ Boss Damage Settings
• Show/hide boss damage tracker
• Show/hide total damage
• Show/hide last damage

♦ Shot Tracker Settings
• Show/hide shot count
• Show/hide missed shots
• Show/hide headshots

♦ Notification Settings
• Show/hide boss death notifications
• Show/hide killer name
• Show/hide last damage
• Show/hide total damage
• Show/hide top damage player

♦ Killsboard Settings
• Enable/disable board
• Hotkey configuration
• Auto-show after mission
• Highlight own killstreaks
• Highlight team killstreaks
• Show killstreak progress

:: PERFORMANCE ::
• Player list caching (updates every 0.1 seconds)
• Localization caching
• Optimized readonly API for high-performance reads
• Hash table for O(1) breed validation
• No impact on game performance during combat

:: TECHNICAL DETAILS ::

♦ Hooks Used
• AttackReportManager.add_attack_result - Tracks damage and kills
• StatsManager.record_private - Tracks shots
• HudElementBossHealth - Integrates boss damage tracker
• EndView - Auto-displays statistics after mission

♦ Data Management
• Saves statistics on End View transition
• Clears data on hub entry
• Resets on new mission start

♦ UI Integration
• Dynamic HUD elements
• Custom View for killstreak board
• Integration with notification system
• Positioning relative to EndPlayerView

