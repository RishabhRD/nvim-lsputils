local M = {}
local api = vim.api
-- close handler
-- jump to location in a new vertical split
-- according to index and result returned by server.
-- Also cleans the data structure(memory mangement)
function M.close_selected_handler(index, command)
    M.popup = nil
    if index == nil then
	M.items = nil
	return
    end
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
    if command == nil then
    elseif command == 'vsp' then
	vim.cmd('vsp')
    elseif command == 'sp' then
	vim.cmd('sp')
    elseif command == 'tab' then
	local buffer = api.nvim_get_current_buf()
        vim.cmd(string.format(":tab sb %d", buffer))
    end
    vim.lsp.util.jump_to_location(location)
    vim.cmd(':normal! zz')
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


function M.close_cancelled_handler()
    M.popup = nil
    M.items = nil
end

function M.close_cancelled(self)
    self:close(M.close_cancelled_handler)
end

function M.select_next(self)
    self:select_next(M.selection_handler)
end

function M.select_prev(self)
    self:select_prev(M.selection_handler)
end

function M.close_vertical_split_handler(index)
    M.close_selected_handler(index, 'vsp')
end

function M.close_vert_split(self)
    self:close(M.close_vertical_split_handler)
end

function M.close_split_handler(index)
    M.close_selected_handler(index, 'sp')
end

function M.close_split(self)
    self:close(M.close_split_handler)
end

function M.close_tab_handler(index)
    M.close_selected_handler(index, 'tab')
end

function M.close_tab(self)
    self:close(M.close_tab_handler)
end

function M.close_edit(self)
    self:close(M.close_selected_handler)
end

-- for codeactions
function M.codeaction_selection_handler(index)
    M.popup = nil
    if index == nil then
	M.actionBuffer = nil
	return
    end
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

function M.customSelectionAction(customFunction)
  return function(popup)
    popup:close(function(index)
      M.popup = nil
      if index == nil then
        M.actionBuffer = nil
        return
      end
      local action = M.actionBuffer[index]
      customFunction(action)
      M.actionBuffer = nil
    end)
  end
end


function M.codeaction_cancel_handler()
    M.popup = nil
    M.actionBuffer = nil
end

function M.codeaction_fix(self)
    self:close(M.codeaction_selection_handler)
end

function M.codeaction_cancel(self)
    self:close(M.codeaction_cancel_handler)
end

function M.codeaction_next(self)
    self:select_next()
end

function M.codeaction_prev(self)
    self:select_prev()
end

return M
