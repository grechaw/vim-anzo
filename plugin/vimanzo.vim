" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo plugin file
" Home: https://github.com/grechaw/vimanzo
" GetLatestVimScripts:

if exists("g:loaded_vimanzo") || &cp
  finish
endif
let g:loaded_vimanzo = 1

if !exists("g:anzo_command")
  let g:anzo_command = "anzo"
endif

if !exists("g:anzo_settings")
  let g:anzo_settings = "~/.anzo/settings.trig"
endif


" Set to version number for release, otherwise -1 for dev-branch
let g:plugin_version = "-1"
"
" Get the directory the script is installed in
let g:vimanzo_plugin_dir = expand('<sfile>:p:h:h')


" echom "Vimanzo loaded..."
