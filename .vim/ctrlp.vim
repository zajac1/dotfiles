let g:ctrlp_by_filename = 1
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|pyc)$'
let g:ctrlp_working_path_mode = 'ra' 
let g:ctrlp_root_markers = 'devel'
let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_open_new_file = 't'
let g:ctrlp_prompt_mappings = { 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ }

hi CtrlPMatch ctermfg =Green 
