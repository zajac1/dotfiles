"General
syntax on
set t_Co=256
set encoding=utf-8
set mouse=a
set backspace=indent,eol,start
set hlsearch
set incsearch ignorecase smartcase hlsearch
set number
set relativenumber
set ts=4
set sw=4
set expandtab
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set background=dark
colorscheme zenburn "Font: Droid Sans Mono

"custom functions
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
          exe "normal! g`\""
           normal! zz
         endif
         end
endfunction

"Cmds and autocmds
filetype off
autocmd BufReadPost * call SetCursorPosition()

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
filetype plugin indent on 
set laststatus=2

"Bundles
Bundle 'scrooloose/nerdtree'      
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdcommenter' 
Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Bundle 'sjl/gundo.vim'
Bundle 'scrooloose/syntastic.git'
Bundle 'flazz/vim-colorschemes'
Bundle 'Valloric/YouCompleteMe'
Bundle 'gregsexton/MatchTag'
Bundle 'vim-scripts/sql.vim--Stinson'
Bundle 'vim-scripts/dbext.vim'
Bundle 'krisajenkins/vim-pipe'
"Bundle 'kien/rainbow_parentheses.vim' 
Bundle 'tpope/vim-speeddating'
Bundle 'mhinz/vim-startify'

"Custom key shortcuts
map <C-n> :NERDTreeToggle<CR>
map <C-_> <leader>c<Space> 
map <C-l> :noh <CR>
nnoremap <F4> :GundoToggle<CR>
nnoremap <silent> <C-S> :<C-u>Update<CR>
nnoremap j gj
nnoremap k gk
cmap w!! w !sudo tee > /dev/null %
"Plugin config
source ~/.vim/startify.vim
source ~/.vim/ctrlp.vim
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
let g:Powerline_symbols = 'fancy'
