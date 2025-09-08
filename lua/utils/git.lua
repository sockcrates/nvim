local M = {}

local has_git_root_cached, git_root_cached = false, nil

--- Finds the nearest Git repository root or returns nil if not found.
---
--- @return string|nil
function M.find_git_ancestor()
  if has_git_root_cached == true then
    return git_root_cached
  end

  local handle = io.popen('git rev-parse --show-toplevel 2>/dev/null', 'r')
  if not handle then
    git_root_cached = nil
    has_git_root_cached = true
    return git_root_cached
  end

  local git_root = handle:read '*l'
  handle:close()

  if git_root and git_root ~= '' then
    git_root = git_root:gsub('%s*$', '')

    local stat = (vim.uv or vim.loop).fs_stat(git_root)
    if stat and stat.type == 'directory' then
      git_root_cached = git_root
      has_git_root_cached = true
      return git_root
    end
  end

  git_root_cached = nil
  has_git_root_cached = true
  return git_root_cached
end

return M
