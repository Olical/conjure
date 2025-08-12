// Evaluate all of this:
const add = (a: number, b: number) => a + b;

add(38, 4);

8 + 5;
(3 + 9 + 30) / 2;

// prints "hello" into the REPL
"hello";

// calling console.log prints a result to the REPL
console.log("hello world");

// a variable declaration
let a: string = "foo";
console.log(a);

let b = 3;
// REPL will throw type mismatch error
// add(a, b);
add(5, b);

// a variable can be changed
a = "bar";
a;

// a constant declaration
const c = "bazzz";
c;

// a constant can't be changed
// c = 1;

// a function can be declared and can print to the REPL from its body
function printToREPL(): string {
  for (let i = 0; i < 10; i++) {
    console.log(i);
  }

  return "success";
}

printToREPL();

// arrow function returns function
const arFn1 = () => (a: number, b: number) => a * b;
const mltp = arFn1();
mltp(2, 3);
mltp(3, 3);

// REPL can check types, so eval the line below will throw type mismatch error
// mltp(3, {});

// top level expressions are working as expected,
// printing from 0 to 4 into the REPL
for (let i = 0; i < 5; i++) {
  console.log(i);
}

// top level async/await is supported
const tlAsync = async (time: number) => {
  let _ = await new Promise((resolve) => setTimeout(resolve, time));
  return `after ${time}`;
};
await tlAsync(2000);

let arrowPlus = (a: number, b: number) => a + b;
arrowPlus(2, 3);

import { minus } from "../javascript/math.js";

minus(1, 2);

import type { IMoped } from "./moped.ts";

class Moped implements IMoped {
  wheels: number;
  engineDisplacement: number;

  constructor(wheels: number, engineDisplacement: number) {
    this.wheels = wheels;
    this.engineDisplacement = engineDisplacement;
  }

  countWheels() {
    return this.wheels;
  }

  getEngineDisplacement() {
    return this.engineDisplacement;
  }
}

let suzukiMoped: IMoped = new Moped(3, 1.0);
suzukiMoped;
suzukiMoped.countWheels();
suzukiMoped.getEngineDisplacement();

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
  changeName: function (n: any) {
    this.name = n;
  },
  changeAge: function (a: any) {
    this.age = a;
  },
  getName: function () {
    return this.name;
  },
  getAge: function () {
    return this.age;
  },
  toString: function () {
    return `${this.name} ${this.age}`;
  },
};

o;
o.changeName("Arola");

// This setTimeout shows a result in the REPL only when
// show_stray_out option is activated in the config.
// However, it can be activated dynamically in on of these ways:
// lua vim.g["conjure#client#javascript#stdio#show_stray_out"]=true
// in VIM's command-line mode and using the <localleader>ts key-mapping
setTimeout(() => {
  console.log("hi");
}, 300);

// Decorators seem to be working
type Constructor = {
  new(...args: any[]): {};
};

function frozen<T extends Constructor>(constructor: T) {
  Object.freeze(constructor);
  Object.freeze(constructor.prototype);

  const wrapper = class extends constructor {
    constructor(...args: any[]) {
      super(...args);
      Object.freeze(this);
    }
  };

  Object.freeze(wrapper);
  Object.freeze(wrapper.prototype);

  return wrapper;
}

function logMethod(originalMethod: any, context: ClassMethodDecoratorContext) {
  const methodName = String(context.name);

  return function (this: any, ...args: any[]) {
    console.log(`LOG: Entering method '${methodName}'.`);
    const result = originalMethod.call(this, ...args);
    console.log(`LOG: Exiting method '${methodName}'.`);
    return result;
  };
}

@frozen
class User {
  name: string;
  private surname: string;

  private email: string;

  constructor(name: string, surname: string, email: string) {
    this.name = name;
    this.surname = surname;
    this.email = email;
  }

  @logMethod
  showName() {
    return this.name;
  }

  showSurname() {
    return this.surname;
  }

  showEmail() {
    return this.email;
  }
}

Object.isFrozen(User);

const user1 = new User("Brenny", "Bendy", "benosaur@mail.kom");
user1.name = "Algenny";
user1;

user1.showName();

(user1 as any).newProp = "888";
user1;

(User as any).prototype.newMethod = () => { };
User.prototype;

// Enums are working
enum Commands {
  Open, Close, Clear, Init
}
let clearCommand: Commands = Commands.Clear;
clearCommand

// And string enums too
enum Direction {
  Up = "UP",
  Down = "DOWN",
  Left = "LEFT",
  Right = "RIGHT",
}
const upDir = Direction.Up;
upDir;

// Heterogeneous enums
enum BooleanLikeHeterogeneousEnum {
  No = 0,
  Yes = "YES",
}
BooleanLikeHeterogeneousEnum.Yes

// Enums with computed members
enum FileAccess {
  // constant members
  None,
  Read = 1 << 1,
  Write = 1 << 2,
  ReadWrite = Read | Write,
  // computed member
  G = "123".length,
}
FileAccess.ReadWrite

// Namespaces are supported
namespace UserModule {
  export interface User {
    username: string;
    email: string;
    isActive: boolean;
    describeUser(): string;
  }

  const emailRegexp = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  export class BasicUser implements User {
    public username: string;
    public email: string;
    public isActive: boolean;

    constructor(username: string, email: string) {
      this.username = username;
      this.email = email;
      this.isActive = this.validateEmail();
    }

    private validateEmail(): boolean {
      return emailRegexp.test(this.email);
    }

    public describeUser(): string {
      return `User: ${this.username}, Email: ${this.email}, Status: ${this.isActive ? "Active" : "Inactive"}`;
    }
  }

  export class AdminUser implements User {
    public username: string;
    public email: string;
    public isActive: boolean;
    public adminLevel: number;

    constructor(username: string, email: string, adminLevel: number) {
      this.username = username;
      this.email = email;
      this.isActive = this.validateAdmin();
      this.adminLevel = adminLevel;
    }

    private validateAdmin(): boolean {
      return this.adminLevel > 0;
    }

    public describeUser(): string {
      return `Admin: ${this.username}, Level: ${this.adminLevel}, Status: ${this.isActive ? "Active" : "Inactive"}`;
    }
  }
}
let userData = [
  { username: "john.doe", email: "john.doe@example.com", admin: false },
  { username: "jane.smith", email: "jane.smith", admin: false },
  { username: "super.admin", email: "super.admin@example.com", admin: true, adminLevel: 10 }
];
let users: UserModule.User[] = [];
for (let data of userData) {
  if (data.admin) {
    let admin = new UserModule.AdminUser(data.username, data.email, data.adminLevel || 0);
    users.push(admin);
  } else {
    let user = new UserModule.BasicUser(data.username, data.email);
    users.push(user);
  }
}
for (let user of users) {
  console.log(user.describeUser());
}

process.stderr.write("error! some error occurred");
