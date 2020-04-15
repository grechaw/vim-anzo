" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file
" Desc: Find services

function! vimanzo#find#find(find_argument, find_options)
  silent! exe "noautocmd botright pedit FindResults"
  noautocmd wincmd P
  set buftype=nofile
  set nowrap
  exec ":norm ggdG"
  exec ": read ! " . g:anzo_command . " find " . " -z " . g:anzo_settings . " " . a:find_options . " " . a:find_argument
  noautocmd wincmd p
endfunction

function! vimanzo#find#findSelectionSubject()
  return vimanzo#find#find(@", "-subj")
endfunction

function! vimanzo#find#findSelectionPredicate()
  return vimanzo#find#find(@", "-pred")
endfunction

"run on selection
function! vimanzo#find#findSelectionObject()
  return vimanzo#find#find(@", "-uri")
endfunction

"run on selection
function! vimanzo#find#findSelectionLiteral()
  return vimanzo#find#find(@", "-lit")
endfunction

nnoremap fl :call vimanzo#find#findSelectionLiteral()<cr>
nnoremap fo :call vimanzo#find#findSelectionObject()<cr>
nnoremap fp :call vimanzo#find#findSelectionPredicate()<cr>
nnoremap fs :call vimanzo#find#findSelectionSubject()<cr>

