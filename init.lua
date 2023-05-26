local keymap = {
    search_for_files_in_working_directory   = '<c-p>',
    search_for_previously_opened_files      = '<Space><Space>',
    search_within_open_file                 = '<Space>fg',
    search_help_pages                       = '<Space>fh',

    rename_symbol                           = '<leader>rn',
    code_action                             = '<leader>ca',
    go_to_definition                        = 'gd',
    go_to_implementation                    = 'gi',
    show_references                         = 'gr',
    hovering_documentation                  = 'K',

    toggle_file_explorer                    ='<c-n>',

    leader_key                              = ';',
}

vim.g.mapleader = keymap.leader_key
vim.g.maplocalleader = keymap.leader_key
vim.opt.tabstop = 4     -- Character width of a tab
vim.opt.shiftwidth = 0  -- Will always be eual to the tabstop
vim.opt.rnu = true      -- Shows relative line numbers
vim.opt.nu = true       -- Shows current line number
vim.opt.wrap = false    -- Don't wrap the line. Let it go offscreen.
vim.opt.shiftround = true
vim.opt.expandtab = true


-- Will only run the first time nvim launches to install packer
    local ensure_packer = function()
        local fn = vim.fn
        local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
            vim.cmd [[packadd packer.nvim]]
            return true
        end
        return false
    end
    local packer_bootstrap = ensure_packer()

-- Packages
local function packer_startup(use)
    use 'wbthomason/packer.nvim'
    use 'lervag/vimtex'                     -- Latex
        vim.g.vimtex_view_method = 'zathura'
    use 'ellisonleao/gruvbox.nvim'          -- Theme
        vim.o.termguicolors = true
        vim.cmd [[ colorscheme gruvbox ]]
    use 'nvim-tree/nvim-tree.lua'           -- File explorer
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        require('nvim-tree').setup()
        vim.keymap.set('n', keymap.toggle_file_explorer, ':NvimTreeFindFileToggle<CR>')
    use 'nvim-tree/nvim-web-devicons'       -- Icons for file explorer and info bar
    use 'nvim-lualine/lualine.nvim'         -- Lower info-bar
        require('lualine').setup {options = {icons_enabled = true, theme = 'gruvbox'}}
    use 'nvim-treesitter/nvim-treesitter'   -- Syntax highlighting
        require('nvim-treesitter.configs').setup {
            ensure_installed = 'all',
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            }
        }
    use {                                   -- LSP
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
    }   require('mason').setup()
        require('mason-lspconfig').setup{
            ensure_installed = {
                'clangd', 'golangci_lint_ls', 'kotlin_language_server',
                'ltex', 'lua_ls', 'marksman', 'pyright', 'zls', 'rust_analyzer'
            }
        }
        require("mason-lspconfig").setup_handlers {
            function (server_name)
                require("lspconfig")[server_name].setup {}
            end,
        }
        vim.keymap.set('n', keymap.rename_symbol, vim.lsp.buf.rename, {})
        vim.keymap.set('n', keymap.code_action, vim.lsp.buf.code_action, {})
        vim.keymap.set('n', keymap.go_to_definition, vim.lsp.buf.definition, {})
        vim.keymap.set('n', keymap.go_to_implementation, vim.lsp.buf.implementation, {})
        vim.keymap.set('n', keymap.show_references, require('telescope.builtin').lsp_references, {})
        vim.keymap.set('n', keymap.hovering_documentation, vim.lsp.buf.hover, {})

    use { 'nvim-telescope/telescope.nvim',  -- FuzzyFind
        tag = '0.1.1',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'BurntSushi/ripgrep'},
            -- ripgrep might not actually
            -- be a nvim package
        }
    };  local builtin = require('telescope.builtin')
        vim.keymap.set('n', keymap.search_for_files_in_working_directory, builtin.find_files, {})
        vim.keymap.set('n', keymap.search_for_previously_opened_files, builtin.oldfiles, {})
        vim.keymap.set('n', keymap.search_within_open_file, builtin.live_grep, {})
        vim.keymap.set('n', keymap.search_help_pages, builtin.help_tags, {})

    if packer_bootstrap then -- Must be last instruction.
        require('packer').sync()
    end
end

return require('packer').startup(packer_startup)
