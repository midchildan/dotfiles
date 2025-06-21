local augroup = vim.api.nvim_create_augroup("vimrc", { clear = true })

-- {{{ General

vim.opt.backup = true
vim.opt.backupdir:remove(".")
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.tex_flavor = "latex"

vim.cmd("silent! packadd! cfilter")

-- See :h :DiffOrig
vim.cmd([[
  command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
    \ | wincmd p | diffthis
]])

-- }}}
-- {{{ Editing

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.copyindent = true
vim.opt.preserveindent = true
vim.opt.formatoptions:append("mB")
vim.opt.fileencodings = {
  "ucs-bom",
  "utf-8",
  "iso-2022-jp",
  "euc-jp",
  "cp932",
  "default",
  "latin1",
}

-- jump to the last known cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(opts)
    local ft = vim.bo[opts.buf].filetype
    local line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
    local in_range = 1 < line and line <= vim.api.nvim_buf_line_count(opts.buf)

    if in_range and not ft:match("commit") then
      vim.api.nvim_feedkeys([[g`"]], "nx", false)
    end
  end,
})

-- }}}
-- {{{ UI

vim.opt.colorcolumn = "81"
vim.opt.foldenable = false
vim.opt.inccommand = "split"
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.showmatch = true
vim.opt.title = true
vim.opt.wildignorecase = true
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "algorithm:histogram",
  "indent-heuristic",
}

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  callback = function(args)
    vim.highlight.on_yank({
      higroup = "Visual",
      timeout = 300,
    })
  end,
})

vim.api.nvim_create_autocmd("QuickfixCmdPost", {
  group = augroup,
  pattern = [[\C[^lA-Z]*]],
  command = "botright cwindow",
})

vim.api.nvim_create_autocmd("QuickfixCmdPost", {
  group = augroup,
  pattern = "l*",
  command = "botright lwindow",
})

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})

-- }}}
-- {{{ Keybindings

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Leader>b", "<Cmd>bmodified<CR>")

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<Cmd>lua vim.snippet.jump(1)<CR>"
  else
    return "<Tab>"
  end
end, { expr = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.snippet.active({ direction = -1 }) then
    return "<Cmd>lua vim.snippet.jump(-1)<CR>"
  else
    return "<S-Tab>"
  end
end, { expr = true })

-- find merge conflict marker
vim.keymap.set({ "n", "x", "o" }, "<Leader>fc", [[/\v^[<=>]{7}( .*<Bar>$)<CR>]])
-- find whitespace errors
vim.keymap.set({ "n", "x", "o" }, "<Leader>f ", [[/\s\+$\<Bar> \+\ze\t<CR>]])
-- find full-width punctuation marks
vim.keymap.set({ "n", "x", "o" }, "<Leader>f.", [[/\v(\.<Bar>．<Bar>。)<CR>]])
vim.keymap.set({ "n", "x", "o" }, "<Leader>f,", [[/\v(,<Bar>，<Bar>、)<CR>]])
vim.keymap.set({ "n", "x", "o" }, "<Leader>f!", [[f! /\v(!<Bar>！)<CR>]])
vim.keymap.set({ "n", "x", "o" }, "<Leader>f!", [[f? /\v(\?<Bar>？)<CR>]])

-- text objects
vim.keymap.set("x", "al", "<Esc>0v$")
vim.keymap.set("o", "al", "<Cmd>normal! 0v$<CR>")
vim.keymap.set("x", "il", "<Esc>^vg_")
vim.keymap.set("o", "il", "<Cmd>normal! ^vg_<CR>")
vim.keymap.set("x", "ag", "gg0oG$")
vim.keymap.set("o", "ag", [[<Cmd>exe "normal! m`"<Bar>keepjumps normal! ggVG<CR>]])

-- toggles
vim.keymap.set("n", "<Leader>ts", "<Cmd>setlocal spell! spell?<CR>")
vim.keymap.set("n", "<Leader>tv", "<Cmd>call vimrc#toggle_virtualedit()<CR>")
vim.keymap.set("n", "<Leader>tq", "<Cmd>call vimrc#toggle_textwidth()<CR>")
vim.keymap.set("n", "<Leader>t#", "<Cmd>setlocal relativenumber! relativenumber?<CR>")
vim.keymap.set("n", "<Leader>t<Tab>", "<Cmd>setlocal list! list?<CR>")

-- 3-way merge
vim.keymap.set("n", "<Leader>1", "<Cmd>diffget LOCAL<CR>")
vim.keymap.set("n", "<Leader>2", "<Cmd>diffget BASE<CR>")
vim.keymap.set("n", "<Leader>3", "<Cmd>diffget REMOTE<CR>")

-- }}}

-- vim:set foldmethod=marker:
