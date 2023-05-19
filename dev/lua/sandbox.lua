-- Evaluate the entire block when cursor is anywhere in it.
local function add (a, b)
  return a + b
end

-- Evaluate function definition when cursor anywhere in it.
-- Otherwise, evaluate entire block.
local sub = function (a, b)
  return a - b
end

-- Evaluate statement when cursor anywhere in it.
sub(2, 42)

-- Evalutate if statement when cursor anywhere in it.
-- Otherwise evaluate entire block.
local function abs (a)
  if a < 0 then
    return -a
  else
    return a
  end
end

-- Evaluate function call when cursor anywhere in function call.
-- Otherwise evaluate print statement.
print(add(10, 20))
print(sub(10, 20))
print(abs(-20))
print(50 + 5)
print("Hello, World!")

-- Evaluate the entire statement when cursor is anywhere in it.
vim.fn.filereadable('/usr/bin/bash')
