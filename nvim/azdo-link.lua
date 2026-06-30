-- Plugin spec: keymaps to copy/open a web code link (Azure DevOps / GitHub) for
-- the current line or visual selection. All logic lives in the `codelink` module
-- (nvim/lua/codelink.lua) so it can be unit tested.
local M = require("codelink")

return {
  "LazyVim/LazyVim",
  keys = {
    { "<leader>gA", function() M.copy(false) end, mode = "n", desc = "Code link: copy line" },
    { "<leader>gA", function() M.copy(true) end, mode = "x", desc = "Code link: copy selection" },
    { "<leader>gO", function() M.open(false) end, mode = "n", desc = "Code link: open line" },
    { "<leader>gO", function() M.open(true) end, mode = "x", desc = "Code link: open selection" },
  },
}
