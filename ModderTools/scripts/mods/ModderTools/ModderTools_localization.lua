return {
    mod_name = {
        en = "ModderTools",
        ru = "Инструменты моддера",
    },
    mod_description = {
        en = "Tools for modders: replace player names with random ones for screenshots",
        ru = "Инструменты для моддеров: замена имен игроков на случайные для скриншотов",
    },

    -- Основные настройки
    enable_random_names = {
        en = "Enable Random Names",
        ru = "Включить случайные имена",
    },
    enable_random_names_description = {
        en = "Master switch for random character names in ModderTools hooks (team panel, nameplates). When on, Squad HUD expanded view also replaces platform account names with deterministic fakes (same pool as console-account option).",
        ru = "Общий переключатель случайных имён персонажа в хуках ModderTools (панель команды, неймплейты). Если включено, в расширенном Squad HUD подменяются и имена платформенных аккаунтов на детерминированные вымышленные (тот же пул, что у опции консольных аккаунтов).",
    },

    -- Настройки элементов UI
    enable_random_console_accounts = {
        en = "Generate console platform accounts",
        ru = "Генерация аккаунтов игровых консолей",
    },
    enable_random_console_accounts_description = {
        en = "Replaces Squad HUD expanded-view account names with one entry from the fixed Warhammer 40K name list (exact spelling, no extra suffixes). Platform icon is still picked among Steam / Xbox / PlayStation for the panel. Use without \"Random Names\" if you only want to hide account strings while keeping character names real.",
        ru = "Подмена имени аккаунта в расширенном Squad HUD одной строкой из фиксированного списка имён Warhammer 40K (как в списке, без суффиксов и цифр). Иконка платформы по-прежнему выбирается между Steam / Xbox / PlayStation. Можно включить без «случайных имён», если нужно скрыть только строку аккаунта.",
    },

    preserve_local_player_identity = {
        en = "Keep local player name and account real",
        ru = "Не подменять ник и аккаунт локального игрока",
    },
    preserve_local_player_identity_description = {
        en = "When on, random names and fake console accounts never apply to your own player (local human). Other players are still substituted when the options above are enabled.",
        ru = "Если включено, случайные имена и подставные аккаунты консолей не применяются к вашему персонажу (локальный человек). Остальные игроки по-прежнему подменяются при включённых опциях выше.",
    },

    enable_team_panel = {
        en = "Replace Names in Team Panel",
        ru = "Замена имен в панели команды",
    },
    enable_team_panel_description = {
        en = "Replaces names in the team panel",
        ru = "Заменяет имена в панели тимейтов",
    },

    enable_nameplate = {
        en = "Replace Names in Nameplates",
        ru = "Замена имен в неймплейтах",
    },
    enable_nameplate_description = {
        en = "World markers above players (mission uses nameplate_party, not template \"nameplate\"). Requires \"Enable Random Names\".",
        ru = "Маркеры над игроками в мире (в миссии — тип nameplate_party). Нужно включить «Включить случайные имена».",
    },
}
