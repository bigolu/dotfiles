-- Wrapper for vim-plug with a few new features.

-- Functions to be called after a plugin is loaded to configure it.
local configs_by_type = {
  sync = {},
  async = {},
  lazy = {},
}

-- Calls the configuration function for the specified, lazy-loaded plugin.
local function plug_wrapper_apply_lazy_config(plugin_name)
  local config = configs_by_type.lazy[plugin_name]
  if type(config) == 'function' then
    config()
  end
end

-- Calls the configuration function for all non-lazy-loaded plugins.
local function apply_configs(configs)
  for _, config in pairs(configs) do
    config()
  end
end

local original_plug_begin = vim.fn['plug#begin']
function PlugBegin()
  original_plug_begin()
end

local original_plug_end = vim.fn['plug#end']
function PlugEnd()
  original_plug_end()

  -- This way code can be run after plugins are loaded, but before 'VimEnter'
  vim.api.nvim_exec_autocmds('User', {pattern = 'PlugEndPost'})

  apply_configs(configs_by_type.sync)

  -- Apply the async configurations after everything else that is currently on the event loop. Now
  -- configs are applied after any files specified on the commandline are opened and after sessions are restored.
  -- This way, neovim shows me the first file "instantly" and by the time I've looked at the file and decided on my
  -- first keypress, the plugin configs have already been applied.
  local function ApplyAsyncConfigs()
    apply_configs(configs_by_type.async)
  end
  vim.defer_fn(ApplyAsyncConfigs, 0)
end

local original_plug = vim.fn['plug#']
-- Similar to the vim-plug `Plug` command, but with an additional option to specify a function to run after a
-- plugin is loaded.
function Plug(repo, options)
  if not options then
    original_plug(repo)
    return
  end

  local original_plug_options = vim.tbl_deep_extend('force', options, {config = nil, sync = nil,})
  original_plug(repo, original_plug_options)

  local config = options.config
  if type(config) == 'function' then
    if options['on'] or options['for'] then
      local plugin_name = repo:match("^[%w-]+/([%w-_.]+)$")
      configs_by_type.lazy[plugin_name] = config
      vim.api.nvim_create_autocmd(
        'User',
        {
          pattern = plugin_name,
          callback = function() plug_wrapper_apply_lazy_config(plugin_name) end,
          group = vim.api.nvim_create_augroup('PlugLua', {}),
          once = true,
        }
      )
    elseif options.sync then
      table.insert(configs_by_type.sync, config)
    else
      table.insert(configs_by_type.async, config)
    end
  end
end
