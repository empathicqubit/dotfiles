call plug#begin('~/.vim/plugged')

Plug 'kien/ctrlp.vim'
Plug 'junegunn/fzf'

if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'editorconfig/editorconfig-vim'

call plug#end()

let g:deoplete#enable_at_startup = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='simple'

let g:tern#is_show_argument_hints_enabled = 1

let g:ctrlp_user_command = [
    \ '.git', 'cd %s && git ls-files . -co --exclude-standard',
    \ 'find %s -type f'
    \ ]

" Tabs
set shiftwidth=4 expandtab tabstop=8 softtabstop=4 smartindent

set showcmd hlsearch

command W :%!sudo tee %

set pastetoggle=<F2>

set hidden

set modeline
set secure

set laststatus=2

let mapleader=","

map <Leader>ev :e $HOME/.vimrc<CR>
map <Leader>rv :source $HOME/.vimrc<CR>
map <Leader>pi :PlugInstall<CR>
map <Leader>sp :set paste!<CR>

imap jj <ESC>
imap kk <ESC>
imap hh <ESC>

inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><s-tab> pumvisible() ? "\<C-p>" : "\<TAB>"
