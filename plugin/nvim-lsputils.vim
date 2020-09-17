if exists('g:loaded_lsputils') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lsputils = 1

if ! exists('lsputils_codeAction_enabled')
	let g:lsputils_codeAction_enabled = 1
endif

lua require'lsputil'
