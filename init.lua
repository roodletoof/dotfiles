local keymap = {
    leader_key = ';',

    -- Normal mode --------------------------------------------------------------------------------------
    telescope_search_for_files_in_working_directory = '<Space>d',
    telescope_search_for_previously_opened_files    = '<Space><Space>',
    telescope_live_grep                             = '<Space>g',
    telescope_search_help_pages                     = '<Space>h',

    lsp_rename_symbol          = '<leader>rn',
    lsp_code_action            = '<leader>ca',
    lsp_go_to_definition       = 'gd',
    lsp_go_to_implementation   = 'gi',
    lsp_show_references        = 'gr',
    lsp_hovering_documentation = 'K',

    test_execute_script      = '<leader>e',

    navigation_toggle_file_explorer ='<c-n>',

    navigation_move_to_panel_left   = '<c-h>',
    navigation_move_to_panel_down   = '<c-j>',
    navigation_move_to_panel_up     = '<c-k>',
    navigation_move_to_panel_right  = '<c-l>',

    formatting_split_line = "<leader>s",
        --> Splits the current line with comma separated items in paranthesis into multiple lines.
        --> Works on all types of parenthesis, and is aware of strings.

    -- Insert / Selection mode --------------------------------------------------------------------------
    snippet_confirm       = '<c-j>',
    snippet_jump_forward  = '<c-k>',
    snippet_jump_backward = '<c-h>',
    snippet_jump_to_end   = '<c-l>',
        --> Edit snippets for the current file with the custom S command.
        --> Follow the printed instructions on failure.
}
local TAB_WIDTH = 4

---@type installed_themes
local colorscheme = 'gruvbox'

vim.o.termguicolors = true
vim.cmd('colorscheme ' .. colorscheme)

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
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_left, '<cmd>wincmd h<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_down, '<cmd>wincmd j<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_up, '<cmd>wincmd k<CR>', {silent = true})
vim.api.nvim_set_keymap('n', keymap.navigation_move_to_panel_right, '<cmd>wincmd l<CR>', {silent = true})
vim.g.c_syntax_for_h = 1
vim.g.python_indent = { -- Fixes retarded default python indentation.
    open_paren = 'shiftwidth()',
    nested_paren = 'shiftwidth()',
    continue = 'shiftwidth()',
    closed_paren_align_last_line = false,
    searchpair_timeout = 300,
}

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

    use 'ellisonleao/gruvbox.nvim'

    use 'nvim-tree/nvim-tree.lua'           -- File explorer.
    use 'nvim-tree/nvim-web-devicons'       -- Provides Pretty icons to look at. Makes the plugin above and below pretty.
    use 'nvim-lualine/lualine.nvim'         -- Provides file information on status bar on the bottom of the wihdow.

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
        requires = {
            {'nvim-lua/plenary.nvim'},
        }
    }

    use 'folke/zen-mode.nvim' -- For centering the text on screen giving a better editing experience in full-screen mode.


    if packer_bootstrap then --Comes after packages
        require('packer').sync()
    end


    vim.g.loaded_netrw = 1       -- Disables some built in plugin
    vim.g.loaded_netrwPlugin = 1 -- Disables some built in plugin
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
            'clangd', 'golangci_lint_ls', 'kotlin_language_server',
            'ltex', 'lua_ls', 'marksman', 'pyright', 'rust_analyzer'
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
    require("lspconfig").gdscript.setup{
        capabilities = capabilities
    }
    require('lspconfig').zls.setup{
        capabilities = capabilities
    }
    vim.keymap.set('n', keymap.lsp_rename_symbol, vim.lsp.buf.rename, {})
    vim.keymap.set('n', keymap.lsp_code_action, vim.lsp.buf.code_action, {})
    vim.keymap.set('n', keymap.lsp_go_to_definition, vim.lsp.buf.definition, {})
    vim.keymap.set('n', keymap.lsp_go_to_implementation, vim.lsp.buf.implementation, {})
    vim.keymap.set('n', keymap.lsp_show_references, require('telescope.builtin').lsp_references, {})
    vim.keymap.set('n', keymap.lsp_hovering_documentation, vim.lsp.buf.hover, {})

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', keymap.telescope_search_for_files_in_working_directory, builtin.find_files, {})
    vim.keymap.set('n', keymap.telescope_search_for_previously_opened_files, builtin.oldfiles, {})
    vim.keymap.set('n', keymap.telescope_live_grep, builtin.live_grep, {})
    vim.keymap.set('n', keymap.telescope_search_help_pages, builtin.help_tags, {})

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

---Returns function that runs the given script_name in the current working directory.
---Only implemented for Linux. ( Uses the sh command )
---@param script_name string
---@return fun() 
local function get_run_script_function(script_name)
    return function()
        ---@type "Linux" | "Darwin" | "Windows_NT"
        local os_name = vim.loop.os_uname().sysname
        if os_name ~= "Linux" then
            error('run_file not implemented for non-linux platforms')
        end

        local run_script_path = vim.fn.getcwd() .. "/" .. script_name
        if not file_exists(run_script_path) then
            error(
                "The run script: '" .. run_script_path .. "' does not exist.\n"..
                "All this command does, is to execute that file."
            )
        end

        vim.cmd('!sh ' .. run_script_path)
    end
end

do
    -- To create a script that runs when typing the command "<leader>er",
    -- create a script called ".r.sh" in the current directory.
    local alphabet = 'abcdefghijklmnopqrstuvwxyzæøåABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ'
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
---The function will properly indent all the lines, but only uses spaces to do so.
---It is currently tied to this init.lua file by a couple of variables. Might become a separate package at some point.
---@type function
local split_line
do
    local TAB_WHITESPACE = ''
    for _ = 1, TAB_WIDTH do
        TAB_WHITESPACE = TAB_WHITESPACE .. ' '
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

return require('packer').startup(packer_startup)


---@alias installed_themes
---| 'blue'
---| 'darkblue'
---| 'default'
---| 'delek'
---| 'desert'
---| 'elflord'
---| 'evening'
---| 'gruvbox'
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
