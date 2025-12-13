local BaseView = require("scripts/ui/views/base_view")
local definitions = require("TeamKills/scripts/mods/TeamKills/killsboard/killsboard_view_definitions")

local KillsboardView = class("KillsboardView", "BaseView")

KillsboardView.init = function(self, settings, context)
	self._definitions = definitions
	KillsboardView.super.init(self, definitions, settings)
end

return KillsboardView

