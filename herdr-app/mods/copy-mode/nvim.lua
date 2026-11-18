vim.keymap.set("n", "q", "<cmd>qa!<cr>")
vim.keymap.set("n", "<Esc>", "<cmd>qa!<cr>")

vim.api.nvim_create_autocmd("BufWinEnter", { once = true, command = "normal! G0" })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.system({ "pbcopy" }, { stdin = table.concat(vim.v.event.regcontents, "\n") }):wait()
    vim.schedule(function() vim.cmd("qa!") end)
  end,
})
