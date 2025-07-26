---@generic A, B
---@param cond boolean
---@param if_true `A`
---@param if_false `B`
---@return `A` | `B`
local function tern(cond, if_true, if_false)
  if cond then
    return if_true
  end
  return if_false
end

---@param cli LuaCLI
---@param fs LuaCLI_FS
---@return nil
local function add_deps_to_path(cli, fs)
  local should_add_devdeps = false
  local deps_dir = fs.ls(fs.join({ fs.cwd, cli.context.config.dep_folder_name }))
  local deps_file = require('deps')

  -- TODO: error if not found

  for _, dir_name in pairs(deps_dir) do
    if dir_name == '_dev' then
      should_add_devdeps = true
    else
      local src_dir = nil

      if deps_file.dependencies[dir_name].src then
        src_dir = dir_name
      end

      local package_path = fs.join({ fs.cwd, cli.context.config.dep_folder_name, dir_name, src_dir, '?.lua' })
      package.path = package.path .. ';' .. package_path
    end
  end

  if should_add_devdeps then
    local dev_deps_dir = fs.ls(fs.join({ fs.cwd, cli.context.config.dep_folder_name, '_dev' }))

    for _, dir_name in pairs(dev_deps_dir) do
      local src_dir = nil

      if deps_file.dev_dependencies[dir_name].src then
        src_dir = dir_name
      end

      local package_path = fs.join({ fs.cwd, cli.context.config.dep_folder_name, '_dev', dir_name, src_dir, '?.lua' })
      package.path = package.path .. ';' .. package_path
    end
  end
end

return {
  tern = tern,
  add_deps_to_path = add_deps_to_path,
}
