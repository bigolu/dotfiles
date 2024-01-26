-- open new horizontal and vertical panes to the right and bottom respectively
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.winminheight = 0
vim.o.winminwidth = 0
vim.keymap.set("n", "<Leader><Bar>", "<Cmd>vsplit<CR>")
vim.keymap.set("n", "<Leader>-", "<Cmd>split<CR>")
vim.keymap.set("n", "<C-w>", vim.cmd.close)

local window_group_id = vim.api.nvim_create_augroup("Window", {})

-- Automatically resize all splits to make them equal when the vim window is resized or a new window
-- is created/closed.
vim.api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
  callback = function()
    -- Don't equalize when vim is starting up so it doesn't reset the window sizes from my session.
    local is_vim_starting = vim.fn.has("vim_starting") == 1
    if is_vim_starting then
      return
    end
    vim.cmd.wincmd("=")
  end,
  group = window_group_id,
})
vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
  callback = function()
    local amatch = vim.fn.expand("<amatch>")
    local id = tonumber(amatch)
    -- sometimes amatch is the file opened in the window
    if id == nil then
      return
    end
    -- Don't equalize splits if the new window is floating, it won't get resized anyway.
    local is_float = vim.api.nvim_win_get_config(id).relative ~= ""
    if is_float then
      return
    end
    vim.cmd.wincmd("=")
  end,
  group = window_group_id,
})

-- TODO: This won't work until I use a release of neovim that has this fix, right now it's only on
-- nightly: https://github.com/neovim/neovim/pull/25096
vim.api.nvim_create_autocmd({ "WinNew" }, {
  callback = function()
    local is_float = vim.api.nvim_win_get_config(0).relative ~= ""
    if is_float then
      local ok, reticle = pcall(require, "reticle")
      if ok then
        reticle.disable_cursorline()
      end
    end
  end,
  group = window_group_id,
})

local toggle_cursor_line_group_id =
  vim.api.nvim_create_augroup("ToggleCursorlineWithWindowFocus", {})
vim.api.nvim_create_autocmd({ "FocusGained" }, {
  callback = function()
    pcall(require("reticle").enable_cursorline)
  end,
  group = toggle_cursor_line_group_id,
})
vim.api.nvim_create_autocmd({ "FocusLost" }, {
  callback = function()
    pcall(require("reticle").disable_cursorline)
  end,
  group = toggle_cursor_line_group_id,
})

-- Resize windows
vim.keymap.set({ "n" }, "<C-Left>", [[<Cmd>vertical resize +1<CR>]], { silent = true })
vim.keymap.set({ "n" }, "<C-Right>", [[<Cmd>vertical resize -1<CR>]], { silent = true })
vim.keymap.set({ "n" }, "<C-Up>", [[<Cmd>resize +1<CR>]], { silent = true })
vim.keymap.set({ "n" }, "<C-Down>", [[<Cmd>resize -1<CR>]], { silent = true })

Plug("anuvyklack/middleclass")

Plug("anuvyklack/windows.nvim", {
  config = function()
    require("windows").setup({
      autowidth = {
        enable = false,
      },
    })

    -- TODO: When tmux is able to differentiate between enter and ctrl+m this mapping should be
    -- updated. tmux issue: https://github.com/tmux/tmux/issues/2705#issuecomment-841133549
    vim.keymap.set("n", "<Leader>m", function()
      vim.cmd.WindowsMaximize()
    end)
  end,
})

-- Seamless movement between vim windows and tmux panes.
Plug("christoomey/vim-tmux-navigator", {
  config = function()
    vim.keymap.set({ "n", "i" }, "<M-h>", "<Cmd>TmuxNavigateLeft<CR>", { silent = true })
    vim.keymap.set({ "n", "i" }, "<M-l>", "<Cmd>TmuxNavigateRight<CR>", { silent = true })
    vim.keymap.set({ "n", "i" }, "<M-j>", "<Cmd>TmuxNavigateDown<CR>", { silent = true })
    vim.keymap.set({ "n", "i" }, "<M-k>", "<Cmd>TmuxNavigateUp<CR>", { silent = true })
  end,
})
vim.g.tmux_navigator_no_mappings = 1
vim.g.tmux_navigator_preserve_zoom = 1
vim.g.tmux_navigator_disable_when_zoomed = 0
