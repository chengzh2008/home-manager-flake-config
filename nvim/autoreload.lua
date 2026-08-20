-- Auto-refresh buffers when the underlying file changes on disk.
-- LazyVim enables 'autoread', but Neovim only re-reads a file on certain
-- events. Running :checktime on focus/buffer/cursor-idle events makes the
-- reload actually happen, and notifies when a file changed externally.
return {
  "LazyVim/LazyVim",
  init = function()
    vim.opt.autoread = true

    local group = vim.api.nvim_create_augroup("auto_reload_files", { clear = true })

    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
      group = group,
      pattern = "*",
      callback = function()
        -- Skip special buffers (terminals, prompts, etc.) and unnamed buffers.
        if vim.bo.buftype ~= "" or vim.fn.expand("%") == "" then
          return
        end
        if vim.fn.mode():match("^[ic]") then
          return
        end
        vim.cmd("checktime")
      end,
    })

    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      group = group,
      pattern = "*",
      callback = function()
        vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
      end,
    })
  end,
}
