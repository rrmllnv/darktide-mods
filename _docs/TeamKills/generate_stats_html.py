#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to parse stat_definitions.lua and generate HTML table with filters
"""

import re
import json
from pathlib import Path

# Map of hook names to their usage locations (from stats_api.md)
HOOK_USAGE = {
    "hook_kill": "scripts/utilities/attack/attack.lua:774",
    "hook_damage_dealt": "scripts/utilities/attack/attack.lua:771",
    "hook_damage_taken": "scripts/utilities/attack/attack.lua:812",
    "hook_blocked_damage": "scripts/utilities/attack/attack.lua:797",
    "hook_blocked_damage_from_unique_enemy": "scripts/utilities/attack/attack.lua:803",
    "hook_dodged_attack": "scripts/utilities/attack/hit_scan.lua:185",
    "hook_melee_kill_toughness_regenerated": "scripts/utilities/attack/attack.lua:925",
    "hook_boss_died": "scripts/utilities/attack/attack.lua:783",
    "hook_alternate_fire_start": "scripts/utilities/alternate_fire.lua:62",
    "hook_alternate_fire_stop": "scripts/utilities/alternate_fire.lua:103",
    "hook_volley_fire_start": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:43",
    "hook_volley_fire_stop": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:59",
    "hook_veteran_kill_volley_fire_target": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:67",
    "hook_veteran_ammo_given": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:1529, 1579",
    "hook_veteran_infiltrate_stagger": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:1254",
    "hook_focus_fire_max_stacks": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:2784",
    "hook_focus_fire_max_reset": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:2788",
    "hook_veteran_weapon_switch_keystone": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:3031, 3121",
    "hook_veteran_improved_tag": "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates.lua:3282",
    "hook_shroudfield_start": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:43",
    "hook_shroudfield_stop": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:49",
    "hook_zealot_fanatic_rage_start": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:894",
    "hook_zealot_fanatic_rage_stop": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:946",
    "hook_martyrdom_stacks": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:1353",
    "hook_zealot_engulfed_enemies": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:1417",
    "hook_zealot_movement_keystone_start": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:241",
    "hook_zealot_movement_keystone_stop": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:203",
    "hook_zealot_loner_aura": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:3187",
    "hook_zealot_health_leeched_during_resist_death": "scripts/settings/buff/archetype_buff_templates/zealot_buff_templates.lua:3577",
    "hook_overcharge_stance_start": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:50",
    "hook_overcharge_stance_stop": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:56",
    "hook_psyker_reached_max_souls": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:202",
    "hook_psyker_time_at_max_souls": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:266",
    "hook_psyker_lost_max_souls": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:280",
    "hook_psyker_spent_max_unnatural_stack": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:760",
    "hook_psyker_empowered_ability": "scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua:2476",
    "hook_ogryn_heavy_hitter_at_max_stacks": "scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:239",
    "hook_ogryn_heavy_hitter_at_max_lost": "scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:204",
    "hook_ogryn_feel_no_pain_kills_at_max": "scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:669",
    "hook_ogryn_frag_grenade": "scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:1275",
    "hook_ogryn_barrage_end": "scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:2021",
    "hook_ogryn_leadbelcher_free_shot": "scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua:2042",
    "hook_broker_exited_punk_rage": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:748",
    "hook_broker_time_ally_buffed_by_stimm_field": "scripts/settings/buff/buff_utils.lua:198",
    "hook_broker_stack_of_vulture_keystone": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:2809",
    "hook_broker_proc_max_stacks_adrenaline_keystone": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3104",
    "hook_broker_exited_max_stacks_of_chemical_dependency": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:2984, 3003",
    "hook_broker_stimm_used": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3434",
    "hook_broker_stimm_restored_tougness": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3232",
    "hook_broker_cluster_staggered_by_flash_grenade": "scripts/settings/buff/archetype_buff_templates/broker_buff_templates.lua:3530",
    "hook_adamant_time_enemy_electrocuted_by_shockmine": "scripts/settings/buff/weapon_buff_templates.lua:487",
    "hook_adamant_whistle_explosion_stagger_monster": "scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:380",
    "hook_adamant_killed_cluster_of_enemies_with_grenade": "scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:418",
    "hook_adamant_killed_enemy_marked_by_execution_order": "scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:1068",
    "hook_adamant_exited_max_forceful_stacks": "scripts/settings/buff/archetype_buff_templates/adamant_buff_templates.lua:1429",
    "hook_red_stimm_active": "scripts/settings/buff/syringe_buff_templates.lua:259",
    "hook_red_stimm_deactivated": "scripts/settings/buff/syringe_buff_templates.lua:272",
    "hook_blue_stimm_active": "scripts/settings/buff/syringe_buff_templates.lua:306",
    "hook_blue_stimm_deactivated": "scripts/settings/buff/syringe_buff_templates.lua:319",
    "hook_green_stimm_corruption_healed": "scripts/settings/buff/syringe_buff_templates.lua:174",
    "hook_ability_time_saved_by_yellow_stimm": "scripts/settings/buff/syringe_buff_templates.lua:232",
    "hook_player_spawned": "scripts/managers/player/player_unit_spawn_manager.lua:228",
    "hook_objective_side_incremented_progression": "scripts/extension_systems/mission_objective/utilities/mission_objective_side.lua:48",
    "hook_game_mode_survival_island_completed": "scripts/managers/game_mode/game_modes/game_mode_survival.lua:521",
    "hook_team_explosion": "scripts/extension_systems/weapon/weapon_system.lua:355",
    "hook_mission_twins_mine_triggered": "scripts/extension_systems/projectile_damage/projectile_damage_extension.lua:258",
    "hook_mission_twins_boss_started_mine_intialized": "scripts/managers/mutator/mutators/mutator_toxic_gas_twins.lua:761",
    "hook_saint_points_acquired": "scripts/managers/mutator/mutators/mutator_gameplay/mutator_gameplay_live_event_saints_simplified.lua:40, 200",
}

# Archetype detection patterns
ARCHETYPE_PATTERNS = {
    "veteran": ["veteran", "volley_fire", "focus_fire", "infiltrate", "voice_of_command"],
    "zealot": ["zealot", "shroudfield", "fanatic_rage", "martyrdom", "chorus"],
    "psyker": ["psyker", "overcharge", "souls", "chain_lightning", "perils"],
    "ogryn": ["ogryn", "heavy_hitter", "feel_no_pain", "barrage", "leadbelcher"],
    "broker": ["broker", "punk_rage", "stimm", "vulture", "adrenaline", "chemical_dependency"],
    "adamant": ["adamant", "companion", "shockmine", "whistle", "execution_order", "forceful"],
}

def detect_archetype(stat_id):
    """Detect archetype from stat ID"""
    stat_lower = stat_id.lower()
    for archetype, patterns in ARCHETYPE_PATTERNS.items():
        if any(pattern in stat_lower for pattern in patterns):
            return archetype
    return None

def find_matching_brace(content, start_pos):
    """Find the matching closing brace for an opening brace"""
    brace_count = 1
    pos = start_pos
    in_string = False
    string_char = None
    
    while pos < len(content) and brace_count > 0:
        char = content[pos]
        
        # Handle string literals
        if not in_string and (char == '"' or char == "'"):
            in_string = True
            string_char = char
        elif in_string and char == string_char:
            # Check for escaped quote
            if pos > 0 and content[pos-1] != '\\':
                in_string = False
                string_char = None
        
        if not in_string:
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
        
        pos += 1
    
    if brace_count == 0:
        return pos - 1
    return None

def parse_stat_definitions(file_path):
    """Parse stat_definitions.lua file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    stats = []
    
    # Pattern to match both stat_definitions.stat_name and stat_definitions["stat_name"] and stat_definitions[stat_name]
    patterns = [
        r'stat_definitions\.([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z0-9_]+)*)\s*=\s*\{',
        r'stat_definitions\[["\']([^"\']+)["\']\]\s*=\s*\{',
        r'stat_definitions\[([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z0-9_]+)*)\]\s*=\s*\{',
    ]
    
    all_matches = []
    for pattern in patterns:
        matches = list(re.finditer(pattern, content))
        all_matches.extend(matches)
    
    # Sort by position to process in order
    all_matches.sort(key=lambda m: m.start())
    
    for match in all_matches:
        stat_id = match.group(1)
        start_pos = match.end()
        
        # Find matching closing brace
        end_pos = find_matching_brace(content, start_pos)
        
        if end_pos:
            stat_body = content[start_pos:end_pos]
            
            # Extract flags
            flags = []
            flag_pattern = r'StatFlags\.([a-zA-Z_]+)'
            flag_matches = re.findall(flag_pattern, stat_body)
            flags = flag_matches
            
            # Extract triggers
            triggers = []
            # Look for triggers array
            triggers_pattern = r'triggers\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
            triggers_match = re.search(triggers_pattern, stat_body, re.DOTALL)
            if triggers_match:
                triggers_content = triggers_match.group(1)
                trigger_id_pattern = r'id\s*=\s*["\']([^"\']+)["\']'
                trigger_matches = re.findall(trigger_id_pattern, triggers_content)
                triggers = trigger_matches
            
            # Extract data fields
            data_fields = []
            data_pattern = r'data\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
            data_match = re.search(data_pattern, stat_body, re.DOTALL)
            if data_match:
                data_content = data_match.group(1)
                # Extract key-value pairs (simplified)
                kv_pattern = r'([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([^,\n}]+)'
                kv_matches = re.findall(kv_pattern, data_content)
                data_fields = [f"{k}: {v.strip()[:50]}" for k, v in kv_matches if len(v.strip()) < 100]
            
            # Extract default value
            default = None
            default_pattern = r'default\s*=\s*([^,\n}]+)'
            default_match = re.search(default_pattern, stat_body)
            if default_match:
                default = default_match.group(1).strip()[:50]
            
            # Determine if it's a hook
            is_hook = 'hook' in flags or stat_id.startswith('hook_')
            
            # Determine if it's team stat
            is_team = 'team' in flags
            
            # Determine archetype
            archetype = detect_archetype(stat_id)
            
            # Get usage location
            usage = HOOK_USAGE.get(stat_id, "")
            
            stat_info = {
                'id': stat_id,
                'flags': flags,
                'triggers': triggers,
                'data_fields': data_fields,
                'default': default,
                'is_hook': is_hook,
                'is_team': is_team,
                'archetype': archetype,
                'usage': usage,
            }
            
            stats.append(stat_info)
    
    return stats

def generate_html(stats):
    """Generate HTML file with table and filters"""
    
    # Get unique flags
    all_flags = set()
    for stat in stats:
        all_flags.update(stat['flags'])
    all_flags = sorted(list(all_flags))
    
    # Get unique archetypes
    all_archetypes = set()
    for stat in stats:
        if stat['archetype']:
            all_archetypes.add(stat['archetype'])
    all_archetypes = sorted(list(all_archetypes))
    
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Darktide Statistics Reference</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #1a1a1a;
            color: #e0e0e0;
            padding: 20px;
        }}
        
        .container {{
            max-width: 1800px;
            margin: 0 auto;
        }}
        
        h1 {{
            color: #ff6b35;
            margin-bottom: 20px;
            text-align: center;
        }}
        
        .filters {{
            background: #2a2a2a;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }}
        
        .filter-group {{
            display: flex;
            flex-direction: column;
        }}
        
        .filter-group label {{
            color: #ff6b35;
            margin-bottom: 5px;
            font-weight: bold;
        }}
        
        .filter-group input,
        .filter-group select {{
            padding: 8px;
            background: #3a3a3a;
            color: #e0e0e0;
            border: 1px solid #555;
            border-radius: 4px;
            font-size: 14px;
        }}
        
        .filter-group input:focus,
        .filter-group select:focus {{
            outline: none;
            border-color: #ff6b35;
        }}
        
        .filter-group input[type="checkbox"] {{
            width: auto;
            margin-right: 5px;
        }}
        
        .checkbox-group {{
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 5px;
        }}
        
        .checkbox-item {{
            display: flex;
            align-items: center;
        }}
        
        .stats-count {{
            background: #2a2a2a;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
            text-align: center;
            color: #ff6b35;
            font-weight: bold;
        }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
            background: #2a2a2a;
            border-radius: 8px;
            overflow: hidden;
        }}
        
        thead {{
            background: #ff6b35;
            color: #1a1a1a;
            position: sticky;
            top: 0;
            z-index: 10;
        }}
        
        th {{
            padding: 12px;
            text-align: left;
            font-weight: bold;
            cursor: pointer;
            user-select: none;
        }}
        
        th:hover {{
            background: #ff8c5a;
        }}
        
        th.sort-asc::after {{
            content: " ▲";
        }}
        
        th.sort-desc::after {{
            content: " ▼";
        }}
        
        tbody tr {{
            border-bottom: 1px solid #3a3a3a;
        }}
        
        tbody tr:hover {{
            background: #333;
        }}
        
        tbody tr.hidden {{
            display: none;
        }}
        
        td {{
            padding: 10px;
            vertical-align: top;
        }}
        
        .stat-id {{
            font-family: 'Courier New', monospace;
            color: #4ec9b0;
            font-weight: bold;
        }}
        
        .flags {{
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
        }}
        
        .flag {{
            background: #3a3a3a;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            color: #e0e0e0;
        }}
        
        .flag.backend {{
            background: #4a9eff;
            color: #fff;
        }}
        
        .flag.team {{
            background: #ff6b35;
            color: #fff;
        }}
        
        .flag.hook {{
            background: #9d4edd;
            color: #fff;
        }}
        
        .flag.no_sync {{
            background: #ffaa00;
            color: #000;
        }}
        
        .flag.never_log {{
            background: #666;
            color: #fff;
        }}
        
        .flag.no_recover {{
            background: #ff4444;
            color: #fff;
        }}
        
        .archetype {{
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            text-transform: capitalize;
        }}
        
        .archetype.veteran {{
            background: #4a9eff;
            color: #fff;
        }}
        
        .archetype.zealot {{
            background: #ff6b35;
            color: #fff;
        }}
        
        .archetype.psyker {{
            background: #9d4edd;
            color: #fff;
        }}
        
        .archetype.ogryn {{
            background: #4ec9b0;
            color: #000;
        }}
        
        .archetype.broker {{
            background: #ffaa00;
            color: #000;
        }}
        
        .archetype.adamant {{
            background: #00ff88;
            color: #000;
        }}
        
        .type-badge {{
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: bold;
        }}
        
        .type-badge.team {{
            background: #ff6b35;
            color: #fff;
        }}
        
        .type-badge.private {{
            background: #4a9eff;
            color: #fff;
        }}
        
        .triggers {{
            font-size: 12px;
            color: #aaa;
        }}
        
        .usage {{
            font-size: 11px;
            color: #888;
            font-family: 'Courier New', monospace;
        }}
        
        .data-fields {{
            font-size: 11px;
            color: #aaa;
            font-family: 'Courier New', monospace;
        }}
        
        .default-value {{
            font-size: 11px;
            color: #4ec9b0;
            font-family: 'Courier New', monospace;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Darktide Statistics Reference</h1>
        <p style="text-align: center; color: #aaa; margin-bottom: 20px;">
            Complete reference of all statistics tracked by Darktide's StatsManager system.<br>
            Filter by flags, type, archetype, or search by ID.
        </p>
        
        <div class="filters">
            <div class="filter-group">
                <label for="search-id">Search by ID:</label>
                <input type="text" id="search-id" placeholder="Enter stat ID...">
            </div>
            
            <div class="filter-group">
                <label>Type:</label>
                <select id="filter-type">
                    <option value="">All</option>
                    <option value="team">Team</option>
                    <option value="private">Private</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Archetype:</label>
                <select id="filter-archetype">
                    <option value="">All</option>
                    <option value="veteran">Veteran</option>
                    <option value="zealot">Zealot</option>
                    <option value="psyker">Psyker</option>
                    <option value="ogryn">Ogryn</option>
                    <option value="broker">Broker</option>
                    <option value="adamant">Adamant</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Flags:</label>
                <div class="checkbox-group">
                    <div class="checkbox-item">
                        <input type="checkbox" id="flag-backend" value="backend">
                        <label for="flag-backend">Backend</label>
                    </div>
                    <div class="checkbox-item">
                        <input type="checkbox" id="flag-team" value="team">
                        <label for="flag-team">Team</label>
                    </div>
                    <div class="checkbox-item">
                        <input type="checkbox" id="flag-hook" value="hook">
                        <label for="flag-hook">Hook</label>
                    </div>
                    <div class="checkbox-item">
                        <input type="checkbox" id="flag-no_sync" value="no_sync">
                        <label for="flag-no_sync">No Sync</label>
                    </div>
                    <div class="checkbox-item">
                        <input type="checkbox" id="flag-never_log" value="never_log">
                        <label for="flag-never_log">Never Log</label>
                    </div>
                    <div class="checkbox-item">
                        <input type="checkbox" id="flag-no_recover" value="no_recover">
                        <label for="flag-no_recover">No Recover</label>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="stats-count" id="stats-count">Total: {len(stats)} statistics</div>
        
        <table id="stats-table">
            <thead>
                <tr>
                    <th data-sort="id">ID</th>
                    <th data-sort="type">Type</th>
                    <th data-sort="archetype">Archetype</th>
                    <th data-sort="flags">Flags</th>
                    <th>Triggers</th>
                    <th>Data Fields</th>
                    <th>Default</th>
                    <th>Usage</th>
                </tr>
            </thead>
            <tbody>
"""
    
    for stat in stats:
        stat_type = "Team" if stat['is_team'] else "Private"
        archetype_html = f'<span class="archetype {stat["archetype"]}">{stat["archetype"]}</span>' if stat['archetype'] else '-'
        
        flags_html = '<div class="flags">'
        for flag in stat['flags']:
            flags_html += f'<span class="flag {flag}">{flag}</span>'
        flags_html += '</div>'
        
        triggers_html = '<div class="triggers">' + '<br>'.join([f'• {t}' for t in stat['triggers']]) + '</div>' if stat['triggers'] else '-'
        
        data_fields_html = '<div class="data-fields">' + '<br>'.join([f'• {f}' for f in stat['data_fields']]) + '</div>' if stat['data_fields'] else '-'
        
        default_html = f'<span class="default-value">{stat["default"]}</span>' if stat['default'] else '-'
        
        usage_html = f'<span class="usage">{stat["usage"]}</span>' if stat['usage'] else '-'
        
        html += f"""
                <tr data-id="{stat['id']}" data-type="{stat_type.lower()}" data-archetype="{stat['archetype'] or ''}" data-flags="{','.join(stat['flags'])}">
                    <td class="stat-id">{stat['id']}</td>
                    <td><span class="type-badge {stat_type.lower()}">{stat_type}</span></td>
                    <td>{archetype_html}</td>
                    <td>{flags_html}</td>
                    <td class="triggers">{triggers_html}</td>
                    <td>{data_fields_html}</td>
                    <td>{default_html}</td>
                    <td>{usage_html}</td>
                </tr>
"""
    
    html += """
            </tbody>
        </table>
    </div>
    
    <script>
        const table = document.getElementById('stats-table');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        const searchInput = document.getElementById('search-id');
        const filterType = document.getElementById('filter-type');
        const filterArchetype = document.getElementById('filter-archetype');
        const statsCount = document.getElementById('stats-count');
        
        let currentSort = { column: null, direction: 'asc' };
        
        // Filter function
        function filterRows() {
            const searchValue = searchInput.value.toLowerCase();
            const typeValue = filterType.value.toLowerCase();
            const archetypeValue = filterArchetype.value.toLowerCase();
            
            // Get checked flags
            const checkedFlags = Array.from(document.querySelectorAll('input[type="checkbox"]:checked')).map(cb => cb.value);
            
            let visibleCount = 0;
            
            rows.forEach(row => {
                const id = row.dataset.id.toLowerCase();
                const type = row.dataset.type;
                const archetype = row.dataset.archetype.toLowerCase();
                const flags = row.dataset.flags.split(',').filter(f => f);
                
                let visible = true;
                
                // Search filter
                if (searchValue && !id.includes(searchValue)) {
                    visible = false;
                }
                
                // Type filter
                if (typeValue && type !== typeValue) {
                    visible = false;
                }
                
                // Archetype filter
                if (archetypeValue && archetype !== archetypeValue) {
                    visible = false;
                }
                
                // Flags filter
                if (checkedFlags.length > 0) {
                    const hasAnyFlag = checkedFlags.some(flag => flags.includes(flag));
                    if (!hasAnyFlag) {
                        visible = false;
                    }
                }
                
                if (visible) {
                    row.classList.remove('hidden');
                    visibleCount++;
                } else {
                    row.classList.add('hidden');
                }
            });
            
            statsCount.textContent = `Showing: ${visibleCount} / ${rows.length} statistics`;
        }
        
        // Sort function
        function sortTable(column) {
            const isAsc = currentSort.column === column && currentSort.direction === 'asc';
            currentSort = { column, direction: isAsc ? 'desc' : 'asc' };
            
            const sortedRows = Array.from(rows).sort((a, b) => {
                let aVal, bVal;
                
                switch(column) {
                    case 'id':
                        aVal = a.dataset.id.toLowerCase();
                        bVal = b.dataset.id.toLowerCase();
                        break;
                    case 'type':
                        aVal = a.dataset.type;
                        bVal = b.dataset.type;
                        break;
                    case 'archetype':
                        aVal = a.dataset.archetype || '';
                        bVal = b.dataset.archetype || '';
                        break;
                    case 'flags':
                        aVal = a.dataset.flags.split(',').length;
                        bVal = b.dataset.flags.split(',').length;
                        break;
                    default:
                        return 0;
                }
                
                if (aVal < bVal) return isAsc ? -1 : 1;
                if (aVal > bVal) return isAsc ? 1 : -1;
                return 0;
            });
            
            // Clear sort indicators
            table.querySelectorAll('th').forEach(th => {
                th.classList.remove('sort-asc', 'sort-desc');
            });
            
            // Add sort indicator
            const header = table.querySelector(`th[data-sort="${column}"]`);
            if (header) {
                header.classList.add(isAsc ? 'sort-asc' : 'sort-desc');
            }
            
            // Reorder rows
            sortedRows.forEach(row => tbody.appendChild(row));
        }
        
        // Event listeners
        searchInput.addEventListener('input', filterRows);
        filterType.addEventListener('change', filterRows);
        filterArchetype.addEventListener('change', filterRows);
        document.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            cb.addEventListener('change', filterRows);
        });
        
        // Sort on header click
        table.querySelectorAll('th[data-sort]').forEach(th => {
            th.addEventListener('click', () => {
                sortTable(th.dataset.sort);
            });
        });
        
        // Initial filter
        filterRows();
    </script>
</body>
</html>
"""
    
    return html

def main():
    """Main function"""
    script_dir = Path(__file__).parent
    # Try multiple possible paths
    possible_paths = [
        script_dir / "GlobalStat" / "stat_definitions.lua",
        script_dir.parent / "GlobalStat" / "stat_definitions.lua",
        script_dir.parent.parent / "_docs" / "GlobalStat" / "stat_definitions.lua",
    ]
    
    stat_def_file = None
    for path in possible_paths:
        if path.exists():
            stat_def_file = path
            break
    
    if not stat_def_file:
        print(f"Error: stat_definitions.lua not found. Tried:")
        for path in possible_paths:
            print(f"  - {path}")
        return
    
    print(f"Parsing {stat_def_file}...")
    stats = parse_stat_definitions(stat_def_file)
    print(f"Found {len(stats)} statistics")
    
    print("Generating HTML...")
    html = generate_html(stats)
    
    output_file = script_dir / "stats_reference.html"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"HTML file generated: {output_file}")

if __name__ == "__main__":
    main()

