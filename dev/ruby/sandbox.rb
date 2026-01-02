# Should be able to evaluate all statements.

# From https://www.ruby-lang.org/en/about/
#   - Seeing Everything as an Object
5.times { print "We *love* Ruby -- it's outrageous!" }

# This should result in an error; undefined method 'plus'
5.plus 3

5+ 3 # 8
5 + 3 # 8

# form-node? can handle nested binary expressions but you must put
# your cursor on the right-most number or operator.
5 + 4 + 3 + 2 + 1 # 15
0.5 + 4 + 3 + 2 + 1 # 10.5

2 * 7 / 3 + 9 # 13

x = 2 * 7 / 3 + 9 # (out) x = 2 * 7 / 3 + 9
# => 13
puts 2 * 7 / 3 + 9


aNum = Numeric.new

# This should result in an error; undefined method '+'
aNum + 2

# After assignment, the '+' method is available.
aNum = 2 # 2

aNum + 2.0 # 4.0
aNum + 2 # 4

#  - Ruby’s Flexibility
#    Add a new method to an existing class.
class Numeric
  def plus(x)
    self.+(x)
  end
end # :plus

# 'plus' and '+' are methods of a Numeric.
y = 5.plus 6
5.plus 6 # 11
5.+ 6 # 11

#  form-node? recognizes the arguments of a function.
6 * 17.2 / 0.2 # 515.9999999999999
y = 5.plus 6 * 17.2 / 0.2
# y = 520.9999999999999

aNum
# => 2
aNum.plus 3 # 5

#   - Blocks: a Truly Expressive Feature
search_engines =
  %w[Google Yahoo MSN].map do |engine|
    "http://www." + engine.downcase + ".com"
  end
# search_engines = ["http://www.google.com", "http://www.yahoo.com", "http://www.msn.com"]

#  - Ruby and the Mixin
#    Modules are collections of methods.
class MyArray
end

MyArray.methods()
# [:allocate,
#  :superclass,
#  :subclasses,
#  :attached_object,
# ...
#  :!=,
#  :__id__,
#  :instance_eval,
#  :instance_exec]
MyArray.methods(false) # []

MyArray.instance_methods()
# [:pretty_print_cycle,
#  :pretty_print_instance_variables,
#  :pretty_print_inspect,
# ...
#  :!=,
#  :__id__,
#  :instance_eval,
#  :instance_exec]
MyArray.instance_methods(false) # []

#  Mixin some stuff.
class MyArray
  include Enumerable
end

# Can we tell how many methods are added when we include from mixin?
Enumerable.methods(false) # []
Enumerable.instance_methods(false)
# [:drop,
#  :drop_while,
#  :cycle,
# ...
#  :zip,
#  :take,
#  :take_while]

MyArray.methods()
# [:allocate,
#  :superclass,
#  :subclasses,
# ...
#  :!=,
#  :__id__,
#  :instance_eval,
#  :instance_exec]
MyArray.methods(false) # []
MyArray.instance_methods()
# [:drop,
#  :drop_while,
#  :cycle,
# ...
#  :zip,
#  :take,
#  :take_while,  <<--- From here and above are from Enumerable.
#  :pretty_print_cycle,
#  :pretty_print_instance_variables,
#  :pretty_print_inspect,
# ...
#  :!=,
#  :__id__,
#  :instance_eval,
#  :instance_exec]
MyArray.instance_methods(false) # []

# End of From https://www.ruby-lang.org/en/about/


#  Incorrect array expression
3 4 5]
# => (error) <internal:kernel>:168:in 'Kernel#loop': (irb):89: syntax errors found (SyntaxError)

[3 4 5]
# => (error) <internal:kernel>:168:in 'Kernel#loop': (irb):90: syntax errors found (SyntaxError)

#  Correct array expression
[3, 4, 5] # [3, 4, 5]


# Block comments
#   - https://docs.ruby-lang.org/en/master/syntax/comments_rdoc.html
=begin
   This is commented out.

   class Foo
   end

=end

#  =begin and =end can not be indented, so this is a syntax error:
class Foo
  =begin
  Will not work
  =end
end

# frozen strings
# https://stackoverflow.com/a/37799399
# `# frozen_string_literal: true` is supposed to make all string literals frozen.
# This works only if the magic comment is in the first comment section of a file.
var = 'hello'
var.frozen? # false
var.freeze()
var.frozen? # true
var << " not" # (error) (irb):29:in '<main>': can't modify frozen String: "hello" (FrozenError)

var2 = -var
var2.frozen? # true
var2 << " not" # (error) (irb):111:in '<main>': can't modify frozen String: "hello" (FrozenError)

var3 = +var
var3.frozen? # false
var3 << " not" # "hello not"


# From Ruby in Twenty Minutes
#   - https://www.ruby-lang.org/en/documentation/quickstart/

puts "Hello World"

3 ** 2

Math.sqrt(9)

a = 3 ** 2
b = 4 ** 2
Math.sqrt(a+b)

def hi
  puts "Hello World!"
end

#  - The Brief, Repetitive Lives of a Method
hi    # eval word or selection

hi()  # eval current-form

def hi(name)
  puts "Hello #{name}!"
end

hi("Matz")

#  - Holding Spots in a String
def hi(name = "World")
  puts "Hello #{name.capitalize}!"
end

# Eval these with selections:
hi "chris"
# (out) hi "chris"

hi
# (out) Hello World!

#  - Evolving Into a Greeter
class Greeter
  def initialize(name = "World")
    @name = name
  end
  def say_hi
    puts "Hi #{@name}!"
  end
  def say_bye
    puts "bye #{@name}, come back soon."
  end
end

greeter = Greeter.new("Pat")
greeter.say_hi
greeter.say_bye
#  This should be an error.
greeter.@name

#  - Under the Object’s Skin
Greeter.instance_methods
Greeter.instance_methods()

Greeter.instance_methods(false) # [:say_hi, :say_bye]

greeter.respond_to?("name") # false
greeter.respond_to?("say_hi") # true
greeter.respond_to?("to_s") # true

#  - Altering Classes—It’s Never Too Late
class Greeter
  attr_accessor :name
end

greeter = Greeter.new("Andy")
#  Access attribute
greeter.respond_to?("name") # true
#  Set attribute
greeter.respond_to?("name=") # true
#  Same as when evaluated with "()".
greeter.say_hi
#  This should update the name attribute.
greeter.name="Betty"
greeter
greeter.name
greeter.say_hi

#  - Cycling and Looping—a.k.a. Iteration
class MegaGreeter
  attr_accessor :names

  # Create the object
  def initialize(names = "World")
    @names = names
  end

  # Say hi to everybody
  def say_hi
    if @names.nil?
      puts "..."
    elsif @names.respond_to?("each")
      # @names is a list of some kind, iterate!
      @names.each do |name|
        puts "Hello #{name}!"
      end
    else
      puts "Hello #{@names}!"
    end
  end

  # Say bye to everybody
  def say_bye
    if @names.nil?
      puts "..."
    elsif @names.respond_to?("join")
      # Join the list elements with commas
      puts "Goodbye #{@names.join(", ")}.  Come back soon!"
    else
      puts "Goodbye #{@names}.  Come back soon!"
    end
  end
end

mg = MegaGreeter.new

# Evaluate with selection:
mg.say_hi
# (out) Hello World!
# => nil

mg.say_bye
# (out) Goodbye World.  Come back soon!
# => nil

mg.names # "World"
mg.names.respond_to?("each") # false
mg.names.respond_to?("join") # false

# Change the name to an array of names
mg.names = ["Albert", "Brenda", "Charles", "Dave", "Engelbert"]

# Evaluate with selection:
mg.say_hi
# (out) Hello Albert!↵Hello Brenda!↵Hello Charles!↵Hello Dave!↵Hello Engelbert!
# => ["Albert", "Brenda", "Charles", "Dave", "Engelbert"]
#
mg.say_bye
# (out) Goodbye Albert, Brenda, Charles, Dave, Engelbert.  Come back soon!
# => nil

