const {app, BrowserWindow} = require('electron');

app.whenReady().then(() => {
    const window = new BrowserWindow({
        width: 650,
        height: 300,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    require('@electron/remote/main').initialize();
    require('@electron/remote/main').enable(window.webContents);
    window.loadFile('index.html');
});

app.on('window-all-closed', () => { app.quit(); });
