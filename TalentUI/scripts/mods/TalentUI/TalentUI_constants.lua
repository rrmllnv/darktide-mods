local mod = get_mod("TalentUI")

local TALENT_ABILITY_METADATA = {
	{
		id = "ability",
		slot = "slot_combat_ability",
		type = "combat_ability",
		name = "talent_ui_all_ability",
		frame = "hex_frame",
		mask = "hex_frame_mask",
	},
	{
		id = "blitz",
		slot = "slot_grenade_ability",
		type = "grenade_ability",
		name = "talent_ui_all_blitz",
		frame = "square_frame",
		mask = "square_frame_mask",
	},
	{
		id = "aura",
		slot = "slot_coherency_ability",
		type = "coherency_ability",
		name = "talent_ui_all_aura",
		frame = "circular_frame",
		mask = "circular_frame_mask",
	},
}

local WEAPON_SLOTS = {
	{
		id = "primary",
		slot = "slot_primary",
		name = "talent_ui_weapon_primary",
	},
	{
		id = "secondary",
		slot = "slot_secondary",
		name = "talent_ui_weapon_secondary",
	},
}

mod.TALENT_ABILITY_METADATA = TALENT_ABILITY_METADATA
mod.WEAPON_SLOTS = WEAPON_SLOTS

return {
	TALENT_ABILITY_METADATA = TALENT_ABILITY_METADATA,
	WEAPON_SLOTS = WEAPON_SLOTS,
}

