fx_version 'cerulean'
game 'gta5'

description 'TheLuxEmpire Recycling System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/menus.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'

dependencies {
    'qb-core',
    'qb-menu',
    'ox_lib'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
