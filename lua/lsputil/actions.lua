local resource = require'lsputil.popupResource'
local M = {}

-- close handler
-- jump to location in a new vertical split
-- according to index and result returned by server.  
-- Also cleans the data structure(memory mangement)
function M.close_vertical_handler(index)
	if index == nil then return end
	resource.popup = nil
	if selected then
		local item = M.items[index]
		local location = {
			uri = 'file://'..item.filename,
			range = {
				start = {
					line = item.lnum - 1,
					--TODO: robust character column
					character = item.col
				}
			}
		}
		vim.cmd('vsp')
		vim.lsp.util.jump_to_location(location)
		vim.cmd(':normal! zz')
	end
	M.items = nil
end

-- close handler
-- jump to location according to index
-- and result returned by server.
-- Also cleans the data structure(memory mangement)
function M.close_handler(index, _, selected)
	if index == nil then return end
	resource.popup = nil
	if selected then
		local item = M.items[index]
		local location = {
			uri = 'file://'..item.filename,
			range = {
				start = {
					line = item.lnum - 1,
					character = item.col
				}
			}
		}
		vim.lsp.util.jump_to_location(location)
		vim.cmd(':normal! zz')
	end
	M.items = nil
end

-- selection handler
-- returns data to preview for index item
-- according to data returned by server
function M.selection_handler(index)
	if index == nil then return end
	local item = M.items[index]
	local startPoint = item.lnum - 3
	if startPoint <= 0 then
		startPoint = item.lnum
	end
	local cmd = string.format('bat %s --color=always --paging=always --plain -n --pager=\'less -RS\' -H %s -r %s:', item.filename, item.lnum, startPoint)
	return {
		cmd = cmd
	}
end


function M.close_selected_handler(index, line)
	M.close_handler(index, line, true)
end

function M.close_cancelled_handler(index, line)
	M.close_handler(index, line, false)
end

function M.close_cancelled(self)
	self:close(close_cancelled_handler)
end

function M.select_next(self)
	self:select_next(M.selection_handler)
end

function M.select_prev(self)
	self:select_prev(M.selection_handler)
end

function M.close_vert_split(self)
	self:close(M.close_vertical_handler)
end

function M.close_edit(self)
	self:close(M.close_selected_handler)
end

-- for codeactions
function M.codeacton_selection_handler(index)
	resource.popup = nil
	local action = M.actionBuffer[index]
	if action.edit or type(action.command) == "table" then
		if action.edit then
			vim.lsp.util.apply_workspace_edit(action.edit)
		end
		if type(action.command) == "table" then
			vim.lsp.buf.execute_command(action.command)
		end
	else
		vim.lsp.buf.execute_command(action)
	end
	M.actionBuffer = nil
end

function M.codeaction_cancel_handler()
	resource.popup = nil
	M.actionBuffer = nil
end

function M.codeaction_fix(self)
	self:close(M.codeacton_selection_handler)
end

function M.codeaction_cancel(self)
	self:close(M.close_cancelled_handler)
end

function M.codeaction_next(self)
	self:select_next()
end

function M.codeaction_prev(self)
	self:select_prev()
end

return M
