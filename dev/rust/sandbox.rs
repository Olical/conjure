// evaluate this root form
pub struct User {
    username: String
}
let user = User { username: String::from("John Doe") };
println!("{}", user.username);

// select and evaluate this:
// :dep rand = { version = "0.7.3" }
let rand_x: u8 = rand::random();
println!("{}", rand_x);

// nice error reporting
let err_x = unknown();

let x = 0;
let y = 1;
// select and evaluate this:
// :vars
//
let all_values = vec![10, 20, 30, 40, 50];
all_values[2..3];
