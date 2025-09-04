local M = {}

--- Checks a directory for the presence of a file.
---
--- @param dir string The directory to check.
--- @param file string The file to look for.
--- @return boolean
function M.dir_contains(dir, file)
  if vim.fn.isdirectory(dir) == 1 then
    local files = vim.fn.readdir(dir)
    for _, f in ipairs(files) do
      if f == file then
        return true
      end
    end
  end
  return false
end

return M
