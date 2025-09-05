local M = {}

local eslint_config_files = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.json',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  'package.json', -- eslint config can be in package.json under "eslintConfig" field
}

--- Searches for eslint configuration files in the nearest git repository root.
---
--- @return boolean True if any eslint config file is found, false otherwise.
local function find_eslint()
  local files = require 'utils.files'
  local git = require 'utils.git'

  local git_root = git.find_nearest_git_root()
  if git_root then
    return files.dir_contains_set_of_files(git_root, eslint_config_files)
  end
  return false
end

function M.has_linter_config_file()
  return find_eslint() ~= false
end

return M
