
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
    call append(0, "ANZOGRAPH")
    call append(line("$"), vimanzo#internal#AppendAnzograph())
    call append(line("$"), "")
    call append(line("$"), "GRAPHMARTS")
    call append(line("$"), vimanzo#internal#AppendGraphmarts())
    call append(line("$"), "")
    call append(line("$"), "PIPELINES")
    call append(line("$"), "")
    call append(line("$"), vimanzo#internal#AppendPipelines())
    call append(line("$"), "")
    call append(line("$"), "MODELS")
    call append(line("$"), "")
    call append(line("$"), vimanzo#internal#AppendModels())
endfunction


