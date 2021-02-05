-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local popfix = require'popfix'
local util = require'lsputil.util'
local action = require'lsputil.actions'

-- default keymaps provided by nvim-lsputils
local keymaps = {
    i = {
	['<CR>'] = action.close_edit,
	['<C-n>'] = action.select_next,
	['<C-p>'] = action.select_prev,
	['<Down>'] = action.select_next,
	['<Up>'] = action.select_prev,
	['<C-c>'] = action.close_cancelled,
	['<C-v>'] = action.close_vert_split,
	['<C-x>'] = action.close_split,
	['<C-t>'] = action.close_tab,
    },
    n = {
	['<CR>'] = action.close_edit,
	['j'] = action.select_next,
	['k'] = action.select_prev,
	['<Down>'] = action.select_next,
	['<Up>'] = action.select_prev,
	['<Esc>'] = action.close_cancelled,
	['q'] = action.close_cancelled,
	['<C-v>'] = action.close_vert_split,
	['<C-x>'] = action.close_split,
	['<C-t>'] = action.close_tab,
    }
}

-- opts for popfix
local function createOpts()
  local opts = {
    mode = 'split',
    height = 12,
    keymaps = keymaps,
    close_on_bufleave = true,
    callbacks = {
      select = action.selection_handler,
      close = action.close_cancelled_handler,
    },
    list = {
      numbering = true
    },
    preview = {
      type = 'terminal',
      border = true,
    }
  }
  util.handleGlobalVariable(vim.g.lsp_utils_location_opts, opts)
  return opts
end
-- callback for lsp references handler
local function references_handler(_, _, locations,_,bufnr)
    if locations == nil or vim.tbl_isempty(locations) then
	print "No references found"
	return
    end
    if action.popup then
	print 'Busy with some LSP popup'
	return
    end
    local data = {}
    local filename = vim.api.nvim_buf_get_name(bufnr)
    action.items = vim.lsp.util.locations_to_items(locations)
    for i, item in pairs(action.items) do
	data[i] = item.text
	if filename ~= item.filename then
	    local cwd = vim.fn.getcwd(0)..'/'
	    local add = util.get_relative_path(cwd, item.filename)
	    data[i] = data[i]..' - '..add
	end
        data[i] = data[i]:gsub("\n", "")
	action.items.text = nil
    end
    local opts = createOpts();
    opts.data = data
    action.popup = popfix:new(opts)
    if not action.popup then
	action.items = nil
    end
    if action.popup.list then
	util.setFiletype(action.popup.list.buffer, 'lsputil_locations_list')
    end
    if action.popup.preview then
	util.setFiletype(action.popup.preview.buffer, 'lsputil_locations_preview')
    end
    if action.popup.prompt then
	util.setFiletype(action.popup.prompt.buffer, 'lsputil_locations_prompt')
    end
    opts.data = nil
end

-- callback for lsp definition, implementation and declaration handler
local definition_handler = function(_,_,locations, _, bufnr)
    if locations == nil or vim.tbl_isempty(locations) then
	return
    end
    if vim.tbl_islist(locations) then
	if #locations > 1 then
	    if action.popup then
		print 'Busy with some LSP popup'
		return
	    end
	    local data = {}
	    local filename = vim.api.nvim_buf_get_name(bufnr)
	    action.items = vim.lsp.util.locations_to_items(locations)
	    for i, item in pairs(action.items) do
		data[i] = item.text
		if filename ~= item.filename then
		    local cwd = vim.fn.getcwd(0)..'/'
		    local add = util.get_relative_path(cwd, item.filename)
		    data[i] = data[i]..' - '..add
		end
                data[i] = data[i]:gsub("\n", "")
		item.text = nil
	    end
            local opts = createOpts();
	    opts.data = data
	    action.popup = popfix:new(opts)
	    if not action.popup then
		action.items = nil
	    end
	    if action.popup.list then
		util.setFiletype(action.popup.list.buffer, 'lsputil_locations_list')
	    end
	    if action.popup.preview then
		util.setFiletype(action.popup.preview.buffer, 'lsputil_locations_preview')
	    end
	    if action.popup.prompt then
		util.setFiletype(action.popup.prompt.buffer, 'lsputil_locations_prompt')
	    end
	    opts.data = nil
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

}
