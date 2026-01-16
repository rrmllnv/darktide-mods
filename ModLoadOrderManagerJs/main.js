const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs').promises;
const { existsSync, readdirSync, statSync, lstatSync, symlink } = require('fs');
const { promisify } = require('util');
const symlinkAsync = promisify(symlink);

// Путь к файлу mod_load_order.txt по умолчанию
const DEFAULT_PATH = 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Warhammer 40,000 DARKTIDE\\mods\\mod_load_order.txt';

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 980,
    height: 900,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    title: 'Mod Load Order Manager',
    autoHideMenuBar: true // Скрываем стандартное меню Electron
  });

  mainWindow.loadFile('app/index.html');

  // Полностью скрываем меню
  mainWindow.setMenuBarVisibility(false);

  // Открываем DevTools в режиме разработки
  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// IPC обработчики

// Получить путь по умолчанию
ipcMain.handle('get-default-path', () => {
  return DEFAULT_PATH;
});

// Проверить существование файла
ipcMain.handle('file-exists', async (event, filePath) => {
  try {
    return existsSync(filePath);
  } catch (error) {
    return false;
  }
});

// Загрузить файл
ipcMain.handle('load-file', async (event, filePath) => {
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    return { success: true, content };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Сохранить файл
ipcMain.handle('save-file', async (event, filePath, content) => {
  try {
    await fs.writeFile(filePath, content, 'utf-8');
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Выбрать файл через диалог
ipcMain.handle('select-file', async (event, defaultPath) => {
  const result = await dialog.showOpenDialog(mainWindow, {
    title: 'Выберите mod_load_order.txt',
    defaultPath: defaultPath,
    filters: [
      { name: 'Text files', extensions: ['txt'] },
      { name: 'All files', extensions: ['*'] }
    ],
    properties: ['openFile']
  });

  if (result.canceled) {
    return { success: false, canceled: true };
  }

  return { success: true, filePath: result.filePaths[0] };
});

// Сканировать папку модов
ipcMain.handle('scan-mods-directory', async (event, modsDir) => {
  try {
    if (!existsSync(modsDir)) {
      return { success: false, error: 'Папка не существует' };
    }

    const items = readdirSync(modsDir);
    const newMods = [];
    const symlinkMods = new Map(); // Карта: имя мода -> является ли симлинком

    for (const item of items) {
      const itemPath = path.join(modsDir, item);
      
      // Используем lstatSync для проверки симлинков (не следует по ссылкам)
      const stats = lstatSync(itemPath);
      const isSymlink = stats.isSymbolicLink();
      
      // Пропускаем файлы, ищем только папки (включая симлинки на папки)
      if (!stats.isDirectory() && !isSymlink) {
        continue;
      }
      
      // Проверяем, является ли это симлинком
      // Если симлинк, проверяем, указывает ли он на папку
      if (isSymlink) {
        try {
          // Проверяем, на что указывает симлинк
          const targetStats = statSync(itemPath);
          if (!targetStats.isDirectory()) {
            continue; // Симлинк указывает не на папку
          }
        } catch (e) {
          // Симлинк указывает на несуществующий путь - пропускаем
          continue;
        }
      }

      // Пропускаем служебные папки
      if (item.startsWith('_') || ['base', 'dmf'].includes(item.toLowerCase())) {
        continue;
      }

      // Проверяем наличие файла .mod в папке
      const modFile = path.join(itemPath, `${item}.mod`);
      if (existsSync(modFile)) {
        newMods.push(item);
        symlinkMods.set(item, isSymlink);
      }
    }

    return { success: true, mods: newMods.sort(), symlinks: symlinkMods };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Получить путь к папке профилей
ipcMain.handle('get-profiles-directory', async (event, modsDir) => {
  try {
    let profilesDir = path.join(modsDir, 'ModLoadOrderManager_profiles');
    
    // Пытаемся создать папку
    if (!existsSync(profilesDir)) {
      try {
        await fs.mkdir(profilesDir, { recursive: true });
      } catch (error) {
        // Если нет прав, используем папку рядом с программой
        profilesDir = path.join(__dirname, 'profiles');
        await fs.mkdir(profilesDir, { recursive: true });
      }
    }

    return { success: true, path: profilesDir };
  } catch (error) {
    try {
      // Последняя попытка - папка рядом с программой
      const profilesDir = path.join(__dirname, 'profiles');
      await fs.mkdir(profilesDir, { recursive: true });
      return { success: true, path: profilesDir };
    } catch (error2) {
      return { success: false, error: error2.message };
    }
  }
});

// Получить список профилей
ipcMain.handle('list-profiles', async (event, profilesDir) => {
  try {
    if (!existsSync(profilesDir)) {
      return { success: true, profiles: [] };
    }

    const files = readdirSync(profilesDir);
    const profiles = files
      .filter(file => file.endsWith('.json'))
      .map(file => file.slice(0, -5)); // Убираем .json

    return { success: true, profiles };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Сохранить профиль
ipcMain.handle('save-profile', async (event, profilesDir, profileName, state) => {
  try {
    if (!existsSync(profilesDir)) {
      await fs.mkdir(profilesDir, { recursive: true });
    }

    const profilePath = path.join(profilesDir, `${profileName}.json`);
    await fs.writeFile(profilePath, JSON.stringify(state, null, 2), 'utf-8');
    
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Загрузить профиль
ipcMain.handle('load-profile', async (event, profilesDir, profileName) => {
  try {
    const profilePath = path.join(profilesDir, `${profileName}.json`);
    const content = await fs.readFile(profilePath, 'utf-8');
    const state = JSON.parse(content);
    
    return { success: true, state };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Удалить профиль
ipcMain.handle('delete-profile', async (event, profilesDir, profileName) => {
  try {
    const profilePath = path.join(profilesDir, `${profileName}.json`);
    if (existsSync(profilePath)) {
      await fs.unlink(profilePath);
      return { success: true };
    }
    return { success: false, error: 'Файл не найден' };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Переименовать профиль
ipcMain.handle('rename-profile', async (event, profilesDir, oldName, newName) => {
  try {
    const oldPath = path.join(profilesDir, `${oldName}.json`);
    const newPath = path.join(profilesDir, `${newName}.json`);
    
    if (!existsSync(oldPath)) {
      return { success: false, error: 'Файл не найден' };
    }
    
    if (existsSync(newPath)) {
      return { success: false, error: 'Профиль с таким именем уже существует' };
    }
    
    await fs.rename(oldPath, newPath);
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Создать символическую ссылку
ipcMain.handle('create-symlink', async (event, linkPath, targetPath) => {
  try {
    // Проверяем, существует ли уже симлинк или папка
    if (existsSync(linkPath)) {
      // Проверяем, является ли это симлинком
      try {
        const stats = await fs.lstat(linkPath);
        if (stats.isSymbolicLink()) {
          return { success: false, error: 'Символическая ссылка уже существует' };
        } else {
          return { success: false, error: 'Папка или файл с таким именем уже существует' };
        }
      } catch (e) {
        return { success: false, error: 'Папка или файл с таким именем уже существует' };
      }
    }
    
    // Проверяем, существует ли целевая папка
    if (!existsSync(targetPath)) {
      return { success: false, error: 'Целевая папка не существует' };
    }
    
    // Создаем символическую ссылку
    // На Windows нужно использовать 'junction' для директорий или 'dir' для символических ссылок
    // 'dir' работает только с правами администратора или в Developer Mode
    const linkType = process.platform === 'win32' ? 'junction' : 'dir';
    
    try {
      await symlinkAsync(targetPath, linkPath, linkType);
      return { success: true };
    } catch (error) {
      // Если не получилось создать junction, пробуем dir (требует прав администратора)
      if (process.platform === 'win32' && linkType === 'junction') {
        try {
          await symlinkAsync(targetPath, linkPath, 'dir');
          return { success: true };
        } catch (e) {
          return { 
            success: false, 
            error: `Не удалось создать символическую ссылку. Возможно, нужны права администратора или включен Developer Mode. Ошибка: ${e.message}` 
          };
        }
      }
      throw error;
    }
  } catch (error) {
    return { success: false, error: error.message };
  }
});

// Выбрать папку через диалог
ipcMain.handle('select-folder', async (event, defaultPath) => {
  const result = await dialog.showOpenDialog(mainWindow, {
    title: 'Выберите папку с модом',
    defaultPath: defaultPath,
    properties: ['openDirectory']
  });

  if (result.canceled) {
    return { success: false, canceled: true };
  }

  return { success: true, folderPath: result.filePaths[0] };
});
