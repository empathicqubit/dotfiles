call plug#begin('~/.vim/plugged')

Plug 'kien/ctrlp.vim'
Plug 'ternjs/tern_for_vim'

call plug#end()

let g:ctrlp_user_command = [
    \ '.git', 'cd %s && git ls-files . -co --exclude-standard',
    \ 'find %s -type f'
    \ ]

" Tabs
set shiftwidth=4 expandtab tabstop=8 softtabstop=4 smartindent

set showcmd hlsearch

set pastetoggle=<F2>

let mapleader=","

map <Leader>ev :e $HOME/.vimrc<CR>
map <Leader>rv :source $HOME/.vimrc<CR>
map <Leader>pi :PlugInstall<CR>
map <Leader>sp :set paste!<CR>

imap jj <ESC>
imap kk <ESC>
imap hh <ESC>
