# Should be able to evaluate all of these.

def add(a, b):
    return a + b


add(4, 29)

4 + 9

5 + 7 + 9

"hello"

print("hello world")

a = "foo"
print(a)

a, b = [1, 2]


def print_things_then_return():
    """
    Print things then return!
    """
    for i in range(4):
        print(i)
    return "all done!"


def newline_in_function_bug():
    return "hey\n\n" + "\\n" + "\n" + "ho"


newline_in_function_bug()

print_things_then_return()

for i in range(20):
    print(i)


def fn_with_multiline_str():
    description = """
    This is a super long,
    descriptive, multiline string.
    """
    print(f"Description: {description}")


fn_with_multiline_str()

import csv
from datetime import datetime


# Class definition
#   - from https://docs.python.org/3/tutorial/classes.html
class Dog:

    def __init__(self, name):
        self.name = name
        self.tricks = []

    def add_trick(self, trick):
        self.tricks.append(trick)

d = Dog('Fido')
e = Dog('Buddy')
d.add_trick('roll_over')
e.add_trick('play dead')
d.tricks
e.tricks


# Class definition with decorator
#   - from https://docs.python.org/3.10/tutorial/classes.html
from dataclasses import dataclass

@dataclass
class Employee:
    name: str
    dept: str
    salary: int

john = Employee('john', 'computer lab', 1000)
john.dept
john.salary


# Function definition with decorator
#   - https://docs.python.org/3.8/library/functools.html?highlight=decorator#functools.cached_property
from functools import lru_cache

@lru_cache(maxsize=None)
def fib(n):
    if n < 2:
        return n
    return fib(n-1) + fib(n-2)

[fib(n) for n in range(16)]
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]

fib.cache_info()
# CacheInfo(hits=28, misses=16, maxsize=None, currsize=16)


# Asyncio samples
#   - Add '-m asyncio' to the python command to evaluate these.

"""
async def slow_fn():
    return "slow_fn result, this is async!"


await slow_fn()

result = None


async def capture():
    global result
    result = await slow_fn()


await capture()
result
"""
