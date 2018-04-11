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
Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'isRuslan/vim-es6'
Plug 'junegunn/rainbow_parentheses.vim'

" NOT ACTUALLY VIM PLUGINS
" ========================
Plug 'ofavre/vimcat', { 'do': 'make -j$(nproc)' }
" ========================
" END OF NON-VIM PLUGINS

call plug#end()

let g:javascript_plugin_jsdoc = 1

let g:syntastic_terraform_tffilter_plan = 1

let g:rainbow#pairs = [['(', ')'], ['<', '>'], ['{', '}'], ['[', ']']]

function! _GitDiffWindowSetup() abort
    setlocal buftype=nofile 
    setlocal bufhidden=hide 
    setlocal noswapfile
    .!git diff && git diff --staged
    setlocal filetype=diff
endfunction

function! GitDiffWindow() abort
    vert new +call\ _GitDiffWindowSetup()
    wincmd J
    wincmd p
    resize 10
endfunction

autocmd BufRead */.git/COMMIT_EDITMSG call GitDiffWindow()

if has('win32')
    let g:python3_host_prog = 'C:/Python36/python.exe'
    set guifont=Liberation_Mono:h10:cANSI:qDRAFT
endif

let g:deoplete#enable_at_startup = 1

let g:deoplete#omni_patterns = {}
let g:deoplete#omni_patterns.terraform = '[^ *\t"{=$]\w*'

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='simple'

let g:tern#is_show_argument_hints_enabled = 1

let g:ctrlp_user_command = [
    \ '.git', 'cd %s && git ls-files . -co --exclude-standard',
    \ 'find %s -type f'
    \ ]

" Tabs
set shiftwidth=4 expandtab tabstop=8 softtabstop=4 smartindent

if has('win32')
    set bs=2
endif

set showcmd hlsearch

command W :%!sudo tee %

set pastetoggle=<F2>

set hidden

if has('win32')
    silent exec "!mkdir $HOME/.vimswap"
else
    silent exec "!mkdir $HOME/.vimswap 2>/dev/null"
endif

set directory=$HOME/.vimswap//

set modeline
set secure
set autoread

set laststatus=2

set encoding=utf8

if(!has('win32') || ( has('win32') && has('gui_running') ))
    set background=dark
    colorscheme palenight

    let g:palenight_terminal_italics=1
endif

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

autocmd BufRead * RainbowParentheses

