" Handles all stderr from the Clojure process.
" Simply prints it in red.
function! s:OnStderr(jobid, lines, source) dict
  echohl ErrorMsg
  for line in a:lines
    if len(line) > 0
      echomsg line
    endif
  endfor
  echo "Error from Conjure, see :messages for more"
  echohl None
endfunction

" Start up the Clojure process if we haven't already.
if ! exists("s:jobid")
  let s:jobid = jobstart("clojure -m conjure.main", {
  \  "rpc": v:true,
  \  "cwd": resolve(expand("<sfile>:p:h") . "/.."),
  \  "on_stderr": function("s:OnStderr")
  \})
endif

" Helper Lua functions to avoid sending too much
" data back and forth over RPC on each command.
lua << EOF
-- Find the log window and buffer if they exist.
local function find_log (log_buf_name)
  local let tabpage = vim.api.nvim_get_current_tabpage()
  local let wins = vim.api.nvim_tabpage_list_wins(tabpage)

  for _, win in ipairs(wins) do
    local let buf = vim.api.nvim_win_get_buf(win)
    local let buf_name = vim.api.nvim_buf_get_name(buf)

    if buf_name == log_buf_name then
      return {win = win, buf = buf}
    end
  end

  return nil
end

-- Global table of helper functions for Conjure to call.
conjure_utils = {}

-- Find or create (and then find again) the log window and buffer.
conjure_utils.upsert_log = function (log_buf_name, width, focus)
  local let result = find_log(log_buf_name)
  if result then
    if focus == true then
      vim.api.nvim_set_current_win(result.win)
    end

    vim.api.nvim_win_set_width(result.win, width)

    return result
  else
    vim.api.nvim_command("botright " .. width .. "vsplit " .. log_buf_name)
    vim.api.nvim_command("setlocal winfixwidth")
    vim.api.nvim_command("setlocal buftype=nofile")
    vim.api.nvim_command("setlocal bufhidden=hide")
    vim.api.nvim_command("setlocal nowrap")
    vim.api.nvim_command("setlocal noswapfile")

    if focus ~= true then
      vim.api.nvim_command("wincmd p")
    end

    return find_log(log_buf_name)
  end
end
EOF

" Map Neovim commands to RPC notify calls.
command! -nargs=1 DevAdd call rpcnotify(s:jobid, "add", <q-args>)
command! -nargs=1 DevRemove call rpcnotify(s:jobid, "remove", <q-args>)
command! -nargs=1 DevEval call rpcnotify(s:jobid, "eval", <q-args>)
command! -nargs=0 DevLog call rpcnotify(s:jobid, "log")
