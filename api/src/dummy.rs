#![feature(plugin)]
#![feature(custom_derive)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate diesel;
#[macro_use]
extern crate diesel_codegen;
#[macro_use]
extern crate serde_derive;
extern crate rocket;
extern crate rocket_contrib;
extern crate select;
extern crate md5;

use rocket_contrib::Template;

fn main() {
    println!("I'm just here to be a placeholder for docker compilation caching");
}
