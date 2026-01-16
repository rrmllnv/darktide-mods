const { contextBridge, ipcRenderer } = require('electron');

// Предоставляем безопасный API для renderer процесса
contextBridge.exposeInMainWorld('electronAPI', {
  getDefaultPath: () => ipcRenderer.invoke('get-default-path'),
  fileExists: (filePath) => ipcRenderer.invoke('file-exists', filePath),
  loadFile: (filePath) => ipcRenderer.invoke('load-file', filePath),
  saveFile: (filePath, content) => ipcRenderer.invoke('save-file', filePath, content),
  selectFile: (defaultPath) => ipcRenderer.invoke('select-file', defaultPath),
  scanModsDirectory: (modsDir) => ipcRenderer.invoke('scan-mods-directory', modsDir),
  getProfilesDirectory: (modsDir) => ipcRenderer.invoke('get-profiles-directory', modsDir),
  listProfiles: (profilesDir) => ipcRenderer.invoke('list-profiles', profilesDir),
  saveProfile: (profilesDir, profileName, state) => ipcRenderer.invoke('save-profile', profilesDir, profileName, state),
  loadProfile: (profilesDir, profileName) => ipcRenderer.invoke('load-profile', profilesDir, profileName),
  deleteProfile: (profilesDir, profileName) => ipcRenderer.invoke('delete-profile', profilesDir, profileName),
  renameProfile: (profilesDir, oldName, newName) => ipcRenderer.invoke('rename-profile', profilesDir, oldName, newName),
  createSymlink: (linkPath, targetPath) => ipcRenderer.invoke('create-symlink', linkPath, targetPath),
  selectFolder: (defaultPath) => ipcRenderer.invoke('select-folder', defaultPath)
});
