" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo plugin file
" Home: https://github.com/grechaw/vimanzo
" GetLatestVimScripts:

if exists("g:loaded_vimanzo") || &cp
  finish
endif
let g:loaded_vimanzo = 1

" Set to version number for release, otherwise -1 for dev-branch
let s:plugin_vers = "-1"
"
" Get the directory the script is installed in
let s:plugin_dir = expand('<sfile>:p:h:h')

if !exists("g:anzo_command")
    let g:anzo_command = "anzo"
endif

if !exists("g:anzo_settings")
    let g:anzo_settings = "~/.anzo/settings.trig"
endif

" mappings
nnoremap <buffer> <localleader>q :call vimanzo#query#ExecuteJournalQuery()<cr>

" echom "Vimanzo loaded..."
