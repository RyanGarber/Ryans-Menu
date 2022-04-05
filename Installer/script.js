const {BrowserWindow, dialog} = require('@electron/remote');
const fs = require('fs');

const luaScriptsFolder = process.env.APPDATA + '\\Stand\\Lua Scripts';
const source = 'https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main/Source';

$('#installer').hide();

$.get('https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main/MANIFEST').done((manifest) => {
    let version = manifest.split('\n')[0];
    let contents = JSON.parse(manifest.split('\n').splice(1).join('\n'));

    $('#version').text(version);
    $('#loading').fadeOut();
    $('#installer').fadeIn();

    $('#install').click(function() {
        // Check for any file named "^Ryan.*\.lua$" but not exactly correct.
        // If it exists, ask to delete it. Write or overwrite the lua file and its resources.
        $('#loading').fadeIn();

        // Detect incorrect Lua name
        let luaScripts = fs.readdirSync(luaScriptsFolder);
        for(let i = 0; i < luaScripts.length; i++) {
            if(/^.*[Rr]yan.*$/.test(luaScripts[i])) {
                if(luaScripts[i] != contents.main) {
                    let response = dialog.showMessageBoxSync({
                        type: 'question',
                        message: 'Another Lua Script was found named "' + luaScripts[i] + '". Would you like to replace it?',
                        buttons: ['Replace It', 'Keep Both']
                    });
                    if(response === 0) {
                        fs.unlinkSync(luaScriptsFolder + '\\' + luaScripts[i]);
                    }
                }
            }
        }

        // Install the main script.
        if(fs.existsSync(luaScriptsFolder + '\\' + contents.main)) {
            fs.unlinkSync(luaScriptsFolder + '\\' + contents.main);
        }
        $.get(source + '/' + contents.main).done((data) => {
            fs.writeFileSync(luaScriptsFolder + '\\' + contents.main, data);
        });

        // Count required files.
        let fileCount = 0;
        for(let type in contents) {
            if(type == 'main') continue;
            fileCount += contents[type].length;
        }
        let filesSaved = 0;

        // Download required files.
        for(let type in contents) {
            for(let i = 0; i < contents[type].length; i++) {
                $.get(source + '/' + type + '/' + contents[type][i]).done((data) => {
                    if(fs.existsSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu')) {
                        fs.rmdirSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu');
                    }
                    fs.mkdirSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu')
                    fs.writeFileSync(luaScripts + '\\' + type + '\\Ryan\'s Menu\\' + contents[type][i], data);
                    filesSaved++;

                    // Show alert when finished.
                    if(filesSaved == fileCount) {
                        let response = dialog.showMessageBox({
                            type: 'info',
                            message: 'Ryan\'s Menu has been successfully installed! Go back to Grand Theft Auto V to continue.'
                        });
                    }
                }).fail(() => {
                    dialog.showMessageBoxSync({
                        type: 'error',
                        message: 'Failed to download required file: "' + type + '/' + contents[type][i] + '".'
                    });
                });
            }
        }
    });
}).fail(() => {
    dialog.showMessageBoxSync({
        type: 'error',
        message: 'Failed to get the latest version. Check your internet connection and try again.'
    });
});