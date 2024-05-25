-- GENERAL SETTINGS
---@type installed_themes
local colorscheme = 'habamax'
vim.o.termguicolors = true
vim.cmd('colorscheme ' .. colorscheme)

vim.cmd [[ autocmd VimEnter * NoMatchParen ]]
do
    local leader_key = ' '
    vim.g.mapleader = leader_key
    vim.g.maplocalleader = leader_key
end
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.rnu = true
vim.opt.nu = true
vim.opt.wrap = false
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8

vim.api.nvim_set_option("clipboard", "unnamedplus")

do
    local navigation_move_to_panel_left = '<c-h>'
    local navigation_move_to_panel_down = '<c-j>'
    local navigation_move_to_panel_up = '<c-k>'
    local navigation_move_to_panel_right = '<c-l>'

    vim.api.nvim_set_keymap('n', navigation_move_to_panel_left, '<cmd>wincmd h<CR>', {silent = true})
    vim.api.nvim_set_keymap('n', navigation_move_to_panel_down, '<cmd>wincmd j<CR>', {silent = true})
    vim.api.nvim_set_keymap('n', navigation_move_to_panel_up, '<cmd>wincmd k<CR>', {silent = true})
    vim.api.nvim_set_keymap('n', navigation_move_to_panel_right, '<cmd>wincmd l<CR>', {silent = true})
    vim.api.nvim_set_keymap('t', navigation_move_to_panel_left, '<cmd>wincmd h<CR>', {silent = true})
    vim.api.nvim_set_keymap('t', navigation_move_to_panel_down, '<cmd>wincmd j<CR>', {silent = true})
    vim.api.nvim_set_keymap('t', navigation_move_to_panel_up, '<cmd>wincmd k<CR>', {silent = true})
    vim.api.nvim_set_keymap('t', navigation_move_to_panel_right, '<cmd>wincmd l<CR>', {silent = true})
end

vim.api.nvim_set_keymap('t', '<esc>', '<C-\\><C-n>', {silent = true})
vim.cmd [[ autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif ]]

vim.cmd [[ autocmd BufWinLeave *.* silent! mkview ]]
vim.cmd [[ autocmd BufWinEnter *.* silent! loadview ]]

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
    callback = vim.highlight.on_yank
})
vim.o.exrc = true -- Allows project specific .nvim.lua config files.

vim.cmd [[ autocmd FileType * set formatoptions-=cro ]] -- Disable automatic comment.

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

-- Snippet edit functionality. Requires Snippy.
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

-- Json2go command. Convert selected json into a go struct by using json2struct terminal command. (install separateley)
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

-- execute project specific scripts
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
            "<leader>e" .. char,
            get_run_script_function("." .. char .. ".sh"),
            { silent = true }
        )
    end
end

-- split line functionality
---@type function
local split_line
do

    -- split_line settings
    local SPLIT_WHITESPACE = '    '
    local SPLIT_DELIMETERS = { -- single characters only
        [','] = true,
        [';'] = true,
    }
    local SPLIT_BETWEEN = { -- single characters only
        ['('] = ')',
        ['['] = ']',
        ['{'] = '}',
    }
    local SPLIT_IGNORE_BETWEEN = { --single characters only
        ['"'] = '"',
        ["'"] = "'",
    }

    split_line = function()
        local line = vim.api.nvim_get_current_line()
        local _, col =  unpack(vim.api.nvim_win_get_cursor(0))
        col = col + 1 -- Doing this to make it 1-indexed

        ---@type integer?
        local first_bracket_i = nil
        for i = col, #line do
            local char = line:sub(i, i)
            if SPLIT_BETWEEN[char] ~= nil then
                first_bracket_i = i
                break
            end
        end

        if not first_bracket_i then
            print('No opening brackets found after cursor on this line.')
            return
        end

        ---@type integer[]
        local split_indexes = {} -- Populate this array
        ---@type integer?
        local last_bracket_i = nil -- And find this index

        do
            ---@type string[]
            local closing_bracket_stack = {}
            local icon_to_close_ignore = ''
            local in_ignore = false

            for i = first_bracket_i, #line do
                local char = line:sub(i,i)

                if in_ignore then
                    in_ignore = not (char == icon_to_close_ignore)
                    goto continue
                end

                if SPLIT_IGNORE_BETWEEN[char] ~= nil then
                    icon_to_close_ignore = SPLIT_IGNORE_BETWEEN[char]
                    in_ignore = true
                    goto continue
                end
                -- string handling complete

                if SPLIT_BETWEEN[char] ~= nil then
                    table.insert(
                        closing_bracket_stack,
                        SPLIT_BETWEEN[char]
                    )
                end

                if char == closing_bracket_stack[#closing_bracket_stack] then
                    table.remove(closing_bracket_stack)
                end

                if #closing_bracket_stack == 1 and SPLIT_DELIMETERS[char] then
                    table.insert(split_indexes, i)
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
        if #split_indexes == 0 then
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
            line:sub(first_bracket_i+1, split_indexes[1])
        )
        for i = 1, #split_indexes-1 do
            table.insert(
                middle_lines,
                line:sub(split_indexes[i], split_indexes[i+1])
            )
        end
        table.insert(
            middle_lines,
            line:sub(split_indexes[#split_indexes], last_bracket_i-1)
        )

        local leading_pattern = "^[%s"
        for k, _ in pairs(SPLIT_DELIMETERS) do
            leading_pattern = leading_pattern .. k
        end
        leading_pattern = leading_pattern .. "]*"

        -- Cleanup step
        for i, middle_line in ipairs(middle_lines) do
            middle_line = middle_line:gsub(leading_pattern, leading_whitespace .. SPLIT_WHITESPACE, 1)
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
     "<leader>s",
    split_line,
    { silent = true }
)

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

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup(
    {
        { 'dcampos/nvim-snippy',
            config = function()
                require('snippy').setup({
                    enable_auto = true,
                    mappings = {
                        is = {
                            ['<Tab>'] = 'expand_or_advance',
                            ['<S-Tab>'] = 'previous',
                        },
                        nx = {
                            ['x'] = 'cut_text',
                        },
                    },
                })
            end
        },
        { "kylechui/nvim-surround",
            version = "*", -- Use for stability; omit to use `main` branch for the latest features
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
                })
            end
        },
    }
)
