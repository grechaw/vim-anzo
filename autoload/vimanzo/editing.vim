" vim:tabstop=2:shiftwitdth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file 
" Desc: Editing Services 
"
"   This module provides services that are useful when editing a file
"   associated with anzo, e.g. a query file. 

" Prompts a user for input and uses it to create a prefix in a query file
" Example Usage
" :call vimanzo#editing#GeneratePrefix()
" Enter the new prefix you would like: gm
" Enter the new string you would like your prefix to replace
" http://openanzo.org/ontologies/2008/07/System#
function! vimanzo#editing#GeneratePrefix() 
  let l:prefix = input("Enter the new prefix you would like: ") 
  let l:replacement = input("Enter the string you would like your prefix to replace: ")
  let l:sed_replacement = substitute(l:replacement, '/', '\\/', 'g')
  execute ":%s/<" . l:sed_replacement . "\\(.*\\)>/". l:prefix . ":\\1/g"
  execute ":normal ggOPREFIX ". l:prefix . ":" . "<" . l:replacement . ">."
endfunction
