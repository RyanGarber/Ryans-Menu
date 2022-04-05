const {BrowserWindow, dialog} = require('@electron/remote');
const fs = require('fs');

const luaScriptsFolder = process.env.APPDATA + '\\Stand\\Lua Scripts';
const source = 'https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main/Source';

$('#installer').hide();

$.get('https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main/VERSION').done((manifest) => {
    manifest =
`0.5.4
{
    "main": "Ryan's Menu.lua",
    "resources": ["Crosshair.png"]
}`;
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
                console.log(luaScripts[i] + ' == ' + contents.main + '?'); // test
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

        // Install the script.
        if(fs.existsSync(luaScriptsFolder + '\\' + contents.main)) {
            fs.unlinkSync(luaScriptsFolder + '\\' + contents.main);
        }
        $.get(source + '/' + contents.main).done(function(data) {
            fs.writeFileSync(luaScriptsFolder + '\\' + contents.main, data);
        });
        
        dialog.showMessageBox({
            type: 'info',
            message: 'Install main file: ' + contents.main
        }).then((response, checkboxChecked) => {
            for(let type in contents) {
                if(type == 'main') continue;

                dialog.showMessageBox({
                    type: 'info',
                    message: 'Install files in "' + type + '": [' + contents[type].join(', ') + ']'
                }).then((response) => {
                    dialog.showMessageBox({
                        type: 'info',
                        message: 'Done!'
                    }).then((response) => {
                        $('#loading').fadeOut();
                    });
                });
            }
        });
    });
}).fail(() => {
    alert('Failed to find the latest version. Check your internet connection and try again.');
});