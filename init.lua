local TAB_WIDTH = 4

local keymap = {
    -- n
    search_for_files_in_working_directory   = '<c-p>',
    search_for_previously_opened_files      = '<Space><Space>',
    live_grep                               = '<Space>fg',
    search_help_pages                       = '<Space>fh',

    -- n
    rename_symbol                           = '<leader>rn',
    code_action                             = '<leader>ca',
    go_to_definition                        = 'gd',
    go_to_implementation                    = 'gi',
    show_references                         = 'gr',
    hovering_documentation                  = 'K',

    -- n
    toggle_file_explorer                    ='<c-n>',

    -- n
    leader_key                              = ';',
    split_line                              = "<leader>s", --TODO Not complete yet. Too tired atm

    -- n
    move_to_panel_left                      = '<c-h>',
    move_to_panel_down                      = '<c-j>',
    move_to_panel_up                        = '<c-k>',
    move_to_panel_right                     = '<c-l>',

    -- i, s
    autocomplete_abort                      = '<C-e>',
    autocomplete_confirm                    = '<C-j>',
    jump_forward_in_snippet                 = '<C-k>',
    jump_backward_in_snippet                = '<C-h>',
    jump_to_snippet_end                     = '<C-l>',
}

local theme_with_real_colors = true

vim.g.mapleader = keymap.leader_key
vim.g.maplocalleader = keymap.leader_key
vim.opt.tabstop = TAB_WIDTH     -- Character width of a tab
vim.opt.shiftwidth = 0          -- Will always be eual to the tabstop
vim.opt.rnu = true              -- Shows relative line numbers
vim.opt.nu = true               -- Shows current line number
vim.opt.wrap = false            -- Don't wrap the line. Let it go offscreen.
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.hlsearch = false        -- Don't highlight searches
vim.opt.incsearch = true        -- Highlight matching patterns as the you are typing it.
vim.opt.scrolloff = 8           -- Always keep 8 lines of code between the cursor and the top/bottom of the screen.
vim.api.nvim_set_option("clipboard", "unnamedplus")
vim.api.nvim_set_keymap('n', keymap.move_to_panel_left, '<cmd>wincmd h<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.move_to_panel_down, '<cmd>wincmd j<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.move_to_panel_up, '<cmd>wincmd k<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.move_to_panel_right, '<cmd>wincmd l<CR>', {silent = true})
vim.g.c_syntax_for_h = 1
vim.g.python_indent = { -- Fixes retarded default python indentation.
    open_paren = 'shiftwidth()',
    nested_paren = 'shiftwidth()',
    continue = 'shiftwidth()',
    closed_paren_align_last_line = false,
    searchpair_timeout = 300,
}

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
    use 'lervag/vimtex'                     -- Provides autocompile on save and stuff. (Could probably just replace this thing with something custom)
    use 'ellisonleao/gruvbox.nvim'          -- Provides these sick colors.
    use 'nvim-tree/nvim-tree.lua'           -- File explorer.
    use 'nvim-tree/nvim-web-devicons'       -- Provides Pretty icons to look at. Makes the plugin above and below pretty.
    use 'nvim-lualine/lualine.nvim'         -- Lower info-bar. Displays filetype of current open file, and whether the file has unstated changes.
    use 'nvim-treesitter/nvim-treesitter'   -- Provides syntax highlighting for many lanugages.

    use 'hrsh7th/nvim-cmp'                  -- Autocompletion framework
    use 'hrsh7th/cmp-nvim-lsp'              -- Autocompletion lsp integration
    use 'folke/neodev.nvim'                 -- lsp integration with the nvim lua API

    use 'dcampos/nvim-snippy'               -- Snippet engine Handles the actual
                                            -- pasting of lsp suggestions. As well as custom snippets
                                            -- (Custom snippets are awesome)

    use 'dcampos/cmp-snippy'                -- nvim-cmp integration

    use {-- LSP
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig', }

    use {-- FuzzyFind your way through previously open files, or project files.
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        requires = { {'nvim-lua/plenary.nvim'}, } }

    use {-- Provides live preview of markdown files that follows the cursor around.
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" }, }

    use 'folke/zen-mode.nvim' -- For centering the text on screen giving a better editing experience in full-screen mode.

    if packer_bootstrap then --Comes after packages
        require('packer').sync()
    end

    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_syntax_enabled = false

    if theme_with_real_colors then
        vim.o.termguicolors = true
        vim.o.background = "dark"
        vim.cmd [[ colorscheme gruvbox ]]
    end

    vim.g.loaded_netrw = 1       -- Disables some built in plugin
    vim.g.loaded_netrwPlugin = 1 -- Disables some built in plugin
    require('nvim-tree').setup()
    vim.keymap.set('n', keymap.toggle_file_explorer, '<cmd>NvimTreeFindFileToggle<CR>', {silent = true})

    require('lualine').setup {options = {icons_enabled = true, theme = 'gruvbox'}}

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
            [keymap.autocomplete_abort]         = cmp.mapping(
                function (_)
                    cmp.mapping.abort()
                end,
                { "i", "s" }
            ),
            [keymap.autocomplete_confirm]       = cmp.mapping(
                function (_)
                    cmp.confirm{ select = true }
                end,
                { "i", "s" }
            ),
            [keymap.jump_backward_in_snippet]   = cmp.mapping(
                function (_)
                    if snippy.can_jump(-1) then
                        snippy.previous()
                    end
                end,
                { "i", "s" }
            ),
            [keymap.jump_forward_in_snippet]    = cmp.mapping(
                function(_)
                    if snippy.can_jump(1) then
                        snippy.next()
                    end
                end,
                { "i", "s" }
            ),
            [keymap.jump_to_snippet_end]        = cmp.mapping(
                function(_)
                    while snippy.can_jump(1) do
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
            'clangd', 'golangci_lint_ls', 'kotlin_language_server',
            'ltex', 'lua_ls', 'marksman', 'pyright', 'zls', 'rust_analyzer'
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
                        runtime = { version = 'LuaJIT', }
                    }
                }
            }
        end,
    }
    vim.keymap.set('n', keymap.rename_symbol, vim.lsp.buf.rename, {})
    vim.keymap.set('n', keymap.code_action, vim.lsp.buf.code_action, {})
    vim.keymap.set('n', keymap.go_to_definition, vim.lsp.buf.definition, {})
    vim.keymap.set('n', keymap.go_to_implementation, vim.lsp.buf.implementation, {})
    vim.keymap.set('n', keymap.show_references, require('telescope.builtin').lsp_references, {})
    vim.keymap.set('n', keymap.hovering_documentation, vim.lsp.buf.hover, {})

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', keymap.search_for_files_in_working_directory, builtin.find_files, {})
    vim.keymap.set('n', keymap.search_for_previously_opened_files, builtin.oldfiles, {})
    vim.keymap.set('n', keymap.live_grep, builtin.live_grep, {})
    vim.keymap.set('n', keymap.search_help_pages, builtin.help_tags, {})

end

do
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
            local snippets_path = vim.fn.stdpath('config') .. '/snippets/' ..
                                vim.api.nvim_buf_get_option(0, "filetype") .. '.snippets'

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
end

--  local function split_line()
--      local line = vim.api.nvim_get_current_line()
--      local items = vim.split(line, ", *")
--      local indent = string.match(line, "^%s*")

--      local formatted_items = {items[1] .. ','}
--      for i = 2, #items -1 do
--          table.insert(formatted_items, indent .. tab_whitespace .. items[i] .. ',')
--      end
--      table.insert(formatted_items, indent .. tab_whitespace .. items[#items] )

--      local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
--      vim.api.nvim_buf_set_lines(0, row-1, row, false, formatted_items)
--  end

local split_line
do
    local TAB_WHITESPACE = ''
    for _ = 1, TAB_WIDTH do
        TAB_WHITESPACE = TAB_WHITESPACE .. ' '
    end

    local BRACKET_COMPLEMENTS = {
        ['{'] ='}',
        ['['] = ']',
        ['('] = ')'
    }

    local OPENING_BRACKET_PATTERN = "[%(%[{]"

    split_line = function()
        local line = vim.api.nvim_get_current_line()

        ---@type integer?
        local first_bracket_i = string.find(line, OPENING_BRACKET_PATTERN)
        assert(first_bracket_i, 'No opening brackets found on given line')

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

                if char:match(OPENING_BRACKET_PATTERN) then
                    table.insert(
                        closing_bracket_stack,
                        BRACKET_COMPLEMENTS[
                            line:sub(i, i)
                        ]
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

        assert(last_bracket_i, "The opening bracket was not closed")

        ---@type string
        local leading_whitespace = string.match(line, "^%s*")
        local first_line = line:sub(1, first_bracket_i)
        local last_line = leading_whitespace .. line:sub(last_bracket_i, #line)
        local concatenated_middle = line:sub(first_bracket_i+1, last_bracket_i-1)
        local adjusted_comma_indexes = {1}
        --TODO populate this instead. Don't bother with the indexes
        local dirty_middle_lines = {}
        do
            local first_line_len = #first_line
            for _, comma_i in ipairs(comma_indexes) do
                table.insert(adjusted_comma_indexes, comma_i - #first_line)
            end
            table.insert(adjusted_comma_indexes, #concatenated_middle)
        end

        ---@type string[]
        local middle_lines = {}
        do
            ---@type string
            local leading_indented_whitespace = leading_whitespace .. TAB_WHITESPACE
            for _, comma_i in ipairs(adjusted_comma_indexes) do
                table.insert(
                    middle_lines,
                    --TODO does not work. Need to separate all the different items, and match from beginning to end to clean them up
                    leading_indented_whitespace .. concatenated_middle:match('([^%s,].*)%s*,%s*', comma_i)
                )
            end
        end
    end
end


vim.keymap.set('n',
    keymap.split_line,
    split_line,
    { silent = true })

return require('packer').startup(packer_startup)
