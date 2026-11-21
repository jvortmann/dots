local capture_first_paint, copied_text, fit_to, show, show_position, standby
local position = vim.api.nvim_create_namespace("copy-mode.position")

vim.o.modeline = false
vim.o.laststatus = 0
vim.o.cmdheight = 0
vim.o.termguicolors = false
vim.o.startofline = true
vim.api.nvim_set_hl(0, "Visual", { ctermfg = 8, ctermbg = 3 })

vim.keymap.set("n", "q", "<cmd>qa!<cr>")
vim.keymap.set("n", "<Esc>", "<cmd>qa!<cr>")
-- The startofline option covers gg, G, H, M, L and the page keys. j and k keep
-- the column, so they map to + and -, which still take a count and a selection.
-- A block selection keeps the plain j and k, so the block keeps its column.
for key, move in pairs({ j = "+", k = "-" }) do
  vim.keymap.set({ "n", "x" }, key, function() return vim.fn.mode() == "\22" and key or move end, { expr = true })
end
-- The buffer is a terminal buffer, so i, a, I and A would enter Terminal mode,
-- where q and Esc do not close copy mode.
vim.api.nvim_create_autocmd("TermEnter", { command = "stopinsert" })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.system({ "pbcopy" }, { stdin = copied_text(vim.v.event) }):wait()
    vim.schedule(function() vim.cmd("qa!") end)
  end,
})

-- The mod calls it through the server of this nvim. The mod shows this
-- terminal when it returns.
function _G.copy_mode_open(source)
  standby("")
  local size = vim.system({ "hc", "get", "--json", source })
  local paint = capture_first_paint(source)
  if paint == "" then vim.cmd("qa!") end
  fit_to(size:wait(500))
  show(paint)
  show_position()
  vim.api.nvim_create_autocmd({ "CursorMoved", "WinScrolled" }, { callback = show_position })
end

function capture_first_paint(source)
  local chunks, quiet, done = {}, vim.uv.new_timer(), false
  local attach = vim.system({ "hc", "attach", "--observe", "--history", "10000", source }, {
    stdout = function(_, data)
      if not data or done then return end
      table.insert(chunks, data)
      quiet:start(30, 0, function() done = true end)
    end,
  }, function() done = true end)
  vim.wait(3000, function() return done end, 5)
  attach:kill("sigterm")
  return table.concat(chunks)
end

-- A program such as pi pads each line to the width of the pane with spaces.
-- The copy removes the spaces at the end of a line, so a blank line copies as
-- an empty line. A selection that ends inside a line keeps its spaces.
function copied_text(yank)
  local lines = vim.deepcopy(yank.regcontents)
  local region = vim.fn.getregionpos(vim.fn.getpos("'["), vim.fn.getpos("']"), { type = yank.regtype:sub(1, 1) })
  for i, span in ipairs(region) do
    local start = span[1]
    if not vim.fn.getline(start[2]):sub(start[3] + #lines[i]):find("%S") then lines[i] = lines[i]:gsub("%s+$", "") end
  end
  return table.concat(lines, "\n")
end

function fit_to(size)
  local ok, terminal = pcall(vim.json.decode, size.stdout or "")
  if ok and type(terminal) == "table" and terminal.cols and terminal.rows then
    vim.o.columns, vim.o.lines = terminal.cols, terminal.rows
  end
end

function show(paint)
  local height = vim.api.nvim_win_get_height(0)
  -- The first paint of `hc attach --observe` has a run of line feeds before the
  -- clear of the screen (ESC[H ESC[2J). Make the run as long as the window. A
  -- longer run shows blank lines between the history and the screen. A shorter
  -- one lets the clear remove the last history line.
  paint = paint:gsub("\n+(\27%[H\27%[2J)", string.rep("\n", height) .. "%1")
  local terminal = vim.api.nvim_open_term(0, {})
  local tick = vim.b.changedtick
  vim.api.nvim_chan_send(terminal, paint)
  -- The buffer gets the lines at the next terminal refresh of nvim, so wait
  -- for the change.
  vim.wait(1000, function() return vim.b.changedtick ~= tick end, 1)
  local row = 1
  for r in paint:gmatch("\27%[(%d+);%d+H") do row = tonumber(r) end
  local top = vim.api.nvim_buf_line_count(0) - height + 1
  vim.fn.winrestview({ topline = top, lnum = top + row - 1 })
  vim.cmd("normal! ^")
end

-- Shows the position of the cursor at the top right: the lines between the
-- cursor line and the last line with text, out of the lines between the first
-- line and that last line. The first line reads [N/N]. The last line with text
-- and the blank rows below it, as after a clear, read [0/N]. The chip is
-- virtual text and not a float, because a headless test sees only the window
-- grid, and a yank skips it. On a full top line it covers the end, as in tmux.
-- WinScrolled moves the chip to the new top line when the view scrolls and the
-- cursor stays.
function show_position()
  local last = vim.fn.prevnonblank(vim.api.nvim_buf_line_count(0))
  vim.api.nvim_buf_clear_namespace(0, position, 0, -1)
  vim.api.nvim_buf_set_extmark(0, position, vim.fn.line("w0") - 1, 0, {
    virt_text = { { ("[%d/%d]"):format(math.max(0, last - vim.fn.line(".")), math.max(0, last - 1)), "Visual" } },
    virt_text_pos = "right_align",
  })
end

-- The label tells the mod where the server of this nvim listens. An empty
-- server removes the label.
function standby(server)
  vim.system({ "hc", "label", vim.env.HC_TERMINAL_ID, "copy-mode.standby=" .. server })
end

standby(vim.v.servername)
