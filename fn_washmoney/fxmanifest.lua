fx_version 'bodacious'
game 'gta5'

version '1.0.0'

client_scripts { 
    'client/locales/*.lua',
    'client/main.lua',
}

server_scripts {
    'server/locales/*.lua',
    'server/main.lua',
}

shared_scripts {
    '@es_extended/locale.lua',
    'config.lua'
}