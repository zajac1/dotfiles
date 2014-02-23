"General
syntax on
set t_Co=256
set encoding=utf-8
set mouse=a
set backspace=indent,eol,start
set hlsearch
set incsearch ignorecase smartcase hlsearch
set number
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

fun! SaveSession()
    exe 'mksession! ~/.vim/sessions/session.vim'
endfun

fun! LoadSession()
    if argc() == 0
        exe 'source ~/.vim/sessions/session.vim'
    endif
endfunction

fun! Mks(name)
        exe "mksession! ~/.vim/sessions/".a:name.".vim"
endfun

fun! Los(name)
    exe "source ~/.vim/sessions/".a:name.".vim"
endfun

"Cmds and autocmds
command! -nargs=1 Mks call Mks(<f-args>)
command! -nargs=1 Los call Los(<f-args>)
autocmd VimEnter * call LoadSession()
autocmd VimLeave * call SaveSession()
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
let g:ctrlp_by_filename = 1
let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_open_new_file = 't'
let g:ctrlp_prompt_mappings = { 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ }
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
