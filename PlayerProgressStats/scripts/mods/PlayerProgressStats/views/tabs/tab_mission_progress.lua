-- tab_mission_progress.lua - Вкладка "Прохождение миссий"

local TabMissionProgress = {}

TabMissionProgress.create_layout = function(safe_read_stat, localize, format_number)
    local layout = {}

    --table.insert(layout, {widget_type = "stat_header", text = localize("stats_mission_progress_header")})

    local ok_mg, mission_groups = pcall(require, "scripts/settings/achievements/achievement_mission_groups")
    local missions = ok_mg and mission_groups and mission_groups.missions or {}

    local function build_difficulty_labels()
        local ok_danger, danger_settings = pcall(require, "scripts/settings/difficulty/danger_settings")
        local labels = {}

        if ok_danger and danger_settings then
            for i, danger in ipairs(danger_settings) do
                labels[#labels + 1] = {
                    suffix = tostring(i),
                    label = Localize(danger.display_name),
                }
                if #labels == 5 then
                    break
                end
            end
        end

        -- Fallback, если что-то пошло не так
        if #labels == 0 then
            labels = {
                {suffix = "1", label = localize("stats_difficulty_1")},
                {suffix = "2", label = localize("stats_difficulty_2")},
                {suffix = "3", label = localize("stats_difficulty_3")},
                {suffix = "4", label = localize("stats_difficulty_4")},
                {suffix = "5", label = localize("stats_difficulty_5")},
            }
        end

        return labels
    end

    local mission_difficulties = build_difficulty_labels()

    local any_data = false

    local function safe_mission_name(mission)
        local name = mission.local_variable and Localize(mission.local_variable) or mission.name
        if not name or string.find(name, "<unlocalized", 1, true) then
            return mission.name
        end
        return name
    end

    for _, mission in ipairs(missions) do
        -- Пропускаем тренировку и пустые категории
        if mission.category and mission.category.default ~= "training_grounds" and mission.name ~= "psykhanium" then
            local mission_name = safe_mission_name(mission)
            local has_any = false

            for _, diff in ipairs(mission_difficulties) do
                local stat_name = string.format("mission_%s_difficulty_%s", mission.name, diff.suffix)
                local val = safe_read_stat(stat_name)

                if val ~= nil then
                    if not has_any then
						
                        table.insert(layout, {widget_type = "stat_header", text = string.format("%s:", mission_name)})
                        has_any = true
                        any_data = true
                    end

                    local status = (val > 0) and localize("mission_progress_done") or localize("mission_progress_not_done")

                    table.insert(layout, {
                        widget_type = "stat_line",
                        text = diff.label,
                        value = status,
                    })
                end
            end

            table.insert(layout, {widget_type = "stat_line", text = "", value = ""})
        end
    end

    if not any_data then
        table.insert(layout, {widget_type = "stat_line", text = localize("mission_progress_no_data"), value = ""})
    end

    return layout
end

return TabMissionProgress


