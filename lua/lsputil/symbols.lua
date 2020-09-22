-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local action = require'popfix.action'

-- buffer storage for each buffer during its popup is displayed
local popup_buffer = {}

-- Guranteed to be referenced one at a time
local temp_item

-- returns line range to display in preview
local function range_result(start_line)
	local line = start_line
	local startLine = start_line
	local endLine
	if startLine <= 3 then
		endLine  = 11 - startLine
		startLine = 1
	else
		endLine = startLine + 7
		startLine = startLine - 2
	end
	return {
		line = line,
		startLine = startLine,
		endLine = endLine
	}
end


-- retreives data form file using cat and sed
-- (both because we want line numebrs)
local function get_data_from_file(filePath, range_res)
	local raw_command = "cat -n '%s' | sed -n '%s,%sp'"
	local command = string.format(raw_command, filePath, range_res.startLine,
		range_res.endLine)
	return vim.fn.systemlist(command)
end

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
		vim.lsp.util.jump_to_location(location)
	end
	popup_buffer[buf] = nil
end

local function selection_handler(buf, index)
	local items = popup_buffer[buf].items
	local item = items[index]
	local range_res = range_result(item.lnum)
	local data = get_data_from_file(item.filename,range_res)
	return {
		data = data,
		line = range_res.line - range_res.startLine,
		filetype = popup_buffer[buf].filetype
	}
end

-- init hander
-- returns data to preview first item
-- according to data returned by server
local function init_handler(_)
	local item = temp_item.item
	local range_res = range_result(item.lnum)
	local data = get_data_from_file(item.filename,range_res)
	return {
		data = data,
		line = range_res.line - range_res.startLine,
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
	end
	local key_maps = {
		n = {
			['<CR>'] = action.close_selected,
			['<ESC>'] = action.close_cancelled,
		}
	}
	local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype');
	temp_item = {
		item = items[1],
		filetype = filetype
	}
	local buf = require'popfix.preview'.popup_preview(data, key_maps,
		init_handler, selection_handler, close_handler)
	popup_buffer[buf] = {
		items = items,
		filetype = filetype
	}
	temp_item = nil
end

return{
	document_handler = symbol_handler,
	workspace_handler = symbol_handler
}
