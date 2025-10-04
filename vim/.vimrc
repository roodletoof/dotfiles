set rtp+=/home/linuxbrew/.linuxbrew/opt/fzf,/usr/local/opt/fzf,/opt/homebrew/opt/fzf
nnoremap ,fa :call fzf#run({'sink': 'edit', 'options': '--preview="bat --color=always {}"'})<CR>
nnoremap ,ff :call fzf#run({'sink': 'edit', 'options': '--preview="bat --color=always {}"', 'source': 'git ls-files'})<CR>

set exrc
set secure
if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif
set tabstop=4
set shiftwidth=0
set expandtab
set rnu
set nu
set nowrap
set shiftround
set nohlsearch
set incsearch
set guicursor=n-v-c:block-Cursor
set cursorline
set autoindent
set ttimeoutlen=50
syntax on

nnoremap ,co :copen<CR>
nnoremap ,cc :cclose<CR>
nnoremap ,cq :call setqflist([])<CR>:cclose<CR>
nnoremap ,ct :call setqflist([{'filename': expand('%'), 'lnum': line('.'), 'col': col('.'), 'text': 'TODO'}], 'a')<CR>
nnoremap ,cf :cfirst<CR>
nnoremap ,cl :clast<CR>
nnoremap <c-n> :cnext<CR>zz
nnoremap <c-p> :cprevious<CR>zz
nnoremap ,cu :colder<CR>
nnoremap ,cr :cnewer<CR>
nnoremap ,h H
nnoremap ,l L
nnoremap H ^
nnoremap L $
xnoremap H ^
xnoremap L $

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

nnoremap <c-d> <c-d>zz
nnoremap <c-u> <c-u>zz

tnoremap <c-w>c <c-\><c-n><c-w>c

autocmd BufEnter *__virtual* setlocal buftype=nofile bufhidden=hide noswapfile

let g:rustfmt_autosave = 0

" remove annoying and bad indentation
autocmd FileType * setlocal indentexpr=

set wildignore=*.o,*.obj,.git/**,tags,*.pyc

" for c tests
set errorformat^=[----]\ %f:%l:\ %m
set path=**

" language specific makeprgs
autocmd BufNewFile,BufRead *.h set filetype=c
autocmd FileType c setlocal path+=/usr/local/include,/usr/include
autocmd FileType python setlocal makeprg=basedpyright
autocmd FileType go setlocal makeprg=go noexpandtab
autocmd FileType csharp setlocal makeprg=dotnet
autocmd FileType yaml setlocal tabstop=2
