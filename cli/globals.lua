---@enum OSNAME
OSNAMES = {
  nix = 'nix',
  windows = 'windows'
}
---@type OSNAME
OSNAME = nil

local function load_osname()
  if package.config:sub(1, 1) == '/' then
    OSNAME = OSNAMES.nix
  else
    OSNAME = OSNAMES.windows
  end
end

load_osname()
