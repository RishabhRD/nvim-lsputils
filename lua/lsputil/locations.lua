-- built upon popfix api(https://github.com/RishabhRD/popfix)
-- for parameter references see popfix readme.

local action = require'popfix.action'
local util = require'lsputil.util'

-- TODO guaranteed to be accesed only by one reference operation by code
local temp_loc

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

local function get_data_from_loaction(location)
  local uri = location.uri or location.targetUri
  local range = location.range or location.targetSelectionRange
  local startLine = range.start.line;
  local displayLine;
  if startLine < 3 then
    displayLine = startLine
    startLine = 0
  else
    startLine = startLine - 2
    displayLine = 2
  end
  local filename = vim.uri_to_fname(uri)
  local bufnr = vim.fn.bufadd(filename)
  local data = vim.api.nvim_buf_get_lines(bufnr, startLine, startLine+8, false)
  if data == nil or vim.tbl_isempty(data) then
    startLine = nil
  else
    local len = #data
    startLine = startLine+1
    for i = 1, len, 1 do
      data[i] = startLine..' '..data[i]
      startLine = startLine + 1
    end
  end
  return{
    data = data,
    line = displayLine
  }
end


-- selection handler
-- returns new preview according to location return by server
-- when selection is changed in popup
local function selection_handler(buf, index)
  local locations = popup_buffer[buf].locations
  local location = locations[index]
  local data_line = get_data_from_loaction(location)
  return {
    data = data_line.data,
    line = data_line.line,
    filetype = popup_buffer[buf].filetype
  }
end

-- init handler
-- return preview for the first location return by server
local function init_handler(_)
  local location = temp_loc.location
  local data_line = get_data_from_loaction(location)
  return {
    data = data_line.data,
    line = data_line.line,
    filetype = temp_loc.filetype
  }
end

-- close handler
-- jump to location if line was selection otherwise do nothing
-- Also cleans the data structure(memory mangement)
local function close_handler(buf, selected, line)
  local locations = popup_buffer[buf].locations
  if selected then
    util.jump_to_location(locations[line], popup_buffer[buf].win)
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
  end
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local win = vim.api.nvim_get_current_win();
  temp_loc = {
    location = locations[1],
    filetype = filetype
  }
  local buf = require'popfix.preview'.popup_preview(data, key_maps,
    init_handler, selection_handler, close_handler)
  popup_buffer[buf] ={
    locations = locations,
    filetype = filetype,
    win = win
  }
  temp_loc = nil
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
      end
      temp_loc = {
        location = locations[1],
        filetype = filetype
      }
      local win = vim.api.nvim_get_current_win()
      local buf = require'popfix.preview'.popup_preview(data, key_maps,
        init_handler, selection_handler, close_handler)
      popup_buffer[buf] ={
        locations = locations,
        filetype = filetype,
        win = win
      }
      temp_loc = nil
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
