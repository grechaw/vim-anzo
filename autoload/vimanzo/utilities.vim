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


