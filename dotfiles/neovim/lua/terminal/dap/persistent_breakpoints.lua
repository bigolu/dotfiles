local breakpoint_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "breakpoints")

local function persist_breakpoints_as_json(path, tbl)
  -- ensure it's saved as a dictionary
  if vim.tbl_isempty(tbl) then
    tbl = vim.empty_dict()
  end

  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local fp = io.open(path, "w")
  if fp == nil then
    vim.notify("Failed to write to file. File: " .. path, vim.log.levels.ERROR)
    return
  else
    fp:write(vim.fn.json_encode(tbl))
    fp:close()
    return
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "PlugEndPost",
  callback = function()
    BREAKPOINTS_FOR_SESSION = BREAKPOINTS_FOR_SESSION or {}

    local function record_breakpoints_for_buffer(buffer)
      local has_active_session = string.len(vim.v.this_session) > 0
      if not has_active_session then
        return
      end

      local bname = vim.api.nvim_buf_get_name(buffer)
      if bname == "" then
        return
      end

      local breakpoints_for_buffer = require("dap.breakpoints").get(buffer)[buffer]
      if #breakpoints_for_buffer == 0 then
        -- so the key in the JSON will be removed
        breakpoints_for_buffer = nil
      end
      BREAKPOINTS_FOR_SESSION[bname] = breakpoints_for_buffer
      local basename = vim.fs.basename(vim.v.this_session)
      persist_breakpoints_as_json(
        vim.fs.joinpath(breakpoint_dir, basename),
        BREAKPOINTS_FOR_SESSION
      )
    end

    local function make_recorder(fn)
      return function(...)
        fn(...)
        record_breakpoints_for_buffer(vim.api.nvim_get_current_buf())
      end
    end
    local dap = require("dap")
    local original_toggle_breakpoint = dap.toggle_breakpoint
    dap.toggle_breakpoint = make_recorder(original_toggle_breakpoint)
    local original_set_breakpoint = dap.set_breakpoint
    dap.set_breakpoint = make_recorder(original_set_breakpoint)
  end,
})

-- To account for breakpoints changed in dapui. I tried to wrap the API it uses to change
-- breakpoints, but failed.
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local has_active_session = string.len(vim.v.this_session) > 0
    if not has_active_session then
      return
    end

    local breakpoints_by_bufname = vim
      .iter(require("dap.breakpoints").get())
      :fold({}, function(acc, bufnr, breakpoints)
        acc[vim.api.nvim_buf_get_name(bufnr)] = breakpoints
        return acc
      end)
    local basename = vim.fs.basename(vim.v.this_session)
    persist_breakpoints_as_json(vim.fs.joinpath(breakpoint_dir, basename), breakpoints_by_bufname)
  end,
})

-- TODO: Should let people know I figured out how to load breakpoints for all buffers:
-- https://github.com/Weissle/persistent-breakpoints.nvim/issues/8
vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = function()
    local function read_json(path)
      local fp = io.open(path, "r")
      if fp == nil then
        vim.notify("Failed to read file. File: " .. path, vim.log.levels.ERROR)
        return nil
      end

      return vim.fn.json_decode(fp:read("*a"))
    end

    -- where background means the file won't be focused and it won't show up in my bufferline
    local function open_file_in_background(filename)
      vim.cmd.badd(filename)
      local buf = vim.fn.bufnr(filename)
      vim.bo[buf].buflisted = false

      return buf
    end

    local function restore_breakpoint(breakpoint, buffer)
      local line = breakpoint.line
      local opts = {
        condition = breakpoint.condition,
        log_message = breakpoint.logMessage,
        hit_condition = breakpoint.hitCondition,
      }
      require("dap.breakpoints").set(opts, buffer, line)
    end

    local session_basename = vim.fs.basename(vim.v.this_session)
    local breakpoints_path = vim.fs.joinpath(breakpoint_dir, session_basename)
    if vim.fn.filereadable(breakpoints_path) == 0 then
      return
    end

    local breakpoints_by_filename = read_json(breakpoints_path)
    if type(breakpoints_by_filename) ~= "table" then
      return
    end

    for filename, breakpoints in pairs(breakpoints_by_filename) do
      -- File no longer exists so remove its breakpoints
      if vim.fn.filereadable(filename) == 0 then
        breakpoints_by_filename[filename] = nil
        goto continue
      end

      local buffer = (vim.fn.bufexists(filename) ~= 0) and vim.fn.bufnr(filename)
        or open_file_in_background(filename)

      vim.iter(breakpoints):each(function(breakpoint)
        restore_breakpoint(breakpoint, buffer)
      end)

      ::continue::
    end

    BREAKPOINTS_FOR_SESSION = breakpoints_by_filename
  end,
})