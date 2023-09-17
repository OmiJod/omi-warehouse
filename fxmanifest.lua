fx_version 'cerulean'
game 'gta5'

author 'Nullvalue'
version '1.0.0'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

shared_scripts {
    'config.lua',
    'shared/*.lua',
    '@ox_lib/init.lua',
}

lua54 'yes'