const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs').promises;
const { existsSync, readdirSync, statSync } = require('fs');

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
    title: 'Mod Load Order Manager'
  });

  mainWindow.loadFile('index.html');

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

    for (const item of items) {
      const itemPath = path.join(modsDir, item);
      
      // Пропускаем файлы, ищем только папки
      if (!statSync(itemPath).isDirectory()) {
        continue;
      }

      // Пропускаем служебные папки
      if (item.startsWith('_') || ['base', 'dmf'].includes(item.toLowerCase())) {
        continue;
      }

      // Проверяем наличие файла .mod в папке
      const modFile = path.join(itemPath, `${item}.mod`);
      if (existsSync(modFile)) {
        newMods.push(item);
      }
    }

    return { success: true, mods: newMods.sort() };
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
