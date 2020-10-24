-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local popfix = require'popfix'
local util = require'lsputil.util'


local backupItems = nil
local items = nil
local keymaps = nil
local additionalKeymaps = nil

-- selection handler
-- returns new preview according to location return by server
-- when selection is changed in popup
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

-- close handler
-- jump to location if line was selection otherwise do nothing
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
	backupItems = nil
end

local function references_handler(_, _, locations,_,bufnr)
	if locations == nil or vim.tbl_isempty(locations) then
		return
	end
	backupItems = items
	local data = {}
	local filename = vim.api.nvim_buf_get_name(bufnr)
	items = vim.lsp.util.locations_to_items(locations)
	for i, item in pairs(items) do
		data[i] = item.text
		if filename ~= item.filename then
			local cwd = vim.fn.getcwd(0)..'/'
			local add = util.get_relative_path(cwd, item.filename)
			data[i] = data[i]..' - '..add
		end
		items.text = nil
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
			title = 'Preview',
		}

	}
	local success = popfix.open(opts)
	if success then
		backupItems = nil
	else
		items = backupItems
		backupItems = nil
	end
end


local definition_handler = function(_,_,locations, _, bufnr)
	if locations == nil or vim.tbl_isempty(locations) then
		return
	end
	if vim.tbl_islist(locations) then
		if #locations > 1 then
			local data = {}
			local filename = vim.api.nvim_buf_get_name(bufnr)
			items = vim.lsp.util.locations_to_items(locations)
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
			local success = popfix.open(opts)
			if success then
				backupItems = nil
			else
				items = backupItems
				backupItems = nil
			end
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
	implementation_handler = definition_handler,
	keymaps = keymaps,
	additional_keymaps = additionalKeymaps

}
