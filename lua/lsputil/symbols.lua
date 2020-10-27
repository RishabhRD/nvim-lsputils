-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local util = require'lsputil.util'
local popfix = require'popfix'

-- buffer storage for each buffer during its popup is displayed
local items = {}
local backupItems = {}
local keymaps = nil
local additionalKeymaps = nil

-- close handler
-- jump to location according to index
-- and result returned by server.
-- Also cleans the data structure(memory mangement)
local function close_handler(index, _, selected)
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
	items = nil
end

-- selection handler
-- returns data to preview for index item
-- according to data returned by server
local function selection_handler(index)
	local item = items[index]
	local startPoint = item.lnum - 3
	if startPoint <= 0 then
		startPoint = item.lnum
	end
	local cmd = string.format('bat %s --color=always --paging=always --plain -n --pager=\'less -RS\' -H %s -r %s:', item.filename, item.lnum, startPoint)
	return {
		cmd = cmd
	}
end

-- callback for lsp actions that returns symbols
-- (for symbols see :h lsp)
local function symbol_handler(_, _, result, _, bufnr)
	if not result or vim.tbl_isempty(result) then return end
	local filename = vim.api.nvim_buf_get_name(bufnr)
	backupItems = items
	items = vim.lsp.util.symbols_to_items(result, bufnr)
	local data = {}
	for i, item in pairs(items) do
		data[i] = item.text
		if filename ~= item.filename then
			local cwd = vim.fn.getcwd(0)..'/'
			local add = util.get_relative_path(cwd, item.filename)
			data[i] = data[i]..' - '..add
		end
		item.text = nil
	end
	local opts = {
		mode = 'split',
		data = data,
		height = 12,
		keymaps = keymaps,
		additional_keymaps = additionalKeymaps,
		callbacks = {
			select = selection_handler,
			close = close_handler
		},
		list = {
			numbering = true
		},
		preview = {
			type = 'terminal',
			border = true,
		}

	}
	if vim.g.lsp_utils_symbols_opts then
		local tmp = vim.g.lsp_utils_symbols_opts
		opts.mode = tmp.mode or opts.mode
		opts.height = tmp.height or opts.height
		if opts.height == 0 then
			if opts.mode == 'editor' then
				opts.height = nil
			elseif opts.mode == 'split' then
				opts.height = 12
			end
		end
		opts.width = tmp.width
		opts.additional_keymaps = tmp.keymaps or opts.additional_keymaps
		if tmp.list then
			if not tmp.list.numbering == nil then
				opts.list.numbering = tmp.list.numbering
			end
			if not tmp.list.border == nil then
				opts.list.border = tmp.list.border
			end
			opts.list.title = tmp.list.title or opts.list.title
		end
		if tmp.preview then
			if not tmp.preview.numbering == nil then
				opts.preview.numbering = tmp.preview.numbering
			end
			if not tmp.preview.border == nil then
				opts.preview.border = tmp.preview.border
			end
			opts.preview.title = tmp.preview.title or opts.preview.title
		end
	end
	local success = popfix.open(opts)
	if success then
		backupItems = nil
	else
		items = backupItems
		backupItems = nil
	end
end

return{
	document_handler = symbol_handler,
	workspace_handler = symbol_handler,
	keymaps = keymaps,
	additional_keymaps = additionalKeymaps
}
