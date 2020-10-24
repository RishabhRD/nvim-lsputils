local actionBuffer = nil
local backupActions = nil
local popfix = require'popfix'

local keymaps = nil
local additionalKeymaps = nil

-- close action handler for handling popup close(popfix api)
local popup_closed = function(index, _, selected)
	if selected then
		local action = actionBuffer[index]
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
	actionBuffer = nil
end

-- codeAction event callback handler
local code_action_handler = function(_,_,actions)
	if actions == nil or vim.tbl_isempty(actions) then
		print("No code actions available")
		return
	end
	backupActions = actionBuffer
	actionBuffer = actions
	local data = {}
	for i, action in ipairs(actions) do
		local title = action.title:gsub('\r\n', '\\r\\n')
		title = title:gsub('\n','\\n')
		data[i] = title
	end
	local opts = {
		data = data,
		mode = 'cursor',
		list = {
			numbering = true,
			coloring = true
		},
		callbacks = {
			close = popup_closed
		},
		keymaps = keymaps,
		additional_keymaps = additionalKeymaps
	}
	local width = 0
	for _, str in ipairs(opts.data) do
		if #str > width then
			width = #str
		end
	end
	opts.list.width = width + 5
	opts.height = opts.height or #opts.data
	local success = popfix.open(opts)
	if success then
		backupActions = nil
	else
		actionBuffer = backupActions
		backupActions = nil
	end
end

return{
	code_action_handler = code_action_handler,
	keymaps = keymaps,
	additional_keymaps = additionalKeymaps
}
