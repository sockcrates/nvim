local M = {} -- M is a common convention for a module's public interface

local cached_git_root = nil -- This will store the result after the first call

--- Finds the nearest Git repository root by executing 'git rev-parse --show-toplevel'.
--- The result is cached after the first successful execution.
---
--- @return string|nil The absolute path to the Git root, or nil if not found.
function M.find_nearest_git_root()
  -- If we've already found and cached the git root, return it immediately
  if cached_git_root ~= nil then
    return cached_git_root
  end

  -- If not cached, proceed to find it
  local handle = io.popen('git rev-parse --show-toplevel 2>/dev/null', 'r')
  if not handle then
    -- Store nil if command fails, so we don't try again (unless you want to retry later)
    -- For now, we'll cache the nil result to prevent repeated attempts.
    cached_git_root = nil
    return nil
  end

  local git_root = handle:read '*l'
  handle:close()

  if git_root and git_root ~= '' then
    git_root = git_root:gsub('%s*$', '')

    local stat = vim.loop.fs_stat(git_root)
    if stat and stat.type == 'directory' then
      cached_git_root = git_root -- Cache the found root
      return git_root
    end
  end

  -- If we reach here, it means no valid git root was found.
  -- Cache nil to avoid re-running the command unnecessarily.
  cached_git_root = nil
  return nil
end

return M
