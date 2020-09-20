" built upon popfix api(https://github.com/RishabhRD/popfix)
" for parameter references see popfix readme.

if exists('g:loaded_lsputils') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lsputils = 1
