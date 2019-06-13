local conjure = {}

-- Believe it or not, this'll check if a string ends with a given suffix.
local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

-- Find the log window and/or buffer if they exist.
local function find_log(log_buf_name)
  local result = {}
  local buf = vim.api.nvim_call_function("bufnr", {log_buf_name .. "$"})

  if buf ~= -1 and vim.api.nvim_buf_line_count(buf) > 0 then
    result.buf = buf

    local tabpage = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)

    for _, win in ipairs(wins) do
      if vim.api.nvim_win_get_buf(win) == buf then
        result.win = win
        return result
      end
    end
  end

  return result
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
function conjure.upsert_log(log_buf_name, size, focus, resize, open)
  local direction = vim.api.nvim_get_var("conjure_log_direction")
  local size_abs = get_log_window_size(size, direction)
  local match = find_log(log_buf_name)

  if match.win and open then
    if focus == true then
      vim.api.nvim_set_current_win(match.win)
    end

    if resize == true then
      if direction == "horizontal" then
        vim.api.nvim_win_set_height(match.win, size_abs)
      else
        vim.api.nvim_win_set_width(match.win, size_abs)
      end
    end

    return match
  elseif match.buf and not open then
    return match
  else
    local split = (direction == "horizontal") and "split" or "vsplit"

    -- Keep the window small if we're just creating it for setlocal calls.
    local size_abs = open and size_abs or 0

    vim.api.nvim_command("botright " .. size_abs .. split .. " " .. log_buf_name)
    vim.api.nvim_command("setlocal winfixwidth")
    vim.api.nvim_command("setlocal winfixheight")
    vim.api.nvim_command("setlocal buftype=nofile")
    vim.api.nvim_command("setlocal bufhidden=hide")
    vim.api.nvim_command("setlocal nowrap")
    vim.api.nvim_command("setlocal noswapfile")
    vim.api.nvim_command("setlocal nobuflisted")
    vim.api.nvim_command("setlocal nospell")
    vim.api.nvim_command("setlocal foldmethod=marker")
    vim.api.nvim_command("setlocal foldlevel=0")
    vim.api.nvim_command("setlocal foldmarker={{{,}}}")
    vim.api.nvim_command("normal! G")

    if open then
      if focus ~= true then
        vim.api.nvim_command("wincmd p")
      end
    else
      vim.api.nvim_command("wincmd q")
    end

    return find_log(log_buf_name)
  end
end

-- Close the log window if it's open in the current tabpage.
function conjure.close_log(log_buf_name)
  local result = find_log_buf_and_win(log_buf_name)
  if result then
    local win_number = vim.api.nvim_win_get_number(result.win)
    vim.api.nvim_command(win_number .. "close!")
  end
end

return conjure
