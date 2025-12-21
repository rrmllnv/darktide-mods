local mod = get_mod("IconPathViewer")
local ScriptWorld = require("scripts/foundation/utilities/script_world")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")
local definitions = mod:io_dofile("IconPathViewer/scripts/mods/IconPathViewer/icon_path_viewer_view/icon_path_viewer_view_definitions")

-- Конвертация Unicode кодов в символы (ТОЧНАЯ КОПИЯ из BetterLoadouts)
local bytemarkers = { { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } }
local function utf8(decimal)
	if decimal < 128 then return string.char(decimal) end
	local charbytes = {}
	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local rem = decimal % 64
				decimal = (decimal - rem) / 64
				charbytes[b] = string.char(128 + rem)
			end
			charbytes[1] = string.char(vals[2] + decimal)
			break
		end
	end
	return table.concat(charbytes)
end

-- Дополнительные Unicode коды для иконок (ТОЧНАЯ КОПИЯ из BetterLoadouts)
local UNICODE_EXTRA_CODES = {
	0xE000, 0xE001, 0xE002, 0xE003, 0xE004, 0xE005, 0xE006, 0xE007,
	0xE01F, 0xE021, 0xE026, 0xE029, 0xE02E, 0xE041, 0xE042, 0xE045,
	0xE046, 0xE049, 0xE04D, 0xE04F, 0xE051, 0xE107, 0xE108, 0xE109,
	0xE10A, 0xE010, 0xE011, 0xE012, 0xE013, 0xE014, 0xE015, 0xE016,
	0xE017, 0xE018, 0xE019,
}

IconPathViewerView = class("IconPathViewerView", "BaseView")

IconPathViewerView.init = function(self, settings)
	IconPathViewerView.super.init(self, definitions, settings)
end

IconPathViewerView.on_enter = function(self)
	IconPathViewerView.super.on_enter(self)
	self:_setup_input_legend()
	self:_setup_grid()
end

IconPathViewerView._setup_input_legend = function(self)
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 100)
	local legend_inputs = self._definitions.legend_inputs

	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)

		self._input_legend_element:add_entry(
			legend_input.display_name,
			legend_input.input_action,
			legend_input.visibility_function,
			on_pressed_callback,
			legend_input.alignment
		)
	end
end

IconPathViewerView._setup_grid = function(self)
	self._icon_table_element = self:_add_element(ViewElementGrid, "icon_table", 103, definitions.grid_settings, "icon_table_pivot")
	self._icon_table_element:set_visibility(true)
	
	-- ТОЧНАЯ КОПИЯ логики из BetterLoadouts
	local ViewElementProfilePresetsSettings = require("scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_settings")
	
	-- Private preset-icons pool (как в BetterLoadouts)
	local PRIVATE_ICON_LOOKUP, PRIVATE_ICON_KEYS = {}, {}


	-- Функция регистрации (ТОЧНАЯ КОПИЯ из BetterLoadouts)
	local function _register_private(list)
		for i = 1, #list do
			local key = list[i]
			if key and not PRIVATE_ICON_LOOKUP[key] then
				PRIVATE_ICON_LOOKUP[key] = key -- our convention (используем путь как материал)
				PRIVATE_ICON_KEYS[#PRIVATE_ICON_KEYS + 1] = key
			end
		end
	end
	
	-- Функция заполнения (ТОЧНАЯ КОПИЯ из BetterLoadouts)
	local function _seed_private_from_vanilla_then_custom()
		local S   = ViewElementProfilePresetsSettings
		local ref = S and S.optional_preset_icon_reference_keys or {}
		local lu  = S and S.optional_preset_icons_lookup or {}

		for i = 1, #ref do
			local vk   = ref[i]
			local vmat = lu[vk]
			if vk and vmat and not PRIVATE_ICON_LOOKUP[vk] then
				PRIVATE_ICON_LOOKUP[vk] = vmat
				PRIVATE_ICON_KEYS[#PRIVATE_ICON_KEYS + 1] = vk
			end
		end

		-- Встроенный список путей (скопирован из BetterLoadouts/constants.lua + ui_settings.lua)
		local DEFAULT_CUSTOM_ICON_PATHS = {
			-- Из BetterLoadouts/constants.lua
			"content/ui/materials/icons/item_types/ranged_weapons",
			"content/ui/materials/icons/circumstances/assault_01",
			"content/ui/materials/icons/item_types/weapons",
			"content/ui/materials/icons/item_types/melee_weapons",
			"content/ui/materials/hud/interactions/icons/grenade",
			"content/ui/materials/icons/circumstances/hunting_grounds_01",
			"content/ui/materials/icons/circumstances/ventilation_purge_01",
			"content/ui/materials/icons/circumstances/nurgle_manifestation_01",
			"content/ui/materials/icons/pocketables/hud/scripture",
			"content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
			-- Иконки из pocketables
			"content/ui/materials/icons/pocketables/hud/small/party_ammo_crate",
			"content/ui/materials/icons/pocketables/hud/small/party_scripture",
			"content/ui/materials/icons/pocketables/hud/small/party_syringe_power",
			"content/ui/materials/icons/pocketables/hud/small/party_syringe_speed",
			"content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
			"content/ui/materials/icons/pocketables/hud/small/party_medic_crate",
			"content/ui/materials/icons/pocketables/hud/small/party_corrupted_auspex_scanner",
			"content/ui/materials/icons/pocketables/hud/small/party_grimoire",
			"content/ui/materials/icons/pocketables/hud/small/party_syringe_ability",
			-- Из ui_settings.lua - item_type_material_lookup
			"content/ui/materials/icons/item_types/body_tattoos",
			"content/ui/materials/icons/item_types/nameplates",
			"content/ui/materials/icons/item_types/companion_gear_full",
			"content/ui/materials/icons/item_types/devices",
			"content/ui/materials/icons/item_types/poses",
			"content/ui/materials/icons/item_types/eye_color",
			"content/ui/materials/icons/item_types/face_types",
			"content/ui/materials/icons/item_types/facial_hair_styles",
			"content/ui/materials/icons/item_types/facial_makeup",
			"content/ui/materials/icons/item_types/scars",
			"content/ui/materials/icons/item_types/face_tattoos",
			"content/ui/materials/icons/item_types/outfits",
			"content/ui/materials/icons/item_types/headgears",
			"content/ui/materials/icons/item_types/lower_bodies",
			"content/ui/materials/icons/item_types/upper_bodies",
			"content/ui/materials/icons/item_types/hair_styles",
			"content/ui/materials/icons/item_types/weapon_trinkets",
			-- Из ui_settings.lua - texture_by_store_category
			"content/ui/materials/icons/item_types/boons",
			"content/ui/materials/icons/item_types/emotes",
			-- Из ui_settings.lua - weapon_card_icons и weapon_action_type_icons
			"content/ui/materials/icons/weapons/actions/activate",
			"content/ui/materials/icons/weapons/actions/ads",
			"content/ui/materials/icons/weapons/actions/brace",
			"content/ui/materials/icons/weapons/actions/burst",
			"content/ui/materials/icons/weapons/actions/charge",
			"content/ui/materials/icons/weapons/actions/defence",
			"content/ui/materials/icons/weapons/actions/flashlight",
			"content/ui/materials/icons/weapons/actions/full_auto",
			"content/ui/materials/icons/weapons/actions/hipfire",
			"content/ui/materials/icons/weapons/actions/linesman",
			"content/ui/materials/icons/weapons/actions/melee",
			"content/ui/materials/icons/weapons/actions/melee_hand",
			"content/ui/materials/icons/weapons/actions/ninjafencer",
			"content/ui/materials/icons/weapons/actions/projectile",
			"content/ui/materials/icons/weapons/actions/quick_grenade",
			"content/ui/materials/icons/weapons/actions/semi_auto",
			"content/ui/materials/icons/weapons/actions/shotgun",
			"content/ui/materials/icons/weapons/actions/smiter",
			"content/ui/materials/icons/weapons/actions/special_bullet",
			"content/ui/materials/icons/weapons/actions/special_attack",
			"content/ui/materials/icons/weapons/actions/tank",
			"content/ui/materials/icons/weapons/actions/vent",
			-- Из MourningstarCommandWheel_buttons.lua
			"content/ui/materials/hud/interactions/icons/barber",
			"content/ui/materials/hud/interactions/icons/contracts",
			"content/ui/materials/hud/interactions/icons/forge",
			"content/ui/materials/hud/interactions/icons/credits_store",
			"content/ui/materials/hud/interactions/icons/mission_board",
			"content/ui/materials/icons/system/escape/premium_store",
			"content/ui/materials/hud/interactions/icons/training_grounds",
			"content/ui/materials/icons/system/escape/leave_training",
			"content/ui/materials/icons/system/escape/social",
			"content/ui/materials/hud/interactions/icons/cosmetics_store",
			"content/ui/materials/icons/system/escape/achievements",
			"content/ui/materials/icons/system/escape/inventory",
			"content/ui/materials/icons/system/escape/change_character",
			"content/ui/materials/hud/interactions/icons/havoc",
			-- Из interaction_icons.html - уникальные иконки взаимодействий
			"content/ui/materials/hud/interactions/icons/ammunition",
			"content/ui/materials/hud/interactions/icons/default",
			"content/ui/materials/hud/interactions/icons/enemy",
			"content/ui/materials/hud/interactions/icons/environment_generic",
			"content/ui/materials/hud/interactions/icons/help",
			"content/ui/materials/hud/interactions/icons/objective_secondary",
			"content/ui/materials/hud/interactions/icons/objective_side",
			"content/ui/materials/hud/interactions/icons/penances",
			"content/ui/materials/hud/interactions/icons/pocketable_default",
			"content/ui/materials/hud/interactions/icons/premium_store",
			"content/ui/materials/hud/interactions/icons/respawn",
			-- Из group_finder_view_definitions.lua
			"content/ui/materials/icons/classes/veteran",
			"content/ui/materials/icons/categories/melee",
			"content/ui/materials/icons/categories/ranged",
			"content/ui/materials/icons/categories/devices",
			"content/ui/materials/icons/list_buttons/check",
			"content/ui/materials/icons/list_buttons/cross",
			-- Из wallet_settings.lua - иконки валют
			"content/ui/materials/icons/currencies/credits_big",
			"content/ui/materials/icons/currencies/credits_small",
			"content/ui/materials/icons/currencies/marks_big",
			"content/ui/materials/icons/currencies/marks_small",
			"content/ui/materials/icons/currencies/premium_big",
			"content/ui/materials/icons/currencies/premium_small",
			"content/ui/materials/icons/currencies/plasteel_big",
			"content/ui/materials/icons/currencies/plasteel_small",
			"content/ui/materials/icons/currencies/diamantine_big",
			"content/ui/materials/icons/currencies/diamantine_small",
			-- Из ability_templates и archetype_talents
			"content/ui/materials/icons/throwables/hud/small/party_non_grenade",
			"content/ui/materials/icons/abilities/throwables/default",
			"content/ui/materials/icons/abilities/ultimate/default",
			"content/ui/materials/icons/abilities/combat/default",
			"content/ui/materials/icons/abilities/default",
			"content/ui/materials/icons/throwables/hud/adamant_whistle",
			-- Из adamant_talents.lua и adamant_abilities.lua
			"content/ui/textures/icons/talents/adamant/adamant_ability_shout",
			"content/ui/textures/icons/talents/adamant/adamant_ability_shout_improved",
			"content/ui/textures/icons/talents/adamant/adamant_ability_charge",
			"content/ui/textures/icons/talents/adamant/adamant_ability_stance",
			"content/ui/textures/icons/talents/adamant/adamant_ability_area_buff_drone",
			"content/ui/textures/icons/talents/adamant/adamant_companion_coherency",
			"content/ui/textures/icons/abilities/hud/adamant/adamant_ability_shout",
			"content/ui/textures/icons/abilities/hud/adamant/adamant_ability_shout_improved",
			"content/ui/textures/icons/abilities/hud/adamant/adamant_ability_charge",
			"content/ui/textures/icons/abilities/hud/adamant/adamant_ability_stance",
			"content/ui/textures/icons/abilities/hud/adamant/adamant_ability_area_buff_drone",
			"content/ui/textures/icons/buffs/hud/adamant/adamant_companion_coherency",
			-- Из broker_talents.lua и broker_abilities.lua
			"content/ui/textures/icons/talents/broker/broker_talent_ability_focus",
			"content/ui/textures/icons/talents/broker/broker_talent_ability_focus_improved",
			"content/ui/textures/icons/talents/broker/broker_talent_ability_punk_rage",
			"content/ui/textures/icons/talents/broker/broker_talent_ability_stimm_field",
			"content/ui/textures/icons/talents/broker/broker_talent_blitz_flash_grenade",
			"content/ui/textures/icons/talents/broker/broker_talent_aura_gunslinger",
			"content/ui/textures/icons/talents/broker/broker_talent_temp_icon_ruffian",
			"content/ui/textures/icons/talents/broker/broker_talent_temp_icon_psycho",
			"content/ui/textures/icons/abilities/hud/broker/broker_ability_focus",
			"content/ui/textures/icons/abilities/hud/broker/broker_ability_focus_improved",
			"content/ui/textures/icons/abilities/hud/broker/broker_ability_punk_rage",
			"content/ui/textures/icons/abilities/hud/broker/broker_ability_stimm_field",
			"content/ui/textures/icons/abilities/hud/psyker/psyker_ability_warp_barrier",
			-- Из zealot_talents.lua
			"content/ui/textures/icons/talents/zealot/zealot_ability_chastise_the_wicked",
			"content/ui/textures/icons/talents/zealot/zealot_blitz_stun_grenade",
			"content/ui/textures/icons/talents/zealot/zealot_aura_the_emperor_will",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_combat",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_base_1",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_base_2",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_base_3",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_1_1",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_1_2",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_1_3",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_2_1",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_2_2",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_2_3",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_3_2",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_3_3",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_4_2",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_4_3",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_5_1",
			"content/ui/textures/icons/talents/zealot_1/zealot_1_tier_5_2",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_combat",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_base_2",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_base_3",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_base_4",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tactical",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_2_1",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_2_2_b",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_2_3",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_3_2",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_3_3",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_4_1",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_4_2",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_4_3",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_4_3_b",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_5_1",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_5_1_b",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_5_2",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_5_3",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_6_1",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_6_2",
			"content/ui/textures/icons/talents/zealot_2/zealot_2_tier_6_3",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_combat",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tactical",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_aura",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_base_1",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_base_2",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_base_3",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_1_1",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_1_3",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_2_1",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_2_2",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_2_3",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_3_1",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_3_2",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_3_3",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_4_2",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_4_3",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_5_2",
			"content/ui/textures/icons/talents/zealot_3/zealot_3_tier_5_3",
			-- Из veteran_talents.lua (из grep результатов)
			"content/ui/textures/icons/talents/veteran/veteran_blitz_frag_grenade",
			"content/ui/textures/icons/talents/veteran/veteran_ability_volley_fire_stance",
			"content/ui/textures/icons/talents/veteran_1/veteran_1_tactical",
			"content/ui/textures/icons/talents/veteran_2/veteran_2_tactical",
			"content/ui/textures/icons/talents/veteran_2/veteran_2_tier_5_1",
			"content/ui/textures/icons/talents/veteran_3/veteran_3_tactical",
			"content/ui/textures/icons/talents/veteran_3/veteran_3_tier_6_3",
			-- Из ogryn_talents.lua
			"content/ui/textures/icons/talents/ogryn_2/ogryn_2_base_4",
			-- Из psyker_talents.lua (основные пути)
			"content/ui/textures/icons/talents/psyker/psyker_ability_smite",
			"content/ui/textures/icons/talents/psyker/psyker_ability_warp_barrier",
			"content/ui/textures/icons/talents/psyker/psyker_blitz_brain_burst",
			"content/ui/textures/icons/talents/psyker_1/psyker_1_combat",
			"content/ui/textures/icons/talents/psyker_2/psyker_2_combat",
			"content/ui/textures/icons/talents/psyker_3/psyker_3_combat",
			-- Из ogryn_abilities.lua
			"content/ui/textures/icons/abilities/hud/ogryn/ogryn_ability_bull_rush",
			"content/ui/textures/icons/abilities/hud/ogryn/ogryn_longer_charge",
			"content/ui/textures/icons/abilities/hud/ogryn/ogryn_ability_speshul_ammo",
			"content/ui/textures/icons/abilities/hud/ogryn/ogryn_ability_taunt",
			-- Из psyker_abilities.lua
			"content/ui/textures/icons/abilities/hud/psyker/psyker_ability_discharge",
			"content/ui/textures/icons/abilities/hud/psyker/psyker_shout_vent_warp_charge",
			"content/ui/textures/icons/abilities/hud/psyker/psyker_ability_warp_barrier",
			"content/ui/textures/icons/abilities/hud/psyker/psyker_sphere_shield",
			"content/ui/textures/icons/abilities/hud/psyker/psyker_ability_overcharge_stance",
			-- Из veteran_abilities.lua
			"content/ui/textures/icons/abilities/hud/veteran/veteran_ability_volley_fire",
			"content/ui/textures/icons/abilities/hud/veteran/veteran_ability_volley_fire_stance",
			"content/ui/textures/icons/abilities/hud/veteran/veteran_ability_undercover",
			"content/ui/textures/icons/abilities/hud/veteran/veteran_ability_voice_of_command",
			-- Из zealot_abilities.lua
			"content/ui/textures/icons/abilities/hud/zealot/zealot_ability_chastise_the_wicked",
			"content/ui/textures/icons/abilities/hud/zealot/zealot_attack_speed_post_ability",
			"content/ui/textures/icons/abilities/hud/zealot/zealot_ability_bolstering_prayer",
			"content/ui/textures/icons/abilities/hud/zealot/zealot_ability_stealth",
			-- Из adamant_archetype.lua
			"content/ui/materials/icons/classes/large/adamant",
			"content/ui/materials/icons/class_badges/adamant_01_01",
			"content/ui/materials/icons/classes/adamant",
			"content/ui/materials/icons/classes/adamant_terminal",
			"content/ui/materials/icons/classes/adamant_terminal_shadow",
			"content/ui/materials/backgrounds/info_panels/adamant",
			"content/ui/textures/frames/class_selection/windows/adamant/class_selection_top_adamant",
			"content/ui/textures/frames/class_selection/windows/adamant/class_selection_top_adamant_unselected",
			-- Из broker_archetype.lua
			"content/ui/materials/icons/classes/large/broker",
			"content/ui/materials/icons/class_badges/broker_01_01",
			"content/ui/materials/icons/classes/broker",
			"content/ui/materials/icons/classes/broker_terminal",
			"content/ui/materials/icons/classes/broker_terminal_shadow",
			"content/ui/materials/backgrounds/info_panels/broker",
			"content/ui/textures/frames/class_selection/windows/broker/class_selection_top_broker",
			"content/ui/textures/frames/class_selection/windows/broker/class_selection_top_broker_unselected",
			-- Из ogryn_archetype.lua
			"content/ui/materials/icons/classes/large/ogryn",
			"content/ui/materials/icons/class_badges/ogryn_01_01",
			"content/ui/materials/icons/classes/ogryn",
			"content/ui/materials/icons/classes/ogryn_terminal",
			"content/ui/materials/icons/classes/ogryn_terminal_shadow",
			"content/ui/materials/backgrounds/info_panels/ogryn",
			"content/ui/textures/frames/class_selection/windows/ogryn/class_selection_top_ogryn",
			"content/ui/textures/frames/class_selection/windows/ogryn/class_selection_top_ogryn_unselected",
			-- Из psyker_archetype.lua
			"content/ui/materials/icons/classes/large/psyker",
			"content/ui/materials/icons/class_badges/psyker_01_01",
			"content/ui/materials/icons/classes/psyker",
			"content/ui/materials/icons/classes/psyker_terminal",
			"content/ui/materials/icons/classes/psyker_terminal_shadow",
			"content/ui/materials/backgrounds/info_panels/psyker",
			"content/ui/textures/frames/class_selection/windows/psyker/class_selection_top_psyker",
			"content/ui/textures/frames/class_selection/windows/psyker/class_selection_top_psyker_unselected",
			-- Из veteran_archetype.lua
			"content/ui/materials/icons/classes/large/veteran",
			"content/ui/materials/icons/class_badges/veteran_01_01",
			"content/ui/materials/icons/classes/veteran",
			"content/ui/materials/icons/classes/veteran_terminal",
			"content/ui/materials/icons/classes/veteran_terminal_shadow",
			"content/ui/materials/backgrounds/info_panels/veteran",
			"content/ui/textures/frames/class_selection/windows/veteran/class_selection_top_veteran",
			"content/ui/textures/frames/class_selection/windows/veteran/class_selection_top_veteran_unselected",
			-- Из zealot_archetype.lua
			"content/ui/materials/icons/classes/large/zealot",
			"content/ui/materials/icons/class_badges/zealot_01_01",
			"content/ui/materials/icons/classes/zealot",
			"content/ui/materials/icons/classes/zealot_terminal",
			"content/ui/materials/icons/classes/zealot_terminal_shadow",
			"content/ui/materials/backgrounds/info_panels/zealot",
			"content/ui/textures/frames/class_selection/windows/zealot/class_selection_top_zealot",
			"content/ui/textures/frames/class_selection/windows/zealot/class_selection_top_zealot_unselected",
			-- Из circumstance templates
			-- Из assault_circumstance_template.lua
			"content/ui/materials/icons/circumstances/assault_01",
			"content/ui/materials/mission_board/circumstances/assault_01",
			-- Из base_live_event_template.lua
			"content/ui/materials/icons/circumstances/live_event_01",
			"content/ui/materials/mission_board/circumstances/live_event_01",
			-- Из darkness_circumstance_template.lua
			"content/ui/materials/icons/circumstances/darkness_01",
			"content/ui/materials/mission_board/circumstances/darkness_01",
			"content/ui/materials/icons/circumstances/darkness_02",
			"content/ui/materials/mission_board/circumstances/darkness_02",
			"content/ui/materials/icons/circumstances/darkness_03",
			"content/ui/materials/mission_board/circumstances/darkness_03",
			"content/ui/materials/icons/circumstances/darkness_04",
			"content/ui/materials/mission_board/circumstances/darkness_04",
			"content/ui/materials/backgrounds/mutators/mutator_lights_out",
			-- Из dummy_resistance_changes_template.lua
			"content/ui/materials/icons/circumstances/more_resistance_01",
			"content/ui/materials/mission_board/circumstances/more_resistance_01",
			"content/ui/materials/icons/circumstances/less_resistance_01",
			"content/ui/materials/mission_board/circumstances/less_resistance_01",
			-- Из extra_trickle_circumstance_template.lua
			"content/ui/materials/icons/circumstances/hunting_grounds_01",
			"content/ui/materials/mission_board/circumstances/hunting_grounds_01",
			-- Из flash_mission_circumstance_template.lua
			"content/ui/materials/icons/circumstances/maelstrom_01",
			"content/ui/materials/mission_board/circumstances/maelstrom_01",
			"content/ui/materials/icons/circumstances/maelstrom_02",
			"content/ui/materials/mission_board/circumstances/maelstrom_02",
			-- Из havoc_circumstance_template.lua
			"content/ui/materials/icons/circumstances/nurgle_manifestation_01",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_nurgle",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_rotten_armor",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_stimmed_minions",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_parasite",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_rampaging_enemies",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_moebian21st",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_skin",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_final_toll",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_heinous_rituals",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_encroaching_garden",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_fading_light_1",
			"content/ui/materials/icons/circumstances/havoc/havoc_mutator_fading_light_2",
			-- Фоновые изображения из havoc_circumstance_template.lua
			"content/ui/materials/backgrounds/mutators/havoc_mutator_nurgle",
			"content/ui/materials/backgrounds/mutators/mutators_bg_rotten_armor",
			"content/ui/materials/backgrounds/mutators/mutators_bg_stimmed_minions",
			"content/ui/materials/backgrounds/mutators/havoc_mutator_parasite",
			"content/ui/materials/backgrounds/mutators/mutators_bg_rampaging_enemies",
			"content/ui/materials/backgrounds/mutators/havoc_mutator_moebian21st",
			"content/ui/materials/backgrounds/mutators/havoc_mutator_skin",
			"content/ui/materials/backgrounds/mutators/mutators_bg_heinous_rituals",
			"content/ui/materials/backgrounds/mutators/mutators_bg_the_encroaching_garden",
			"content/ui/materials/backgrounds/mutators/havoc_emperor_01",
			"content/ui/materials/backgrounds/mutators/havoc_emperor_02",
			-- Из hunting_grounds_circumstance_template.lua
			"content/ui/materials/icons/circumstances/hunting_grounds_01",
			"content/ui/materials/mission_board/circumstances/hunting_grounds_01",
			"content/ui/materials/icons/circumstances/hunting_grounds_02",
			"content/ui/materials/mission_board/circumstances/hunting_grounds_02",
			"content/ui/materials/icons/circumstances/hunting_grounds_03",
			"content/ui/materials/mission_board/circumstances/hunting_grounds_03",
			-- Из live_event_barrel_grounds_circumstance_template.lua
			"content/ui/materials/backgrounds/mutators/mutators_bg_default",
			-- Из resistance_changes_template.lua
			"content/ui/materials/icons/circumstances/six_one_01",
			"content/ui/materials/mission_board/circumstances/six_one_01",
			"content/ui/materials/icons/circumstances/special_waves_01",
			"content/ui/materials/mission_board/circumstances/special_waves_01",
			"content/ui/materials/icons/circumstances/special_waves_02",
			"content/ui/materials/mission_board/circumstances/special_waves_02",
			"content/ui/materials/icons/circumstances/special_waves_03",
			"content/ui/materials/mission_board/circumstances/special_waves_03",
			"content/ui/materials/icons/circumstances/placeholder",
			-- Из toxic_gas_circumstance_template.lua
			"content/ui/materials/backgrounds/mutators/mutator_toxic_gas",
			-- Из ventilation_purge_circumstance_template.lua
			"content/ui/materials/icons/circumstances/ventilation_purge_02",
			"content/ui/materials/mission_board/circumstances/ventilation_purge_02",
			"content/ui/materials/icons/circumstances/ventilation_purge_03",
			"content/ui/materials/mission_board/circumstances/ventilation_purge_03",
			"content/ui/materials/icons/circumstances/ventilation_purge_04",
			"content/ui/materials/mission_board/circumstances/ventilation_purge_04",
			"content/ui/materials/backgrounds/mutators/mutator_vent",
			"content/ui/materials/backgrounds/mutators/mutator_vent_sniper",
			-- Из dialogue_speaker_voice_settings.lua
			"content/ui/textures/icons/npc_portraits/mission_givers/procter_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/procter_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/sergeant_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/sergeant_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/pilot_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/pilot_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/alice_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/alice_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/explicator_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/explicator_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/tank_commander_a",
			"content/ui/textures/icons/npc_portraits/mission_givers/default",
			"content/ui/textures/icons/npc_portraits/mission_givers/tech_priest_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/tech_priest_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/sefoni_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/sefoni_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/rannick_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/rannick_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/brahms_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/brahms_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/melk_a",
			"content/ui/textures/icons/npc_portraits/enemies/wolfer_a",
			"content/ui/textures/icons/npc_portraits/enemies/officer_01",
			"content/ui/textures/icons/npc_portraits/enemies/officer_02",
			"content/ui/textures/icons/npc_portraits/mission_givers/krall_a",
			"content/ui/textures/icons/npc_portraits/mission_givers/enginseer_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/enginseer_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/hestia_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/hestia_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/swagger_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/swagger_a_small",
			"content/ui/textures/icons/npc_portraits/mission_givers/darinda_a",
			"content/ui/materials/icons/npc_portraits/mission_givers/darinda_a_small",
			-- Из area_buff_drone.lua
			"content/ui/materials/icons/throwables/hud/area_buff_drone",
			"content/ui/materials/icons/throwables/hud/small/party_grenade",
			-- Из stepper_pass_templates.lua
			"content/ui/materials/buttons/arrow_01",
			"content/ui/materials/icons/generic/danger",
			"content/ui/materials/frames/difficulty_stepper_frame",
			"content/ui/materials/buttons/double_arrow",
			"content/ui/materials/buttons/double_arrow_glow",
			"content/ui/materials/icons/difficulty/difficulty_indicator_empty",
			"content/ui/materials/icons/difficulty/selection_frame_dimond_small",
			"content/ui/materials/icons/difficulty/difficulty_indicator_full",
			"content/ui/materials/icons/difficulty/difficulty_skull_uprising",
			-- Из weapon_details_pass_templates.lua
			"content/ui/materials/icons/buffs/frames/background",
			"content/ui/materials/icons/buffs/frames/inner_line_thin",
			"content/ui/materials/icons/traits/empty",
			"content/ui/materials/icons/traits/container",
			"content/ui/materials/icons/traits/frames/addon_lock",
			-- Из view_element_profile_presets_settings.lua
			"content/ui/materials/icons/presets/preset_01",
			"content/ui/materials/icons/presets/preset_02",
			"content/ui/materials/icons/presets/preset_03",
			"content/ui/materials/icons/presets/preset_04",
			"content/ui/materials/icons/presets/preset_05",
			"content/ui/materials/icons/presets/preset_06",
			"content/ui/materials/icons/presets/preset_07",
			"content/ui/materials/icons/presets/preset_08",
			"content/ui/materials/icons/presets/preset_09",
			"content/ui/materials/icons/presets/preset_10",
			"content/ui/materials/icons/presets/preset_11",
			"content/ui/materials/icons/presets/preset_12",
			"content/ui/materials/icons/presets/preset_13",
			"content/ui/materials/icons/presets/preset_14",
			"content/ui/materials/icons/presets/preset_15",
			"content/ui/materials/icons/presets/preset_16",
			"content/ui/materials/icons/presets/preset_17",
			"content/ui/materials/icons/presets/preset_18",
			"content/ui/materials/icons/presets/preset_19",
			"content/ui/materials/icons/presets/preset_20",
			"content/ui/materials/icons/presets/preset_21",
			"content/ui/materials/icons/presets/preset_22",
			"content/ui/materials/icons/presets/preset_23",
			"content/ui/materials/icons/presets/preset_24",
			"content/ui/materials/icons/presets/preset_25",
			-- Из character_appearance_view.lua
			"content/ui/materials/icons/character_creator/home_planet",
			"content/ui/materials/icons/character_creator/childhood",
			"content/ui/materials/icons/character_creator/growth",
			"content/ui/materials/icons/character_creator/accomplishment",
			"content/ui/materials/icons/character_creator/appearence",
			"content/ui/materials/icons/character_creator/personality",
			"content/ui/materials/icons/character_creator/sentence",
			"content/ui/materials/icons/character_creator/companion_appearence",
			"content/ui/materials/icons/character_creator/home_planet_broker",
			"content/ui/textures/icons/generic/placeholder_childhood",
			"content/ui/textures/icons/generic/placeholder_growingup",
			"content/ui/textures/icons/generic/placeholder_formative",
			"content/ui/textures/icons/generic/randomize",
			"content/ui/textures/icons/appearances/eyes/eyes_r1_l1",
			"content/ui/textures/icons/appearances/eyes/eyes_r0_l1",
			"content/ui/textures/icons/appearances/eyes/eyes_r1_l0",
			"content/ui/textures/icons/appearances/eyes/eyes_r0_l0",
			"content/ui/textures/icons/appearances/eyes/eyes_r2_l2",
			"content/ui/textures/icons/appearances/backgrounds/face_tattoos",
			"content/ui/textures/icons/appearances/backgrounds/body_tattoos",
			"content/ui/textures/icons/appearances/backgrounds/full_body_tattoos",
			"content/ui/textures/icons/appearances/backgrounds/scars",
			"content/ui/textures/icons/appearances/body_types/feminine",
			"content/ui/textures/icons/appearances/body_types/masculine",
			"content/ui/textures/icons/appearances/dog/fur_pattern",
			"content/ui/textures/icons/appearances/no_option",
			"content/ui/materials/icons/appearances/skin_color",
			"content/ui/materials/icons/appearances/eye_color",
			"content/ui/materials/icons/appearances/hair_color",
			"content/ui/materials/icons/item_types/body_types",
			"content/ui/materials/icons/item_types/height",
			"content/ui/materials/icons/item_types/fur_color",
			"content/ui/materials/icons/item_types/fur_pattern",
			-- Из class_selection_view_blueprints.lua
			"content/ui/materials/icons/talents/combat_talent_icon_container",
			"content/ui/materials/icons/talents/talent_icon_container",
			"content/ui/textures/icons/talents/menu/frame_active",
			"content/ui/materials/icons/items/containers/item_container_landscape",
			-- Из contracts_view_definitions.lua и contracts_view_settings.lua
			"content/ui/materials/icons/contracts/contract_task",
			"content/ui/materials/icons/contracts/complexity_tutorial",
			"content/ui/materials/icons/contracts/complexity_easy",
			"content/ui/materials/icons/contracts/complexity_hard",
			"content/ui/materials/icons/contracts/complexity_medium",
			-- Из cosmetics_vendor_background_view_definitions.lua
			"content/ui/materials/icons/item_types/accessories",
			-- Из havoc_play_view_definitions.lua
			"content/ui/textures/icons/generic/havoc_strike",
			"content/ui/materials/icons/engrams/engram_rarity_04",
			"content/ui/textures/icons/engrams/engram_rarity_01",
			"content/ui/materials/icons/mission_types/mission_type_01",
			-- Из inventory_background_view.lua
			"content/ui/materials/icons/items/weapons/melee/empty",
			"content/ui/materials/icons/items/weapons/ranged/empty",
			"content/ui/materials/icons/items/attachments/defensive/empty",
			"content/ui/materials/icons/items/attachments/tactical/empty",
			"content/ui/materials/icons/items/attachments/utility/empty",
			"content/ui/materials/icons/items/gears/head/empty",
			"content/ui/materials/icons/items/gears/arms/empty",
			"content/ui/materials/icons/items/gears/legs/empty",
			"content/ui/materials/icons/item_types/beveled/headgears",
			"content/ui/materials/icons/item_types/beveled/upper_bodies",
			"content/ui/materials/icons/item_types/beveled/lower_bodies",
			"content/ui/materials/icons/item_types/beveled/accessories",
			"content/ui/materials/icons/item_types/beveled/companion_gear_full",
			"content/ui/materials/icons/item_types/outfits",
			-- Из live_events_view_settings.lua
			"content/ui/materials/icons/currencies/premium_big",
			"content/ui/materials/icons/currencies/credits_big",
			"content/ui/materials/icons/currencies/diamantine_big",
			"content/ui/materials/icons/currencies/plasteel_big",
			"content/ui/materials/icons/items/containers/item_container_square",
			-- Из lobby_view_definitions.lua
			"content/ui/materials/icons/generic/havoc",
			"content/ui/materials/icons/generic/checkmark",
			"content/ui/textures/icons/items/frames/default",
			-- Из mission_voting_view_definitions.lua
			"content/ui/materials/icons/difficulty/difficulty_skull_uprising",
			"content/ui/materials/icons/generic/havoc_chevron",
			-- Из penance_overview_view_blueprints.lua
			"content/ui/materials/icons/generic/bookmark",
			"content/ui/materials/icons/achievements/achievement_icon_container_v2",
			"content/ui/textures/icons/achievements/default",
			"content/ui/materials/icons/achievements/frames/achievements_dropshadow_medium",
			"content/ui/materials/icons/generic/top_right_triangle",
			"content/ui/materials/frames/achievements/penance_reward_symbol",
			"content/ui/materials/frames/achievements/penance_reward_symbol_small",
			"content/ui/materials/frames/achievements/penance_reward_symbol_medium",
			"content/ui/materials/frames/achievements/wintrack_claimed_reward_display_background_glow",
			"content/ui/materials/symbols/new_item_indicator",
			-- Из penance_overview_view_settings.lua
			"content/ui/textures/icons/achievements/number_overlays/01",
			"content/ui/textures/icons/achievements/number_overlays/02",
			"content/ui/textures/icons/achievements/number_overlays/03",
			"content/ui/textures/icons/achievements/number_overlays/04",
			"content/ui/textures/icons/achievements/number_overlays/05",
			"content/ui/textures/icons/achievements/number_overlays/06",
			"content/ui/textures/icons/achievements/number_overlays/07",
			"content/ui/textures/icons/achievements/number_overlays/08",
			"content/ui/textures/icons/achievements/number_overlays/09",
			"content/ui/textures/icons/achievements/number_overlays/10",
			"content/ui/materials/icons/achievements/categories/category_account",
			"content/ui/materials/icons/achievements/categories/category_adamant",
			"content/ui/materials/icons/achievements/categories/category_broker",
			"content/ui/materials/icons/achievements/categories/category_endeavour",
			"content/ui/materials/icons/achievements/categories/category_exploration",
			"content/ui/materials/icons/achievements/categories/category_heretics",
			"content/ui/materials/icons/achievements/categories/category_mission",
			"content/ui/materials/icons/achievements/categories/category_ogryn",
			"content/ui/materials/icons/achievements/categories/category_psyker",
			"content/ui/materials/icons/achievements/categories/category_tactical",
			"content/ui/materials/icons/achievements/categories/category_veteran",
			"content/ui/materials/icons/achievements/categories/category_weapons",
			"content/ui/materials/icons/achievements/categories/category_zealot",
			-- Из system_view_content_list.lua
			"content/ui/materials/icons/system/escape/news",
			"content/ui/materials/icons/system/escape/credits",
			"content/ui/materials/icons/system/escape/settings",
			"content/ui/materials/icons/system/escape/leave_party",
			"content/ui/materials/icons/system/escape/quit",
			"content/ui/materials/icons/system/escape/party_finder",
			"content/ui/materials/icons/system/escape/leave_mission",
			-- Из minimap/teammate_status.lua
			"content/ui/materials/mission_board/circumstances/hunting_grounds_01",
			"content/ui/materials/mission_board/circumstances/nurgle_manifestation_01",
			"content/ui/materials/mission_board/circumstances/maelstrom_01",
			"content/ui/materials/mission_board/circumstances/maelstrom_02",
			"content/ui/materials/mission_board/circumstances/special_waves_03",
			"content/ui/materials/mission_board/circumstances/less_resistance_01",
		}
		_register_private(DEFAULT_CUSTOM_ICON_PATHS)
	end
	
	_seed_private_from_vanilla_then_custom()

	mod:info("PRIVATE_ICON_KEYS count: %d", #PRIVATE_ICON_KEYS)

	-- Создаем layout ТОЧНО как в BetterLoadouts (строки 150-157)
	local layout = {}
	for i = 1, #PRIVATE_ICON_KEYS do
		local key = PRIVATE_ICON_KEYS[i]
		local mat = PRIVATE_ICON_LOOKUP[key]
		if mat then
			layout[#layout + 1] = {
				widget_type = "icon_box",
				icon_index = i,
				icon_key = key,
				icon = mat, -- Материал (путь к иконке) для отображения
				icon_path = mat, -- Материал (путь к иконке) для копирования
				icon_path_short = string.match(key, "([^/]+)$") or key,
			}
		end
	end

	mod:info("Layout entries count: %d", #layout)

	local spacing_entry = {
		widget_type = "spacing_vertical"
	}

	table.insert(layout, 1, spacing_entry)
	table.insert(layout, #layout + 1, spacing_entry)

	local left_click_callback = callback(self, "cb_on_icon_left_pressed")

	self._icon_table_element:present_grid_layout(layout, definitions.blueprints, left_click_callback)
	
	mod:info("Loaded %d icons from BetterLoadouts logic", #PRIVATE_ICON_KEYS)
end

IconPathViewerView.cb_on_icon_left_pressed = function(self, widget, element)
	if widget and widget.content then
		local content = widget.content
		-- Для Unicode глифов копируем Unicode код
		if content.unicode_code and element.widget_type == "unicode_icon" then
			Clipboard.put(content.unicode_code)
			mod:notify(mod:localize("msg_copied_path", content.unicode_code))
		-- Для обычных иконок копируем путь
		elseif content.icon_path then
			Clipboard.put(content.icon_path)
			mod:notify(mod:localize("msg_copied_path", content.icon_path))
		end
	end
end

IconPathViewerView._on_back_pressed = function(self)
	Managers.ui:close_view(self.view_name)
end

IconPathViewerView._destroy_renderer = function(self)
	if self._offscreen_renderer then
		self._offscreen_renderer = nil
	end

	local world_data = self._offscreen_world

	if world_data then
		Managers.ui:destroy_renderer(world_data.renderer_name)
		ScriptWorld.destroy_viewport(world_data.world, world_data.viewport_name)
		Managers.ui:destroy_world(world_data.world)

		world_data = nil
	end
end

IconPathViewerView.update = function(self, dt, t, input_service)
	return IconPathViewerView.super.update(self, dt, t, input_service)
end

IconPathViewerView.draw = function(self, dt, t, input_service, layer)
	return IconPathViewerView.super.draw(self, dt, t, input_service, layer)
end

IconPathViewerView._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	IconPathViewerView.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

IconPathViewerView.on_exit = function(self)
	IconPathViewerView.super.on_exit(self)

	self:_destroy_renderer()
end

return IconPathViewerView

