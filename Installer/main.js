const {app, dialog, BrowserWindow} = require('electron');

app.whenReady().then(() => {
    const window = new BrowserWindow({
        width: 650,
        height: 300,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });
    
    window.loadFile('index.html');
    require('@electron/remote/main').initialize()
    require('@electron/remote/main').enable(window.webContents);
});

app.on('window-all-closed', () => { app.quit(); });
