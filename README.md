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

## Custom Options

nvim-lsputils provides 3 global variables:

- lsp_utils_location_opts
- lsp_utils_symbols_opts
- lsp_utils_codeaction_opts

These 3 variables are supposed to have vimscript dictionary values (Lua tables)

lsp_utils_location_opts defines options for:

- definition handler
- references handler
- declaration handler
- implementation handler
- type_definition hander

lsp_utils_symbols_opts defines options for:

- workspace symbol handler
- files symbols handler

lsp_utils_codeaction_opts defines options for:

- code_action handler

lsp_utils_location_opts and lsp_utils_symbols_opts takes following key-value pairs:

- height (integer) (Defines height of window)
	if value is 0 then a suitable default height is provided. (Specially for
		editor mode)
- width (integer) (Defines width of window)
- mode (string)
	- split (for split previews (default))
	- editor (for floating previews)
- list (vimscript dictionary / Lua tables) Accepts following key/value pairs:
	- border (boolean) (borders in floating mode)
	- numbering (boolean) (vim window numbering active or not)
	- title (boolean) (title for window)
- preview (vimscript dictionary / Lua tables) Accepts following key/value pairs:
	- border (boolean) (borders in floating mode)
	- numbering (boolean) (vim window numbering active or not)
	- title (boolean) (title for window)
- keymaps (vimscript dictionary / Lua tables) Additional keymaps.
	See https://github.com/RishabhRD/popfix to read about keymaps documentation.

lsp_utils_codeaction_opts takes following key-value pairs:

- height (integer) (Defines height of window)
	if value is 0 then a suitable default height is provided. (Specially for
		editor mode)
- width (integer) (Defines width of window)
- mode (string)
	- split (for split previews (default))
	- editor (for floating previews)
- list (vimscript dictionary / Lua tables) Accepts following key/value pairs:
	- border (boolean) (borders in floating mode)
	- numbering (boolean) (vim window numbering active or not)
	- title (boolean) (title for window)

See https://github.com/RishabhRD/popfix for more documentation of options.

These options helps to get better theme that suits your need.

### Sample themeing with lua

	vim.g.lsp_utils_location_opts = {
		height = 24,
		mode = 'editor',
		preview = {
			title = 'Location Preview'
		},
		keymaps = {
			n = {
				['<C-n>'] = 'j',
				['<C-p>'] = 'k',
			}
		}
	}
	vim.g.lsp_utils_symbols_opts = {
		height = 0,
		mode = 'editor',
		preview = {
			title = 'Symbol Preview'
		},
		keymaps = {
			n = {
				['<C-n>'] = 'j',
				['<C-p>'] = 'k',
			}
		}
	}
