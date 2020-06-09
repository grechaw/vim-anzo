"
" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file
" Desc: Query services
"
execute 'source ' . expand('<sfile>:p:h') . '/utilities.vim'

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
  call vimanzo#query#ExecuteQuery("-a","")
endfunction 

function! vimanzo#query#ExecuteQuery(datasource, graphmart)
  let l:query_file = bufname("%")
  silent! execute ":w"
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

"FUNCTION: ExceuteQueryFromString
"This function runs a query against a datasource and potentially graphmart
"given the query string that it is passed.
"@TODO the internals of this funciton are similar to ExecuteQuery if we need 
"something similar again it might be worth abstracting them out to their own
"function
function! vimanzo#query#ExecuteQueryFromString(query, datasource, graphmart)
  if a:datasource == "-a"
    exec ": read ! " . g:anzo_command . " query -a -z " . g:anzo_settings . " " . a:query
  else 
    exec ":read ! " . g:anzo_command . " query -z " . g:anzo_settings . " -ds " . a:datasource . " -dataset " . a:graphmart . " " . a:query
  endif
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
  let l:datasource = "http://cambridgesemantics.com/datasource/SystemTables"
  let l:select = "SELECT ?azg ?gmart (SAMPLE(?title) as ?label) \n"
  let l:status = "?gmart <http://cambridgesemantics.com/ontologies/GraphmartStatus#status> ?status . \n"
  let l:type   = "?gmart a <http://cambridgesemantics.com/ontologies/GraphmartStatus#GraphmartStatus>. \n "
  let l:title  = "?gmart dc:title ?title . \n"
  let l:azg    = "?gmart  <http://cambridgesemantics.com/ontologies/Graphmarts#graphQueryEngineUri> ?azg \n"
  let l:where  = " WHERE { " . l:status . l:type . l:title . l:azg . " } GROUP BY ?azg ?gmart"
  let l:query  = l:select . l:where 
  let l:result_list = vimanzo#query#internalQuery( l:query, 0, l:datasource)
  for l:entry in l:result_list 
    let l:key = l:entry["azg"] . ";" . l:entry["gmart"]
    let g:graphmart_uri_title_dictionary[l:key] = l:entry["label"] 
  endfor
endfunction

"Opens a new pane to display all graphmart
"titles that are values in the graphmart 
"dictionary and allows the user to set the 
"currently focused graphmart 
function! vimanzo#query#DisplayGraphmartsWithoutQuery() 
  call vimanzo#query#GetGraphmartsInfo()
  call vimanzo#utilities#CreateSidebar(g:graphmart_uri_title_dictionary, "query", "Active Graphmarts")
endfunction

function! vimanzo#query#DisplayGraphmartsAndQuery() 
  call vimanzo#query#GetGraphmartsInfo()
  call vimanzo#utilities#CreateSidebar(g:graphmart_uri_title_dictionary, "query", "Active Graphmarts")
endfunction

function! vimanzo#query#GenerateBindings() 
  silent execute ":nnoremap <buffer> <CR> :call  vimanzo#query#setAZGAndGraphmartWithQuery() <CR>"
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
    if l:line ==# l:graphmart_title
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

"Function: A query function that takes either a filepath or a 
"query string and returns a dictionary of the results

function! vimanzo#query#internalQuery(query_object, is_filepath, datasource) 
  let l:query_options="-a -o json"
  if a:datasource !=# ""
    let l:query_options = l:query_options . " -ds " . a:datasource 
  endif
  if a:is_filepath 
    let l:result_string=system(g:anzo_command . " query " . l:query_options . " -z " . g:anzo_settings . " -f " . a:query_object)
  else 
    let l:result_string=system(g:anzo_command . " query " . l:query_options . " -z " . g:anzo_settings  . " \"" . a:query_object . "\"" )
  endif 
  if v:version < 800
    let l:result_list=vimanzo#utilities#ParseStringToCSV(l:result_string)
  else
    let l:result_list=json_decode(l:result_string)['results']['bindings']
    " prune type info
    for item in l:result_list
      for key in keys(item)
        let item[key] = item[key]["value"]
      endfor
    endfor
  endif 
  return l:result_list
endfunction 
