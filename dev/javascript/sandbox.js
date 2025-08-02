// Evaluate all of this:
const add = (a, b) => a + b;

add(38, 4);

8 + 5;
(3 + 9 + 30) / 2;

// prints "hello" into the REPL
("hello");

// calling console.log prints a result to the REPL
console.log("hello world");

// a variable declaration
let a = "foo";
console.log(a);

let b = 3;
add(a, b);

// a variable can be changed
a = "bar";
a;

// a constant declaration
const c = "bazzz";
c;

// a constant can't be changed
c = 1;

// a function can be declared and can print to the REPL from its body
function printToREPL() {
  for (let i = 0; i < 10; i++) {
    console.log(i);
  }

  return "success";
}

printToREPL();

// arrow function returns function
const arFn1 = () => (a, b) => a * b;
mltp = arFn1();
mltp(2, 3);
mltp(3, 3);

// top level expressions are working as expected,
// printing from 0 to 4 into the REPL
for (let i = 0; i < 5; i++) {
  console.log(i);
}

// top level async/await is supported
const tlAsync = async (time) => {
  let _ = await new Promise((resolve) => setTimeout(resolve, time));
  return `after ${time}`;
};
await tlAsync(2000);

let arrowPlus = (a, b) => a + b;
arrowPlus(2, 3);

// global imports are working as expected
import { readFileSync } from "node:fs";
readFileSync("./dev/javascript/math.js").toString();
path.resolve();

// local imports too
import { minus } from "./math.js";
minus(5, 1);
minus(1, 200);

// classes are supported
class Moped {
  wheels;
  engine;

  constructor(wheels, engine) {
    this.wheels = wheels;
    this.engine = engine;
  }

  countWheels() {
    return this.wheels;
  }

  engineDisplacement() {
    return this.engine;
  }
}

let suzukiMoped = new Moped(3, 1.0);
suzukiMoped;
suzukiMoped.countWheels();
suzukiMoped.engineDisplacement();

let array1 = [1, 2, 3, 4, 5, 6, 7, 8];

array1
  // just a comment
  .map((x) => x * 2)
  .map((x) => x + 3)
  /* multiline comments are ignored too */
  .map((x) => x / 6)
  .filter((x) => x > 1);

let o = {
  // Object with a comment inside
  name: "",
  age: 0,
  /* change name of the object */
  changeName: function (n) { this.name = n },
  changeAge: function (a) { this.age = a },
  getName: function () { return this.name },
  getAge: function () { return this.age },
  toString: function () { return `${name} ${age}` }
}

o
o.changeName("Arola");

process.stderr.write("error! some error occurred");
