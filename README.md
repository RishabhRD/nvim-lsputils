# nvim-lsputils

Neovim built-in LSP client implementation is so lightweight and awesome.
However, default settings for actions like go-to-definition, code-quickfix, etc
may not seem user friendly for many users. But neovim LSP client is highly
extensible with lua. This plugin focuses on making such LSP actions highly user
friendly.

## Features

- Floating popup for code actions
- Preview window for references
- Preview window for definition, declaration, type-definition, implementation
- Preview window for document symbol and workspace symbol

## Demo

### After applying plugin:
![](https://user-images.githubusercontent.com/26287448/93617774-076ad600-f9f4-11ea-9c4e-d37019241320.gif)


### After applying plugin:
![](https://user-images.githubusercontent.com/26287448/93617977-4e58cb80-f9f4-11ea-9406-6e0ff0f2ec93.gif)

## Future goals

- LspSearch command to search symbol over workspace and list it in a window.
- Fuzzy finding of symbols

## Prerequisite

- Neovim nightly

## Installation

This plugin utilizes RishabhRD/popfix plugin for managing underlying popups
and previews.
It can be installed with any plugin manager. For example with vim-plug:

	Plug 'RishabhRD/popfix'
	Plug 'RishabhRD/nvim-lsputils'

## Setup

Add following to init.vim lua chunk as:

	lua <<EOF
	vim.lsp.callbacks['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
	vim.lsp.callbacks['textDocument/references'] = require'lsputil.locations'.references_handler
	vim.lsp.callbacks['textDocument/definition'] = require'lsputil.locations'.definition_handler
	vim.lsp.callbacks['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
	vim.lsp.callbacks['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
	vim.lsp.callbacks['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
	vim.lsp.callbacks['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
	vim.lsp.callbacks['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
	EOF
