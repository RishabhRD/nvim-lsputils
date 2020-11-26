# nvim-lsputils

Neovim built-in LSP client implementation is so lightweight and awesome.
However, default settings for actions like go-to-definition, code-quickfix, etc
may not seem user friendly for many users. But neovim LSP client is highly
extensible with lua. This plugin focuses on making such LSP actions highly user
friendly.

## WARNING:
Due to this pull request (https://github.com/neovim/neovim/pull/12655), the
way to override default lsp behavior has changed and thus it is needed to use
`vim.lsp.handlers` instead of `vim.lsp.callbacks`.

Read the setup section for required changes required from user side.

### Why not hide these details in plugin itself?
It would be comfortable if these details are hidden in plugin itself. However,
this limits the usecase of plugin and then it can't be used in the most
flexible as it works currently.
(For example: conditional loading of plugin with certain lsp-servers)

## Features

- Floating popup for code actions
- Preview window for references
- Preview window for definition, declaration, type-definition, implementation
- Preview window for document symbol and workspace symbol
- Fuzzy finding of symbols [optional]

## Demo

### Code Action:
![](https://user-images.githubusercontent.com/26287448/98861852-f7b7bd00-248b-11eb-8c11-fd37ab5d45d7.gif)


### References:
![](https://user-images.githubusercontent.com/26287448/98860407-9ee72500-2489-11eb-8b61-4ca7cb3f78ee.gif)

### Custom theming (See below for more details)
![](https://user-images.githubusercontent.com/26287448/98858320-6abe3500-2486-11eb-8795-a8d1bb8dbecc.gif)

## Future goals

- LspSearch command to search symbol over workspace and list it in a window.

** Fuzzy finding of symbols is optional for the time being. This is because
fuzzy engine of popfix is still in developement. However, it usually it doesn't
crash and work as expected. For using it read custom options section. 
For the code snippet read sample theming section. **

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
	vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
	vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
	vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
	vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
	vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
	vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
	vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
	vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
	EOF

## Custom Options

**NOTE: EACH attribute of custom opts is optional. If not provided, a suitable
default is used in place of it.**

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
	- border_chars (vimscript dictionary/ Lua table) (border characters for list)
		Sample border_chars example:
		```
		border_chars = {
			TOP_LEFT = '┌',
			TOP_RIGHT = '┐',
			MID_HORIZONTAL = '─',
			MID_VERTICAL = '│',
			BOTTOM_LEFT = '└',
			BOTTOM_RIGHT = '┘',
		}
		```
		If any of shown key of border_chars is missing then a space character
		is used instead of it.
- preview (vimscript dictionary / Lua tables) Accepts following key/value pairs:
	- border (boolean) (borders in floating mode)
	- numbering (boolean) (vim window numbering active or not)
	- title (string) (title for window)
	- border_chars (vimscript dictionary/ Lua table) (border characters for preview window)
		Sample border_chars example:
		```
		border_chars = {
			TOP_LEFT = '┌',
			TOP_RIGHT = '┐',
			MID_HORIZONTAL = '─',
			MID_VERTICAL = '│',
			BOTTOM_LEFT = '└',
			BOTTOM_RIGHT = '┘',
		}
		If any of shown key of border_chars is missing then a space character
		is used instead of it.
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
	- title (string) (title for window)
	- border_chars (vimscript dictionary/ Lua table) (border characters for list)
		Sample border_chars example:
		```
		border_chars = {
			TOP_LEFT = '┌',
			TOP_RIGHT = '┐',
			MID_HORIZONTAL = '─',
			MID_VERTICAL = '│',
			BOTTOM_LEFT = '└',
			BOTTOM_RIGHT = '┘',
		}
		```
		If any of shown key of border_chars is missing then a space character
		is used instead of it.
- prompt (table) (optional and may break)
	- border (boolean) (borders in floating mode)
	- numbering (boolean) (vim window numbering active or not)
	- border_chars (vimscript dictionary/ Lua table) (border characters for list)
		Sample border_chars example:
		```
		border_chars = {
			TOP_LEFT = '┌',
			TOP_RIGHT = '┐',
			MID_HORIZONTAL = '─',
			MID_VERTICAL = '│',
			BOTTOM_LEFT = '└',
			BOTTOM_RIGHT = '┘',
		}
		```
		If any of shown key of border_chars is missing then a space character
		is used instead of it.

See https://github.com/RishabhRD/popfix for more documentation of options.

These options helps to get better theme that suits your need.

### Sample themeing with lua

	local border_chars = {
		TOP_LEFT = '┌',
		TOP_RIGHT = '┐',
		MID_HORIZONTAL = '─',
		MID_VERTICAL = '│',
		BOTTOM_LEFT = '└',
		BOTTOM_RIGHT = '┘',
	}
	vim.g.lsp_utils_location_opts = {
		height = 24,
		mode = 'editor',
		preview = {
			title = 'Location Preview',
			border = true,
			border_chars = border_chars
		},
		keymaps = {
			n = {
				['<C-n>'] = 'j',
				['<C-p>'] = 'k',
			}
		}
	}
	vim.g.lsp_utils_symbols_opts = {
		height = 24,
		mode = 'editor',
		preview = {
			title = 'Symbols Preview',
			border = true,
			border_chars = border_chars
		},
		prompt = {},
	}

** Symbols would have fuzzy find features with these configuration **
