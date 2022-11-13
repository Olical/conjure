1 + 1

function add(x, y)
    println("x is $x and y is $y")

    # Functions return the value of their last statement
    x + y
end

add(5, 6)
# => x is 5 and y is 6
# => 11

# Compact assignment of functions
f_add(x, y) = x + y  # => f_add (generic function with 1 method)
f_add(3, 4)  # => 7

# Function can also return multiple values as tuple
fn(x, y) = x + y, x - y # => fn (generic function with 1 method)
fn(3, 4)  # => (7, -1)

# You can define functions that take a variable number of
# positional arguments
function varargs(args...)
    return args
    # use the keyword return to return anywhere in the function
end
# => varargs (generic function with 1 method)

varargs(1, 2, 3)  # => (1,2,3)

# The ... is called a splat.
# We just used it in a function definition.
# It can also be used in a function call,
# where it will splat an Array or Tuple's contents into the argument list.
add([5,6]...)  # this is equivalent to add(5,6)

x = (5, 6)  # => (5,6)
add(x...);  # this is equivalent to add(5,6)


# You can define functions with optional positional arguments
function defaults(a, b, x=5, y=6)
    return "$a $b and $x $y"
end
# => defaults (generic function with 3 methods)

defaults('h', 'g')  # => "h g and 5 6"
defaults('h', 'g', 'j')  # => "h g and j 6"
defaults('h', 'g', 'j', 'k')  # => "h g and j k"
