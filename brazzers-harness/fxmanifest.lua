fx_version 'cerulean'
game 'gta5'

name "Brazzers Harness"
author "Brazzers Development | MannyOnBrazzers#6826"
version "1.2"

description 'Racing harness system for QBCore'
repository 'https://github.com/BrazzersDevelopment/brazzers-harness'

lua54 'yes'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
    'install.lua',
}

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/*.lua',
	'shared/*.lua',
}

files {
    'README/IMAGES/*.png',
    'FIXES.md',
    'TROUBLESHOOTING.md',
}

dependencies {
    'qb-core',
    'oxmysql',
}