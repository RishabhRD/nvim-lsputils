if vim.g.lsputils_codeAction_enabled == 1 then
	vim.lsp.callbacks['textDocument/codeAction'] =
	require'lsputil.codeAction'.code_action_handler
end

if vim.g.lsputils_reference_enabled == 1 then
	vim.lsp.callbacks['textDocument/references'] =
	require'lsputil.locations'.references_handler
end

if vim.g.lsputils_definition_enabled == 1 then
	vim.lsp.callbacks['textDocument/definition'] =
	require'lsputil.locations'.definition_handler
end

if vim.g.lsputils_declaration_enabled == 1 then
	vim.lsp.callbacks['textDocument/declaration'] =
	require'lsputil.locations'.declaration_handler
end

if vim.g.lsputils_typeDefinition_enabled == 1 then
	vim.lsp.callbacks['textDocument/typeDefinition'] =
	require'lsputil.locations'.typeDefinition_handler
end

if vim.g.lsputils_implementation_enabled == 1 then
	vim.lsp.callbacks['textDocument/implementation'] =
	require'lsputil.locations'.implementation_handler
end

if vim.g.lsputils_doc_symbol_enabled == 1 then
	vim.lsp.callbacks['textDocument/documentSymbol'] =
	require'lsputil.symbols'.document_handler
end

if vim.g.lsputils_workspace_symbol_enabled == 1 then
	vim.lsp.callbacks['workspace/symbol'] =
	require'lsputil.symbols'.workspace_handler
end
