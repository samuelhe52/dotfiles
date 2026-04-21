return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = nil,
      direction = "float",
      start_in_insert = true,
      insert_mappings = false,
      terminal_mappings = false,
      persist_size = true,
      persist_mode = true,
      close_on_exit = false,
      shade_terminals = true,
      float_opts = {
        border = "rounded",
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.85)
        end,
      },
    },
    config = function(_, opts)
      local toggleterm = require("toggleterm")
      local terms = require("toggleterm.terminal")
      local Terminal = terms.Terminal
      local python_env = require("config.python")

      toggleterm.setup(opts)

      local current = 1
      local runners = {}
      local current_python_env

      local function terminal_ids()
        local ids = {}
        for _, term in ipairs(terms.get_all(true)) do
          table.insert(ids, term.id)
        end
        table.sort(ids)
        return ids
      end

      local function close_all_open_terminals()
        toggleterm.toggle_all()
      end

      local function last_file_buffer_path()
        local buffers = vim.fn.getbufinfo({ buflisted = 1 })
        table.sort(buffers, function(a, b)
          return (a.lastused or 0) > (b.lastused or 0)
        end)

        for _, info in ipairs(buffers) do
          if info.bufnr ~= vim.api.nvim_get_current_buf() then
            local name = vim.api.nvim_buf_get_name(info.bufnr)
            if name ~= "" and vim.bo[info.bufnr].buftype == "" then
              return name
            end
          end
        end
      end

      local function current_terminal_context()
        local buf = vim.api.nvim_get_current_buf()
        local file = nil

        if vim.bo[buf].buftype == "" then
          file = vim.api.nvim_buf_get_name(buf)
        else
          file = last_file_buffer_path()
        end

        local dir = file and file ~= "" and vim.fn.fnamemodify(file, ":p:h") or vim.fn.getcwd()
        local env = current_python_env(file ~= "" and file or nil)
        local key = env.venv and string.format("%s::%s", env.venv, dir) or nil

        return {
          buf = buf,
          file = file,
          dir = dir,
          env = env,
          key = key,
        }
      end

      local function sync_current_terminal_from_buffer()
        local toggle_number = vim.b.toggle_number
        if toggle_number and toggle_number > 0 then
          current = toggle_number
        end
      end

      local function sync_terminal_context(term, context)
        if not term or not term.job_id or not context.env.venv or term._python_context_key == context.key then
          return
        end

        local activate = python_env.activation_command(context.env)
        if activate then
          vim.fn.chansend(term.job_id, activate .. "\n")
        end

        vim.fn.chansend(term.job_id, string.format("cd %s\n", vim.fn.shellescape(context.dir)))
        term._python_context_key = context.key
      end

      local function open_terminal(id)
        local existing = terms.get(id, true)
        close_all_open_terminals()
        current = id
        if existing then
          existing:open()
        else
          vim.cmd(string.format("%dToggleTerm direction=float name=shell-%d", id, id))
        end

        local term = terms.get(id, true)
        if term and not existing then
          sync_terminal_context(term, current_terminal_context())
        end
      end

      local function toggle_current_terminal()
        current = math.max(current, 1)
        local term = terms.get(current, true)
        if term then
          term:toggle()
          return
        end

        vim.cmd(string.format("%dToggleTerm direction=float name=shell-%d", current, current))
        term = terms.get(current, true)
        if term then
          sync_terminal_context(term, current_terminal_context())
        end
      end

      local function next_terminal_id()
        local ids = terminal_ids()
        if #ids == 0 then
          return 1
        end
        return ids[#ids] + 1
      end

      local function cycle_terminal(step)
        local ids = terminal_ids()
        if #ids == 0 then
          open_terminal(1)
          return
        end

        local position = 1
        for i, id in ipairs(ids) do
          if id == current then
            position = i
            break
          end
        end

        local next_position = ((position - 1 + step) % #ids) + 1
        open_terminal(ids[next_position])
      end

      local function terminal_label(term)
        local name = term.display_name or term.name or ("term-" .. term.id)
        local marker = term.id == current and "*" or " "
        return string.format("%s [%d] %s", marker, term.id, name)
      end

      local function select_terminal()
        local available = terms.get_all(true)
        if #available == 0 then
          vim.notify("No terminal instances are open", vim.log.levels.INFO)
          return
        end

        table.sort(available, function(a, b)
          return a.id < b.id
        end)

        vim.ui.select(available, {
          prompt = "Select terminal",
          format_item = terminal_label,
        }, function(choice)
          if choice then
            open_terminal(choice.id)
          end
        end)
      end

      local function kill_current_terminal()
        local term = terms.get(current, true)
        if not term then
          return
        end

        term:shutdown()

        local ids = terminal_ids()
        if #ids == 0 then
          current = 1
        else
          current = ids[1]
        end
      end

      local function runner_terminal(name)
        if runners[name] then
          return runners[name]
        end

        runners[name] = Terminal:new({
          direction = "float",
          close_on_exit = false,
          hidden = true,
          display_name = name,
        })

        return runners[name]
      end

      local function reset_runner_terminal(name)
        local term = runners[name]
        if term then
          term:shutdown()
          runners[name] = nil
        end

        return runner_terminal(name)
      end

      local function ensure_file_is_saved(buf)
        if vim.bo[buf].buftype ~= "" then
          vim.notify("Quick run only works for file buffers", vim.log.levels.WARN)
          return false
        end

        local file = vim.api.nvim_buf_get_name(buf)
        if file == "" then
          vim.notify("Save the current buffer before running it", vim.log.levels.WARN)
          return false
        end

        if vim.bo[buf].modified then
          vim.api.nvim_buf_call(buf, vim.cmd.write)
        end

        return true, file
      end

      current_python_env = function(file)
        local has_venv_selector, venv_selector = pcall(require, "venv-selector")
        if has_venv_selector then
          local active_python = venv_selector.python()
          if active_python and active_python ~= "" then
            return {
              python = active_python,
              venv = venv_selector.venv(),
            }
          end
        end

        return python_env.resolve(file)
      end

      local function run_in_terminal(name, command, context)
        local term = reset_runner_terminal(name)

        term:open()
        sync_terminal_context(term, context)
        term:send(command, false)
      end

      local function run_python_buffer()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].filetype ~= "python" then
          vim.notify("Python quick run only supports python buffers", vim.log.levels.WARN)
          return
        end

        local ok, file = ensure_file_is_saved(buf)
        if not ok then
          return
        end

        local context = current_terminal_context()
        local command = string.format(
          "%s %s",
          vim.fn.shellescape(context.env.python),
          vim.fn.shellescape(file)
        )

        run_in_terminal("python-runner", command, context)
      end

      local function open_python_terminal()
        local term = runner_terminal("python-shell")
        local context = current_terminal_context()

        current = term.id
        term:open()
        sync_terminal_context(term, context)
      end

      local function terminal_command(action, opts)
        opts = opts or {}
        return function()
          sync_current_terminal_from_buffer()
          vim.cmd("stopinsert")
          action()
          if opts.enter_insert then
            vim.cmd("startinsert")
          end
        end
      end

      vim.keymap.set({ "n", "t" }, "<C-`>", function()
        sync_current_terminal_from_buffer()
        if vim.fn.mode() == "t" then
          vim.cmd("stopinsert")
        end
        toggle_current_terminal()
      end, { desc = "Toggle Terminal" })
      vim.keymap.set("n", "<leader>tt", toggle_current_terminal, { desc = "Toggle Terminal" })
      vim.keymap.set("n", "<leader>rp", run_python_buffer, { desc = "Run Python Buffer" })

      vim.keymap.set("t", "<C-a>h", terminal_command(function()
        cycle_terminal(-1)
      end, { enter_insert = true }), { desc = "Previous Terminal" })
      vim.keymap.set("t", "<C-a>l", terminal_command(function()
        cycle_terminal(1)
      end, { enter_insert = true }), { desc = "Next Terminal" })
      vim.keymap.set("t", "<C-a>n", terminal_command(function()
        open_terminal(next_terminal_id())
      end, { enter_insert = true }), { desc = "Create Terminal" })
      vim.keymap.set("t", "<C-a>i", terminal_command(select_terminal), { desc = "Inspect Terminals" })
      vim.keymap.set("t", "<C-a>x", terminal_command(kill_current_terminal), { desc = "Kill Terminal" })
      vim.keymap.set("t", "<C-a>p", terminal_command(open_python_terminal, { enter_insert = true }), { desc = "Python Terminal" })
      vim.keymap.set("t", "<C-a>`", terminal_command(toggle_current_terminal, { enter_insert = true }), { desc = "Toggle Terminal" })
    end,
  },
}
