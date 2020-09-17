local function references_handler(_, _, result)
	if result == nil or vim.tbl_isempty(result) then
		return
	end
	require'popfix.preview'.popup_preview(result)
end

return{
	references_handler = references_handler
}
