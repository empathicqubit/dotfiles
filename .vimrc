call plug#begin('~/.vim/plugged')

Plug 'arl/tmux-gitbar'

Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }

Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'empathicqubit/fzf.vim'

if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif

"Plug 'empathicqubit/vim-document-currentpath', { 'do': 'yarn install' }

Plug 'qpkorr/vim-renamer'
Plug 'chrisbra/Colorizer'
Plug 'maxbane/vim-asm_ca65'
Plug 'lambdalisue/suda.vim'
Plug 'leafgarland/typescript-vim'
Plug 'tikhomirov/vim-glsl'
"Plug 'mhartington/nvim-typescript', {'do': 'npm install -g neovim && ./install.sh'}
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern tern-chrome-extension' }
Plug 'editorconfig/editorconfig-vim'
Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'isRuslan/vim-es6'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'mzlogin/vim-smali'
"Plug 'derekwyatt/vim-scala'
Plug 'pearofducks/ansible-vim'

" NOT ACTUALLY VIM PLUGINS
" ========================
Plug 'ofavre/vimcat', { 'do': 'make -j$(nproc)' }
Plug 'empathicqubit/i3-layout-manager'
Plug 'rjekker/i3-battery-popup'
" ========================
" END OF NON-VIM PLUGINS

call plug#end()

let g:javascript_plugin_jsdoc = 1

let g:document_currentpath_path = ''

let g:airline_section_b = '%{g:document_currentpath_path}'

let g:syntastic_terraform_tffilter_plan = 1

let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["scala"] }

let g:rainbow#pairs = [['(', ')'], ['<', '>'], ['{', '}'], ['[', ']']]

let g:LanguageClient_serverCommands = { 'haskell': ['hie-wrapper'] }

let g:LanguageClient_rootMarkers = ['*.cabal', 'stack.yaml']

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

let g:deoplete#omni#input_patterns.scala='[^. *\t]\.\w*'


let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='simple'

let g:tern#is_show_argument_hints_enabled = 1

" Tabs
set shiftwidth=4 expandtab tabstop=8 softtabstop=4 smartindent

if has('win32')
    set bs=2
else
    set backspace=indent,eol,start
endif

set showcmd hlsearch

command W :w suda://%

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

map <Leader>cz :ColorHighlight<CR>
map <Leader>ev :e $HOME/.vimrc<CR>
map <Leader>rv :source $HOME/.vimrc<CR>
map <Leader>pi :PlugInstall<CR>
map <Leader>pt :set paste!<CR>
map <Leader>ag :Ag<CR>
map <Leader>_ f_x~<CR>

noremap <C-p> :GFiles<CR>

imap jj <ESC>
imap hh <ESC>

inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><s-tab> pumvisible() ? "\<C-p>" : "\<TAB>"

autocmd BufRead * RainbowParentheses

autocmd BufWritePost *.scala silent :EnTypeCheck
nnoremap <Leader>t :EnType<CR>

" https://vim.fandom.com/wiki/Different_syntax_highlighting_within_regions_of_a_file

function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ keepend
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction

call TextEnableCodeSnip(  'javascript',   '# BEGIN JS',   '# END JS', 'SpecialComment')
