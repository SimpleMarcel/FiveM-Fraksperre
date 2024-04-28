fx_version 'adamant'
game 'gta5'

author 'MarcelSimple'
description 'Simple Fraksperre'
version '1.0.0'


server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'Server/Simple_Server.lua',
    'Einstellungen/Simple_Einstellungen.lua'
}

client_scripts {
    'Client.lua'
}

ui_page 'UI/index.html'
files {
    'UI/*.*',
    'UI/**/*.*',
    'UI/**/**/*.*'
}