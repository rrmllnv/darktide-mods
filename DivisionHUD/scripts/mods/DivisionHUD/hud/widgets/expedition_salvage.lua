local Text = require("scripts/utilities/ui/text")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local WalletSettings = require("scripts/settings/wallet_settings")

local M = {}

local function reset_widget(widget)
	if not widget or not widget.content then
		return
	end

	widget.content.visible = false
	widget.content.text = ""
	widget.alpha_multiplier = 0
	widget.dirty = true
end

function M.init(self)
	local widget = self._widgets_by_name and self._widgets_by_name.expedition_salvage

	reset_widget(widget)
end

function M.update(self, local_player, widget, opacity)
	if not widget or not widget.content or not widget.style then
		return
	end

	local game_mode_manager = Managers.state and Managers.state.game_mode
	local game_mode = game_mode_manager and game_mode_manager:game_mode()
	local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()

	if game_mode_name ~= "expedition" or not game_mode or not game_mode.expedition_currency then
		widget.content.visible = false
		widget.dirty = true

		return
	end

	if not local_player or not local_player.is_human_controlled or not local_player:is_human_controlled() then
		widget.content.visible = false
		widget.dirty = true

		return
	end

	local peer_id = local_player.peer_id and local_player:peer_id()
	local amount = 0

	if peer_id then
		local ok, value = pcall(function()
			return game_mode:expedition_currency(peer_id)
		end)

		if ok and type(value) == "number" then
			amount = value
		elseif ok and value ~= nil then
			amount = tonumber(value) or 0
		end
	end

	local salvage_settings = WalletSettings.expedition_salvage
	local string_symbol = salvage_settings and salvage_settings.string_symbol or ""

	widget.content.visible = true
	widget.content.text = string.format("%s %s", Text.format_currency(math.floor(amount + 0.5)), string_symbol)
	widget.alpha_multiplier = opacity or 1

	local text_color = widget.style.text and widget.style.text.text_color

	if text_color then
		local base = UIHudSettings.color_tint_main_1
		local eff = opacity

		text_color[1] = math.floor((base[1] or 255) * eff)
		text_color[2] = base[2] or 255
		text_color[3] = base[3] or 255
		text_color[4] = base[4] or 255
	end

	widget.dirty = true
end

function M.destroy(self)
	local widget = self._widgets_by_name and self._widgets_by_name.expedition_salvage

	reset_widget(widget)
end

return M
