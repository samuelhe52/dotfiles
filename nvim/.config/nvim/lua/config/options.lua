local opt = vim.opt

vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_prettier_needs_config = false

local function copilot_client()
  local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
  if #clients > 0 then
    return clients[1]
  end
  clients = vim.lsp.get_clients({ name = "copilot" })
  if #clients > 0 then
    return clients[1]
  end
end

local function copilot_sign_in()
  local client = copilot_client()
  if not client then
    vim.notify("Open a buffer with Copilot attached, then run :LspCopilotSignIn again.", vim.log.levels.WARN)
    return
  end

  client:request("signIn", vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end

    if result.command then
      local code = result.userCode
      local command = result.command
      vim.fn.setreg("+", code)
      vim.fn.setreg("*", code)
      local continue = vim.fn.confirm(
        "Copied your one-time code to clipboard.\nOpen the browser to complete the sign-in process?",
        "&Yes\n&No"
      )
      if continue == 1 then
        client:exec_cmd(command, { bufnr = vim.api.nvim_get_current_buf() }, function(cmd_err, cmd_result)
          if cmd_err then
            vim.notify(cmd_err.message, vim.log.levels.ERROR)
            return
          end
          if cmd_result.status == "OK" then
            vim.notify("Signed in as " .. cmd_result.user .. ".")
          end
        end)
      end
    end

    if result.status == "PromptUserDeviceFlow" then
      vim.notify("Enter your one-time code " .. result.userCode .. " in " .. result.verificationUri)
    elseif result.status == "AlreadySignedIn" then
      vim.notify("Already signed in as " .. result.user .. ".")
    end
  end)
end

local function copilot_sign_out()
  local client = copilot_client()
  if not client then
    vim.notify("Open a buffer with Copilot attached, then run :LspCopilotSignOut again.", vim.log.levels.WARN)
    return
  end

  client:request("signOut", vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    if result.status == "NotSignedIn" then
      vim.notify("Not signed in.")
    end
  end)
end

vim.api.nvim_create_user_command("LspCopilotSignIn", copilot_sign_in, { desc = "Sign in Copilot with GitHub" })
vim.api.nvim_create_user_command("LspCopilotSignOut", copilot_sign_out, { desc = "Sign out Copilot with GitHub" })

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 200
opt.timeoutlen = 300
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.undofile = true
opt.swapfile = false
