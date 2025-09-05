fx_version "cerulean"
game "gta5"

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

shared_scripts {
    'shared/config.lua',
    'shared/framework.lua'
}

dependencies {
    'vrp'
}

client_scripts {
    'src/client.lua'
}

server_scripts {
    'src/server.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
