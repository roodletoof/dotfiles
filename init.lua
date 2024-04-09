local keymap = {
    leader_key = ';',

    -- Terminal mode ------------------------------------------------------------------------------------
    exit_terminal_mode = '<esc>',
    toggle_terminal = '<c-;>',

    -- Normal mode --------------------------------------------------------------------------------------
    telescope_search_for_files_in_working_directory = '<space>d',
    telescope_search_for_previously_opened_files = '<space><space>',
    telescope_live_grep = '<space>g',
    telescope_search_help_pages = '<space>h',
    telescope_search_current_buffer = '<space>j',
    telescope_search_buffers = '<space>o',

    lsp_rename_symbol = '<leader>rn',
    lsp_code_action = '<leader>ca',
    lsp_go_to_definition = 'gd',
    lsp_go_to_type_definition = 'gt',
    lsp_go_to_implementation = 'gi',
    lsp_show_references = 'gr',
    lsp_hovering_documentation = 'K',
    lsp_next_diagnostic = '<leader>j',
    lsp_hovering_diagnostics = '<leader>k',

    test_execute_script = '<leader>e',

    navigation_toggle_file_explorer ='<c-n>',

    navigation_move_to_panel_left = '<c-h>',
    navigation_move_to_panel_down = '<c-j>',
    navigation_move_to_panel_up = '<c-k>',
    navigation_move_to_panel_right = '<c-l>',

    formatting_split_line = "<leader>s",
        --> Splits the current line with comma separated items in paranthesis into multiple lines.
        --> Works on all types of parenthesis, and is aware of strings.

    -- Insert / Selection mode --------------------------------------------------------------------------
    snippet_confirm = '<c-j>',
    snippet_jump_forward = '<c-k>',
    snippet_jump_backward = '<c-h>',
        --> Edit snippets for the current file with the custom S command.
        --> Follow the printed instructions on failure.

    debug_continue = '<space>r',
    debug_run_to_cursor = '<space>c',
    debug_toggle_breakpoint = '<space>b',
    debug_clear_breakpoints = '<space>B',
    debug_step_over = '<right>',
    debug_step_into = '<down>',
    debug_step_out = '<up>',
    debug_state = '<space>s',
    debug_terminate = '<space>t',
    debug_view_expr_value = '<space>e',
    debug_frames = '<space>f',

}
local TAB_WIDTH = 4
local EXPAND_TAB = true

---@type installed_themes
--local colorscheme = 'slate'
local colorscheme = 'gruvbox'


vim.cmd [[ autocmd VimEnter * NoMatchParen ]]
vim.g.mapleader = keymap.leader_key
vim.g.maplocalleader = keymap.leader_key
vim.opt.tabstop = TAB_WIDTH-- Character width of a tab
vim.opt.shiftwidth = 0-- Will always be eual to the tabstop
vim.opt.rnu = true-- Shows relative line numbers
vim.opt.nu = true-- Shows current line number
vim.opt.wrap = false-- Don't wrap the line. Let it go offscreen.
vim.opt.shiftround = true
vim.opt.expandtab = EXPAND_TAB
vim.opt.hlsearch = false-- Don't highlight searches
vim.opt.incsearch = true-- Highlight matching patterns as the you are typing it.
vim.opt.scrolloff = 8-- Always keep 8 lines of code between the cursor and the top/bottom of the screen.
vim.api.nvim_set_option("clipboard", "unnamedplus")
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_left, '<cmd>wincmd h<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_down, '<cmd>wincmd j<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_up, '<cmd>wincmd k<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_right, '<cmd>wincmd l<CR>', {silent = true})

vim.api.nvim_set_keymap('t', keymap.exit_terminal_mode, '<C-\\><C-n>', {silent = true})
vim.api.nvim_set_keymap('t', keymap.navigation_move_to_panel_left, '<cmd>wincmd h<CR>', {silent = true})
vim.api.nvim_set_keymap('t', keymap.navigation_move_to_panel_down, '<cmd>wincmd j<CR>', {silent = true})
vim.api.nvim_set_keymap('t', keymap.navigation_move_to_panel_up, '<cmd>wincmd k<CR>', {silent = true})
vim.api.nvim_set_keymap('t', keymap.navigation_move_to_panel_right, '<cmd>wincmd l<CR>', {silent = true})
vim.cmd [[ autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif ]]

vim.g.c_syntax_for_h = 1
vim.g.python_indent = { -- Fixes retarded default python indentation.
    open_paren = 'shiftwidth()',
    nested_paren = 'shiftwidth()',
    continue = 'shiftwidth()',
    closed_paren_align_last_line = false,
    searchpair_timeout = 300,
}
vim.api.nvim_create_autocmd('TextYankPost', { -- Highlights yanked text.
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', {clear = true}),
    callback = function()
        vim.highlight.on_yank()
    end
})
vim.o.exrc = true -- Allows project specific .nvim.lua config files.
vim.cmd [[ autocmd FileType * set formatoptions-=cro ]] -- Disable automatic comment.


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

local function packer_startup(use)
    use 'wbthomason/packer.nvim'

    use 'nvim-tree/nvim-tree.lua'-- File explorer.
    use 'nvim-tree/nvim-web-devicons'-- Provides Pretty icons to look at. Makes the plugin above and below pretty.
    use 'nvim-lualine/lualine.nvim'-- Provides file information on status bar on the bottom of the wihdow.

    use 'nvim-treesitter/nvim-treesitter'-- Provides syntax highlighting for many lanugages.

    use 'hrsh7th/nvim-cmp'-- Autocompletion framework
    use 'hrsh7th/cmp-nvim-lsp'-- Autocompletion lsp integration
    use 'folke/neodev.nvim'-- lsp integration with the nvim lua API

    use 'dcampos/nvim-snippy'-- Snippet engine Handles the actual
        -- pasting of lsp suggestions. As well as custom snippets
        -- (Custom snippets are awesome)

    use 'dcampos/cmp-snippy'-- nvim-cmp integration

    use {-- LSP
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig', }

    use {-- FuzzyFind your way through previously open files, or project files.
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use 'folke/zen-mode.nvim' -- For centering the text on screen giving a better editing experience in full-screen mode.

    use 'michaeljsmith/vim-indent-object' -- Treats lines of the same indentation as a new text object, access with i and I.
    use 'tpope/vim-surround' -- Allows you to surround text with tags, quotes and brackets.
    use 'tpope/vim-repeat' -- Needed for above plugin to repeat actions.

    use 'mfussenegger/nvim-dap'
    use 'mfussenegger/nvim-dap-python' -- follow instructions or start venv before starting nvim.
    use 'theHamsta/nvim-dap-virtual-text'
    use 'leoluz/nvim-dap-go'

    use "ellisonleao/gruvbox.nvim"

    use {"akinsho/toggleterm.nvim", tag = '*', config = function()
        require("toggleterm").setup{ }
    end}

    if packer_bootstrap then --Comes after packages
        require('packer').sync()
    end

    -- set colors after packer, because colorscheme might be installed
    vim.o.termguicolors = true
    vim.cmd('colorscheme ' .. colorscheme)

    vim.g.loaded_netrw = 1-- Disables some built in plugin
    vim.g.loaded_netrwPlugin = 1--Disables some built in plugin
    require'nvim-tree'.setup()
    vim.keymap.set('n', keymap.navigation_toggle_file_explorer, '<cmd>NvimTreeFindFileToggle<CR>', {silent = true})

    require'lualine'.setup{}

    require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        }
    }

    local cmp = require('cmp')
    local types = require('cmp.types')
    local snippy = require('snippy')

    cmp.setup{
        mapping = {
            ['<Down>'] = { i = cmp.mapping.select_next_item{ behavior = types.cmp.SelectBehavior.Select } },
            ['<Up>'] = { i = cmp.mapping.select_prev_item{ behavior = types.cmp.SelectBehavior.Select } },
            [keymap.snippet_confirm]       = cmp.mapping(
                function (_)
                    cmp.confirm{ select = true }
                end,
                { "i", "s" }
            ),
            [keymap.snippet_jump_backward]   = cmp.mapping(
                function (_)
                    if snippy.can_jump(-1) then
                        snippy.previous()
                    end
                end,
                { "i", "s" }
            ),
            [keymap.snippet_jump_forward]    = cmp.mapping(
                function(_)
                    if snippy.can_jump(1) then
                        snippy.next()
                    end
                end,
                { "i", "s" }
            ),
        },
        snippet = {
            expand = function(args)
                snippy.expand_snippet(args.body)
            end,
        },
        sources = cmp.config.sources(
            {
                { name = 'snippy' },
                { name = 'nvim_lsp' },
            },
            {{ name = 'buffer' }}
        )
    }

    require('mason').setup()
    require('mason-lspconfig').setup{
        ensure_installed = {
            'clangd',
            'kotlin_language_server',
            'ltex',
            'lua_ls',
            'marksman',
            'pyright',
            'rust_analyzer',
            'gopls'
        }
    }
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    require("mason-lspconfig").setup_handlers {
        function (server_name) -- default_handler
            require("lspconfig")[server_name].setup {
                capabilities = capabilities
            }
        end,
        lua_ls = function()
            require("neodev").setup{} -- load the neovim api
            require("lspconfig").lua_ls.setup {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        workspace = {
                            checkThirdParty = true,
                        },

                    }
                }
            }
        end,
    }
-- * `Lua.runtime.special`: set the property `love.filesystem.load` to `"loadfile"`;
-- * `Lua.workspace.library`: add element `"${3rd}/love2d/library"` ;

    require("lspconfig").gdscript.setup{
        capabilities = capabilities
    }
    require('lspconfig').zls.setup{
        capabilities = capabilities
    }
    local telescope_builtin = require('telescope.builtin')
    vim.keymap.set('n', keymap.lsp_rename_symbol, vim.lsp.buf.rename, {})
    vim.keymap.set('n', keymap.lsp_code_action, vim.lsp.buf.code_action, {})
    vim.keymap.set('n', keymap.lsp_go_to_definition, telescope_builtin.lsp_definitions, {})
    vim.keymap.set('n', keymap.lsp_go_to_type_definition, telescope_builtin.lsp_type_definitions, {})
    vim.keymap.set('n', keymap.lsp_go_to_implementation, telescope_builtin.lsp_implementations, {})
    vim.keymap.set('n', keymap.lsp_show_references, telescope_builtin.lsp_references, {})
    vim.keymap.set('n', keymap.lsp_hovering_documentation, vim.lsp.buf.hover, {})
    vim.keymap.set('n', keymap.lsp_next_diagnostic, vim.diagnostic.goto_next, {})
    vim.keymap.set('n', keymap.lsp_hovering_diagnostics, vim.diagnostic.open_float, {})

    vim.keymap.set('n', keymap.telescope_search_for_files_in_working_directory, telescope_builtin.find_files, {})
    vim.keymap.set('n', keymap.telescope_search_for_previously_opened_files, telescope_builtin.oldfiles, {})
    vim.keymap.set('n', keymap.telescope_live_grep, telescope_builtin.live_grep, {})
    vim.keymap.set('n', keymap.telescope_search_help_pages, telescope_builtin.help_tags, {})
    vim.keymap.set('n', keymap.telescope_search_current_buffer, telescope_builtin.current_buffer_fuzzy_find, {})
    vim.keymap.set('n', keymap.telescope_search_buffers, telescope_builtin.buffers, {})

    local dap = require'dap'
    local widgets = require('dap.ui.widgets')
    local my_sidebar = widgets.sidebar(widgets.scopes)
    local my_centered = widgets.centered_float(widgets.frames)

    vim.api.nvim_create_autocmd('VimEnter', { -- Close the middle window that automatically opens for some reason.
        desc = 'Close the window floating in the middle as vim opens.',
        group = vim.api.nvim_create_augroup('close-dap-frames', {clear = true}),
        callback = function()
            my_centered.close()
        end
    }) --TODO change this if I can. Super hacky.

    vim.keymap.set('n', keymap.debug_continue, dap.continue, {})
    vim.keymap.set('n', keymap.debug_toggle_breakpoint, dap.toggle_breakpoint, {})
    vim.keymap.set('n', keymap.debug_clear_breakpoints, dap.clear_breakpoints, {})
    vim.keymap.set('n', keymap.debug_step_over, dap.step_over, {})
    vim.keymap.set('n', keymap.debug_step_into, dap.step_into, {})
    vim.keymap.set('n', keymap.debug_step_out, dap.step_out, {})
    vim.keymap.set('n', keymap.debug_state, my_sidebar.toggle, {})
    vim.keymap.set('n', keymap.debug_frames, my_centered.toggle, {})
    vim.keymap.set('n', keymap.debug_terminate, dap.terminate, {})
    vim.keymap.set('n', keymap.debug_run_to_cursor, dap.run_to_cursor, {})
    vim.keymap.set('n', keymap.debug_view_expr_value, widgets.hover, {})

    -- More configurations:
    -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go
    require'dap-python'.setup('~/.virtualenvs/debugpy/bin/python')
    require'dap-go'.setup()


    dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "-i", "dap" }
    }

    dap.configurations.c = {
        {
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "${workspaceFolder}",
            stopAtBeginningOfMainSubprogram = false,
        },
    }

    -- nicer debugging. displays variable values inline
    -- https://github.com/theHamsta/nvim-dap-virtual-text
    require'nvim-dap-virtual-text'.setup{}
end

---@param name string
---@return boolean
local function file_exists(name)
    local f = io.open(name,"r")

    if f~=nil then
        f:close()
        return true
    else
        return false
    end
end

-- Opens a default .snippets file for the filetype you are currently editing in a horizontal split pane.
-- If the .snippets file does not exist, it will be created.
-- This requires the snippets folder to exist in the config folder.
-- If the folder does not exist, the command will print out a helpful error message showing what the path
-- should look like.
vim.api.nvim_create_user_command(
    'S',
    function ()
        ---@type string
        local snippets_path = vim.fn.stdpath('config') .. '/snippets/' .. vim.api.nvim_buf_get_option(0, "filetype") .. '.snippets'

        if not file_exists(snippets_path) then
            local file = io.open( snippets_path, 'w' )
                assert(
                    file ~= nil,
                    ("io.open('%s', 'w') returned nil.\n"):format(snippets_path) ..
                    "Make sure the snippets folder in the above path exists."
                )
            file:close()
            print('created file: ', snippets_path)
        end

        vim.api.nvim_command(('SnippyEdit %s'):format(snippets_path))
    end,
    { nargs = 0 }
)

vim.api.nvim_create_user_command(
    'Json2go',
    function(opts)
        local lstart = opts.line1 - 1
        local lend = opts.line2
        local lines = vim.api.nvim_buf_get_lines(
            vim.api.nvim_get_current_buf(),
            lstart,
            lend,
            false
        )
        local lines_str = vim.fn.join(lines, ' ')
        lines_str = lines_str:gsub('\\', '\\\\')
        lines_str = lines_str:gsub("'", "\\'")
        ---@type string[]
        local struct_lines = {}

        local file = io.popen( "json2struct -s " .. "'" .. lines_str .. "'", "r" )
        assert(file ~= nil)
        for line in file:lines() do
            table.insert(struct_lines, line)
        end
        file:close()

        vim.api.nvim_buf_set_lines(0, lstart, lend, false, struct_lines)

    end,
    { range = true }
)


--{ "frames": [ { "filename": "cape", "frame": { "x": 32, "y": 45, "w": 4, "h": 7 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 7 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "cape", "frame": { "x": 12, "y": 46, "w": 5, "h": 5 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 19, "w": 5, "h": 5 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "cape", "frame": { "x": 32, "y": 45, "w": 4, "h": 7 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 7 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 12, "y": 46, "w": 5, "h": 5 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 19, "w": 5, "h": 5 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 37, "y": 45, "w": 4, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 27, "y": 46, "w": 3, "h": 5 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 16, "w": 3, "h": 5 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 22, "y": 46, "w": 4, "h": 4 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 4 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 42, "y": 49, "w": 2, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 18, "w": 2, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 18, "y": 46, "w": 3, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 18, "w": 3, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "cape", "frame": { "x": 72, "y": 43, "w": 12, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 3, "y": 18, "w": 12, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 50, "y": 32, "w": 3, "h": 7 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 3, "h": 7 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 37, "y": 45, "w": 4, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 27, "y": 46, "w": 3, "h": 5 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 16, "w": 3, "h": 5 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 22, "y": 46, "w": 4, "h": 4 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 4 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 42, "y": 49, "w": 2, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 18, "w": 2, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 37, "y": 45, "w": 4, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 27, "y": 46, "w": 3, "h": 5 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 16, "w": 3, "h": 5 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 22, "y": 46, "w": 4, "h": 4 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 1, "y": 17, "w": 4, "h": 4 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "cape", "frame": { "x": 42, "y": 49, "w": 2, "h": 6 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 18, "w": 2, "h": 6 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 1, "y": 31, "w": 10, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 10, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "hero", "frame": { "x": 12, "y": 31, "w": 9, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 9, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "hero", "frame": { "x": 1, "y": 31, "w": 10, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 10, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 12, "y": 31, "w": 9, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 9, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 67, "y": 29, "w": 11, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 3, "y": 11, "w": 11, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 54, "y": 29, "w": 12, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 10, "w": 12, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 42, "y": 16, "w": 11, "h": 15 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 10, "w": 11, "h": 15 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 22, "y": 31, "w": 9, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 9, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 32, "y": 31, "w": 9, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 12, "w": 9, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "hero", "frame": { "x": 23, "y": 1, "w": 19, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 19, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 43, "y": 1, "w": 19, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 19, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 63, "y": 1, "w": 20, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 3, "y": 11, "w": 20, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 63, "y": 15, "w": 20, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 10, "w": 20, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 1, "y": 1, "w": 21, "h": 15 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 10, "w": 21, "h": 15 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 23, "y": 16, "w": 18, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 18, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 63, "y": 1, "w": 20, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 3, "y": 11, "w": 20, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 63, "y": 15, "w": 20, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 10, "w": 20, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 1, "y": 1, "w": 21, "h": 15 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 2, "y": 10, "w": 21, "h": 15 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "hero", "frame": { "x": 23, "y": 16, "w": 18, "h": 14 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 4, "y": 11, "w": 18, "h": 14 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 1000 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 84, "y": 1, "w": 1, "h": 1 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 0, "y": 0, "w": 1, "h": 1 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 61, "y": 43, "w": 10, "h": 9 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 18, "y": 15, "w": 10, "h": 9 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 14, "y": 17, "w": 8, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 11, "y": 11, "w": 8, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 1, "y": 17, "w": 12, "h": 13 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 12, "y": 8, "w": 12, "h": 13 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 42, "y": 32, "w": 7, "h": 16 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 21, "y": 8, "w": 7, "h": 16 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 1, "y": 46, "w": 10, "h": 4 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 15, "y": 6, "w": 10, "h": 4 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 54, "y": 16, "w": 8, "h": 10 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 10, "y": 0, "w": 8, "h": 10 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 50, "y": 43, "w": 10, "h": 10 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 17, "y": 0, "w": 10, "h": 10 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 }, { "filename": "particle", "frame": { "x": 79, "y": 29, "w": 4, "h": 12 }, "rotated": false, "trimmed": true, "spriteSourceSize": { "x": 24, "y": 8, "w": 4, "h": 12 }, "sourceSize": { "w": 28, "h": 25 }, "duration": 100 } ], "meta": { "app": "https://www.aseprite.org/", "version": "1.3.5-x64", "image": "testSprite.ase.png", "format": "I8", "size": { "w": 86, "h": 56 }, "scale": "1", "frameTags": [ { "name": "idle", "from": 0, "to": 1, "direction": "forward", "color": "#000000ff" }, { "name": "laugh", "from": 2, "to": 3, "direction": "forward", "color": "#000000ff" }, { "name": "run", "from": 4, "to": 7, "direction": "forward", "color": "#000000ff" }, { "name": "draw_gun", "from": 8, "to": 10, "direction": "forward", "repeat": "1", "color": "#000000ff" }, { "name": "run_gun", "from": 11, "to": 18, "direction": "forward", "color": "#000000ff" } ], "layers": [ { "name": "cape", "opacity": 255, "blendMode": "normal", "cels": [{ "frame": 1, "color": "#57b9f2ff" }] }, { "name": "hero", "opacity": 255, "blendMode": "normal" }, { "name": "particle", "opacity": 255, "blendMode": "normal", "cels": [{ "frame": 13, "zIndex": -1, "data": "some user data here" }] } ], "slices": [ { "name": "hurtbox", "color": "#0000ffff", "data": "some user data", "keys": [{ "frame": 0, "bounds": {"x": 5, "y": 12, "w": 7, "h": 13 } }, { "frame": 1, "bounds": {"x": 5, "y": 12, "w": 6, "h": 13 } }, { "frame": 2, "bounds": {"x": 5, "y": 12, "w": 7, "h": 13 } }, { "frame": 3, "bounds": {"x": 5, "y": 12, "w": 6, "h": 13 } }, { "frame": 4, "bounds": {"x": 5, "y": 12, "w": 7, "h": 10 } }, { "frame": 5, "bounds": {"x": 5, "y": 11, "w": 6, "h": 11 } }, { "frame": 6, "bounds": {"x": 5, "y": 11, "w": 6, "h": 12 } }, { "frame": 7, "bounds": {"x": 5, "y": 12, "w": 6, "h": 13 } }, { "frame": 8, "bounds": {"x": 5, "y": 13, "w": 6, "h": 12 } }, { "frame": 9, "bounds": {"x": 5, "y": 12, "w": 6, "h": 13 } }, { "frame": 11, "bounds": {"x": 5, "y": 12, "w": 7, "h": 10 } }, { "frame": 12, "bounds": {"x": 5, "y": 11, "w": 6, "h": 11 } }, { "frame": 13, "bounds": {"x": 5, "y": 11, "w": 6, "h": 12 } }, { "frame": 14, "bounds": {"x": 5, "y": 12, "w": 6, "h": 13 } }, { "frame": 15, "bounds": {"x": 5, "y": 12, "w": 7, "h": 10 } }, { "frame": 16, "bounds": {"x": 5, "y": 11, "w": 6, "h": 11 } }, { "frame": 17, "bounds": {"x": 5, "y": 11, "w": 6, "h": 12 } }, { "frame": 18, "bounds": {"x": 5, "y": 12, "w": 6, "h": 13 } }] } ] } }


do
    ---Returns function that runs the given script_name in the current working directory.
    ---Only implemented for Linux. ( Uses the sh command )
    ---@param script_name string
    ---@return fun() 
    local function get_run_script_function(script_name)
        return function()
            ---@type "Linux" | "Darwin" | "Windows_NT"
            local os_name = vim.loop.os_uname().sysname
            if os_name == "Windows_NT" then
                error('run_file not implemented for non-unix platforms')
            end

            local run_script_path = vim.fn.getcwd() .. "/" .. script_name
            if not file_exists(run_script_path) then
                error(
                    "The run script: '" .. run_script_path .. "' does not exist.\n"..
                    "All this command does, is to execute that file."
                )
            end

            vim.cmd([[ TermExec cmd="sh ]].. run_script_path ..[[" direction=vertical size=80 ]])
        end
    end

    -- To create a script that runs when typing the command "<leader>er",
    -- create a script called ".r.sh" in the current directory.
    local alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    for i = 1, #alphabet do
        local char = alphabet:sub(i, i)
        vim.keymap.set(
            'n',
            keymap.test_execute_script .. char,
            get_run_script_function("." .. char .. ".sh"),
            { silent = true }
        )
    end
end

---Splits the line under the cursor into multiple lines.
---Works on lines with properly opening and closing brackets: (),[],{}
---Starts at the cursor position and moves to the right until it finds an opening bracket.
---Then formats all comma separated items within that bracket scope, and splits the line into multiple.
---The function is aware for strings starting with ' or ", and keeps track of how deeply nested it is 
---in the brackets.
---The function will properly indent all the lines, taking into consideration the TAB_WHITESPACE and EXPAND_TAB constants.
---It is currently tied to this init.lua file by a couple of variables. Might become a separate package at some point.
---@type function
local split_line
do
    local TAB_WHITESPACE = '\t'
    if EXPAND_TAB then
        TAB_WHITESPACE = ''
        for _ = 1, TAB_WIDTH do
            TAB_WHITESPACE = TAB_WHITESPACE .. ' '
        end
    end

    local get_closing_bracket = function(char)
        if char == '(' then return ')' end
        if char == '[' then return ']' end
        if char == '{' then return '}' end
        error("Not an opening bracket")
    end

    ---@param char string
    ---@return boolean
    local is_opening_bracket = function(char)
        return char == '(' or char == '[' or char == '{'
    end

    split_line = function()
        local line = vim.api.nvim_get_current_line()
        local _, col =  unpack(vim.api.nvim_win_get_cursor(0))
        col = col + 1 -- Doing this to make it 1-indexed

        ---@type integer?
        local first_bracket_i = nil
        for i = col, #line do
            local char = line:sub(i, i)
            if is_opening_bracket(char) then
                first_bracket_i = i
                break
            end
        end

        if not first_bracket_i then
            print('No opening brackets found after cursor on this line.')
            return
        end

        ---@type integer[]
        local comma_indexes = {} -- Populate this array
        ---@type integer?
        local last_bracket_i = nil -- And find this index

        do
            ---@type string[]
            local closing_bracket_stack = {}
            local icon_to_close_string = ''
            local in_string = false

            for i = first_bracket_i, #line do
                local char = line:sub(i,i)

                if in_string then
                    in_string = not (char == icon_to_close_string)
                    goto continue
                end

                if char == '"' or char == "'" then
                    icon_to_close_string = char
                    in_string = true
                    goto continue
                end
                -- string handling complete

                if is_opening_bracket( char ) then
                    table.insert(
                        closing_bracket_stack,
                        get_closing_bracket( char )
                    )
                end

                if char == closing_bracket_stack[#closing_bracket_stack] then
                    table.remove(closing_bracket_stack)
                end

                if #closing_bracket_stack == 1 and char == ',' then
                    table.insert(comma_indexes, i)
                end

                if #closing_bracket_stack == 0 then
                    last_bracket_i = i
                    break
                end
                ::continue::
            end
        end

        if not last_bracket_i then
            print("The first opening bracket found after the cursor was not closed on this line.")
            return
        end
        if #comma_indexes == 0 then
            print('No comma separated items within brackets that were opened and closed after the cursor.')
            return
        end

        ---@type string
        local leading_whitespace = string.match(line, "^%s*")
        local first_line = line:sub(1, first_bracket_i)
        local last_line = leading_whitespace .. line:sub(last_bracket_i, #line)

        local middle_lines = {}
        table.insert(
            middle_lines,
            line:sub(first_bracket_i+1, comma_indexes[1])
        )
        for i = 1, #comma_indexes-1 do
            table.insert(
                middle_lines,
                line:sub(comma_indexes[i], comma_indexes[i+1])
            )
        end
        table.insert(
            middle_lines,
            line:sub(comma_indexes[#comma_indexes], last_bracket_i-1)
        )

        -- Cleanup step
        for i, middle_line in ipairs(middle_lines) do
            middle_line = middle_line:gsub("^[%s,]*", leading_whitespace .. TAB_WHITESPACE, 1)
            middle_line = middle_line:gsub("[%s]*$", '', 1)
            middle_lines[i] = middle_line
        end

        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_lines(0, row-1, row, false, {first_line})
        vim.api.nvim_buf_set_lines(0, row, row, false, {last_line})
        vim.api.nvim_buf_set_lines(0, row, row, false, middle_lines)
    end
end


vim.keymap.set(
    'n',
    keymap.formatting_split_line,
    split_line,
    { silent = true }
)

vim.keymap.set(
    {'n', 't', 'i'},
    keymap.toggle_terminal,
    function ()
        vim.cmd [[ ToggleTerm direction=vertical size=80 ]]
    end,
    { silent = true }
)

return require('packer').startup(packer_startup)

---@alias installed_themes
---| 'blue'
---| 'darkblue'
---| 'default'
---| 'delek'
---| 'desert'
---| 'elflord'
---| 'evening'
---| 'habamax'
---| 'industry'
---| 'koehler'
---| 'lunaperche'
---| 'morning'
---| 'murphy'
---| 'pablo'
---| 'peachpuff'
---| 'quiet'
---| 'ron'
---| 'shine'
---| 'slate'
---| 'torte'
---| 'zellner'
---| 'gruvbox'
