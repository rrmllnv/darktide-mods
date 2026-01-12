local TabLocalizationDebug = {}

local test_localization_keys = {

    -- "loc_achievement_enemies_killed_by_barrels_name",
    -- "loc_achievement_enemies_killed_by_barrels_description",
    -- "loc_achievement_enemies_killed_by_poxburster_name",
    -- "loc_achievement_enemies_killed_by_poxburster_description",

    "loc_breed_display_name_chaos_hound",
    "loc_breed_display_name_chaos_hound", -- mutator
    "loc_breed_display_name_chaos_lesser_mutated_poxwalker",
    "loc_breed_display_name_chaos_mutated_poxwalker",
    "loc_breed_display_name_chaos_newly_infected",
    "loc_breed_display_name_chaos_ogryn_bulwark",
    "loc_breed_display_name_chaos_ogryn_executor",
    "loc_breed_display_name_chaos_ogryn_gunner",
    "loc_breed_display_name_chaos_plage_ogryn",
    "loc_breed_display_name_chaos_poxwalker_bomber",
    "loc_breed_display_name_chaos_poxwalker",

    "loc_breed_display_name_cultist_ritualist",
    "loc_breed_display_name_cultist_assault",
    "loc_breed_display_name_cultist_berzerker",
    "loc_breed_display_name_cultist_captain",
    "loc_breed_display_name_cultist_flamer",
    "loc_breed_display_name_cultist_grenadier",
    "loc_breed_display_name_cultist_gunner",
    "loc_breed_display_name_cultist_melee",
    "loc_breed_display_name_cultist_mutant",
    "loc_breed_display_name_cultist_mutant", -- mutator
    "loc_breed_display_name_cultist_ritualist", -- mutator
    "loc_breed_display_name_cultist_shocktrooper",


    "loc_breed_display_name_renegade_assault",
    "loc_breed_display_name_renegade_berzerker",
    "loc_breed_display_name_renegade_captain",
    "loc_breed_display_name_renegade_executor",
    "loc_breed_display_name_renegade_flamer",
    "loc_breed_display_name_renegade_flamer", -- mutator
    "loc_breed_display_name_renegade_grenadier",
    "loc_breed_display_name_renegade_gunner",
    "loc_breed_display_name_renegade_melee",
    "loc_breed_display_name_renegade_netgunner",
    "loc_breed_display_name_renegade_plasma_gunner",
    "loc_breed_display_name_renegade_radio_operator",
    "loc_breed_display_name_renegade_rifleman",
    "loc_breed_display_name_renegade_shocktrooper",
    "loc_breed_display_name_renegade_sniper",
    "loc_breed_display_name_renegade_twin_captain",
    "loc_breed_display_name_renegade_twin_captain_two",


    
    "loc_plague_ogryn_name",
	"loc_daemonhost_name",
	"loc_mutator_daemonhost_name",
    "loc_breed_display_name_chaos_daemonhost",
    "loc_breed_display_name_chaos_beast_of_nurgle",
    "loc_breed_display_name_chaos_spawn",
    -- "loc_breed_display_name_chaos_plague_ogryn",
    "loc_breed_display_name_renegade_twin_captain",
	"loc_breed_display_name_renegade_twin_captain_two",
    
    "loc_breed_display_name_chaos_ogryn_executor",
    "loc_breed_display_name_chaos_ogryn_gunner",
    "loc_breed_display_name_chaos_ogryn_bulwark",
    "loc_breed_display_name_renegade_gunner",
    "loc_breed_display_name_cultist_gunner",
    
    "loc_breed_display_name_chaos_poxwalker_bomber",
    "loc_breed_display_name_chaos_hound",
    "loc_breed_display_name_cultist_mutant",
    "loc_breed_display_name_renegade_flamer",
    "loc_breed_display_name_cultist_flamer",
    "loc_breed_display_name_renegade_sniper",
    "loc_breed_display_name_renegade_netgunner",
    
    "loc_settings_menu_close_menu",
    "loc_settings_menu_reset_to_default",
    
    -- "loc_your_test_key_here",
}

TabLocalizationDebug.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}
    
    table.insert(layout, {widget_type = "stat_header", text = "🔍 DEBUG: Localization Test"})
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    for i, key in ipairs(test_localization_keys) do
        local translated_text = localize(key)
        
        if translated_text ~= key then
            table.insert(layout, {widget_type = "debug_line", text = key, value = translated_text})
        else
            table.insert(layout, {widget_type = "debug_line", text = key, value = "[NOT FOUND]"})
        end
        
        if i % 3 == 0 then
            --table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
        end
    end
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    table.insert(layout, {widget_type = "stat_header", text = "Instruction"})
    table.insert(layout, {widget_type = "stat_line", text = "Add keys to test_localization_keys[]", value = ""})
    table.insert(layout, {widget_type = "stat_line", text = "File: tabs/tab_localization_debug.lua", value = ""})
    
    return layout
end

return TabLocalizationDebug

