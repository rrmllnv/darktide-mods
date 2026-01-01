local mod = get_mod("ModderTools")
local ref = "nameplate"

-- Хук для обновления неймплейтов
mod:hook_safe(CLASS.HudElementWorldMarkers, "update", function(self, dt, t, ui_renderer)
    if not mod.is_enabled_feature(ref) or not mod:get("enable_random_names") then
        return
    end

    -- Получаем все маркеры
    local markers = self._markers

    if not markers then
        return
    end

    -- Проходим по всем маркерам и ищем неймплейты игроков
    for marker_id, marker_data in pairs(markers) do
        local widget = marker_data.widget
        local marker_type = marker_data.type

        -- Ищем маркеры типа "nameplate"
        if marker_type == "nameplate" and widget then
            local player = marker_data.player

            if player and not player.__deleted and player:is_human_controlled() then
                local account_id = player:account_id() or player:name() or player:peer_id()
                local content = widget.content

                if content and account_id then
                    local current_text = content.header or content.text
                    local player_name = player:name() or player:character_name()

                    if current_text and player_name and account_id then
                        -- Заменяем имя на случайное
                        local new_text = mod.replace_name_in_text(current_text, account_id, player_name)

                        if new_text ~= current_text then
                            if content.header then
                                content.header = new_text
                            elseif content.text then
                                content.text = new_text
                            end
                        end
                    end
                end
            end
        end
    end
end)

