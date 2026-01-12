-- tab_general.lua - Вкладка "Общее"

local TabGeneral = {}

TabGeneral.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}
    
    local total_kills = safe_read_stat("total_kills")
    local renegade_kills = safe_read_stat("total_renegade_kills")
    local cultist_kills = safe_read_stat("total_cultist_kills")
    local chaos_kills = safe_read_stat("total_chaos_kills")
    local barrel_kills = safe_read_stat("enemies_killed_with_barrels")
    local poxburster_kills = safe_read_stat("enemies_killed_with_poxburster_explosion")
    local companion_pounce_kills = safe_read_stat("adamant_killed_enemies_pounced_by_companion")
    local companion_coherency_kills = safe_read_stat("adamant_team_companion_in_coherency_kills")
    local red_stimm_kills = safe_read_stat("total_kills_gained_while_using_red_stimm")
    local blue_stimm_kills = safe_read_stat("total_kills_gained_while_using_blue_stimm")
    local grenadier_killed_before_attack = safe_read_stat("grenadier_killed_before_attack_occurred")
    local flamer_killed_before_attack = safe_read_stat("flamer_killed_before_attack_occurred")
    local electrocuted_kills = safe_read_stat("adamant_killed_electrocuted_enemies")
    local stance_kills = safe_read_stat("adamant_enemies_killed_during_stance")
    local melee_terminus_kills = safe_read_stat("adamant_melee_kills_with_terminus_warrant")
    local ranged_terminus_kills = safe_read_stat("adamant_ranged_kills_with_terminus_warrant")
    local kill_climbing = safe_read_stat("kill_climbing")
    local kills_during_max_focus_fire = safe_read_stat("kills_during_max_focus_fire_stack")
    local veteran_krak_grenade_kills = safe_read_stat("veteran_krak_grenade_kills")
    local ogryn_heavy_hitter_kills = safe_read_stat("ogryn_kills_during_max_stacks_heavy_hitter")
    local broker_missile_kills = safe_read_stat("broker_enemies_killed_by_missile_launcher")
    local broker_focus_kills = safe_read_stat("broker_enemies_killed_with_focus_mode")
    local broker_stimm_heavy_kills = safe_read_stat("broker_stimm_heavy_attack_kills")
    local other_kills = total_kills - (renegade_kills + cultist_kills + chaos_kills + barrel_kills + poxburster_kills + companion_pounce_kills + companion_coherency_kills + red_stimm_kills + blue_stimm_kills + grenadier_killed_before_attack + flamer_killed_before_attack + electrocuted_kills + stance_kills + melee_terminus_kills + ranged_terminus_kills + kill_climbing + kills_during_max_focus_fire + veteran_krak_grenade_kills + ogryn_heavy_hitter_kills + broker_missile_kills + broker_focus_kills + broker_stimm_heavy_kills)

    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_total_kills"),
        value = format_number(total_kills),
        text_key = "stats_total_kills",
        stat_name = "total_kills",
    })
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_renegade_kills"),
        value = format_number(renegade_kills),
        text_key = "stats_renegade_kills",
        stat_name = "total_renegade_kills",
    })
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_cultist_kills"),
        value = format_number(cultist_kills),
        text_key = "stats_cultist_kills",
        stat_name = "total_cultist_kills",
    })
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_chaos_kills"),
        value = format_number(chaos_kills),
        text_key = "stats_chaos_kills",
        stat_name = "total_chaos_kills",
    })
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_barrel_kills"),
        value = format_number(barrel_kills),
        text_key = "stats_barrel_kills",
        stat_name = "enemies_killed_with_barrels",
    })
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_poxburster_explosion_kills"),
        value = format_number(poxburster_kills),
        text_key = "stats_poxburster_explosion_kills",
        stat_name = "enemies_killed_with_poxburster_explosion",
    })

    if companion_pounce_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_companion_pounce_kills"),
            value = format_number(companion_pounce_kills),
            text_key = "stats_companion_pounce_kills",
            stat_name = "adamant_killed_enemies_pounced_by_companion",
        })
    end

    if companion_coherency_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_companion_coherency_kills"),
            value = format_number(companion_coherency_kills),
            text_key = "stats_companion_coherency_kills",
            stat_name = "adamant_team_companion_in_coherency_kills",
        })
    end

    if red_stimm_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_red_stimm_kills"),
            value = format_number(red_stimm_kills),
            text_key = "stats_red_stimm_kills",
            stat_name = "total_kills_gained_while_using_red_stimm",
        })
    end

    if blue_stimm_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_blue_stimm_kills"),
            value = format_number(blue_stimm_kills),
            text_key = "stats_blue_stimm_kills",
            stat_name = "total_kills_gained_while_using_blue_stimm",
        })
    end

    if grenadier_killed_before_attack > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_grenadier_killed_before_attack"),
            value = format_number(grenadier_killed_before_attack),
            text_key = "stats_grenadier_killed_before_attack",
            stat_name = "grenadier_killed_before_attack_occurred",
        })
    end

    if flamer_killed_before_attack > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_flamer_killed_before_attack"),
            value = format_number(flamer_killed_before_attack),
            text_key = "stats_flamer_killed_before_attack",
            stat_name = "flamer_killed_before_attack_occurred",
        })
    end

    if electrocuted_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_electrocuted_kills"),
            value = format_number(electrocuted_kills),
            text_key = "stats_electrocuted_kills",
            stat_name = "adamant_killed_electrocuted_enemies",
        })
    end

    if stance_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_stance_kills"),
            value = format_number(stance_kills),
            text_key = "stats_stance_kills",
            stat_name = "adamant_enemies_killed_during_stance",
        })
    end

    if melee_terminus_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_melee_terminus_kills"),
            value = format_number(melee_terminus_kills),
            text_key = "stats_melee_terminus_kills",
            stat_name = "adamant_melee_kills_with_terminus_warrant",
        })
    end

    if ranged_terminus_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_ranged_terminus_kills"),
            value = format_number(ranged_terminus_kills),
            text_key = "stats_ranged_terminus_kills",
            stat_name = "adamant_ranged_kills_with_terminus_warrant",
        })
    end

    if kill_climbing > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_kill_climbing"),
            value = format_number(kill_climbing),
            text_key = "stats_kill_climbing",
            stat_name = "kill_climbing",
        })
    end

    if kills_during_max_focus_fire > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_kills_during_max_focus_fire"),
            value = format_number(kills_during_max_focus_fire),
            text_key = "stats_kills_during_max_focus_fire",
            stat_name = "kills_during_max_focus_fire_stack",
        })
    end

    if veteran_krak_grenade_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_veteran_krak_grenade_kills"),
            value = format_number(veteran_krak_grenade_kills),
            text_key = "stats_veteran_krak_grenade_kills",
            stat_name = "veteran_krak_grenade_kills",
        })
    end

    if ogryn_heavy_hitter_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_ogryn_heavy_hitter_kills"),
            value = format_number(ogryn_heavy_hitter_kills),
            text_key = "stats_ogryn_heavy_hitter_kills",
            stat_name = "ogryn_kills_during_max_stacks_heavy_hitter",
        })
    end

    if broker_missile_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_broker_missile_kills"),
            value = format_number(broker_missile_kills),
            text_key = "stats_broker_missile_kills",
            stat_name = "broker_enemies_killed_by_missile_launcher",
        })
    end

    if broker_focus_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_broker_focus_kills"),
            value = format_number(broker_focus_kills),
            text_key = "stats_broker_focus_kills",
            stat_name = "broker_enemies_killed_with_focus_mode",
        })
    end

    if broker_stimm_heavy_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_broker_stimm_heavy_kills"),
            value = format_number(broker_stimm_heavy_kills),
            text_key = "stats_broker_stimm_heavy_kills",
            stat_name = "broker_stimm_heavy_attack_kills",
        })
    end

    if other_kills > 0 then
        table.insert(layout, {
            widget_type = "stat_line",
            text = localize("stats_other_kills"),
            value = format_number(other_kills),
            text_key = "stats_other_kills",
            stat_name = nil,
        })
    end

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_player_rescues"),
        value = format_number(safe_read_stat("total_player_rescues")),
        text_key = "stats_player_rescues",
        stat_name = "total_player_rescues",
    })
    table.insert(layout, {
        widget_type = "stat_line",
        text = localize("stats_player_assists"),
        value = format_number(safe_read_stat("total_player_assists")),
        text_key = "stats_player_assists",
        stat_name = "total_player_assists",
    })
    
    --table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_sprint_dodges"), value = format_number(safe_read_stat("total_sprint_dodges"))})
    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_slide_dodges"), value = format_number(safe_read_stat("total_slide_dodges"))})

    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_coherency_toughness"), value = format_number(safe_read_stat("total_coherency_toughness"))})
    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_melee_toughness_regen"), value = format_number(safe_read_stat("total_melee_toughness_regen"))})

    return layout
end

return TabGeneral

