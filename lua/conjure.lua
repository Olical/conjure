local conjure = {}

-- Believe it or not, this'll check if a string ends with a given suffix.
local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

-- Find the log window and buffer if they exist.
local function find_log (log_buf_name)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)

  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)

    -- OSX symlinks /tmp to /private/tmp so we check the suffix instead.
    if ends_with(buf_name, log_buf_name) then
      return {win = win, buf = buf}
    end
  end

  return nil
end


-- Returns the absolute number of lines
local function get_log_window_size(size, direction)
  local percentage_size = (size == "small") and
    vim.api.nvim_get_var("conjure_log_size_small") or
    vim.api.nvim_get_var("conjure_log_size_large")

  local vim_window_size = (direction == "horizontal") and
    vim.api.nvim_get_option("lines") or
    vim.api.nvim_get_option("columns")

  return math.floor(vim_window_size * (percentage_size / 100))
end


-- Find or create (and then find again) the log window and buffer.
function conjure.upsert_log(log_buf_name, size, focus, resize)
  local direction = vim.api.nvim_get_var("conjure_log_direction")
  local size_abs = get_log_window_size(size, direction)

  local result = find_log(log_buf_name)
  if result then
    if focus == true then
      vim.api.nvim_set_current_win(result.win)
    end

    if resize == true then
      if direction == "horizontal" then
        vim.api.nvim_win_set_height(result.win, size_abs)
      else
        vim.api.nvim_win_set_width(result.win, size_abs)
      end
    end

    return result
  else
    local split = (direction == "horizontal") and "split" or "vsplit"
    vim.api.nvim_command("botright " .. size_abs .. split .. " " .. log_buf_name)
    vim.api.nvim_command("setlocal winfixwidth")
    vim.api.nvim_command("setlocal buftype=nofile")
    vim.api.nvim_command("setlocal bufhidden=hide")
    vim.api.nvim_command("setlocal nowrap")
    vim.api.nvim_command("setlocal noswapfile")
    vim.api.nvim_command("setlocal nobuflisted")
    vim.api.nvim_command("setlocal nospell")
    vim.api.nvim_command("setlocal foldmethod=marker")
    vim.api.nvim_command("setlocal foldlevel=0")
    vim.api.nvim_command("setlocal foldmarker={{{,}}}")

    if focus ~= true then
      vim.api.nvim_command("wincmd p")
    end

    return find_log(log_buf_name)
  end
end

-- Close the log window if it's open in the current tabpage.
function conjure.close_log (log_buf_name)
  local result = find_log(log_buf_name)
  if result then
    local win_number = vim.api.nvim_win_get_number(result.win)
    vim.api.nvim_command(win_number .. "close!")
  end
end

return conjure
