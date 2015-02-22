" GUARD:
if expand("%:p") ==# expand("<sfile>:p")
  unlet! g:loaded_transform
endif
if exists('g:loaded_transform')
  finish
endif
let g:loaded_transform = 1
let s:old_cpo = &cpo
set cpo&vim

" Main:

" AutoCmd:

" Command:
command! -range -bar -nargs=* Transform call transform#start(<line1>, <line2>, <f-args>)

" KeyMap:
nnoremap <silent> <Plug>(transform) :Transform<CR>
xnoremap <silent> <Plug>(transform) :Transform<CR>
inoremap <silent> <Plug>(transform) <C-o>:Transform<CR>

" Finish:
let &cpo = s:old_cpo
" vim: foldmethod=marker
