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
        pkgs.vimPlugins.vim-airline-themes
        pkgs.vimPlugins.vim-peekaboo
        {
          plugin = pkgs.vimPlugins.vim-airline;
          type = "lua";
          # https://github.com/neovim/neovim/issues/14281
          config = ''
            vim.opt.showmode = false
            vim.g.airline_skip_empty_sections = true
            if vim.env.USE_POWERLINE ~= "" then
              vim.g.airline_powerline_fonts = true

              -- Fira Code doesn't contain the colnr symbol yet
              -- https://github.com/tonsky/FiraCode/issues/1243
              vim.g.airline_symbols = { colnr = "${builtins.fromJSON ''"\u33c7"''}" }
            end
            vim.g["airline#parts#ffenc#skip_expected_string"] = "utf-8[unix]"
          '';
        }
        {
          plugin = pkgs.vimPlugins.context-vim;
          type = "lua";
          config = ''
            vim.g.context_enabled = false
            vim.keymap.set("n", "<Leader>tz", "<Cmd>ContextToggle<CR>")
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

        # Language Support
        pkgs.vimPlugins.cmp-buffer
        pkgs.vimPlugins.cmp-path
        pkgs.vimPlugins.cmp-nvim-lsp
        pkgs.vimPlugins.cmp-nvim-lsp-signature-help
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          type = "lua";
          config = ''
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")
            local servers = {
              "ansiblels",
              "clangd",
              "eslint",
              "jdtls",
              "rust_analyzer",
              "rubocop",
              "pyright",
              "tsserver",
            }

            for _, lsp in ipairs(servers) do
              lspconfig[lsp].setup({
                capabilities = capabilities,
              })
            end
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-cmp;
          type = "lua";
          config = ''
            local cmp = require("cmp")
            cmp.setup({
              mapping = cmp.mapping.preset.insert(),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
              }, {
                { name = "path" },
              }, {
                { name = "buffer" },
              }),
              snippet = {
                expand = function(args)
                  vim.snippet.expand(args.body)
                end,
              },
            })
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
          plugin = pkgs.vimPlugins.nerdtree;
          type = "lua";
          config = ''
            vim.keymap.set("n", "<Leader>tf", "<Cmd>NERDTreeToggle<CR>")
            vim.keymap.set("n", "<Leader>tF", "<Cmd>NERDTreeFind<CR>")
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
