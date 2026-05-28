local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  -- REMOVED THE OLD v2 COMMIT HASH TO ALLOW V3 TO DOWNLOAD
}

function M.config()
  local icons = require "user.icons"

  require("ibl").setup {
    indent = { 
      char = icons.ui.LineMiddle, 
    },
    whitespace = {
      remove_blankline_trail = true,
    },
    exclude = {
      filetypes = {
        "help",
        "startify",
        "dashboard",
        "lazy",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "text",
      },
      buftypes = { "terminal", "nofile" },
    },
    scope = { 
      enabled = true,
      char = icons.ui.LineMiddle,
      show_start = true,
      show_end = false,
    },
  }
end

return M

