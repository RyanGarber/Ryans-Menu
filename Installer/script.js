const {BrowserWindow, dialog} = require('@electron/remote');
const https = require('https'), stream = require('stream').Transform;
const fs = require('fs');

const luaScriptsFolder = process.env.APPDATA + '\\Stand\\Lua Scripts';
const source = 'https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main/Source';

$('#installer').hide();

$.get('https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main/MANIFEST').done((manifest) => {
    let version = manifest.split('\n')[0];
    let contents = JSON.parse(manifest.split('\n').splice(1).join('\n'));
    console.log('Received manifest for version ' + version + '.', contents);

    // Detect installed version
    if(fs.existsSync(luaScriptsFolder + '\\Ryan\'s Menu.lua')) {
        try {
            let installedScript = fs.readFileSync(luaScriptsFolder + '\\Ryan\'s Menu.lua', 'utf8');
            let installedVersion = installedScript.split('\n')[0].replace('VERSION = "', '').replace('"', '');
            $('.install-type').text(installedVersion == version ? 'Reinstall' : 'Update');
            $('#installed-version').text('You currently have v' + installedVersion + '.');
        }
        catch(e) {
            $('.install-type').text('Install');
        }
    }
    else {
        $('.install-type').text('Install');
    }

    $('#version').text(version);
    $('#loading').fadeOut();
    $('#installer').fadeIn();

    $('#install').click(function() {
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
        console.log('Cleaned main script file.');

        $.get(source + '/' + contents.main).done((data) => {
            fs.writeFileSync(luaScriptsFolder + '\\' + contents.main, data);
            console.log('Saved main script file.');
        }).fail(() => {
            console.error('Failed to get main script file.', details);
        });

        // Count required files.
        let fileCount = 0;
        for(let type in contents) {
            if(type == 'main') continue;
            fileCount += contents[type].length;
        }
        console.log('Ready to install ' + fileCount + ' file(s).');

        // Download required files.
        let filesSaved = 0;
        for(let type in contents) {
            if(type == 'main') continue;
            
            if(!fs.existsSync(luaScriptsFolder + '\\' + type)) fs.mkdirSync(luaScriptsFolder + '\\' + type);
            if(fs.existsSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu')) {
                fs.rmSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu', {recursive: true, force: true});
            }
            fs.mkdirSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu')
            console.log('Cleaned directory ' + type + '.');
            
            for(let i = 0; i < contents[type].length; i++) {
                https.request(source + '/' + type + '/' + contents[type][i], (response) => {
                    let data = new stream();
                    response.on('data', (chunk) => {
                        data.push(chunk);
                    });
                    response.on('end', () => {
                        fs.writeFileSync(luaScriptsFolder + '\\' + type + '\\Ryan\'s Menu\\' + contents[type][i], data.read());
                        filesSaved++;
                        console.log('Saved file ' + contents[type][i] + ' in directory ' + type + '.');

                        // Show alert when finished.
                        if(filesSaved == fileCount) {
                            dialog.showMessageBox({
                                type: 'info',
                                message: 'Ryan\'s Menu has been successfully installed! You may now go back to Grand Theft Auto V.'
                            });
                            $('#loading').fadeOut();
                            console.log(filesSaved + '/' + fileCount + ' files saved. Ready to go!');
                        }
                    });
                }).end();
                
                /*fail((details) => {
                    console.error('Failed to get file: ' + contents[type][i] + ' for directory ' + type + '.', details);
                    dialog.showMessageBoxSync({
                        type: 'error',
                        message: 'Failed to download required file: "' + type + '/' + contents[type][i] + '".'
                    });
                });*/
            }
        }
    });
}).fail((details) => {
    console.error('Failed to get manifest.', details);
    dialog.showMessageBoxSync({
        type: 'error',
        message: 'Failed to get the latest version. Check your internet connection and try again.'
    });
});