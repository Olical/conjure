// Examples from "Evcxr common usage information".
//   - https://github.com/evcxr/evcxr/blob/main/COMMON.md

// With the cursor on the word, pub, evaluate form works.
pub struct User {
    username: String
}

let user = User { username: String::from("John Doe") };
println!("{}", user.username);

// The REPL will accept commands that are not legal Rust statements.
// Select and evaluate this to load the rand crate from crates.io:
// :dep rand = { version = "0.7.3" }
let rand_x: u8 = rand::random();
println!("{}", rand_x);

// nice error reporting
let err_x = unknown();

let x = 0;
let y = 1;
// Select and evaluate this to see what variables have been defined:
// :vars

let all_values = vec![10, 20, 30, 40, 50];
//  This line with a semi-colon produces an error. Without the semi-colon, it's syntactically OK.
//  To verify this, make a selection and evaluate it.
//  With a form-node? function defined for the Rust client, we can evaluate the line
//  when the cursor is anywhere on the line except on the semi-colon. This sends the line without
//  the semi-colon.
all_values[2..3];

// This is an error because he variable `some_values` contains a reference with a non-static
// lifetime and can't be persisted.
let some_values = &all_values[2..3];
