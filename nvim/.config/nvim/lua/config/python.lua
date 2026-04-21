local M = {}

local function executable(path)
  return path and vim.fn.executable(path) == 1
end

local function find_venv(start_dir)
  local current_dir = start_dir

  while current_dir and current_dir ~= "" do
    for _, name in ipairs({ ".venv", "venv", "env" }) do
      local venv_dir = current_dir .. "/" .. name
      local python = venv_dir .. "/bin/python"
      if executable(python) then
        return {
          venv = venv_dir,
          python = python,
          root = current_dir,
        }
      end
    end

    local parent = vim.fn.fnamemodify(current_dir, ":h")
    if parent == current_dir then
      break
    end
    current_dir = parent
  end
end

function M.resolve(path)
  local start_dir = nil

  if path and path ~= "" then
    local absolute = vim.fn.fnamemodify(path, ":p")
    if vim.fn.isdirectory(absolute) == 1 then
      start_dir = absolute
    else
      start_dir = vim.fn.fnamemodify(absolute, ":h")
    end
  else
    start_dir = vim.fn.getcwd()
  end

  local local_env = find_venv(start_dir)
  if local_env then
    return local_env
  end

  local active_venv = vim.env.VIRTUAL_ENV
  if active_venv and active_venv ~= "" then
    local python = active_venv .. "/bin/python"
    if executable(python) then
      return {
        venv = active_venv,
        python = python,
        root = start_dir,
      }
    end
  end

  return {
    venv = nil,
    python = "python3",
    root = start_dir,
  }
end

function M.activation_command(env)
  if not env.venv then
    return nil
  end

  return string.format(
    "export VIRTUAL_ENV=%s; export PATH=%s:$PATH",
    vim.fn.shellescape(env.venv),
    vim.fn.shellescape(env.venv .. "/bin")
  )
end

return M
