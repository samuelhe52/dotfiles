local map = vim.keymap.set

local sidebar_filetypes = {
  ["NvimTree"] = true,
  ["alpha"] = true,
  ["neo-tree"] = true,
  ["snacks_dashboard"] = true,
  ["snacks_explorer"] = true,
  ["snacks_layout_box"] = true,
}

local function is_sidebar_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return true
  end

  if vim.bo[buf].buftype ~= "" then
    return true
  end

  return sidebar_filetypes[vim.bo[buf].filetype] == true
end

local function pick_fallback_buffer(current)
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(buffers, function(a, b)
    return (a.lastused or 0) > (b.lastused or 0)
  end)

  for _, info in ipairs(buffers) do
    if info.bufnr ~= current and not is_sidebar_buffer(info.bufnr) then
      return info.bufnr
    end
  end

  return vim.api.nvim_create_buf(true, false)
end

local function delete_buffer_skip_sidebars()
  local current = vim.api.nvim_get_current_buf()

  if vim.bo[current].modified then
    local ok, choice = pcall(
      vim.fn.confirm,
      ("Save changes to %q?"):format(vim.fn.bufname(current)),
      "&Yes\n&No\n&Cancel"
    )
    if not ok or choice == 0 or choice == 3 then
      return
    end
    if choice == 1 then
      vim.api.nvim_buf_call(current, vim.cmd.write)
    end
  end

  local target = pick_fallback_buffer(current)

  for _, win in ipairs(vim.fn.win_findbuf(current)) do
    vim.api.nvim_win_set_buf(win, target)
  end

  if vim.api.nvim_buf_is_valid(current) then
    pcall(vim.api.nvim_buf_delete, current, { force = true })
  end
end

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>W", "<cmd>wa<cr>", { desc = "Save all files" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>bd", delete_buffer_skip_sidebars, { desc = "Delete buffer" })
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "Clear search highlight" })

map("t", "<C-]>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to lower window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to upper window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to right window" })
