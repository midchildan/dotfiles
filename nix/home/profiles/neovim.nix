{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.profiles.neovim;

  vimDir = ../../../files/.vim;
  vimFiles = map toString (lib.filesystem.listFilesRecursive vimDir);
  vimFilesRelative = map (lib.removePrefix (toString vimDir + "/")) vimFiles;
  vimFilesFiltered = lib.filter (lib.hasInfix "/") vimFilesRelative;
  vimRuntime = lib.genAttrs vimFilesFiltered (path: {
    source = toString vimDir + "/" + path;
  });

  javaDebug = pkgs.vscode-extensions.vscjava.vscode-java-debug;
  javaDebugGlob = "${javaDebug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";
in
{
  options.dotfiles.profiles.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      extraLuaConfig = builtins.readFile ../../../files/.config/nvim/init.lua;
      plugins = [
        {
          plugin = pkgs.emptyDirectory;
          runtime = vimRuntime;
        }

        # Editing
        {
          plugin = pkgs.vimPlugins.conform-nvim;
          type = "lua";
          config = # lua
            ''
              vim.opt.formatexpr = "v:lua.require('conform').formatexpr()"

              require("conform").setup({
                formatters_by_ft = {
                  ["*"] = { "treefmt" },
                },
                default_format_opts = {
                  lsp_format = "fallback",
                },
                formatters = {
                  treefmt = {
                    command = "treefmt",
                    args = { "--stdin", "--on-unmatched=fatal", "$FILENAME" },
                    cwd = require("conform.util").root_file({ "treefmt.toml", "flake.nix" })
                  },
                },
              })
            '';
        }
        {
          plugin = pkgs.vimPlugins.vim-easy-align;
          type = "lua";
          config = # lua
            ''
              vim.keymap.set({ "n", "x" }, "g=", "<Plug>(EasyAlign)", { remap = true })
            '';
        }
        {
          plugin = pkgs.vimPlugins.vim-sandwich;
          type = "lua";
          config = # lua
            ''
              vim.keymap.set({ "n", "x" }, "s", "<Nop>", { remap = true })

              -- NOTE: Same feature as vim/vim#958
              vim.keymap.set(
                { "x", "o" },
                "im",
                "<Plug>(textobj-sandwich-literal-query-i)",
                { remap = true }
              )
              vim.keymap.set(
                { "x", "o" },
                "am",
                "<Plug>(textobj-sandwich-literal-query-a)",
                { remap = true }
              )
            '';
        }

        # Colorscheme
        {
          plugin = pkgs.vimPlugins.gruvbox;
          config = # vim
            ''
              colorscheme gruvbox
              set cursorline
              set pumblend=15 winblend=15
            '';
        }

        # UI
        pkgs.vimPlugins.vim-peekaboo
        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          type = "lua";
          # https://github.com/neovim/neovim/issues/14281
          config = # lua
            ''
              vim.opt.showmode = false

              require("lualine").setup({
                sections = {
                  lualine_a = { "mode" },
                  lualine_b = {
                    "branch",
                    {
                      "diff",
                      colored = false,
                    },
                    "diagnostics",
                  },
                  lualine_c = {
                    {
                      "filename",
                      path = 1,
                    },
                  },
                  lualine_x = {
                    {
                      "encoding",
                      cond = function()
                        return vim.opt.fileencoding:get() ~= "utf-8"
                      end,
                    },
                    {
                      "fileformat",
                      icons_enabled = false,
                      cond = function()
                        return vim.opt.fileformat:get() ~= "unix"
                      end,
                    },
                    {
                      "filetype",
                      colored = false,
                    },
                  },
                  lualine_y = { "progress" },
                  lualine_z = { "location" }
                },
                extensions = {
                  "fugitive",
                  "fzf",
                  "man",
                  "neo-tree",
                  "quickfix",
                },
              })
            '';
        }
        {
          plugin = pkgs.vimPlugins.fzf-lua;
          type = "lua";
          config = # lua
            ''
              local fzf = require("fzf-lua")
              fzf.setup({
                winopts = {
                  winblend = vim.opt.winblend:get(),
                  preview = {
                    layout = "vertical",
                  },
                },
              })

              local function fzf_projects(opts)
                opts = opts or {}
                opts.prompt = "Projects> "
                opts.actions = {
                  default = function(selected)
                    vim.cmd("tcd " .. selected[1])
                  end
                }
                fzf.fzf_exec("${lib.getExe pkgs.ghq} list -p", opts)
              end

              vim.keymap.set("n", "<Leader><Leader>", fzf.git_files)
              vim.keymap.set("n", "<Leader>,", fzf.buffers)
              vim.keymap.set("n", "<Leader>.", fzf.files)
              vim.keymap.set("n", "<Leader>gp", fzf_projects)
              vim.keymap.set("n", "<Leader>g/", fzf.lines)
              vim.keymap.set("n", "<Leader>g]", fzf.tags)
              vim.keymap.set("n", "<Leader>o", fzf.oldfiles)
              vim.keymap.set("n", "<Leader>p", fzf.builtin)
              vim.keymap.set("n", "<Leader>P", fzf.resume)
              vim.keymap.set("n", "<Leader>q:", fzf.command_history)
              vim.keymap.set("n", "<Leader>q/", fzf.search_history)
              vim.keymap.set("n", "<Leader>'", fzf.marks)
              vim.keymap.set("n", "<Leader>/", fzf.blines)
              vim.keymap.set("n", "<Leader>:", fzf.commands)
              vim.keymap.set("n", "<Leader>]", fzf.btags)
            '';
        }
        {
          plugin = pkgs.vimPlugins.gitsigns-nvim;
          type = "lua";
          config = # lua
            ''
              local gitsigns = require("gitsigns")
              gitsigns.setup({
                on_attach = function(bufnr)
                  local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                  end

                  map("n", "]c", function()
                    if vim.wo.diff then
                      vim.cmd.normal({"]c", bang = true})
                    else
                      gitsigns.nav_hunk("next")
                    end
                  end)

                  map("n", "[c", function()
                    if vim.wo.diff then
                      vim.cmd.normal({"[c", bang = true})
                    else
                      gitsigns.nav_hunk("prev")
                    end
                  end)
                end
              })
            '';
        }
        {
          plugin = pkgs.vimPlugins.vim-illuminate;
          config = # vim
            ''
              hi link IlluminatedWordText cursorLine
              hi link IlluminatedWordRead cursorLine
              hi link IlluminatedWordWrite cursorLine
              nnoremap <silent> <Leader>t* <Cmd>IlluminationToggle<CR>
            '';
        }
        {
          plugin = pkgs.vimPlugins.indent-blankline-nvim;
          type = "lua";
          config = # lua
            ''
              require("ibl").setup({
                enabled = false,
              })
              vim.keymap.set("n", "<Leader>t<Tab>", "<Cmd>IBLToggle<CR>")
            '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-treesitter-context;
          type = "lua";
          config = # lua
            ''
              require("treesitter-context").setup({ enable = false })
              vim.keymap.set("n", "<Leader>tz", "<Cmd>TSContextToggle<CR>")
            '';
        }

        # Language Support
        pkgs.vimPlugins.friendly-snippets
        pkgs.vimPlugins.nvim-dap
        {
          plugin = pkgs.vimPlugins.blink-cmp;
          type = "lua";
          config = # lua
            ''
              local blink = require("blink.cmp")
              blink.setup({
                completion = {
                  menu = {
                    winblend = vim.opt.pumblend:get(),
                  },
                  documentation = {
                    auto_show = true,
                    window = {
                      winblend = vim.opt.pumblend:get(),
                    },
                  },
                },
                signature = {
                  enabled = true,
                  window = {
                    winblend = vim.opt.pumblend:get(),
                  },
                },
                keymap = {
                  -- Fixes builtin completion
                  ["<C-y>"] = { "select_and_accept", "fallback" },
                },
              })

              -- Fixes builtin completion
              vim.api.nvim_create_autocmd('TextChangedP', {
                callback = function() blink.hide() end
              })
            '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          type = "lua";
          config = # lua
            ''
              vim.lsp.config("jdtls", {
                init_options = {
                  bundles = { vim.fn.glob("${javaDebugGlob}", 1) }
                },
              })

              vim.lsp.enable({
                "ansiblels",
                "clangd",
                "eslint",
                "gopls",
                "jdtls",
                "rust_analyzer",
                "rubocop",
                "pyright",
                "ts_ls",
              })
            '';
        }
        {
          plugin = pkgs.vimPlugins.ale;
          type = "lua";
          config = # lua
            ''
              vim.g.ale_set_quickfix = false
              vim.g.ale_set_loclist = false
              vim.g.ale_use_neovim_diagnostics_api = true
              vim.g.ale_virtualtext_cursor = 'disabled'
            '';
        }

        # TreeSitter
        {
          plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
          type = "lua";
          config = # lua
            ''
              require("nvim-treesitter.configs").setup({
                auto_install = false,
                highlight = {
                  enable = true,
                },
                indent = {
                  enable = true,
                },
              })
            '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-treesitter-textobjects;
          type = "lua";
          config = # lua
            ''
              require("nvim-treesitter.configs").setup({
                textobjects = {
                  select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                      ["af"] = "@function.outer",
                      ["if"] = "@function.inner",
                      ["ac"] = "@class.outer",
                      ["ic"] = "@class.inner",
                    },
                  },
                  swap = {
                    enable = true,
                    swap_next = {
                      ["<Leader>>"] = "@parameter.inner",
                    },
                    swap_previous = {
                      ["<Leader><"] = "@parameter.inner",
                    },
                  },
                },
              })
            '';
        }

        # Utilities
        pkgs.vimPlugins.direnv-vim
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.gv-vim
        {
          plugin = pkgs.vimPlugins.neo-tree-nvim;
          type = "lua";
          config = # lua
            ''
              require("neo-tree").setup({
                close_if_last_window = true,
                sources = {
                  "filesystem",
                  "buffers",
                  "git_status",
                  "document_symbols",
                },
                source_selector = {
                  winbar = true,
                },
                filesystem = {
                  group_empty_dirs = true,
                  scan_mode = "deep",
                  follow_current_file = {
                    enabled = true,
                  },
                },
              })

              vim.keymap.set("n", "<Leader>tf", "<Cmd>Neotree toggle<CR>")
              vim.keymap.set("n", "<Leader>tF", "<Cmd>Neotree reveal<CR>")
              vim.keymap.set("n", "<Leader>tt",
                "<Cmd>Neotree document_symbols toggle right selector=false<CR>")
            '';
        }
        {
          plugin = pkgs.vimPlugins.undotree;
          type = "lua";
          config = # lua
            ''
              vim.g.undotree_WindowLayout = 2
              vim.keymap.set("n", "<Leader>tu", "<Cmd>UndotreeToggle<CR>")
            '';
        }
      ];
    };
  };
}
