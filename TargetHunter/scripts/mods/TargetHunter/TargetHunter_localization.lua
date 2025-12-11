local localizations = {
	mod_name = {
		en = "Target Hunter",
		ru = "Охотник за Целью",
	},
	mod_description = {
		en = "Adds HUD world markers for elite and boss enemies to show their position.",
		ru = "Добавляет маркеры на HUD для элитных и боссов, показывая их позицию.",
	},
	enable_bosses = {
		en = "Track bosses",
		ru = "Отмечать боссов",
	},
	enable_bosses_description = {
		en = "Show markers on boss/monster enemies.",
		ru = "Показывать маркеры на босcах/монстрах.",
	},
	enable_elites = {
		en = "Track elites",
		ru = "Отмечать элиту",
	},
	enable_elites_description = {
		en = "Show markers on elite/special enemies.",
		ru = "Показывать маркеры на элитных/спец врагах.",
	},
	max_distance = {
		en = "Max distance",
		ru = "Макс. дистанция",
	},
	max_distance_description = {
		en = "Hide markers farther than this distance.",
		ru = "Скрывать маркеры дальше этой дистанции.",
	},

	-- Groups
	bosses_group = { en = "Bosses", ru = "Боссы" },
	elites_group = { en = "Elites", ru = "Элита" },
	specials_group = { en = "Specials", ru = "Специалисты" },

	-- Bosses
	boss_beast_of_nurgle = { en = "Beast of Nurgle", ru = "Зверь Нургла" },
	boss_chaos_spawn = { en = "Chaos Spawn", ru = "Порождение Хаоса" },
	boss_plague_ogryn = { en = "Plague Ogryn", ru = "Чумной огрин" },
	boss_daemonhost = { en = "Daemonhost", ru = "Демонхост" },
	boss_renegade_captain = { en = "Renegade Captain", ru = "Капитан отступников" },
	boss_renegade_twins = { en = "Renegade Twin Captains", ru = "Капитаны-близнецы" },
	boss_cultist_captain = { en = "Cultist Captain", ru = "Капитан культистов" },

	-- Elites
	elite_chaos_ogryn_gunner = { en = "Chaos Ogryn Gunner", ru = "Огрин-хаосит стрелок" },
	elite_chaos_ogryn_executor = { en = "Chaos Ogryn Executor", ru = "Каратель огрин-хаосит" },
	elite_chaos_ogryn_bulwark = { en = "Chaos Ogryn Bulwark", ru = "Огрин-хаосит щитоносец" },
	elite_renegade_shocktrooper = { en = "Renegade Shocktrooper", ru = "Штурмовик-отступник" },
	elite_renegade_plasma_gunner = { en = "Renegade Plasma Gunner", ru = "Плазменщик-отступник" },
	elite_renegade_radio_operator = { en = "Renegade Radio Operator", ru = "Радиооператор-отступник" },
	elite_renegade_gunner = { en = "Renegade Gunner", ru = "Стрелок-отступник" },
	elite_renegade_executor = { en = "Renegade Executor", ru = "Каратель-отступник" },
	elite_renegade_berzerker = { en = "Renegade Berzerker", ru = "Берсерк-отступник" },
	elite_cultist_shocktrooper = { en = "Cultist Shocktrooper", ru = "Штурмовик-культист" },
	elite_cultist_gunner = { en = "Cultist Gunner", ru = "Стрелок-культист" },
	elite_cultist_berzerker = { en = "Cultist Berzerker", ru = "Берсерк-культист" },

	-- Specials
	special_poxburster = { en = "Poxburster", ru = "Поксбурстер" },
	special_hound = { en = "Hound", ru = "Пёс Хаоса" },
	special_mutant = { en = "Mutant", ru = "Мутант" },
	special_cultist_flamer = { en = "Cultist Flamer", ru = "Культист-поджигатель" },
	special_cultist_grenadier = { en = "Cultist Grenadier", ru = "Гренадёр-культист" },
	special_renegade_flamer = { en = "Renegade Flamer", ru = "Поджигатель-отступник" },
	special_renegade_grenadier = { en = "Renegade Grenadier", ru = "Гренадёр-отступник" },
	special_renegade_sniper = { en = "Renegade Sniper", ru = "Снайпер-отступник" },
	special_renegade_netgunner = { en = "Renegade Netgunner", ru = "Сетемёт-отступник" },
}

-- Локализация цветов c подсветкой (как в StimmCountdown)
local InputUtils = require("scripts/managers/input/input_utils")
local function readable(text)
	local readable_string = ""
	for token in string.gmatch(text, "([^_]+)") do
		local first = string.sub(token, 1, 1)
		token = string.format("%s%s", string.upper(first), string.sub(token, 2))
		readable_string = string.trim(string.format("%s %s", readable_string, token))
	end
	return readable_string
end

for _, color_name in ipairs(Color.list) do
	local color_values = Color[color_name](100, true)
	local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
	localizations[color_name] = { en = text, ru = text }
end

-- Подписи для color dropdown'ов (используем цветные варианты)
local color_targets = {
	"boss_beast_of_nurgle",
	"boss_chaos_spawn",
	"boss_plague_ogryn",
	"boss_daemonhost",
	"boss_renegade_captain",
	"boss_renegade_twins",
	"boss_cultist_captain",

	"elite_chaos_ogryn_gunner",
	"elite_chaos_ogryn_executor",
	"elite_chaos_ogryn_bulwark",
	"elite_renegade_shocktrooper",
	"elite_renegade_plasma_gunner",
	"elite_renegade_radio_operator",
	"elite_renegade_gunner",
	"elite_renegade_executor",
	"elite_renegade_berzerker",
	"elite_cultist_shocktrooper",
	"elite_cultist_gunner",
	"elite_cultist_berzerker",

	"special_poxburster",
	"special_hound",
	"special_mutant",
	"special_cultist_flamer",
	"special_cultist_grenadier",
	"special_renegade_flamer",
	"special_renegade_grenadier",
	"special_renegade_sniper",
	"special_renegade_netgunner",
}

for _, base in ipairs(color_targets) do
	local key = base .. "_color"
	local base_loc = localizations[base]
	localizations[key] = {
		en = base_loc and (base_loc.en .. " color") or key,
		ru = base_loc and (base_loc.ru .. " (цвет)") or key,
	}
end

return localizations
