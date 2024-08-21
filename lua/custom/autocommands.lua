-- Autocommands (happen automatically upon some event)

-- require("custom.utils")

-- do not use number and relative number or spelling for terminal, directly go to insert mode
local term_settings = vim.api.nvim_create_augroup("term_settings", { clear = true })
vim.api.nvim_create_autocmd({"TermOpen"}, {
  pattern = '*',
  group = term_settings,
  command = [[setlocal norelativenumber nonumber nospell timeoutlen=300]],
})
vim.api.nvim_create_autocmd({"TermOpen"}, {
  pattern = '*',
  group = term_settings,
  command = "startinsert",
})


-- ignore case in command line mode
local dynamic_smartcase = vim.api.nvim_create_augroup("dynamic_smartcase", { clear = true })
vim.api.nvim_create_autocmd({"CmdLineEnter"}, {
  pattern = ':',
  group = dynamic_smartcase,
  command = "set nosmartcase",
})
vim.api.nvim_create_autocmd({"CmdLineLeave"}, {
  pattern = ':',
  group = dynamic_smartcase,
  command = "set smartcase",
})


-- Return to last edit position when opening a file
local resume_edit_position = vim.api.nvim_create_augroup("resume_edit_position", { clear = true })
vim.api.nvim_create_autocmd({"BufReadPost"}, {
  pattern = '*',
  group = resume_edit_position,
  command = "if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") && &ft !~# 'commit' | execute \"normal! g`\\\"zvzz\" | endif"
})


-- Automatically reload the file if it is changed outside of Nvim, see
-- https://unix.stackexchange.com/a/383044/221410. It seems that `checktime`
-- command does not work in command line. We need to check if we are in command
-- line before executing this command. See also
-- https://vi.stackexchange.com/a/20397/15292.
local auto_read = vim.api.nvim_create_augroup("auto_read", { clear = true })
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  pattern = '*',
  group = auto_read,
  command = "if mode() == 'n' && getcmdwintype() == '' | checktime | endif",
})
vim.api.nvim_create_autocmd({"FileChangedShellPost"}, {
  pattern = '*',
  group = auto_read,
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded!' | echohl None",
})


local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })
vim.api.nvim_create_autocmd({"BufEnter", "FocusGained", "InsertLeave", "WinEnter"}, {
  pattern = '*',
  group = numbertoggle,
  command = [[ if &nu | set rnu | endif ]],
})
vim.api.nvim_create_autocmd({"BufLeave", "FocusLost", "InsertEnter", "WinLeave"}, {
  pattern = '*',
  group = numbertoggle,
  command = [[ if &nu | set nornu | endif ]],
})


-- when yanking highlight the text
vim.api.nvim_create_autocmd({"TextYankPost"}, {
  pattern = '*',
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout=300, on_visual=false}) end,
})

-- Quit Nvim if we have only one window, and its filetype match our pattern.
local quit_current_win = function()
  vim.cmd([[
    let quit_filetypes = ['qf', 'vista']
    let buftype = getbufvar(bufnr(), '&filetype')
    if winnr('$') == 1 && index(quit_filetypes, buftype) != -1
      quit
    endif
  ]])
end


local auto_close_win = vim.api.nvim_create_augroup("auto_close_win", { clear = true })
vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = '*',
  group = auto_close_win,
  callback = quit_current_win,
})


-- " remove trailing whitespace on save, see https://stackoverflow.com/questions/356126/how-can-you-automatically-remove-trailing-whitespace-in-vim#356130
-- autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call utils#StripTrailingWhitespaces()
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})


-- initial vim open set-up
local initialsetup = vim.api.nvim_create_augroup("initialsetup", { clear = true })
vim.api.nvim_create_autocmd({"VimEnter"}, {
  pattern = '*',
  group = initialsetup,
  command = "NvimTreeToggle",
})
vim.api.nvim_create_autocmd({"VimEnter"}, {
  pattern = '*',
  group = initialsetup,
  command = "wincmd l",
})
