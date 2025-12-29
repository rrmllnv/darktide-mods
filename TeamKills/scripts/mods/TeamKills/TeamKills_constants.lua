local mod = get_mod("TeamKills")

mod.melee_lessers = {
	"chaos_newly_infected",
	"chaos_poxwalker",
	"chaos_mutated_poxwalker",
	"chaos_armored_infected",
	"cultist_melee",
	"cultist_ritualist",
	"chaos_mutator_ritualist",
	"renegade_melee",
}

mod.ranged_lessers = {
	"chaos_lesser_mutated_poxwalker",
	"cultist_assault",
	"renegade_assault",
	"renegade_rifleman",
}

mod.melee_elites = {
	"cultist_berzerker",
	"renegade_berzerker",
	"renegade_executor",
	"chaos_ogryn_bulwark",
	"chaos_ogryn_executor",
}

mod.ranged_elites = {
	"cultist_gunner",
	"renegade_gunner",
	"renegade_plasma_gunner",
	"renegade_radio_operator",
	"cultist_shocktrooper",
	"renegade_shocktrooper",
	"chaos_ogryn_gunner",
}

mod.specials = {
	"chaos_poxwalker_bomber",
	"renegade_grenadier",
	"cultist_grenadier",
	"renegade_sniper",
	"renegade_flamer",
	"renegade_flamer_mutator",
	"cultist_flamer",
}

mod.disablers = {
	"chaos_hound",
	"chaos_hound_mutator",
	"cultist_mutant",
	"cultist_mutant_mutator",
	"renegade_netgunner",
}

mod.bosses = {
	"chaos_beast_of_nurgle",
	"chaos_daemonhost",
	"chaos_mutator_daemonhost",
	"chaos_spawn",
	"chaos_plague_ogryn",
	"chaos_plague_ogryn_sprayer",
	"renegade_captain",
	"cultist_captain",
	"renegade_twin_captain",
	"renegade_twin_captain_two",
}

mod.color_presets = {
	white = {255, 255, 255},
	red = {255, 54, 36},
	green = {61, 112, 55},
	blue = {30, 144, 255},
	yellow = {226, 199, 126},
	orange = {255, 183, 44},
	purple = {166, 93, 172},
	cyan = {107, 209, 241},
	teal = {62, 143, 155},
	gold = {196, 195, 108},
	purple_deep = {130, 66, 170},
	magenta = {102, 38, 98},
	orange_dark = {148, 46, 14},
	orange_medium = {245, 121, 21},
	amber = {191, 151, 73},
	grey = {102, 102, 102},
}

mod.DEFAULT_KILLSTREAK_DURATION = 2.5
mod.DEFAULT_FONT_SIZE = 16
mod.DEFAULT_OPACITY = 100

mod.KILLSTREAK_DURATION_EASY = 4
mod.KILLSTREAK_DURATION_NORMAL = 2.5
mod.KILLSTREAK_DURATION_HARD = 1
