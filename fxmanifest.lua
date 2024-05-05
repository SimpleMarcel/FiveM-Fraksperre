fx_version 'adamant'
game 'gta5'

author 'MarcelSimple'
description 'Simple Fraksperre'
version '1.0.1'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'Einstellungen/Simple_Einstellungen.lua',
    'Server/Simple_Server.lua'
}

client_scripts {
    'Client/Simple_Client.lua'
}

ui_page 'UI/SimpleScripts.html'
files {
    'UI/*.*',
    'UI/**/*.*',
    'UI/**/**/*.*'
}