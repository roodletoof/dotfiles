autocmd BufEnter *__virtual* setlocal buftype=nofile bufhidden=hide noswapfile
autocmd BufNewFile,BufRead *.h set filetype=c
autocmd BufWinEnter *.* silent! loadview 
autocmd BufWinLeave *.* silent! mkview 
autocmd FileType * setlocal indentexpr=
autocmd FileType c setlocal path+=/usr/local/include,/usr/include
autocmd FileType csharp setlocal makeprg=dotnet
autocmd FileType go setlocal makeprg=go noexpandtab
autocmd FileType make setlocal noexpandtab
autocmd FileType python setlocal makeprg=basedpyright
autocmd FileType yaml setlocal tabstop=2
let g:rustfmt_autosave = 0
nnoremap ,cD :call setqflist(filter(getqflist(), 'v:val != getqflist()[getqflist({"idx": 0}).idx - 1]'))<CR>
nnoremap ,cc :cclose<CR>
nnoremap ,cf :cfirst<CR>
nnoremap ,cl :clast<CR>
nnoremap ,co :copen<CR>
nnoremap ,cq :call setqflist([])<CR>:cclose<CR>
nnoremap ,cr :cnewer<CR>
nnoremap ,ct :call setqflist([{'filename': expand('%'), 'lnum': line('.'), 'col': col('.'), 'text': 'TODO'}], 'a')<CR>
nnoremap ,cu :colder<CR>
nnoremap ,fa :call fzf#run({'sink': 'edit', 'options': '--preview="bat --color=always {}"'})<CR>
nnoremap ,ff :call fzf#run({'sink': 'edit', 'options': '--preview="bat --color=always {}"', 'source': 'git ls-files'})<CR>
nnoremap ,h H
nnoremap ,l L
nnoremap ,t <c-w>v<c-w>l:terminal<CR>a
nnoremap <c-d> <c-d>zz
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-n> :cnext<CR>zz
nnoremap <c-p> :cprevious<CR>zz
nnoremap <c-u> <c-u>zz
nnoremap H ^
nnoremap L $
set autoindent
set cursorline
set errorformat^=[----]\ %f:%l:\ %m
set expandtab
set exrc
set guicursor=n-v-c:block-Cursor
set incsearch
set nohlsearch
set nowrap
set nu
set path=**
set rnu
set rtp+=/home/linuxbrew/.linuxbrew/opt/fzf,/usr/local/opt/fzf,/opt/homebrew/opt/fzf
set secure
set shiftround
set shiftwidth=0
set tabstop=4
set ttimeoutlen=50
set viewoptions=folds,cursor
set wildignore=*.o,*.obj,.git/**,tags,*.pyc
syntax on
tnoremap <c-w>c <c-\><c-n><c-w>c
xnoremap H ^
xnoremap L $

if has('clipboard')
  set clipboard^=unnamed,unnamedplus
endif
