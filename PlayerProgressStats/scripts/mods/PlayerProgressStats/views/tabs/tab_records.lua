-- tab_records.lua - Вкладка "Рекорды"

local TabRecords = {}

TabRecords.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}

    -- Боевые рекорды
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_records_combat")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_headshots"),
        value = format_number(safe_read_stat("max_head_shot_in_a_row")),
        description = Localize("loc_achievement_consecutive_headshots_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_kills_60s"),
        value = format_number(safe_read_stat("max_kills_last_60_sec")),
        description = Localize("loc_achievement_fast_enemies_x_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_headshots_10s"),
        value = format_number(safe_read_stat("max_head_shot_kills_last_10_sec")),
        description = Localize("loc_achievement_fast_headshot_x_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_focus_fire_kills"),
        value = format_number(safe_read_stat("kills_during_max_focus_fire_stack")),
        description = Localize("loc_achievement_veteran_enemies_killed_with_max_focus_fire_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_elite_special_volley"),
        value = format_number(safe_read_stat("max_multiple_elite_or_special_kills_during_volley_fire_heresy")),
        description = Localize("loc_achievement_veteran_2_hard_1_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_smite_elite_special"),
        value = format_number(safe_read_stat("max_elite_or_special_kills_with_smite_last_12_sec")),
        description = Localize("loc_achievement_psyker_2_elite_or_special_kills_with_smite_last_10_sec_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_smite_boss_damage"),
        value = format_number(safe_read_stat("max_smite_damage_done_to_boss")),
        description = Localize("loc_achievement_psyker_2_kill_boss_solo_with_smite_description"),
    })

    local fastest_boss = safe_read_stat("fastest_boss_kill")
    if fastest_boss > 0 and fastest_boss < 18000 then
        table.insert(layout, {
            widget_type = "stat_line_with_description",
            text = localize("stats_fastest_boss_kill"),
            value = format_number(fastest_boss) .. "s",
            description = Localize("loc_achievement_boss_fast_x_description"),
        })
    end

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})

    -- Оборона / командные
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_records_defense")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_dodges_record"),
        value = format_number(safe_read_stat("max_dodges_in_a_row")),
        description = Localize("loc_achievement_consecutive_dodge_x_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_damage_blocked_20s"),
        value = format_number(safe_read_stat("max_damage_blocked_last_20_sec")),
        description = Localize("loc_achievement_fast_blocks_x_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_team_poxburster_avoided"),
        value = format_number(safe_read_stat("team_poxburster_damage_avoided")),
        description = Localize("loc_achievement_team_poxburster_damage_avoided_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_grenadier_before_attack"),
        value = format_number(safe_read_stat("grenadier_killed_before_attack_occurred")),
        description = Localize("loc_achievement_grenadier_killed_before_attack_occurred_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_flamer_before_attack"),
        value = format_number(safe_read_stat("flamer_killed_before_attack_occurred")),
        description = Localize("loc_achievement_flamer_killed_before_attack_occurred_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_bullwark_backstab_damage"),
        value = format_number(safe_read_stat("bulwark_backstab_damage_inflicted")),
        description = Localize("loc_achievement_bulwark_backstab_damage_inflicted_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_team_chaos_spawn_clean"),
        value = format_number(safe_read_stat("team_chaos_spawned_killed_no_players_grabbed")),
        description = Localize("loc_achievement_team_chaos_spawned_killed_no_players_grabbed_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_team_beast_clean"),
        value = format_number(safe_read_stat("team_chaos_beast_of_nurgle_slain_no_corruption")),
        description = Localize("loc_achievement_team_chaos_beast_of_nurgle_slain_no_corruption_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_max_different_players_rescued"),
        value = format_number(safe_read_stat("max_different_players_rescued")),
        description = Localize("loc_achievement_revive_all_description"),
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    -- Рекорды миссий
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_mission_records")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_lowest_damage_taken"),
        value = format_number(safe_read_stat("lowest_damage_taken_on_win") or 0),
        description = Localize("loc_achievement_mission_no_damage_description")
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})

    -- Класс: Veteran
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_records_veteran")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_vet_max_weakspot_hits_volley"),
        value = format_number(safe_read_stat("max_weakspot_hit_during_volley_fire_alternate_fire")),
        description = Localize("loc_achievement_veteran_2_weakspot_hits_during_volley_fire_alternate_fire_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_vet_max_elite_weakspot_volley"),
        value = format_number(safe_read_stat("max_elite_weakspot_kill_during_volley_fire_alternate_fire")),
        description = Localize("loc_achievement_veteran_2_elite_weakspot_kills_during_volley_fire_alternate_fire_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_vet_max_last_round_kills"),
        value = format_number(safe_read_stat("max_veteran_2_kills_with_last_round_in_mag")),
        description = Localize("loc_achievement_veteran_2_kills_with_last_round_in_mag_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_vet_min_melee_damage_taken"),
        value = format_number(safe_read_stat("veteran_min_melee_damage_taken")),
        description = Localize("loc_achievement_veteran_2_no_melee_damage_taken_description"),
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})

    -- Класс: Zealot
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_records_zealot")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_zealot_stagger_sniper_distance"),
        value = format_number(safe_read_stat("max_zealot_2_stagger_sniper_with_grenade_distance")),
        description = Localize("loc_achievement_zealot_2_stagger_sniper_with_grenade_distance_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_zealot_kills_shocked_15s"),
        value = format_number(safe_read_stat("max_zealot_2_kills_of_shocked_enemies_last_15")),
        description = Localize("loc_achievement_zealot_2_kills_of_shocked_enemies_last_15_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_zealot_heal_leech_resist"),
        value = format_number(safe_read_stat("max_zealot_2_health_healed_with_leech_during_resist_death")),
        description = Localize("loc_achievement_zealot_2_healed_up_after_resisting_death_description"),
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})

    -- Класс: Psyker
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_records_psyker")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_psyker_edge_kills_2s"),
        value = format_number(safe_read_stat("max_psyker_2_edge_kills_last_2_sec")),
        description = Localize("loc_achievement_psyker_2_edge_kills_last_2_sec_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_psyker_time_max_souls"),
        value = format_number(safe_read_stat("max_psyker_2_time_at_max_souls")),
        description = Localize("loc_achievement_psyker_2_stay_at_max_souls_for_duration_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_psyker_kills_overcharge"),
        value = format_number(safe_read_stat("max_psyker_kills_during_overcharge_stance")),
        description = Localize("loc_achievement_psyker_kills_during_overcharge_stance_description"),
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    -- Класс: Ogryn
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_records_ogryn")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_ogryn_lunge_hits"),
        value = format_number(safe_read_stat("max_ogryn_2_lunge_number_of_enemies_hit")),
        description = Localize("loc_achievement_ogryn_2_bull_rushed_100_enemies_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_ogryn_lunge_distance"),
        value = format_number(safe_read_stat("max_ogryn_2_lunge_distance_last_x_seconds")),
        description = Localize("loc_achievement_ogryn_2_bull_rushed_70_within_25_seconds_description"),
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_ogryn_bullrushed"),
        value = format_number(safe_read_stat("max_ogryns_bullrushed")),
        description = Localize("loc_achievement_ogryn_2_bull_rushed_4_ogryns_description"),
    })

    return layout
end

return TabRecords

