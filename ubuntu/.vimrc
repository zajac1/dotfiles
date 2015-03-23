"General
set nocompatible
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
set linebreak
let &showbreak='↪ '
set cursorline          " Highlight the cursor screen line 
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set background=dark
autocmd BufReadPost * call SetCursorPosition()
set t_ut=               "tmux & vim dont like each other (bckgr-color fix)
filetype off
set rtp+=~/.vim/bundle/vundle/
set laststatus=2
set autochdir   " change pwd to current edited file directory
set wildmenu    " fancy command autocompletion hints
set gdefault    " find and replace global option is implicit
set shiftround  " rounds up indendation, ie. if there is 11 spaces and you hit tab it makes 12, not, say, 15
autocmd BufRead,BufNewFile *.html set filetype=mako

"custom functions
source ~/.vim/functions.vim

"Bundles
call vundle#begin()
Plugin 'gmarik/vundle'
Plugin 'kien/ctrlp.vim'           
Plugin 'scrooloose/nerdcommenter' 
Plugin 'sjl/gundo.vim'
Plugin 'scrooloose/syntastic'
Plugin 'flazz/vim-colorschemes'
Plugin 'gregsexton/MatchTag'
Plugin 'sophacles/vim-bundle-mako'
Plugin 'mhinz/vim-startify'
Plugin 'JulesWang/css.vim'
Plugin 'nathanaelkane/vim-indent-guides'
"Plugin 'mtth/scratch.vim'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/snipMate'
"Plugin 'Raimondi/delimitMate'
Plugin 'vim-scripts/vim-pipe'
Plugin 'mattn/emmet-vim'
Plugin 'tmhedberg/matchit'
"Bundle 'dart-lang/dart-vim-plugin'
"Bundle 'vim-scripts/SQLComplete.vim'
"Bundle 'JessicaKMcIntosh/Vim/blob/master/syntax/sql.vim'
"Bundle 'vim-scripts/dbext.vim'
"Bundle 'Valloric/YouCompleteMe'
"Bundle 'tpope/vim-speeddating'
"Bundle 'adinapoli/vim-markmultiple'
"Bundle 'ap/vim-css-color'
call vundle#end()
filetype plugin indent on 
colorscheme Tomorrow-Night
"colorscheme seoul256
"Custom key shortcuts
map <silent> <C-p> :CtrlP /home/azajac/devel/projects/<CR>
map <silent> <C-n> :call ToggleVExplorer()<CR>
map <silent> <C-l> :noh <CR>
map <silent> <leader>se <localleader>r
map <C-_> <leader>c<Space> 
set pastetoggle=<F2>
nnoremap <F4> :GundoToggle<CR>
nnoremap <leader>ev :tabe $MYVIMRC<cr>
nnoremap j gj
nnoremap k gk
nnoremap Q <nop>
nnoremap S i<cr><esc><right>
nnoremap <tab> >>
nnoremap <s-tab> <<
nnoremap <C-w><C-o> :ptselect ^ /<c-r>=expand('<cword>')<cr>$<cr>
nnoremap <silent> <leader><tab> :Scratch<cr>
nmap <silent> <leader>I <Plug>IndentGuidesToggle
nnoremap <silent><leader>c :call ColorPicker()<cr>
"calculator
inoremap <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
"css hints
inoremap <C-x> <C-x><C-o>
nmap <leader><tab> <C-y>,

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
cmap w!! w !sudo tee > /dev/null %

"Plugin config
source ~/.vim/startify.vim
source ~/.vim/ctrlp.vim
source ~/.vim/syntastic.vim
source ~/.vim/netrw.vim
"source ~/.vim/dbext.vim
source ~/.vim/vimpipe.vim
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

"persist (g)undo tree between sessions
set undofile
set history=100
set undolevels=100
"powerline config
set rtp+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/vim/
let g:Powerline_symbols = 'fancy'
