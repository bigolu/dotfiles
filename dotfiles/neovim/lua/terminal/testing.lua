Plug("nvim-neotest/neotest", {
  config = function()
    require("neotest").setup({
      benchmark = { enabled = false },
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
        }),
      },
      floating = {
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        max_height = 0.6,
        max_width = 0.6,
        options = { winblend = 2 },
      },
      icons = {
        failed = " ",
        passed = " ",
        unknown = "?",
        running = " ",
        skipped = " ",
        watching = " ",
        running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      },
      summary = {
        mappings = {
          expand = { "<Tab>", "<2-LeftMouse>" },
          expand_all = "<S-Tab>",
          jumpto = "<CR>",
          next_failed = "]l",
          prev_failed = "[l",
          stop = "s",

          -- disabled
          short = "zza",
          target = "zzb",
          clear_target = "zzc",
          output = "zzd",
        },
        open = function()
          vim.cmd(string.format(
            [[
            topleft vsplit
            vertical resize %d
          ]],
            math.floor(vim.o.columns * 0.33)
          ))
          return vim.api.nvim_get_current_win()
        end,
        "",
      },
      output = { enabled = false },
      output_panel = {
        open = function()
          vim.cmd(string.format(
            [[
              botright split
              resize %d
            ]],
            math.floor(vim.o.lines * 0.30)
          ))
          vim.wo.winhighlight = ""
          return vim.api.nvim_get_current_win()
        end,
      },
    })

    vim.keymap.set(
      "n",
      "<M-t>",
      require("neotest").summary.toggle,
      { desc = "Toggle test summary window" }
    )

    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = "neotest-summary",
      callback = function()
        vim.b.minicursorword_disable = true
        vim.b.minicursorword_disable_permanent = true

        vim.wo.signcolumn = "no"
        vim.wo.statuscolumn = ""

        vim.wo.winhighlight = "CursorLine:NeotestCurrentLine"

        vim.keymap.set(
          "n",
          "q",
          require("neotest").summary.close,
          { desc = "Close neotest summary window", buffer = true }
        )
        vim.keymap.set(
          "n",
          "o",
          require("neotest").output_panel.toggle,
          { desc = "Toggle test output terminal", buffer = true }
        )
      end,
    })

    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = "neotest-output-panel",
      callback = function()
        vim.keymap.set(
          "n",
          "q",
          require("neotest").output_panel.close,
          { desc = "Close test output terminal", buffer = true }
        )
        vim.wo.winbar = "  Test output"
      end,
    })

    local utils = require("terminal.utilities")
    vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
      callback = function()
        if vim.o.filetype == "neotest-summary" then
          utils.set_persistent_highlights("tests", {
            TestTitle = "BufferLineBufferSelected",
            TestBorder = "BufferLineIndicatorSelected",
          })
        end
      end,
    })
    vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        if vim.o.filetype == "neotest-summary" then
          utils.set_persistent_highlights("tests", {
            TestTitle = "BufferLineBufferVisible",
            TestBorder = "Ignore",
          })
        end
      end,
    })
  end,
})

Plug("nvim-neotest/neotest-python")
