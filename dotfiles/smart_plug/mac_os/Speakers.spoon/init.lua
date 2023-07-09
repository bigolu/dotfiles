local icon = [[ASCII:
1 · · · · · · · · · · · · · · 1 2 
4 · · · · · · · · · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · 6 · · · · · · · · 
· · · · · · · 6 · 6 · · · · · · · 
· · · · · · · · 6 · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · 5 · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · 5 · · · · · 5 · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · 5 · · · · · · · · 
· · · · · · · · · · · · · · · · · 
· · · · · · · · · · · · · · · · 2 
4 3 · · · · · · · · · · · · · · 3 
]]

local function execute(executable, arguments, callback)
  -- I'm using hs.task because os.execute was really slow. For more on why os.execute was slow see here:
  -- https://github.com/Hammerspoon/hammerspoon/issues/2570
  return hs.task.new(
    executable,
    callback,
    arguments
  ):start()
end

local speakerctl_path = os.getenv('HOME') .. '/.nix-profile/bin/speakerctl'

local function turn_on()
  execute(
    speakerctl_path,
    {'on',}
  )
end

local function turn_off()
  execute(
    speakerctl_path,
    {'off',}
  )
end

local function make_menu()
  local task = execute(speakerctl_path, {})
  task:waitUntilExit()
  local exit_code = task:terminationStatus()

  local menu_item = {
    title = 'Disconnected from speakers',
    disabled = true,
  }
  if exit_code == 0 then
    menu_item = {
      title = 'Turn speakers off',
      fn = turn_off,
    }
  elseif exit_code == 1 then
    menu_item = {
      title = 'Turn speakers on',
      fn = turn_on,
    }
  end

  return {menu_item}
end

local M = {}

M.menubar_item = hs.menubar.new():setIcon(icon):setMenu(make_menu)

return M