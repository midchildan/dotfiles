let g:tex_flavor='latex'

let g:tex_conceal='adbmgs'
setlocal conceallevel=2
hi Conceal guibg=black guifg=cyan

"LaTeX-Box
let g:LatexBox_output_type='pdf'
let g:LatexBox_latexmk_options='-pdfdvi'
let g:LatexBox_latexmk_async=1
let g:LatexBox_complete_inlineMath=1
let g:LatexBox_Folding=1
