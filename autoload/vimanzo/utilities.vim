"Vimanzo autoload plugin file
" Desc: General Utilities for interacting with Anzo

"FUNCTION: CreateAndPopulateTopLeftFrame
"This function creates a vertical frame on the left. 
"It binds Enter to the execution of some functionality 
"and prints all the items necessary in the top frame.
function! vimanzo#utilities#CreateSidebar(info_dictionary, execute_command, minibuffer_name)
  silent! execute "topleft vertical 31 new" 
  noautocmd wincmd h 
  silent! execute "edit "  . a:minibuffer_name
  call vimanzo#utilities#CreatePaneInternal(a:info_dictionary, a:execute_command)
endfunction

function! vimanzo#utilities#CreateNewTab(info_dictionary, execute_command, minibuffer_name)
  silent! execute "tabedit " . a:minibuffer_name
  call vimanzo#utilities#CreatePaneInternal(a:info_dictionary, a:execute_command)
endfunction

function! vimanzo#utilities#CreatePaneInternal(info_dictionary, execute_command)
  silent! execute "normal ggdGd$"
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal cursorline
  silent execute ":call vimanzo#" . a:execute_command . "#GenerateBindings()" 
  let l:key_count = 0
  for s:key in keys(a:info_dictionary)
    let l:display_item = a:info_dictionary[s:key] 
    if l:key_count > 0 
      execute "normal! o \<Esc>" 
    endif
    execute "normal! i" . l:display_item . "\<Esc>"
    let l:key_count = l:key_count + 1 
  endfor
endfunction

"FUNCTION: vimanzo#utilities#ParseQueryResultCSVToDictionary -- 
"parses a csv string into a list whose first item is a list of columns and
"whose second item is a list of rows. A row itself is a list of strings 
function! vimanzo#utilities#ParseStringToCSV(raw_info)
  let l:raw_info_with_newlines = substitute(a:raw_info, '\n', '\r', 'g')
  let l:within_quote = 0
  let l:columns = [] 
  let l:not_added_columns = 1
  let l:rows = [] 
  let l:current_item = ""
  let l:current_row = []
  for s:char in split(l:raw_info_with_newlines, '\zs') 
    "    echom s:char 
    "    echom l:current_item 
    "    echom l:current_row
    if s:char ==# "," && !l:within_quote 
      call add(l:current_row, l:current_item)
      let l:current_item = ""
    elseif s:char ==# "\r" && !l:within_quote
      call add(l:current_row, l:current_item)
      let l:current_item = ""
      if l:not_added_columns
        let l:columns = l:current_row
        let l:not_added_columns = 0
      else
        call add(l:rows, l:current_row)
      endif
      let l:current_row = [] 
    elseif s:char ==# "\""
      let l:within_quote = !l:within_quote
    else
      let l:current_item = l:current_item . s:char 
    endif
  endfor 
  echom l:columns
  echom l:rows
 return vimanzo#utilities#CSVToJSON([l:columns, l:rows] )
endfunction

"FUNCTION: vimanzo#utilities#CSVToJSON -- 
"Takes a csv specified as a list whose first element is a list of columns and
"whose second element is a list of lists of results. It returns a list of json
"objects
function! vimanzo#utilities#CSVToJSON(csv)
  let l:columns = a:csv[0]
  let l:rows = a:csv[1]
  let l:result = []
  for s:row in l:rows: 
    let l:json_row = {} 
    let l:column_idx = 0 
    for l:column in l:columns: 
      l:json_row[l:column] = s:row[l:column_idx]
      add(l:result, l:json_row)
    endfor
  endfor
  return l:result
endfunction


