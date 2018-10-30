pub mod prepl;
pub mod server;

use std::thread;

pub fn start() {
    let handles = vec![
        thread::spawn(|| {
            server::start();
        }),
        thread::spawn(|| {
            prepl::start();
        }),
    ];

    for handle in handles {
        handle.join().unwrap();
    }
}
