fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description "Keiron's framework conversion"

ui_page 'html/index.html'

version '1.0'

file 'import.lua'

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua'
}

shared_scripts {
    'shared/**/*.lua',
    'import.lua'
}

files {
    'html/index.html',
	'html/jquery.js',
	'html/init.js'
}