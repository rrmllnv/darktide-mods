local mod = get_mod("FriendlyFireNotify")

local AttackReportManager = mod:original_require("scripts/managers/attack_report/attack_report_manager")

local notifications = mod:io_dofile("FriendlyFireNotify/scripts/mods/FriendlyFireNotify/FriendlyFireNotify_notifications")
local incoming = mod:io_dofile("FriendlyFireNotify/scripts/mods/FriendlyFireNotify/FriendlyFireNotify_incoming")
local outgoing = mod:io_dofile("FriendlyFireNotify/scripts/mods/FriendlyFireNotify/FriendlyFireNotify_outgoing")

mod.incoming = incoming
mod.outgoing = outgoing
mod.player_from_unit = mod.player_from_unit or notifications.player_from_unit

mod.on_all_mods_loaded = function()
	incoming.reset()
	outgoing.reset()
	notifications.refresh_settings()
end

mod.on_setting_changed = function(setting_id)
	if setting_id == "min_damage_threshold"
		or setting_id == "show_total_damage"
		or setting_id == "show_team_total_damage"
		or setting_id == "notification_coalesce_time"
		or setting_id == "notification_duration_time"
		or setting_id == "notification_background_color"
	then
		notifications.refresh_settings()
	end
end

function mod.on_game_state_changed(status, state_name)
	if (state_name == "GameplayStateRun" or state_name == "StateGameplay") and status == "enter" then
		incoming.reset()
		outgoing.reset()
		notifications.refresh_settings()
	end
end

mod.update = function()
	incoming.update()
	outgoing.update()
end

mod:hook_safe(AttackReportManager, "_process_attack_result", function(self, buffer_data)
	incoming.on_attack_result(buffer_data)
	outgoing.on_attack_result(buffer_data)
end)

if mod.DEBUG then
	mod:command("notify", "Test FriendlyFireNotify notification (damage/kill)", function(mode)
		local local_player = Managers.player and Managers.player:local_player(1)

		if not local_player or not Managers.event then
			return
		end

		if mode == "kill" then
			notifications.show_incoming_kill("Тестовый игрок", 4, 5, local_player, local_player)
		else
			notifications.show_incoming_damage({
				player_name = "Ophelia",
				damage_amount = 34,
				total_damage = 57,
				is_self_damage = false,
				source_text = "barrel explosion",
				notification_player = local_player,
				portrait_player = local_player,
				team_total_damage = 81,
			})
		end
	end)
end