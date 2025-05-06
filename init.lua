---@diagnostic disable: missing-fields
-- vim:foldmethod=marker

local function get_python_venv_path() --{{{1
    return vim.fn.stdpath('config') .. '/.venv/bin/python'
end

do
    vim.g.python3_host_prog = get_python_venv_path()
end

-- GENERAL SETTINGS {{{1

vim.cmd [[
    set nofixeol
    set exrc
    set secure
    set clipboard=unnamedplus
    set cursorline
    set tabstop=4
    set shiftwidth=0
    set rnu
    set nu
    set nowrap
    set shiftround
    set expandtab
    set nohlsearch
    set incsearch
    "set scrolloff=8
    set guicursor=n-v-c:block-Cursor

    nnoremap <c-d> <c-d>zz
    nnoremap <c-u> <c-u>zz
    nnoremap } }zz
    nnoremap { {zz

    nnoremap ,co :copen<CR>
    nnoremap ,cc :cclose<CR>
    nnoremap ,cq :call setqflist([])<CR>:cclose<CR>
    nnoremap ,ct :call setqflist([{'filename': expand('%'), 'lnum': line('.'), 'col': col('.'), 'text': 'TODO'}], 'a')<CR>
    nnoremap ,cf :cfirst<CR>
    nnoremap ,cl :clast<CR>
    nnoremap <c-n> :cnext<CR>zz
    nnoremap <c-p> :cprevious<CR>zz
    nnoremap ,cd :cd %:p:h<CR>
    nnoremap ,cu :colder<CR>
    nnoremap ,cr :cnewer<CR>

    nnoremap ,cD :call setqflist(filter(getqflist(), 'v:val != getqflist()[getqflist({"idx": 0}).idx - 1]'))<CR>

    nnoremap ,t <c-w>v<c-w>l:terminal<CR>a

    " Don't include curdir, it just causes pain.
    set viewoptions=folds,cursor
    autocmd BufWinLeave *.* silent! mkview 
    autocmd BufWinEnter *.* silent! loadview 

    nnoremap <c-h> <c-w>h
    nnoremap <c-j> <c-w>j
    nnoremap <c-k> <c-w>k
    nnoremap <c-l> <c-w>l
    nnoremap ,v <c-w>v
    tnoremap <c-h> <c-\><c-n><c-w>h
    tnoremap <c-j> <c-\><c-n><c-w>j
    tnoremap <c-k> <c-\><c-n><c-w>k
    tnoremap <c-l> <c-\><c-n><c-w>l

    tnoremap <c-w>c <c-\><c-n><c-w>c

    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup='Visual', timeout=100}
    autocmd BufEnter *__virtual* setlocal buftype=nofile bufhidden=hide noswapfile

    let g:rustfmt_autosave = 1

    " remove annoying and bad indentation
    autocmd FileType * setlocal indentexpr=
]]

vim.api.nvim_create_autocmd({
    'BufRead',
    'BufNewFile'
}, {
    pattern = {'*.h'},
    callback = function()
        vim.bo.filetype = 'c'
    end
})

local function file_exists(name) --{{{1
    local f = io.open(name,"r")
    if f~=nil then
        f:close()
        return true
    else
        return false
    end
end

-- LAZY.NVIM BOOTSTRAP {{{1
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

require'lazy'.setup{ --{{{1
    { 'stevearc/oil.nvim', --{{{2
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        lazy = false,
        config = function ()
            require("oil").setup({
                default_file_explorer = true,
                columns = {
                    "icon",
                    "permissions",
                    "size",
                    "mtime",
                },
                buf_options = {
                    buflisted = false,
                    bufhidden = "hide",
                },
                win_options = {
                    wrap = false,
                    signcolumn = "no",
                    cursorcolumn = false,
                    foldcolumn = "0",
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = "nvic",
                },
                delete_to_trash = false,
                skip_confirm_for_simple_edits = false,
                prompt_save_on_select_new_entry = true,
                cleanup_delay_ms = 2000,
                lsp_file_methods = {
                    enabled = true,
                    timeout_ms = 1000,
                    autosave_changes = false,
                },
                constrain_cursor = "editable",
                watch_for_changes = false,
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" },
                },
                use_default_keymaps = true,
                view_options = {
                    show_hidden = true,
                    is_hidden_file = function(name, bufnr)
                        local m = name:match("^%.")
                        return m ~= nil
                    end,
                    is_always_hidden = function(name, bufnr)
                        return false
                    end,
                    natural_order = "fast",
                    case_insensitive = false,
                    sort = {
                        { "type", "asc" },
                        { "name", "asc" },
                    },
                    highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
                        return nil
                    end,
                },
                extra_scp_args = {},
                float = {
                    padding = 2,
                    max_width = 0,
                    max_height = 0,
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                    get_win_title = nil,
                    preview_split = "auto",
                    override = function(conf)
                        return conf
                    end,
                },
                preview_win = {
                    update_on_cursor_moved = true,
                    preview_method = "fast_scratch",
                    disable_preview = function(filename)
                        return false
                    end,
                    win_options = {},
                },
                confirmation = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = 0.9,
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                },
                progress = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = { 10, 0.9 },
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = "rounded",
                    minimized_border = "none",
                    win_options = {
                        winblend = 0,
                    },
                },
                ssh = {
                    border = "rounded",
                },
                keymaps_help = {
                    border = "rounded",
                },
            })
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        end
    },
    { 'github/copilot.vim', --{{{2
        config = function()
            -- q for qomplete ;)
            vim.keymap.set('i', '<c-q>', 'copilot#Accept("\\<CR>")', {
                expr = true,
                replace_keycodes = false,
            })
            vim.g.copilot_no_tab_map = true
            vim.keymap.set('n', '<c-q>', ':Copilot panel<CR>', { noremap = true, silent = true })
        end,
    },
    { 'rafaelsq/nvim-goc.lua', --{{{2
        config = function ()
            local goc = require'nvim-goc'
            goc.setup{}
            ---@param name string
            local cmd = function(name)
                vim.api.nvim_create_user_command(
                    'Go'..name,
                    'lua require"nvim-goc".'..name..'()',
                    { nargs = 0 }
                )
            end
            cmd('Coverage')
            cmd('CoverageFunc')
            cmd('ClearCoverage')
        end,
    },
    { 'f-person/git-blame.nvim', --{{{2
        keys = {',a'},
        config = function ()
            require'gitblame'.setup{
                enabled = false,
            }
            vim.cmd[[
                nnoremap ,a :GitBlameToggle<CR>
            ]]
        end
    },
    { 'unblevable/quick-scope', --{{{2
        init = function()
            vim.cmd [[
                let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
            ]]
        end,
    },
    { 'michaeljsmith/vim-indent-object', --{{{2
    },
    { 'kylechui/nvim-surround', --{{{2
        version = '*', -- Use for stability; omit to use `main` branch for the latest features
        event = 'VeryLazy',
        config = function()
            require('nvim-surround').setup{}
        end
    },
    { 'echasnovski/mini.align', --{{{2
        version = false,
        config = function()
            require'mini.align'.setup()
        end,
    },
    { 'sainnhe/everforest', --{{{2
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.termguicolors = true
            vim.g.everforest_enable_italic = true
            vim.cmd.colorscheme('everforest')
        end,
    },
    { 'folke/zen-mode.nvim', --{{{2
        keys = {",z"},
        config = function ()
            vim.keymap.set(
                'n',
                ",z",
                vim.cmd.ZenMode,
                { silent = true }
            )
        end
    },
    { 'seblyng/roslyn.nvim', --{{{2
        --WARN: requires html-lsp, roslyn and rzls installed via Mason
        dependencies = { 'tris203/rzls.nvim', },
        ft = {'cs', 'razor'},
        config = function()
            require'rzls'.setup{}
            require'roslyn'.setup{
                args = {
                    '--stdio',
                    '--logLevel=Information',
                    '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
                    '--razorSourceGenerator=' .. vim.fs.joinpath(
                        vim.fn.stdpath'data' --[[@as string]],
                        'mason',
                        'packages',
                        'roslyn',
                        'libexec',
                        'Microsoft.CodeAnalysis.Razor.Compiler.dll'
                    ),
                    '--razorDesignTimePath=' .. vim.fs.joinpath(
                        vim.fn.stdpath'data' --[[@as string]],
                        'mason',
                        'packages',
                        'rzls',
                        'libexec',
                        'Targets',
                        'Microsoft.NET.Sdk.Razor.DesignTime.targets'
                    ),
                },
                config = {
                    handlers = require 'rzls.roslyn_handlers',
                    ['csharp|code_lens'] = {
                        dotnet_enable_references_code_lens = true,
                    }
                },
            }
        end,
        init = function()
            vim.filetype.add{
                extension = {
                    razor = 'razor',
                    cshtml = 'razor'
                }
            }
        end,
        opts = {
            exe = {
                'dotnet',
                vim.fs.joinpath(
                    vim.fn.stdpath'data' --[[@as string]],
                    'mason',
                    'packages',
                    'roslyn',
                    'libexec',
                    'Microsoft.CodeAnalysis.LanguageServer.dll'
                )
            },
        },
    },
    { "folke/lazydev.nvim", --{{{2
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "${3rd}/love2d/library", words = { "love" } },
            },
        },
    },
    { 'neovim/nvim-lspconfig', --{{{2
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
        config = function()
            require'mason'.setup{
                registries = {
                    'github:mason-org/mason-registry',
                    'github:crashdummyy/mason-registry',
                },
            }

            do --it seems like mason-lspconfig's ensure_installed field does not work for lsps in 3rd-party registries
                local is_installed = require'mason-registry'.is_installed
                local c_sharp_requirements = { 'html-lsp', 'roslyn', 'rzls', }
                for _, requirement in ipairs(c_sharp_requirements) do
                    if not is_installed(requirement) then
                        vim.cmd('MasonInstall '..requirement)
                    end
                end
            end

            require'mason-lspconfig'.setup()
            require'mason-lspconfig'.setup_handlers{
                function (server_name)
                    require'lspconfig'[server_name].setup{}
                end,
                zls = function()
                    require'lspconfig'.zls.setup{ enable_autofix = false }
                    vim.g.zig_fmt_autosave = false
                end,
                lua_ls = function()
                    require'lspconfig'.lua_ls.setup{
                        Lua = { runtime = { version = "LuaJIT" } }
                    }
                end,
                gopls = function()
                    require'lspconfig'.gopls.setup{
                        settings = {
                            gopls = {
                                templateExtensions = {'html', 'gotmpl'}
                            },
                        },
                        filetypes = {
                            'go',
                            'gomod',
                            'gowork',
                            'gotmpl',
                            'html'
                        }
                    }
                end,
            }

            require'lspconfig'.gdscript.setup{}

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    vim.bo[args.buf].tagfunc = nil
                end,
            })

            local function jump_to_definition()
                local word = vim.fn.expand("<cword>")
                vim.cmd("tag " .. word)
            end

            vim.keymap.set( 'n', ',fc', jump_to_definition, { noremap = true, silent = true})
            vim.keymap.set( 'n', ',fd', vim.lsp.buf.definition, { noremap = true, silent = true})

            vim.cmd [[
                noremap ,rn :lua vim.lsp.buf.rename()<CR>
                noremap ,ft :lua vim.lsp.buf.type_definition()<CR>
                noremap ,fr :lua vim.lsp.buf.references()<CR>
                noremap ,ca :lua vim.lsp.buf.code_action()<CR>
                noremap ,oe :lua vim.diagnostic.open_float()<CR>
                noremap ,ea :lua vim.diagnostic.setqflist()<CR>
                noremap ,ee :lua vim.diagnostic.setqflist{severity="ERROR"}<CR>
                noremap ,ew :lua vim.diagnostic.setqflist{severity="WARN"}<CR>
                noremap ,ei :lua vim.diagnostic.setqflist{severity="INFO"}<CR>
                noremap ,eh :lua vim.diagnostic.setqflist{severity="HINT"}<CR>
            ]]
        end
    },
    { 'nvim-treesitter/nvim-treesitter', --{{{2
        config = function()
            require'nvim-treesitter.configs'.setup{
                sync_install = false,
                auto_install = true,
                indent = {
                    enable = true,
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            }
        end,
    },
    { "kdheepak/lazygit.nvim", --{{{2
        lazy = true,
        cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile", },
        dependencies = { "nvim-lua/plenary.nvim", },
        keys = { { ",g", "<cmd>LazyGit<cr>", desc = "LazyGit" }, },
    },
    { 'mfussenegger/nvim-dap', --{{{2
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'theHamsta/nvim-dap-virtual-text',
            'leoluz/nvim-dap-go',
            'mfussenegger/nvim-dap-python',
        },
        keys = {',b', ',db', ',B', '<B'},
        config = function()
            require'nvim-dap-virtual-text'.setup{ commented = true, }
            require'dap-go'.setup()
            require'dap-python'.setup(get_python_venv_path())

            local dap = require'dap'
            dap.adapters.godot = { type = 'server', host = '127.0.0.1', port = 6006, }
            dap.configurations.gdscript = { {type = 'godot', request = 'launch', name = 'Launch scene', project = "${workspaceFolder}",} }

            dap.adapters.lldb = {
                type = 'executable',
                command = vim.fn.exepath('lldb-dap'),
                name = 'lldb'
            }

            dap.configurations.c = {
                {
                    name = 'Launch',
                    type = 'lldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = function()
                        local i = vim.fn.input('input args: ')
                        return vim.fn.split(i)
                    end,
                    runInTerminal = true,
                },
            }
            dap.configurations.cpp = dap.configurations.c
            dap.configurations.rust = dap.configurations.c

            vim.cmd [[
                nnoremap ,b :DapToggleBreakpoint<CR>
                nnoremap ,B :DapClearBreakpoints<CR>
                nnoremap <B :DapClearBreakpoints<CR>
                nnoremap ,db :DapContinue<CR>
                nnoremap <Down> :DapStepInto<CR>
                nnoremap <UP> :DapStepOut<CR>
                nnoremap <Right> :DapStepOver<CR>
            ]]
        end
    },
    { 'dcampos/nvim-snippy', --{{{2
        config = function()
            require'snippy'.setup{ enable_auto = true, }
            vim.cmd [[
                imap <expr> <c-l> '<Plug>(snippy-next)'
                imap <expr> <c-k> '<Plug>(snippy-previous)'
                smap <expr> <c-l> '<Plug>(snippy-next)'
                smap <expr> <c-k> '<Plug>(snippy-previous)'
                nmap g; <Plug>(snippy-cut-text)
                xmap g; <Plug>(snippy-cut-text)
            ]]

            vim.api.nvim_create_user_command(
                'S',
                function ()
                    ---@type string
                    local snippets_path = vim.fn.stdpath('config') .. '/snippets/' .. vim.bo.filetype .. '.snippets'

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
    },
    { 'hrsh7th/nvim-cmp', --{{{2
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'dcampos/nvim-snippy',
            'dcampos/cmp-snippy',
            'quangnguyen30192/cmp-nvim-tags',
        },
        config = function()
            local cmp = require'cmp'
            cmp.setup{
                snippet = {
                    expand = function(args)
                        require'snippy'.expand_snippet(args.body)
                    end,
                },
                mapping = {
                    ['<C-y>'] = cmp.mapping.confirm{ select = true },
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                },
                sources = cmp.config.sources(
                    {
                        { name = 'snippy',   priority = 100000000000000000000 },
                        { name = 'nvim_lsp', priority = 1000000000},
                        { name = 'tags',     priority = 100 },
                        { name = 'path',     priority = 1},
                    }
                ),
                preselect = cmp.PreselectMode.None,
            }
        end,
    },
    { 'nvim-telescope/telescope.nvim', --{{{2
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim',
        },
        config = function()
            local a = require'telescope.actions'
            require'telescope'.setup{
                defaults = {
                    file_ignore_patterns = {'%__virtual.cs$'},
                    mappings = {
                        i = { ["<C-Q>"] = a.smart_send_to_qflist + a.open_qflist, ["<C-j>"] = a.select_default, },
                        n = { ["<C-Q>"] = a.smart_send_to_qflist + a.open_qflist, ["<C-j>"] = a.select_default, },
                    }
                },
                extensions = { ['ui-select'] = { require'telescope.themes'.get_dropdown{}, }, },
            }
            vim.cmd [[
                noremap ,ff :lua require'telescope.builtin'.find_files({hidden=true, no_ignore=true, no_ignore_parent=true})<CR>
                noremap ,fo :lua require'telescope.builtin'.oldfiles()<CR>
                noremap ,fg :lua require'telescope.builtin'.live_grep()<CR>
                noremap ,fz :lua require'telescope.builtin'.current_buffer_fuzzy_find()<CR>
                noremap ,fh :lua require'telescope.builtin'.help_tags()<CR>
                noremap ,fm :lua require'telescope.builtin'.marks()<CR>
                noremap ,fb :lua require'telescope.builtin'.buffers()<CR>

                noremap ,fea :lua require'telescope.builtin'.diagnostics()<CR>
                noremap ,fee :lua require'telescope.builtin'.diagnostics{severity="ERROR"}<CR>
                noremap ,few :lua require'telescope.builtin'.diagnostics{severity="WARN"}<CR>
                noremap ,fei :lua require'telescope.builtin'.diagnostics{severity="INFO"}<CR>
                noremap ,feh :lua require'telescope.builtin'.diagnostics{severity="HINT"}<CR>
            ]]

            require'telescope'.load_extension'ui-select'
        end,
    },
}

do -- split line {{{1

    local SPLIT_DELIMETERS = { -- single characters only
        [','] = true,
        [';'] = true,
    }
    local SPLIT_BETWEEN = { -- single characters only
        ['('] = ')',
        ['['] = ']',
        ['{'] = '}',
        ['<'] = '>',
    }
    local SPLIT_IGNORE_BETWEEN = { --single characters only
        ['"'] = '"',
        ["'"] = "'",
    }

    local split_line = function()
        local SPLIT_WHITESPACE = '	'
        if vim.o.expandtab then
            SPLIT_WHITESPACE = ''
            for _ = 1, vim.o.tabstop do
                SPLIT_WHITESPACE = SPLIT_WHITESPACE .. ' '
            end
        end

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

        if middle_lines[#middle_lines]:match("^%s*$") ~= nil then
            table.remove(middle_lines)
        end

        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_lines(0, row-1, row, false, {first_line})
        vim.api.nvim_buf_set_lines(0, row, row, false, {last_line})
        vim.api.nvim_buf_set_lines(0, row, row, false, middle_lines)
    end

    vim.keymap.set(
        'n',
        ",s",
        split_line,
        { silent = true }
    )
end
