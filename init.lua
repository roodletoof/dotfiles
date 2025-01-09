-- GENERAL SETTINGS

vim.opt.tabstop = 8
vim.opt.shiftwidth = 0
vim.opt.rnu = true
vim.opt.nu = true
vim.opt.wrap = false
vim.opt.shiftround = true
vim.opt.expandtab = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8

vim.o.exrc = true   -- Enable local project configuration files
vim.o.secure = true -- Disable potentially unsafe commands in .nvimrc

vim.cmd [[
	set clipboard=unnamedplus
	set cursorline

	nnoremap ,co :copen<CR>
	nnoremap ,cc :cclose<CR>
	nnoremap ,cq :call setqflist([])<CR>:cclose<CR>
	nnoremap ,ct :call setqflist([{'filename': expand('%'), 'lnum': line('.'), 'col': col('.'), 'text': 'TODO'}], 'a')<CR>
	nnoremap ,cf :cfirst<CR>
	nnoremap ,cl :clast<CR>
	nnoremap <c-n> :cnext<CR>
	nnoremap <c-p> :cprevious<CR>
	nnoremap ,cd :cd %:p:h<CR>
	nnoremap ,cu :colder<CR>
	nnoremap ,cr :cnewer<CR>

	tnoremap <esc> <c-\><c-n>
	autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif 
	nnoremap ,t <c-w>v<c-w>l:terminal<CR>a

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
]]

vim.g.c_syntax_for_h = 1
vim.g.python_indent = { -- Fixes retarded default python indentation.
	open_paren = 'shiftwidth()',
	nested_paren = 'shiftwidth()',
	continue = 'shiftwidth()',
	closed_paren_align_last_line = false,
	searchpair_timeout = 300,
}

local function file_exists(name)
	local f = io.open(name,"r")
	if f~=nil then
		f:close()
		return true
	else
		return false
	end
end


-- LAZY.NVIM BOOTSTRAP
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

require'lazy'.setup{
	{ 'justinmk/vim-sneak', },
	{ 'michaeljsmith/vim-indent-object', },
	{ 'Asheq/close-buffers.vim',
		config = function()
			vim.cmd [[
				nnoremap <c-w>o <c-w>o:Bdelete other<CR>
				nnoremap <c-w><c-o> <c-w><c-o>:Bdelete other<CR>
			]]
		end
	},
	{ 'kylechui/nvim-surround',
		version = '*', -- Use for stability; omit to use `main` branch for the latest features
		event = 'VeryLazy',
		config = function()
			require('nvim-surround').setup{}
		end
	},
	{ 'sainnhe/everforest',
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.termguicolors = true
			vim.g.everforest_enable_italic = true
			vim.cmd.colorscheme('everforest')
		end,
	},
	{ 'folke/zen-mode.nvim',
		config = function ()
			vim.keymap.set(
				'n',
				",z",
				vim.cmd.ZenMode,
				{ silent = true }
			)
		end
	},
	{ 'stevearc/oil.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', },
		config = function ()
			local oil = require('oil')
			oil.setup{
				default_file_explorer = true,
				columns = {'icon'},
				view_options = {
					show_hidden = true,
				},
			}
			vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "Open parent directory" })
		end,
	},
	{ 'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim', },
		config = function()
			local a = require'telescope.actions'
			require'telescope'.setup{
				defaults = {
					mappings = {
						i = { ["<C-Q>"] = a.smart_send_to_qflist + a.open_qflist, },
						n = { ["<C-Q>"] = a.smart_send_to_qflist + a.open_qflist, },
					}
				}
			}
			vim.cmd [[
				noremap ,ff :lua require'telescope.builtin'.find_files()<CR>
				noremap ,fo :lua require'telescope.builtin'.oldfiles()<CR>
				noremap ,fg :lua require'telescope.builtin'.live_grep()<CR>
				noremap ,fz :lua require'telescope.builtin'.current_buffer_fuzzy_find()<CR>
				noremap ,fh :lua require'telescope.builtin'.help_tags()<CR>
				noremap ,fm :lua require'telescope.builtin'.man_pages()<CR>
				noremap ,fe :lua require'telescope.builtin'.diagnostics()<CR>
				noremap ,fb :lua require'telescope.builtin'.buffers()<CR>
			]]
		end,
	},
	{ 'neovim/nvim-lspconfig',
		config = function()
			require'lspconfig'.gopls.setup{}
			require'lspconfig'.rust_analyzer.setup{}
			require'lspconfig'.gdscript.setup{}
			require'lspconfig'.clangd.setup{}
			require'lspconfig'.pyright.setup{}
			vim.cmd [[
				noremap ,rn :lua vim.lsp.buf.rename()<CR>
				noremap ,fd :lua vim.lsp.buf.definition()<CR>
				noremap ,ft :lua vim.lsp.buf.type_definition()<CR>
				noremap ,fr :lua vim.lsp.buf.references()<CR>
				noremap ,ca :lua vim.lsp.buf.code_action()<CR>
				noremap ,oe :lua vim.diagnostic.open_float()<CR>
			]]
		end
	},
	{ 'mfussenegger/nvim-dap',
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
			'theHamsta/nvim-dap-virtual-text',
			'leoluz/nvim-dap-go',
			'mfussenegger/nvim-dap-python',
		},

		config = function()
			require'nvim-dap-virtual-text'.setup{ commented = true, }
			require'dap-go'.setup()
			require'dap-python'.setup(vim.fn.stdpath('config') .. '/.venv/bin/python')

			local dap = require'dap'
			dap.adapters.godot = { type = 'server', host = '127.0.0.1', port = 6006, }
			dap.configurations.gdscript = { {type = 'godot', request = 'launch', name = 'Launch scene', project = "${workspaceFolder}",} }

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
	{ 'dcampos/nvim-snippy',
		config = function()
			require'snippy'.setup{ enable_auto = true, }
			vim.cmd [[
				imap <expr> <c-l> '<Plug>(snippy-next)'
				imap <expr> <c-k> '<Plug>(snippy-previous)'
				smap <expr> <c-l> '<Plug>(snippy-next)'
				smap <expr> <c-k> '<Plug>(snippy-previous)'
				xmap <Tab> <Plug>(snippy-cut-text)
			]]

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
		end
	},
	{ 'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'dcampos/nvim-snippy',
			'dcampos/cmp-snippy',
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
						{ name = 'snippy', priority = 100000000000000000000 },
						{ name = 'nvim_lsp', priority = 100},
						{ name = 'path', priority = 1},
					}
				),
				preselect = cmp.PreselectMode.None,
			}
		end,
	},
}

do -- split line
	local SPLIT_WHITESPACE = '	'
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

	local split_line = function()
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
