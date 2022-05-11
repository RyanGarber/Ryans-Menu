const https = require('https'), stream = require('stream').Transform;
const fs = require('fs');

const lua_scripts = process.env.APPDATA + '\\Stand\\Lua Scripts';
const repository = 'https://raw.githubusercontent.com/RyanGarber/Ryans-Menu/main';

let latest_version = null;
let contents = null;

let installed_version = null;
let possible_duplicate = null;

let possible_duplicate_modal_opened = -1;
let install_complete_modal_opened = -1;

function purge(directory) {
    var files = fs.readdirSync(directory);
    files.forEach((file) => {
        var file_path = directory + "/" + file;
        if(fs.lstatSync(file_path).isDirectory()) purge(file_path);
        else fs.unlinkSync(file_path);
    });
    fs.rmdirSync(directory);
}

setInterval(() => {
    if(possible_duplicate_modal_opened !== -1 && Date.now() - possible_duplicate_modal_opened > 500) {
        if(!$('#confirm-replace').is('.show')) {
            $('#loading').fadeOut();
            $('#installer').fadeIn();
            possible_duplicate_modal_opened = -1;
        }
    }

    if(install_complete_modal_opened !== -1 && Date.now() - install_complete_modal_opened > 500) {
        if(!$('#install-complete').is('.show')) {
            window.location.reload();
            install_complete_modal_opened = -1;
        }
    }
}, 1);

// Install
function install() {
    // Install the main script.
    if(fs.existsSync(lua_scripts + '\\' + contents.main)) {
        fs.unlinkSync(lua_scripts + '\\' + contents.main);
    }
    console.log('Removed old script file');

    $.get(repository + '/Source/' + contents.main).done((data) => {
        fs.writeFileSync(lua_scripts + '\\' + contents.main, data);
        console.log('Saved new script file');
    });

    // Count required files.
    let file_count = 0;
    for(let type in contents) {
        if(type == 'main') continue;
        file_count += contents[type].length;
    }

    // Download required files.
    let files_saved = 0;
    for(let type in contents) {
        if(type == 'main') continue;
        
        if(!fs.existsSync(lua_scripts + '\\' + type)) fs.mkdirSync(lua_scripts + '\\' + type);
        if(fs.existsSync(lua_scripts + '\\' + type + '\\Ryan\'s Menu')) {
            purge(lua_scripts + '\\' + type + '\\Ryan\'s Menu');
        }
        fs.mkdirSync(lua_scripts + '\\' + type + '\\Ryan\'s Menu')
        console.log('Purged directory: .../' + type + '/Ryan\'s Menu/');
        
        for(let i = 0; i < contents[type].length; i++) {
            https.request(repository + '/Source/' + type + '/' + contents[type][i], (response) => {
                let data = new stream();
                response.on('data', (chunk) => {
                    data.push(chunk);
                });
                response.on('end', () => {
                    fs.writeFileSync(lua_scripts + '\\' + type + '\\Ryan\'s Menu\\' + contents[type][i], data.read());
                    files_saved++;
                    console.log('Saved .../' + type + '/' + contents[type][i] + ' (' + files_saved + '/' + file_count + ')');

                    // Install complete
                    if(files_saved == file_count) {
                        install_complete_modal_opened = Date.now();
                        $('#install-complete').modal('show');
                        console.log(files_saved + '/' + file_count + ' files saved!');
                    }
                });
            }).end();
        }
    }
}

// Ready to install
function ready() {
    let install_type = 'Install';
    if(installed_version != null) {
        if(installed_version != latest_version) install_type = 'Update';
        else install_type = 'Reinstall';

        $('#installed-version').show();
        $('#installed-version > span').text(installed_version);
    }

    $('.install-type').text(install_type);

    $('#loading').fadeOut();
    $('#installer').fadeIn();

    $('#install').click(() => {
        $('#installer').fadeOut();
        $('#loading').fadeIn();
    
        // Handle possible duplicates and start install
        if(possible_duplicate != null) {
            possible_duplicate_modal_opened = Date.now();
            $('#confirm-replace').modal('show');
            
            $('#confirm-replace-yes')
                .off('click')
                .on('click', () => {
                    possible_duplicate_modal_opened = -1;
                    $('#confirm-replace').modal('hide');

                    fs.unlinkSync(lua_scripts + '\\' + possible_duplicate);
                    setTimeout(install, 500);
                });

            $('#confirm-replace-no')
                .off('click')
                .on('click', () => {
                    possible_duplicate_modal_opened = -1;
                    $('#confirm-replace').modal('hide');
                    
                    setTimeout(install, 500);
                });
        }
        else {
            setTimeout(install, 500);
        }
    });
}

// Get latest version
$.get(repository + '/MANIFEST', (manifest) => {
    latest_version = manifest.split('\n')[0];
    contents = JSON.parse(manifest.split('\n').splice(1).join('\n'));
    console.log('Received manifest: ', latest_version, contents);

    $('#latest-version').text(latest_version);

    // Find installed versions
    let luas = fs.readdirSync(lua_scripts);
    console.log('Found ' + luas.length + ' Lua script(s)')

    let lua_found = false;
    for(let i = 0; i < luas.length; i++) {
        if(luas[i] == 'Ryan\'s Menu.lua') {
            let lua_source = fs.readFileSync(lua_scripts + "\\" + luas[i], 'utf-8');
            installed_version = lua_source.split('\n')[0].match(/"(.+)"/)[1];
            lua_found = true;
            console.log('Ryan\'s Menu has been installed before');
            ready();
        }
        else if(/^.*[Rr]yan.*$/.test(luas[i])) {
            possible_duplicate = luas[i];
            $('#possible-duplicate').text(luas[i].replace('.lua', ''))
            console.log('Found a similarly named script: ' + possible_duplicate);;
        }
    }
    if(!lua_found) ready();
});

$('#go-changelog').click((e) => {
    e.preventDefault();
    window.location.href = 'https://ryangq.ddns.net/menu/changelog?installer=' + window.location.href;
});