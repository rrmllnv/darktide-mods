local TabEnemies = {}

TabEnemies.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_bosses")})
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_beast_of_nurgle"), 
        value = format_number(safe_read_stat("total_chaos_beast_of_nurgle_killed")),
        text_key = "loc_breed_display_name_chaos_beast_of_nurgle",
        stat_name = "total_chaos_beast_of_nurgle_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_spawn"), 
        value = format_number(safe_read_stat("total_chaos_spawn_killed")),
        text_key = "loc_breed_display_name_chaos_spawn",
        stat_name = "total_chaos_spawn_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_plage_ogryn"), 
        value = format_number(safe_read_stat("total_chaos_plague_ogryn_killed")),
        text_key = "loc_breed_display_name_chaos_plage_ogryn",
        stat_name = "total_chaos_plague_ogryn_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_plage_ogryn") .. " (" .. localize("sprayer") .. ")", 
        value = format_number(safe_read_stat("total_chaos_plague_ogryn_sprayer_killed")),
        text_key = "loc_breed_display_name_chaos_plage_ogryn",
        stat_name = "total_chaos_plague_ogryn_sprayer_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_daemonhost"), 
        value = format_number(safe_read_stat("total_chaos_daemonhost_killed")),
        text_key = "loc_breed_display_name_chaos_daemonhost",
        stat_name = "total_chaos_daemonhost_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_daemonhost") .. " (" .. localize("mutator") .. ")", 
        value = format_number(safe_read_stat("total_chaos_mutator_daemonhost_killed")),
        text_key = "loc_breed_display_name_chaos_daemonhost",
        stat_name = "total_chaos_mutator_daemonhost_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_captain"), 
        value = format_number(safe_read_stat("total_renegade_captain_killed")),
        text_key = "loc_breed_display_name_renegade_captain",
        stat_name = "total_renegade_captain_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_twin_captain"), 
        value = format_number(safe_read_stat("total_renegade_twin_captain_killed")),
        text_key = "loc_breed_display_name_renegade_twin_captain",
        stat_name = "total_renegade_twin_captain_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_twin_captain_two"), 
        value = format_number(safe_read_stat("total_renegade_twin_captain_two_killed")),
        text_key = "loc_breed_display_name_renegade_twin_captain_two",
        stat_name = "total_renegade_twin_captain_two_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_captain"), 
        value = format_number(safe_read_stat("total_cultist_captain_killed")),
        text_key = "loc_breed_display_name_cultist_captain",
        stat_name = "total_cultist_captain_killed",
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_elites")})
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_ogryn_gunner"), 
        value = format_number(safe_read_stat("total_chaos_ogryn_gunner_killed")),
        text_key = "loc_breed_display_name_chaos_ogryn_gunner",
        stat_name = "total_chaos_ogryn_gunner_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_ogryn_executor"), 
        value = format_number(safe_read_stat("total_chaos_ogryn_executor_killed")),
        text_key = "loc_breed_display_name_chaos_ogryn_executor",
        stat_name = "total_chaos_ogryn_executor_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_ogryn_bulwark"), 
        value = format_number(safe_read_stat("total_chaos_ogryn_bulwark_killed")),
        text_key = "loc_breed_display_name_chaos_ogryn_bulwark",
        stat_name = "total_chaos_ogryn_bulwark_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_shocktrooper"), 
        value = format_number(safe_read_stat("total_renegade_shocktrooper_killed")),
        text_key = "loc_breed_display_name_renegade_shocktrooper",
        stat_name = "total_renegade_shocktrooper_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_plasma_gunner"), 
        value = format_number(safe_read_stat("total_renegade_plasma_gunner_killed")),
        text_key = "loc_breed_display_name_renegade_plasma_gunner",
        stat_name = "total_renegade_plasma_gunner_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_radio_operator"), 
        value = format_number(safe_read_stat("total_renegade_radio_operator_killed")),
        text_key = "loc_breed_display_name_renegade_radio_operator",
        stat_name = "total_renegade_radio_operator_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_gunner"), 
        value = format_number(safe_read_stat("total_renegade_gunner_killed")),
        text_key = "loc_breed_display_name_renegade_gunner",
        stat_name = "total_renegade_gunner_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_executor"), 
        value = format_number(safe_read_stat("total_renegade_executor_killed")),
        text_key = "loc_breed_display_name_renegade_executor",
        stat_name = "total_renegade_executor_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_berzerker"), 
        value = format_number(safe_read_stat("total_renegade_berzerker_killed")),
        text_key = "loc_breed_display_name_renegade_berzerker",
        stat_name = "total_renegade_berzerker_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_shocktrooper"), 
        value = format_number(safe_read_stat("total_cultist_shocktrooper_killed")),
        text_key = "loc_breed_display_name_cultist_shocktrooper",
        stat_name = "total_cultist_shocktrooper_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_gunner"), 
        value = format_number(safe_read_stat("total_cultist_gunner_killed")),
        text_key = "loc_breed_display_name_cultist_gunner",
        stat_name = "total_cultist_gunner_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_berzerker"), 
        value = format_number(safe_read_stat("total_cultist_berzerker_killed")),
        text_key = "loc_breed_display_name_cultist_berzerker",
        stat_name = "total_cultist_berzerker_killed",
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_specials")})
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_poxwalker_bomber"), 
        value = format_number(safe_read_stat("total_chaos_poxwalker_bomber_killed")),
        text_key = "loc_breed_display_name_chaos_poxwalker_bomber",
        stat_name = "total_chaos_poxwalker_bomber_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_hound"), 
        value = format_number(safe_read_stat("total_chaos_hound_killed")),
        text_key = "loc_breed_display_name_chaos_hound",
        stat_name = "total_chaos_hound_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_hound") .. " (" .. localize("mutator") .. ")", 
        value = format_number(safe_read_stat("total_chaos_hound_mutator_killed")),
        text_key = "loc_breed_display_name_chaos_hound",
        stat_name = "total_chaos_hound_mutator_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_mutant"), 
        value = format_number(safe_read_stat("total_cultist_mutant_killed")),
        text_key = "loc_breed_display_name_cultist_mutant",
        stat_name = "total_cultist_mutant_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_mutant") .. " (" .. localize("mutator") .. ")", 
        value = format_number(safe_read_stat("total_cultist_mutant_mutator_killed")),
        text_key = "loc_breed_display_name_cultist_mutant",
        stat_name = "total_cultist_mutant_mutator_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_flamer"), 
        value = format_number(safe_read_stat("total_renegade_flamer_killed")),
        text_key = "loc_breed_display_name_renegade_flamer",
        stat_name = "total_renegade_flamer_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_flamer") .. " (" .. localize("mutator") .. ")", 
        value = format_number(safe_read_stat("total_renegade_flamer_mutator_killed")),
        text_key = "loc_breed_display_name_renegade_flamer",
        stat_name = "total_renegade_flamer_mutator_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_grenadier"), 
        value = format_number(safe_read_stat("total_renegade_grenadier_killed")),
        text_key = "loc_breed_display_name_renegade_grenadier",
        stat_name = "total_renegade_grenadier_killed",
    })
        
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_sniper"), 
        value = format_number(safe_read_stat("total_renegade_sniper_killed")),
        text_key = "loc_breed_display_name_renegade_sniper",
        stat_name = "total_renegade_sniper_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_netgunner"), 
        value = format_number(safe_read_stat("total_renegade_netgunner_killed")),
        text_key = "loc_breed_display_name_renegade_netgunner",
        stat_name = "total_renegade_netgunner_killed",
    })

    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_flamer"), 
        value = format_number(safe_read_stat("total_cultist_flamer_killed")),
        text_key = "loc_breed_display_name_cultist_flamer",
        stat_name = "total_cultist_flamer_killed",
    })

    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_grenadier"), 
        value = format_number(safe_read_stat("total_cultist_grenadier_killed")),
        text_key = "loc_breed_display_name_cultist_grenadier",
        stat_name = "total_cultist_grenadier_killed",
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_roamers")})
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_rifleman"), 
        value = format_number(safe_read_stat("total_renegade_rifleman_killed")),
        text_key = "loc_breed_display_name_renegade_rifleman",
        stat_name = "total_renegade_rifleman_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_melee"), 
        value = format_number(safe_read_stat("total_renegade_melee_killed")),
        text_key = "loc_breed_display_name_renegade_melee",
        stat_name = "total_renegade_melee_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_assault"), 
        value = format_number(safe_read_stat("total_renegade_assault_killed")),
        text_key = "loc_breed_display_name_renegade_assault",
        stat_name = "total_renegade_assault_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_melee"), 
        value = format_number(safe_read_stat("total_cultist_melee_killed")),
        text_key = "loc_breed_display_name_cultist_melee",
        stat_name = "total_cultist_melee_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_assault"), 
        value = format_number(safe_read_stat("total_cultist_assault_killed")),
        text_key = "loc_breed_display_name_cultist_assault",
        stat_name = "total_cultist_assault_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_ritualist"), 
        value = format_number(safe_read_stat("total_cultist_ritualist_killed")),
        text_key = "loc_breed_display_name_cultist_ritualist",
        stat_name = "total_cultist_ritualist_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_ritualist") .. " (" .. localize("mutator") .. ")", 
        value = format_number(safe_read_stat("total_chaos_mutator_ritualist_killed")),
        text_key = "loc_breed_display_name_cultist_ritualist",
        stat_name = "total_chaos_mutator_ritualist_killed",
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})

    table.insert(layout, {widget_type = "stat_header", text = localize("stats_horde")})
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_poxwalker"), 
        value = format_number(safe_read_stat("total_chaos_poxwalker_killed")),
        text_key = "loc_breed_display_name_chaos_poxwalker",
        stat_name = "total_chaos_poxwalker_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_poxwalker") .. " (" .. localize("mutated") .. ")", 
        value = format_number(safe_read_stat("total_chaos_mutated_poxwalker_killed")),
        text_key = "loc_breed_display_name_chaos_poxwalker",
        stat_name = "total_chaos_mutated_poxwalker_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_poxwalker") .. " (" .. localize("lesser_mutated") .. ")", 
        value = format_number(safe_read_stat("total_chaos_lesser_mutated_poxwalker_killed")),
        text_key = "loc_breed_display_name_chaos_poxwalker",
        stat_name = "total_chaos_lesser_mutated_poxwalker_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_chaos_armored_infected_breed_name"), 
        value = format_number(safe_read_stat("total_chaos_armored_infected_killed")),
        text_key = "loc_chaos_armored_infected_breed_name",
        stat_name = "total_chaos_armored_infected_killed",
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_newly_infected"), 
        value = format_number(safe_read_stat("total_chaos_newly_infected_killed")),
        text_key = "loc_breed_display_name_chaos_newly_infected",
        stat_name = "total_chaos_newly_infected_killed",
    })
    
    return layout
end

return TabEnemies
