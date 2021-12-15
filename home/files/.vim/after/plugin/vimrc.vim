" FIXME: Workaround for https://github.com/neoclide/coc.nvim/pull/3511
let &runtimepath = join(globpath(&runtimepath, '', v:false, v:true), ',')
