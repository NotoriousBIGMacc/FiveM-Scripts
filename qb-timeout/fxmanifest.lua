shared_script "@ReaperV4/bypass.lua"
lua54 "yes" -- needed for Reaper

--- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'
author 'LIL PEEN'

description 'QB-Timeout - Temporary Ban Area System'
version '1.0.0'

shared_scripts {
   '@qb-core/shared/locale.lua',
  'config.lua'
}

client_scripts {
   'client/main.lua'
}

server_scripts {
   '@oxmysql/lib/MySQL.lua',
   'install.lua',
   'server/main.lua'
}

lua54 'yes'