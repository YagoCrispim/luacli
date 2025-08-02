---@class DepsFile
return {
  name = '',
  version = 0,
  scripts = {
    start = {
      desc = 'Start project',
      cb = function(params)
        -- Add all the dependencies to the package.path
        -- package.cpath must be loaded manually
        params.utils.add_deps_to_path()

        -- requires de entrypoint file
        -- require(entrypoint.lua)
      end
    },
    test = {
      desc = 'Run project tests',
      cb = function()
        error('Not implemented.')
      end
    },
  },
  dev_dependencies = {
    placeholder = 'https://github.com/placeholder/placeholder.git',
    luabundler = {
      src = 'luabundler',
      url = 'https://github.com/YagoCrispim/luabundler.git',
    },
    moontest = {
      src = 'moontest',
      url = 'https://github.com/YagoCrispim/moontest',
      postInstall = function(params)
        -- any lua code...
        -- os.execute("sudo apt install ...")
        -- os.execute("./my_script.sh")
        -- os.execute("./my_script.bat")
        -- os.execute("./my_script.ps1")
        -- etc
      end
    },
  },
}
