autocmd BufEnter *__virtual* setlocal buftype=nofile bufhidden=hide noswapfile
autocmd BufNewFile,BufRead *.h set filetype=c
autocmd BufWinEnter *.* silent! loadview 
autocmd BufWinLeave *.* silent! mkview 
autocmd FileType * setlocal indentexpr=
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
nnoremap ,h H
nnoremap ,l L
nnoremap ,t <c-w>v<c-w>l:terminal<CR>a
nnoremap <c-d> <c-d>zz
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-n> :cnext<CR>
nnoremap <c-p> :cprevious<CR>
nnoremap <c-u> <c-u>zz
nnoremap H ^
nnoremap L $

" i use ctrl-a for the tmux prefix key
nnoremap <C-a> <Nop>
nnoremap <C-x> <Nop>
nnoremap ,a <C-a>
nnoremap ,x <C-x>

set autoindent
set cursorline

set nobackup
set nowritebackup
set noswapfile
set autoread
set undofile
set undodir=~/.vim/undodir
if !isdirectory(expand('~/.vim/undodir'))
    call mkdir(expand('~/.vim/undodir'), 'p')
endif

set undodir=~/.vim/undodir
set undofile
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

nnoremap 'A 'A'"
nnoremap 'B 'B'"
nnoremap 'C 'C'"
nnoremap 'D 'D'"
nnoremap 'E 'E'"
nnoremap 'F 'F'"
nnoremap 'G 'G'"
nnoremap 'H 'H'"
nnoremap 'I 'I'"
nnoremap 'J 'J'"
nnoremap 'K 'K'"
nnoremap 'L 'L'"
nnoremap 'M 'M'"
nnoremap 'N 'N'"
nnoremap 'O 'O'"
nnoremap 'P 'P'"
nnoremap 'Q 'Q'"
nnoremap 'R 'R'"
nnoremap 'S 'S'"
nnoremap 'T 'T'"
nnoremap 'U 'U'"
nnoremap 'V 'V'"
nnoremap 'W 'W'"
nnoremap 'X 'X'"
nnoremap 'Y 'Y'"
nnoremap 'Z 'Z'"
