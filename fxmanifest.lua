fx_version 'cerulean'
games { 'gta5' }

author 'CA'
description 'A Custom Radio Script for FiveM with many features by ca'

ui_page 'html/ui.html'

shared_script 'config.lua'

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua',
}

files {
  'html/ui.html',
  'html/js/*.js',
  'html/css/*.css',
  'html/img/*.png',
}

exports {
  'JoinRadio',
  'LeaveRadio',
  'SetRadioState',
}