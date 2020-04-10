" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file
" Desc: Query services

" This function is just a test to get the stubs all working together
function! vimanzo#query#test()
    echom "Query Test"
endfunction

" This function is also a test, but hits the anzo cli
function! vimanzo#query#testCLI()
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

"This is a generic function that runs a query and puts the results into
"minibuffer
function! vimanzo#query#ExecuteQuery(query_options)
  let l:query_file = bufname("%")
  silent! exe "noautocmd botright pedit QueryResults"
  noautocmd wincmd P
  set buftype=nofile
  set nowrap
  exec ":norm ggdG"
  exec ": read ! " . g:anzo_command . " query " . a:query_options . " -z " . g:anzo_settings . " -f " . l:query_file
  noautocmd wincmd p
endfunction

"This function runs a query against the journal showing the results in a minibuffer
function! vimanzo#query#ExecuteJournalQuery()
  call vimanzo#query#ExecuteQuery("-a")
endfunction

"This function executes a sparql query and unpacks the json
"to reutrn the results as a vim structure
function! vimanzo#query#queryForVim()
  let l:query_file = bufname("%")
  " Use json results and all graphs
  let l:query_options="-a -o json"
  let l:result_string=system(g:anzo_command . " query " . l:query_options . " -z " . g:anzo_settings . " -f " . l:query_file)
  let l:result_list=json_decode(l:result_string)['results']['bindings']
  " prune type info
  for item in l:result_list
    for key in keys(item)
      let item[key] = item[key]["value"]
    endfor
  endfor
  return l:result_list
endfunction

com! JournalQuery :call vimanzo#query#ExecuteJournalQuery()

