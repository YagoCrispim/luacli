-- file: bundle.lua
local bundler = require 'bundler'

-- Join path pieces with corresponding separator
local function join_path(paths, separator)
  local result = ''

  for _, v in pairs(paths) do
    if result == '' then
      result = v
    else
      result = result .. separator .. v
    end
  end

  result = result:gsub('\n', '')
  return result
end

-- Get current workdir and path separator dynamically
local cwd = os.getenv("PWD") or io.popen("cd"):read()
local separator = '/'
if not package.config:sub(1, 1) == '/' then
  separator = '\\'
end

-- Mount output path and lib entrypoint dynamically
local out = join_path({ cwd, 'cli.lua' }, separator)
local entrypoint = join_path({ 'cli', 'cli.lua' }, separator)
bundler:bundle(cwd, entrypoint, out)
