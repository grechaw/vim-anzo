" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file
" Desc: Query services


"This function runs a query against the journal showing the results in a minibuffer
function! vimanzo#query#ExecuteJournalQuery()
  call vimanzo#query#ExecuteQuery("-a","")
endfunction 

function! vimanzo#query#ExecuteQuery(datasource, graphmart)
  let l:query_file = bufname("%")
  silent! execute ":w<CR>"
  silent! exe "noautocmd botright pedit Query Results"
  noautocmd wincmd P
  set buftype=nofile
  set nowrap
  exec ":norm ggdG"
  if a:datasource ==# "-a"
    exec ":read ! " . g:anzo_command . " query -a -z " . g:anzo_settings . " -f " . l:query_file
  else 
    exec ":read ! " . g:anzo_command . " query -z " . g:anzo_settings . " -ds " . a:datasource . " -dataset " . a:graphmart . " -f " . l:query_file 
  endif
  noautocmd wincmd p
endfunction

nnoremap <buffer> <localleader>q :call vimanzo#query#ExecuteJournalQuery()<cr>

function! vimanzo#query#DatasourceQuery()
  call vimanzo#query#ExecuteQuery(g:current_focused_azg, g:current_focused_graphmart)
endfunction

" Stores information about the currently online graphmarts. The keys of 
" this dictioanry are azg uris concatenated to a graphmart they have loaded
" separated by a semi-colon. The values are the graphmart titles
let g:graphmart_uri_title_dictionary = {"-a;http://cambridgesemantics.com/datasource/SystemTables": "System Tables"}

" Gathers information about all the currently online graphmarts
" Maybe we want to run this at initialization time and then allow 
" for manual refresh
function! vimanzo#query#GetGraphmartsInfo()
  let l:raw_info = substitute(system("anzo query -a -ds http://cambridgesemantics.com/datasource/SystemTables  \"SELECT ?azg ?gmart (SAMPLE(?title) as ?label) WHERE { ?gmart <http://cambridgesemantics.com/ontologies/GraphmartStatus#status> ?status; a <http://cambridgesemantics.com/ontologies/GraphmartStatus#GraphmartStatus> ; dc:title ?title ; <http://cambridgesemantics.com/ontologies/Graphmarts#graphQueryEngineUri> ?azg } GROUP BY ?azg ?gmart \" -o csv"), '\n', ',' , 'g')
  let l:within_quote = 0
  let l:current_azg = "" 
  let l:current_graphmart = ""
  let l:current_item = ""
  let l:column_headers = ""
  for s:char in split(l:raw_info, '\zs') 
    if s:char ==# "," && !l:within_quote 
      if l:current_azg ==# ""
        let l:current_azg = l:current_item 
        let l:current_item = ""
      elseif l:current_graphmart ==# ""
        let l:current_graphmart = l:current_item 
        let l:current_item = ""
      else
        if l:column_headers ==# "" 
          let l:column_headers = l:current_graphmart
        else
          let g:graphmart_uri_title_dictionary[l:current_azg . ";" . l:current_graphmart] = l:current_item
        endif 
        let l:current_azg = "" 
        let l:current_graphmart = ""
        let l:current_item = "" 
      endif
    elseif s:char ==# "\"" 
      let l:within_quote = !l:within_quote 
    else 
      let l:current_item = l:current_item . s:char 
    endif 
  endfor
endfunction

"Opens a new pane to display all graphmart
"titles that are values in the graphmart 
"dictionary and allows the user to set the 
"currently focused graphmart 
function! vimanzo#query#DisplayGraphmartsWithoutQuery() 
  call vimanzo#query#DisplayGraphmartsInternal("vimanzo#query#setAZGAndGraphmart()")
endfunction

function! vimanzo#query#DisplayGraphmartsAndQuery()
  call vimanzo#query#DisplayGraphmartsInternal("vimanzo#query#setAZGAndGraphmartWithQuery()")
endfunction

"This is abstracted out so that we can either
"display and set the focused graphmart without 
"running a query or run a query after that graphmart is 
"set.
function! vimanzo#query#DisplayGraphmartsInternal(graphmart_set_command) 
  silent! execute "topleft vertical 31 new" 
  noautocmd wincmd h
  silent! execute "edit Active Graphmarts" 
  silent! execute "normal ggdGd$"
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal cursorline
  silent execute ":nnoremap <buffer> <CR> :call " . a:graphmart_set_command . " ()<CR>"
  call vimanzo#query#GetGraphmartsInfo()
  let l:key_count = 0
  for s:key in keys(g:graphmart_uri_title_dictionary)
    let l:graphmart_title = g:graphmart_uri_title_dictionary[s:key] 
    if l:key_count > 0 
      execute "normal! o \<Esc>" 
    endif
    execute "normal! i" . l:graphmart_title . "\<Esc>"
    let l:key_count = l:key_count + 1 
  endfor
endfunction

let g:current_focused_azg = ""
let g:current_focused_graphmart = "" 

function! vimanzo#query#setAZGAndGraphmart()
  call vimanzo#query#setAZGAndGraphmartInternal("no_query")
endfunction

function! vimanzo#query#setAZGAndGraphmartWithQuery()
  call vimanzo#query#setAZGAndGraphmartInternal("run_query")
endfunction

"This should only be called from within the frame set by 
"vimanzo#query#DisplayGraphmartsInternal function. 
function! vimanzo#query#setAZGAndGraphmartInternal(run_query)
  let l:line  = getline('.')
  let l:unparsed_dictionary_azg = ""
  for s:key in keys(g:graphmart_uri_title_dictionary)
    let l:graphmart_title = g:graphmart_uri_title_dictionary[s:key]
    if l:line ==# l:graphmart_title . " " "this is a little hacky, but somewhere a space gets inserted
      let l:unparsed_dictionary_azg = s:key
    endif
  endfor
  if !(l:unparsed_dictionary_azg ==# "")
    let l:azg_graphmart_list = split(l:unparsed_dictionary_azg, ";")
    let g:current_focused_azg = l:azg_graphmart_list[0]
    let g:current_focused_graphmart = l:azg_graphmart_list[1]
  endif 
  execute ":q \"Active Graphmarts\"<CR>"
  if a:run_query ==# "run_query"
    call vimanzo#query#DatasourceQuery() 
  endif
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
