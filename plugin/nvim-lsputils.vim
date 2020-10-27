" built upon popfix api(https://github.com/RishabhRD/popfix)
" for parameter references see popfix readme.

if exists('g:loaded_lsputils') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

if ! exists('g:lsp_utils_location_opts')
	let g:lsp_utils_location_opts = v:null
endif

if ! exists('g:lsp_utils_symbols_opts')
	let g:lsp_utils_symbols_opts = v:null
endif

if ! exists('g:lsp_utils_codeaction_opts')
	let g:lsp_utils_codeaction_opts = v:null
endif

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lsputils = 1
