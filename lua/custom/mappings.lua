require "nvchad.mappings"

local map = vim.keymap.set
local nomap = vim.keymap.del

-- normal mode
map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "<leader><CR>", "<cmd> noh <CR>", { desc = "no highlight" })
map("n", "<leader>y", "<cmd> %y+ <CR>", { desc = "copy whole file" })
map("n", "<leader>Q", ":<C-U>qa<CR>", { desc = "close all open buffers"})

-- resizing windows
map("n", "<A-j>", ":resize -2<CR>", { desc = "decrease window size"})
map("n", "<A-k>", ":resize +2<CR>", { desc = "increase window size"})
map("n", "<A-h>", ":vertical resize -2<CR>", { desc = "decrease window size vertical"})
map("n", "<A-l>", ":vertical resize +2<CR>", { desc = "increase window size vertical"})

-- Navigation in the location and quickfix list
-- Relevant for when using things like :grep or :lgrep when searching
-- From help: must use grep or lgrep to get these
map("n", "[l", ":lprevious<CR>", { desc = "go to previous location"})
map("n", "]l", ":lnext<CR>", { desc = "go to previous location"})
map("n", "[L", ":lfirst<CR>", { desc = "go to first jump"})
map("n", "]L", ":llast<CR>", { desc = "go to last jump"})
map("n", "[q", ":cprevious<CR>", { desc = "go to previous quickfix item"})
map("n", "]q", ":cnext<CR>", { desc = "go to next quickfix item"})
map("n", "[Q", ":cfirst<CR>", { desc = "go to first quickfix item"})
map("n", "]Q", ":clast<CR>", { desc = "go to last quickfix item"})

-- Yank from current cursor position to the end of the line (make it
-- consistent with the behavior of D, C)
map("n", "Y", "y$", { desc = "yank to end of line"})

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
map("n", "c", [["_c]], { desc = "change without putting in register"})
map("n", "C", [["_C]], { desc = "change without putting in register"})
map("n", "cc", [["_cc]], { desc = "change without putting in register"})

-- tabufline
map("n", "<A-;>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<A-,>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

map("n", "<leader>d", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

nomap("n", "<leader>x")

-- nvimtree
map("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- telescope
nomap("n", "<leader>cm")
nomap("n", "<leader>gt")
nomap("n", "<leader>fw")
map("n", "<leader>fg", "<cmd>Telescope live_grep <CR>", { desc = "telescope live grep" })
map("n", "<leader>km", "<cmd>Telescope keymaps <CR>", { desc = "telescope show keys" })
map("n", "<leader>gc", "<cmd>Telescope git_commits <CR>", { desc = "telescope git commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status <CR>", { desc = "telescope git status" })

-- nvterm
map({ "n", "t" }, "<A-t>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "terminal new vertical term" })

-- -- -- -- -- -- --

-- insert mode

-- visual mode
--
map("x", "c", [["_c]], { desc = "change without putting in register"})
-- Replace visual selection with text in register, but not contaminate the
-- register, see also https://stackoverflow.com/q/10723700/6064933.
map("x", "p", [["_c<ESC>p]], { desc = "change without putting in register"})

-- terminal mode
local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

map("t", "<Esc><Esc>", termcodes "<C-\\><C-N>", { desc = "escape terminal mode" })
