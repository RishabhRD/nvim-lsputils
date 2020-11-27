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
	local uri = 'file://'..filename
	local bufnr = vim.uri_to_bufnr(uri)
	vim.fn.bufload(bufnr)
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

local function handleGlobalVariable(var, opts)
	if var == nil then return end
	opts.mode = var.mode or opts.mode
	opts.height = var.height or opts.height
	if opts.height == 0 then
		if opts.mode == 'editor' then
			opts.height = nil
		elseif opts.mode == 'split' then
			opts.height = 12
		end
	end
	opts.width = var.width
	if var.keymaps then
		if not opts.keymaps then
			opts.keymaps = {}
		end
		if var.keymaps.i then
			if not opts.keymaps.i then
				opts.keymaps.i = {}
			end
			for k, v in pairs(var.keymaps.i) do
				opts.keymaps.i[k] = v
			end
		end
		if var.keymaps.n then
			if not opts.keymaps.n then
				opts.keymaps.n = {}
			end
			for k, v in pairs(var.keymaps.n) do
				opts.keymaps.n[k] = v
			end
		end
	end
	if var.list then
		if not (var.list.numbering == nil) then
			opts.list.numbering = var.list.numbering
		end
		if not (var.list.border == nil) then
			opts.list.border = var.list.border
		end
		opts.list.title = var.list.title or opts.list.title
		opts.list.border_chars = var.list.border_chars
	end
	if var.preview and opts.preview then
		if not (var.preview.numbering == nil) then
			opts.preview.numbering = var.preview.numbering
		end
		if not (var.preview.border == nil) then
			opts.preview.border = var.preview.border
		end
		opts.preview.title = var.preview.title or opts.preview.title
		opts.preview.border_chars = var.preview.border_chars
	end
	if var.prompt then
		opts.prompt = {
			border_chars = var.prompt.border_chars,
			coloring = var.prompt.coloring,
			prompt_text = 'Symbols',
			search_type = 'plain',
			border = true
		}
		if var.prompt.border == false or var.prompt.border == true then
			opts.prompt.border = var.prompt.border
		end
	end
end


return{
	get_data_from_file = get_data_from_file,
	get_relative_path = get_relative_path,
	handleGlobalVariable = handleGlobalVariable,
}

