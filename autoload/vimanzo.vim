
function! vimanzo#Overview()
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


