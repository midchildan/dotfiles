if executable('prettier')
  setlocal formatprg=prettier\ --parser=json
elseif executable('python')
  setlocal formatprg=python\ -mjson.tool
endif
