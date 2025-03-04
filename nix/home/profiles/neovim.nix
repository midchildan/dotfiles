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
          config = ''
            vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

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
          config = ''
            vim.keymap.set({ "n", "x" }, "g=", "<Plug>(EasyAlign)", { remap = true })
          '';
        }
        {
          plugin = pkgs.vimPlugins.vim-easymotion;
          type = "lua";
          config = ''
            vim.g.EasyMotion_do_mapping = false
            vim.g.EasyMotion_smartcase = true
            vim.g.EasyMotion_use_migemo = true
            vim.keymap.set({ "n", "x", "o" }, "<Leader>j", "<Plug>(easymotion-j)", { remap = true })
            vim.keymap.set({ "n", "x", "o" }, "<Leader>k", "<Plug>(easymotion-k)", { remap = true })
            vim.keymap.set({ "x", "o" }, "<Leader>s", "<Plug>(easymotion-s2)", { remap = true })
            vim.keymap.set("n", "<Leader>s", "<Plug>(easymotion-overwin-f2)", { remap = true })
            vim.keymap.set({ "n", "x", "o" }, "g/", "<Plug>(easymotion-sn)", { remap = true })
          '';
        }
        {
          plugin = pkgs.vimPlugins.vim-sandwich;
          type = "lua";
          config = ''
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
          config = ''
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
          config = ''
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
          plugin = pkgs.vimPlugins.fzfWrapper;
          config = ''
            let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

            command! -bang Compilers call vimrc#fzf_compilers(0, <bang>0)
            command! -bang BCompilers call vimrc#fzf_compilers(1, <bang>0)
            command! -bang -nargs=* Projects call vimrc#fzf_projects(<q-args>, <bang>0)
          '';
        }
        {
          plugin = pkgs.vimPlugins.fzf-vim;
          type = "lua";
          config = ''
            vim.keymap.set("n", "<Leader><Leader>", "<Cmd>GitFiles<CR>")
            vim.keymap.set("n", "<Leader>,", "<Cmd>Buffers<CR>")
            vim.keymap.set("n", "<Leader>.", "<Cmd>Files<CR>")
            vim.keymap.set("n", "<Leader>gp", "<Cmd>Projects<CR>")
            vim.keymap.set("n", "<Leader>g/", "<Cmd>Lines<CR>")
            vim.keymap.set("n", "<Leader>g]", "<Cmd>Tags <C-r>=expand('<cword>')<CR><CR>")
            vim.keymap.set("n", "<Leader>o", "<Cmd>History<CR>")
            vim.keymap.set("n", "<Leader>q:", "<Cmd>History:<CR>")
            vim.keymap.set("n", "<Leader>q/", "<Cmd>History/<CR>")
            vim.keymap.set("n", "<Leader>'", "<Cmd>Marks<CR>")
            vim.keymap.set("n", "<Leader>/", "<Cmd>BLines<CR>")
            vim.keymap.set("n", "<Leader>:", "<Cmd>Commands<CR>")
            vim.keymap.set("n", "<Leader>]", "<Cmd>BTags <C-r>=expand('<cword>')<CR><CR>")
          '';
        }
        {
          plugin = pkgs.vimPlugins.gitsigns-nvim;
          type = "lua";
          config = ''
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
          config = ''
            hi link IlluminatedWordText cursorLine
            hi link IlluminatedWordRead cursorLine
            hi link IlluminatedWordWrite cursorLine
            nnoremap <silent> <Leader>t* <Cmd>IlluminationToggle<CR>
          '';
        }
        {
          plugin = pkgs.vimPlugins.indent-blankline-nvim;
          type = "lua";
          config = ''
            require("ibl").setup({
              enabled = false,
            })
            vim.keymap.set("n", "<Leader>t<Tab>", "<Cmd>IBLToggle<CR>")
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-notify;
          type = "lua";
          config = ''
            vim.notify = require("notify")
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-treesitter-context;
          type = "lua";
          config = ''
            require("treesitter-context").setup({ enable = false })
            vim.keymap.set("n", "<Leader>tz", "<Cmd>TSContextToggle<CR>")
          '';
        }

        # Language Support
        pkgs.vimPlugins.friendly-snippets
        {
          plugin = pkgs.vimPlugins.blink-cmp;
          type = "lua";
          config = ''
            local blink = require("blink-cmp")
            blink.setup({
              completion = {
                menu = {
                  winblend = vim.o.pumblend,
                },
                documentation = {
                  auto_show = true,
                  window = {
                    winblend = vim.o.pumblend,
                  },
                },
              },
              signature = {
                enabled = true,
                window = {
                  winblend = vim.o.pumblend,
                },
              },
            })
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          type = "lua";
          config = ''
            local capabilities = blink.get_lsp_capabilities()
            local lspconfig = require("lspconfig")
            local servers = {
              "ansiblels",
              "clangd",
              "eslint",
              "gopls",
              "jdtls",
              "rust_analyzer",
              "rubocop",
              "pyright",
              "ts_ls",
            }

            for _, lsp in ipairs(servers) do
              lspconfig[lsp].setup({
                capabilities = capabilities,
                silent = true,
              })
            end
          '';
        }
        {
          plugin = pkgs.vimPlugins.ale;
          type = "lua";
          config = ''
            vim.g.ale_use_neovim_diagnostics_api = true
            vim.g.ale_disable_lsp = true
            vim.g.ale_set_quickfix = false
            vim.g.ale_set_loclist = false
          '';
        }

        # TreeSitter
        {
          plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
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
          config = ''
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
          config = ''
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
                sources = {
                  { source = "filesystem", display_name = " 󰉓 Files" },
                  { source = "buffers", display_name = " 󰈙 Buffers" },
                  { source = "git_status", display_name = "  Git" },
                  { source = "document_symbols", display_name = "  Symbols" },
                },
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
          '';
        }
        {
          plugin = pkgs.vimPlugins.tagbar;
          type = "lua";
          config = ''
            vim.keymap.set("n", "<Leader>tt", "<Cmd>TagbarToggle<CR>")
          '';
        }
        {
          plugin = pkgs.vimPlugins.undotree;
          type = "lua";
          config = ''
            vim.g.undotree_WindowLayout = 2
            vim.keymap.set("n", "<Leader>tu", "<Cmd>UndotreeToggle<CR>")
          '';
        }
      ];
    };
  };
}
