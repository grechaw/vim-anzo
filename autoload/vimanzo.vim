
function! vimanzo#Overview()
    " We have an internal function in utitities.vim that might handle this 
    " if not we should add one. Do we want this in the bottom right - it might
    " be easier to use if it's a full tab of it's own. 
    silent! exec "noautocmd botright pedit Anzo Overview"
    noautocmd wincmd P
    set buftype=nofile
    set nowrap
    set expandtab
    set shiftwidth=2
    set foldmethod=indent
    set tabstop=40
    exec ":norm ggdG"
    echom "Getting Anzograph metadata..."
    call append(0, "ANZOGRAPH")
    call append(line("$"), vimanzo#internal#AppendAnzograph())
    call append(line("$"), "")
    echom "Getting graphmart metadata..."
    call append(line("$"), "GRAPHMARTS")
    call append(line("$"), vimanzo#internal#AppendGraphmarts())
    call append(line("$"), "")
    echom "Getting pipeline metadata..."
    call append(line("$"), "PIPELINES")
    call append(line("$"), "")
    call append(line("$"), vimanzo#internal#AppendPipelines())
    call append(line("$"), "")
    echom "Getting model metadata..."
    call append(line("$"), "MODELS")
    call append(line("$"), "")
    call append(line("$"), vimanzo#internal#AppendModels())
    echom "Done."
    return "success"
endfunction


