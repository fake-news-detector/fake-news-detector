extern crate fake_news_api;

use std::env;
use fake_news_api::{run_job, start_server};

fn main() {
    let arg1 = env::args().nth(1);

    match arg1 {
        Some(command) => run_job(&*command),
        _ => start_server(),
    }
}
