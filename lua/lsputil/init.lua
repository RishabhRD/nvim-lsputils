if vim.g.lsputils_codeAction_enabled == 1 then
	vim.lsp.callbacks['textDocument/codeAction'] =
	require'lsputil.codeAction'.code_action_handler
end

if vim.g.lsputils_reference_enabled == 1 then
	vim.lsp.callbacks['textDocument/references'] =
	require'lsputil.references'.references_handler
end
