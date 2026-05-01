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
        en = "Master switch: must be on for team panel and nameplate name replacement to run.",
        ru = "Общий переключатель: без него замена имён в панели команды и неймплейтах не выполняется.",
    },

    -- Настройки элементов UI
    enable_random_console_accounts = {
        en = "Generate console platform accounts",
        ru = "Генерация аккаунтов игровых консолей",
    },
    enable_random_console_accounts_description = {
        en = "Replaces squad expanded-view account names and platform (Steam, Xbox, PlayStation) with deterministic fakes for screenshots. Independent from random character names.",
        ru = "Подменяет имена аккаунтов и платформу (Steam, Xbox, PlayStation) в расширенном виде отряда на детерминированные вымышленные значения для скриншотов. Не зависит от случайных имён персонажей.",
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
