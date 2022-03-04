let g:jsonnet_fmt_on_save = v:false
if executable('jsonnetfmt')
  setlocal formatprg=jsonnetfmt\ -
endif
