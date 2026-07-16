local function termcode(keys)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function default_enter()
  if _G.MiniPairs then
    return _G.MiniPairs.cr()
  end
  return termcode("<CR>")
end

local function restore_option(buf, name, value)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.bo[buf][name] = value
    end
  end)
end

local function swift_enter()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local col = cursor[2]
  local inside_braces = line:sub(col, col) == "{" and line:sub(col + 1, col + 1) == "}"

  if inside_braces and vim.bo.smartindent then
    local buf = vim.api.nvim_get_current_buf()
    local old_smartindent = vim.bo.smartindent
    vim.bo.smartindent = false
    restore_option(buf, "smartindent", old_smartindent)
  end

  return default_enter()
end

-- Swift keeps smartindent globally, but `{}` needs a one-key suppression so
-- MiniPairs can split the block without pushing `}` over.
vim.keymap.set("i", "<CR>", swift_enter, {
  buffer = true,
  expr = true,
  noremap = true,
  silent = true,
  desc = "Swift smart Enter",
})
