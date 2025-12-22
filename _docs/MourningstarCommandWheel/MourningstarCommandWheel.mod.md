# MourningstarCommandWheel.mod - Документация

## Описание файла

Файл регистрации мода в системе Darktide Mod Framework. Определяет метаданные мода и пути к основным файлам.

## Структура

Файл возвращает таблицу с двумя полями:

### `run`
Функция инициализации мода, которая вызывается при загрузке.

**Логика:**
1. Проверяет наличие `new_mod` в глобальной области видимости
2. Регистрирует мод с именем `"MourningstarCommandWheel"`
3. Указывает пути к основным файлам:
   - `mod_script` - основной файл мода (`MourningstarCommandWheel.lua`)
   - `mod_data` - файл данных мода (`MourningstarCommandWheel_data.lua`)
   - `mod_localization` - файл локализации (`MourningstarCommandWheel_localization.lua`)

### `packages`
Массив пакетов, необходимых для работы мода. В данном случае пустой массив `{}`, так как мод не требует дополнительных пакетов.

## Использование

Этот файл загружается автоматически системой модов игры при запуске. Он должен находиться в корневой папке мода и иметь имя `{mod_name}.mod`.

## Связанные файлы

- `MourningstarCommandWheel.lua` - основной файл мода
- `MourningstarCommandWheel_data.lua` - данные мода
- `MourningstarCommandWheel_localization.lua` - локализация

