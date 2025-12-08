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
    local other_kills = total_kills - (renegade_kills + cultist_kills + chaos_kills + barrel_kills + poxburster_kills + companion_pounce_kills + companion_coherency_kills)

    table.insert(layout, {widget_type = "stat_line", text = localize("stats_total_kills"), value = format_number(total_kills)})
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_renegade_kills"), value = format_number(renegade_kills)})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_cultist_kills"), value = format_number(cultist_kills)})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_chaos_kills"), value = format_number(chaos_kills)})
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_barrel_kills"), value = format_number(barrel_kills)})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_poxburster_explosion_kills"), value = format_number(poxburster_kills)})

    if companion_pounce_kills > 0 then
        table.insert(layout, {widget_type = "stat_line", text = localize("stats_companion_pounce_kills"), value = format_number(companion_pounce_kills)})
    end

    if companion_coherency_kills > 0 then
        table.insert(layout, {widget_type = "stat_line", text = localize("stats_companion_coherency_kills"), value = format_number(companion_coherency_kills)})
    end

    if other_kills > 0 then
        table.insert(layout, {widget_type = "stat_line", text = localize("stats_other_kills"), value = format_number(other_kills)})
    end

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_player_rescues"), value = format_number(safe_read_stat("total_player_rescues"))})
    table.insert(layout, {widget_type = "stat_line", text = localize("stats_player_assists"), value = format_number(safe_read_stat("total_player_assists"))})
    
    --table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_sprint_dodges"), value = format_number(safe_read_stat("total_sprint_dodges"))})
    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_slide_dodges"), value = format_number(safe_read_stat("total_slide_dodges"))})

    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_coherency_toughness"), value = format_number(safe_read_stat("total_coherency_toughness"))})
    --table.insert(layout, {widget_type = "stat_line", text = localize("stats_melee_toughness_regen"), value = format_number(safe_read_stat("total_melee_toughness_regen"))})

    return layout
end

return TabGeneral

