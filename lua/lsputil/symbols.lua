-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local util = require'lsputil.util'
local popfix = require'popfix'
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
  util.handleGlobalVariable(vim.g.lsp_utils_symbols_opts, opts)
  return opts
end
-- callback for lsp actions that returns symbols
-- (for symbols see :h lsp)
local function symbol_handler(_, _, result, _, bufnr)
    if action.popup then
	print 'Busy in some other LSP popup'
	return
    end
    if not result or vim.tbl_isempty(result) then return end
    local filename = vim.api.nvim_buf_get_name(bufnr)
    action.items = vim.lsp.util.symbols_to_items(result, bufnr)
    local data = {}
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
    local opts = createOpts()
    opts.data = data
    action.popup = popfix:new(opts)
    if not action.popup then
	action.items = nil
    end
    if action.popup.list then
	util.setFiletype(action.popup.list.buffer, 'lsputil_symbols_list')
    end
    if action.popup.preview then
	util.setFiletype(action.popup.preview.buffer, 'lsputil_symbols_preview')
    end
    if action.popup.prompt then
	util.setFiletype(action.popup.prompt.buffer, 'lsputil_symbols_prompt')
    end
    opts.data = nil
end

return{
    document_handler = symbol_handler,
    workspace_handler = symbol_handler,
    keymaps = keymaps,
}
