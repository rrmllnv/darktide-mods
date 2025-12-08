-- tab_enemies.lua - Вкладка "Враги"
-- Полный список врагов с категоризацией на основе исходников игры

local TabEnemies = {}

TabEnemies.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}
    
    -- ============================
    -- БОССЫ (is_boss = true)
    -- ============================
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_bosses")})
    
    -- Beast of Nurgle
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_beast_of_nurgle"), 
        value = format_number(safe_read_stat("total_chaos_beast_of_nurgle_killed"))
    })
    
    -- Chaos Spawn
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_spawn"), 
        value = format_number(safe_read_stat("total_chaos_spawn_killed"))
    })
    
    -- Plague Ogryn
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_plage_ogryn"), 
        value = format_number(safe_read_stat("total_chaos_plague_ogryn_killed"))
    })
    
    -- Daemonhost (обычный + mutator)
    local daemonhost = safe_read_stat("total_chaos_daemonhost_killed") + safe_read_stat("total_chaos_mutator_daemonhost_killed")
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_daemonhost"), 
        value = format_number(daemonhost)
    })
    
    -- Renegade Captains
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_captain"), 
        value = format_number(safe_read_stat("total_renegade_captain_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_twin_captain"), 
        value = format_number(safe_read_stat("total_renegade_twin_captain_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_twin_captain_two"), 
        value = format_number(safe_read_stat("total_renegade_twin_captain_two_killed"))
    })
    
    -- Cultist Captain
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_captain"), 
        value = format_number(safe_read_stat("total_cultist_captain_killed"))
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    -- ============================
    -- 🛡️ ЭЛИТЫ (tags.elite = true)
    -- ============================
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_elites")})
    
    -- Chaos Ogryn Elites
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_ogryn_gunner"), 
        value = format_number(safe_read_stat("total_chaos_ogryn_gunner_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_ogryn_executor"), 
        value = format_number(safe_read_stat("total_chaos_ogryn_executor_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_ogryn_bulwark"), 
        value = format_number(safe_read_stat("total_chaos_ogryn_bulwark_killed"))
    })
    
    -- Renegade Elites
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_shocktrooper"), 
        value = format_number(safe_read_stat("total_renegade_shocktrooper_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_plasma_gunner"), 
        value = format_number(safe_read_stat("total_renegade_plasma_gunner_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_radio_operator"), 
        value = format_number(safe_read_stat("total_renegade_radio_operator_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_gunner"), 
        value = format_number(safe_read_stat("total_renegade_gunner_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_executor"), 
        value = format_number(safe_read_stat("total_renegade_executor_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_berzerker"), 
        value = format_number(safe_read_stat("total_renegade_berzerker_killed"))
    })
    
    -- Cultist Elites
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_shocktrooper"), 
        value = format_number(safe_read_stat("total_cultist_shocktrooper_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_gunner"), 
        value = format_number(safe_read_stat("total_cultist_gunner_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_berzerker"), 
        value = format_number(safe_read_stat("total_cultist_berzerker_killed"))
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    -- ============================
    -- ⚡ СПЕЦИАЛИСТЫ (tags.special = true)
    -- ============================
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_specials")})
    
    -- Poxburster
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_poxwalker_bomber"), 
        value = format_number(safe_read_stat("total_chaos_poxwalker_bomber_killed"))
    })
    
    -- Hound (обычный + mutator)
    local hound = safe_read_stat("total_chaos_hound_killed") + safe_read_stat("total_chaos_hound_mutator_killed")
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_hound"), 
        value = format_number(hound)
    })
    
    -- Mutant (обычный + mutator)
    local mutant = safe_read_stat("total_cultist_mutant_killed") + safe_read_stat("total_cultist_mutant_mutator_killed")
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_mutant"), 
        value = format_number(mutant)
    })
    
    -- Renegade Flamer (обычный + mutator)
    local renegade_flamer = safe_read_stat("total_renegade_flamer_killed") + 
                            safe_read_stat("total_renegade_flamer_mutator_killed")
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_flamer"), 
        value = format_number(renegade_flamer)
    })
    
    -- Renegade Grenadier
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_grenadier"), 
        value = format_number(safe_read_stat("total_renegade_grenadier_killed"))
    })
        
    -- Sniper
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_sniper"), 
        value = format_number(safe_read_stat("total_renegade_sniper_killed"))
    })
    
    -- Netgunner
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_netgunner"), 
        value = format_number(safe_read_stat("total_renegade_netgunner_killed"))
    })

    -- Cultist Flamer
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_flamer"), 
        value = format_number(safe_read_stat("total_cultist_flamer_killed"))
    })

    -- Cultist Grenadier
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_grenadier"), 
        value = format_number(safe_read_stat("total_cultist_grenadier_killed"))
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    -- ============================
    -- 👥 ROAMERS (базовые враги)
    -- ============================
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_roamers")})
    
    -- Renegade Roamers
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_rifleman"), 
        value = format_number(safe_read_stat("total_renegade_rifleman_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_melee"), 
        value = format_number(safe_read_stat("total_renegade_melee_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_renegade_assault"), 
        value = format_number(safe_read_stat("total_renegade_assault_killed"))
    })
    
    -- Cultist Roamers
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_melee"), 
        value = format_number(safe_read_stat("total_cultist_melee_killed"))
    })
    
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_cultist_assault"), 
        value = format_number(safe_read_stat("total_cultist_assault_killed"))
    })

    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})

    -- ============================
    -- 🧟 ОРДА (tags.horde = true)
    -- ============================
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_horde")})
    
    -- Poxwalker (все виды)
    local poxwalker = safe_read_stat("total_chaos_poxwalker_killed") + 
                      safe_read_stat("total_chaos_mutated_poxwalker_killed") + 
                      safe_read_stat("total_chaos_lesser_mutated_poxwalker_killed")
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_poxwalker"), 
        value = format_number(poxwalker)
    })
    
    -- Newly Infected
    table.insert(layout, {
        widget_type = "stat_line", 
        text = localize("loc_breed_display_name_chaos_newly_infected"), 
        value = format_number(safe_read_stat("total_chaos_newly_infected_killed"))
    })
    
    return layout
end

return TabEnemies
