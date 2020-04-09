" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file
" Desc: Query services

" This function is just a test to get the stubs all working together
function! vimanzo#query#test()
    echom "Query Test"
endfunction

" This function is also a test, but hits the anzo cli
function! vimanzo#query#testconnection()
    echom "Query Test Anzo Connection"
endfunction


if !exists("g:anzo_command")
    let g:anzo_command = "anzo"
endif

if !exists("g:anzo_settings")
    let g:anzo_command = "~/.anzo/settings.trig"
endif

function! ExecuteQuery()
    silent !clear
    execute "!" . g:anzo_command . " query -x " . g:anzo_settings . " " . bufname("%")
endfunction

nnoremap <buffer> <localleader>q :call ExecuteQuery()<cr>
