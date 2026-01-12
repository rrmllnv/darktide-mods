
local TabMissions = {}

TabMissions.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_missions_main")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_missions"),
        value = format_number(safe_read_stat("missions")),
        description = localize("description_missions"),
        text_key = "stats_missions",
        stat_name = "missions",
        description_key = "description_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_auric_missions"),
        value = format_number(safe_read_stat("auric_missions")),
        description = localize("description_auric_missions"),
        text_key = "stats_auric_missions",
        stat_name = "auric_missions",
        description_key = "description_auric_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_havoc_missions"),
        value = format_number(safe_read_stat("havoc_missions")),
        description = localize("description_havoc_missions"),
        text_key = "stats_havoc_missions",
        stat_name = "havoc_missions",
        description_key = "description_havoc_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_maelstrom_missions"),
        value = format_number(safe_read_stat("mission_maelstrom")),
        description = localize("description_maelstrom_missions"),
        text_key = "stats_maelstrom_missions",
        stat_name = "mission_maelstrom",
        description_key = "description_maelstrom_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_auric_maelstrom_missions"),
        value = format_number(safe_read_stat("mission_auric_maelstrom")),
        description = localize("description_auric_maelstrom_missions"),
        text_key = "stats_auric_maelstrom_missions",
        stat_name = "mission_auric_maelstrom",
        description_key = "description_auric_maelstrom_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_circumstance_missions"),
        value = format_number(safe_read_stat("mission_circumstance")),
        description = localize("description_circumstance_missions"),
        text_key = "stats_circumstance_missions",
        stat_name = "mission_circumstance",
        description_key = "description_circumstance_missions",
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_flawless_header")})
    table.insert(layout, {
        widget_type = "stat_line_with_description", 
        text = localize("stats_flawless_missions"), 
        value = format_number(safe_read_stat("max_flawless_mission_in_a_row")),
        description = localize("description_flawless_missions"),
        text_key = "stats_flawless_missions",
        stat_name = "max_flawless_mission_in_a_row",
        description_key = "description_flawless_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description", 
        text = localize("stats_personal_flawless_auric"), 
        value = format_number(safe_read_stat("personal_flawless_auric")),
        description = localize("description_personal_flawless_auric"),
        text_key = "stats_personal_flawless_auric",
        stat_name = "personal_flawless_auric",
        description_key = "description_personal_flawless_auric",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description", 
        text = localize("stats_team_flawless_missions"), 
        value = format_number(safe_read_stat("team_flawless_missions")),
        description = localize("description_team_flawless_missions"),
        text_key = "stats_team_flawless_missions",
        stat_name = "team_flawless_missions",
        description_key = "description_team_flawless_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description", 
        text = localize("stats_flawless_auric_maelstrom"), 
        value = format_number(safe_read_stat("flawless_auric_maelstrom")),
        description = localize("description_flawless_auric_maelstrom"),
        text_key = "stats_flawless_auric_maelstrom",
        stat_name = "flawless_auric_maelstrom",
        description_key = "description_flawless_auric_maelstrom",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description", 
        text = localize("stats_flawless_auric_maelstrom_consecutive"), 
        value = format_number(safe_read_stat("flawless_auric_maelstrom_consecutive")),
        description = localize("description_flawless_auric_maelstrom_consecutive"),
        text_key = "stats_flawless_auric_maelstrom_consecutive",
        stat_name = "flawless_auric_maelstrom_consecutive",
        description_key = "description_flawless_auric_maelstrom_consecutive",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description", 
        text = localize("stats_flawless_havoc_won"), 
        value = format_number(safe_read_stat("flawless_havoc_won")),
        description = localize("description_flawless_havoc_won"),
        text_key = "stats_flawless_havoc_won",
        stat_name = "flawless_havoc_won",
        description_key = "description_flawless_havoc_won",
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_havoc_header")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_havoc_missions"),
        value = format_number(safe_read_stat("havoc_missions")),
        description = localize("description_havoc_missions"),
        text_key = "stats_havoc_missions",
        stat_name = "havoc_missions",
        description_key = "description_havoc_missions",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_havoc_win_assisted"),
        value = format_number(safe_read_stat("havoc_win_assisted")),
        description = localize("description_havoc_win_assisted"),
        text_key = "stats_havoc_win_assisted",
        stat_name = "havoc_win_assisted",
        description_key = "description_havoc_win_assisted",
    })
    
    local havoc_rank = 0
    for i = 8, 1, -1 do
        if safe_read_stat("havoc_rank_reached_0" .. i) > 0 then
            havoc_rank = i * 5
            break
        end
    end
    
    if havoc_rank > 0 then
        table.insert(layout, {
            widget_type = "stat_line_with_description",
            text = localize("stats_havoc_rank"),
            value = format_number(havoc_rank),
            description = localize("description_havoc_rank"),
            text_key = "stats_havoc_rank",
            stat_name = nil,
            description_key = "description_havoc_rank",
        })
    end
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_twins_header")})
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_mission_twins"),
        value = format_number(safe_read_stat("mission_twins")),
        description = localize("description_mission_twins"),
        text_key = "stats_mission_twins",
        stat_name = "mission_twins",
        description_key = "description_mission_twins",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_mission_twins_hard_mode"),
        value = format_number(safe_read_stat("mission_twins_hard_mode")),
        description = localize("description_mission_twins_hard_mode"),
        text_key = "stats_mission_twins_hard_mode",
        stat_name = "mission_twins_hard_mode",
        description_key = "description_mission_twins_hard_mode",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_mission_twins_secret_puzzle"),
        value = format_number(safe_read_stat("mission_twins_secret_puzzle_trigger")),
        description = localize("description_mission_twins_secret_puzzle"),
        text_key = "stats_mission_twins_secret_puzzle",
        stat_name = "mission_twins_secret_puzzle_trigger",
        description_key = "description_mission_twins_secret_puzzle",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_mission_twins_killed_within_x"),
        value = format_number(safe_read_stat("mission_twins_killed_successfully_within_x")),
        description = localize("description_mission_twins_killed_within_x"),
        text_key = "stats_mission_twins_killed_within_x",
        stat_name = "mission_twins_killed_successfully_within_x",
        description_key = "description_mission_twins_killed_within_x",
    })
    table.insert(layout, {
        widget_type = "stat_line_with_description",
        text = localize("stats_mission_twins_no_mines"),
        value = format_number(safe_read_stat("mission_twins_no_mines_triggered")),
        description = localize("description_mission_twins_no_mines"),
        text_key = "stats_mission_twins_no_mines",
        stat_name = "mission_twins_no_mines_triggered",
        description_key = "description_mission_twins_no_mines",
    })
    
    table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
    
    table.insert(layout, {widget_type = "stat_header", text = localize("stats_zones_header")})
    
    local zones = {
        {key = "dust", loc_key = "loc_zone_dust"},
        {key = "entertainment", loc_key = "loc_zone_entertainment"},
        {key = "operations", loc_key = "loc_zone_operations"},
        {key = "tank_foundry", loc_key = "loc_zone_tank_foundry"},
        {key = "throneside", loc_key = "loc_zone_throneside"},
        {key = "transit", loc_key = "loc_zone_transit"},
        {key = "void", loc_key = "loc_zone_void"},
        {key = "watertown", loc_key = "loc_zone_watertown"},
        {key = "horde", loc_key = "loc_horde_mission_breifing_zone"},
        {key = "hourglass", loc_key = "loc_zone_name_hourglass_short"},
        {key = "carnival", loc_key = "loc_zone_name_carnival_short"},
    }
    
    for _, zone in ipairs(zones) do
        local stat_name = string.format("zone_%s_missions_completed", zone.key)
        local count = safe_read_stat(stat_name)
        if count > 0 then
            table.insert(layout, {
                widget_type = "stat_line_with_description",
                text = localize(zone.loc_key),
                value = format_number(count),
                description = localize("description_zone_missions"),
                text_key = zone.loc_key,
                stat_name = stat_name,
                description_key = "description_zone_missions",
            })
        end
    end
    
    return layout
end

return TabMissions
