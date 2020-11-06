local actionBuffer = nil
local popfix = require'popfix'
local resource = require'lsputil.popupResource'

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
	resource.popup = nil
end

-- codeAction event callback handler
local code_action_handler = function(_,_,actions)
	if actions == nil or vim.tbl_isempty(actions) then
		print("No code actions available")
		return
	end
	if resource.popup then
		print 'Busy in other LSP popup'
		return
	end
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
			border = true,
			-- TODO: I like borders for code_actions. Otherwise, it's hard for
			-- to understand I entered to border mode.
			-- coloring = true
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
	opts.width = width + 5
	opts.height = opts.height or #opts.data
	if vim.g.lsp_utils_codeaction_opts then
		local tmp = vim.g.lsp_utils_codeaction_opts
		opts.mode = tmp.mode or opts.mode
		if tmp.height == 0 then
			if opts.mode == 'editor' then
				opts.height = nil
			elseif opts.mode == 'split' then
				opts.height = 12
			end
		end
		opts.width = tmp.width
		opts.additional_keymaps = tmp.keymaps or opts.additional_keymaps
		if tmp.list then
			if not (tmp.list.numbering == nil) then
				opts.list.numbering = tmp.list.numbering
			end
			if not (tmp.list.border == nil) then
				opts.list.border = tmp.list.border
			end
			opts.list.title = tmp.list.title or opts.list.title
			opts.list.border_chars = tmp.list.border_chars
		end
	end
	local popup = popfix:new(opts)
	if popup then
		resource.popup = popup
	else
		actionBuffer = nil
	end
end

return{
	code_action_handler = code_action_handler,
	keymaps = keymaps,
	additional_keymaps = additionalKeymaps
}
