## README for LuaCLI Project

### Overview

**LuaCLI** is a command-line interface (CLI) tool that simplifies project setup, dependency management, and task automation for Lua projects. With LuaCLI, users can easily initialize new projects, install required dependencies, and execute scripts defined in a `deps.lua` file. This tool enhances the development experience by automating repetitive tasks and providing a clear structure for managing project scripts.

### Features

- **Project Initialization**: Quickly create a `deps.lua` file and a `.gitignore` file to set up your project.
- **Dependency Installation**: Automatically install both project and development dependencies specified in the `deps.lua` file.
- **Script Execution**: Run defined scripts with simple commands, making it easy to automate tasks.

### Installation

To get started with LuaCLI, ensure you have Lua installed on your system. You can download it from [the official Lua website](https://www.lua.org/download.html).

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Initialize the CLI tool:
   ```bash
   lua cli.lua init
   ```

### Usage

LuaCLI provides three primary commands: `init`, `install`, and `run`.

#### Command: `init`

Sets up a new project by creating a `deps.lua` file and a `.gitignore` file.

```bash
lua cli.lua init
```

#### Command: `install`

Installs the dependencies listed in the `deps.lua` file.

```bash
lua cli.lua install
```

#### Command: `run`

Executes a specific script defined in the `deps.lua` file.

```bash
lua cli.lua run <script_name>
```

### Example Usage

To initialize a new project, run:

```bash
lua cli.lua init
```

To install dependencies, run:

```bash
lua cli.lua install
```

To run a specific script, use:

```bash
lua cli.lua run <script_name>
```

### Example `deps.lua` File

Here’s a complete example of a `deps.lua` file that you can use as a template for your projects:

```lua
---@class DepsFile
return {
  name = 'MyProject',
  version = 1.0,
  scripts = {
    start = {
      desc = 'Start project',
      cb = function(params)
        params.utils.add_deps_to_path()
        require('entrypoint')
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
    luabundler = {
      -- Lua bundle project main directory
      src = 'luabundler',
      url = 'https://github.com/YagoCrispim/luabundler.git',
    },
    moontest = {
      -- moontest main directory
      src = 'moontest',
      url = 'https://github.com/YagoCrispim/moontest',
      postInstall = function(params)
        os.execute("sudo apt install some-package")
        os.execute("./setup_script.sh")
      end
    },
  },
}
```

### Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

### License

This project is licensed under the MIT License. See the LICENSE file for more details.
