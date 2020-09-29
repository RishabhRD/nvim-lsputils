-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local action = require'popfix.action'
local util = require'lsputil.util'

-- TODO guaranteed to be accesed only by one reference operation by code
local temp_item

local popup_buffer = {}

local key_maps = {
  n = {
    ['<CR>'] = action.close_selected,
    ['<ESC>'] = action.close_cancelled,
    ['q'] = action.close_cancelled
  },
  i = {
  }
}

-- selection handler
-- returns new preview according to location return by server
-- when selection is changed in popup
local function selection_handler(buf, index)
  local items = popup_buffer[buf].items
  local item = items[index]
  local data_line = util.get_data_from_file(item.filename,item.lnum - 1)
  return {
    data = data_line.data,
    line = data_line.line,
    filetype = popup_buffer[buf].filetype
  }
end

-- init handler
-- return preview for the first location return by server
local function init_handler(_)
  local item = temp_item.item
  local data_line = util.get_data_from_file(item.filename, item.lnum-1)
  return {
    data = data_line.data,
    line = data_line.line,
    filetype = temp_item.filetype
  }
end

-- close handler
-- jump to location if line was selection otherwise do nothing
-- Also cleans the data structure(memory mangement)
local function close_handler(buf, selected, line)
  local items = popup_buffer[buf].items
  if selected then
    local item = items[line]
    local location = {
      uri = 'file://'..item.filename,
      range = {
        start = {
          line = item.lnum - 1,
          character = item.col - 1
        }
      }
    }
    util.jump_to_location(location, popup_buffer[buf].win)
  end
  popup_buffer[buf] = nil
end

local function references_handler(_, _, locations,_,bufnr)
  if locations == nil or vim.tbl_isempty(locations) then
    return
  end
  local data = {}
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local items = vim.lsp.util.locations_to_items(locations)
  for i, item in pairs(items) do
    data[i] = item.text
    if filename ~= item.filename then
      data[i] = data[i]..' - '..item.filename
    end
    items.text = nil
  end
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local win = vim.api.nvim_get_current_win();
  temp_item = {
    item = items[1],
    filetype = filetype
  }
  local buf = require'popfix.preview'.popup_preview(data, key_maps,
    init_handler, selection_handler, close_handler)
  popup_buffer[buf] ={
    items = items,
    filetype = filetype,
    win = win
  }
  temp_item = nil
end


local definition_handler = function(_,_,locations, _, bufnr)
  if locations == nil or vim.tbl_isempty(locations) then
    return
  end
  if vim.tbl_islist(locations) then
    if #locations > 1 then
      local data = {}
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
      local items = vim.lsp.util.locations_to_items(locations)
      for i, item in pairs(items) do
        data[i] = item.text
        if filename ~= item.filename then
          data[i] = data[i]..' - '..item.filename
        end
        item.text = nil
      end
      temp_item = {
        item = items[1],
        filetype = filetype
      }
      local win = vim.api.nvim_get_current_win()
      local buf = require'popfix.preview'.popup_preview(data, key_maps,
        init_handler, selection_handler, close_handler)
      popup_buffer[buf] ={
        items = items,
        filetype = filetype,
        win = win
      }
      temp_item = nil
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
  key_maps = key_maps
}
