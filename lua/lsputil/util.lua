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

local function get_base(path)
	local len = #path
	for i = len , 1, -1 do
		if path:sub(i,i) == '/' then
			local ret =  path:sub(i+1,len)
			return ret
		end
	end
end

local function getDirectores(path)
	local data = {}
	local len = #path
	if len <= 1 then return nil end
	local last_index = 1
	for i = 2, len do
		local cur_char = path:sub(i,i)
		if cur_char == '/' then
			local my_data = path:sub(last_index + 1, i - 1)
			table.insert(data, my_data)
			last_index = i
		end
	end
	return data
end

local function get_relative_path(base_path, my_path)
	local base_data = getDirectores(base_path)
	local my_data = getDirectores(my_path)
	local base_len = #base_data
	local my_len = #my_data

	if base_len > my_len then
		return my_path
	end

	if base_data[1] ~= my_data[1] then
		return my_path
	end

	local cur = 0
	for i = 1, base_len do
		if base_data[i] ~= my_data[i] then
			break
		end
		cur = i
	end
	local data = ''
	for i = cur+1, my_len do
		data = data..my_data[i]..'/'
	end
	data = data..get_base(my_path)
	return data
end


return{
	jump_to_location = jump_to_location,
	get_data_from_file = get_data_from_file,
	get_relative_path = get_relative_path
}
