"Vimanzo autoload plugin file
" Desc: General Utilities for interacting with Anzo

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
  return [l:columns, l:rows] 
endfunction


