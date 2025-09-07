local M = {}

local function exists_in_package_json(dir, key)
  local package_json_path = dir .. '/package.json'
  local file = io.open(package_json_path, 'r')
  if file then
    local content = file:read '*a'
    file:close()
    if content and content:match('"' .. key .. '"%s*:') then
      return true
    end
  end
  return false
end

local eslint_config_files = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.json',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  'eslint.config.js',
  'eslint.config.cjs',
  'eslint.config.mjs',
  'eslint.config.ts',
  'eslint.config.cts',
  'eslint.config.mts',
}

local function eslint_exists_in_dir(dir)
  local files = require 'utils.files'

  if files.dir_contains_set_of_files(dir, eslint_config_files) then
    return true
  end

  if exists_in_package_json(dir, 'eslintConfig') then
    return true
  end

  return false
end

local has_eslint_cached = nil

--- Searches for eslint configuration files in the current directory, nearest
--- git root, or an eslint installation.
---
--- @return boolean True if any eslint config file is found, false otherwise.
function M.find_eslint()
  if has_eslint_cached ~= nil then
    return has_eslint_cached
  end

  if eslint_exists_in_dir(vim.fn.getcwd()) then
    has_eslint_cached = true
    return true
  end

  local git = require 'utils.git'
  local git_root = git.find_nearest_git_root()
  if git_root then
    if eslint_exists_in_dir(git_root) then
      has_eslint_cached = true
      return true
    end
  end

  if vim.fn.executable 'eslint' == 1 or vim.fn.executable 'eslint_d' then
    has_eslint_cached = true
    return true
  end

  has_eslint_cached = false
  return false
end

local biome_config_files = {
  'biome.json',
  'biome.jsonc',
}

local has_biome_cached = nil

--- Searches for biome configuration files in the current directory or nearest
--- git root.
---
--- @return boolean True if any biome config file is found, false otherwise.
function M.find_biome()
  if has_biome_cached ~= nil then
    return has_biome_cached
  end

  local files = require 'utils.files'
  if files.dir_contains_set_of_files(vim.fn.getcwd(), biome_config_files) then
    has_biome_cached = true
    return true
  end

  local git = require 'utils.git'
  local git_root = git.find_nearest_git_root()
  if git_root then
    if files.dir_contains_set_of_files(git_root, biome_config_files) then
      has_biome_cached = true
      return true
    end
  end

  has_biome_cached = false
  return false
end

local prettier_config_files = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.json5',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  '.prettierrc.toml',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
  'prettier.config.ts',
  'prettier.config.cts',
  'prettier.config.mts',
}

local function prettier_exists_in_dir(dir)
  local files = require 'utils.files'

  if files.dir_contains_set_of_files(dir, prettier_config_files) then
    return true
  end

  if exists_in_package_json(dir, 'prettier') then
    return true
  end

  return false
end

local has_prettier_cached = nil

--- Searches for prettier configuration files in the current directory or
--- nearest git root.
---
--- @return boolean True if any prettier config file is found, false otherwise.
function M.find_prettier()
  if has_prettier_cached ~= nil then
    return has_prettier_cached
  end

  if prettier_exists_in_dir(vim.fn.getcwd()) then
    has_prettier_cached = true
    return true
  end

  local git = require 'utils.git'
  local git_root = git.find_nearest_git_root()
  if git_root then
    if prettier_exists_in_dir(git_root) then
      has_prettier_cached = true
      return true
    end
  end

  if
      vim.fn.executable 'prettier' == 1 or vim.fn.executable 'prettierd' == 1
  then
    has_prettier_cached = true
    return true
  end

  has_prettier_cached = false
  return false
end

local has_venv_path_cached, venv_path_cached = false, nil

local function get_venv_path()
  if has_venv_path_cached == true then
    return venv_path_cached
  end
  if vim.fn.executable('pipenv') == 1 then
    -- Look for flake8 in a virtual environment
    local output = vim.fn.systemlist("pipenv --venv")
    local venv = output[#output]
    if vim.fn.isdirectory(venv) == 1 then
      has_venv_path_cached = true
      venv_path_cached = venv
      return venv
    end
  end
  has_venv_path_cached = true
  return nil
end

local has_flake8_cached, flake_8_location_cached = nil, nil

--- Searches for flake8 in the system or in a pipenv virtual environment.
---
--- @return boolean, string|nil
function M.find_flake8()
  if has_flake8_cached ~= nil then
    return has_flake8_cached, flake_8_location_cached
  end

  if vim.fn.executable 'flake8' == 1 then
    flake_8_location_cached = vim.fn.exepath 'flake8'
    has_flake8_cached = true
    return has_flake8_cached, flake_8_location_cached
  end

  local venv = get_venv_path()
  if venv ~= nil then
    flake_8_location_cached = venv .. '/bin/flake8'
    has_flake8_cached = vim.fn.filereadable(flake_8_location_cached) == 1
    return has_flake8_cached, flake_8_location_cached
  end

  has_flake8_cached = false
  flake_8_location_cached = nil
  return has_flake8_cached, flake_8_location_cached
end

local has_black_cached, black_location_cached = nil, nil

--- Searches for black in the system or in a pipenv virtual environment.
---
--- @return boolean, string|nil
function M.find_black()
  if has_black_cached ~= nil then
    return has_black_cached, black_location_cached
  end

  if vim.fn.executable 'black' == 1 then
    black_location_cached = vim.fn.exepath 'black'
    has_black_cached = true
    return has_black_cached, black_location_cached
  end

  local venv = get_venv_path()
  if venv ~= nil then
    black_location_cached = venv .. '/bin/black'
    has_black_cached = vim.fn.filereadable(black_location_cached) == 1
    if has_black_cached then
      return has_black_cached, black_location_cached
    end
  end

  has_black_cached = false
  black_location_cached = nil
  return has_black_cached, black_location_cached
end

local has_isort_cached, isort_location_cached = nil, nil

--- Searches for black in the system or in a pipenv virtual environment.
---
--- @return boolean, string|nil
function M.find_isort()
  if has_isort_cached ~= nil then
    return has_isort_cached, isort_location_cached
  end

  if vim.fn.executable 'isort' == 1 then
    isort_location_cached = vim.fn.exepath 'isort'
    has_isort_cached = true
    return has_isort_cached, isort_location_cached
  end

  local venv = get_venv_path()
  if venv ~= nil then
    isort_location_cached = venv .. '/bin/isort'
    has_isort_cached = vim.fn.filereadable(isort_location_cached) == 1
    if has_isort_cached then
      return has_isort_cached, isort_location_cached
    end
  end

  has_isort_cached = false
  isort_location_cached = nil
  return has_isort_cached, isort_location_cached
end

return M
