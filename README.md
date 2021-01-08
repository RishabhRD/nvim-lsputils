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
- Fuzzy finding of symbols, references, defintion and codeActions [optional]
- <C-t>, <C-v>, <C-x> opens tabs, vertical split and horizontal split for
  location and symbol actions

## Demo

### Code Action:
![](https://user-images.githubusercontent.com/26287448/98861852-f7b7bd00-248b-11eb-8c11-fd37ab5d45d7.gif)


### References:
![](https://user-images.githubusercontent.com/26287448/98860407-9ee72500-2489-11eb-8b61-4ca7cb3f78ee.gif)

### Custom theming (See below for more details)
![](https://user-images.githubusercontent.com/26287448/98858320-6abe3500-2486-11eb-8795-a8d1bb8dbecc.gif)

### Fuzzy search:
![](https://user-images.githubusercontent.com/26287448/100378731-abe34700-3039-11eb-98e6-151007b49d5a.gif)


## Future goals

- LspSearch command to search symbol over workspace and list it in a window.

**Fuzzy finding feature is optional for the time being. This is because
fuzzy engine of popfix is still in developement. However, it usually doesn't
crash and work as expected. For using it read custom options section. 
For the code snippet read sample theming section.**

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

## Default keymaps

### For codeaction

**In normal mode:**

|Key     |Action                                     |
|:------:|-------------------------------------------|
|\<CR\>  |Applies the codeaction                     |
|\<Esc\> |Quits the menu without applying codeaction |
|q       |Quits the menu without applying codeaction |
|j       |Selects next item                          |
|k       |Selects previous item                      |
|\<Down\>|Selects next item                          |
|\<Up\>  |Selects previous item                      |


**In insert mode(Fuzzy search mode):**

|Key     |Action                                     |
|:------:|-------------------------------------------|
|\<CR\>  |Applies the codeaction                     |
|\<C-c\> |Quits the menu without applying codeaction |
|\<C-n\> |Selects next item                          |
|\<C-p\> |Selects previous item                      |
|\<Down\>|Selects next item                          |
|\<Up\>  |Selects previous item                      |

### For symbols, references, and defintions

(document symbols + workspace symbols + references + defintions)

**In normal mode:**

|Key     |Action                                     |
|:------:|-------------------------------------------|
|\<CR\>  |Jump to location in same window            |
|\<C-v\> |Jump to location in a vertical split       |
|\<C-x\> |Jump to location in a horizontal split     |
|\<C-t\> |Jump to location in a new tab              |
|\<Esc\> |Quits the menu without jumping to location |
|q       |Quits the menu without jumping to location |
|j       |Selects next item                          |
|k       |Selects previous item                      |
|\<Down\>|Selects next item                          |
|\<Up\>  |Selects previous item                      |

**In insert mode(Fuzzy search mode):**

|Key     |Action                                     |
|:------:|-------------------------------------------|
|\<CR\>  |Jump to location in same window            |
|\<C-v\> |Jump to location in a vertical split       |
|\<C-x\> |Jump to location in a horizontal split     |
|\<C-t\> |Jump to location in a new tab              |
|\<C-c\> |Quits the menu without jumping to location |
|\<C-n\> |Selects next item                          |
|\<C-p\> |Selects previous item                      |
|\<Down\>|Selects next item                          |
|\<Up\>  |Selects previous item                      |
  
## Custom Filetypes

nvim-lsputils export some custom filetypes for their created buffer.
This enables users to do customization for nvim-lsputil buffers.

Custom filetypes are:

- For codeaction:

    - lsputil_codeaction_list (Represents codeaction list)
    - lsputil_codeaction_prompt (Represents codeaction prompt) (If enabled)

- For symbols (workspace and document symbols):

    - lsputil_symbols_list (Represents symbols list)
    - lsputil_symbols_preview (Represents symbols preview)
    - lsputil_symbols_prompt (Represents symbols prompt)

- For locations (definition, declaration, references, implementation):

    - lsputil_locations_list (Represents locations list)
    - lsputil_locations_preview (Represents locations preview)
    - lsputil_locations_prompt (Represents locations prompt)

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

```
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
```

**Symbols would have fuzzy find features with these configuration**

## Advanced configuration

nvim-lsputils provides some extension in handler function definition so that
it can be integrated with some other lsp plugins easily.

Currently codeaction supports this extended defintion. Codeaction handler signature
is something like:

```lua
code_action_handler(_, _, actions, _, _, _, customSelectionHandler)
```

``customSelectionHandler`` is not defined by standard docs. However, nvim-lsputils
provide it for easy extension and use with other plugins. ``customSelectionHandler`` is expected to be a function
that accepts the selection action(from all codeactions) as parameter. If provided to the function,
the function executes this customSelectionHandler with selected action instead
of applying codeaction directly.

A simple ``customSelectionHandler`` can look like:
```lua
local function customSelectionHandler(selectedAction)
  print("Action selected: ", selectedAction)
end
```


One simple example is integration with [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls).

```lua
local jdtls_ui = require'jdtls.ui'
function jdtls_ui.pick_one_async(items, _, _, cb)
  require'lsputil.codeAction'.code_action_handler(nil, nil, items, nil, nil, nil, cb)
end
```

This code snippet modifies the nvim-jdtls UI to make use of nvim-lsputils UI.
With this code snippet, nvim-lsputils would provide the UI but the action would
be decided by the functin parameter cb.
