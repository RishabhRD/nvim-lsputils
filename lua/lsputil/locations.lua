-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local action = require'popfix.action'

-- TODO guaranteed to be accesed only by one reference operation by code
local temp_loc

local popup_buffer = {}
local function range_result(range)
	local line = range.start.line + 1
	local startLine = range.start.line + 1
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

-- selection handler
-- returns new preview according to location return by server
-- when selection is changed in popup
local function selection_handler(buf, index)
	local locations = popup_buffer[buf]
	local location = locations[index]
	local uri = location.uri or location.targetUri
	local range = location.range or location.targetSelectionRange
	local range_res = range_result(range)
	local filePath = uri:gsub('^file://', '')
	local raw_command = "cat -n %s | sed -n '%s,%sp'"
	local command = string.format(raw_command, filePath, range_res.startLine,
		range_res.endLine)
	local data = vim.fn.systemlist(command)
	return {
		data = data,
		line = range_res.line - range_res.startLine
	}
end

-- init handler
-- return preview for the first location return by server
local function init_handler(_)
	local location = temp_loc
	local uri = location.uri or location.targetUri
	local range = location.range or location.targetSelectionRange
	local range_res = range_result(range)
	local filePath = uri:gsub('^file://', '')
	local raw_command = "cat -n %s | sed -n '%s,%sp'"
	local command = string.format(raw_command, filePath, range_res.startLine,
		range_res.endLine)
	local data = vim.fn.systemlist(command)
	return {
		data = data,
		line = range_res.line - range_res.startLine
	}
end

-- close handler
-- jump to location if line was selection otherwise do nothing
-- Also cleans the data structure(memory mangement)
local function close_handler(buf, selected, line)
	local locations = popup_buffer[buf]
	if selected then
		vim.lsp.util.jump_to_location(locations[line])
	end
	popup_buffer[buf] = nil
end

local function references_handler(_, _, locations,_,bufnr)
	if locations == nil or vim.tbl_isempty(locations) then
		return
	end
	local data = {}
	local filename = vim.api.nvim_buf_get_name(bufnr)
	for i, location in pairs(locations) do
		local uri = location.uri or location.targetUri
		local range = location.range or location.targetSelectionRange
		local filePath = uri:gsub('^file://', '')
		--TODO path shortening
		local curData = ''..(range.start.line + 1)..' '
		if filename ~= filePath then
			curData = curData..filePath .. ': '
		end
		local command = "sed '%sq;d' %s"
		command = string.format(command, range.start.line + 1, filePath)
		local appendedList = vim.fn.systemlist(command)
		local appendedData = appendedList[1]
		curData = curData .. appendedData
		data[i] = curData
	end
	local key_maps = {
		n = {
			['<CR>'] = action.close_selected,
			['<ESC>'] = action.close_cancelled,
		}
	}
	temp_loc = locations[1]
	local buf = require'popfix.preview'.popup_preview(data, key_maps,
		init_handler, selection_handler, close_handler)
	popup_buffer[buf] = locations
	temp_loc = nil
end


local definition_handler = function(_,_,locations, _, bufnr)
	if locations == nil or vim.tbl_isempty(locations) then
		return
	end
	if vim.tbl_islist(locations) then
		if #locations > 1 then
			local data = {}
			local filename = vim.api.nvim_buf_get_name(bufnr)
			for i, location in pairs(locations) do
				local uri = location.uri or location.targetUri
				local range = location.range or location.targetSelectionRange
				local filePath = uri:gsub('^file://', '')
				--TODO path shortening
				local curData = ''..(range.start.line + 1)..' '
				if filename ~= filePath then
					curData = curData..filePath .. ': '
				end
				local command = "sed '%sq;d' %s"
				command = string.format(command, range.start.line + 1, filePath)
				local appendedList = vim.fn.systemlist(command)
				local appendedData = appendedList[1]
				curData = curData .. appendedData
				data[i] = curData
			end
			local key_maps = {
				n = {
					['<CR>'] = action.close_selected,
					['<ESC>'] = action.close_cancelled,
				}
			}
			temp_loc = locations[1]
			local buf = require'popfix.preview'.popup_preview(data, key_maps,
				init_handler, selection_handler, close_handler)
			popup_buffer[buf] = locations
			temp_loc = nil
		else
			vim.lsp.util.jump_to_location(locations[1])
		end
	else
		vim.lsp.util.jump_to_location(locations)
	end
end

return{
	references_handler = references_handler,
	definition_handler = definition_handler,
	declaration_handler = definition_handler,
	typeDefinition_handler = definition_handler,
	implementation_handler = definition_handler
}
