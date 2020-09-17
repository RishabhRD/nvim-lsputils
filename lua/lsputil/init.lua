if vim.g.lsputils_codeAction_enabled == 1 then
	vim.lsp.callbacks['textDocument/codeAction'] =
	require'lsputil.codeAction'.code_action_handler
end
