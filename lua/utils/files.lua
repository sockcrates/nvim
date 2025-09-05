local M = {}

--- Checks a directory for the presence of a file.
---
--- @param dir string The directory to check.
--- @param file string The file to look for.
--- @return boolean
function M.dir_contains_file(dir, file)
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

--- Checks a directory for the presence of a set of files.
---
--- @param dir string The directory to check.
--- @param files table A table of strings, where each string is a file to look
--- for.
function M.dir_contains_set_of_files(dir, files)
  if vim.fn.isdirectory(dir) == 1 then
    local dir_files = vim.fn.readdir(dir)
    local file_set = {}
    for _, f in ipairs(dir_files) do
      file_set[f] = true
    end

    for _, f in ipairs(files) do
      if file_set[f] then
        return true
      end
    end
  end
  return false
end

return M
