local utils = require 'cli.utils'

---@class LuaCLI_FS
local FS = {
  cwd = os.getenv("PWD") or io.popen("cd"):read() --[[ @as string ]],
  separator = utils.tern(package.config:sub(1, 1) == '/', '/', '\\') --[[ @as PathSeparator ]],
}

function FS.ls(path)
  local files = {}
  for file in io.popen("ls " .. path):lines() do
    table.insert(files, file)
  end
  return files
end

function FS.join(paths)
  local result = ''

  for _, v in pairs(paths) do
    if result == '' then
      result = v
    else
      result = result .. FS.separator .. v
    end
  end

  result = result:gsub('\n', '')
  return result
end

function FS.exists(path, is_file)
  local command = ''
  local res_to_match = ''
  local read_all_flag = ''

  if OSNAME == OSNAMES.nix then
    local arch_type = ' -d '
    if is_file then arch_type = ' -f ' end
    command = 'if [ ' .. arch_type .. '"' .. path .. '" ]; then echo "1"; else echo "0"; fi'
    res_to_match = '1'
    read_all_flag = '*a'
  end

  if OSNAME == OSNAMES.windows then
    command = 'IF EXIST "' .. path .. '" echo 1 ELSE echo 0'
    command = 'IF EXIST "' .. path .. '" (echo 1) ELSE (echo 0)'
    res_to_match = '1'
    read_all_flag = '*l'
  end

  local handle = io.popen(command)

  if not handle then
    error('Could not execute: ' .. command)
  end

  local result = handle:read(read_all_flag)
  handle:close()

  return result:match(res_to_match)
end

function FS.read_file(file_path)
  if not FS.exists(file_path, true) then
    return nil
  end

  local read_tool = ''

  if OSNAME == 'windows' then
    read_tool = 'type'
  else
    read_tool = 'cat'
  end

  local command = read_tool .. ' "' .. file_path .. '"'
  local handle = io.popen(command)

  if not handle then
    error('Could not execute: ' .. command)
  end

  local result = handle:read("*a")
  handle:close()

  return result
end

return FS
