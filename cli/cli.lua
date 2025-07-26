-- ALWAYS ON TOP
require 'cli.globals'
--
local fs = require 'cli.fs'
local utils = require 'cli.utils'

local deps_file_template = [[---@class DepsFile
return {
  scripts = {
    test = {
      desc = 'Run project tests',
      cb = function(add_dependencies_to_path)
        -- Optional call
        -- add_dependencies_to_path()
        error('Not implemented.')
      end
    },
  },
  dependencies = {
    -- example
    -- utils = 'git@github.com:YagoCrispim/lua_utils.git'
  },
  dev_dependencies = {}
}]]

-- forward declaration
local add_deps_to_path
local instal_dependency
local cb_context

---@class LuaCLI
local cli = {
  context = {
    op = arg[1],
    checked_deps = {},
    config = {
      dep_folder_name = 'libs',
    }
  },
}

cli.run = {
  desc = 'Execute a command in deps.lua with given name',
  cb = function()
    local success, deps = pcall(function()
      return require 'deps'
    end)

    if not success then
      print('[ERROR]: deps.lua not found. run "lua cli.lua init" to create it.')
      return
    end

    assert(deps, "'deps.lua' not found in current directory.")

    local script_name = arg[2]

    if not script_name then
      print('Script not informed.')
      print('Usage: lua cli.lua run <script_name>')
      return
    end

    if not deps.scripts or not deps.scripts[script_name] then
      print('[ERROR]: Script "' .. script_name .. '" not found.')
      return
    end

    deps.scripts[script_name].cb(cb_context)
  end
}

cli.install = {
  desc = 'Install project dependencies',
  cb = function(deps_param)
    local deps = deps_param

    if not deps_param then
      local success, depsfile = pcall(function()
        return require 'deps'
      end)

      if not success then
        print('[ERROR]: deps.lua not found. run "lua cli.lua init" to create it.')
        return
      end

      deps = depsfile
    end

    assert(deps, "'deps.lua' not found in current directory.")

    if (deps.dependencies or deps.dev_dependencies) then
      if not fs.exists(cli.context.config.dep_folder_name) then
        os.execute('mkdir libs')
      end

      if deps.dependencies then
        for name, dep in pairs(deps.dependencies) do
          local install_path = fs.join({ '.', cli.context.config.dep_folder_name, name })
          instal_dependency(name, dep, install_path)
        end
      end

      if deps.dev_dependencies then
        for name, dep in pairs(deps.dev_dependencies) do
          local install_path = fs.join({ '.', cli.context.config.dep_folder_name, '_dev', name })
          instal_dependency(name, dep, install_path)
        end
      end
    end
  end
}

cli.init = {
  desc = "Initialize a project",
  cb = function()
    local cwd = fs.cwd
    local deps_path = fs.join({ cwd, 'deps.lua' })
    local ignore_path = fs.join({ cwd, '.gitignore' })

    if not fs.exists(deps_path, true) then
      ---@type any
      local deps = io.open(deps_path, 'w')
      deps:write(deps_file_template)
      deps:close()
      print('deps.lua created.')
    else
      print('deps.lua already exist.')
    end

    if not fs.exists(ignore_path, true) then
      ---@type any
      local gitIgnore = io.open(ignore_path, 'w')
      gitIgnore:write('libs')
      gitIgnore:close()
      print('.gitignore created.')
    else
      print('.gitignore already exist')
    end
  end
}

---@param op string
function cli:get_op(op)
  if not cli[op] then
    print('CLI commands')
    for _, v in pairs({ 'init', 'install', 'run' }) do
      if type(v) ~= 'function' then
        print('- ' .. v, cli[v].desc)
      end
    end

    local success, deps = pcall(function()
      return require 'deps'
    end)

    if not success then
      return
    end

    if deps then
      print('\nProject scripts')

      for k, v in pairs(deps.scripts) do
        if type(v) ~= 'function' then
          print('- ' .. k, v.desc)
        end
      end
    end
    return
  end

  return cli[op]
end

---@param name string
---@param dep string|DepTable|fun(params: DepsScriptFnParams):nil
---@param install_path string
instal_dependency = function(name, dep, install_path)
  ---@generic T
  ---@param content string
  ---@return `T` | nil
  local function eval_script(content)
    ---@diagnostic disable-next-line: undefined-global, deprecated
    local eval = utils.tern(_VERSION == 'Lua 5.4', load, loadstring)

    if content and content ~= "" then
      local func, _ = eval(content)
      if func then
        return func()
      end
    else
      return nil
    end
  end

  ---@param dep_path string
  ---@param skip_setup_call? boolean
  local function for_each_dep(dep_path, skip_setup_call)
    local path = fs.join({ dep_path, 'deps.lua' })
    local setup_file = fs.join({ dep_path, 'setup.lua' })

    if fs.exists(setup_file, true) then
      os.execute('lua ' .. setup_file)
    end

    if skip_setup_call then
      return
    end

    local deps_file = eval_script(path)
    if deps_file then
      cli.install.cb(deps_file)
    end
  end

  if not fs.exists(install_path) then
    cli.context.checked_deps[name] = true

    if type(dep) == "string" then
      print('\n--- Installing ' .. name .. ' into ' .. install_path .. ' ---')
      os.execute('git clone --depth 1 ' .. dep .. ' ' .. install_path)
      for_each_dep(install_path)
    end

    if type(dep) == "table" then
      print('\n--- Installing ' .. name .. ' into ' .. install_path .. ' ---')
      local branch = dep.branch or 'main'
      local command = 'git clone --depth 1 --branch ' ..
          branch .. ' ' .. dep.url .. ' ' .. fs.join({ install_path, name })
      os.execute(command)

      if dep.postInstall then
        dep.postInstall(cb_context)
      end

      for_each_dep(install_path)
    end

    if type(dep) == "function" then
      print('\n--- Running function for ' .. name)
      dep(cb_context)
    end
  else
    if not cli.context.checked_deps[name] then
      print('The dependency "' .. name .. '" is already installed.')
      cli.context.checked_deps[name] = true
      for_each_dep(install_path)
    end
  end
end

local original_add_deps_to_path = utils.add_deps_to_path
add_deps_to_path = function()
  original_add_deps_to_path(cli, fs)
end
utils.add_deps_to_path = add_deps_to_path

cb_context = {
  fs = fs,
  utils = utils,
}

local handler = cli:get_op(cli.context.op)
if handler then
  handler.cb()
end
