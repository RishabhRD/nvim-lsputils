if exists('g:loaded_lsputils') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_lsputils = 1

if ! exists('lsputils_codeAction_enabled')
	let g:lsputils_codeAction_enabled = 1
endif

if ! exists('lsputils_reference_enabled')
	let g:lsputils_reference_enabled = 1
endif

if ! exists('lsputils_definition_enabled')
	let g:lsputils_definition_enabled = 1
endif

if ! exists('lsputils_declaration_enabled')
	let g:lsputils_declaration_enabled = 1
endif

if ! exists('lsputils_typeDefinition_enabled')
	let g:lsputils_typeDefinition_enabled = 1
endif

if ! exists('lsputils_implementation_enabled')
	let g:lsputils_implementation_enabled = 1
endif

lua require'lsputil'
