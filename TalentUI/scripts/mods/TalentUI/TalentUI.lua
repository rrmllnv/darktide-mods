local mod = get_mod("TalentUI")

-- Подключение модулей для тимейтов и локального игрока
-- TalentUI_teammate_all_abilities показывает все 3 способности (ability, blitz, aura) для тимейтов
mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_teammate_all_abilities")
-- Старые модули (отключены, так как функциональность покрыта TalentUI_teammate_all_abilities):
-- mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_teammate_ability")
-- mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_teammate_blitz")
mod:io_dofile("TalentUI/scripts/mods/TalentUI/TalentUI_local_ability")

