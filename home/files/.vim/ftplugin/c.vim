setlocal cinoptions=l1,g0,N-s,t0,(0,w1,Ws,m1
setlocal foldmethod=syntax
let b:ale_linters=[] " rely mainly on CoC for linting

nnoremap <buffer> <silent> <LocalLeader>go :SourcetrailRefresh<CR>
nnoremap <buffer> <silent> <LocalLeader>gp :SourcetrailActivateToken<CR>
