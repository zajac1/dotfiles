    let g:startify_custom_header =
      \ map(split(system('fortune | figlet -w 145'), '\n'), '"   ". v:val') + ['','']
let g:startify_session_dir = '~/.vim/sessions'
let g:startify_list_order = ['sessions', 'files', 'dir', 'bookmarks']
let g:startify_session_detection = 0
let g:startify_session_persistence = 1
let g:startify_change_to_dir = 1
let g:startify_restore_position = 0
let g:startify_custom_footer = 
\'                                                      Vim is a charityware. See :help uganda'

hi StartifyBracket ctermfg=240
hi StartifyFooter ctermfg=240
hi StartifyHeader ctermfg=245
hi StartifyNumber ctermfg=215
hi StartifyPath ctermfg=245
hi StartifySlash ctermfg=240
