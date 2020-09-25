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

### Code Action:
![](https://user-images.githubusercontent.com/26287448/93617774-076ad600-f9f4-11ea-9c4e-d37019241320.gif)


### References:
![](https://user-images.githubusercontent.com/26287448/93930985-d3691b00-fd3b-11ea-9053-b699e4d36558.gif)

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

## Custom keymappings

Lua API can be used to provide custom keymappings.

	require'lsputil.locations'.key_maps
	require'lsputil.symbols'.key_maps

exposes keymaps for locations(i.e., references, definition, etc) and
symbols (i.e., document symbols and workspace symbols).

	local loc = require'lsputil.locations'
	loc.key_maps['n']['\<leader\>as'] = .....(function or string)
	loc.key_maps['i']['\<leader\>as> = .....(function or string)

Here first and second line provides normal and insert mode mappings(to leader as) for
lua function or other string for locations.

	local loc = require'lsputil.symbols'
	loc.key_maps['n']['\<leader\>as'] = .....(function or string)
	loc.key_maps['i']['\<leader\>as'] = .....(function or string)

Here first and second line provides normal and insert mode mappings(to leader as) for
lua function or other string for symbols.

See https://github.com/RishabhRD/popfix for more documentation of keymappings.
