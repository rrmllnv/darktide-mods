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
    local other_kills = total_kills - (renegade_kills + cultist_kills + chaos_kills + barrel_kills + poxburster_kills + companion_pounce_kills + companion_coherency_kills + red_stimm_kills + blue_stimm_kills + grenadier_killed_before_attack + flamer_killed_before_attack)

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

