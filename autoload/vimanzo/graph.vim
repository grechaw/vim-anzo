" vim:tabstop=2:shiftwidth=2:expandtab:textwidth=99
" Vimanzo autoload plugin file
" Desc: Graph services

if !exists("g:anzo_command")
  let g:anzo_command = "anzo"
endif

if !exists("g:anzo_settings")
  let g:anzo_settings = "~/.anzo/settings.trig"
endif

function! vimanzo#graph#getGraph(uri)
  let l:result_graph = systemlist(g:anzo_command . " get -z " . g:anzo_settings . " " . a:uri )
  let l:joined = join(l:result_graph, "\n")
  if (l:joined =~ "^ErrorCode.*")
      echo l:joined
  elseif (l:joined =~ "^Graph does not exist.*")
      echo l:joined
  else
      silent! exe "noautocmd botright pedit Trig: " . a:uri
      noautocmd wincmd P
      set buftype=nofile
      set nowrap
      exec ":norm ggdG"
      call append(0, l:result_graph)   "send a list to append to output multiple lines
      exec ":norm gg"
      noautocmd wincmd p
  endif
endfunction

