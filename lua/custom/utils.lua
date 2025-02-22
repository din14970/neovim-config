-- Remove trailing white space, see https://vi.stackexchange.com/a/456/15292
vim.cmd([[
  function! utils#StripTrailingWhitespaces() abort
    let l:save = winsaveview()
    keeppatterns %s/\v\s+$//e
    call winrestview(l:save)
  endfunction
]])

-- Create command alias safely, see https://stackoverflow.com/q/3878692/6064933
-- The following two functions are taken from answer below on SO:
-- https://stackoverflow.com/a/10708687/6064933
vim.cmd([[
  function! utils#Cabbrev(key, value) abort
    execute printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
          \ a:key, 1+len(a:key), <SID>Single_quote(a:value), <SID>Single_quote(a:key))
  endfunction
]])


vim.cmd([[
  function! s:Single_quote(str) abort
    return "'" . substitute(copy(a:str), "'", "''", 'g') . "'"
  endfunction
]])


-- Check the syntax group in the current cursor position, see
-- https://stackoverflow.com/q/9464844/6064933 and
-- https://jordanelver.co.uk/blog/2015/05/27/working-with-vim-colorschemes/
vim.cmd([[
  function! utils#SynGroup() abort
    if !exists('*synstack')
      return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  endfunction
]])


-- Generate random integers in the range [Low, High] in pure vim script,
-- adapted from https://stackoverflow.com/a/12739441/6064933
vim.cmd([[
  function! utils#RandInt(Low, High) abort
    " Use lua to generate random int. It is faster. Ref: https://stackoverflow.com/a/20157671/6064933
    call v:lua.math.randomseed(localtime())
    return v:lua.math.random(a:Low, a:High)
  endfunction
]])


-- Custom fold expr, adapted from https://vi.stackexchange.com/a/9094/15292
vim.cmd([[
  function! utils#VimFolds(lnum) abort
    " get content of current line and the line below
    let l:cur_line = getline(a:lnum)
    let l:next_line = getline(a:lnum+1)

    if l:cur_line =~# '^"{'
      return '>' . (matchend(l:cur_line, '"{*') - 1)
    endif

    if l:cur_line ==# '' && (matchend(l:next_line, '"{*') - 1) == 1
      return 0
    endif

    return '='
  endfunction
]])

-- Custom fold text, adapted from https://vi.stackexchange.com/a/3818/15292
-- and https://vi.stackexchange.com/a/6608/15292
vim.cmd([[
  function! utils#MyFoldText() abort
    let l:line = getline(v:foldstart)
    let l:fold_line_num = v:foldend - v:foldstart
    let l:fold_text = substitute(l:line, '^"{\+', '', 'g')
    let l:fill_char_num = &textwidth - len(l:fold_text) - len(l:fold_line_num) - 10
    return printf('+%s%s %s (%s L)', repeat('-', 4), l:fold_text, repeat('-', l:fill_char_num), l:fold_line_num)
  endfunction
]])


-- Toggle cursor column
vim.cmd([[
  function! utils#ToggleCursorCol() abort
    if &cursorcolumn
      set nocursorcolumn
      echo 'cursorcolumn: OFF'
    else
      set cursorcolumn
      echo 'cursorcolumn: ON'
    endif
  endfunction
]])


vim.cmd([[
  function! utils#SwitchLine(src_line_idx, direction) abort
    if a:direction ==# 'up'
      if a:src_line_idx == 1
          return
      endif
      move-2
    elseif a:direction ==# 'down'
      if a:src_line_idx == line('$')
          return
      endif
      move+1
    endif
  endfunction
]])


vim.cmd([[
  function! utils#MoveSelection(direction) abort
    " only do this if previous mode is visual line mode. Once we press some keys in
    " visual line mode, we will leave this mode. So the output of `mode()` will be
    " `n` instead of `V`. We can use `visualmode()` instead to check the previous
    " mode, see also https://stackoverflow.com/a/61486601/6064933
    if visualmode() !=# 'V'
      return
    endif

    let l:start_line = line("'<")
    let l:end_line = line("'>")
    let l:num_line = l:end_line - l:start_line + 1

    if a:direction ==# 'up'
      if l:start_line == 1
        " we can also directly use `normal gv`, see https://stackoverflow.com/q/9724123/6064933
        normal! gv
        return
      endif
      silent execute printf('%s,%smove-2', l:start_line, l:end_line)
      normal! gv
    elseif a:direction ==# 'down'
      if l:end_line == line('$')
        normal! gv
        return
      endif
      silent execute printf('%s,%smove+%s', l:start_line, l:end_line, l:num_line)
      normal! gv
    endif
  endfunction
]])


vim.cmd([[
  function! utils#Get_titlestr() abort
    let l:title_str = ''
    if g:is_linux
        let l:title_str = hostname() . '  '
    endif
    let l:title_str = l:title_str . expand('%:p:~') . '  '
    if &buflisted
      let l:title_str = l:title_str . strftime('%Y-%m-%d %H:%M',getftime(expand('%')))
    endif

    return l:title_str
  endfunction
]])


-- Check if we are inside a Git repo.
vim.cmd([[
  function! utils#Inside_git_repo() abort
    let res = system('git rev-parse --is-inside-work-tree')
    if match(res, 'true') == -1
      return v:false
    else
      " Manually trigger a specical user autocmd InGitRepo (to use it for
      " lazyloading of fugitive by packer.nvim).
      " See also https://github.com/wbthomason/packer.nvim/discussions/534.
      doautocmd User InGitRepo
      return v:true
    endif
  endfunction
]])

vim.cmd([[
  function! utils#GetGitBranch()
    let l:res = systemlist('git rev-parse --abbrev-ref HEAD')[0]
    if match(l:res, 'fatal') != -1
      return ''
    else
      return l:res
    endif
  endfunction
]])


-- Redirect command output to a register for later processing.
-- Ref: https://stackoverflow.com/q/2573021/6064933 and https://unix.stackexchange.com/q/8101/221410 .
vim.cmd([[
  function! utils#CaptureCommandOutput(command) abort
    redir @m
    execute a:command
    redir END
  endfunction
]])


-- Edit all files matching the given patterns.
vim.cmd([[
  function! utils#MultiEdit(patterns) abort
    for p in a:patterns
      for f in glob(p, 0, 1)
        execute 'edit ' . f
      endfor
    endfor
  endfunction
]])


-- see https://stackoverflow.com/questions/356126/how-can-you-automatically-remove-trailing-whitespace-in-vim#356130
vim.cmd([[
  function! utils#StripTrailingWhitespaces()
    if !&binary && &filetype != 'diff'
      let l:save = winsaveview()
      keeppatterns %s/\s\+$//e
      call winrestview(l:save)
    endif
  endfun
]])
