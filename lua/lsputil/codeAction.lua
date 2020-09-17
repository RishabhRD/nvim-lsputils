local popup_buffer = {}

local popup_closed = function(buffer,selected,line)
	if selected then
		local actions = popup_buffer[buffer]
		local action = actions[line]
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
	end
	popup_buffer[buffer] = nil
end

local code_action_handler = function(_,_,actions)
	if actions == nil or vim.tbl_isempty(actions) then
		print("No code actions available")
		return
	end
	local data = {}
	for i, action in ipairs(actions) do
		local title = action.title:gsub('\r\n', '\\r\\n')
		title = title:gsub('\n','\\n')
		data[i] = title
	end
	local action = require'popfix.action'
	local key_maps = {
		n = {
			['<CR>'] = action.close_selected,
			['<ESC>'] = action.close_cancelled,
			['<C-n>'] = action.next_select,
			['<C-p>'] = action.prev_select,
			['<C-j>'] = action.next_select,
			['<C-k>'] = action.prev_select,
		}
	}
	local buf = require'popfix.popup'.popup_window(data, key_maps, nil, nil, popup_closed)
	popup_buffer[buf] = actions
end

return{
	code_action_handler = code_action_handler
}
