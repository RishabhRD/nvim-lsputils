-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local action = require'popfix.action'
local util = require'lsputil.util'

-- buffer storage for each buffer during its popup is displayed
local popup_buffer = {}

-- Guranteed to be referenced one at a time
local temp_item

local key_maps = {
	n = {
		['<CR>'] = action.close_selected,
		['<ESC>'] = action.close_cancelled,
		['q'] = action.close_cancelled
	},
	i = {
	}
}


-- close handler
-- jump to location according to index
-- and result returned by server.
-- Also cleans the data structure(memory mangement)
local function close_handler(buf, selected, index)
	local items = popup_buffer[buf].items
	if selected then
		local item = items[index]
		local location = {
			uri = 'file://'..item.filename,
			range = {
				start = {
					line = item.lnum - 1,
					character = item.col - 1
				}
			}
		}
		util.jump_to_location(location, popup_buffer[buf].win)
	end
	popup_buffer[buf] = nil
end

-- selection handler
-- returns data to preview for index item
-- according to data returned by server
local function selection_handler(buf, index)
	local items = popup_buffer[buf].items
	local item = items[index]
	local data_line = util.get_data_from_file(item.filename,item.lnum - 1)
	return {
		data = data_line.data,
		line = data_line.line,
		filetype = popup_buffer[buf].filetype
	}
end

-- init hander
-- returns data to preview first item
-- according to data returned by server
local function init_handler(_)
	local item = temp_item.item
	local data_line = util.get_data_from_file(item.filename,item.lnum - 1)
	return {
		data = data_line.data,
		line = data_line.line,
		filetype = temp_item.filetype
	}
end

-- callback for lsp actions that returns symbols
-- (for symbols see :h lsp)
local function symbol_handler(_, _, result, _, bufnr)
	if not result or vim.tbl_isempty(result) then return end
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local items = vim.lsp.util.symbols_to_items(result, bufnr)
	local data = {}
	for i, item in pairs(items) do
		data[i] = item.text
		if filename ~= item.filename then
			data[i] = data[i]..' - '..item.filename
		end
		item.text = nil
	end
	local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype');
	temp_item = {
		item = items[1],
		filetype = filetype
	}
	local win = vim.api.nvim_get_current_win()
	local buf = require'popfix.preview'.popup_preview(data, key_maps,
		init_handler, selection_handler, close_handler)
	popup_buffer[buf] = {
		items = items,
		filetype = filetype,
		win = win
	}
	temp_item = nil
end

return{
	document_handler = symbol_handler,
	workspace_handler = symbol_handler,
	key_maps = key_maps
}
