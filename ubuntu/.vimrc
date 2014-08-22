"General
syntax on
set encoding=utf-8
let mapleader = "\<Space>"
let maplocalleader = "\\"
set t_Co=256
set mouse=a
set hlsearch
set incsearch ignorecase smartcase hlsearch
set number
set relativenumber 
set tags=~/devel/projects/portal/tags
set ts=4
set sw=4
set expandtab
set scrolloff=5
let &showbreak='↪ '
set cursorline          " Highlight the cursor screen line 
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set background=dark
autocmd BufReadPost * call SetCursorPosition()
set t_ut=
filetype off
set rtp+=~/.vim/bundle/vundle/
set laststatus=2
set autochdir
autocmd BufRead,BufNewFile *.html set syntax=mako

"custom functions
source ~/.vim/functions.vim

"Bundles
call vundle#begin()
Bundle 'gmarik/vundle'
Bundle 'kien/ctrlp.vim'           
Bundle 'scrooloose/nerdcommenter' 
Bundle 'sjl/gundo.vim'
Bundle 'scrooloose/syntastic'
Bundle 'flazz/vim-colorschemes'
Bundle 'gregsexton/MatchTag'
Bundle 'sophacles/vim-bundle-mako'
Bundle 'mhinz/vim-startify'
Bundle 'JulesWang/css.vim'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'mtth/scratch.vim'
Bundle 'tpope/vim-surround'
Bundle 'vim-scripts/snipMate'
"Bundle 'Valloric/YouCompleteMe'
"Bundle 'tpope/vim-speeddating'
"Bundle 'adinapoli/vim-markmultiple'
"Bundle 'ap/vim-css-color'
call vundle#end()
filetype plugin indent on 
colorscheme Tomorrow-Night
"Custom key shortcuts
map <silent> <C-n> :call ToggleVExplorer()<CR>
map <silent> <C-l> :noh <CR>
map <C-_> <leader>c<Space> 
set pastetoggle=<F2>
nnoremap <F4> :GundoToggle<CR>
nnoremap j gj
nnoremap k gk
nnoremap S i<cr><esc><right>
nnoremap ; :
nnoremap <C-w><C-o> :ptselect ^ /<c-r>=expand('<cword>')<cr>$<cr>
nnoremap <silent> <leader><tab> :Scratch<cr>
nmap <silent> <Leader>I <Plug>IndentGuidesToggle
nnoremap <silent><leader>c :call ColorPicker()<cr>
"calculator
inoremap <C-B> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
imap <C-x> <C-x><C-o>

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
map <tab> %
cmap w!! w !sudo tee > /dev/null %

"Plugin config
source ~/.vim/startify.vim
source ~/.vim/ctrlp.vim
source ~/.vim/syntastic.vim
source ~/.vim/netrw.vim
let g:indent_guides_guide_size = 1
let g:scratch_top = 0
"backup/persistance settings
set undodir=~/.vim/tmp/undo//
set backupdir=~/.vim/tmp/backup//
set directory=~/.vim/tmp/swap//
set backupskip=/tmp/*,/private/tmp/*"
set backup
set writebackup
set noswapfile

" persist (g)undo tree between sessions
set undofile
set history=100
set undolevels=100
"powerline config
set rtp+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/vim/
let g:Powerline_symbols = 'fancy'
