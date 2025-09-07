return {
  "danymat/neogen",
  config = function()
    require("neogen").setup {
      snippet_engine = "luasnip",
      languages = {
        go = {
          template = {
            annotation_convention = "godoc",
          },
        },
        lua = {
          template = {
            annotation_convention = "ldoc",
          },
        },
        javascript = {
          template = {
            annotation_convention = "jsdoc",
          },
        },
        typescript = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
      },
    }
  end
}
