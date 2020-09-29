local function get_line_byte_from_position(bufnr, position)
	-- LSP's line and characters are 0-indexed
	-- Vim's line and columns are 1-indexed
	local col = position.character
	-- When on the first character, we can ignore the difference between byte and
	-- character
	if col > 0 then
		local line = position.line
		local lines = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)
		if #lines > 0 then
			return vim.str_byteindex(lines[1], col)
		end
	end
	return col
end

local function jump_to_location(location, win)
	-- location may be Location or LocationLink
	local uri = location.uri or location.targetUri
	if uri == nil then return end
	local bufnr = vim.uri_to_bufnr(uri)
	-- Save position in jumplist
	vim.cmd "normal! m'"

	-- Push a new item into tagstack
	local from = {vim.fn.bufnr('%'), vim.fn.line('.'), vim.fn.col('.'), 0}
	local items = {{tagname=vim.fn.expand('<cword>'), from=from}}
	vim.fn.settagstack(vim.fn.win_getid(), {items=items}, 't')

	--- Jump to new location (adjusting for UTF-16 encoding of characters)
	vim.api.nvim_set_current_win(win)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_option(0, 'buflisted', true)
	local range = location.range or location.targetSelectionRange
	local row = range.start.line
	local col = get_line_byte_from_position(0, range.start)
	vim.api.nvim_win_set_cursor(0, {row + 1, col})
	return true
end

-- retreives data form file
-- and line to highlight
local function get_data_from_file(filename,startLine)
	local displayLine;
	if startLine < 3 then
		displayLine = startLine
		startLine = 0
	else
		startLine = startLine - 2
		displayLine = 2
	end
	local bufnr = vim.fn.bufadd(filename)
	local data = vim.api.nvim_buf_get_lines(bufnr, startLine, startLine+8, false)
	if data == nil or vim.tbl_isempty(data) then
		startLine = nil
	else
		local len = #data
		startLine = startLine+1
		for i = 1, len, 1 do
			data[i] = startLine..' '..data[i]
			startLine = startLine + 1
		end
	end
	return{
		data = data,
		line = displayLine
	}
end

return{
	jump_to_location = jump_to_location,
	get_data_from_file = get_data_from_file
}
