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
    let g:anzo_settings = "~/.anzo/settings.trig"
endif

function! vimanzo#query#GetGraph(uri)
    silent !clear
    execute "!" . g:anzo_command . " get -z " . g:anzo_settings . " " . a:uri 
endfunction


"This function runs a query against the journal showing the results in a minibuffer
function! vimanzo#query#ExecuteJournalQuery()
  let l:query_file = bufname("%")
  silent! exe "noautocmd botright pedit QueryResults"
  noautocmd wincmd P
  set buftype=nofile
  exec ":norm ggdG"
  exec ": read ! " . g:anzo_command . " query -a -z " . g:anzo_settings . " -f " . l:query_file
  noautocmd wincmd p
endfunction

com! JournalQuery :call vimanzo#query#ExecuteJournalQuery()

function! vimanzo#query#ExecuteQuery()
    silent !clear
    execute "!" . g:anzo_command . " query -z " . g:anzo_settings . " -f " . bufname("%")
endfunction

nnoremap <buffer> <localleader>q :call vimanzo#query#ExecuteJournalQuery()<cr>
